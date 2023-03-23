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
//  MFBLocation.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/6/23.
//

import Foundation

@objc public enum FlightState : Int {
    case fsOnGround
    case fsInFlight
    case fsJustLanded
    
    func localizedName() -> String {
        switch (self) {
        case .fsInFlight:
            return String(localized:"In Flight", comment: "Flight status")
        case .fsOnGround, .fsJustLanded:
            return String(localized:"On Ground", comment:"Flight status")
        }
    }
}

@objc public protocol AutoDetectDelegate {
    @objc @discardableResult func takeoffDetected() -> NSString
    @objc @discardableResult func nightTakeoffDetected() -> NSString
    @objc @discardableResult func landingDetected() -> NSString
    @objc @discardableResult func fsLandingDetected(_ : Bool) -> NSString
    @objc func addNightTime(_ : Double)
    @objc func flightCouldBeInProgress() -> Bool
    @objc func newLocation(_ : CLLocation)
}

@objc public class MFBLocation : NSObject, CLLocationManagerDelegate {
    // MARK: Constants

#if DEBUG
    #warning("DEBUG IS ON")
#if targetEnvironment(simulator)
#warning("GPS SIM IS ON!!!")
#else
#warning("Debug, but using HARDWARE GPS")
#endif
#else
#warning("RELEASE BUILD - HARDWARE GPS")
#endif // if debug

    // if debug and on the simulator, use fake GPS when starting engine otherwise, use the real thing.
    @objc public static var USE_FAKE_GPS : Bool {
        get {
#if DEBUG && targetEnvironment(simulator)
            return true
#else
            return false
#endif
        }
    }
    
    // speeds for distinguishing takeoff/landing
    // we want some hysteresis here, so set the take-off speed higher than the landing speed
    private static let TAKEOFF_SPEED_DEFAULT = 55.0
    private static let LANDING_SPEED_DEFAULT = 40.0
    private static let MIN_DISTANCE  = 10
    private static let MIN_SAMPLE_RATE_TAXI = 4.0
    private static let MIN_SAMPLE_RATE_AIRBORNE = 6.0
    
    private static let TAKEOFF_SPEED_MIN   = 20.0
    private static let TAKEOFF_SPEED_MAX   = 100.0
    private static let TAKEOFF_SPEED_SPREAD_BREAK = 50.0
    private static let TAKEOFF_LANDING_SPREAD_LOW  = 10.0
    private static let TAKEOFF_LANDING_SPREAD_HIGH  = 15.0
    private static let FULL_STOP_SPEED = 8.0
    
    // minimum horizontal accuracy for us not to throw things out.
    @objc public static let MIN_ACCURACY  = 50.0
    
    // Number of supposedly valid GPS samples to ignore after a wake-up
    private static let BOGUS_SAMPLE_COUNT = 2
    
    // MARK: public properties
    @objc public var fRecordFlightData = false
    @objc public var fRecordHighRes = UserPreferences.current.recordHighRes
    @objc public var fRecordingIsPaused = false
    @objc public var fSuppressAllRecording = false
    @objc public var cSamplesSinceWaking = 0
    @objc public var delegate : AutoDetectDelegate? = nil
    @objc public var lastSeenLoc : CLLocation? = nil
    @objc public var currentLoc : CLLocation? = nil
    @objc public var rgAllSamples : [String] = []
    @objc public var currentFlightState = FlightState.fsOnGround
    
    
    // MARK: private properties
    private var flightTrackData = ""
    private var locManager : CLLocationManager? = nil
    private var fIsBlessed = false
    private var PreviousLoc : CLLocation? = nil
    private var fPreviousLocWasNight = false
    
    private static var vTakeOff = TAKEOFF_SPEED_DEFAULT
    private static var vLanding = LANDING_SPEED_DEFAULT
    
    // MARK: user defaults keys
    private static let _szKeyPrefFlightTrackData = "keyFlightTrackDataInProgress"
    private static let _szKeyPrefFlightSamples = "keyFlightSamples"
    private static let _szKeyPrefFlightState = "keyCurrentFlightState"
    private static let _szKeyPrefIsRecording = "keyPrefIsRecording"
    
    
    // MARK: Object Lifecycle
    @objc override public init() {
        super.init()
        MFBLocation.refreshTakeoffSpeed()
    }
    
    @objc(initWithGPS:) public convenience init(withGPS fBlessed : Bool) {
        self.init()
        if fBlessed {
            fIsBlessed = true
            setUpLocManager()
            restoreState()
        }
    }
    
