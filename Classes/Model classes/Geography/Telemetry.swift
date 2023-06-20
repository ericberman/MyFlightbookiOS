/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2014-2023 MyFlightbook, LLC
 
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
//  Telemetry.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/5/23.
//

import Foundation

@objc public enum ImportedFileType : Int {
    case GPX
    case KML
    case CSV
    case NMEA
    case Unknown
}

@objc public class CLMutableLocation : NSObject {
    static let INFERRED_HERROR = 5

    @objc public var latitude = 0.0
    @objc public var longitude = 0.0
    @objc public var altitude = 0.0
    @objc public var speed = 0.0
    @objc public var horizontalAccuracy = INFERRED_HERROR
    @objc public var timeStamp : Date? = nil
    @objc public var hasSpeed = false
    @objc public var hasAlt = false
    @objc public var hasTime = false
    
    public convenience init(_ lat: Double, _ lon: Double) {
        self.init()
        latitude = lat
        longitude = lon
    }

    @objc public func addSpeed(_ s: Double) {
        speed = s
        hasSpeed = true
    }
    
    @objc public func addAlt(_ a: Double) {
        altitude = a
        hasAlt = true
    }
    
    @objc public func addTime(_ dt : Date) {
        timeStamp = dt
        hasTime = true
    }
    
    @objc public var location : CLLocation {
        get {
            return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                              altitude: hasAlt ? altitude : 0,
                              horizontalAccuracy: CLLocationAccuracy(horizontalAccuracy),
                              verticalAccuracy: 0, course: 0, courseAccuracy: 0,
                              speed: hasSpeed ? speed : 0,
                              speedAccuracy: 0,
                              timestamp: timeStamp ?? Date())
        }
    }
    
    @objc public func setInvalidLocation() {
        latitude = -200
        longitude = -200
    }
    
    @objc public var isValidLocation : Bool {
        get {
            return abs(latitude) <= 90 && abs(longitude) <= 180
        }
    }
    
    @objc public override var description: String {
        get {
            return String(format: "%.6f, %.6f, %@, %@, %@",
                          latitude,
                          longitude,
                          hasAlt ? String(format: "%.2fm", altitude) : "No altitude",
                          hasSpeed ? String(format: "%.2fkts", speed) : "No Speed",
                          (timeStamp as? NSDate)?.iso8601DateString() ?? "")
        }
    }
}

@objc public class Telemetry : NSObject, XMLParserDelegate {
    @objc public static let TELEMETRY_META_AIRCRAFT_TAIL = "aircraft"
    static let MIN_TIME_FOR_SPEED = 4
    
    @objc public var szRawData = ""
    @objc public var lastError = ""
    @objc public var metaData : [String : Any] = [:]
    @objc public var hasSpeed = false
    
    internal var samplesToReturn : [CLMutableLocation] = []
    internal var locInProgress : CLMutableLocation? = nil
    internal var elementInProgress = ""
    
    internal let numberFormatter = Telemetry.getPosixNumberFormatter()
    
    @objc public override init() {
        super.init()
    }
    
    private convenience init(url : URL) {
        self.init()
        do {
            szRawData = try String(contentsOf: url)
        }
        catch {
            szRawData = ""
        }
    }
    
    @objc(initWithString:) public convenience init(sz : String) {
        self.init()
        szRawData = sz
    }
    
    // MARK: Abstract methods
    @objc public var samples : [CLLocation] {
        get {
            // TODO: Should throw
            return []
        }
    }
    
    internal class func serializeFromPath(_ arSamples : [CLLocation]) -> String {
        // TODO: should throw
        return ""
    }
    
    // MARK: Class-level functions
    public static func typeFromURL(_ url : URL) -> ImportedFileType {
        var ft : ImportedFileType = .Unknown
        if (url.isFileURL) {
            let ext = (url.absoluteString.uppercased() as NSString).pathExtension
            switch (ext) {
            case "GPX":
                ft = .GPX
            case "KML":
                ft = .KML
            case "CSV":
                ft = .CSV
            case "NMEA":
                ft = .NMEA
            default:
                ft = .Unknown
            }
        }
        return ft
    }
    
