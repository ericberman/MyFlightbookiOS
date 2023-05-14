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
//  RouteAnnotation.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/5/23.
//

import Foundation
import MapKit

@objc public class RouteAnnotation : NSObject, MKAnnotation {
    @objc public var center = CLLocationCoordinate2D()
    @objc public var lineColor = UIColor.systemBlue.withAlphaComponent(0.65)
    
    // MARK: MKAnnotation support
    @objc public var coordinate : CLLocationCoordinate2D {
        get {
            return center
        }
    }
    
    @objc public var title : String? {
        return NSStringFromClass(type(of: self)) as String
    }
    
    @objc public var subtitle: String? {
        return ""
    }
    
    internal var coordinates : [CLLocationCoordinate2D] {
        get {
            return []
        }
    }
        
    internal static var SupportsGeoDesic : Bool {
        return NSClassFromString("MKGeodesicPolyline") != nil
    }
    
    @objc public func getOverlay() -> MKPolyline {
        let rgcoord = coordinates
        if (RouteAnnotation.SupportsGeoDesic) {
            let gpl = MKGeodesicPolyline(coordinates: rgcoord, count: rgcoord.count)
            gpl.title = title
            return gpl
        } else {
            let gpl = MKPolyline(coordinates: rgcoord, count: rgcoord.count)
            gpl.title = title
            return gpl
        }
    }
        
    @objc public class func colorForPolyline() -> UIColor  {
        return UIColor.clear
    }
}

@objc public class AirportRoute : RouteAnnotation {
    @objc public var airports : Airports?

    override var coordinates: [CLLocationCoordinate2D] {
        get {
            return airports?.rgAirports.map { $0.coordinate } ?? []
        }
    }
         
    @objc public override class func colorForPolyline() -> UIColor {
        return UserPreferences.current.routeColor.withAlphaComponent(0.65)
    }
}

@objc public class FlightRoute : RouteAnnotation {
    @objc public var rgll : MFBWebServiceSvc_ArrayOfLatLong?
    
    override var coordinates: [CLLocationCoordinate2D] {
        get {
            if let points = rgll?.latLong as? [MFBWebServiceSvc_LatLong] {
                return points.map { $0.coordinate() }
            } else {
                return []
            }
        }
    }
        
    @objc public override class func colorForPolyline() -> UIColor {
        return UserPreferences.current.pathColor.withAlphaComponent(0.65)
    }
}