    // MARK: StateManagement
    @objc public func saveState() {
        let def = UserDefaults.standard
        
        def.set(currentFlightState.rawValue, forKey: MFBLocation._szKeyPrefFlightState)
        def.set(fRecordFlightData, forKey: MFBLocation._szKeyPrefIsRecording)
        def.set(flightTrackData, forKey: MFBLocation._szKeyPrefFlightTrackData)
        def.set(rgAllSamples, forKey: MFBLocation._szKeyPrefFlightSamples)
    }
    
    @objc public static func refreshTakeoffSpeed() {
        // Initialize takeoff/landing speed
        vTakeOff = Double(UserPreferences.current.TakeoffSpeed)
        if (vTakeOff < TAKEOFF_SPEED_MIN || vTakeOff > TAKEOFF_SPEED_MAX) {
            vTakeOff = TAKEOFF_SPEED_DEFAULT
        }
        vLanding = (vTakeOff >= TAKEOFF_SPEED_SPREAD_BREAK) ? vTakeOff - TAKEOFF_LANDING_SPREAD_HIGH : vTakeOff - TAKEOFF_LANDING_SPREAD_LOW
    }
    
    @objc public func restoreState() {
        let defs = UserDefaults.standard
        
        currentFlightState = FlightState(rawValue: defs.integer(forKey: MFBLocation._szKeyPrefFlightState))!
        fRecordFlightData = defs.bool(forKey: MFBLocation._szKeyPrefIsRecording)
        
        flightTrackData = defs.string(forKey: MFBLocation._szKeyPrefFlightTrackData) ?? ""
        
        rgAllSamples = (defs.object(forKey: MFBLocation._szKeyPrefFlightTrackData) as? [String]) ?? []
        
        fRecordHighRes = UserPreferences.current.recordHighRes
        MFBLocation.refreshTakeoffSpeed()
    }
    
    // MARK: night flight options
    var NightFlightSunsetOffset : Int {
        get {
            switch (UserPreferences.current.nightFlightPref) {
            case .civilTwilight, .sunset, .invalidLast:
                return 0
            case .sunsetPlus15:
                return 15
            case .sunsetPlus30:
                return 30
            case .sunsetPlus60:
                return 60
            }
        }
    }
    
    func IsNightForFlight(_ sst : SunriseSunset?) -> Bool {
        // short circuit daytime
        if (sst == nil || !sst!.isNight) {
            return false
        }
        
        switch (UserPreferences.current.nightFlightPref) {
        case .civilTwilight:
            return sst!.isCivilNight
        case .sunset:
            return true    // we already verified that isNight is true above.
        case .sunsetPlus15, .sunsetPlus30, .sunsetPlus60:
            return sst!.isWithinNightOffset
        case .invalidLast:
            return false
        }
    }
    
    // MARK: CLLocation management
    func setUpLocManager(_ startUpdating : Bool = true) {
        if locManager == nil {
            NSLog("SetUpLocManager")
            
            let lm = CLLocationManager()
            if lm.authorizationStatus == .notDetermined {
                lm.requestAlwaysAuthorization()
            }
            
            lm.delegate = self
            lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            lm.distanceFilter = kCLDistanceFilterNone
            lm.pausesLocationUpdatesAutomatically = false
            lm.activityType = .airborne
            lm.allowsBackgroundLocationUpdates = true
            locManager = lm
        }
        
        if (startUpdating) {
            locManager!.startUpdatingLocation()
        }
        locManager!.allowsBackgroundLocationUpdates = true
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if (manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted) {
            locManager = nil
            return
        }
        
        locManager = locManager ?? manager  // just in case it's nil, use this one.
        
        locManager!.startUpdatingLocation()
        locManager!.allowsBackgroundLocationUpdates = true
    }
    
    @objc public var isLocationServicesEnabled : Bool {
        get {
            locManager = locManager ?? CLLocationManager() // ensure it's not nil
            return locManager!.authorizationStatus == .authorizedAlways || locManager!.authorizationStatus == .authorizedWhenInUse
        }
    }
    /*
     // Is this function ever called?  Commenting out in case not
     public static var isSignificantChangeMonitoringEnables : Bool {
     return CLLocationManager.significantLocationChangeMonitoringAvailable()
     }
     */
    
