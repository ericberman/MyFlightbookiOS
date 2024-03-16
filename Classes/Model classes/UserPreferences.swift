/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023-2024 MyFlightbook, LLC
 
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
//  UserPreferences.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/23/23.
//

import Foundation
import MapKit

@objc public enum autoHobbs:Int, CaseIterable {
    case none = 0
    case flight
    case engine
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .none:
            return String(localized:"Off", comment:"No auto-fill")
        case .flight:
            return String(localized:"Flight Time", comment:"Auto-fill based on time in the air")
        case .engine:
            return String(localized:"Engine Time", comment:"Auto-fill based on engine time")
        default:
            return ""
        }
    }
}

@objc public enum autoTotal:Int, CaseIterable {
    case none = 0
    case flight
    case engine
    case hobbs
    case block
    case flightStartToEngineEnd
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .none:
            return String(localized:"Off", comment:"No auto-fill")
        case .flight:
            return String(localized:"Flight Time", comment:"Auto-fill based on time in the air")
        case .engine:
            return String(localized:"Engine Time", comment:"Auto-fill based on engine time")
        case .hobbs:
            return String(localized:"Hobbs Time", comment:"Auto-fill total based on hobbs time")
        case .block:
            return String(localized:"Block Time", comment:"Auto-fill total based on block time")
        case .flightStartToEngineEnd:
            return String(localized:"FlightEngine Time", comment:"Auto-fill total based on flight start to engine shutdown")
        default:
            return ""
        }
    }
}

@objc public enum unitsSpeed:Int, CaseIterable {
    case kts = 0
    case mph
    case kph
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .kts:
            return String(localized:"UnitsKnots", comment:"Units - Knots")
        case .kph:
            return String(localized:"UnitsKph", comment:"Units - KPH")
        case .mph:
            return String(localized:"UnitsMph", comment:"Units - MPH")
        default:
            return ""
        }
    }
    
    func formatSpeedMpS(_ sIn : Double) -> String {
        // Negative speeds are stupid.
        let s = sIn < 0 ? 0 : sIn

        switch (UserPreferences.current.speedUnits) {
        case .kts:
            return String.localizedStringWithFormat(String(localized: "%.1fkts", comment: "Speed in knots.  '%.1f' is replaced by the actual speed; leave it there."), s)
        case .kph:
            return String.localizedStringWithFormat(String(localized: "%.1fkm/h", comment: "Speed in kph"), s * MFBConstants.KTS_TO_KPH)
        case .mph:
            return String.localizedStringWithFormat(String(localized: "%.1fmph", comment: "Speed in mph"), s * MFBConstants.KTS_TO_MPH)
        default:
            return ""
        }
    }
}

@objc public enum unitsAlt:Int, CaseIterable {
    case feet = 0
    case meters
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .meters:
            return String(localized:"UnitsMeters", comment:"Units - Meters")
        case .feet:
            return String(localized:"UnitsFeet", comment:"Units - Feet")
        default:
            return ""
        }
    }
    
    func formatMetersAlt(_ alt : Double ) -> String {
        switch (self) {
        case .feet:
            return String.localizedStringWithFormat("%.1f%@",  round(alt * MFBConstants.METERS_TO_FEET), String(localized: "ft", comment: "Feet"))
        case .meters:
            return String.localizedStringWithFormat("%.1f%@",  round(alt), String(localized: "meters", comment: "meters"))
        default:
            return ""
        }
    }
}

@objc public enum flightTimeDetail:Int, CaseIterable {
    case none
    case short
    case detailed
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
            
        default:
            return ""
        }
    }
}

@objc public enum nightFlightOptions : Int, CaseIterable {
    case civilTwilight
    case sunset
    case sunsetPlus15
    case sunsetPlus30
    case sunsetPlus60
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .sunset:
            return String(localized: "NFSunset", comment: "Night flight starts sunset")
        case .civilTwilight:
            return String(localized: "NFCivilTwighlight", comment: "Night flight starts End of civil twilight")
        case .sunsetPlus15:
            return String(localized: "NFSunsetPlus15", comment: "Night flight starts Sunset + 15 minutes")
        case .sunsetPlus30:
            return String(localized: "NFSunsetPlus30", comment: "Night flight starts Sunset + 30 minutes")
        case .sunsetPlus60:
            return String(localized: "NFSunsetPlus60", comment: "Night flight starts Sunset + 60 minutes")
        default:
            return ""
        }
    }
}

@objc public enum nightLandingOptions : Int, CaseIterable {
    case sunsetPlus60
    case night
    case invalidLast
    
