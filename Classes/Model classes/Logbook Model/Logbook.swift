/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2025 MyFlightbook, LLC
 
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
//  Logbook.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/13/23.
//

import Foundation

@objc public protocol LEControllerProtocol : AutoDetectDelegate {
    @objc func saveState()
    @objc func startEngineExternal()
    @objc func stopEngineExternal()
    @objc func stopEngineExternalNoSubmit()
    @objc func startFlightExternal()
    @objc func stopFlightExternal()
    @objc func blockOutExternal()
    @objc func blockInExternal()
    @objc func resumeFlightExternal()
    @objc func pauseFlightExternal()
    @objc func toggleFlightPause()
    @objc func flightCouldBeInProgress() -> Bool
    @objc var le : LogbookEntry! { get }
}

@objc public protocol RecentFlightsProtocol {
    @objc func addJSONFlight(_ szJSON : String)
    @objc func addTelemetryFlight(_ url : URL)
}

@objc(LogbookEntry) public class LogbookEntry : MFBAsyncOperation, MFBSoapCallDelegate, NSCoding, NSSecureCoding {
    // TODO: Can any of these be made private
    @objc public var entryData = MFBWebServiceSvc_LogbookEntry.getNewLogbookEntry()
    @objc public var rgPicsForFlight = NSMutableArray()
    @objc public var fIsPaused = false
    @objc public var fShuntPending = false
    @objc public var dtTotalPauseTime = TimeInterval()
    @objc public var dtTimeOfLastPause = TimeInterval()
    @objc public var accumulatedNightTime = 0.0
    
    @objc public var rgPathLatLong : MFBWebServiceSvc_ArrayOfLatLong? = nil
    @objc public var szAuthToken : String? = nil
    @objc public var errorString = ""
    @objc public var gpxPath : String? = nil
    @objc public var issues : [String] = []
    
    @objc public var progressLabel : UILabel? = nil

    private var retVal = false

    private let _szKeyPendingFlightsArray = "pref_pendingFlightsArray"
    private let _szkeyEntryData = "_keyEntryData"
    private let _szkeyImages = "_keyImageArray"
    private let _szkeyIsPaused = "_keyIsPaused"
    private let _szkeyShuntPending = "_keyShuntPending"
    private let _szkeyPausedTime = "_pausedTime"
    private let _szkeyLastPauseTime = "_lastPauseTime"
    private let _szkeyAccumulatedNightTime = "_accumulatedNightTime"
    
    private let CONTEXT_FLAG_COMMIT=4038
    
    @objc public static var NEW_FLIGHT_ID : NSNumber {
        get {
            return MFBWebServiceSvc_LogbookEntry.idNewFlight()
        }
    }
    
    @objc public static var PENDING_FLIGHT_ID : NSNumber {
        get {
            return MFBWebServiceSvc_LogbookEntry.idPendingFlight()
        }
    }
    
    @objc public static var QUEUED_FLIGHT_UNSUBMITTED : NSNumber {
        get {
            return MFBWebServiceSvc_LogbookEntry.idQueuedFlight()
        }
    }
    
    // MARK: Play/pause
    private var timeSinceLastPaused : TimeInterval {
        get {
            return fIsPaused ? TimeInterval(Date().timeIntervalSinceReferenceDate - dtTimeOfLastPause) : 0
        }
    }
    
    @objc public var totalTimePaused : TimeInterval {
        get {
            return dtTotalPauseTime + timeSinceLastPaused
        }
    }
    
    @objc func pauseFlight() {
        dtTimeOfLastPause = Date().timeIntervalSinceReferenceDate
        fIsPaused = true
    }
    
    @objc func unPauseFlight() {
        if (fIsPaused) {
            dtTotalPauseTime += self.timeSinceLastPaused
            fIsPaused = false
        }
    }
    