    func recordLocation(_ loc : CLLocation, withEvent szEvent : String) {
        let s = loc.speed * MFBConstants.MPS_TO_KNOTS
        if (fRecordFlightData && !fRecordingIsPaused && !fSuppressAllRecording) {
            // write a header row if none present
            if (flightTrackData.isEmpty) {
                flightTrackData.append("LAT,LON,PALT,SPEED,HERROR,DATE,TZOFFSET,COMMENT\r\n")
            }
            
            let df = Date.getYYYYMMDDFormatter()
            let locNeutral = Locale(identifier: "en_US_POSIX")
            
            let szRow = String(format: "%.8F,%.8F,%d,%.1F,%.1F,%@,%d,%@\r\n",
                               locale: locNeutral,
                               loc.coordinate.latitude,
                               loc.coordinate.longitude,
                               Int(loc.altitude * MFBConstants.METERS_TO_FEET),
                               s,
                               loc.horizontalAccuracy,
                               df.string(from: loc.timestamp),
                               -df.timeZone.secondsFromGMT() / 60,
                               szEvent)
            flightTrackData.append(szRow)
        }
    }
    
    @objc public func startRecordingFlightData() {
        if (UserPreferences.current.recordTelemetry) {
            fRecordFlightData = true
        }
    }
    
    @objc public func stopRecordingFlightData() {
        NSLog("stopRecordingFlightData \r\n")
        fRecordFlightData = false
    }
    
    // Call to cause a state transition.  Don't call multiple times in a row!!
    func setFlightState(_ fs :FlightState, atNight fIsNightForLandings : Bool, withNotes szNotes : inout String) -> FlightState {
        if fs == currentFlightState {
            return fs
        }
        
        switch (fs) {
        case .fsInFlight:
            NSLog("setFlightState: Takeoff detected!")
            currentFlightState = .fsInFlight
            if (delegate != nil) {
                if delegate!.flightCouldBeInProgress() {
                    szNotes.append(" \(delegate!.takeoffDetected())")
                    if (fIsNightForLandings) {
                        szNotes.append(" \(delegate!.nightTakeoffDetected())")
                    }
                }
            }
        case .fsJustLanded:
            if (currentFlightState == .fsInFlight) { // can only come into this state from in-flight.
                currentFlightState = .fsJustLanded
                NSLog("setFlightState: Landing detected!")
                if (delegate?.flightCouldBeInProgress() ?? false) {
                    szNotes.append(" \(delegate!.landingDetected())")
                }
            }
        case .fsOnGround:
            if (currentFlightState == .fsJustLanded) {   // can only come into this state from just landed
                NSLog("setFlightState: Full-stop landing!")
                currentFlightState = .fsOnGround
                if (delegate?.flightCouldBeInProgress() ?? false) {
                    szNotes.append(" \(delegate!.fsLandingDetected(fIsNightForLandings))")
                }
            }
            break
        }
        return fs
    }
    