    public static func typeFromString(_ szTelemetry : String) -> ImportedFileType {
        if szTelemetry.contains("<gpx") {
            return .GPX
        }
        else if szTelemetry.contains("<kml") {
            return .KML
        }
        else if szTelemetry.contains("$GP") {
            return .NMEA
        } else {
            return .CSV
        }
    }
    
    @objc public static func telemetryWithURL(_ url : URL) -> Telemetry? {
        let ft = typeFromURL(url)
        switch (ft) {
        case .GPX:
            return GPXTelemetry(url: url)
        case .KML:
            return KMLTelemetry(url: url)
        case .CSV:
            return CSVTelemetry(url: url)
        case .NMEA:
            return NMEATelemetry(url: url)
        default:
            return nil
        }
    }
    
    @objc public static func telemetryWithString(_ szTelemetry : String) -> Telemetry? {
        let ft = typeFromString(szTelemetry)
        switch (ft) {
        case .GPX:
            return GPXTelemetry(sz: szTelemetry)
        case .KML:
            return KMLTelemetry(sz: szTelemetry)
        case .CSV:
            return CSVTelemetry(sz: szTelemetry)
        case .NMEA:
            return NMEATelemetry(sz: szTelemetry)
        default:
            return nil
        }
    }
    
    // MARK: Synthetic Path
    public static func locationAt(lat : Double, lon : Double, dt : Date, speed : Double) -> CLLocation {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return CLLocation(coordinate: coord, altitude: 0, horizontalAccuracy: CLLocationAccuracy(CLMutableLocation.INFERRED_HERROR), verticalAccuracy: 0, course:0, speed: speed, timestamp: dt)
    }
    