    func localizedName() -> String {
        switch (self) {
        case .night:
            return String(localized: "NFLNight", comment: "Night Landings: Night")
        case .sunsetPlus60:
            return String(localized: "NFLSunsetPlus1Hour", comment: "Night Landings: 60 minutes after sunset")
        default:
            return ""
        }
    }
}

// Object to set/store user preferences
@objc public class UserPreferences : NSObject {
    @objc public let szPrefAutoHobbs = "prefKeyAutoHobbs"
    @objc public let szPrefAutoTotal = "prefKeyAutoTotal"
    @objc public let szPrefKeyHHMM = "keyUseHHMM"
    @objc public let szPrefKeyRoundNearestTenth  = "keyRoundNearestTenth"
    @objc public let keyPrefSuppressUTC = "keySuppressUTC"
    @objc public let _szKeyPrefTakeOffSpeed = "keyPrefTakeOffSpeed"
    @objc public let keyIncludeHeliports = "keyIncludeHeliports"
    @objc public let keyMapMode = "keyMappingMode"
    @objc public let keyShowImages = "keyShowImages"
    @objc public let keyShowFlightTimes = "keyShowFlightTimes2"
    @objc public let keyNightFlightPref = "keyNightFlightPref"
    @objc public let keyNightLandingPref = "keyNightLandingPref"
    @objc public let keySpeedUnitPref = "keySpeedUnitPref"
    @objc public let keyAltUnitPref = "keyAltUnitPref"
    @objc public let keyShowTach = "keyShowTach"
    @objc public let keyShowHobbs = "keyShowHobbs"
    @objc public let keyShowBlock = "keyShowBlock"
    @objc public let keyShowEngine = "keyShowEngine"
    @objc public let keyShowFlight = "keyShowFlight"
    @objc public let keyRouteColor = "keyRouteColor"
    @objc public let keyPathColor = "keyPathColor"
    
    @objc public let keyPrefRecordFlightData = "keyAutoDetectRoute"
    @objc public let keyPrefRecordHighRes = "keyRecordHighRes"
    @objc public let keyPrefAutoDetect = "keyAutoDetectTakeOffAndLanding"
    @objc public let keyPrefIsRecording = "keyPrefIsRecording"
    
    @objc public static let toSpeeds = [20, 40, 55, 70, 85, 100]
    
    // backing variable for a single shared instance - lazy initialized
    private static var _currentPrefs : UserPreferences?
    
    @objc public static var current : UserPreferences {
        get {
            if (_currentPrefs == nil) {
                _currentPrefs = UserPreferences()
            }
            return _currentPrefs!
        }
    }
    
    @objc public static func invalidate() -> Void {
        _currentPrefs = nil;
    }
    
