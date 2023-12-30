/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  GPSSim.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/6/23.
//

import Foundation

@objc public class GPSSim : NSObject {
    var mfbloc : MFBLocation? = nil
    var leDelegate : MFBWebServiceSvc_LogbookEntry? = nil
    var noDelayOnBackground = false
    
    @objc public override init() {
        super.init()
        mfbloc = MFBAppDelegate.threadSafeAppDelegate.mfbloc
    }
    
    public convenience init(withLoc loc : MFBLocation, delegate: MFBWebServiceSvc_LogbookEntry) {
        self.init()
        mfbloc = loc
        mfbloc?.stopUpdatingLocation()
        leDelegate = delegate
        mfbloc?.delegate = delegate
    }
    
    @objc func FeedEvent(_ loc : CLLocation) {
        mfbloc?.feedEvent(loc)
    }
    
    @discardableResult func FeedEventsFromTelemetry(_ t : Telemetry) -> Date? {
        let rgcoords = t.samples
        if !t.lastError.isEmpty || rgcoords.isEmpty {
            return nil
        }

        // Push the current MFBLocation "onto the stack" as it were - replace the global one for the duration.
        let globalLoc = MFBAppDelegate.threadSafeAppDelegate.mfbloc
        
        if (mfbloc != nil) {
            MFBAppDelegate.threadSafeAppDelegate.mfbloc = mfbloc!
        }
        
        // make sure we don't get spurious location updates from the real GPS
        mfbloc?.stopUpdatingLocation()
        mfbloc?.currentLoc = nil    // so that dates in the past work when using sim.
        mfbloc?.lastSeenLoc = nil
        
        if leDelegate != nil {
            let firstLoc = rgcoords[0]
            mfbloc?.currentLoc = firstLoc
            mfbloc?.lastSeenLoc = firstLoc
            
            // start the flight on the first sample
            if t.hasSpeed {
                // Issue #151: drop seconds from engine start/end
                let dt = (firstLoc.timestamp as NSDate).dateByTruncatingSeconds()
                self.leDelegate?.date = dt!
                self.leDelegate?.engineStart = dt!
            }
            else {
                leDelegate?.date = Date()
                leDelegate?.route = Airports.appendNearestAirport("")
            }
        }
        
        let fIsMainThread = Thread().isMainThread   // save a method call on each iteration.
        NSLog("GPSSim: Starting telemetry feed %@", fIsMainThread ? " on main thread " : " on background thread");
        
        for loc in rgcoords {
            globalLoc.lastSeenLoc = loc
            if leDelegate != nil {
                globalLoc.currentLoc = loc
            }
            if fIsMainThread || noDelayOnBackground {
                FeedEvent(loc)
            } else {
                performSelector(onMainThread: #selector(FeedEvent), with: loc, waitUntilDone: true)
                Thread.sleep(forTimeInterval: 0.05)
            }
        }
        
        NSLog("GPSSim: Ending telemetry feed")

        if let le = leDelegate {
            let lastLoc = rgcoords.last!
            if t.hasSpeed {
                // Issue #151: drop seconds from engine start/end
                let dt = (lastLoc.timestamp as NSDate).dateByTruncatingSeconds()
                le.engineEnd = dt
                le.flightData = mfbloc?.flightDataAsString()
            } else {
                le.route = Airports.appendNearestAirport(le.route)
                le.flightData = t.szRawData
            }
        }

        // restore the global location manager
        mfbloc = nil
        MFBAppDelegate.threadSafeAppDelegate.mfbloc = globalLoc  // restore the prior loc manager (which could be what we've been using!)
        globalLoc.startUpdatingLocation()  // and resume updates
        
        return rgcoords.last!.timestamp
    }
    
    @objc public static func BeginSim() {
        let ft = ImportedFileType.CSV
        var szCSVFilePAth = ""
        var t : Telemetry? = nil
        
        do {
            switch (ft) {
            case .CSV, .Unknown:
                szCSVFilePAth = Bundle.main.path(forResource: "GPSSamples", ofType: "csv")!
                t = try CSVTelemetry(sz: String.init(contentsOfFile: szCSVFilePAth, encoding: .utf8))
            case .GPX:
                szCSVFilePAth = Bundle.main.path(forResource: "tracklog", ofType: "gpx")!
                t = try GPXTelemetry(sz: String.init(contentsOfFile: szCSVFilePAth, encoding: .utf8))
            case .KML:
                szCSVFilePAth = Bundle.main.path(forResource: "tracklog", ofType: "kml")!
                t = try KMLTelemetry(sz: String.init(contentsOfFile: szCSVFilePAth, encoding: .utf8))
            default:
                break
            }
            
            if t != nil {
                autoreleasepool {
                    let sim = GPSSim()
                    DispatchQueue(label: "simqueue", qos: .background).async {
                        sim.FeedEventsFromTelemetry(t!)
                    }
                }
            }
        }
        catch { }
    }
    
    @discardableResult static func autoFill(_ le : LogbookEntry, fromTelemetry t : Telemetry, allowRecording fAllowRecord : Bool) -> Date? {
        let loc = MFBLocation()
        if (!fAllowRecord) {
            loc.fSuppressAllRecording = true
        }

        let sim = GPSSim(withLoc: loc, delegate: le.entryData)
        sim.noDelayOnBackground = true
        let finalDate = sim.FeedEventsFromTelemetry(t)

        if !t.lastError.isEmpty {
            le.errorString = t.lastError
        }
        return finalDate
    }
    
    @objc public static func ImportTelemetry(_ url : URL) -> LogbookEntry? {

        let le = LogbookEntry()
        le.entryData = MFBWebServiceSvc_LogbookEntry.getNewLogbookEntry()
        le.entryData.aircraftID = NSNumber(integerLiteral: Aircraft.sharedAircraft.DefaultAircraftID)
        
        guard let t = Telemetry.telemetryWithURL(url) else {
            return nil
        }

        GPSSim.autoFill(le, fromTelemetry: t, allowRecording: true)
        
        if let szTail = t.metaData[Telemetry.TELEMETRY_META_AIRCRAFT_TAIL] as? String, let ac = Aircraft.sharedAircraft.AircraftByTail(szTail) {
            le.entryData.aircraftID = ac.aircraftID;
        }

        le.entryData.flightID = LogbookEntry.QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
        MFBAppDelegate.threadSafeAppDelegate.performSelector(onMainThread: #selector(MFBAppDelegate.queueFlightForLater), with: le, waitUntilDone: false)

        return le
    }
    
    public static func autoFill(_ le : LogbookEntry?) {
        guard let ed = le?.entryData else {
            return
        }
        
        // Issue # 314 - turn on autodetection if not on
        let savedAutodetect = UserPreferences.current.autodetectTakeoffs
        UserPreferences.current.autodetectTakeoffs = true
        
        var blockOut : Date? = nil
        var blockIn : Date? = nil
        var t : Telemetry? = nil
        let cfpBlockIn = ed.getExistingProperty(PropTypeID.blockIn.rawValue)
        let cfpBlockOut = ed.getExistingProperty(PropTypeID.blockOut.rawValue);
        
        // blockIn / blockOut here is not strictly block in/out, it's just "Best guess start / end"
        blockOut = cfpBlockOut?.dateValue ?? (ed.isKnownEngineStart() ? ed.engineStart : (ed.isKnownFlightStart() ? ed.flightStart : nil))
        blockIn = cfpBlockIn?.dateValue ?? (ed.isKnownEngineEnd() ? ed.engineEnd : (ed.isKnownFlightEnd() ? ed.flightEnd : nil))
        
        var fSetXC = false
        var fSyntheticPath = false
        var fSetNight = false
        
        if (ed.flightData ?? "").isEmpty {
            if blockOut != nil && blockIn != nil && blockOut!.compare(blockIn!) == .orderedAscending {
                // generate synthetic path IF we have exactly two airports
                let ap = Airports()
                fSetXC = ap.maxDistanceOnRoute(ed.route) > MFBConstants.CROSS_COUNTRY_THRESHOLD    // maxDistanceOnRoute will call loadAirports.
                
                // issue #286: don't do a synthetic path if autodetection is off because it will clear a bunch of fields but won't fill them back in.
                if ap.rgAirports.count == 2 && UserPreferences.current.autodetectTakeoffs {
                    t = Telemetry.synthesizePathFrom(fromLoc: ap.rgAirports[0].latLong.coordinate(), toLoc: ap.rgAirports[1].latLong.coordinate(), dtStart: blockOut, dtEnd: blockIn)
                    fSyntheticPath = t != nil
                    
                    if fSyntheticPath && !ed.isKnownEngineStart() {
                            ed.engineStart = Date(timeInterval: 0, since: blockOut!)  // use datewithtimeinterval to create a new copy, not a reference.
                    }
                }
            }
        } else {
            t = Telemetry.telemetryWithString(ed.flightData)
            ed.flightStart = nil
            ed.flightEnd = nil   // we will recompute these
        }
        
        // We now have telemetry (either measured or synthesized).
        if t != nil {
            // Clear all of the things that can be computed
            var dtEngineSaved = ed.engineEnd;   // clear this so that flight will appear to be in progress
            ed.engineEnd = nil

            let dtBlockInSaved = cfpBlockIn?.dateValue  // clear block-in as well - see issue #316
            cfpBlockIn?.dateValue = nil
            
            ed.route = ""
            ed.totalFlightTime = NSNumber(floatLiteral: 0.0)
            ed.crossCountry = NSNumber(floatLiteral: 0.0)
            ed.nighttime = NSNumber(floatLiteral: 0.0)
            ed.landings = NSNumber(integerLiteral: 0)
            ed.fullStopLandings = NSNumber(integerLiteral: 0)
            ed.nightLandings = NSNumber(integerLiteral: 0)
            ed.removeProperty(PropTypeID.nightTakeOff)
            fSetNight = true
            
            let szDataSaved = ed.flightData
            let tsFinal = GPSSim.autoFill(le!, fromTelemetry: t!, allowRecording: false)
            
            // close off engine end if we don't have one that we saved.
            if NSDate.isUnknownDate(dt: dtEngineSaved) {
                dtEngineSaved = tsFinal
            }
            ed.engineEnd = dtEngineSaved            // restore engine end.  If synthetic path, this will be overwritten below anyhow.
            cfpBlockIn?.dateValue = dtBlockInSaved  // restore block-in time.
            ed.flightData = szDataSaved             // Restore flight data.  If synthetic path, this will be overwritten below anyhow.
        }
        
        if (fSyntheticPath) {
            ed.flightData = ""
            if !ed.isKnownEngineEnd() {
                ed.engineEnd = blockIn == nil ? nil : Date(timeInterval: 0, since: blockIn!)
            }
        }
        
        // Autototal based on any of the above
        var dtTotal = (ed.hobbsEnd.doubleValue > ed.hobbsStart.doubleValue && ed.hobbsStart.doubleValue > 0) ?
            // hobbs has priority, if present
            ed.hobbsEnd.doubleValue - ed.hobbsStart.doubleValue :
        ((blockIn != nil && blockOut != nil && blockIn!.compare(blockOut!) == .orderedDescending) ?
         blockIn!.timeIntervalSince(blockOut!) / 3600.0 : 0.0)
        
        if UserPreferences.current.roundTotalToNearestTenth {
            dtTotal = round(dtTotal * 10.0) / 10.0
            if fSetNight {
                ed.nighttime = NSNumber(floatLiteral: round(ed.nighttime.doubleValue * 10.0) / 10.0)
            }
        }

        if ed.totalFlightTime.doubleValue == 0 {
            ed.totalFlightTime = NSNumber(floatLiteral: dtTotal)
        }
        
        // And autohobbs, if appropriate.
        le?.autoFillHobbs()
        
        if (fSetXC) {
            ed.crossCountry = NSNumber(floatLiteral: ed.totalFlightTime.doubleValue)
        }
        
        le?.autoFillFinish()
        
        // Restore previous autodetection settings
        UserPreferences.current.autodetectTakeoffs = savedAutodetect
    }
}