    // MARK: Autofill Utilities
    @objc @discardableResult public func autoFillHobbs() -> Bool {
        var dtHobbs = TimeInterval(0)
        var dtFlight = TimeInterval(0)
        var dtEngine = TimeInterval(0)
        let dtPausedTime = self.totalTimePaused
        
        let hobbsStart = entryData.hobbsStart.doubleValue
        
        if !NSDate.isUnknownDate(dt: entryData.flightStart) && !NSDate.isUnknownDate(dt: entryData.flightEnd) {
            dtFlight = entryData.flightEnd.timeIntervalSince(entryData.flightStart)
        }
        
        if !NSDate.isUnknownDate(dt: entryData.engineStart) && !NSDate.isUnknownDate(dt: entryData.engineEnd) {
            dtEngine = entryData.engineEnd.timeIntervalSince(entryData.engineStart)
        }

                                 
        if hobbsStart > 0 {
            switch (UserPreferences.current.autoHobbsMode)
            {
            case .flight:
                dtHobbs = dtFlight
                break
            case .engine:
                dtHobbs = dtEngine
                break
            case .none:
                break
            default:
                break
            }
            
            dtHobbs -= dtPausedTime;
            
            if (dtHobbs > 0)
            {
                var hobbsEnd = hobbsStart + (dtHobbs / 3600.0);
                // Issue #226 - round to nearest 10th of an hour if needed
                if (UserPreferences.current.roundTotalToNearestTenth) {
                    hobbsEnd = round(hobbsEnd * 10.0) / 10.0;
                }
                self.entryData.hobbsEnd = NSNumber(floatLiteral: hobbsEnd)
                return true
            }
        }
        return false
    }
    
    @objc @discardableResult public func autoCrossCountry(_ dtTotal : TimeInterval) -> Bool {
        let ap = Airports()
        let maxDist = ap.maxDistanceOnRoute(entryData.route)
        
        let fIsCC = (maxDist > MFBConstants.CROSS_COUNTRY_THRESHOLD)
        
        entryData.crossCountry = (fIsCC && dtTotal > 0) ? Double(dtTotal) as NSNumber : 0.0
        return true
    }
    
    @objc public func autoFillTotal() -> Bool {
        let dtPauseTime = self.totalTimePaused / 3600.0  // pause time in hours
        var dtTotal = TimeInterval(0)
        
        var fIsRealAircraft = true
        
        let ac = Aircraft.sharedAircraft.AircraftByID(entryData.aircraftID.intValue)
        if (ac != nil) {
            fIsRealAircraft = !ac!.isSim()
        }
        
        switch (UserPreferences.current.autoTotalMode) {
        case .engine:
            if (!NSDate.isUnknownDate(dt: entryData.engineStart) && !NSDate.isUnknownDate(dt: entryData.engineEnd)) {
                if (entryData.engineEnd.compare(entryData.engineStart) == .orderedDescending) {
                    dtTotal = entryData.engineEnd.timeIntervalSince(entryData.engineStart) / 3600.0 - dtPauseTime
                }
            }
        case .flight:
            if (!NSDate.isUnknownDate(dt: entryData.flightStart) && !NSDate.isUnknownDate(dt: entryData.flightEnd)) {
                let flightStart = entryData.flightStart.timeIntervalSinceReferenceDate
                let flightEnd = entryData.flightEnd.timeIntervalSinceReferenceDate
                dtTotal = ((flightEnd - flightStart) / 3600.0) - dtPauseTime
            }
        case .hobbs:
            let hobbsStart = entryData.hobbsStart.doubleValue
            let hobbsEnd = entryData.hobbsEnd.doubleValue
                // NOTE: we do NOT subtract dtPauseTime here because hobbs should already have subtracted pause time,
                // whether from being entered by user (hobbs on airplane pauses on ground or with engine stopped)
                // or from this being called by autohobbs (which has already subtracted it)
            if (hobbsStart > 0 && hobbsEnd > 0) {
                dtTotal = hobbsEnd - hobbsStart
            }
            case .block:
            var blockOut : Date? = nil
            var blockIn : Date? = nil
                
            for c in entryData.customProperties.customFlightProperty {
                if let cfp = c as? MFBWebServiceSvc_CustomFlightProperty {
                    if (cfp.propTypeID.intValue == PropTypeID.blockOut.rawValue) {
                        blockOut = cfp.dateValue
                    }
                    if (cfp.propTypeID.intValue == PropTypeID.blockIn.rawValue) {
                        blockIn = cfp.dateValue
                    }
                }
            }
            if (!NSDate.isUnknownDate(dt: blockOut) && !NSDate.isUnknownDate(dt: blockIn)) {
                dtTotal = (blockIn!.timeIntervalSince(blockOut!) / 3600.0) - dtPauseTime
            }

        case .flightStartToEngineEnd:
            if !NSDate.isUnknownDate(dt: entryData.flightStart) && !NSDate.isUnknownDate(dt: entryData.engineEnd) {
                dtTotal = entryData.engineEnd.timeIntervalSince(entryData.flightStart) / 3600.0 - dtPauseTime
            }
        case .none:
            return false
            default:
                return false
        }

        if (dtTotal > 0) {
            if (UserPreferences.current.roundTotalToNearestTenth) {
                dtTotal = round(dtTotal * 10.0) / 10.0;
            }

            if (fIsRealAircraft) {
                entryData.totalFlightTime = NSNumber(floatLiteral: dtTotal)
                autoCrossCountry(dtTotal)
            }
            else {
                self.entryData.groundSim = NSNumber(floatLiteral: dtTotal)
            }
            
            return true
        }
        return false
    }
    