    // ALWAYS use current, don't create your own.
    private override init() {
        // set the default in-the-cockpit values.
        UserDefaults.standard.register(defaults: [keyShowHobbs : true,
                                                  keyShowEngine : true,
                                                  keyShowFlight : true,
                                                  keyShowImages : false])  // images are really a "hide images" flag for backwards compatibility.

        let ud = UserDefaults.standard
        autoTotalMode = autoTotal(rawValue: ud.integer(forKey: szPrefAutoTotal)) ?? .none
        autoHobbsMode = autoHobbs(rawValue: ud.integer(forKey: szPrefAutoHobbs)) ?? .none
        let speed = ud.integer(forKey: _szKeyPrefTakeOffSpeed)
        TakeoffSpeed = speed == 0 ? UserPreferences.toSpeeds[2] : speed
        roundTotalToNearestTenth = ud.bool(forKey: szPrefKeyRoundNearestTenth)
        HHMMPref = ud.bool(forKey: szPrefKeyHHMM)
        UseLocalTime = ud.bool(forKey: keyPrefSuppressUTC)
        autodetectTakeoffs = ud.bool(forKey: keyPrefAutoDetect)
        recordTelemetry = ud.bool(forKey: keyPrefRecordFlightData)
        recordHighRes = ud.bool(forKey: keyPrefRecordHighRes)
        includeHeliports = ud.bool(forKey: keyIncludeHeliports)
        showFlightImages = !ud.bool(forKey: keyShowImages)  // true by default
        showTach = ud.integer(forKey: keyShowTach) != 0
        showHobbs = ud.integer(forKey: keyShowHobbs) != 0
        showBlock = ud.integer(forKey: keyShowBlock) != 0
        showEngine = ud.integer(forKey: keyShowEngine) != 0
        showFlight = ud.integer(forKey: keyShowFlight) != 0
        showFlightTimes = flightTimeDetail(rawValue: ud.integer(forKey: keyShowFlightTimes)) ?? .short
        // We used to store maptype offset by 1 so that "0" could mean "Default" (= hybrid)
        // so for backwards compatibility, subtract one from what we find - if result is negative, go hybrid
        let iMapType = ud.integer(forKey: keyMapMode) - 1
        mapType = iMapType < 0 ? .hybrid : MKMapType(rawValue: UInt(iMapType)) ?? .hybrid
        nightFlightPref = nightFlightOptions(rawValue: ud.integer(forKey: keyNightFlightPref)) ?? .civilTwilight
        nightLandingPref = nightLandingOptions(rawValue: ud.integer(forKey: keyNightLandingPref)) ?? .sunsetPlus60
        speedUnits = unitsSpeed(rawValue: UserDefaults.standard.integer(forKey: keySpeedUnitPref)) ?? .kts
        altitudeUnits = unitsAlt(rawValue: UserDefaults.standard.integer(forKey: keyAltUnitPref)) ?? .feet

        let dRouteColor = UserDefaults.standard.object(forKey: keyRouteColor) as? Data
        routeColor = dRouteColor == nil ? UIColor.blue : try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: dRouteColor!) ?? UIColor.blue
        let dPathColor = UserDefaults.standard.object(forKey: keyPathColor) as? Data
        pathColor = dPathColor == nil ? UIColor.red : try! NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: dPathColor!) ?? UIColor.red
        super.init()
    }
    
    @objc public func commit() -> Void {
        let ud = UserDefaults.standard
        ud.set(autoTotalMode.rawValue, forKey: szPrefAutoTotal)
        ud.set(autoHobbsMode.rawValue, forKey: szPrefAutoHobbs)
        ud.set(TakeoffSpeed, forKey: _szKeyPrefTakeOffSpeed)
        ud.set(roundTotalToNearestTenth, forKey: szPrefKeyRoundNearestTenth)
        ud.set(HHMMPref, forKey: szPrefKeyHHMM)
        ud.set(UseLocalTime, forKey: keyPrefSuppressUTC)
        ud.set(autodetectTakeoffs, forKey: keyPrefAutoDetect)
        ud.set(recordTelemetry, forKey: keyPrefRecordFlightData)
        ud.set(recordHighRes, forKey: keyPrefRecordHighRes)
        ud.set(includeHeliports, forKey: keyIncludeHeliports)
        ud.set(!showFlightImages, forKey: keyShowImages)
        ud.set(showTach ? 1 : 0, forKey: keyShowTach)
        ud.set(showHobbs ? 1 : 0, forKey: keyShowHobbs)
        ud.set(showBlock ? 1 : 0, forKey: keyShowBlock)
        ud.set(showEngine ? 1 : 0, forKey: keyShowEngine)
        ud.set(showFlight ? 1 : 0, forKey: keyShowFlight)
        ud.set(showFlightTimes.rawValue, forKey: keyShowFlightTimes)
        // For backwards compatibility, offset the maptype up by 1 so that 0 can be reserved for "default".
        ud.set(mapType.rawValue + 1, forKey: keyMapMode)
        ud.set(nightFlightPref.rawValue, forKey:  keyNightFlightPref)
        ud.set(nightLandingPref.rawValue, forKey: keyNightLandingPref)
        ud.set(speedUnits.rawValue, forKey: keySpeedUnitPref)
        ud.set(altitudeUnits.rawValue, forKey: keyAltUnitPref)

        try! ud.set(NSKeyedArchiver.archivedData(withRootObject: routeColor, requiringSecureCoding: true), forKey: keyRouteColor)
        try! ud.set(NSKeyedArchiver.archivedData(withRootObject: pathColor, requiringSecureCoding: true), forKey: keyPathColor)
        ud.synchronize()
    }
    
    @objc public var autoTotalMode : autoTotal
    @objc public var autoHobbsMode : autoHobbs
    @objc public var TakeoffSpeed : Int
    @objc public var roundTotalToNearestTenth : Bool
    @objc public var HHMMPref : Bool
    @objc public var UseLocalTime : Bool
    @objc public var autodetectTakeoffs : Bool
    @objc public var recordTelemetry : Bool
    @objc public var recordHighRes : Bool
    @objc public var includeHeliports : Bool
    @objc public var showFlightImages : Bool
    @objc public var showTach : Bool
    @objc public var showHobbs : Bool
    @objc public var showBlock : Bool
    @objc public var showEngine : Bool
    @objc public var showFlight : Bool
    @objc public var routeColor : UIColor
    @objc public var pathColor : UIColor
    @objc public var showFlightTimes : flightTimeDetail
    @objc public var mapType : MKMapType 
    @objc public var nightFlightPref : nightFlightOptions
    @objc public var nightLandingPref : nightLandingOptions
    @objc public var speedUnits : unitsSpeed
    @objc public var altitudeUnits : unitsAlt
}