    /*
     Returns a synthesized path between two points, even spacing, between the two timestamps.
     ///
     /// Can be used to estimate night flight, for example, or draw a great-circle path between two points.
     ///
     /// From http://www.movable-type.co.uk/scripts/latlong.html
     /// Formula:
     ///     a = sin((1−f)⋅δ) / sin δ
     ///     b = sin(f⋅δ) / sin δ
     ///     x = a ⋅ cos φ1 ⋅ cos λ1 + b ⋅ cos φ2 ⋅ cos λ2
     ///     y = a ⋅ cos φ1 ⋅ sin λ1 + b ⋅ cos φ2 ⋅ sin λ2
     ///     z = a ⋅ sin φ1 + b ⋅ sin φ2
     ///     φi = atan2(z, √x² + y²)
     ///     λi = atan2(y, x)
     /// where f is fraction along great circle route (f=0 is point 1, f=1 is point 2), δ is the angular distance d/R between the two points.
     */
    @objc(synthesizePathFrom:to:start:end:) public static func synthesizePathFrom(fromLoc : CLLocationCoordinate2D, toLoc: CLLocationCoordinate2D, dtStart : Date?, dtEnd : Date?) -> Telemetry? {
        if (NSDate.isUnknownDate(dt: dtEnd) || NSDate.isUnknownDate(dt: dtStart) || dtStart!.compare(dtEnd!) != .orderedAscending) {
            return nil
        }
        var lst : [CLLocation] = []
        
        let rlat1 = Double.pi * (fromLoc.latitude / 180.0)
        let rlon1 =  Double.pi * (fromLoc.longitude / 180.0)
        let rlat2 =  Double.pi * (toLoc.latitude / 180.0)
        let rlon2 =  Double.pi * (toLoc.longitude / 180.0)
        
        let dLon = rlon2 - rlon1
        
        let delta = atan2(sin(dLon) * cos(rlat2), cos(rlat1) * sin(rlat2) - sin(rlat1) * cos(rlat2) * cos(dLon))
        let sin_delta = sin(delta)
        
        // Compute path at 1-minute intervals, subtracting off one minute since we'll add a few "full-stop" samples below.
        let ts = dtEnd!.timeIntervalSince(dtStart!)
        let minutes = (ts / 60.0) - 1
        
        if (minutes > 48 * 60 || minutes <= 0) {  // don't do paths more than 48 hours, or negative times.
            return nil
        }
        
        let clFrom = CLLocation(latitude: fromLoc.latitude, longitude: fromLoc.longitude)
        let clTo = CLLocation(latitude: toLoc.latitude, longitude: toLoc.longitude)
        
        // We need to derive an average speed.  But no need to compute - just assume constant speed.  This is in nm
        let distanceM = clFrom.distance(from: clTo)
        let speedMS = distanceM / ts    // distance in meters divided by time in seconds.  We know ts > 0 because of check for date order above
        let distanceNM = MFBConstants.NM_IN_A_METER * distanceM
        
        // low distance (< 1nm) is probably pattern work - just pick a decent speed.  If you actually go somewhere, then derive a speed.
        let speedKts = (distanceNM < 1.0) ? 150 : speedMS * MFBConstants.MPS_TO_KNOTS;
        
        // Add a few stopped fields at the end to make it clear that there's a full-stop.  Separate them by a few seconds each.
        
        let rgPadding = [
            Telemetry.locationAt(lat: toLoc.latitude, lon: toLoc.longitude, dt: dtEnd!.addingTimeInterval(3), speed: 0.1),
            Telemetry.locationAt(lat: toLoc.latitude, lon: toLoc.longitude, dt: dtEnd!.addingTimeInterval(6), speed: 0.1),
            Telemetry.locationAt(lat: toLoc.latitude, lon: toLoc.longitude, dt: dtEnd!.addingTimeInterval(9), speed: 0.1)
        ]
        
        lst.append(Telemetry.locationAt(lat: fromLoc.latitude, lon: fromLoc.longitude, dt: dtStart!, speed: 0))
        
        for minute in 0...Int(minutes) {
            if (distanceNM < 1.0) {
                lst.append(Telemetry.locationAt(lat: fromLoc.latitude, lon: fromLoc.longitude, dt: dtStart!.addingTimeInterval(TimeInterval(60*minute)), speed: speedKts))
            } else {
                let f = Double(minute) / minutes
                let a = sin((1.0 - f) * delta) / sin_delta
                let b = sin(f * delta) / sin_delta
                let x = a * cos(rlat1) * cos(rlon1) + b * cos(rlat2) * cos(rlon2)
                let y = a * cos(rlat1) * sin(rlon1) + b * cos(rlat2) * sin(rlon2)
                let z = a * sin(rlat1) + b * sin(rlat2)
                
                let rlat = atan2(z, sqrt(x * x + y * y))
                let rlon = atan2(y, x)
                
                let dlat = 180 * (rlat / Double.pi)
                let dlon = 180 * (rlon / Double.pi)
                lst.append(Telemetry.locationAt(lat: dlat, lon: dlon, dt: dtStart!.addingTimeInterval(TimeInterval(60 * minute)), speed: speedKts))
            }
        }
        
        lst.append(contentsOf: rgPadding)
        
        return Telemetry.telemetryWithString(CSVTelemetry.serializeFromPath(lst))
    }
    
    // MARK: Conversion
    @objc public func serializeAs(_ ft : ImportedFileType) -> String {
        switch (ft) {
        case .GPX:
            if self is GPXTelemetry {
                return szRawData
            }
            else {
                return GPXTelemetry.serializeFromPath(samples)
            }
        case .KML:
            if self is KMLTelemetry {
                return szRawData
            }
            else {
                return KMLTelemetry.serializeFromPath(samples)
            }
        case .CSV:
            if self is CSVTelemetry {
                return szRawData
            }
            else {
                return CSVTelemetry.serializeFromPath(samples)
            }
        default:
            return ""
        }
    }
    