    func newLocation(_ newLocation : CLLocation) {
        let s = newLocation.speed * MFBConstants.MPS_TO_KNOTS
        let acc = newLocation.horizontalAccuracy
        var szEvent = ""
        let fValidSpeed = (s >= 0)
        var fValidQuality = (acc > 0 && acc < MFBLocation.MIN_ACCURACY)
        var fValidTime = true  // see if enough time has elapsed to record this.
        var dt = TimeInterval(0)
        cSamplesSinceWaking += 1
        let fEnoughSamples = cSamplesSinceWaking >= MFBLocation.BOGUS_SAMPLE_COUNT
        var fForceRecord = false // true to record even a sample that we would otherwise discard.

        lastSeenLoc = newLocation // keep this, even if it's noisy (still useful for nearby airports)
        if (currentLoc != nil) {
            // get the time interval since the last location
            dt = newLocation.timestamp.timeIntervalSince(currentLoc!.timestamp)
            let dtLimit = TimeInterval((currentFlightState == .fsInFlight) ? MFBLocation.MIN_SAMPLE_RATE_AIRBORNE : MFBLocation.MIN_SAMPLE_RATE_TAXI)
            fValidTime = (dt > dtLimit)
        }
        else {
            currentLoc = newLocation // Initialize with current position if this is our first.
        }
        
        // Sometimes we get bogus speed even with a high reported accuracy this results in bogus landings.
        // We will reset the samplessincewaking if this happens, to let the GPS catch up.
        // There are two conditions where this is a concern:
        // a) If we are in the FLYING state and we get a 0 speed.
        // b) If we are in the FLYING state and we get a speed under the landing speed, we will do a quick acceleration test.
        //    If we are below the landing speed and the acceleration would imply more than 2G's.
        //    1G = 9.8m/s2 (meter per second squared)
        let sLanding = Double(MFBLocation.vLanding)
        
        var fs = currentFlightState
        if (fs == .fsInFlight && s < sLanding && dt > 0 && fEnoughSamples && (s == 0 || abs((newLocation.speed - (currentLoc?.speed ?? 0.0)) / dt) > 2.0 * 9.8)) {
            if (s == 0) {
                szEvent.append("Speed of 0.0kts is suspect - discarding ")
            }
            else {
                szEvent.append(String(format: "Acceleration of %0.3f seems suspect ", fabs((newLocation.speed - (currentLoc?.speed ?? 0.0)) / dt)))
            }
            fValidQuality = false
        }
        
        let fValidSample = fValidSpeed && fValidQuality && fEnoughSamples
        
        if (fValidSample) {
            let sst = SunriseSunset(dt: newLocation.timestamp, latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude, nightOffset: NightFlightSunsetOffset)
            let fAutodetect = UserPreferences.current.autodetectTakeoffs
            
            let fIsNightForFlight = IsNightForFlight(sst)
            let fIsNightForLandings = (UserPreferences.current.nightLandingPref == .night) ? fIsNightForFlight : sst.isFAANight
            
            if (PreviousLoc != nil && fPreviousLocWasNight && fIsNightForFlight && fAutodetect) {
                let t = newLocation.timestamp.timeIntervalSince(PreviousLoc!.timestamp) / 3600.0    // time is in seconds, convert it to hours
                if (t < 0.5 && (delegate?.flightCouldBeInProgress() ?? false)) {   // limit of half an hour between samples for night time
                    delegate?.addNightTime(t)
                }
            }
                        
            fPreviousLocWasNight = fIsNightForFlight
            PreviousLoc = lastSeenLoc
            
            // Autodetection of takeoff/landing
            if (fAutodetect) {
                switch (fs) {
                case .fsInFlight: // In flight - look for a drop below landing speed for a landing
                    if (s < sLanding) {
                        szEvent.append(String(localized: "Landing", comment: "In flight telemetry, this is shown next to a landing event"))
                        fs = setFlightState(.fsJustLanded, atNight: fIsNightForLandings, withNotes: &szEvent)
                        fForceRecord = true  // enable recording of this event in telemetry
                    }
                case .fsJustLanded, .fsOnGround: // on the ground (touch & go or full stop) - look for a take-off
                    if s > MFBLocation.TakeOffSpeed {
                        szEvent.append(String(localized: "Takeoff", comment: "In flight telemetry, this is shown to indicate a takeoff event"))
                        startRecordingFlightData()
                        fs = setFlightState(.fsInFlight, atNight: fIsNightForLandings, withNotes: &szEvent)
                        fForceRecord = true  // enable recording of this event in telemetry
                    }
                }
                
                // see if we've had a full-stop landing
                if (fs == .fsJustLanded && s < MFBLocation.FULL_STOP_SPEED) {
                    szEvent.append(String(format: String(localized: "Full-stop %@landing", comment: "If a full-stop landing is detected, this is written into the comments for flight telemetry.  the %@ is replaced either with nothing or with 'night' to indicate a night landing"),
                                          fIsNightForLandings ? String(localized: "night ", comment: "Night as an adjective - i.e., a night landing") : ""))
                    fs = setFlightState(.fsOnGround, atNight: fIsNightForLandings, withNotes: &szEvent)
                    fForceRecord = true  // enable recording of this event in telemetry
                }
            }
        }
        
        let fRecordable = !fSuppressAllRecording && (delegate?.flightCouldBeInProgress() ?? false) && fRecordFlightData
        
        // record this if appropriate - we do the valid time check here to avoid too tightly clustered
        // samples, but any event (landing/takeoff) will set it to be true.
        if ((fRecordHighRes && fValidSpeed) || (fRecordable && (fForceRecord || (fValidTime && fValidSample)))) {
            recordLocation(newLocation, withEvent: szEvent)
        }
        
        if (fRecordable) {
            rgAllSamples.append(String(format: "%.8F\t%.8F\t%.1F\t%.2F\t%F",
                                       newLocation.coordinate.latitude,
                                       newLocation.coordinate.longitude,
                                       newLocation.altitude,
                                       newLocation.speed,
                                       newLocation.timestamp.timeIntervalSince1970))
        }
        
        if fForceRecord {
            saveState()
        }
        
        // update to the new location if it was a good sample and valid time
        if (fValidTime && fValidSample) {
            currentLoc = newLocation
        }
        
        // pass on the update event to any location delegate, regardless of quality
        delegate?.newLocation(newLocation)
        
        // TODO: We should call watch data directly rather than going through the app delegate
        // Update watch data
        if let sw = MFBAppDelegate.threadSafeAppDelegate.watchData {
            sw.latDisplay = lastSeenLoc?.coordinate.latitude.asLatString() ?? ""
            sw.lonDisplay = lastSeenLoc?.coordinate.longitude.asLonString() ?? ""
            sw.flightstatus = currentFlightState.localizedName()
            sw.speedDisplay = UserPreferences.current.speedUnits.formatSpeedMpS((lastSeenLoc?.speed ?? 0))
            sw.altDisplay = UserPreferences.current.altitudeUnits.formatMetersAlt(lastSeenLoc?.altitude ?? 0)
            MFBAppDelegate.threadSafeAppDelegate.updateWatchContext()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
#if DEBUG
            if self.fIsBlessed {
                NSLog("Received REAL location %8f, %8f", loc.coordinate.latitude, loc.coordinate.longitude)
            }
#endif
            self.newLocation(loc)
        }
    }
    
