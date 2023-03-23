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
//  MFBConstants.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/8/23.
//

import Foundation

// Cached credentials, aircraft durations
@objc public enum CacheStatus : Int {
    case invalid
    case valid
    case validButRefresh
}

@objc public class MFBConstants : NSObject {
    
    @objc public static var CACHE_LIFETIME : Int {
        get {
            #if DEBUG
            return 60 * 2   // 2 minute cache lifetime in debug
            #else
            return 3600 * 24 * 14       // 14 day lifetime in retail
            #endif
        }
    }
    
    @objc public static var CACHE_REFRESH : Int {
        get {
            #if DEBUG
            return 30   // after 30 seconds, attempt a refresh
            #else
            return 3600 * 24 * 14 // // Cache is valid for 2 weeks, but we will attempt refreshes after 3 days
            #endif
        }
    }
    
    @objc public static let MFBFLIGHTIMAGEUPLOADPAGE = "/logbook/public/uploadpicture.aspx"
    @objc public static let MFBAIRCRAFTIMAGEUPLOADPAGE = "/logbook/public/uploadairplanepicture.aspx?id=1"
    @objc public static let MFBAIRCRAFTIMAGEUPLOADPAGENEW = "/logbook/public/uploadairplanepicture.aspx"
    @objc public static let MFB_KEYFLIGHTIMAGE = "idFlight"
    @objc public static let MFB_KEYAIRCRAFTIMAGE = "txtAircraft"

    @objc public static let MPS_TO_KNOTS = 1.94384449
    @objc public static let KTS_TO_KPH = 1.852
    @objc public static let KTS_TO_MPH = 1.15078
    @objc public static let METERS_TO_FEET = 3.2808399
    @objc public static let METERS_IN_A_NM = 1852.0
    @objc public static let NM_IN_A_METER = 0.000539956803
    
    // Minimum threshold distance for Cross-country Flight (in NM)
    @objc public static let CROSS_COUNTRY_THRESHOLD = 50.0
    
    // IRATE initializers
#if DEBUG
    @objc public static let MIN_IRATE_EVENTS = 2
    @objc public static let MIN_IRATE_DAYS = 0.01
    @objc public static let MIN_IRATE_USES = 4
#else
    @objc public static let MIN_IRATE_EVENTS = 5
    @objc public static let MIN_IRATE_DAYS = 10.0
    @objc public static let MIN_IRATE_USES = 10
#endif
    
    @objc public static let IRATE_URL = URL(string: String(format: "https://itunes.apple.com/us/app/myflightbook/id%d?mt=8&action=write-review",
                                                           _appStoreID))
}
