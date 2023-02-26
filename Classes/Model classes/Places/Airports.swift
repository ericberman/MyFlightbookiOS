/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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
//  Airports.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/25/23.
//

import Foundation
import MapKit
import SQLite3

@objc public class Airports : NSObject {
    @objc public var errorString = ""
    @objc public var rgAirports : [MFBWebServiceSvc_airport] = []

    public static let szUSAirportPrefix = "K"
    public static let szNavaidPrefix = "@"
    
    private static let MIN_NAVAID_CODE_LENGTH = 2
    private static let MIN_AIRPORT_CODE_LENGTH = 3
    private static let MAX_AIRPORT_CODE_LENGTH = 6
        
    private static let RegAdHocFix = "\(szNavaidPrefix)\\b\\d{1,2}(?:[\\.,]\\d*)?[NS]\\d{1,3}(?:[\\.,]\\d*)?[EW]\\b"  // Must have a digit on the left side of the decimal
    
    private static let RegexAirports = String(format:"((?:%@)|(?:@?\\b[A-Z0-9]{%d,%d}\\b))", RegAdHocFix, min(MIN_NAVAID_CODE_LENGTH, MIN_AIRPORT_CODE_LENGTH), MAX_AIRPORT_CODE_LENGTH)
    
    private static var _reAdhoc : NSRegularExpression?
    private static var _reAirports : NSRegularExpression?
    
    public static func degreesToRadians(_ degrees : Double) -> Double {
        return (degrees * 0.0174532925199433)
    }
    
    public static func isAdhocFix(sz : String) -> Bool {
        if (_reAdhoc == nil) {
            _reAdhoc = try! NSRegularExpression(pattern: Airports.RegAdHocFix, options:.caseInsensitive)
        }
        return _reAdhoc!.numberOfMatches(in: sz, range: NSMakeRange(0, sz.count)) > 0
    }
    
    @objc public override init() {
        super.init()
    }
    
    @objc public static func defaultRegionForPosition(_ loc : CLLocation) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: loc.coordinate, span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))
    }
    
    @discardableResult @objc(loadAirportsNearPosition: limit:) public func loadAirportsNearPosition(_ loc : MKCoordinateRegion, max : Int) -> Bool {
        errorString = ""
        rgAirports = []
        
        let db = SwiftHackBridge.getDB()

        let la = LocalAirports(loc: loc, db: db, limit: max)
        rgAirports = la.rgAirports
        return !errorString.isEmpty
    }
    
    @objc(appendAirport:ToRoute:) public static func appendAirport(_ ap : MFBWebServiceSvc_airport?, szRouteSoFar : String?) -> String {
        var szReturn = szRouteSoFar ?? ""

        if szReturn.isEmpty {
            return ap?.code ?? ""
        }
        
        if (!(ap?.code ?? "").isEmpty) {
            // check that this airport is not already at the end of the list
            let szCurrent = szReturn    // guaranteed non-nil
            let r = szCurrent.range(of: ap!.code!, options: [.backwards, .caseInsensitive])
 
            // if it's not at the end of the list OR szCurrent is still nil, append it.
            if (r == nil) {
                szReturn = "\(szReturn.trimmingCharacters(in: .whitespaces)) \(ap!.code!)".uppercased().trimmingCharacters(in: .whitespaces)
            }
        }
        return szReturn
    }
    
    @objc public static func appendNearestAirport(_ szRouteSoFar : String) -> String {
        let ap = Airports()
        let lastLoc = SwiftHackBridge.lastLoc()
        if (lastLoc == nil) {
            return szRouteSoFar
        }
        
        ap.loadAirportsNearPosition(Airports.defaultRegionForPosition(lastLoc!), max: 1)
        return (ap.rgAirports.isEmpty) ? szRouteSoFar : Airports.appendAirport(ap.rgAirports[0], szRouteSoFar: szRouteSoFar)
    }
    
    @objc public func loadAirportsFromRoute(_ szRoute : String) -> Void {
        NSLog("loadAirportsFromRoute")
        errorString = ""
        
        rgAirports = []
        
        let loc = SwiftHackBridge.lastLoc()
        
        let la = LocalAirports.init(szAirports: szRoute, db: SwiftHackBridge.getDB(), loc: loc?.coordinate)
        
        self.rgAirports = la.rgAirports
    }
    
    @objc public func maxDistanceOnRoute(_ szRoute : String) -> Double {
        var dist = 0.0
        
        self.loadAirportsFromRoute(szRoute)
        
        let cAirports = rgAirports.count
        for i in 0 ..< cAirports {
            let ap1 = rgAirports[i]
            if (!ap1.isPort()) {
                continue
            }
            
            for j in i + 1 ..< cAirports {
                let ap2 = rgAirports[j]
                
                if (!ap2.isPort()) {
                    continue
                }
                
                let lat1rad = Airports.degreesToRadians(ap1.latLong.latitude.doubleValue)
                let lon1 = ap1.latLong.longitude.doubleValue
                let lat2rad = Airports.degreesToRadians(ap2.latLong.latitude.doubleValue)
                let lon2 = ap2.latLong.longitude.doubleValue
                let d = acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(Airports.degreesToRadians(lon2) - Airports.degreesToRadians(lon1))) * 3440.06479;
                dist = max(d, dist)
            }
        }
        return dist
    }
    
    @objc public func defaultZoomRegionWithPath(_ rgll : MFBWebServiceSvc_ArrayOfLatLong?) -> MKCoordinateRegion {
        let llb = LatLongBox()
        
        if (!rgAirports.isEmpty) {
            for ap in rgAirports {
                llb.addPoint(ap.latLong.coordinate())
            }
        }
        
        if ((rgll?.latLong?.count ?? 0) > 0) {
            for ll in rgll!.latLong {
                if let l = ll as? MFBWebServiceSvc_LatLong {
                    llb.addPoint(l.coordinate())
                }
            }
        }
        return llb.getRegion()
    }
    
    @objc public static func CodesFromString(_ szAirports : String) -> [String] {
        var rgResult : [String] = []
        if (_reAirports == nil) {
            _reAirports = try! NSRegularExpression(pattern: Airports.RegexAirports, options: .caseInsensitive)
        }
        
        let airports = szAirports.uppercased()
        let rgMatches = _reAirports!.matches(in: airports, range: NSMakeRange(0, airports.count))
        for tcr in rgMatches {
            rgResult.append(String(airports[Range(tcr.range, in: airports)!]))
        }

        return rgResult
    }
}

