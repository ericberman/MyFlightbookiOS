/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2025 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  RecentFlights.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/9/23.
//

import Foundation

public class RecentFlights : PullRefreshTableViewControllerSW, LEEditDelegate, UIAlertViewDelegate, MFBSoapCallDelegate, QueryDelegate, NetworkManagementListener, RecentFlightsProtocol {
    public var fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
    
    private var dictImages : [NSNumber : CommentedImage] = [:]
    private var uploadInProgress = false
    private var ipSelectedCell : IndexPath? = nil
    private var JSONObjToImport : Any? = nil
    private var urlTelemetry : URL? = nil
    private var rgFlights : [MFBWebServiceSvc_LogbookEntry] = []
    private var rgPendingFlights : [MFBWebServiceSvc_PendingFlight] = []
    private var errorString = ""
    private var callsAwaitingCompletion = 0
    private var refreshOnResultsComplete = false
    private var offscreenCells : [String : RecentFlightCell] = [:]
    private var networkMgr : MFBNetworkManager!
    private var iFlightInProgress = 0
    private var cFlightsToSubmit = 0
    private var fCouldBeMoreFlights = true
    private var cellProgress : ProgressCell!
    private var activeSections : [rfSection] = []
    
    private let cFlightsPageSize = 15
    
    let dictLock = NSLock()
    
    enum rfSection : Int, CaseIterable {
        case sectFlightQuery = 0, sectUploadInProgress, sectUnsubmittedFlights, sectPendingFlights, sectExistingFlights
    }
    
    // MARK: - Get a recent flights view with a query
    public static func viewForFlightsMatching(query fq : MFBWebServiceSvc_FlightQuery?) -> UIViewController {
        let rf = RecentFlights(nibName: "RecentFlights", bundle: nil)
        if fq != nil {
            rf.fq = fq!
        }
        rf.refresh()
        return rf
    }
    
