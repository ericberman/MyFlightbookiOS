/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2023 MyFlightbook, LLC
 
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
//  LEEditController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/6/23.
//

import Foundation
import QuartzCore
import MobileCoreServices

public class LEEditController : LogbookEntryBaseTableViewController, EditPropertyDelegate, AutoDetectDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, LEControllerProtocol {
    
    private var timerElapsed : Timer!
    private var dictPropCells : [NSNumber : PropertyCell] = [:]
    private var digitizedSig : UIImage? = nil
    private var selectibleAircraft : [MFBWebServiceSvc_Aircraft] = []
    private var propDatePicker = UIDatePicker()
    
    private let _szKeyCachedImageArray = "cachedImageArrayKey"
    private let _szkeyITCCollapseState = "keyITCCollapseState"
    
    private var heightDateTail : CGFloat!
    private var heightComments : CGFloat!
    private var heightRoute : CGFloat!
    private var heightLandings : CGFloat!
    private var heightGPS : CGFloat!
    private var heightTimes : CGFloat!
    private var heightSharing : CGFloat!
    
    private static let rgAllCockpitRows : [leRow] = [.rowCockpitHeader, .rowGPS, .rowTachStart, .rowHobbsStart, .rowEngineStart, .rowBlockOut, .rowFlightStart, .rowFlightEnd, .rowBlockIn, .rowEngineEnd, .rowHobbsEnd, .rowTachEnd]
    private let dfSunriseSunset = DateFormatter()

    enum leSection : Int, CaseIterable {
        case sectGeneral = 0, sectInCockpit, sectTimes, sectProperties, sectSignature, sectImages, sectSharing
    }
    
    enum  leRow : Int, CaseIterable {
        case rowDateTail = 0, rowComments, rowRoute, rowLandings,
        rowCockpitHeader, rowGPS, rowTachStart, rowHobbsStart, rowEngineStart, rowBlockOut, rowFlightStart, rowFlightEnd, rowBlockIn, rowEngineEnd, rowHobbsEnd, rowTachEnd,
        rowTimes, rowPropertiesHeader, rowNthProperty, rowAddProperties, rowSigHeader, rowSigState, rowSigComment, rowSigValidity,
        rowImagesHeader, rowNthImage, rowSharingHeader, rowSharing
    }
    
    enum nextTime : Int, CaseIterable {
        case timeHobbsStart = 0, timeEngineStart, timeFlightStart, timeFlightEnd, timeEngineEnd, timeHobbsEnd, timeNone
    }

    
    let rowGeneralFirst = leRow.rowDateTail.rawValue
    let rowGeneralLast = leRow.rowLandings.rawValue
    let rowCockpitFirst = leRow.rowCockpitHeader.rawValue
    let rowSigFirst = leRow.rowSigHeader.rawValue
    let rowSigLast = leRow.rowSigValidity.rawValue