    internal func parse() -> [CLMutableLocation] {
        samplesToReturn = []
        let xmlp = XMLParser.init(data: szRawData.data(using: .utf8)!)
        xmlp.delegate = self
        
        // Subclass must implement the actual handling.
        return xmlp.parse() ? samplesToReturn : []
    }
    
    internal func initLocationInProgress() {
        elementInProgress = ""
        locInProgress = CLMutableLocation()
    }
    
    // Compute speed in m/s, if needed.
    internal func computeSpeed() {
        if (locInProgress == nil) {
            return
        }
        if (locInProgress!.speed <= 0 && locInProgress!.hasTime && locInProgress!.isValidLocation && samplesToReturn.count > 0) {
            var cl : CLLocation? = nil
            var t = 0.0
            // Find the reference sample to use - since timestamps in GPX/KML have only whole-second resolution, go back at least MIN_TIME_FOR_SPEED to find a sample to use.
            var i = samplesToReturn.count - 1
            while (i >= 0) {
                cl = samplesToReturn[i].location
                if let t2 = locInProgress?.timeStamp?.timeIntervalSince(cl!.timestamp) {
                    if (t2 >= TimeInterval(Telemetry.MIN_TIME_FOR_SPEED)) {
                        t = t2
                        break;
                    }
                }
                i -= 1
            }
            
            if (t > 0) {
                let dist = cl?.distance(from: CLLocation(latitude: locInProgress!.latitude, longitude: locInProgress!.longitude)) ?? 0.0
                let speed = dist / t
                locInProgress?.addSpeed(speed)
                hasSpeed = true
            }
        }
    }
    
    public static func getPosixNumberFormatter() -> NumberFormatter {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US_POSIX")
        return nf
    }
    
    // MARK: XML Parsing
    public func parserDidStartDocument(_ parser: XMLParser) {
        initLocationInProgress()
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        locInProgress = nil
        elementInProgress = ""
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if elementInProgress.isEmpty {
            elementInProgress = string
        } else {
            elementInProgress.append(string)
        }
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        lastError = parseError.localizedDescription
    }
}
                           
internal enum KMLArrayContext : Int {
    case None
    case Accuracy
    case Speed
}

@objc public class KMLTelemetry : Telemetry {
    private let tupleDelimieters = CharacterSet(charactersIn: " ,")
    private var currentGXValueIndex = 0
    private var fHasTrack = false
    private var currentContext = KMLArrayContext.None
    
    public override init() {
        super.init()
    }
    
    @objc public override var samples: [CLLocation] {
        fHasTrack = false // assume no track, yet.
        // Need to do a speed check
        let rgMutableLocations = parse()
        // self.samplesToReturn now has CLMutableLocations, NOT CLLocations.
        samplesToReturn = []
        let fNeedsSpeed = !hasSpeed  // save this value since computing the 1st speed modifies self.hasSpeed
        for cml in rgMutableLocations {
            if (fNeedsSpeed) {
                locInProgress = cml
                computeSpeed()
            }
            samplesToReturn.append(cml)
        }
        locInProgress = nil
        
        return samplesToReturn.map { $0.location }
    }
    