    private func autoFillCostOfFlight() {
        // Fill in cost of flight.
        let ac = Aircraft.sharedAircraft.AircraftByID(self.entryData.aircraftID.intValue)
        
        if ac == nil {
            return
        }
        
        let regex = try! NSRegularExpression(pattern: "#PPH:(\\d+(?:[.,]\\d+)?)#", options: .caseInsensitive)
        let m = regex.firstMatch(in: ac!.privateNotes, range: NSRange(location: 0, length: ac!.privateNotes.count))
        if m == nil || m!.numberOfRanges < 2 {
            return
        }

        let rValue = Range(m!.range(at: 1))!
        let rCapture = ac!.privateNotes[rValue]
        let rate = UITextField.valueForString(sz: rCapture, numType: .Decimal, fHHMM: false).doubleValue
        
        if (rate == 0.0) {
            return;
        }
        
        let tachStart = entryData.getExistingProperty(.tachStart)?.decValue.doubleValue ?? 0.0
        let tachEnd = entryData.getExistingProperty(.tachEnd)?.decValue.doubleValue ?? 0.0
        let time = (entryData.hobbsEnd.doubleValue > entryData.hobbsStart.doubleValue && entryData.hobbsStart.doubleValue > 0) ?
            entryData.hobbsEnd.doubleValue - entryData.hobbsStart.doubleValue : ((tachEnd > tachStart && tachStart > 0)  ? tachEnd - tachStart : entryData.totalFlightTime.doubleValue)
                
        if (time > 0) {
            let cost = rate * time;
            entryData.setPropertyValue(.flightCost, withDecimal: cost)
        }
    }
    
    private func autoFillFuel() {
        let cfpFuelAtStart = entryData.getExistingProperty(.fuelAtStart)
        let cfpFuelAtEnd = entryData.getExistingProperty(.fuelAtEnd)
        
        let fuelConsumed = max((cfpFuelAtStart?.decValue.doubleValue ?? 0.0) - (cfpFuelAtEnd?.decValue.doubleValue ?? 0.0), 0.0)

        if (fuelConsumed > 0) {
            entryData.setPropertyValue(.fuelConsumed, withDecimal: fuelConsumed)

            if entryData.totalFlightTime.doubleValue > 0 {
                let burnRate = fuelConsumed / entryData.totalFlightTime.doubleValue
                entryData.setPropertyValue(.fuelBurnRate, withDecimal: burnRate)
            }
        }
    }
    
