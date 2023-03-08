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

/*
// TODO: Migrate GPSSim here; depends on LogbookEntry, though.
@objc public class GPSSim : NSObject {
    var mfbloc : MFBLocation? = nil
    var leDelegate : MFBWebServiceSvc_LogbookEntry? = nil
    var noDelayOnBackground = false
    
    @objc public override init() {
        super.init()
        self.mfbloc?.stopUpdatingLocation()
    }
    
    func FeedEvent(_ loc : CLLocation) {
        mfbloc?.feedEvent(loc)
    }
    
    @discardableResult func FeedEventsFromTelemetry(_ t : Telemetry) -> Date? {
        var rgcoords = t.samples
        if !t.lastError.isEmpty || rgcoords.isEmpty {
            return nil
        }

        // Push the current MFBLocation "onto the stack" as it were - replace the global one for the duration.
        let globalLoc = SwiftHackBridge.globalMFBLoc()
        
        if (mfbloc != nil) {
            SwiftHackBridge.setGlobalMFBLoc(mfbloc)
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
            globalLoc?.lastSeenLoc = loc
            if leDelegate != nil {
                globalLoc?.currentLoc = loc
            }
            if fIsMainThread || noDelayOnBackground {
                FeedEvent(loc)
            } else {
                DispatchQueue.main.async {
                    self.FeedEvent(loc)
                }
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
        SwiftHackBridge.setGlobalMFBLoc(globalLoc)    // restore the prior loc manager (which could be what we've been using!)
        globalLoc?.startUpdatingLocation()  // and resume updates
        
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
    
    @objc public static autofill:(LogbookEnetry) {
        // TODO: Requires more of LogbookEntry to be converted
    }
}
 */
