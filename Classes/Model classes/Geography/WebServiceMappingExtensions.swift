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
//  WebServiceAirportExtensions.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/26/23.
//

import Foundation
import SQLite3
import MapKit


// MARK: MFBWebServiceSvc_airport extensions
extension MFBWebServiceSvc_airport : MKAnnotation {
    @objc(initFromRow:) public convenience init(row : OpaquePointer?) {
        self.init()
        if row != nil {
            code = String(cString: sqlite3_column_text(row, 0))
            name = String(cString: sqlite3_column_text(row, 1))
            latLong = MFBWebServiceSvc_LatLong()
            latLong.latitude = NSNumber(floatLiteral: sqlite3_column_double(row, 4))
            latLong.longitude = NSNumber(floatLiteral: sqlite3_column_double(row, 5))
            latitude = latLong.latitude.stringValue
            longitude = latLong.longitude.stringValue
            facilityTypeCode = String(cString: sqlite3_column_text(row, 2))
            // column 3 is sourceusername - ignore it.
            // column 6 is preferred - ignore it
            var sz = sqlite3_column_text(row, 7)
            country = (sz == nil) ? "" : String(cString: sz!)
            sz = sqlite3_column_text(row, 8)
            admin1 = (sz == nil) ? "" : String(cString: sz!)
            distanceFromPosition = NSNumber(floatLiteral: sqlite3_column_double(row, 9))
        }
    }
    
    // MKAnnotation
    @objc public var coordinate : CLLocationCoordinate2D {
        if (self.latLong != nil) {
            return CLLocationCoordinate2D(latitude: latLong.latitude.doubleValue, longitude: latLong.longitude.doubleValue)
        } else {
            return CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
        }
    }
    
    @objc public var title : String? {
        return "\(code ?? "") \(name ?? "")"
    }
    
    @objc(compareDistance:) public func compareDistance(ap : MFBWebServiceSvc_airport) -> ComparisonResult {
        return distanceFromPosition.compare(ap.distanceFromPosition)
    }
    
    @objc public var subtitle : String? {
        var dist = distanceFromPosition.doubleValue
        let lastLoc = SwiftHackBridge.lastLoc()
        if (dist == 0.0 && lastLoc != nil) {
            // try to compute the distance
            let cloc = lastLoc!.coordinate
            if (cloc.latitude != 0.0 && cloc.longitude != 0.0) {
                dist = MFBConstants.NM_IN_A_METER * lastLoc!.distance(from: CLLocation(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0))
            }
        }
        let szDistance = String(format: String(localized: " (%.1fNM away)", comment: "Distance to airport - %.1f is replaced by the distance in nautical miles"), dist)
        
        let szcountry = country ?? ""
        let szAdmin = admin1 ?? ""
        let szLocale = (szcountry.isEmpty || szcountry.starts(with: "--")) ? "" : "\(szAdmin)\(!szAdmin.isEmpty && !szcountry.isEmpty ? ", " : "")\(szcountry)".trimmingCharacters(in: .whitespaces)
        return szLocale.isEmpty ? self.name : "\(szLocale) \(dist == 0.0 ? "" : szDistance)"
    }
    
    @objc(getAdHoc:) public static func getAdHoc(_ szLatLon : String) -> MFBWebServiceSvc_airport? {
        let ap = MFBWebServiceSvc_airport()
        let ll = MFBWebServiceSvc_LatLong.fromString(szLatLon)
        if (ll == nil) {
            return nil
        }
        let loc = SwiftHackBridge.lastLoc()
        ap.latLong = ll!
        ap.latitude = ll!.latitude.stringValue
        ap.longitude = ll!.longitude.stringValue
        ap.facilityType = "FX"
        ap.facilityTypeCode = "FX"
        
        ap.distanceFromPosition = NSNumber(floatLiteral: MFBConstants.NM_IN_A_METER * (loc == nil ? 0 : loc!.distance(from: CLLocation(latitude: ll!.latitude.doubleValue, longitude: ll!.longitude.doubleValue))))
        ap.name = ll!.description
        ap.code = szLatLon
        ap.userName = ""
        return ap
    }
    
    @objc public func isAdhoc() -> Bool {
        return Airports.isAdhocFix(sz: "\(Airports.szNavaidPrefix)\(self.code ?? "")")
    }
    