    private func autoFillInstruction() {
        // Check for ground instruction given or received
        let dual = entryData.dual.doubleValue
        let cfi = entryData.cfi.doubleValue
        
        if ((dual > 0 && cfi == 0) || (cfi > 0 && dual == 0)) {
            let cfpLessonStart = entryData.getExistingProperty(.lessonStart)
            let cfpLessonEnd = entryData.getExistingProperty(.lessonEnd)
            

            if (cfpLessonEnd == nil || cfpLessonStart == nil || cfpLessonEnd!.dateValue.compare(cfpLessonStart!.dateValue) != .orderedDescending) {
                return;
            }

            let tsLesson = cfpLessonEnd!.dateValue.timeIntervalSince(cfpLessonStart!.dateValue)

            
            // pull out flight or engine time, whichever is greater
            let tsFlight = entryData.isKnownFlightEnd() && entryData.isKnownFlightStart() && entryData.flightEnd!.compare(entryData.flightStart) == .orderedDescending ? entryData.flightEnd.timeIntervalSince(entryData.flightStart) : TimeInterval(0)
            let tsEngine = entryData.isKnownEngineEnd() && entryData.isKnownEngineStart() && entryData.engineEnd!.compare(entryData.engineStart) == .orderedDescending ? entryData.engineEnd.timeIntervalSince(entryData.engineStart) : TimeInterval(0)
            
            let tsNonGround = max(max(tsFlight, tsEngine), 0);
            
            let groundHours = (tsLesson - tsNonGround) / 3600.0;
            
            let idPropTarget = dual > 0 ? PropTypeID.groundInstructionReceived : PropTypeID.groundInstructionGiven
            
            if (groundHours > 0) {
                entryData.setPropertyValue(idPropTarget, withDecimal: groundHours)
            }
        }
    }
    
    @objc public func autoFillFinish() {
        autoFillCostOfFlight()
        autoFillFuel()
        autoFillInstruction()
    }
    
    enum LogbookError: Error {
        case runtimeError(String)
    }
    
    // MARK: Commit/delete/retrieve flight
    @objc public func commitFlight() throws {
        NSLog("CommitFlight called")
        
        let sc = MFBSoapCall()
        sc.delegate = self
        
        let pf = entryData as? MFBWebServiceSvc_PendingFlight
        let fIsPendingFlight = pf != nil
        let fIsExistingFlight = !entryData.isNewOrAwaitingUpload()
        
        /*
            Scenarios:
             - fShuntPending is false, Regular flight, new or existing: call CommitFlightWithOptions
             - fShuntPending is false, Pending flight without a pending ID call CommitFlightWithOptions.  Shouldn't happen, but no big deal if it does
             - fShuntPending is false, Pending flight with a Pending ID: call MFBWebServiceSvc_CommitPendingFlight to commit it
             - fShuntPending is false, Pending flight without a pending ID: THROW EXCEPTION, how did this happen?
         
             - fShuntPending is true, Regular flight that is not new/pending (sorry about ambiguous "pending"): THROW EXCEPTION; this is an error
             - fShuntPending is true, Regular flight that is NEW: call MFBWebServiceSvc_CreatePendingFlight
             - fShuntPending is true, PendingFlight without a PendingID: call MFBWebServiceSvc_CreatePendingFlight.  Shouldn't happen, but no big deal if it does
             - fShuntPending is true, PendingFlight with a PendingID: call MFBWebServiceSvc_UpdatePendingFlight
         */
        

        // So...with the above said:
        if fShuntPending {
            if (fIsExistingFlight) {
                throw LogbookError.runtimeError("Attempting to save a flight already in the logbook into pending flights")
            }
            
            // if it's a new logbookentry OR it's a pending flight without a pending ID, add it as a new pending flight
            if !fIsPendingFlight || (pf!.pendingID ?? "").isEmpty {
                NSLog("Add pending flight")
               
                let addPF = MFBWebServiceSvc_CreatePendingFlight()
                addPF.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
                addPF.le = entryData
                sc.makeCallAsync { b, sc in
                    b.createPendingFlightAsync(usingParameters: addPF, delegate: sc)
                }
            } else {
                // Else it MUST be a pending flight and it MUST have a pending ID - update
                NSLog("Update Pending Flight")
                
                if pf == nil {
                    throw LogbookError.runtimeError("updatePendingFlight called on something other than a pending flight!")
                } else {
                    let  updPF = MFBWebServiceSvc_UpdatePendingFlight()
                    updPF.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
                    updPF.pf = pf
                    sc.makeCallAsync { b, sc in
                        b.updatePendingFlightAsync(usingParameters: updPF, delegate: sc)
                    }
                }
            }
        } else {
            // we're going to try to save it as a regular flight.
            if fIsPendingFlight {
                if fIsExistingFlight || pf!.pendingID.isEmpty {
                    throw LogbookError.runtimeError("Attempting to save a flight already in the logbook into pending flights, or save pending flight with no pendingID")
                }
                
                let commitPF = MFBWebServiceSvc_CommitPendingFlight()
                commitPF.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
                commitPF.pf = pf
                
                sc.makeCallAsync { b, sc in
                    b.commitPendingFlightAsync(usingParameters: commitPF, delegate: sc)
                }
            } else {
                // check for videos without WiFi
                if !CommentedImage.canSubmitImages((rgPicsForFlight as! [CommentedImage])) {
                    errorString = String(localized: "ErrorNeedWifiForVids", comment: "Can't upload with videos unless on wifi")
                    operationCompleted(sc)
                    return
                }
                
                let commitFlight = MFBWebServiceSvc_CommitFlightWithOptions()

                commitFlight.le = entryData;
                commitFlight.po = nil;
                commitFlight.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
                                
                sc.contextFlag = CONTEXT_FLAG_COMMIT;

                sc.makeCallAsync { b, sc in
                    b.commitFlightWithOptionsAsync(usingParameters: commitFlight, delegate: sc)
                }
            }
        }
    }

