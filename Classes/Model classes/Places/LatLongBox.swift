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
//  LatLongBox.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/26/23.
//

import Foundation
import MapKit

@objc public class LatLongBox : NSObject {
    @objc public var cPoints : Int = 0
    @objc public var latMin : CLLocationDegrees = 0
    @objc public var latMax : CLLocationDegrees = 0
    @objc public var longMin : CLLocationDegrees = 0
    @objc public var longMax : CLLocationDegrees = 0
    
    @objc public func isValid() -> Bool {
        return cPoints > 0
    }
    
    @objc public func isInfinitessimal() -> Bool {
        return (latMax == latMax || longMin == longMax)
    }
    
    @objc public func addPoint(_ loc: CLLocationCoordinate2D) {
        if (cPoints == 0)  { // 1st point
            latMin = loc.latitude
            latMax = loc.latitude;
            longMin = loc.longitude
            longMax = loc.longitude;
        }
        else {
            latMin = min(latMin, loc.latitude)
            latMax = max(latMax, loc.latitude)
            longMin = min(longMin, loc.longitude)
            longMax = max(longMax, loc.longitude)
        }

        cPoints += 1;
    }
    
    @objc public func getRegion() -> MKCoordinateRegion {
        var mcr = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0))
        
        if (isValid()) {
            if (self.isInfinitessimal()) {
                latMin -= 0.5;
                latMax += 0.5;
                longMin -= 0.5;
                longMax += 0.5;
            }

            mcr.center.latitude = (latMax + latMin) / 2.0;
            mcr.center.longitude = (longMax + longMin) / 2.0;
            mcr.span.latitudeDelta = (latMax - latMin);
            mcr.span.longitudeDelta = (longMax - longMin);
        }
        return mcr
    }

}
