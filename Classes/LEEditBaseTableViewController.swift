/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2024 MyFlightbook, LLC
 
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
//  LEEditBaseTableViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/6/23.
//

import Foundation

@objc public protocol LEEditDelegate {
    func flightUpdated(_ sender : LogbookEntryBaseTableViewController)
}

public class LogbookEntryBaseTableViewController : FlightEditorBaseTableViewController, SelectTemplatesDelegate, ApproachEditorDelegate, TotalsCalculatorDelegate, NearbyAirportsDelegate {
    @objc public var le : LogbookEntry!
    public var flightProps = FlightProps()
    public var activeTemplates : Set<MFBWebServiceSvc_PropertyTemplate> = []
    @IBOutlet var delegate : LEEditDelegate? = nil
    
    private let _szKeyCurrentFlight = "keyCurrentNewFlight"
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up longpress recognizers for times
        enableLongPressForField(idTotalTime, selector: #selector(timeCalculator))
        enableLongPressForField(idDate, selector: #selector(setToday))
        
        idbtnAppendNearest.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(appendAdHoc)))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Issue #109 - stupid apple bug; button initially shows up as gray despite being enabled.
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        idRoute.placeholder = String(localized: "Route", comment: "Entry field: Route")
        idPopAircraft.placeholder = String(localized: "Aircraft", comment: "Entry field: Aircraft")
        