    @objc public func BodyReturned(body : AnyObject) {
        if let resp = body as? MFBWebServiceSvc_CommitFlightWithOptionsResponse {
            entryData = resp.commitFlightWithOptionsResult
            retVal = true
        } else if let resp = body as? MFBWebServiceSvc_DeleteLogbookEntryResponse {
            retVal = resp.deleteLogbookEntryResult.boolValue
        } else if let resp = body as? MFBWebServiceSvc_FlightPathForFlightResponse {
            rgPathLatLong = resp.flightPathForFlightResult
            retVal = true
        } else if let resp = body as? MFBWebServiceSvc_FlightPathForFlightGPXResponse {
            gpxPath = resp.flightPathForFlightGPXResult
            retVal = true
        } else if body is MFBWebServiceSvc_CommitPendingFlightResponse {
            retVal = true
        } else if let resp = body as? MFBWebServiceSvc_UpdatePendingFlightResponse {
            let arr = resp.updatePendingFlightResult.pendingFlight as? [MFBWebServiceSvc_PendingFlight] ?? []
            let szPending = (entryData as! MFBWebServiceSvc_PendingFlight).pendingID!
            entryData = arr.first() { pf in
                pf.pendingID.compare(szPending) == .orderedSame
            }!
            retVal = true
        } else if let resp = body as? MFBWebServiceSvc_CheckFlightResponse {
            issues = resp.checkFlightResult.string as? [String] ?? []
            retVal = true
        } else  if body is MFBWebServiceSvc_CreatePendingFlightResponse {
            // Nothing to do here, really; flights will be picked up in a subsequent call
            retVal = true
        }
    }
        