    private func parseTuple(_ sz : String) -> Bool {
        let rgLine = sz.components(separatedBy: tupleDelimieters)
        if (rgLine.count < 2) {
            return false
        }
        if let l = locInProgress {
            l.longitude = numberFormatter.number(from: rgLine[0])?.doubleValue ?? 0.0
            l.latitude = numberFormatter.number(from: rgLine[1])?.doubleValue ?? 0.0
            if (rgLine.count >= 3) {
                if let alt = numberFormatter.number(from: rgLine[2])?.doubleValue {
                    l.addAlt(alt)
                }
            }
            return true
        }
        return false
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementInProgress = ""
        if (elementName == "gx:SimpleArrayData") {
            currentContext = .None
            currentGXValueIndex = 0
            let szDataType = attributeDict["name"]
            if (szDataType == "speedKts" || szDataType == "speed_kts") {
                currentContext = .Speed
            } else if (szDataType == "acc_horiz") {
                currentContext = .Accuracy
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // Case #1: basic KML just has coordinates element - lame, because no speed is possible.
        if (elementName.compare("coordinates", options: .caseInsensitive) == .orderedSame) {
            if (fHasTrack) {  // we've seen a gx:track element - don't parse the placemark coordinates!!!
                return
            }

            // This is a set of space-delimited tuples of longitude, latitude, altitude
            let rgLines = elementInProgress.replacingOccurrences(of: "\r", with: "").components(separatedBy: "\n")
            
            for sz in rgLines {
                if (parseTuple(sz)) {
                    samplesToReturn.append(locInProgress!)
                    initLocationInProgress()
                }
            }
        } else if elementName.compare("when", options: .caseInsensitive) == .orderedSame {
            // Case #2 (preferred)
            if let d = NSDate.init(iso8601String: elementInProgress) {
                locInProgress?.addTime(d as Date)
            }
        }
        else if elementName.compare("gx:coord", options: .caseInsensitive) == .orderedSame {
            fHasTrack = true
            if parseTuple(elementInProgress) {
                samplesToReturn.append(locInProgress!)
            } else {
                NSLog("Error reading tuple: \(elementInProgress)")
            }
            // set up for the next sample
            initLocationInProgress()
        }
        else if elementName.compare("gx:value", options: .caseInsensitive) == .orderedSame {
            if currentGXValueIndex < samplesToReturn.count {
                let cml = samplesToReturn[currentGXValueIndex]
                currentGXValueIndex += 1
                switch (currentContext) {
                case .Accuracy:
                    let acc = numberFormatter.number(from: elementInProgress)?.intValue ?? CLMutableLocation.INFERRED_HERROR
                    cml.horizontalAccuracy = acc
                case .Speed:
                    if let speedInKts = numberFormatter.number(from: elementInProgress)?.doubleValue {
                        cml.addSpeed(speedInKts / MFBConstants.MPS_TO_KNOTS)
                        self.hasSpeed = true
                    }
                default:
                    break;
                }
            }
        } else if elementName.compare("gx:SimpleArrayData", options: .caseInsensitive) == .orderedSame {
            currentContext = .None
            currentGXValueIndex = 0
        }
   }
    
    @objc public static override func serializeFromPath(_ arSamples: [CLLocation]) -> String {
        // Hack - this is brute force writing, not proper generation of XML.  But it works...
        // We are also assuming valid timestamps (i.e., we're using gx:Track)
        var szKML = """
<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">"
<Document>\r\n<open>1</open>\r\n<visibility>1</visibility>\r\n<Placemark>\r\n\r\n<gx:Track>\r\n<extrude>1</extrude>\r\n<altitudeMode>absolute</altitudeMode>\r\n
"""
        let nf = getPosixNumberFormatter()
        for cl in arSamples {
            szKML.append(String(format: "<when>%@</when>\r\n<gx:coord>%@ %@ %@</gx:coord>\r\n",
                                (cl.timestamp as NSDate).iso8601DateString(),
                                nf.string(from: NSNumber(floatLiteral: cl.coordinate.longitude))!,
                                nf.string(from: NSNumber(floatLiteral: cl.coordinate.latitude))!,
                                nf.string(from: NSNumber(floatLiteral: cl.altitude))!))
        }
        szKML.append("</gx:Track></Placemark></Document></kml>")
        return szKML
    }
}

@objc public class GPXTelemetry : Telemetry {
    @objc public override var samples: [CLLocation] {
        get {
            return parse().map { $0.location }
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        elementInProgress = ""
        if elementName.compare("trkpt", options: .caseInsensitive) == .orderedSame {
            initLocationInProgress()
            let szLat = attributeDict["lat"] ?? ""
            let szLon = attributeDict["lon"] ?? ""
            if !szLat.isEmpty && !szLon.isEmpty {
                if let l = locInProgress {
                    l.latitude = numberFormatter.number(from: szLat)?.doubleValue ?? 0.0
                    l.longitude = numberFormatter.number(from: szLon)?.doubleValue ?? 0.0
                }
            }
        } else if elementName.compare("name", options: .caseInsensitive) == .orderedSame {
            if let szTail = attributeDict[Telemetry.TELEMETRY_META_AIRCRAFT_TAIL] {
                if !szTail.isEmpty {
                    metaData[Telemetry.TELEMETRY_META_AIRCRAFT_TAIL] = szTail
                }
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName.compare("trkpt", options: .caseInsensitive) == .orderedSame {
            // Close it out!
            computeSpeed()
            samplesToReturn.append(locInProgress!)
        } else {
            if elementName.compare("time", options: .caseInsensitive) == .orderedSame {
                locInProgress?.addTime(NSDate.init(iso8601String: elementInProgress) as Date)
            } else if elementName.compare("ele", options: .caseInsensitive) == .orderedSame {
                if let alt = numberFormatter.number(from: elementInProgress) {
                    locInProgress?.addAlt(alt.doubleValue)
                }
            } else if elementName.compare("speed", options: .caseInsensitive) == .orderedSame {
                if let speed = numberFormatter.number(from: elementInProgress)?.doubleValue {
                    locInProgress?.addSpeed(speed)
                    hasSpeed = true
                }
            } else if elementName.compare("badelf:speed", options: .caseInsensitive) == .orderedSame {
                if let speed = numberFormatter.number(from: elementInProgress)?.doubleValue {
                    locInProgress?.addSpeed(speed)
                    hasSpeed = true
                }
            } else if elementName.compare("acc_horiz", options: .caseInsensitive) == .orderedSame {
                if let acc = numberFormatter.number(from: elementInProgress) {
                    locInProgress?.horizontalAccuracy = acc.intValue
                }
            }
        }
    }
    
    @objc public override class func serializeFromPath(_ arSamples: [CLLocation]) -> String {
        // Hack - this is brute force writing, not proper generation of XML.  But it works...
        var szGPX = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<gpx creator=\"http://myflightbook.com\" version=\"1.1\" xmlns=\"http://www.topografix.com/GPX/1/1\">"
        szGPX.append("\r\n<trk>\r\n\t\t<name />\r\n\t\t<trkseg>]")
        
        let szFmtTrackPoint = "\r\n\t\t\t<trkpt lat=\"%8f\" lon=\"%.8f\">\r\n\t\t\t\t<ele>%.8f</ele>\r\n\t\t\t\t<time>%@</time>\r\n\t\t\t\t<speed>%.4f</speed>\r\n\t\t\t</trkpt>"
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        // gpx > trk > trkseg > trkpt
        for cl in arSamples {
            szGPX.append(String(format: szFmtTrackPoint, cl.coordinate.latitude, cl.coordinate.longitude, cl.altitude, df.string(from: cl.timestamp), cl.speed))
        }
        
        szGPX.append("\r\n\t\t</trkseg>\r\n\t</trk>\r\n</gpx>")
        return szGPX
    }
}

@objc public class CSVTelemetry : Telemetry {
    @objc public override var samples: [CLLocation] {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        // get an array of lines
        let rgLines = szRawData.replacingOccurrences(of: "\r", with: "").components(separatedBy: "\n")
        
        var ar : [CLLocation] = []
        var iLine = 0
        
        for sz in rgLines {
            let rgLine = sz.components(separatedBy: ",")
            if (rgLine.count < 6) {
                continue
            }
            
            let fHeaderRow = iLine == 0
            iLine += 1
            
            // skip the header line
            if (fHeaderRow) {
                iLine += 1
                continue
            }
            
            let Latitude = Double(rgLine[0])!
            let Longitude = Double(rgLine[1])!
            let Altitude = Double(rgLine[2])!
            let Speed = Double(rgLine[3])! / MFBConstants.MPS_TO_KNOTS
            let HError = Double(rgLine[4])!
            var dt = df.date(from: rgLine[5])!
            if (rgLine.count > 7) {
                let tzOffset = rgLine[6].isEmpty ? 0 : Int(rgLine[6])!
                if (tzOffset > 0) {
                    dt = dt.addingTimeInterval(TimeInterval(tzOffset * 60))
                }
            }
            
            // NSString * Comment = (NSString *) [rgLine objectAtIndex:7];
            
            // NSLog(@"%d: Lat=%.8f, Lon=%.8f, Alt=%.1f, Speed=%.1f, Err=%.0f, date=%s\n", ++iSample, Latitude, Longitude, Altitude, Speed, HError, [(NSString *) [rgLine objectAtIndex:5] UTF8String]);

            let coord = CLLocationCoordinate2D(latitude: Latitude, longitude: Longitude)
            
            let loc = CLLocation(coordinate: coord, altitude: Altitude,
                                 horizontalAccuracy: HError, verticalAccuracy: 0,
                                 course: 0, speed: Speed, timestamp: dt)
            
            ar.append(loc)
        }
        
        return ar
    }
    
    @objc public override class func serializeFromPath(_ arSamples: [CLLocation]) -> String {
        var sz = "LAT,LON,PALT,SPEED,HERROR,DATE\r\n"
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        
        for cl in arSamples {
            sz.append(String(format: "%.8F,%.8F,%d,%.1F,%.1F,%@\r\n",
                             cl.coordinate.latitude,
                             cl.coordinate.longitude,
                             Int(cl.altitude * MFBConstants.METERS_TO_FEET),
                             cl.speed,
                             cl.horizontalAccuracy,
                             df.string(from: cl.timestamp)))
        }
        return sz
    }
    
    
}

@objc public class NMEATelemetry : Telemetry {
    @objc public override var samples: [CLLocation] {
        var results : [CLMutableLocation] = []
        
        let separator = NSCharacterSet.newlines
        let sentences = szRawData.components(separatedBy: separator)
        
        var lastAltitudeSeen = 0.0
        hasSpeed = false
        for sentence in sentences {
            let result = NMEAParser.parseSentence(sentence)
            if let loc = result as? CLMutableLocation {
                if (loc.hasAlt) {
                    lastAltitudeSeen = loc.altitude    // GPGGA has altitude, but not date or speed; just take altitude here and wait for the GPRMC.
                }
                else {
                    hasSpeed = hasSpeed || loc.hasSpeed
                    loc.addAlt(lastAltitudeSeen)
                    results.append(loc)
                }
            }
        }
        
        return results.map { $0.location }
    }
}

@objc public class NMEASatelliteStatus : NSObject {
    @objc public var HDOP = 0.0
    @objc public var VDOP = 0.0
    @objc public var PDOP = 0.0
    @objc public var Mode = ""
    @objc public var satellites = Set<NSNumber>()
}

@objc public class NMEAParser : NSObject {
    public static func parseGPRMC(_ words : [String]) -> CLMutableLocation? {
        if (words.count < 12) {
            return nil
        }
        
        // UTC Time in hhmmss
        if (words[1].count < 6) {
            return nil
        }
        
        let hour = Int(words[1][0..<2])!
        let min = Int(words[1][2..<4])!
        let sec = Int(words[1][4..<6])!
        let day = Int(words[9][0..<2])!
        let month = Int(words[9][2..<4])!
        let year = Int(words[9][4..<6])! + 2000
        
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = min
        dateComponents.second = sec
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dateComponents)!
        
        if words[2].compare("A", options: .caseInsensitive) != .orderedSame {
            return nil
        }
        
        let nf = Telemetry.getPosixNumberFormatter()

        var lat = Double(words[3][0..<2])! + nf.number(from: words[3][2..<words[3].count])!.doubleValue / 60.0
        if words[4].compare("S", options: .caseInsensitive) == .orderedSame {
            lat = -lat
        }
        var lon =  Double(words[5][0..<3])! + nf.number(from: words[5][3..<words[5].count])!.doubleValue / 60.0
        if words[6].compare("W", options: .caseInsensitive) == .orderedSame {
            lon = -lon
        }
        let speed = nf.number(from: words[7])!.doubleValue
        
        let loc = CLMutableLocation(lat, lon)
        loc.addSpeed(speed)
        loc.addTime(date)
        return loc
    }
    
    public static func parseGPGGA(_ words : [String]) -> CLMutableLocation? {
        if (words.count < 15) {
            return nil
        }

        // check for empty latitude/longitude or malformed time
        if (words[1].count < 6 || words[2].isEmpty || words[4].isEmpty) {
            return nil
        }
        
        // UTC Time in hhmmss
        let hour = Int(words[1][0..<2])!
        let min = Int(words[1][2..<4])!
        let sec = Int(words[1][4..<6])!

        var dateComponents = DateComponents()
        let compsNow = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        dateComponents.year = compsNow.year
        dateComponents.month = compsNow.month
        dateComponents.day = compsNow.day
        dateComponents.hour = hour
        dateComponents.minute = min
        dateComponents.second = sec
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: dateComponents)!

        let nf = Telemetry.getPosixNumberFormatter()

        var lat = Double(words[2][0..<2])! + nf.number(from: words[2][2..<words[2].count])!.doubleValue / 60.0
        if words[3].compare("S", options: .caseInsensitive) == .orderedSame {
            lat = -lat
        }
        var lon =  Double(words[4][0..<3])! + nf.number(from: words[4][3..<words[4].count])!.doubleValue / 60.0
        if words[5].compare("W", options: .caseInsensitive) == .orderedSame {
            lon = -lon
        }
        let alt = nf.number(from: words[9])!.doubleValue
        
        let loc = CLMutableLocation(lat, lon)
        loc.addAlt(alt)
        loc.addTime(date)
        
        return loc
    }
    
    public static func parseGPGSA(_ words : [String]) -> NMEASatelliteStatus? {
        if (words.count < 18) {
            return nil
        }
        
        let status = NMEASatelliteStatus()
        switch (Int(words[2])) {
        case 1:
            status.Mode = "No fix"
        case 2:
            status.Mode = "2-D"
        case 3:
            status.Mode = "3-D"
        default:
            status.Mode = ""
            break;
        }
        
        for i in 3..<14 {
            if !words[i].isEmpty {
                status.satellites.insert(NSNumber(integerLiteral: i))
            }
        }
        
        let nf = Telemetry.getPosixNumberFormatter()

        status.PDOP = nf.number(from: words[15])?.doubleValue ?? 0.0
        status.HDOP = nf.number(from: words[16])?.doubleValue ?? 0.0
        
        var szVDOP = words[17]
        if let r = szVDOP.range(of: "*") {
            szVDOP = String(szVDOP[szVDOP.startIndex..<r.lowerBound])
        }
        status.VDOP = nf.number(from: szVDOP)?.doubleValue ?? 0.0
        
        return status
    }
    
    @objc public static func parseSentence(_ sentence : String?) -> NSObject? {
        if (sentence == nil || !sentence!.hasPrefix("$GP")) {
            return nil
        }
        
        let s = sentence!
        let words = s.components(separatedBy: ",")
        
        if s.hasPrefix("$GPRMC") {
            return NMEAParser.parseGPRMC(words)
        } else if s.hasPrefix("$GPGGA") {
            return NMEAParser.parseGPGGA(words)
        } else if s.hasPrefix("$GPGSA") {
            return NMEAParser.parseGPGSA(words)
        }
        return nil
    }
}