    @objc public func isPort() -> Bool {
        return facilityTypeCode == "A" || facilityTypeCode == "S" || facilityTypeCode == "H"
    }
    
    @objc public func NavaidPriority() -> Int {
        // Airports ALWAYS have priority
        if (self.isPort()) {
            return 0
        }

        // Otherwise, give priority to VOR/VORTAC/etc., else NDB, else GPS fix, else everything else
        // VOR Types:
        if (facilityTypeCode == "V" ||
            facilityTypeCode == "C" ||
            facilityTypeCode == "D" ||
            facilityTypeCode == "T") {
            return 1
        }
        
        // NDB Types:
        if (facilityTypeCode == "R" ||
            facilityTypeCode == "RD" ||
            facilityTypeCode == "M" ||
            facilityTypeCode == "MD" ||
            facilityTypeCode == "U") {
            return 2
        }
        
        // Generic fix
        if (facilityTypeCode == "FX") {
            return 3
        }
        
        return 4;
    }
    
    @objc public override var description: String {
        return "\(facilityTypeCode ?? "") (\(code ?? "")) \(name ?? "")"
    }
}

// MARK: MFBWebServiceSvc_VisitedAirport extensions
extension MFBWebServiceSvc_VisitedAirport : MKAnnotation {
    @objc public func compareName(_ va : MFBWebServiceSvc_VisitedAirport) -> ComparisonResult {
        return airport.name.compare(va.airport.name, options: .caseInsensitive)
    }
    
    @objc public func AllCodes() -> String {
        return "\(code ?? ""),\(aliases ?? "")"
    }
    
    @objc public override var description : String {
        return airport.description
    }
    
    // Allow a visited airport to be annotatable based on the underlying airport.
    @objc public var coordinate : CLLocationCoordinate2D {
        return airport.coordinate
    }
    
    @objc public var title : String? {
        return airport.title ?? ""
    }
    
    @objc public var subtitle : String? {
        return airport.subtitle ?? ""
    }
}

// MARK: MFBWebServiceSvc_LatLong extensions
extension MFBWebServiceSvc_LatLong {
    @objc public override var description : String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 8
        return "\(nf.string(from: latitude)!), \(nf.string(from: longitude)!)"
    }
    
    @objc public func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    }
    
    @objc public static func fromString(_ szIn : String) -> MFBWebServiceSvc_LatLong? {
        let sz = szIn.uppercased()
        do {
            let reAirports = try NSRegularExpression(pattern: "@?([^a-zA-Z]+)([NS]) *([^a-zA-Z]+)([EW])", options: .caseInsensitive)
            let rgMatches = reAirports.matches(in: sz, range: NSMakeRange(0, sz.count))
            if (!rgMatches.isEmpty) {
                let tcr = rgMatches[0]
                let ll = MFBWebServiceSvc_LatLong()
                let szLatString = sz[Range(tcr.range(at: 1), in: sz)!]
                let szLatNS = sz[Range(tcr.range(at: 2), in: sz)!]
                let szLonString = sz[Range(tcr.range(at: 3), in: sz)!]
                let szLonEW = sz[Range(tcr.range(at: 4), in: sz)!]
                ll.latitude = NSNumber(floatLiteral: (Double(szLatString) ?? 0.0) * (szLatNS == "N" ? 1 : -1))
                ll.longitude = NSNumber(floatLiteral: (Double(szLonString) ?? 0.0) * (szLonEW == "E" ? 1 : -1))
                return ll
            }
        }
        catch {
            return nil
        }
        return nil
    }
    
    @objc(initWithCoord:) public convenience init(coord : CLLocationCoordinate2D) {
        self.init()
        latitude = NSNumber(floatLiteral: coord.latitude)
        longitude = NSNumber(floatLiteral: coord.longitude)
    }

    @objc public func toAdhocString() -> String {
        let  nf = NumberFormatter()
        nf.maximumFractionDigits = 4
        let latString = nf.string(from: NSNumber(floatLiteral: abs(latitude.doubleValue)))!
        let lonString = nf.string(from: NSNumber(floatLiteral: abs(longitude.doubleValue)))!
        return "\(Airports.szNavaidPrefix)\(latString)\(latitude.doubleValue > 0 ? "N" : "S")\(lonString)\(longitude.doubleValue > 0 ? "E" : "W")"
    }
}