@objc class LocalAirports : NSObject {
    @objc public var database : OpaquePointer? = nil
    @objc public var rgAirports : [MFBWebServiceSvc_airport] = []
    
    private static func distanceColumnFromLoc(_ loc : CLLocationCoordinate2D?) -> String {
        if (loc == nil) {
            return "0 AS Distance"  // no loc = zero distance
        }
        
        return String(format: "distance(ap.latitude, ap.longitude, %.8f, %.8f) AS Distance",
                      loc!.latitude,
                      loc!.longitude)
    }
    
    private static func isUSAirport(_ szAirport : String) -> Bool {
        return szAirport.count == 4 && szAirport.hasPrefix(Airports.szUSAirportPrefix)
    }
    
    private static func USAirportPrefix(_ szAirport : String) -> String {
        return isUSAirport(szAirport) ? String(szAirport[szAirport.index(after: szAirport.startIndex)...]) : szAirport
    }
    
    private override init() {
        super.init()
    }
    
    @objc(initWithLocation: withDB: withLimit:) public convenience init(loc : MKCoordinateRegion, db : OpaquePointer?, limit : Int) {
        self.init()
        database = db
        rgAirports =  []
        
        // if the span is more than about 4 degrees in either direction, return
        // an empty set - we're too far zoomed out to be meaningful.
        if (loc.span.latitudeDelta > 4.0 || loc.span.longitudeDelta > 4.0) {
            return
        }
        
        var sqlAirportsNearPosition : OpaquePointer?
        
        let lat = loc.center.latitude
        let lon = loc.center.longitude
        
        // BUG: this doesn't work if we cross 180 degrees, but there are so few airports there that it shouldn't matter
        let minLat = max(lat - (loc.span.latitudeDelta / 2.0), -90.0);
        let maxLat = min(lat + (loc.span.latitudeDelta / 2.0), 90.0);
        let minLong = lon - (loc.span.longitudeDelta / 2.0);
        let maxLong = lon + (loc.span.longitudeDelta / 2.0);

        // we don't bother correcting lon's below -180 or above +180 for reason above
        let lastLoc = SwiftHackBridge.lastLoc()
        let curLoc = (lastLoc == nil) ? loc.center : lastLoc!.coordinate
        
        let fHeliports = UserPreferences.current.includeHeliports
        
        let szSql = String(format: "SELECT ap.*, %@ FROM airports ap WHERE ap.latitude BETWEEN %.8F AND %.8F AND ap.longitude BETWEEN %.8F AND %.8F AND Type IN %@ ORDER BY ROUND(Distance, 2) ASC, Preferred DESC, length(AirportID) DESC %@",
                           LocalAirports.distanceColumnFromLoc(curLoc),
                           minLat, maxLat, minLong, maxLong,
                           fHeliports ? "('H', 'A', 'S')" : "('A', 'S')",
                           limit > 0 ? String(format: "LIMIT %d", limit) : "")
        if (sqlite3_prepare(database, szSql.cString(using: .ascii), -1, &sqlAirportsNearPosition, nil) != SQLITE_OK) {
            NSLog("Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database))
        }
        
        while (sqlite3_step(sqlAirportsNearPosition) == SQLITE_ROW) {
            rgAirports.append(MFBWebServiceSvc_airport(row: sqlAirportsNearPosition))
        }
        
        sqlite3_finalize(sqlAirportsNearPosition)
    }
    
    public convenience init(szAirports : String, db : OpaquePointer?, loc : CLLocationCoordinate2D?) {
        self.init()
        database = db
        rgAirports = []
        
        var dictAp : [String : MFBWebServiceSvc_airport] = [:]
        var sqlResolveAirports : OpaquePointer?
        
        // Break up the string into constituent airports
        let rgCodes = Airports.CodesFromString(szAirports)
        if (rgCodes.isEmpty) {
            return
        }
        
        // Find any matches in the database.
        // Need to strip any leading "@" for the actual search; we'll apply this logic further below.
        let szAirportSet = NSMutableString()
        for ac in rgCodes {
            var airportCode = ac
            // If it's an ad-hoc fix, just add it directly to the dictionary
            if (Airports.isAdhocFix(sz: airportCode)) {
                let apAdHoc = MFBWebServiceSvc_airport.getAdHoc(airportCode)
                if (apAdHoc != nil) {
                    dictAp[airportCode] = apAdHoc
                    continue
                }
            }
            
            // Strip the leading "@" if necessary:
            if (airportCode .hasPrefix("@")) {
                airportCode = String(airportCode[airportCode.index(after: airportCode.startIndex)...])
            }
            szAirportSet.appendFormat("%@\"%@\"", szAirportSet.length > 0 ? ", " : "", airportCode)
            if (LocalAirports.isUSAirport(airportCode)) {
                szAirportSet.appendFormat("%@\"%@\"", szAirportSet.length > 0 ? ", " : "", LocalAirports.USAirportPrefix(airportCode))
            }
        }
        
        let szSql = String(format: "SELECT ap.*, %@ FROM airports ap WHERE ap.airportID in (%@)",
                           LocalAirports.distanceColumnFromLoc(loc), szAirportSet)
        
        if (sqlite3_prepare(database, szSql.cString(using: .ascii), -1, &sqlResolveAirports, nil) != SQLITE_OK) {
            NSLog("Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database))
        }
        
        // Read the results and put them into a dictionary by their code
        while (sqlite3_step(sqlResolveAirports) == SQLITE_ROW) {
            let ap = MFBWebServiceSvc_airport(row: sqlResolveAirports)
            
            // if it's an airport/heliport/seaport, store it using its code
            if (ap.isPort()) {
                dictAp[ap.code] = ap
            } else {
                // else store it using the navaid key (prefix "@"), replacing any lower priority (higher navaid priority) navaid
                let szKey = "\(Airports.szNavaidPrefix)\(ap.code!)"
                let ap2 = dictAp[szKey]
                if (ap2 == nil || ap.NavaidPriority() < ap2!.NavaidPriority()) {
                    dictAp[szKey] = ap
                }
            }
            // slightly more efficient than autorelease
        }
        sqlite3_finalize(sqlResolveAirports);
        
        // We now have in dictAp an dictionary of the typed airports, in no particular order and effectively deduped by the database
        // Now we need to add the airports to rgairports in the order in which they were typed.
        for szTypedCode in rgCodes {
            var ap = dictAp[szTypedCode]
            
            // if not found, see if it is under the navaid
            if (ap == nil) {
                ap = dictAp["\(Airports.szNavaidPrefix)\(szTypedCode)"]
            }
            
            // if that didn't work, try seeing if it's there without the "K" prefix
            if (ap == nil) {
                ap = dictAp[LocalAirports.USAirportPrefix(szTypedCode)]
            }
            
            if (ap != nil) {
                rgAirports.append(ap!)
            }
        }
    }
}