    // MARK: Get an LEEditController
    public static func editorForFlight(_ le : LogbookEntry, delegate : LEEditDelegate? = nil) -> LEEditController {
        let leView = LEEditController(nibName: UIDevice.current.userInterfaceIdiom == .pad ? "LEEditController-iPad" : "LEEditController", bundle: nil)
        leView.le = le
        leView.delegate = delegate
        leView.view = leView.view // force viewdidload, etc.
        return leView
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        dfSunriseSunset.dateFormat = "hh:mm a z"
        
        flightProps = FlightProps()
        
        // row heights seem to change for some strange reason
        heightComments = cellComments.frame.size.height
        heightDateTail = cellDateAndTail.frame.size.height
        heightGPS = cellGPS.frame.size.height
        heightLandings = cellLandings.frame.size.height
        heightRoute = cellRoute.frame.size.height
        heightSharing = cellSharing.frame.size.height
        heightTimes = cellTimeBlock.frame.size.height
        
        // And set up remaining inputviews/accessory views
        idDate.inputView = datePicker
        datePicker.preferredDatePickerStyle = .wheels
        propDatePicker.preferredDatePickerStyle = .wheels
        
        idPopAircraft.inputView = pickerView
        idComments.inputAccessoryView = vwAccessory
        idRoute.inputAccessoryView = vwAccessory
        idDate.inputAccessoryView = vwAccessory
        idPopAircraft.inputAccessoryView = vwAccessory
        idComments.delegate = self
        idPopAircraft.delegate = self
        idRoute.delegate = self
        
        // self.le should be nil on first run, in which case we load up a flight
        // in progress or start a new one (if no saved state).
        // if self.le is already set up, we should be good to go with it.
        if le == nil {
            restoreFlightInProgress()
        }
        
        // Check to see if this is a pending flight
        let fIsPendingFlight = le.entryData is MFBWebServiceSvc_PendingFlight
        
        // If we have an unknown aircraft and just popped from creating one, then reset preferred aircraft
        if le.entryData.aircraftID.intValue <= 0 {
            setCurrentAircraft(Aircraft.sharedAircraft.preferredAircraft)
        }
        
        if let ac = Aircraft.sharedAircraft.AircraftByID(le.entryData.aircraftID.intValue) {
            let templateArray = (ac.defaultTemplates.int_.count) > 0 ? MFBWebServiceSvc_PropertyTemplate.templatesWithIDs(ac.defaultTemplates.int_ as! [NSNumber]) : MFBWebServiceSvc_PropertyTemplate.defaultTemplates
            activeTemplates = Set(templateArray)
        } else {
            le.entryData.aircraftID = NSNumber(integerLiteral: -1)
        }
        templatesUpdated(activeTemplates)
        
        initFormFromLE()
        
        refreshProperties()
        
        collapseAll()
        if le.rgPicsForFlight.count > 0 {
            expandedSections.insert(leSection.sectImages.rawValue)
        }
        
        if le.entryData.isNewFlight() {
            if !UserDefaults.standard.bool(forKey: _szkeyITCCollapseState) {
                
                expandedSections.insert(leSection.sectInCockpit.rawValue)
            }
            expandedSections.insert(leSection.sectProperties.rawValue)
        }
        
        if le.entryData.isSigned() {
            expandedSections.insert(leSection.sectSignature.rawValue)
        }
        
        expandedSections.insert(leSection.sectSharing.rawValue)
        
        
        /* Set up toolbar and submit buttons */
        let biSign = UIBarButtonItem(title: String(localized: "SignFlight", comment: "Let a CFI sign this flight"),
                                     style: .plain,
                                     target: self,
                                     action: #selector(signFlight))
        
        let biSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let biOptions = UIBarButtonItem(title: String(localized: "Options", comment: "Options button for autodetect, etc."),
                                        style: .plain,
                                        target: self,
                                        action: #selector(configAutoDetect))
        
        let bbGallery = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImages))
        let bbCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePictures))
        let bbSend = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendFlight))
        
        bbGallery.isEnabled = canUsePhotoLibrary()
        bbCamera.isEnabled = canUseCamera()
        
        bbGallery.style = .plain
        bbCamera.style = .plain
        bbSend.style = .plain
        
        var ar : [UIBarButtonItem] = []
        
        if fIsPendingFlight {
            // Pending flight: Only option other than "Add" is "Add Pending"
            ar.append(bbSend)
        }
        else {
            if le.entryData.isNewFlight() {
                ar.append(biOptions)
            }
            
            if !le.entryData.isNewOrAwaitingUpload() && le.entryData.cfiSignatureState != MFBWebServiceSvc_SignatureState_Valid {
                ar.append(biSign)
            }
            
            ar.append(contentsOf: [bbSend, biSpacer, bbGallery, bbCamera])
        }
        
        navigationController?.isToolbarHidden = false
        toolbarItems = ar
        
        // Submit button
        let bbSubmit = UIBarButtonItem(title: le.entryData.isNewOrAwaitingUpload() ? String(localized: "Add", comment: "Generic Add") : String(localized: "Update", comment: "Update"),
                                       style:.plain,
                                       target:self,
                                       action:#selector(submitFlight))
        
        navigationItem.rightBarButtonItem = bbSubmit
        
        if le.entryData.isNewFlight() {
            timerElapsed = Timer(timeInterval: 1.0, target: self, selector: #selector(updatePausePlay), userInfo: nil, repeats: true)
            RunLoop.current.add(timerElapsed, forMode: .default)
        }
        
        
        if le.entryData.isSigned() && le.entryData.hasDigitizedSig.boolValue {
            DispatchQueue.global().async {
                let szURL = String(format: "https://%@/logbook/public/ViewSig.aspx?id=%d", MFBHOSTNAME, self.le.entryData.flightID.intValue)
                do {
                    try self.digitizedSig =  UIImage(data: Data(contentsOf: URL(string: szURL)!))
                    DispatchQueue.main.async {
                        self.reload()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.showErrorAlertWithMessage(msg: error.localizedDescription)
                    }
                }
            }
        }
        
        tableView.sectionHeaderTopPadding = 0
        
        MFBAppDelegate.threadSafeAppDelegate.registerNotifyResetAll(self)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        saveState()
        
        if le.rgPicsForFlight.count > 0 {
            for ci in le.rgPicsForFlight as? [CommentedImage] ?? [] {
                ci.flushCachedImage()
            }
            selectibleAircraft = []
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.endEditing(true)
        initLEFromForm()
        navigationController?.isToolbarHidden = true
        dictPropCells.removeAll()
        saveState()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = false
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let app = MFBAppDelegate.threadSafeAppDelegate
        
        // Pick up an aircraft if one was added and none had been selected
        if (idPopAircraft.text ?? "").isEmpty {
            if let ac = Aircraft.sharedAircraft.preferredAircraft {
                idPopAircraft.text = ac.displayTailNumber
                le.entryData.aircraftID = ac.aircraftID
                le.entryData.tailNumDisplay = ac.displayTailNumber
            }
        }
        
        initFormFromLE() // pick up any potential changes
        
        saveState() // keep things in sync with any changes
        
        // the option to record could have changed; if so, and if we are in-flight, need to start recording.
        if app.mfbloc.fRecordFlightData && flightCouldBeInProgress() {
            app.mfbloc.startRecordingFlightData()
        }

        // update the position report, but only if this is a new flight
        if le.entryData.isNewFlight() && app.mfbloc.lastSeenLoc != nil {
            newLocation(app.mfbloc.lastSeenLoc!)
            updatePositionReport()
        }
        
        // enable/disable the add/update button based on sign-in state
        navigationItem.rightBarButtonItem?.isEnabled = MFBProfile.sharedProfile.isValid()
        
        // Initialize the list of selectibleAircraft and hold on to it
        // We do this on each view-will-appear so that we can pick up any aircraft that have been shown/hidden.
        selectibleAircraft = Aircraft.sharedAircraft.AircraftForSelection(le.entryData.aircraftID)

        // And reload the aircraft picker regardless, in case it changed too
        pickerView.reloadAllComponents()

        tableView.reloadData()
        app.ensureWarningShownForUser()
    }
    
    @objc public func flightCouldBeInProgress() -> Bool {
        return le.entryData.flightCouldBeInProgress()
    }
    
    // MARK: - Pausing of flight and auto time
    // TODO: time paused and the computation of elapsed time should be moved into LogbookEntry object, not here.  Can be consumed by watchkit directly then too.
    var timePaused : TimeInterval {
        get {
            return Date.timeIntervalSinceReferenceDate - le.dtTimeOfLastPause
        }
    }
        
    var elapsedTime : TimeInterval {
        get {
            var dtTotal = 0.0
            var dtFlight = 0.0
            var dtEngine = 0.0
            var dtBlock = 0.0
            
            if le.entryData.isKnownFlightStart() {
                dtFlight = (NSDate.isUnknownDate(dt: le.entryData.flightEnd) ? Date.timeIntervalSinceReferenceDate  : le.entryData.flightEnd.timeIntervalSinceReferenceDate) - le.entryData.flightStart.timeIntervalSinceReferenceDate
            }

            if le.entryData.isKnownEngineStart() {
                dtEngine = (NSDate.isUnknownDate(dt: le.entryData.engineEnd) ? Date.timeIntervalSinceReferenceDate : le.entryData.engineEnd.timeIntervalSinceReferenceDate) - le.entryData.engineStart.timeIntervalSinceReferenceDate
            }
            
            let dtOut = le.entryData.getExistingProperty(.blockOut)?.dateValue
            if !NSDate.isUnknownDate(dt: dtOut) {
                let dtIn = le.entryData.getExistingProperty(.blockIn)?.dateValue
                dtBlock = (NSDate.isUnknownDate(dt: dtIn) ? Date.timeIntervalSinceReferenceDate : dtIn!.timeIntervalSinceReferenceDate) - dtOut!.timeIntervalSinceReferenceDate
            }
                
            let totalsMode = UserPreferences.current.autoTotalMode
            
            // if totals mode is FLIGHT TIME, then elapsed time is based on flight time if/when it is known.
            // OTHERWISE, we use engine time (if known) or else flight time.
            switch (totalsMode) {
            case .block:
                dtTotal = dtBlock
            case .flight:
                dtTotal = dtFlight
            case .engine:
                dtTotal = dtEngine
            default:
                dtTotal = max(dtEngine, dtFlight, dtBlock)
            }

            dtTotal -= le.totalTimePaused
            if dtTotal <= 0 {
                dtTotal = 0 // should never happen
            }

            return dtTotal;
        }
    }
    
    @objc func updatePausePlay() {
        let app = MFBAppDelegate.threadSafeAppDelegate;

        idbtnPausePlay.setImage(UIImage(named: le.fIsPaused ? "Play.png" : "Pause.png"), for:[])
        
        let fShowPausePlay = app.mfbloc.currentFlightState != .fsInFlight && flightCouldBeInProgress()
        idbtnPausePlay.isHidden = !fShowPausePlay

        idlblElapsedTime.text = elapsedTime.toHHMMSS()
        
        app.mfbloc.fRecordingIsPaused = le.fIsPaused
        
        // Update any data that the watch might poll
        app.watchData?.elapsedSeconds = elapsedTime
        app.watchData?.isPaused = le.fIsPaused
        
        app.watchData?.flightStage = le.entryData.isKnownEngineEnd() ? .done : (flightCouldBeInProgress() ? .inprogress : .unstarted)
    }
    
    @IBAction public func toggleFlightPause() {
        let totalsMode = UserPreferences.current.autoTotalMode;
        
        // don't pause or play if we're not flying/engine started
        if le.entryData.isKnownFlightStart() || (totalsMode != .flight && le.entryData.isKnownEngineStart()) {
            if le.fIsPaused {
                le.unPauseFlight()
            } else {
                le.pauseFlight()
            }
        } else {
            le.unPauseFlight()
            le.dtTotalPauseTime = 0
        }

        updatePausePlay()
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
    }
    
    @objc public func pauseFlightExternal() {
        if !le.fIsPaused {
            toggleFlightPause()
        }
    }
    
    @objc public func resumeFlightExternal() {
        if le.fIsPaused {
            toggleFlightPause()
        }
    }

    // MARK: - Read/Write Form
    func initFormFromLE(_ fReload : Bool) {
        super.initFormFromLE()
        
        DispatchQueue.global().async {
            let rgCiLocal : [CommentedImage] = (self.le.rgPicsForFlight as? [CommentedImage] ?? []).filter { ci in
                !(ci.imgInfo?.livesOnServer ?? true)
            }

            let rgPics = NSMutableArray()
            if CommentedImage.initCommentedImagesFromMFBII(self.le.entryData.flightImages?.mfbImageInfo as? [MFBWebServiceSvc_MFBImageInfo] ?? [], toArray: rgPics) {
                DispatchQueue.main.async {
                    self.le.rgPicsForFlight = rgPics
                    rgPics.addObjects(from: rgCiLocal)
                    self.tableView.reloadData()
                    if self.le.rgPicsForFlight.count > 0 && !self.isExpanded(leSection.sectImages.rawValue) {
                        self.expandSection(leSection.sectImages.rawValue)
                    }
                }
            }
        }
                
        updatePausePlay()
        
        idimgRecording.isHidden = !MFBAppDelegate.threadSafeAppDelegate.mfbloc.fRecordFlightData || !flightCouldBeInProgress()
        MFBAppDelegate.threadSafeAppDelegate.watchData?.isRecording = !idimgRecording.isHidden
        
        if fReload {
            tableView.reloadData()
        }
    }
    
    override func initFormFromLE() {
        initFormFromLE(true)
    }
    
    // MARK: - In The Cockpit customization
    func propIDFromCockpitRow(_ row : leRow) -> PropTypeID {
        switch row {
        case .rowBlockIn:
            return .blockIn
        case .rowBlockOut:
            return .blockOut
        case .rowTachStart:
            return .tachStart
        case .rowTachEnd:
            return .tachEnd
        default:
            fatalError("propIDFromCockpitRow: \(row) is not a valid cockpit row")
        }
    }
    
    var cockpitRows : [leRow] {
        get {
            let l = le.entryData
            return LEEditController.rgAllCockpitRows.filter { row in
                switch row {
                case .rowTachStart, .rowTachEnd:
                    return UserPreferences.current.showTach
                case .rowHobbsStart, .rowHobbsEnd:
                    // Have to show hobbs if present since it won't show in properties
                    return UserPreferences.current.showHobbs || l.hobbsStart.doubleValue > 0.0 || l.hobbsEnd.doubleValue > 0.0
                case .rowEngineStart, .rowEngineEnd:
                    // Have to show engine if present since it won't show in properties
                    return UserPreferences.current.showEngine || l.isKnownEngineStart() || l.isKnownEngineEnd()
                case .rowBlockOut, .rowBlockIn:
                    return UserPreferences.current.showBlock
                case .rowFlightStart, .rowFlightEnd:
                    // Have to show flight if present since it won't show in properties
                    return UserPreferences.current.showFlight || l.isKnownFlightStart() || l.isKnownFlightEnd()
                case .rowGPS:
                    return l.isNewFlight()
                default:
                    return true
                }
            }
        }
    }
    
    // Return the set of properties that should show in the properties section.  Excludes block times if in-the-cockpit block option is on, excludes tach if tach option is on
    var propsForPropsSection : [MFBWebServiceSvc_CustomFlightProperty] {
        return (le.entryData.customProperties.customFlightProperty as? [MFBWebServiceSvc_CustomFlightProperty] ?? []).filter { cfp in
            switch cfp.propTypeID.intValue {
            case PropTypeID.blockOut.rawValue, PropTypeID.blockIn.rawValue:
                return !UserPreferences.current.showBlock
            case PropTypeID.tachStart.rawValue, PropTypeID.tachEnd.rawValue:
                return !UserPreferences.current.showTach
            default:
                return true
            }
        }
    }
    
    // MARK: - TableViewDatasource
    func cellIDFromIndexPath(_ ip : IndexPath) -> leRow {
        let row = ip.row
        
        switch leSection(rawValue: ip.section) {
        case .sectGeneral:
            return leRow(rawValue: rowGeneralFirst + row)!
        case .sectImages:
            return (row == 0) ? .rowImagesHeader : .rowNthImage
        case .sectInCockpit:
            // cockpit rows should be a complete set of rows, including header.
            // Issue #308: deleting a value from a field like hobbs and then navigating can then delete the rows; add a failsafe
            return row < cockpitRows.count ? cockpitRows[row] : .rowGPS
        case .sectProperties:
            return (row == 0) ? .rowPropertiesHeader : ((row == propsForPropsSection.count + 1) ? .rowAddProperties : .rowNthProperty)
        case .sectSharing:
            return (row == 0) ? .rowSharingHeader : .rowSharing
        case .sectTimes:
            return .rowTimes
        case .sectSignature:
            return leRow(rawValue: leRow.rowSigHeader.rawValue + row)!
        case .none:
            fatalError("Invalid section \(ip.section) passed to cellIDFromIndexPath")
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return leSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch leSection(rawValue: section) {
        case .sectGeneral:
            return rowGeneralLast - rowGeneralFirst + 1
        case .sectImages:
            return le.rgPicsForFlight.count == 0 ? 0 : 1 + (isExpanded(leSection.sectImages.rawValue) ? le.rgPicsForFlight.count : 0)
        case .sectInCockpit:
            return isExpanded(leSection.sectInCockpit.rawValue) ? cockpitRows.count : 1
        case .sectProperties:
            return 1 + (isExpanded(leSection.sectProperties.rawValue) ? propsForPropsSection.count + 1 : 0)
        case .sectSharing:
            return isExpanded(leSection.sectSharing.rawValue) ? 2 : 1
        case .sectTimes:
            return 1
        case .sectSignature:
            return le.entryData.isSigned() ? (isExpanded(leSection.sectSignature.rawValue) ? rowSigLast - rowSigFirst + 1 : 1) : 0
        default:
            return 0
        }
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == leSection.sectSignature.rawValue ?
        (le.entryData.cfiSignatureState == MFBWebServiceSvc_SignatureState_None ? nil : "") : ""
    }
    
    @objc func hobbsChanged(_ sender : UITextField) {
        let ec = owningCell(sender)!
        let row = cellIDFromIndexPath(tableView.indexPath(for: ec)!)
        if row == .rowHobbsStart {
            le.entryData.hobbsStart = sender.getValue()
        } else {
            le.entryData.hobbsEnd = sender.getValue()
        }
    }
    
    @objc func tachChanged(_ sender : UITextField) {
        let ec = owningCell(sender)!
        let row = cellIDFromIndexPath(tableView.indexPath(for: ec)!)
        let propTypeID = (row == .rowTachStart) ? PropTypeID.tachStart : PropTypeID.tachEnd
        if sender.getValue().intValue == 0 {
            try! le.entryData.removeProperty(NSNumber(integerLiteral: propTypeID.rawValue), withServerAuth: MFBProfile.sharedProfile.AuthToken as NSString, deleteSvc: flightProps)
        } else {
            le.entryData.setPropertyValue(propTypeID, withDecimal: sender.getValue().doubleValue)
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = cellIDFromIndexPath(indexPath)
        
        switch row {
        case .rowCockpitHeader:
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle:String(localized: "In the Cockpit", comment: "In the Cockpit"), forSection:leSection.sectInCockpit.rawValue, initialState:isExpanded(leSection.sectInCockpit.rawValue))
        case .rowImagesHeader:
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle:String(localized: "Images", comment: "Images Header"), forSection:leSection.sectImages.rawValue, initialState:isExpanded(leSection.sectImages.rawValue))
        case .rowPropertiesHeader:
            let cell = ExpandHeaderCell.getHeaderCell(tableView, withTitle:String(localized: "Properties", comment: "Properties Header"), forSection:leSection.sectProperties.rawValue, initialState:isExpanded(leSection.sectProperties.rawValue))
            if !FlightProps.sharedTemplates.isEmpty {
                cell.DisclosureButton.isHidden = false
                cell.DisclosureButton.addTarget(self, action: #selector(pickTemplates), for: .touchDown)
            }
            return cell
        case .rowSigHeader:
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle:String(localized: "sigHeader", comment: "Signature Section Title"), forSection:leSection.sectSignature.rawValue, initialState:true)
        case .rowDateTail:
            return cellDateAndTail
        case .rowComments:
            return cellComments
        case .rowRoute:
            return cellRoute
        case .rowLandings:
            return cellLandings
        case .rowGPS:
            cellGPS.accessoryType = hasAccessories ? .disclosureIndicator : .none
            return self.cellGPS
        case .rowHobbsStart:
            let dcell = decimalCell(tableView, prompt:String(localized: "Hobbs Start:", comment: "Hobbs Start prompt"), value: le.entryData.hobbsStart, selector:#selector(hobbsChanged))
            enableLongPressForField(dcell.txt, selector: #selector(setHighWaterHobbs))
            return dcell;
        case .rowHobbsEnd:
            return decimalCell(tableView, prompt:String(localized: "Hobbs End:", comment: "Hobbs End prompt"), value:le.entryData.hobbsEnd, selector:#selector(hobbsChanged))
        case .rowEngineStart:
            return dateCell(le.entryData.engineStart as? NSDate, prompt:String(localized: "Engine Start:", comment: "Engine Start prompt"), tableView:tableView)
        case .rowEngineEnd:
            return dateCell(le.entryData.engineEnd as? NSDate, prompt:String(localized: "Engine Stop:", comment: "Engine Stop prompt"), tableView:tableView)
        case .rowFlightStart:
            return dateCell(le.entryData.flightStart as? NSDate, prompt:String(localized: "First Takeoff:", comment: "First Takeoff prompt"), tableView:tableView)
        case .rowFlightEnd:
            return dateCell(le.entryData.flightEnd as? NSDate, prompt:String(localized: "Last Landing:", comment: "Last Landing prompt"), tableView:tableView)
        case .rowTachStart:
            let cfp = le.entryData.getExistingProperty(PropTypeID.tachStart)
            let dcell = decimalCell(tableView, prompt:String(localized: "TachStart", comment: "Tach Start prompt"), value:cfp?.decValue ?? 0.0, selector:#selector(tachChanged))
            enableLongPressForField(dcell.txt, selector: #selector(setHighWaterTach))
            return dcell;
        case .rowTachEnd:
            let cfp = le.entryData.getExistingProperty(PropTypeID.tachEnd)
            return decimalCell(tableView, prompt:String(localized: "TachEnd", comment: "Tach End prompt"), value:cfp?.decValue ?? 0.0, selector:#selector(tachChanged))
        case .rowBlockOut:
            let cfp = le.entryData.getExistingProperty(PropTypeID.blockOut)
            return dateCell((cfp?.dateValue ?? NSDate.distantPast) as NSDate, prompt:String(localized: "BlockOut", comment: "Block Out prompt"), tableView:tableView)
        case .rowBlockIn:
            let cfp = le.entryData.getExistingProperty(PropTypeID.blockIn)
            return dateCell((cfp?.dateValue ?? NSDate.distantPast) as NSDate, prompt:String(localized: "BlockIn", comment: "Block In prompt"), tableView:tableView)
        case .rowTimes:
            return self.cellTimeBlock
        case .rowSharingHeader:
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle:String(localized: "Sharing", comment: "Sharing Header"), forSection:leSection.sectSharing.rawValue, initialState:isExpanded(leSection.sectSharing.rawValue))
        case .rowSharing:
            return self.cellSharing
        case .rowAddProperties:
            let cellID = "EditPropsCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell.init(style: .default, reuseIdentifier: cellID)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "Flight Properties", comment: "Flight Properties")
            config.textProperties.adjustsFontSizeToFitWidth = true
            cell.contentConfiguration = config
            return cell
        case .rowSigState:
            let cellID = "SigStateCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell.init(style: .subtitle, reuseIdentifier: cellID)
            cell.accessoryType = .none
            cell.selectionStyle = .none
            let df = DateFormatter()
            df.dateStyle = .short
            
            var config = cell.defaultContentConfiguration()
            
            config.text = String(format:String(localized: "sigStateTemplate1", comment: "Signature Status - date and CFI"), df.string(from: le.entryData.cfiSignatureDate), le.entryData.cfiName)
            config.secondaryText = NSDate.isUnknownDate(dt: le.entryData.cfiExpiration) ?
            String(format:String(localized: "sigStateTemplate2NoExp", comment: "Signature Status - certificate & No Expiration"), le.entryData.cfiCertificate) :
            String(format:String(localized: "sigStateTemplate2", comment: "Signature Status - certificate & Expiration"), le.entryData.cfiCertificate, df.string(from: le.entryData.cfiExpiration))
            config.textProperties.adjustsFontSizeToFitWidth = true
            config.image = UIImage(named: le.entryData.cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid ? "sigok" : "siginvalid")
            cell.contentConfiguration = config
            return cell
        case .rowSigComment:
            let tc = TextCell.getTextCell(tableView)
            tc.accessoryType = .none
            tc.txt.text = le.entryData.cfiComments
            tc.selectionStyle = .none
            tc.txt.adjustsFontSizeToFitWidth = true
            return tc
        case .rowSigValidity:
            let cellID = "SigValidityCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell.init(style: .default, reuseIdentifier: cellID)
            cell.accessoryType = .none
            cell.selectionStyle = .none
            var config = cell.defaultContentConfiguration()
            config.text = le.entryData.cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid ? String(localized: "sigStateValid", comment: "Signature Valid") : String(localized: "sigStateInvalid", comment: "Signature Invalid")
            config.textProperties.adjustsFontSizeToFitWidth = true
            config.image = digitizedSig
            cell.contentConfiguration = config
            return cell
        case .rowNthImage:
            // TODO: This is common with aircraft; should be moved to util or somesuch.
            let cellID = "cellImage"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell.init(style: .default, reuseIdentifier: cellID)
            
            let imageIndex = indexPath.row - 1
            assert(imageIndex >= 0 && imageIndex < le.rgPicsForFlight.count)
            let ci = le.rgPicsForFlight[imageIndex] as! CommentedImage
            
            cell.indentationLevel = 1
            cell.accessoryType = .disclosureIndicator
            cell.indentationWidth = 10.0
            
            var config = cell.defaultContentConfiguration()
            config.text = ci.imgInfo?.comment ?? ""
            config.textProperties.adjustsFontSizeToFitWidth = true
            config.textProperties.numberOfLines = 3
            if ci.hasThumbnailCache {
                config.image = ci.GetThumbnail()
            } else {
                DispatchQueue.global().async {
                    ci.GetThumbnail()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            cell.contentConfiguration = config
            return cell
        case .rowNthProperty:
            let cfp = propsForPropsSection[indexPath.row - 1]   // account for header row
            if flightProps.rgPropTypes.isEmpty {
                flightProps = FlightProps.getFlightPropsNoNet()
            }
            let cpt = flightProps.propTypeFromID(cfp.propTypeID)!
            var _pc = dictPropCells[cpt.propTypeID]
            if _pc == nil {
                _pc = PropertyCell.getPropertyCell(tableView, withCPT: cpt, andFlightProperty: cfp)
                dictPropCells[cpt.propTypeID] = _pc!
            }
            else {
                _pc!.cfp = cfp
            }
            let pc = _pc!
            
            pc.txt.delegate = self
            pc.flightPropDelegate = flightProps
            pc.configureCell(vwAccessory, andDatePicker: propDatePicker, defValue: le.entryData.xfillValueForPropType(cpt) ?? NSNumber(integerLiteral: 0))
            return pc
        }
    }
    
    // MARK: - TableViewDelegate
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = cellIDFromIndexPath(indexPath)
        switch row {
        case .rowDateTail:
            return heightDateTail
        case .rowComments:
            return heightComments
        case .rowRoute:
            return heightRoute
        case .rowLandings:
            return heightLandings
        case .rowGPS:
            return heightGPS
        case .rowTimes:
            return heightTimes
        case .rowSharing:
            return heightSharing
        case .rowSigComment:
            return (le.entryData.cfiComments ?? "").isEmpty ? 0 : UITableView.automaticDimension
        case .rowNthImage:
            return 100.0
        case .rowNthProperty:
            return 57.0
        default:
            return UITableView.automaticDimension
        }
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let row = cellIDFromIndexPath(indexPath)
        if row == .rowNthImage {
            return true
        } else if row == .rowNthProperty {
            let cfp = propsForPropsSection[indexPath.row - 1]
            let cpt = flightProps.propTypeFromID(cfp.propTypeID)!
            return !cpt.isLocked
        }
        return false
    }
    
    public override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return String(localized: "Delete", comment: "Title for 'delete' button in image list")
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let row = cellIDFromIndexPath(indexPath)
            if row == .rowNthImage {
                let ci = le.rgPicsForFlight[indexPath.row - 1] as! CommentedImage
                ci.deleteImage(MFBProfile.sharedProfile.AuthToken)
                
                // then remove it from the array
                le.rgPicsForFlight.removeObject(at: indexPath.row - 1)
                var ar = [indexPath]
                
                // If deleting the last image we will delete the whole section, so delete the header row too
                if le.rgPicsForFlight.count == 0 {
                    ar.append(IndexPath(row: 0, section: indexPath.section))
                }
                tableView.deleteRows(at: ar, with: .fade)
            } else if row == .rowNthProperty {
                do {
                    try le.entryData.removeProperty(propsForPropsSection[indexPath.row - 1].propTypeID, withServerAuth:MFBProfile.sharedProfile.AuthToken as NSString, deleteSvc:flightProps)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    showErrorAlertWithMessage(msg: error.localizedDescription)
                }
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = cellIDFromIndexPath(indexPath)
        let cell = tableView.cellForRow(at: indexPath)
        switch row {
        case .rowAddProperties:
            let vwProps = FlightProperties.init(nibName: "FlightProperties", bundle: nil)
            vwProps.le = le
            vwProps.activeTemplates = activeTemplates
            vwProps.delegate = self
            tableView.endEditing(true)
            pushOrPopView(target: vwProps, sender: cell!, delegate: self)
        case .rowPropertiesHeader, .rowCockpitHeader, .rowImagesHeader, .rowSharingHeader, .rowSigHeader:
            toggleSection(indexPath.section)
            
            // preserve the state of ITC expansion
            if row == .rowCockpitHeader && le.entryData.isNewFlight() {
                UserDefaults.standard.set(!isExpanded(indexPath.section), forKey: _szkeyITCCollapseState)
                UserDefaults.standard.synchronize()
            }
        case .rowHobbsEnd, .rowHobbsStart, .rowEngineStart, .rowEngineEnd, .rowFlightEnd, .rowFlightStart, .rowComments, .rowRoute:
            if let t = (tableView.cellForRow(at: indexPath) as! NavigableCell).firstResponderControl {
                t.becomeFirstResponder()
                if let tf = t as? UITextField {
                    activeTextField = tf
                }
            }
        case .rowGPS:
            viewAccessories()
        case .rowNthImage:
            tableView.endEditing(true)
            let ic = ImageComment(nibName: "ImageComment", bundle: nil)
            ic.ci = le.rgPicsForFlight[indexPath.row - 1] as? CommentedImage
            navigationController?.pushViewController(ic, animated: true)
        case .rowNthProperty:
            let pc = tableView.cellForRow(at: indexPath) as! PropertyCell
            if pc.handleClick() {
                flightProps.propValueChanged(pc.cfp)
                if pc.cfp.isDefaultForType(pc.cpt) && !pc.cpt.isLocked && !MFBWebServiceSvc_PropertyTemplate.propListForSets(activeTemplates as NSSet).contains(pc.cpt.propTypeID ?? 0) {
                    le.entryData.removeProperty(pc.cfp.propTypeID)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                } else {
                    tableView.reloadData()
                }
            }
        default:
            tableView.endEditing(true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    @discardableResult func dateClick(_ dtIn : Date?, onInit completionBlock : (Date)->Void) -> Bool {
        datePicker.datePickerMode = .dateAndTime
        self.datePicker.preferredDatePickerStyle = .wheels
        
        var dt = dtIn ?? Date.distantPast // Web issue #1099 - want to ensure trunaction of seconds.

        let ec = tableView.cellForRow(at: ipActive!) as! EditCell

        // see if this is a "Tap for today" click - if so, set to today and resign.
        if (ec.txt.text ?? "").isEmpty || NSDate.isUnknownDate(dt:dt) {
            let fWasUnknownEngineStart = NSDate.isUnknownDate(dt: le.entryData.engineStart)
            let fWasUnknownFlightStart = NSDate.isUnknownDate(dt: le.entryData.flightStart)
            let fWasUnknownBlockOut = NSDate.isUnknownDate(dt: le.entryData.getExistingProperty(.blockOut)?.dateValue)
            
            // Since we don't display seconds, truncate them; this prevents odd looking math like
            // an interval from 12:13:59 to 12:15:01, which is a 1:02 but would display as 12:13-12:15 (which looks like 2 minutes)
            // By truncating the time, we go straight to 12:13:00 and 12:15:00, which will even yield 2 minutes.
            if NSDate.isUnknownDate(dt: dt) {
                dt = NSDate().dateByTruncatingSeconds()
                datePicker.date = dt
            }
            
            completionBlock(dt)
            
            ec.txt.text = NSDate.isUnknownDate(dt: dt) ? "" : dt.utcString(useLocalTime: UserPreferences.current.UseLocalTime)
            tableView.endEditing(true)
            
            let row = cellIDFromIndexPath(ipActive!)
            switch row {
            case .rowEngineStart:
                startEngine()
                if fWasUnknownEngineStart && le.entryData.isNewFlight() {
                    resetDateOfFlight()
                }
            case .rowEngineEnd:
                stopEngine()
            case .rowFlightStart:
                startFlight()
                if fWasUnknownEngineStart && fWasUnknownFlightStart && le.entryData.isNewFlight() {
                    resetDateOfFlight()
                }
            case .rowFlightEnd:
                stopFlight()
                
            case .rowBlockOut:
                if fWasUnknownBlockOut {
                    resetDateOfFlight()
                }
            case .rowBlockIn:
                break
            default:
                break
            }
            return false
        }
        
        datePicker.date = dt;
        datePicker.timeZone = UserPreferences.current.UseLocalTime ? TimeZone.current : TimeZone(secondsFromGMT: 0)
        datePicker.locale = UserPreferences.current.UseLocalTime ? Locale.current : Locale(identifier: "en-GB")
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var fShouldEdit = true
        let tc = owningCellGeneric(textField)!
        ipActive = tableView.indexPath(for:tc)
        
        if ipActive == nil {
            // should only happen if tc is hidden?
            activeTextField = nil
            return false
        }
        
        let row = cellIDFromIndexPath(ipActive!)
        
        enableNextPrev(vwAccessory)
        
        // fix up where enableNextPrev can fail
        vwAccessory.btnPrev.isEnabled = (textField != idDate)
        if let nc = tc as? NavigableCell {
            if textField != nc.lastResponderControl {
                vwAccessory.btnNext.isEnabled = true
            }
        }
        vwAccessory.btnDelete.isEnabled = (textField != idPopAircraft)
        
        // see if it's an engine/flight date
        switch row {
        case .rowEngineStart:
            dateClick(le.entryData.engineStart, onInit: { d in
                self.le.entryData.engineStart = d
            })
        case .rowEngineEnd:
            dateClick(le.entryData.engineEnd, onInit: { d in
                self.le.entryData.engineEnd = d
            })
        case .rowFlightStart:
            dateClick(le.entryData.flightStart, onInit: { d in
                self.le.entryData.flightStart = d
            })
        case .rowFlightEnd:
            dateClick(le.entryData.flightEnd, onInit: { d in
                self.le.entryData.flightEnd = d
            })
        case .rowBlockOut, .rowBlockIn:
            let propID = propIDFromCockpitRow(row)
            let cfp = le.entryData.getExistingProperty(propID)
            dateClick(cfp?.dateValue ?? Date.distantPast) { d in
                self.le.entryData.setPropertyValue(propID, withDate: d)
            }
        case .rowNthProperty:
            if let pc = tc as? PropertyCell {
                fShouldEdit = pc.prepForEditing()
                if !fShouldEdit {
                    if pc.cfp.propTypeID.intValue == PropTypeID.blockOut.rawValue {
                        dateOfFlightShouldReset(pc.cfp.dateValue ?? le.entryData.date)
                    }
                    if pc.cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime {
                        propertyUpdated(pc.cpt)
                    }
                }
            }
        default:
            break
        }
        
        if textField == idDate {
            if NSDate.isUnknownDate(dt: le.entryData.date) {
                le.entryData.date = Date()
                setDisplayDate(le.entryData.date)
                return false
            }
            datePicker.date = le.entryData.date
            datePicker.datePickerMode = .date
        } else if textField == idPopAircraft {
            if le.entryData.aircraftID.intValue > 0 {
                for i in 0..<selectibleAircraft.count {
                    let ac = selectibleAircraft[i]
                    if ac.aircraftID.intValue == le.entryData.aircraftID.intValue {
                        pickerView.selectRow(i, inComponent: 0, animated: true)
                        break
                    }
                }
            }
        }
        activeTextField = textField;
        return fShouldEdit
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        // issue #267 - for inexplicable reasons, textview delegate is not the same as textfield delegate.
        le.entryData.comment = textView.text;
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        // to check if total changed
        let oldTotal = le.entryData.totalFlightTime.doubleValue
        
        // catch any changes from retained fields
        initLEFromForm()

        let tc = owningCellGeneric(textField)!  // should never be nil!
        var ip = tableView.indexPath(for: tc)
        
        // If the cell is off-screen (hidden), we need to get its index path by position.
        if ip == nil {
            ip = tableView.indexPathForRow(at: tc.center)
        }
        
        // Issue #164: See if this was the aircraft field, in which case we need to update templates
        if textField == idPopAircraft {
            let original = NSMutableSet(set: activeTemplates as Set)
            // switching aircraft - update the templates, starting fresh.
            if let ac = Aircraft.sharedAircraft.AircraftByID(le.entryData.aircraftID.intValue) {
                // Reset all templates.
                activeTemplates.removeAll()
                updateTemplatesForAircraft(ac)
            }
            
            // call templatesUpdated, but only if there's actually been a change
            let originalCount = original.count
            original.minus(activeTemplates)
            if originalCount != activeTemplates.count || original.count != 0 {
                templatesUpdated(activeTemplates)
            }
        } else if textField == idTotalTime {
            // Issue #159: if total time changes, need to reset properties cross-fill value.
            if oldTotal != idTotalTime.getValue().doubleValue {
                tableView.reloadData()
            }
        }
        
        let row = cellIDFromIndexPath(ip!)
        if row == .rowNthProperty {
            if let pc = tc as? PropertyCell {
                pc.handleTextUpdate(textField)
                propertyUpdated(pc.cpt)
                flightProps.propValueChanged(pc.cfp)
                
                if pc.cfp.isDefaultForType(pc.cpt) && !pc.cpt.isLocked && !MFBWebServiceSvc_PropertyTemplate.propListForSets(activeTemplates as NSSet).contains(pc.cpt.propTypeID ?? -1) {
                    le.entryData.removeProperty(pc.cfp.propTypeID)
                    tableView.deleteRows(at: [ip!], with: .fade)
                }
            }
        } else if leSection(rawValue: ip!.section) == .sectInCockpit {
            // fNeedsReInit says if we need to update the other fields based on possible changes from autohobbs/autototals.
            // do autohobbs if this WASN'T an explicit edit of the hobbs times.
            var fNeedsReInit = false

            switch row {
            case .rowHobbsEnd:
                le.entryData.hobbsEnd = textField.getValue()
            case .rowHobbsStart:
                le.entryData.hobbsStart = textField.getValue()
                fNeedsReInit = autoHobbs()
            default:
                fNeedsReInit = autoHobbs()
            }

            if autoTotal() || fNeedsReInit {
                initFormFromLE(false) // don't reload the table because it could mess up our editing.
            }
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == idRoute {
            return true
        }
        
        // Hack, but for in-line editing of free-form text properties, need to allow arbitrary text and support autocomplete
        var vw = textField.superview
        while vw != nil {
            if let pc = vw as? PropertyCell {
                return pc.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
            }
            vw = vw?.superview
        }

        // OK, at this point we have a number - either integer, decimal, or HH:MM.  Allow it if the result makes sense.
        return textField.isValidNumber(szProposed: ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string))
    }
    
    // MARK: - In the Cockpit
    @objc func startEngine() {
        if le.entryData.isNewFlight() {
            if !le.entryData.isKnownEngineStart() {
                resetDateOfFlight()
            }
            if UserPreferences.current.autodetectTakeoffs {
                autofillClosest()
            }
        }
        
        initFormFromLE()
        if !le.entryData.isNewFlight() {
            return
        }
        
        MFBAppDelegate.threadSafeAppDelegate.mfbloc.currentFlightState = .fsOnGround
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
        
        if MFBLocation.USE_FAKE_GPS {
            GPSSim.BeginSim()
        }
    }
    
    @objc public func startEngineExternal() {
        if !le.entryData.isKnownEngineStart() {
            resetDateOfFlight()
            le.entryData.engineStart = Date()
            startEngine()
        }
    }
    
    @objc @discardableResult public func autoTotal() -> Bool {
        if le.autoFillTotal() {
            idTotalTime.setValue(num: le.entryData.totalFlightTime)
            idGrndSim.setValue(num: le.entryData.groundSim)
            idXC.setValue(num: le.entryData.crossCountry)
            return true
        }
        return false
    }
    
    @objc @discardableResult public func autoHobbs() -> Bool {
        if le.autoFillHobbs() {
            // get the index path of the hobbs end cell
            // this is a bit of a hack, but it's robust to the cell changing position
            var iRow = tableView(tableView, numberOfRowsInSection: leSection.sectInCockpit.rawValue) - 1
            var ip : IndexPath? = nil
            while iRow >= 0 {
                ip = IndexPath(row: iRow, section: leSection.sectInCockpit.rawValue)
                if cellIDFromIndexPath(ip!) == .rowHobbsEnd {
                    break
                }
                iRow -= 1
            }
            if ip != nil && iRow >= 0, let ec = tableView.cellForRow(at: ip!) as? EditCell {
                ec.txt.setValue(num: le.entryData.hobbsEnd)
            }

            // do the total time too, if appropriate
            if UserPreferences.current.autoTotalMode == .hobbs {
                autoTotal()
            }
            return true
        }
        return false
    }
    
    @objc public func stopEngine() {
        if UserPreferences.current.autodetectTakeoffs {
            autofillClosest()
        }

        autoHobbs()
        autoTotal()

        if !le.entryData.isNewFlight() {
            return
        }

        MFBAppDelegate.threadSafeAppDelegate.mfbloc.stopRecordingFlightData()
        idimgRecording.isHidden = true
        initFormFromLE()
        le.unPauseFlight()
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
    }
    
    @objc public func stopEngineExternal() {
        if !le.entryData.isKnownEngineEnd() {
            le.entryData.engineEnd = Date()
            stopEngine()
            le.entryData.flightID = LogbookEntry.QUEUED_FLIGHT_UNSUBMITTED   // don't auto-submit this flight!
            MFBAppDelegate.threadSafeAppDelegate.queueFlightForLater(le)
            resetFlight()
            updatePausePlay()
            MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
        }
    }
    
    @objc public func stopEngineExternalNoSubmit() {
        if !le.entryData.isKnownEngineEnd() {
            le.entryData.engineEnd = Date()
            stopEngine()
        }
    }
    
    @objc public func startFlight() {
        if le.entryData.isNewFlight() {
            if !le.entryData.isKnownEngineStart() && !le.entryData.isKnownFlightStart() {
                resetDateOfFlight()
            }
            
            if UserPreferences.current.autodetectTakeoffs {
                autofillClosest()
            }
            
            MFBAppDelegate.threadSafeAppDelegate.mfbloc.startRecordingFlightData() // will ignore recording if not set to do so.
            MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
        }
        
        initFormFromLE()
    }
    
    @objc public func stopFlight() {
        initFormFromLE()
        autoHobbs()
        autoTotal()
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
    }
    
    func afterDataModified() {
        autoHobbs()
        autoTotal()
        initFormFromLE()
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
    }
    
    @objc public func startFlightExternal() {
        if NSDate.isUnknownDate(dt: le.entryData.flightStart) {
            le.entryData.flightStart = Date()
            startFlight()
            afterDataModified()
        }
    }
    
    @objc public func stopFlightExternal() {
        if NSDate.isUnknownDate(dt: le.entryData.flightEnd) {
            le.entryData.flightEnd = Date()
            stopFlight()
        }
    }
    
    @objc public func blockOutExternal() {
        let cfp = le.entryData.getExistingProperty(.blockOut)
        if !NSDate.isUnknownDate(dt: cfp?.dateValue) {
            return
        }
        
        le.entryData.setPropertyValue(.blockOut, withDate: Date())
        
        if !le.entryData.isKnownEngineStart() && !le.entryData.isKnownFlightStart() {
            resetDateOfFlight()
        }
        
        afterDataModified()
    }

    @objc public func blockInExternal() {
        let cfp = le.entryData.getExistingProperty(.blockIn)
        if !NSDate.isUnknownDate(dt: cfp?.dateValue) {
            return
        }
        
        le.entryData.setPropertyValue(.blockIn, withDate: Date())
        afterDataModified()
    }
    
    // MARK: - Autodetection delegates
    @objc public func takeoffDetected() -> NSString {
        le.entryData.takeoffDetected()
        
        initFormFromLE()
        le.unPauseFlight() // if we're flying, we're not paused.
        
        saveState()
        
        // in case cockpit view is visible, have it update
        return (MFBAppDelegate.threadSafeAppDelegate.fDebugMode ? "Route is \(le.entryData.route ?? ""), landings is \(le.entryData.landings.intValue), FS Landings is \(le.entryData.fullStopLandings.intValue)" : "") as NSString
    }
    
    @objc public func nightTakeoffDetected() -> NSString {
        if !le.entryData.isKnownEngineEnd() {
            le.entryData.nightTakeoffDetected()    // let the logbookentry handle this
            tableView.reloadData()
            saveState()
        }

        return ""
    }
    
    @objc public func landingDetected() -> NSString {
        // don't modify the flight if engine is ended.
        if le.entryData.isKnownEngineEnd() {
            return ""
        }
        
        let szRouteOrigin = le.entryData.route ?? ""
        let landingsOrigin = le.entryData.landings.intValue;

        if !NSDate.isUnknownDate(dt:le.entryData.flightStart) {
            le.entryData.landingDetected()    // delegate further to the logbook entry.
            idLandings.setValue(num: le.entryData.landings)
            idRoute.text = le.entryData.route
            tableView.reloadData()
        }
        
        saveState()
        
        return (MFBAppDelegate.threadSafeAppDelegate.fDebugMode ? "Route was: \(szRouteOrigin) Now: \(le.entryData.route ?? ""); landings were: \(landingsOrigin) Now: \(le.entryData.landings.intValue)" : "") as NSString
    }
    
    @objc public func fsLandingDetected(_ fIsNight : Bool) -> NSString {
        // don't modify the flight if engine is ended.
        if le.entryData.isKnownEngineEnd() {
            return ""
        }
        
        let fsLandingsOrigin = fIsNight ? le.entryData.nightLandings.intValue : le.entryData.fullStopLandings.intValue
        
        le.entryData.fsLandingDetected(fIsNight) // delegate to logbookentry
        idNightLandings.setValue(num: le.entryData.nightLandings)
        idDayLandings.setValue(num: le.entryData.fullStopLandings)
        
        saveState()
        
        // NOTE: we don't pass this on to the sub-view because otherwise we would double count!
        // Also note that above already has updated this form.
        return (MFBAppDelegate.threadSafeAppDelegate.fDebugMode ? " FS \(fIsNight ? "Night" : "") Landing: was: \(fsLandingsOrigin) now: \(fIsNight ? le.entryData.nightLandings.intValue : le.entryData.fullStopLandings.intValue)" : "") as NSString
    }
    
    @objc public func addNightTime(_ t : Double) {
        if le.fIsPaused {
            return
        }
        
        le.accumulatedNightTime += t
        var accumulatedNight = le.accumulatedNightTime
        if UserPreferences.current.roundTotalToNearestTenth {
            accumulatedNight = round(accumulatedNight * 10.0) / 10.0
        }
        let d = NSNumber(floatLiteral: accumulatedNight)
        idNight.setValue(num: d)
        le.entryData.nighttime = d
    }
    
    // MARK: - Location Manager Delegates
    func updatePositionReport() {
        if let loc = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc {
            let lat = loc.coordinate.latitude
            let lon = loc.coordinate.longitude
            lblLat.text = MFBLocation.latitudeDisplay(lat)
            lblLon.text = MFBLocation.longitudeDisplay(lon)

            let s = SunriseSunset(dt: Date(), latitude: lat, longitude: lon, nightOffset: 0)
            let dSunrise = s.Sunrise as Date?
            let dSunset = s.Sunset as Date?
            
            lblSunrise.text = dSunrise == nil ? "" : dfSunriseSunset.string(from: dSunrise!)
            lblSunset.text = dSunset == nil ? "" : dfSunriseSunset.string(from: dSunset!)
            
            // issue #272: show an icon of the world instead of information disclosure.
            // But let's show Americas if Latitude < -20, otherwise show eastern hemisphere.
            btnViewRoute.setTitle((lon < -20) ? "🌎" : "🌍", for: [.normal])
        }
    }
    
    @objc public func newLocation(_ newLocation : CLLocation) {
        let s = newLocation.speed * MFBConstants.MPS_TO_KNOTS
        let fValidSpeed = s >= 0
        var fValidQuality = false
        let acc = newLocation.horizontalAccuracy

        if acc > MFBLocation.MIN_ACCURACY || acc < 0 {
            idLblQuality.text = String(localized: "Poor", comment: "Poor GPS quality")
            fValidQuality = false
        } else {
            idLblQuality.text = (acc < (MFBLocation.MIN_ACCURACY / 2)) ? String(localized: "Excellent", comment: "Excellent GPS quality") : String(localized: "Good", comment: "Good GPS quality")
            fValidQuality = true
        }
        
        let app = MFBAppDelegate.threadSafeAppDelegate;
        
        if le.entryData.isKnownEngineEnd() && app.mfbloc.currentFlightState != .fsOnGround { // can't fly with engine off
            app.mfbloc.currentFlightState = .fsOnGround
            NSLog("Engine is off so forced currentflightstate to OnGround")
        }
        
        let fs = app.mfbloc.currentFlightState
        idLblStatus.text = MFBLocation.flightStateDisplay(fs)
        if fs == .fsInFlight {
            le.unPauseFlight()
        }
        let szInvalid = ""
        idLblSpeed.text = (fValidSpeed && fValidQuality) ? MFBLocation.speedDisplay(s) : szInvalid
        idLblAltitude.text = (fValidSpeed && fValidQuality) ? MFBLocation.altitudeDisplay(newLocation) : szInvalid
        idimgRecording.isHidden = !app.mfbloc.fRecordFlightData || !flightCouldBeInProgress()
        
        updatePausePlay() // ensure that this is visible if we're not flying

        // update position, sunrise/sunset
        updatePositionReport()
    }
    
    // MARK: - EditPropertyDelegate
    public func propertyUpdated(_ cpt: MFBWebServiceSvc_CustomPropertyType) {
        let propID = cpt.propTypeID.intValue
        
        if UserPreferences.current.autoTotalMode == .block {
            // Autoblock if editing a block time start or stop
            if propID == PropTypeID.blockOut.rawValue || propID == PropTypeID.blockIn.rawValue {
                autoTotal()
            }
        }
    }
    
    public func dateOfFlightShouldReset(_ dt: Date) {
        if !NSDate.isUnknownDate(dt: dt) {
            resetDateOfFlight()
        }
    }
    
    // MARK: - Data Source - aircraft picker
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let selectible = selectibleAircraft.count
        return selectible == 0 || selectible == (Aircraft.sharedAircraft.rgAircraftForUser ?? []).count ? selectible : selectible + 1;
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var lbl : UILabel!
        if (view == nil) {
            let l = UILabel()
            l.font = UIFont.preferredFont(forTextStyle: .title1)
            l.textAlignment = .center
            lbl = l
        } else {
            lbl = (view as! UILabel)
        }
        
        lbl.attributedText = self.pickerView(pickerView, attributedTitleForRow:row, forComponent:component)
        return lbl
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let size = UIFont.preferredFont(forTextStyle: .title1).pointSize;
        if row == selectibleAircraft.count {   // "Show all"
            return NSAttributedString.attributedStringFromMarkDown(sz: "_\(String(localized: "ShowAllAircraft", comment: "Show all aircraft"))_" as NSString, size: size)
        }
        
        let ac = self.selectibleAircraft[row]
        if ac.isAnonymous() {
            return NSAttributedString.attributedStringFromMarkDown(sz: "*\(ac.displayTailNumber)*" as NSString, size:size)
        }
        
        return NSAttributedString.attributedStringFromMarkDown(sz: "*\(ac.tailNumber ?? "")* (\(ac.modelDescription ?? ""))" as NSString, size:size)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == self.selectibleAircraft.count {  // show all
            selectibleAircraft = Aircraft.sharedAircraft.rgAircraftForUser ?? []
            pickerView.reloadAllComponents()
            pickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            let ac = self.selectibleAircraft[row]
            le.entryData.aircraftID = ac.aircraftID
            le.entryData.tailNumDisplay = ac.displayTailNumber
            idPopAircraft.text = ac.displayTailNumber
        }
    }
    
    
    // MARK: - DatePicker
    @IBAction func dateChanged(_ sender : UIDatePicker) {
        assert(ipActive != nil)
        let row = cellIDFromIndexPath(ipActive!)
        let sect = leSection(rawValue: ipActive!.section)
        if row == .rowDateTail {
            le.entryData.date = sender.date
            idDate.text = (sender.date as NSDate).dateString()
            return
        }

        if sect == .sectInCockpit {
            let ec = tableView.cellForRow(at: ipActive!) as! EditCell
            ec.txt.text = sender.date.utcString(useLocalTime: UserPreferences.current.UseLocalTime)
            switch row {
            case .rowDateTail:
                return
            case .rowEngineStart:
                le.entryData.engineStart = sender.date
                resetDateOfFlight()
            case .rowEngineEnd:
                le.entryData.engineEnd = sender.date
            case .rowFlightStart:
                le.entryData.flightStart = sender.date
                resetDateOfFlight()
            case .rowFlightEnd:
                le.entryData.flightEnd = sender.date
            case .rowBlockOut, .rowBlockIn:
                if NSDate.isUnknownDate(dt: sender.date) {
                    do {
                        try le.entryData.removeProperty(NSNumber(integerLiteral: propIDFromCockpitRow(row).rawValue), withServerAuth:MFBProfile.sharedProfile.AuthToken as NSString, deleteSvc:flightProps)
                    }
                    catch {
                        showErrorAlertWithMessage(msg: "Error deleting property: \(error.localizedDescription)")
                    }
                } else {
                    le.entryData.setPropertyValue(propIDFromCockpitRow(row), withDate: sender.date)
                    if row == .rowBlockOut {
                        resetDateOfFlight()
                    }
                }
            default:
                break
            }
            autoHobbs()
            autoTotal()
        }
    }
    
    // MARK: - AccessoryBar Delegate
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        let row = cellIDFromIndexPath(ip)
        switch row {
        case .rowComments, .rowRoute, .rowHobbsEnd, .rowHobbsStart, .rowTachStart, .rowTachEnd, .rowTimes, .rowLandings, .rowDateTail:
            return true
        case .rowEngineEnd:
            return !NSDate.isUnknownDate(dt: le.entryData.engineEnd)
        case .rowEngineStart:
            return !NSDate.isUnknownDate(dt: le.entryData.engineStart)
        case .rowFlightEnd:
            return !NSDate.isUnknownDate(dt: le.entryData.flightEnd)
        case .rowFlightStart:
            return !NSDate.isUnknownDate(dt: le.entryData.flightStart)
        case .rowBlockOut, .rowBlockIn:
            return !NSDate.isUnknownDate(dt: le.entryData.getExistingProperty(propIDFromCockpitRow(row))?.dateValue)
        case .rowNthProperty:
            let cfp = propsForPropsSection[ip.row - 1]
            let cpt = flightProps.propTypeFromID(cfp.propTypeID)!   // should never fail
            return cpt.type != MFBWebServiceSvc_CFPPropertyType_cfpBoolean
        default:
            return false
        }
    }
    
    public override func deleteClicked() {
        activeTextField?.text = ""
        
        // handle deletion of date for flight - issue #306
        if activeTextField == self.idDate {
            self.le.entryData.date = Date.distantPast
            setDisplayDate(self.le.entryData.date)
            tableView.endEditing(true)
            return
        }
        
        assert(ipActive != nil)
        let row = cellIDFromIndexPath(ipActive!)
        let sect = leSection(rawValue: ipActive!.section)
        if (sect == .sectInCockpit) {
            // Issue #308 - do end-editing BEFORE nullifying an in-the-cockpit item, so that didEndEditing will still have a potentially removed row.
            tableView.endEditing(true)
            switch row {
            case .rowHobbsStart:
                le.entryData.hobbsStart = activeTextField?.getValue()
            case .rowHobbsEnd:
                // Could affect total, but DON'T auto-hobbs or we undo the delete.
                le.entryData.hobbsEnd = activeTextField?.getValue()
                autoTotal()
                tableView.reloadData()
                return
            case .rowDateTail:
                return
            case .rowEngineStart:
                le.entryData.engineStart = nil
            case .rowEngineEnd:
                le.entryData.engineEnd = nil
            case .rowFlightStart:
                le.entryData.flightStart = nil
            case .rowFlightEnd:
                le.entryData.flightEnd = nil
            case .rowBlockOut, .rowBlockIn, .rowTachStart, .rowTachEnd:
                do {
                    try le.entryData.removeProperty(NSNumber(integerLiteral: propIDFromCockpitRow(row).rawValue), withServerAuth:MFBProfile.sharedProfile.AuthToken as NSString, deleteSvc:flightProps)
                }
                catch {
                    showErrorAlertWithMessage(msg: "Error deleting property: \(error.localizedDescription)")
                }
            default:
                break
            }
            autoHobbs()
            autoTotal()
        }
        
        initLEFromForm()
        tableView.reloadData()  // Issue #308 - in case in-the-cockpit fields were deleted
    }
    
    // MARK: - Add Image
    public override func addImage(_ ci: CommentedImage) {
        le.rgPicsForFlight.add(ci)
        tableView.reloadData()
        if !isExpanded(leSection.sectImages.rawValue) {
            expandSection(leSection.sectImages.rawValue)
        }
    }
}
