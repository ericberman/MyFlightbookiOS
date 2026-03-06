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
//  GPSSimulator.swift
//  MFBSample
//
//  Created by Eric Berman on 3/3/26.
//

import Network
import CocoaAsyncSocket
import AVFAudio

/*
   Implement a listener for a simulated GPS signal from a flight simulator.  Unlike GPSSim, which is a testing tool to rapidly feed a set of GPS events, this
   replaces the hardware GPS signal for a network provided one.
 */
class SimulatorGPSReceiver: NSObject, GCDAsyncUdpSocketDelegate {
    private let minSampleInterval = 0.5 // half a second per sample
    private var socket4902: GCDAsyncUdpSocket?
    private var socket4900: GCDAsyncUdpSocket?
    private var lastSample = Date().addingTimeInterval(-1)
    private let parser = XPlaneDataParser()
    private var lastPosition = XPlanePosition(
        latitude: 0, longitude: 0, altitudeFeet: 0,
        groundspeedKnots: 0, headingTrue: 0, pitch: 0, roll: 0
    )
    private var silentAudioActive = false
    
    func startListening() {
        startSilentAudio()
        socket4902 = makeSocket(on: 49002)
        socket4900 = makeSocket(on: 49000)
    }
    
    func stopListening() {
        stopSilentAudio()
        socket4902?.close()
        socket4902 = nil
        socket4900?.close()
        socket4900 = nil
        print("🔴 Simulator GPS stopped")
    }
    
    private func makeSocket(on port: UInt16) -> GCDAsyncUdpSocket? {
        let socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: .global())
        do {
            try socket.enableReusePort(true)      // allow multiple apps on same port
            try socket.bind(toPort: port)
            try socket.enableBroadcast(true)      // receive broadcast packets
            try socket.beginReceiving()
            print("✅ Listening on UDP port \(port)")
            return socket
        } catch {
            print("❌ Failed to bind port \(port): \(error)")
            return nil
        }
    }
    
    func startSilentAudio() {
        guard !silentAudioActive else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, options: .mixWithOthers)
            try session.setActive(true)
            silentAudioActive = true
        } catch {
            print("Audio session start error: \(error)")
        }
    }

    func stopSilentAudio() {
        guard silentAudioActive else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            silentAudioActive = false
        } catch {
            print("Audio session stop error: \(error)")
        }
    }
    
    // MARK: - GCDAsyncUdpSocketDelegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket,
                   didReceive data: Data,
                   fromAddress address: Data,
                   withFilterContext filterContext: Any?) {
        parsePacket(data)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotBindToPort port: UInt16, error: Error?) {
        print("❌ Could not bind to port \(port): \(error?.localizedDescription ?? "unknown")")
    }
    
    func parsePacket(_ data: Data) {
        // Try ForeFlight JSON first (port 49002)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let xgps = json["XGPS"] as? [String: Double] {
            let lat  = xgps["Latitude"] ?? 0
            let lon  = xgps["Longitude"] ?? 0
            let alt  = xgps["Altitude"] ?? 0   // feet MSL
            let trk  = xgps["Track"] ?? 0      // degrees true
            let spd  = xgps["Speed"] ?? 0      // knots
            if (Date().timeIntervalSince(lastSample) > minSampleInterval) {
                lastSample = Date()
                DispatchQueue.main.async {
                    self.updatePosition(lat: lat, lon: lon, alt: alt, track: trk, speed: spd)
                }
            }
            
            return
        } else {
            // Fall back to X-Plane binary (port 49000)
            let parser = XPlaneDataParser()
            guard let parsed = parser.parse(data) else { return }
            let header = String(bytes: data.prefix(5), encoding: .ascii)
            
            if header == "XATT2" {
                // Only update attitude fields
                lastPosition.headingTrue = parsed.headingTrue
                lastPosition.pitch = parsed.pitch
                lastPosition.roll = parsed.roll
            } else {
                // XGPS2 — update position fields, keep last attitude
                lastPosition.latitude = parsed.latitude
                lastPosition.longitude = parsed.longitude
                lastPosition.altitudeFeet = parsed.altitudeFeet
                lastPosition.groundspeedKnots = parsed.groundspeedKnots
                // heading also comes in XGPS2, so update it too
                lastPosition.headingTrue = parsed.headingTrue
            }
            
            // Only emit a location when we have a valid position
            guard lastPosition.latitude != 0 || lastPosition.longitude != 0 else { return }
            if (Date().timeIntervalSince(lastSample) > minSampleInterval) {
                lastSample = Date()
                DispatchQueue.main.async {
                    MFBAppDelegate.threadSafeAppDelegate.mfbloc.newLocation(parser.toCLLocation(self.lastPosition))
                }
            }
        }
    }
    
    func updatePosition(lat: Double, lon: Double, alt: Double, track: Double, speed: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let altMeters = alt * 0.3048  // feet to meters
        let spdMeters = speed * 0.514444  // knots to m/s
        
        let location = CLLocation(
            coordinate: coordinate,
            altitude: altMeters,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: track,
            speed: spdMeters,
            timestamp: Date()
        )
        
        MFBAppDelegate.threadSafeAppDelegate.mfbloc.newLocation(location)
    }
}