    // MARK: Location Information
    @objc public static var TakeOffSpeed : Double {
        get {
            return vTakeOff
        }
    }
    
    @objc public static var LandingSpeed : Double {
        get {
            return vLanding
        }
    }
    
    // MARK: FlightData
    @objc public func resetFlightData() {
        flightTrackData = ""
        rgAllSamples = []
        currentFlightState = .fsOnGround
        saveState()
    }
    
    @objc public func flightDataAsString() -> String {
        return "\(flightTrackData)" // return a new string.
    }
    
    // MARK: GPX
    @objc public func gpxFilePath() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .full
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = formatter.string(from: Date())
        
        let fileName = String(format: "log_%@.gpx", dateString)
        return NSTemporaryDirectory().appending(fileName)
    }
    
    @objc public func gpxData() -> String {
        var arCoords : [CLLocation] = []
        
        // gpx > trk > trkseg > trkpt
        for szCoord in rgAllSamples {
            let rgCoords = szCoord.components(separatedBy: "\t")
            if (rgCoords.count == 5) {
                let lat = Double(rgCoords[0])!
                let lon = Double(rgCoords[1])!
                let alt = Double(rgCoords[2])!
                let speed = Double(rgCoords[3])!
                let dt = Date(timeIntervalSince1970: Double(rgCoords[4])!)
                
                let cl = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                    altitude: alt, horizontalAccuracy: 0, verticalAccuracy: 0,
                                    course: 0, courseAccuracy: 0,
                                    speed: speed, speedAccuracy: 0, timestamp: dt)
                arCoords.append(cl)
            }
        }
        return GPXTelemetry.serializeFromPath(arCoords)
    }
    
    @objc public func writeToFile(_ szData : String) -> String? {
        let filePath = gpxFilePath()
        // write gpx to file
        do {
            try szData.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
        catch {
            return nil
        }
        
        return filePath
    }
    
    // MARK: Display
    @objc public static func altitudeDisplay(_ loc : CLLocation) -> String {
        return UserPreferences.current.altitudeUnits.formatMetersAlt(loc.altitude)
    }

    @objc public static func speedDisplay(_ s : CLLocationSpeed) -> String {
        return UserPreferences.current.speedUnits.formatSpeedMpS(s)
    }

    @objc public static func latitudeDisplay(_ lat : Double) -> String {
        // TODO: switch to using asLatString (swift)
        return lat.asLatString()
    }
    
    @objc public static func flightStateDisplay(_ fs : FlightState) -> String {
        // TODO: switch to calling localizedName directly.
        return fs.localizedName()
    }

    @objc public static func longitudeDisplay(_ lon : Double) -> String {
        // TODO: switch to using asLonString (swift)
        return lon.asLonString()
    }
    
    // MARK: Start/Stop
    @objc public func stopUpdatingLocation() {
        locManager?.stopUpdatingLocation()
        locManager?.allowsBackgroundLocationUpdates = false
    }
    
    @objc public func startUpdatingLocation() {
        locManager?.startUpdatingLocation()
        locManager?.allowsBackgroundLocationUpdates = true
    }
    
    @objc public func feedEvent(_ loc : CLLocation) {
        if (locManager == nil) {
            setUpLocManager(false)
        }
        locationManager(locManager!, didUpdateLocations: [loc])
    }

}
