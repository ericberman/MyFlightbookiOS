/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2026 MyFlightbook, LLC
 
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
//  XPlaneDataParser.swift
//  MFBSample
//
//  Created by Eric Berman on 3/3/26.
//

import Foundation

struct XPlanePosition {
    var latitude: Double
    var longitude: Double
    var altitudeFeet: Double
    var groundspeedKnots: Double
    var headingTrue: Double
    var pitch: Double
    var roll: Double
}

class XPlaneDataParser {
    
    func parse(_ data: Data) -> XPlanePosition? {
        guard data.count >= 6 else { return nil }
        
        // Check which format we have
        let header5 = String(bytes: data.prefix(5), encoding: .ascii)
        
        switch header5 {
        case "XGPS2":
            return parseXGPS2(data)
        case "XATT2":
            return parseXATT2(data)  // attitude data — see below
        case "DATA\0":
            return parseXPlaneData(data)
        default:
            print("Unknown header: \(header5 ?? "nil")")
            return nil
        }
    }
    
    // MARK: - XGPS2 (position)
    
    private func parseXGPS2(_ data: Data) -> XPlanePosition? {
        guard let string = String(data: data, encoding: .ascii) else { return nil }
        
        // Format: "XGPS2,lon,lat,alt,speed,???"
        let parts = string.split(separator: ",")
        guard parts.count >= 6,
              parts[0] == "XGPS2",
              let lon     = Double(parts[1]),
              let lat     = Double(parts[2]),
              let altMeters = Double(parts[3]),
              let track   = Double(parts[4]),
              let speedMS = Double(parts[5]) else { return nil }
        
        return XPlanePosition(
            latitude: lat,
            longitude: lon,
            altitudeFeet: altMeters * 3.28084,      // meters → feet
            groundspeedKnots: speedMS * 1.94384,    // m/s → knots
            headingTrue: track,
            pitch: 0,
            roll: 0
        )
    }
    
    // MARK: - XATT2 (attitude — sent as a separate packet)
    
    private func parseXATT2(_ data: Data) -> XPlanePosition? {
        // XATT2 contains heading, pitch, roll — no position
        // You'd merge this with the last known XGPS2 position
        guard data.count >= 18 else { return nil }
        
        let offset = 6  // skip "XATT2\0"
        
        let heading = data.parseFloat(at: offset)      // bytes 6-9
        let pitch   = data.parseFloat(at: offset + 4)  // bytes 10-13
        let roll    = data.parseFloat(at: offset + 8)  // bytes 14-17
        
        // Return partial — caller should merge with last position
        return XPlanePosition(
            latitude: 0, longitude: 0, altitudeFeet: 0,
            groundspeedKnots: 0,
            headingTrue: Double(heading),
            pitch: Double(pitch),
            roll: Double(roll)
        )
    }

    // MARK: - Original X-Plane DATA\0 binary (keep for compatibility)
    
    private func parseXPlaneData(_ data: Data) -> XPlanePosition? {
        var position = XPlanePosition(
            latitude: 0, longitude: 0, altitudeFeet: 0,
            groundspeedKnots: 0, headingTrue: 0, pitch: 0, roll: 0
        )
        var gotPosition = false
        let chunkSize = 36
        var offset = 5

        while offset + chunkSize <= data.count {
            let chunk = data.subdata(in: offset..<(offset + chunkSize))
            let index = chunk.parseInt32(at: 0)
            switch index {
            case 20:
                position.latitude     = Double(chunk.parseFloat(at: 4))
                position.longitude    = Double(chunk.parseFloat(at: 8))
                position.altitudeFeet = Double(chunk.parseFloat(at: 12))
                gotPosition = true
            case 21:
                position.groundspeedKnots = Double(chunk.parseFloat(at: 20))
            case 17:
                position.pitch       = Double(chunk.parseFloat(at: 4))
                position.roll        = Double(chunk.parseFloat(at: 8))
                position.headingTrue = Double(chunk.parseFloat(at: 12))
            default:
                break
            }
            offset += chunkSize
        }
        return gotPosition ? position : nil
    }
}

// MARK: - Data helpers (add Double support)

private extension Data {
    func parseInt32(at offset: Int) -> Int32 {
        subdata(in: offset..<(offset+4))
            .withUnsafeBytes { $0.load(as: Int32.self) }
    }
    func parseFloat(at offset: Int) -> Float {
        subdata(in: offset..<(offset+4))
            .withUnsafeBytes { $0.load(as: Float.self) }
    }
    func parseDouble(at offset: Int) -> Double {
        subdata(in: offset..<(offset+8))
            .withUnsafeBytes { $0.load(as: Double.self) }
    }
}

extension XPlaneDataParser {
    func toCLLocation(_ pos: XPlanePosition) -> CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(
                latitude: pos.latitude,
                longitude: pos.longitude
            ),
            altitude: pos.altitudeFeet * 0.3048,         // feet → meters
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: pos.headingTrue,
            speed: pos.groundspeedKnots * 0.514444,      // knots → m/s
            timestamp: Date()
        )
    }
}