    // MARK: -  View lifecycle, management
    public override func viewDidLoad() {
        super.viewDidLoad()
        cellProgress = ProgressCell.getProgressCell(tableView)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        navigationItem.rightBarButtonItem = editButtonItem;
        
        // get notifications when the network is acquired or lost
        networkMgr = MFBNetworkManager(delegate: self)
        
        let app = MFBAppDelegate.threadSafeAppDelegate
        
        // get notifications when data is changed OR when user signs out
        app.registerNotifyDataChanged(self)
        app.registerNotifyResetAll(self)
        
        tableView.estimatedRowHeight = UIDevice.current.userInterfaceIdiom == .pad ? 80 : 44
        tableView.rowHeight = UITableView.automaticDimension
        navigationController?.isToolbarHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        // put the refresh button up IF we are the top controller
        // else, don't do anything with it because we need a way to navigate back
        if navigationController?.viewControllers[0] == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshObjC))
        } else {
            navigationItem.leftBarButtonItem = nil
        }
        navigationController?.isToolbarHidden = true
        
        loadThumbnails(rgFlights)   // this will run asynchronously
        
        if !MFBNetworkManager.shared.isOnLine && rgFlights.isEmpty && PackAndGo.lastFlightsPackDate != nil {
            rgFlights = PackAndGo.cachedFlights
            warnPackedData(PackAndGo.lastVisitedPackDate)
        }
        super.viewWillAppear(animated)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MFBNetworkManager.shared.isOnLine && (hasUnsubmittedFlights || !fIsValid || rgFlights.isEmpty) {
            refresh()
        } else {
            tableView.reloadData()
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        invalidateViewController()
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
    }
    
    // MARK: - LEEditDelegate delegate
    public func flightUpdated(_ sender: LogbookEntryBaseTableViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Refreshing
    func warnPackedData(_ dtLastPack : NSDate?) {
        if let dt = dtLastPack as? Date {
            let df = DateFormatter()
            df.dateStyle = .short
            showError(String(format: String(localized: "PackAndGoUsingCached", comment: "Pack and go - Using Cached"), df.string(from: dt)),
                      withTitle: String(localized: "PackAndGoOffline", comment: "Pack and go - Using Cached"))
        }
    }
    
    func refresh(_ fSubmitUnsubmittedFlights : Bool) {
        let dtLastPack = PackAndGo.lastFlightsPackDate
        if !MFBNetworkManager.shared.isOnLine {
            if dtLastPack != nil {
                rgFlights = PackAndGo.cachedFlights
                rgPendingFlights = [];   // no pending flights with pack-and-go
                tableView.reloadData()
                fIsValid = true
                warnPackedData(dtLastPack)
            } else {
                errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
                showError(errorString, withTitle:String(localized: "Error loading recent flights", comment: "Title for error message on recent flights"))
            }
            return
        }
        
        dictLock.lock()
        dictImages.removeAll()
        dictLock.unlock()
        rgFlights.removeAll()
        rgPendingFlights.removeAll()
        
        // Issue #332 - Reset high-water marks
        Aircraft.sharedAircraft.clearHighWater()        
        
        fCouldBeMoreFlights = true
        let app = MFBAppDelegate.threadSafeAppDelegate
        app.invalidateCachedTotals()
        
        // if we are forcing a resubmit, clear any errors and resubmit; this will cause
        // loadFlightsForUser to be called (refreshing the existing flights.)
        // Otherwise, just do the refresh directly.
        if fSubmitUnsubmittedFlights && hasUnsubmittedFlights {
            // clear the errors from unsubmitted flights so that they can potentially go again.
            for le in app.rgUnsubmittedFlights {
                (le as? LogbookEntry)!.errorString = ""
            }
            submitUnsubmittedFlights()
        } else {
            tableView.reloadData()    // this should trigger refresh simply by displaying the trigger row.
        }
    }
    
    public override func refresh() {
        refresh(true)
    }
    
    @objc func refreshObjC() {
        refresh(true)
    }
    
    // MARK: - Invalidatable
    public override func invalidateViewController() {
        rgFlights.removeAll()
        rgPendingFlights.removeAll()
        dictLock.lock()
        dictImages.removeAll()
        dictLock.unlock()
        fCouldBeMoreFlights = true
        fIsValid = false
    }
    
    // MARK: View a flight
    func pushViewControllerForFlight(_ le : LogbookEntry) {
        let leView = LEEditController.editorForFlight(le, delegate: self)
        navigationController?.pushViewController(leView, animated: true)
    }
    
    // MARK: -  Managing simultaneous calls
    /*
     This is a bit of a hack, but because of committing flights and simultenous outstanding calls to pendingflights and flightswithquery, we can have multiple calls awaiting results.
     This can also lead to two race conditions.
     
     The first is just general badness where the pending flights call returns quickly and resets callInProgress, so the table reloads and because callInProgress is NO,
     it triggers a second (or third or fourth) call to flightsWithQuery.  ouch!
     
     The second is a race condition:
     - View appears, which causes reload, which causes flightsWithQuery call
     - Also needs to submit an unsubmittedflight, so it submits this
     - Submission returns quickly, so it calls refresh, but refresh no-ops because it already has a call outstanding.
     
     The fix for this is to count the number of outstanding requests.  For the latter, we'll also allow a flag saying "hey, when all requests finish, do one more refresh.  (That's the hack).
     */
    
    let pendingCallLock = NSLock()
    
    func addPendingCall() {
        pendingCallLock.lock()
        callInProgress = true
        callsAwaitingCompletion += 1
        NSLog("RECENT FLIGHTS ADD PENDING CALL, count = \(callsAwaitingCompletion)")
        pendingCallLock.unlock()
    }
    
    func removePendingCall() {
        pendingCallLock.lock()
        callsAwaitingCompletion -= 1
        callInProgress = callsAwaitingCompletion != 0
        if callsAwaitingCompletion < 0 {
            fatalError("negative calls pending completion!")
        }
        NSLog("RECENT FLIGHTS REMOVE PENDING CALL, count = \(callsAwaitingCompletion)")
        pendingCallLock.unlock()
        
        if !callInProgress && refreshOnResultsComplete {
            refreshOnResultsComplete = false
            refresh(false)
        }
    }
    
    // MARK: -  Loading recent flights / infinite scroll
    func loadFlightsForUser() {
        errorString = ""
        
        if !fCouldBeMoreFlights || callInProgress {
            return
        }
        
        let authtoken = MFBProfile.sharedProfile.AuthToken
        if authtoken.isEmpty {
            errorString = String(localized: "You must be signed in to view recent flights.", comment: "Error - must be signed in to view flights")
            showError(errorString, withTitle:String(localized: "Error loading recent flights", comment: "Title for error message on recent flights"))
            fCouldBeMoreFlights = false
        } else if !MFBNetworkManager.shared.isOnLine {
            errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
            showError(errorString, withTitle:String(localized: "Error loading recent flights", comment: "Title for error message on recent flights"))
            fCouldBeMoreFlights = false
        } else {
            addPendingCall()
            
            let fbdSVC = MFBWebServiceSvc_FlightsWithQueryAndOffset()
            
            fbdSVC.szAuthUserToken = authtoken;
            fbdSVC.fq = fq;
            fbdSVC.offset = NSNumber(integerLiteral: rgFlights.count)
            fbdSVC.maxCount = NSNumber(integerLiteral: cFlightsPageSize)
            
            let sc = MFBSoapCall(delegate: self)
            
            sc.makeCallAsync { b, sc in
                b.flightsWithQueryAndOffsetAsync(usingParameters: fbdSVC, delegate: sc)
            }
            
            // Get pending flights as well, but only on first refresh because we already have all of the pending flights from the previous (offset=0) call
            if fbdSVC.offset.intValue == 0 && fq.isUnrestricted() {
                addPendingCall()
                let pfu = MFBWebServiceSvc_PendingFlightsForUser()
                pfu.szAuthUserToken = authtoken
                
                sc.makeCallAsync { b, sc in
                    b.pendingFlightsForUserAsync(usingParameters: pfu, delegate: sc)
                }
            }
        }
    }
    
    func deletePendingFlight(_ pf : MFBWebServiceSvc_PendingFlight) {
        if callInProgress {
            return
        }
        
        let authtoken = MFBProfile.sharedProfile.AuthToken
        if authtoken.isEmpty {
            errorString = String(localized: "You must be signed in to perform this action", comment: "Error - must be signed in")
            showError(errorString, withTitle:String(localized: "Error loading recent flights", comment: "Title for error message on recent flights"))
        } else if !MFBNetworkManager.shared.isOnLine {
            errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
            showError(errorString, withTitle:String(localized: "Error deleting flight", comment: "Title for error message when flight delete fails"))
        } else {
            addPendingCall()
            
            let dpfSvc = MFBWebServiceSvc_DeletePendingFlight()
            dpfSvc.szAuthUserToken = authtoken
            dpfSvc.idpending = pf.pendingID
            
            let sc = MFBSoapCall(delegate: self)
            
            sc.makeCallAsync { b, sc in
                b.deletePendingFlightAsync(usingParameters: dpfSvc, delegate: sc)
            }
        }
    }
    
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse {
            let rgIncrementalResults = resp.flightsWithQueryAndOffsetResult.logbookEntry as! [MFBWebServiceSvc_LogbookEntry]
            fCouldBeMoreFlights = rgIncrementalResults.count >= cFlightsPageSize
            rgFlights.append(contentsOf: rgIncrementalResults)
            
            // Update any high-water mark tach/hobbs
            let aircraft = Aircraft.sharedAircraft
            for le in rgFlights {
                aircraft.setHighWaterHobbs(le.hobbsEnd, forAircraft: le.aircraftID)
                if let cfp = le.getExistingProperty(.tachEnd) {
                    aircraft.setHighWaterTach(cfp.decValue, forAircraft: le.aircraftID)
                }
                if let cfp = le.getExistingProperty(.flightMeterEnd) {
                    aircraft.setHighWaterFlightMeter(cfp.decValue, forAircraft: le.aircraftID)
                }
            }
            NSLog("RECENT FLIGHTS: Flight List Result Received")

            loadThumbnails(rgIncrementalResults)
        } else if let resp = body as? MFBWebServiceSvc_PendingFlightsForUserResponse {
            NSLog("RECENT FLIGHTS: Pending Flights Received")

            rgPendingFlights = resp.pendingFlightsForUserResult.pendingFlight as! [MFBWebServiceSvc_PendingFlight]
        } else if let resp = body as? MFBWebServiceSvc_DeletePendingFlightResponse {
            rgPendingFlights = resp.deletePendingFlightResult.pendingFlight as! [MFBWebServiceSvc_PendingFlight]
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        if !errorString.isEmpty {
            showError(errorString, withTitle:String(localized: "Error loading recent flights", comment: "Title for error message on recent flights"))
            fCouldBeMoreFlights = false
        }
        removePendingCall()
        
        fIsValid = true
        
        if isLoading {
            stopLoading()
        }
        
        tableView.reloadData()
        
        // update the glance.
        if fq.isUnrestricted() && !rgFlights.isEmpty {
            MFBAppDelegate.threadSafeAppDelegate.watchData?.latestFlight = rgFlights[0].toSimpleItem(fHHMM: UserPreferences.current.HHMMPref)
        }
        // Issue #380 - look for newly added aircraft
        let ac = Aircraft.sharedAircraft
        var needsRefresh = false
        for f in rgFlights {
            if ac.indexOfAircraftID(f.aircraftID.intValue) < 0 {
                needsRefresh = true
                break
            }
        }
        if needsRefresh {
            ac.invalidateCachedAircraft()
            ac.refreshIfNeeded()
        }
    }
    
    // MARK: - Thumbnails
    func loadThumbnails(_ flights : [MFBWebServiceSvc_LogbookEntry]?) {
        if flights == nil || flights!.isEmpty || !UserPreferences.current.showFlightImages {
            return
        }
        
        
        DispatchQueue.global(qos: .background).async {
            for le in flights! {
                // crash if you store into a dictionary using nil, so check for that
                self.dictLock.lock()
                let fSkip = le.flightID == nil || self.dictImages[le.flightID] != nil
                self.dictLock.unlock()
                if fSkip {
                    continue
                }
                
                let ci = CommentedImage()
                if le.flightImages.mfbImageInfo.count > 0 {
                    ci.imgInfo = le.flightImages.mfbImageInfo[0] as? MFBWebServiceSvc_MFBImageInfo
                } else {
                    // try to get an aircraft image
                    let ac = Aircraft.sharedAircraft.AircraftByID(le.aircraftID.intValue)
                    if ac != nil && ac!.aircraftImages.mfbImageInfo.count > 0 {
                        ci.imgInfo = ac!.aircraftImages.mfbImageInfo[0] as? MFBWebServiceSvc_MFBImageInfo
                    } else {
                        ci.imgInfo = nil
                    }
                }
                
                ci.GetThumbnail()
                self.dictLock.lock()
                self.dictImages[le.flightID] = ci
                self.dictLock.unlock()
            }
            
            // don't refresh the UI until we've loaded them all, just to avoid excessive herky-jerky refresh
            DispatchQueue.main.async {
                self.reload()
            }
        }
    }
    
    // MARK: - UnsubmittedFlights
    var hasUnsubmittedFlights : Bool {
        get {
            return MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights.count > 0
        }
    }
    
    func submitUnsubmittedFlightsCompleted(_ sc : MFBSoapCall?, fromCaller le : LogbookEntry) {
        let app = MFBAppDelegate.threadSafeAppDelegate;
        NSLog("RECENT FLIGHTS: submitUnsubmittedFlightsCompleted")
        if le.errorString.isEmpty && !le.entryData.isQueued() { // success
            app.dequeueUnsubmittedFlight(le)
            iRate.sharedInstance().logEvent(false)  // ask user to rate the app if they have saved the requesite # of flights
            NSLog("iRate eventCount: \(iRate.sharedInstance().eventCount), uses: \(iRate.sharedInstance().usesCount)")
            tableView.reloadData()
        }
        
        iFlightInProgress += 1
        
        if (iFlightInProgress >= cFlightsToSubmit) {
            NSLog("RECENT FLIGHTS: No more flights to submit");
            uploadInProgress = false
            if callInProgress {
                refreshOnResultsComplete = true
            }
            else {
                refresh(false)
            }
        } else {
            NSLog("RECENT FLIGHTS: submitting next flight")
            submitUnsubmittedFlight()
        }
    }
    
    func submitUnsubmittedFlight() {
        let progressValue = (Float(iFlightInProgress) + 1.0) / Float(cFlightsToSubmit)
        
        cellProgress.progressBar.progress = progressValue
        let flightTemplate = String(localized: "Flight %d of %d", comment: "Progress message when uploading unsubmitted flights")
        cellProgress.progressLabel.text = String(format: flightTemplate, iFlightInProgress + 1, cFlightsToSubmit)
        cellProgress.progressDetailLabel.text = ""
        
        // Take this off of the BACK of the array, since we're going to remove it if successful and don't want to screw up
        // the other indices.
        let app = MFBAppDelegate.threadSafeAppDelegate;
        let index = cFlightsToSubmit - iFlightInProgress - 1;
        if index >= app.rgUnsubmittedFlights.count { // should never happen.
            NSLog("RECENT FLIGHTS: index \(index) is greater than app.rgUnsubmittedFlights.count (\(app.rgUnsubmittedFlights.count))")
            return
        }
        
        NSLog("iFlight=\(iFlightInProgress), cFlights=\(cFlightsToSubmit), rgCount=\(app.rgUnsubmittedFlights.count), index=\(index)")
        
        let le = app.rgUnsubmittedFlights[index] as! LogbookEntry
        
        if !le.entryData.isQueued() && le.errorString.isEmpty { // no holdover error
            le.szAuthToken = MFBProfile.sharedProfile.AuthToken
            le.progressLabel = cellProgress.progressDetailLabel
            le.setDelegate(self) { sc, ao in
                NSLog("RECENT FLIGHTS: Commit le completed")
                self.removePendingCall()
                self.submitUnsubmittedFlightsCompleted(sc, fromCaller: ao as! LogbookEntry)
            }
            
            addPendingCall()
            do {
                NSLog("RECENT FLIGHTS: Commit le starting")
                try le.commitFlight()
            } catch {
                showErrorAlertWithMessage(msg: error.localizedDescription)
            }
        }
        else  {// skip the commit on this; it needs to be fixed - just go on to the next one.
            submitUnsubmittedFlightsCompleted(nil, fromCaller: le)
        }
    }
    
    func submitUnsubmittedFlights() {
        if !hasUnsubmittedFlights || !MFBNetworkManager.shared.isOnLine || uploadInProgress {
            return
        }
        
        NSLog("RECENT FLIGHTS : SubmitUnsubmitted, uploadInProgress is \(uploadInProgress ? "TRUE" : "FALSE")")
        
        cFlightsToSubmit = MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights.count
        
        if cFlightsToSubmit == 0 {
            return
        }
        
        uploadInProgress = true
        iFlightInProgress = 0;
        tableView.reloadData()
        
        submitUnsubmittedFlight()
    }
    
    // MARK: - Table view data source
    func refreshActiveSections() {
        /*
         Layout is:
         FlightQuery  - always visible
         (upload progress)
         (unsubmittedflights)
         (pendingflights)
         Existing flights
         
         We refresh this and cache in self.activeSessions because unsubmittedflihts or uploadinprogress can change between calls to numberofsectionsintableview and sectionfromindexpathsection.
         */
        activeSections.removeAll()
        activeSections.append(.sectFlightQuery)  // Query - always visible
        
        if uploadInProgress {
            activeSections.append(.sectUploadInProgress)
        }
        if hasUnsubmittedFlights {
            activeSections.append(.sectUnsubmittedFlights)
        }
        if !rgPendingFlights.isEmpty && fq.isUnrestricted() {
            // don't show pending flights if we have an active query.
            activeSections.append(.sectPendingFlights)
        }
        activeSections.append(.sectExistingFlights)
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        refreshActiveSections()
        return activeSections.count
    }
    
    // Customize the number of rows in the table view
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeSections[section] {
        case .sectFlightQuery:
            return MFBNetworkManager.shared.isOnLine ? 1 : 0
        case .sectUploadInProgress:
            return uploadInProgress ? 1 : 0
        case .sectUnsubmittedFlights:
            return MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights.count
        case .sectPendingFlights:
            return fq.isUnrestricted() ? rgPendingFlights.count : 0
        case .sectExistingFlights:
            return rgFlights.count + (MFBNetworkManager.shared.isOnLine && (callInProgress || fCouldBeMoreFlights) ? 1 : 0)
        }
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch activeSections[section] {
        case .sectExistingFlights:
            return rgFlights.isEmpty ? String(localized: "No flights found for selected dates.", comment: "No flights found in date range") :
            String(localized: "Recent Flights", comment: "Title for list of recent flights")
        case .sectUnsubmittedFlights:
            return String(localized: "Flights awaiting upload", comment: "Title for list of flights awaiting upload")
        case  .sectPendingFlights:
            return String(localized: "PendingFlightsHeader", comment: "Title for list of pending flights")
        case .sectUploadInProgress, .sectFlightQuery:
            return ""
        }
    }
    
    func flightForIndexPath(_ indexPath : IndexPath) -> MFBWebServiceSvc_LogbookEntry? {
        let section = activeSections[indexPath.section]
        if section == .sectPendingFlights {
            return rgPendingFlights[indexPath.row]
        } else if section == .sectExistingFlights && indexPath.row < rgFlights.count {
            return rgFlights[indexPath.row]
        }
        return nil
    }
    
    func rowTypeForFlight(_ le : MFBWebServiceSvc_LogbookEntry) -> recentFlightRowType {
        let fShowImages = UserPreferences.current.showFlightImages
        let fShowSig = le.cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid || le.cfiSignatureState == MFBWebServiceSvc_SignatureState_Invalid
        return fShowImages ? (fShowSig ? .textSigAndImage : .textAndImage) : (fShowSig ? .textAndSig : .textOnly);
    }
    
    func reuseIDForRowtype(_ rt : recentFlightRowType) -> String {
        let RFCellIdentifierText = "recentFlightCellText"
        let RFCellIdentifierSig = "recentFlightCellSig"
        let RFCellIdentifierImg = "recentFlightCellImg"
        let RFCellIdentifierImgSig = "recentflightcellSigAndImg"

        switch rt {
        case .textOnly:
            return RFCellIdentifierText
        case .textAndSig:
            return RFCellIdentifierSig
        case .textAndImage:
            return RFCellIdentifierImg
        case .textSigAndImage:
            return RFCellIdentifierImgSig
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var le : MFBWebServiceSvc_LogbookEntry? = nil
        var ci : CommentedImage? = nil
        var errString = ""
        
        let section = activeSections[indexPath.section]
        
        switch section {
        case .sectFlightQuery:
            let CellQuerySelector = "querycell"
            let cellSelector = tableView.dequeueReusableCell(withIdentifier: CellQuerySelector) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellQuerySelector)
            cellSelector.accessoryType = .disclosureIndicator;
            
            var config = cellSelector.defaultContentConfiguration()
            config.text =  String(localized: "FlightSearch", comment: "Choose Flights")
            if (fq.isUnrestricted()) {
                config.secondaryText = String(localized: "All Flights", comment: "All flights are selected")
                cellSelector.backgroundColor = UIColor.systemBackground
            } else {
                config.secondaryText = String(localized: "Not all flights", comment: "Not all flights are selected")
                config.secondaryTextProperties.adjustsFontSizeToFitWidth = true
                config.secondaryTextProperties.font = UIFont.boldSystemFont(ofSize: config.secondaryTextProperties.font.pointSize)
                cellSelector.backgroundColor = UIColor.secondarySystemBackground
            }
            config.image = UIImage(named: "search.png")
            cellSelector.contentConfiguration = config
            return cellSelector
        case .sectUploadInProgress:
            return cellProgress
        case .sectPendingFlights:
            le = flightForIndexPath(indexPath)
        case .sectUnsubmittedFlights:
            // We could have a race condition where we are fetching a flight after it has been submitted.
            let l = MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights[indexPath.row] as! LogbookEntry
            
            ci = l.rgPicsForFlight.count > 0 ? l.rgPicsForFlight[0] as? CommentedImage : nil
            le = l.entryData
            errString = l.errorString
        case .sectExistingFlights:
            if indexPath.row >= rgFlights.count {   // is this the row to trigger the next batch of flights?
                loadFlightsForUser()  // get the next batch
                return waitCellWithText(String(localized: "Getting Recent Flights...", comment: "Progress - getting recent flights"))
            }
            
            le = flightForIndexPath(indexPath)
            dictLock.lock()
            ci = le!.flightID == nil ? nil : dictImages[le!.flightID]
            dictLock.unlock()
        }
        
        // if we are here, we'd better have initialized le
        assert(le != nil)
        
        let rt = rowTypeForFlight(le!)
        let identifier = reuseIDForRowtype(rt)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RecentFlightCell ?? RecentFlightCell.newRecentFlightCell(rowType: rt)
        
        if le!.tailNumDisplay == nil {
            le!.tailNumDisplay = Aircraft.sharedAircraft.AircraftByID(le!.aircraftID.intValue)?.tailNumber ?? ""
        }
        
        var isColored = false

        let flightColor = (le?.flightColorHex ?? "").isEmpty ? nil : UIColor(hex: le!.flightColorHex!)
        if section == .sectUnsubmittedFlights || section == .sectPendingFlights {
            cell.backgroundColor = UIColor.systemGray4
        } else if flightColor != nil {
            isColored = true
            cell.backgroundColor = flightColor
        }

        // this will force a layout
        cell.setFlight(le!, image: ci, errorString: errString, tableView: tableView, isColored: isColored)

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return default heights if it's OTHER than a pending flight or existing flight - which we can tell by nil le
        let l = flightForIndexPath(indexPath)
        if l == nil {
            return tableView.rowHeight
        }
        
        let le = l! // if we're here, l is non-nil
        
        dictLock.lock()
        let ci = (le.flightID == nil || le is MFBWebServiceSvc_PendingFlight) ? nil : dictImages[le.flightID]
        dictLock.unlock()
        
        // Determine which reuse identifier should be used for the cell at this
        // index path.
        let rt = rowTypeForFlight(le)
        let reuseIdentifier = reuseIDForRowtype(rt)

        // Use a dictionary of offscreen cells to get a cell for the reuse
        // identifier, creating a cell and storing it in the dictionary if one
        // hasn't already been added for the reuse identifier. WARNING: Don't
        // call the table view's dequeueReusableCellWithIdentifier: method here
        // because this will result in a memory leak as the cell is created but
        // never returned from the tableView:cellForRowAtIndexPath: method!
        
        if offscreenCells[reuseIdentifier] == nil {
            offscreenCells[reuseIdentifier] = RecentFlightCell.newRecentFlightCell(rowType: rt)
        }
        let cell = offscreenCells[reuseIdentifier]! // had better be there now!

        // Configure the cell with content for the given indexPath.  This will force a layout
        cell.setFlight(le, image: ci, errorString: "", tableView: tableView, isColored: false)

        // Get the actual height required for the cell's contentView
        var height = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height;

        // Add an extra point to the height to account for the cell separator,
        // which is added between the bottom of the cell's contentView and the
        // bottom of the table view cell.
        height += 1.0

        return height
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if callInProgress || isLoading {
            return
        }
        
        var le : LogbookEntry? = nil;
        
        switch activeSections[indexPath.section] {
        case .sectFlightQuery:
            assert(indexPath.row == 0, "Flight query row must only have one row!")
            let fqf = FlightQueryForm(style: .grouped)
            fqf.delegate = self
            fqf.query = fq
            navigationController?.pushViewController(fqf, animated:true)
            return
        case .sectUploadInProgress:
            return
        case .sectExistingFlights:
            le = LogbookEntry()
            le!.entryData = rgFlights[indexPath.row]
        case .sectPendingFlights:
            le = LogbookEntry()
            le!.entryData = rgPendingFlights[indexPath.row]
        case .sectUnsubmittedFlights:
            le = MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights[indexPath.row] as? LogbookEntry
        }
        
        assert(le != nil, "Unable to find the flight to display!");
        pushViewControllerForFlight(le!)
    }
     
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch activeSections[indexPath.section] {
        case .sectFlightQuery, .sectUploadInProgress:
            return false
        case .sectExistingFlights:
            return indexPath.row < rgFlights.count    // don't allow delete of the "Getting additional flights" row
        case .sectUnsubmittedFlights:
            return !callInProgress;    // Issue #245: don't allow deletion of flight being uploaded
        case .sectPendingFlights:
            return true
        }
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ipSelectedCell = indexPath;
            let alert = UIAlertController(title: String(localized: "Confirm Deletion", comment: "Title of confirm message to delete a flight"),
                                    message:String(localized: "Are you sure you want to delete this flight?  This CANNOT be undone!", comment: "Delete Flight confirmation"),
                                      preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel))
            alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"),
                                          style:.destructive) { uaa in
                let app = MFBAppDelegate.threadSafeAppDelegate
                let le = LogbookEntry()
                
                let rs = self.activeSections[indexPath.section]
                
                if (rs == .sectExistingFlights) {
                    // deleting an existing flight
                    le.szAuthToken = MFBProfile.sharedProfile.AuthToken
                    let leToDelete = self.rgFlights[indexPath.row]
                    let idFlightToDelete = leToDelete.flightID.intValue
                    
                    self.dictLock.lock()
                    self.dictImages.removeValue(forKey: leToDelete.flightID)
                    self.dictLock.unlock()
                    self.rgFlights.remove(at: indexPath.row)
                    
                    le.setDelegate(self) { sc, ao in
                        if (sc?.errorString ?? "").isEmpty {
                            self.refresh() // will call invalidatecached totals
                        } else {
                            let szError = "\(String(localized: "Unable to delete the flight.", comment: "Error deleting flight")) \(sc?.errorString ?? "")"
                            self.showAlertWithTitle(title: String(localized: "Error deleting flight", comment: "Title for error message when flight delete fails"), message: szError)
                        }
                    }
                    le.deleteFlight(idFlightToDelete)
                } else if rs == .sectUnsubmittedFlights {
                    app.dequeueUnsubmittedFlight(app.rgUnsubmittedFlights[indexPath.row] as! LogbookEntry)
                } else if rs == .sectPendingFlights {
                    self.deletePendingFlight(self.rgPendingFlights[indexPath.row])
                }
                self.ipSelectedCell = nil
                tableView.reloadData()
            })
            present(alert, animated:true, completion:nil)
        }
    }
     
    // MARK: -  QueryDelegate
    public func queryUpdated(_ f: MFBWebServiceSvc_FlightQuery) {
        fq = f
        refresh()
    }
    
    // MARK: -  NetworkManagementListener Delegate
    public func newState(_ newState: NetworkStatus) {
        if uploadInProgress {
            return
        }
        
        NSLog("RecentFlights: Network acquired - submitting any unsubmitted flights")
        fCouldBeMoreFlights = true
        DispatchQueue.main.async {
            self.submitUnsubmittedFlights()
        }
    }
    
    // MARK: -  Add flight via URL
    public func addJSONFlight(_ szJSON: String) {
        do {
            JSONObjToImport = try JSONSerialization.jsonObject(with: szJSON.data(using: .utf8)!, options: .mutableContainers)
        }
        catch {
            showErrorAlertWithMessage(msg: error.localizedDescription)
            JSONObjToImport = nil
            return
        }

        // get the name of the requesting app.
        if let dictRoot = JSONObjToImport as? [String : Any] {
            if let dictMeta = dictRoot["metadata"] as? [String : Any] {
                if let szApplication = dictMeta["application"] as? String {
                    
                    let alert = UIAlertController(title: "", message: String(format: String(localized: "AddFlightPrompt", comment: "Import Flight"), szApplication), preferredStyle:.alert)
                    alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel))
                    alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style:.default) { uaa in
                        LogbookEntry.addPendingJSONFlights(self.JSONObjToImport! as AnyObject)
                        self.JSONObjToImport = nil
                        self.tableView.reloadData()
                    })
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    // MARK: -  Add flight via Telemetry
    public func addTelemetryFlight(_ url: URL) {
        urlTelemetry = url
        
        let alert = UIAlertController(title: "", message: String(localized: "InitFromTelemetry", comment: "Import Flight Telemetry"), preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel))
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style:.default) { uaa in
            self.presentProgressAlert(message: String(localized: "ActivityInProgress", comment: "Activity In Progress"))
            DispatchQueue.global().async {
                let le = GPSSim.ImportTelemetry(self.urlTelemetry!)
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                    if (le == nil) {
                        return
                    }
                    
                    // Check for an existing new flight in-progress.
                    // If the new flight screen is sitting with an initial hobbs but otherwise empty, then use its starting hobbs and then reset it.
                    let leMain = (MFBAppDelegate.threadSafeAppDelegate.getActiveTabBar()!.leMain as? LEEditController)!
                    let leActiveNew = leMain.le.entryData
                    let fIsInInitialState = leActiveNew.isInInitialState()
                    let initHobbs = fIsInInitialState ? leActiveNew.hobbsStart : NSNumber(floatLiteral: 0.0)
                    
                    le!.entryData.hobbsStart = initHobbs
                    let lev = LEEditController.editorForFlight(le!, delegate: self)
                    lev.autoHobbs()
                    lev.autoTotal()
                    
                    /// Carry over the ending hobbs as the new starting hobbs for the flight.
                    if fIsInInitialState {
                        leMain.le.entryData.hobbsStart = lev.le.entryData.hobbsEnd
                    }
                    
                    self.navigationController?.pushViewController(lev, animated: true)

                    self.urlTelemetry = nil
                    self.tableView.reloadData()
                }
            }
        })
        present(alert, animated: true)
    }
}