    @objc public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        
        if sc.contextFlag == CONTEXT_FLAG_COMMIT {
            if sc.errorString.isEmpty {
                CommentedImage.uploadImages(rgPicsForFlight as! [CommentedImage], progressUpdate: { sz in
                    self.progressLabel?.text = sz
                },
                toPage: MFBConstants.MFBFLIGHTIMAGEUPLOADPAGE,
                authString: szAuthToken ?? MFBProfile.sharedProfile.AuthToken,
                keyName: MFBConstants.MFB_KEYFLIGHTIMAGE,
                keyValue: entryData.flightID.stringValue) {
                    self.operationCompleted(sc)
                    // If this was a pending flight, it will be in the pending flight list.  Remove it, if so.
                    MFBAppDelegate.threadSafeAppDelegate.dequeueUnsubmittedFlight(self)
                }
            } else {
                // there was an error - make sure operationCompleted gets called regardless.
                self.operationCompleted(sc)
            }
        } else {
            operationCompleted(sc)
        }
    }
    
    @objc public func deleteFlight(_ idFlight : Int) {
        NSLog("deleteFlight called")

        retVal = false
        
        let sc = MFBSoapCall()
        sc.delegate = self;
        
        let de = MFBWebServiceSvc_DeleteLogbookEntry()
        de.szAuthUserToken = szAuthToken
        de.idFlight = NSNumber(integerLiteral: idFlight)

        sc.makeCallAsync { b, sc in
            b.deleteLogbookEntryAsync(usingParameters: de, delegate: sc)
        }
    }
    
    @objc public func checkFlight() {
        NSLog("checkFlight called")
        let sc = MFBSoapCall()
        sc.delegate = self
        let cf = MFBWebServiceSvc_CheckFlight()
        cf.szAuthUserToken = MFBProfile.sharedProfile.AuthToken
        cf.le = entryData
        sc.makeCallAsync { b, sc in
            b.checkFlightAsync(usingParameters: cf, delegate: sc)
        }
    }
    
    @objc public func getPathFromInProgressTelemetry(_ szTelemetry : String?) {
        let t = Telemetry.telemetryWithString(szTelemetry ?? "")
        let samples = t?.samples ?? []
        
        rgPathLatLong = MFBWebServiceSvc_ArrayOfLatLong()
        for loc in samples {
            let ll = MFBWebServiceSvc_LatLong(coord: CLLocationCoordinate2D(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
            rgPathLatLong?.add(ll)
        }
    }
    
    @objc public func getFlightPath() {
        NSLog("getFlightPath called")
        
        if entryData.isNewOrAwaitingUpload() {
            getPathFromInProgressTelemetry(entryData.isNewFlight() ? MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString() : entryData.flightData)
            operationCompleted(nil)
            return
        }
        
        let sc = MFBSoapCall()
        sc.delegate = self;
        
        let fp = MFBWebServiceSvc_FlightPathForFlight()
        fp.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
        fp.idFlight = entryData.flightID
        
        sc.makeCallAsync { b, sc in
            b.flightPathForFlightAsync(usingParameters: fp, delegate: sc)
        }
    }
    
    @objc public func getGPXDataForFlight() {
        let sc = MFBSoapCall()
        sc.delegate = self;

        let fp = MFBWebServiceSvc_FlightPathForFlightGPX()

        fp.szAuthUserToken = szAuthToken ?? MFBProfile.sharedProfile.AuthToken
        fp.idFlight = entryData.flightID
        
        sc.makeCallAsync { b, sc in
            b.flightPathForFlightGPXAsync(usingParameters: fp, delegate: sc)
        }
    }
    
    // MARK: Persistenc
    @objc public static var supportsSecureCoding: Bool {
        get {
            return true
        }
    }
    
    @objc public func encode(with coder: NSCoder) {
        // Be sure NOT to encode this with the UTCDateFromLocalDate version from commitFlight
        coder.encode(entryData, forKey: _szkeyEntryData)
        
        coder.encode(rgPicsForFlight, forKey:_szkeyImages)
        coder.encode(fIsPaused, forKey:_szkeyIsPaused)
        coder.encode(fShuntPending, forKey:_szkeyShuntPending)
        coder.encode(dtTotalPauseTime, forKey:_szkeyPausedTime)
        coder.encode(dtTimeOfLastPause, forKey:_szkeyLastPauseTime)
        coder.encode(accumulatedNightTime, forKey:_szkeyAccumulatedNightTime)
    }
    
    @objc required public convenience init(coder decoder : NSCoder) {
        self.init()
        
        entryData = decoder.decodeObject(of: MFBWebServiceSvc_LogbookEntry.self, forKey:_szkeyEntryData)!
        rgPicsForFlight = NSMutableArray(array: decoder.decodeObject(of: [CommentedImage.self, NSArray.self, NSMutableArray.self, MFBWebServiceSvc_MFBImageInfo.self], forKey: _szkeyImages) as! [CommentedImage])
        fIsPaused = decoder.decodeBool(forKey: _szkeyIsPaused)
        dtTotalPauseTime = decoder.decodeDouble(forKey: _szkeyPausedTime)
        dtTimeOfLastPause = decoder.decodeDouble(forKey: _szkeyLastPauseTime)
        
        accumulatedNightTime = decoder.decodeDouble(forKey: _szkeyAccumulatedNightTime)
        fShuntPending = decoder.decodeBool(forKey: _szkeyShuntPending)
    }
    
    @objc public func initNumerics() {
        entryData.approaches = NSNumber(integerLiteral: 0)
        entryData.landings = NSNumber(integerLiteral: 0)
        entryData.nightLandings = NSNumber(integerLiteral: 0)
        entryData.fullStopLandings = NSNumber(integerLiteral: 0)
        
        entryData.cfi = NSNumber(floatLiteral: 0)
        entryData.crossCountry = NSNumber(floatLiteral: 0)
        entryData.dual = NSNumber(floatLiteral: 0)
        entryData.imc = NSNumber(floatLiteral: 0)
        entryData.nighttime = NSNumber(floatLiteral: 0)
        entryData.pic = NSNumber(floatLiteral: 0)
        entryData.sic = NSNumber(floatLiteral: 0)
        entryData.simulatedIFR = NSNumber(floatLiteral: 0)
        entryData.groundSim = NSNumber(floatLiteral: 0)
        entryData.totalFlightTime = NSNumber(floatLiteral: 0)
        
        entryData.catClassOverride = NSNumber(integerLiteral: 0)
    }
    
    // JSON format here is described at Support the LogTen Pro API format for a “myflightbook://“ url scheme, as defined at
    // http://s3.amazonaws.com/entp-tender-production/assets/f9e264a74a0b287577bf3035c4f400204336d84d/LogTen_Pro_API.pdf
    @objc public static func addPendingJSONFlights(_ JSONObjToImport : AnyObject) {
        // Get the metadata
        if let dictRoot = JSONObjToImport as? [String : AnyObject] {
            let dictMeta = dictRoot["metadata"] as? [String : String]

            let rgFlights = dictRoot["flights"] as? [[NSString  : AnyObject]]
            // TODO: Error handling, messages
            
            let dfDate = DateFormatter()
            let dfDateTime = DateFormatter()
            
            if let dateFormat = dictMeta?["dateFormat"] {
                dfDate.dateFormat = dateFormat
            }
            if let dateTimeFormat = dictMeta?["dateAndTimeFormat"] {
                dfDateTime.dateFormat = dateTimeFormat
            }
            
            let fZulu = dictMeta?["timesAreZulu"] == nil ? true : dictMeta!["timesAreZulu"]!.compare("true", options:.caseInsensitive) == .orderedSame
            
            let tzZulu = TimeZone(secondsFromGMT: 0)
            dfDate.timeZone = NSTimeZone.local
            dfDateTime.timeZone = fZulu ? tzZulu : NSTimeZone.local
            
            for d in rgFlights ?? [] {
                let le = LogbookEntry()
                le.entryData.flightID = MFBWebServiceSvc_LogbookEntry.idQueuedFlight()
                
                le.errorString = le.entryData.fromJSONDictionary(d, dateFormatter: dfDate, dateTimeFormatter: dfDateTime)

                MFBAppDelegate.threadSafeAppDelegate.queueFlightForLater(le)
            }
        }
    }
}