        // pick up any changes in the HHMM setting
        idXC.isHHMM = UserPreferences.current.HHMMPref
        idSIC.isHHMM = UserPreferences.current.HHMMPref
        idSimIMC.isHHMM = UserPreferences.current.HHMMPref
        idCFI.isHHMM = UserPreferences.current.HHMMPref
        idDual.isHHMM = UserPreferences.current.HHMMPref
        idGrndSim.isHHMM = UserPreferences.current.HHMMPref
        idIMC.isHHMM = UserPreferences.current.HHMMPref
        idNight.isHHMM = UserPreferences.current.HHMMPref
        idPIC.isHHMM = UserPreferences.current.HHMMPref
        idTotalTime.isHHMM = UserPreferences.current.HHMMPref
    }
    
    // MARK: - Table view data source
    // ALL DONE IN SUPER OR SUBCLASSES
    
    // MARK: - Save State
    @objc public func saveState() {
        // don't save anything if we are viewing an existing flight or a pending flight.
        if le.entryData.isNewFlight() && !(le.entryData is MFBWebServiceSvc_PendingFlight) {
            // LE should already be in sync with the UI
            le.entryData.flightData = MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString()
            
            do {
                let defs = UserDefaults.standard
                try defs.set(NSKeyedArchiver.archivedData(withRootObject: le!, requiringSecureCoding: true), forKey: _szKeyCurrentFlight)
                defs.synchronize()
            }
            catch {
                showErrorAlertWithMessage(msg: "Error saving state: \(error.localizedDescription)")
            }
        }
    }
    
    public func restoreFlightInProgress() {
        if let ar = UserDefaults.standard.object(forKey: _szKeyCurrentFlight) as? Data {
            do {
                let f = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, LogbookEntry.self, NSNumber.self, MFBWebServiceSvc_LogbookEntry.self, NSDate.self, CommentedImage.self], from: ar)
                // For some reason, after conversion to swift, f is not returning a LogbookEntry but rather a [LogbookEntry].  I have absolutely no idea why
                if let l1 = f as? LogbookEntry {
                    le = l1
                } else if let l2 = f as? [LogbookEntry] {
                    if l2.isEmpty {
                        fatalError("What is going on here?!?  NSKeyedUnarchiver returned something for the in progress flight, but not a logbookEntry")
                    }
                    le = l2[0]
                } else {
                    fatalError("No idea what nskeyedunarchiver is returning for _szKeyCurrentFlight")
                }
            }
            catch {
                NSLog("Error restoring state: \(error.localizedDescription)")
                le = LogbookEntry() // just create a new one
            }
        } else {
            le = LogbookEntry()
            setupForNewFlight()
        }
    }
    
    // MARK: - Resetting flights
    // re-initializes a flight but DOES NOT update any UI.
    func setupForNewFlight() {
        let endingHobbs = le.entryData.hobbsEnd // remember ending hobbs for last flight...
        let endingTach = le.entryData.getExistingProperty(PropTypeID.tachEnd)?.decValue ?? 0
        let endingFuel = le.entryData.getExistingProperty(PropTypeID.fuelAtEnd)?.decValue ?? 0
        let endingFlightMeter = le.entryData.getExistingProperty(PropTypeID.flightMeterEnd)?.decValue ?? 0
        
        le = LogbookEntry()
        le.entryData.date = Date.distantPast    // Issue #306 - allow floating "Today"

        // Add in any locked properties - but don't hit the web.
        let fp = FlightProps.getFlightPropsNoNet()
        le.entryData.customProperties.setProperties(fp.defaultPropList())

        let ac = Aircraft.sharedAircraft.preferredAircraft
        
        // Initialize the active templates to the defaults, either for this aircraft or the ones you've indicated you want to use by default.
        let templates = (ac?.defaultTemplates.int_.count ?? 0) > 0 ? MFBWebServiceSvc_PropertyTemplate.templatesWithIDs(ac?.defaultTemplates.int_ as! [NSNumber]) : MFBWebServiceSvc_PropertyTemplate.defaultTemplates
        activeTemplates = Set(templates)
        templatesUpdated(activeTemplates)

        setCurrentAircraft(ac)
        
        let mfbloc = MFBAppDelegate.threadSafeAppDelegate.mfbloc;
        mfbloc.stopRecordingFlightData()
        mfbloc.resetFlightData() // clean up any old flight-tracking data
        
        le.initNumerics()
        
        // ...and start the starting hobbs to be the previous flight's ending hobbs.  If it was nil, we're fine.
        le.entryData.hobbsStart = endingHobbs;
        if endingTach.doubleValue > 0 {
            le.entryData.setPropertyValue(.tachStart, withDecimal: endingTach.doubleValue)
        }
        if (endingFuel.doubleValue > 0) {
            le.entryData.setPropertyValue(.fuelAtStart, withDecimal: endingFuel.doubleValue)
        }
        if (endingFlightMeter.doubleValue > 0) {
            le.entryData.setPropertyValue(.flightMeterStart, withDecimal: endingFlightMeter.doubleValue)
        }
        saveState() // clean up any old state
        MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
    }
    
    func resetFlight() {
        setupForNewFlight()
        initFormFromLE()
    }
    
    func resetFlightWithConfirmation() {
        let alert = UIAlertController(title: "", message: String(localized: "Are you sure you want to reset this flight?  This CANNOT be undone", comment: "Reset Flight confirmation"), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style: .destructive) { aa in
            self.resetFlight()
            MFBAppDelegate.threadSafeAppDelegate.watchData?.flightStage = .unstarted
            MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
        })
        present(alert, animated: true)
    }
    
    // MARK: - Invalidatable
    public override func invalidateViewController() {
        DispatchQueue.main.async {
            self.resetFlight()
        }
    }
    
    // MARK: Flight Submission
    // Called after a flight is EITHER successfully posted to the site OR successfully queued for later.
    func submitFlightSuccessful() {
        let app = MFBAppDelegate.threadSafeAppDelegate
        // set the preferred aircraft
        Aircraft.sharedAircraft.DefaultAircraftID = le.entryData.aircraftID.intValue
        
        // invalidate any cached totals and currency, since the newly entered flight renders them obsolete
        app.invalidateCachedTotals()
        
        // TODO: if there isn't a delegate, shouldn't the app itself be the delegate, to decouple this from recentflights/etc.?
        // and let any delegate know that the flight has updated
        if delegate != nil {
            // just notify the delegate; let them handle things - only do the animation if it's a new flight
            delegate?.flightUpdated(self)
        } else {
            let targetView = app.tabRecents.viewControllers[0].view!
            UIView.transition(from: navigationController!.view, to: targetView, duration: 0.75, options: .transitionCurlUp) { fFinished in
                if (fFinished) {
                    // Could this be where the recents view isn't loaded?
                    MFBAppDelegate.threadSafeAppDelegate.tabBarController.selectedViewController = MFBAppDelegate.threadSafeAppDelegate.tabRecents
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at:.top, animated:true)
                }
            }
        }
        
        // clear the form for another entry
        setupForNewFlight()
        initFormFromLE()
    }
    
    func submitFlightInternal(asPending : Bool) {
        tableView.endEditing(true)
        
        // Basic validation
        // make sure we have the latest of everything - this should be unnecessary
        initLEFromForm()
        
        if le.entryData.aircraftID.intValue <= 0 {
            let alert = UIAlertController(title: String(localized: "No Aircraft", comment: "Title for No Aircraft error"),
                                          message: String(localized: "Each flight must specify an aircraft.  Create one now?", comment: "Error - must have aircraft"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel, handler:nil))
            alert.addAction(UIAlertAction(title: String(localized: "Create", comment: "Button title to create an aircraft"), style:.default, handler: { act in
                self.newAircraft()
            }))
            present(alert, animated: true)
        }
        
        if le.entryData.isNewFlight() || le.entryData.cfiSignatureState != MFBWebServiceSvc_SignatureState_Valid {
            submitFlightConfirmed(asPending : asPending)
        } else {
            let alert = UIAlertController(title: String(localized: "ConfirmEdit", comment: "Confirm edit"),
                                          message: String(localized: "ConfirmModifySignedFlight", comment: "Modify signed flight confirmation"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel, handler:nil))
            alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style:.default, handler: { act in
                self.submitFlightConfirmed(asPending : asPending)
            }))
            present(alert, animated: true)
        }
    }
    
    func submitFlightConfirmed(asPending : Bool) {
        let app = MFBAppDelegate.threadSafeAppDelegate
        let pf = MFBProfile.sharedProfile
        if (!pf.isValid()) { // should never happen - app delegate should have prevented this page from showing.
            return
        }
        
        le.szAuthToken = pf.AuthToken
        le.entryData.user = pf.UserName
        
        // Determine if this is going to logbook or to pending flights
        le.fShuntPending = asPending
        
        let fIsNew = le.entryData.isNewFlight()
        
        // Issue #306: handle "floating" date
        if NSDate.isUnknownDate(dt: le.entryData.date) {
            le.entryData.date = Date()
            setDisplayDate(le.entryData.date)
        }
        
        // get flight telemetry
        app.mfbloc.stopRecordingFlightData()
        if (fIsNew) {
            le.entryData.flightData = app.mfbloc.flightDataAsString()
        } else if !le.entryData.isNewOrAwaitingUpload() { // for existing flights, don't send up flighttrackdata
            le.entryData.flightData = nil
        }
        
        // remove any non-default properties from the list.
        le.entryData.customProperties.setProperties(flightProps.distillList(le.entryData.customProperties.customFlightProperty as? [MFBWebServiceSvc_CustomFlightProperty], includeLockedProps:false, includeTemplates:nil))
        
        le.errorString = "" // assume no error
        
        // if it's a new flight, queue it.  We set the id to -2 to distinguish it from a new flight.
        // If it's unsubmitted, we just no-op and tell the user it's still queued.
        if le.entryData.isNewOrAwaitingUpload() {
            self.le.entryData.flightID = LogbookEntry.PENDING_FLIGHT_ID
        }
        
        // add it to the pending flight queue - it will start submitting when recent flights are viewed
        app.queueFlightForLater(le)
        submitFlightSuccessful()
    }
    
    @objc func submitFlight(_ sender : Any) {
        submitFlightInternal(asPending: false)
    }
    
    func submitPending(_ sender : Any) {
        submitFlightInternal(asPending: true)
    }
    
    // MARK: - Binding data to UI
    public func initLEFromForm() {
        let entryData = le.entryData
        
        // Set _le properties that have not been auto-set already
        if entryData.flightID == nil {
            entryData.flightID = LogbookEntry.NEW_FLIGHT_ID
        }
        entryData.route = idRoute.text;
        entryData.comment = idComments.text;
        entryData.approaches = idApproaches.getValue()
        entryData.fHoldingProcedures = USBoolean(bool: idHold.isSelected)
        entryData.fullStopLandings = idDayLandings.getValue()
        entryData.nightLandings = idNightLandings.getValue()
        entryData.landings = idLandings.getValue()
        
        entryData.cfi = idCFI.getValue()
        entryData.sic = idSIC.getValue()
        entryData.pic = idPIC.getValue()
        entryData.dual = idDual.getValue()
        entryData.crossCountry = idXC.getValue()
        entryData.imc = idIMC.getValue()
        entryData.simulatedIFR = idSimIMC.getValue()
        entryData.groundSim = idGrndSim.getValue()
        entryData.nighttime = idNight.getValue()
        entryData.totalFlightTime = idTotalTime.getValue()
        
        entryData.fIsPublic = USBoolean(bool: idPublic.isSelected)
    }
    
    func setDisplayDate(_ dt : NSDate) {
        idDate.text = NSDate.isUnknownDate(dt: dt as Date) ? String(localized: "lblToday", comment: "Prompt indicating a floating date of TODAY") :  dt.dateString()
    }
    
    func setDisplayDate(_ dt : Date) {
        setDisplayDate(dt as NSDate)
    }
    
    func resetDateOfFlight() {
        if le.entryData.isNewFlight() {
            var dt = Date()
            
            if le.entryData.isKnownEngineStart() && le.entryData.engineStart.compare(dt) == .orderedAscending {
                dt = le.entryData.engineStart
            }
            if le.entryData.isKnownFlightStart() && le.entryData.flightStart.compare(dt) == .orderedAscending {
                dt = le.entryData.flightStart
            }
            let cfp = le.entryData.getExistingProperty(.blockOut)
            if (cfp?.dateValue ?? .distantFuture).compare(dt) == .orderedAscending {
                dt = cfp!.dateValue as Date
            }
            le.entryData.date = dt
            setDisplayDate(dt as NSDate)
        }
    }
    
    func setCurrentAircraft(_ ac : MFBWebServiceSvc_Aircraft?) {
        if ac == nil {
            le.entryData.aircraftID = 0
            le.entryData.tailNumDisplay = ""
            idPopAircraft.text = ""
        } else {
            let fChanged = ac!.aircraftID.intValue != le.entryData.aircraftID.intValue
            le.entryData.aircraftID = ac?.aircraftID
            le.entryData.tailNumDisplay = ac!.displayTailNumber
            idPopAircraft.text = ac!.displayTailNumber
            
            if (fChanged) {
                updateTemplatesForAircraft(ac!)
            }
        }
    }
    
    func initFormFromLE() {
        let entryData = le.entryData;
        
        setDisplayDate(entryData.date as NSDate)
        
        setCurrentAircraft(Aircraft.sharedAircraft.AircraftByID(entryData.aircraftID.intValue))
        self.idRoute.text = entryData.route
        self.idComments.text = entryData.comment
        
        idApproaches.setValueWithDefault(num: entryData.approaches, numDefault: 0.0)
        idLandings.setValueWithDefault(num: entryData.landings, numDefault: 0.0)
        idDayLandings.setValueWithDefault(num: entryData.fullStopLandings, numDefault: 0.0)
        idNightLandings.setValueWithDefault(num: entryData.nightLandings, numDefault: 0.0)
        
        idTotalTime.setValueWithDefault(num: entryData.totalFlightTime, numDefault: 0.0)
        idCFI.setValueWithDefault(num: entryData.cfi, numDefault: 0.0)
        idSIC.setValueWithDefault(num: entryData.sic, numDefault: 0.0)
        idPIC.setValueWithDefault(num: entryData.pic, numDefault: 0.0)
        idDual.setValueWithDefault(num: entryData.dual, numDefault: 0.0)
        idXC.setValueWithDefault(num: entryData.crossCountry, numDefault: 0.0)
        idIMC.setValueWithDefault(num: entryData.imc, numDefault: 0.0)
        idSimIMC.setValueWithDefault(num: entryData.simulatedIFR, numDefault: 0.0)
        idGrndSim.setValueWithDefault(num: entryData.groundSim, numDefault: 0.0)
        idNight.setValueWithDefault(num: entryData.nighttime, numDefault: 0.0)
        idHold.setCheckboxValue(value: entryData.fHoldingProcedures.boolValue)
        
        // sharing options
        idPublic.setCheckboxValue(value: entryData.fIsPublic.boolValue)
    }
    
    // MARK: - send actions for a flight
    func repeatFlight(fReverse: Bool) {
        let leNew = LogbookEntry()
        
        leNew.entryData = fReverse ? le.entryData.cloneAndReverse() : le.entryData.clone()
        
        leNew.entryData.flightID = LogbookEntry.QUEUED_FLIGHT_UNSUBMITTED  // don't auto-submit this flight!
        MFBAppDelegate.threadSafeAppDelegate.queueFlightForLater(leNew)

        let alert = UIAlertController(title: String(localized: "flightActionComplete", comment: "Flight Action Complete Title"),
                                      message: String(localized: "flightActionRepeatComplete", comment: "Flight Action - repeated flight created"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style: .cancel) { _ in
            self.delegate?.flightUpdated(self)
        })

        present(alert, animated: true)
    }
    
    @objc public func sendFlight(_ sender : UIBarButtonItem) {
        let uac = UIAlertController(title: String(localized: "flightActionMenuPrompt", comment: "Actions for this flight"), message:nil, preferredStyle:.actionSheet)
        
        // New Flights
        if le.entryData.isNewFlight() || le.entryData.isAwaitingUpload() || le.entryData is MFBWebServiceSvc_PendingFlight {
            uac.addAction(UIAlertAction(title: String(localized: "flightActionAutoFill", comment: "Flight Action Autofill"), style:.default) { aa in
                self.initLEFromForm()
                if self.le.entryData.isNewFlight() && ((self.le.entryData.flightData ?? "").isEmpty) {
                    self.le.entryData.flightData = MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString();
                }
                GPSSim.autoFill(self.le)
                self.initFormFromLE()
            })

            if le.entryData is MFBWebServiceSvc_PendingFlight {
                uac.addAction(UIAlertAction(title: String(localized: "flightActionRepeatFlight", comment: "Flight Action - repeat a flight"), style:.default) { aa in
                    self.repeatFlight(fReverse: false)
                })
                
                uac.addAction(UIAlertAction(title: String(localized: "flightActionReverseFlight", comment: "Flight Action - repeat and reverse flight"), style:.default) { aa in
                    self.repeatFlight(fReverse: true)
                })
            }
            
            uac.addAction(UIAlertAction(title: String(localized: "flightActionSavePending", comment: "Flight Action - Save Pending"), style:.default) { aa in
                self.submitPending(sender)
            })
            
            if le.entryData.isNewFlight() {
                uac.addAction(UIAlertAction(title: String(localized: "Reset", comment: "Reset button on flight entry"), style:.default) { aa in
                    self.resetFlightWithConfirmation()
                })
            }
        } else {
            uac.addAction(UIAlertAction(title: String(localized: "flightActionRepeatFlight", comment: "Flight Action - repeat a flight"), style:.default) { aa in
                self.repeatFlight(fReverse: false)
            })
            
            uac.addAction(UIAlertAction(title: String(localized: "flightActionReverseFlight", comment: "Flight Action - repeat and reverse flight"), style:.default) { aa in
                self.repeatFlight(fReverse: true)
            })
            
            if !le.entryData.sendFlightLink.isEmpty {
                uac.addAction(UIAlertAction(title: String(localized: "flightActionSend", comment: "Flight Action - Send"), style:.default) { aa in
                    self.le.entryData.sendFlight()
                })
            }
            
            if !le.entryData.socialMediaLink.isEmpty {
                uac.addAction(UIAlertAction(title: String(localized: "flightActionShare", comment: "Flight Action - Share"), style:.default) { aa in
                    self.le.entryData.shareFlight(sender, fromViewController: self)
                })
            }
        }

        uac.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel) { aa in
            uac.dismiss(animated: true)
        })

        let bbiView = sender.value(forKey: "view") as! UIView
        uac.popoverPresentationController?.sourceView = bbiView;
        uac.popoverPresentationController?.sourceRect = bbiView.frame;
        
        present(uac, animated:true)
    }
    
    // MARK: - New Aircraft
    @IBAction func newAircraft() {
        tableView.endEditing(true)
        MyAircraft.pushNewAircraftOnViewController(self.navigationController!)
    }
    
    // MARK: - Signing flights
    @IBAction @objc func signFlight(_ sender : Any) {
        let szURL = MFBProfile.sharedProfile.authRedirForUser(params: "d=SIGNENTRY&idFlight=\(self.le.entryData.flightID.intValue)&naked=1")
        
        let vwWeb = HostedWebViewController(url: szURL)
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()   // this flight could now be invalid
        tableView.endEditing(true)
        navigationController?.pushViewController(vwWeb, animated:true)
    }

    // MARK: - Templates
    func updateTemplatesForAircraft(_ ac: MFBWebServiceSvc_Aircraft) {
        let set = NSMutableSet(set: activeTemplates as! Set)
        FlightProps.updateTemplates(set, forAircraft: ac)
        activeTemplates = set as! Set
    }
    
    public func templatesUpdated(_ templateSet: Set<MFBWebServiceSvc_PropertyTemplate>) {
        activeTemplates = templateSet
        if le.entryData.aircraftID.intValue > 0 {
            updateTemplatesForAircraft(Aircraft.sharedAircraft.AircraftByID(le.entryData.aircraftID.intValue)!)
        }
        let rgAllProps = flightProps.crossProduct(le.entryData.customProperties.customFlightProperty as! [MFBWebServiceSvc_CustomFlightProperty])
        le.entryData.customProperties.setProperties(flightProps.distillList(rgAllProps as? [MFBWebServiceSvc_CustomFlightProperty], includeLockedProps:true, includeTemplates: activeTemplates as NSSet))
        tableView.reloadData()
    }
    
    @objc public func pickTemplates(_ sender : Any) {
        let st = SelectTemplates()
        st.templateSet = activeTemplates
        st.delegate = self
        tableView.endEditing(true)
        if let v = sender as? UIView {
            pushOrPopView(target: st, sender: v, delegate: self)
        } else {
            navigationController?.pushViewController(st, animated: true)
        }
    }

    // MARK: - Approach Helper
    @IBAction func addApproach(_ sender : UIView) {
        let editor = ApproachEditor()
        editor.delegate = self
        editor.airports = Airports.CodesFromString(idRoute.text ?? "")
        tableView.endEditing(true)
        pushOrPopView(target: editor, sender: sender, delegate: self)
    }
    
    public func addApproachDescription(_ approachDescription: ApproachDescription) {
        le.entryData.addApproachDescription(approachDescription.description)
        
        if approachDescription.addToTotals {
            let cApproaches = NSNumber(integerLiteral: le.entryData.approaches.intValue + approachDescription.approachCount)
            le.entryData.approaches = cApproaches
            idApproaches.setValue(num: cApproaches)
        }
        tableView.reloadData()
    }


    // MARK: - Time calculator
    @objc func timeCalculator(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            idTotalTime.resignFirstResponder()
            le.entryData.totalFlightTime = idTotalTime.getValue()
            let tc = TotalsCalculator()
            tc.delegate = self
            tc.initialTotal = le.entryData.totalFlightTime
            tableView.endEditing(true)
            pushOrPopView(target: tc, sender: idTotalTime, delegate: self)
        }
    }
    
    public func updateTotal(_ value: NSNumber) {
        le.entryData.totalFlightTime = value
        idTotalTime.setValue(num: value)
    }
    
    // MARK: - Set Today
    @objc func setToday(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            idDate.resignFirstResponder()
            resetDateOfFlight()
        }
    }
    
    // MARK: - Options
    @objc func configAutoDetect() {
        tableView.endEditing(true)
        navigationController?.pushViewController(AutodetectOptions(nibName: "AutodetectOptions", bundle: nil), animated: true)
    }
    
    // MARK: - LongPressCross-fill support
    @objc func setHighWaterHobbs(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            let target = sender.view as! UITextField
            let highWaterHobbs = Aircraft.sharedAircraft.getHighWaterHobbsForAircraft(le.entryData.aircraftID)
            if highWaterHobbs.doubleValue > 0 {
                target.setValue(num: highWaterHobbs)
                le.entryData.hobbsStart = highWaterHobbs
            }
        }
    }
    
    @objc func setHighWaterTach(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            let target = sender.view as! UITextField
            let highWaterTach = Aircraft.sharedAircraft.getHighWaterTachForAircraft(le.entryData.aircraftID)
            if highWaterTach.doubleValue > 0 {
                target.setValue(num: highWaterTach)
                le.entryData.setPropertyValue(.tachStart, withDecimal: highWaterTach.doubleValue)
            }
        }
    }
    
    @objc func setHighWaterFlightMeter(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            let target = sender.view as! UITextField
            let highWaterMeter = Aircraft.sharedAircraft.getHighWaterFlightMeter(le.entryData.aircraftID)
            if highWaterMeter.doubleValue > 0 {
                target.setValue(num: highWaterMeter)
                le.entryData.setPropertyValue(.flightMeterStart, withDecimal: highWaterMeter.doubleValue)
            }
        }
    }
    
    // MARK: NearbyAirportsDelegate
    public func routeUpdated(_ newRoute: String) {
        idRoute.text = newRoute
        le.entryData.route = newRoute
    }

    // MARK: Nearest airports and autofill
    @IBAction func autofillClosest() {
        let r = Airports.appendNearestAirport(idRoute.text ?? "")
        le.entryData.route = r
        idRoute.text = r
    }

    @objc func appendAdHoc(_ sender : Any) {
        if let coord = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc?.coordinate {
            let szLatLong =  MFBWebServiceSvc_LatLong(coord: coord).toAdhocString()
            le.entryData.route = szLatLong
            idRoute.text = szLatLong
        }
    }
    
    @IBAction func viewClosest() {
        if navigationController != nil {
            le.entryData.route = idRoute.text;
            let vwNearbyAirports = NearbyAirports()
            
            let ap = Airports()
            ap.loadAirportsFromRoute(le.entryData.route)
            vwNearbyAirports.pathAirports = ap
            vwNearbyAirports.routeText = le.entryData.route
            vwNearbyAirports.delegateNearest = le.entryData.isNewFlight() ? self : nil
            
            vwNearbyAirports.associatedFlight = le;
            
            vwNearbyAirports.rgImages = []
            
            if le.entryData.isNewFlight() {
                le.gpxPath = MFBAppDelegate.threadSafeAppDelegate.mfbloc.gpxData()
            }
            
            for ci in self.le.rgPicsForFlight as? [CommentedImage] ?? [] {
                if ci.imgInfo?.location != nil {
                    vwNearbyAirports.addImage(ci)
                }
            }
            tableView.endEditing(true)
            navigationController?.pushViewController(vwNearbyAirports, animated: true)
        }
    }
    
    // MARK: - UIPopoverPresentationController functions
    func refreshProperties() {
        if le.entryData.isNewOrAwaitingUpload() && le.entryData.customProperties == nil {
            le.entryData.customProperties = MFBWebServiceSvc_ArrayOfCustomFlightProperty()
        }

        // refresh will happen async
        let fp = FlightProps()
        fp.loadCustomPropertyTypes()
    }
}
