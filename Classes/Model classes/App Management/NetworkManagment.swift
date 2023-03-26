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
//  NetworkManagment.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation
import Network

@objc public enum NetworkStatus : Int {
    case notReachable = 0
    case reachableViaWifi = 1
    case reachableViaWWAN = 2
}

@objc public protocol NetworkManagementListener {
    func newState(_ newState : NetworkStatus)
}

@objc public class MFBNetworkManager : NSObject {
    private let networkMonitor = NWPathMonitor()
    @objc public var fNetworkStateKnown = false
    @objc public var lastKnownNetworkStatus : NetworkStatus = .notReachable
    var delegate : NetworkManagementListener? = nil
    
    private static var _shared : MFBNetworkManager? = nil
    
    @objc public static var shared : MFBNetworkManager {
        get {
            if (_shared == nil) {
                _shared = MFBNetworkManager()
            }
            return _shared!
        }
    }
    
    @objc public var isOnLine : Bool {
        get {
            // There is a lag between when the reachability object is initialized and we get our first notification
            // So as a hack, we use a flag (fNetworkStateKnown) to indicate that we have not yet received a notification
            // and we optimistically assume we are ONLINE if we get that.  Once the app is running, we assume reachability
            // is valid.
            return lastKnownNetworkStatus != .notReachable || !fNetworkStateKnown
        }
    }
    
    @objc public override init() {
        super.init()
        networkMonitor.pathUpdateHandler = { path in
            switch (path.status) {
            case .unsatisfied, .requiresConnection:
                self.fNetworkStateKnown = true
                self.lastKnownNetworkStatus = .notReachable
                self.delegate?.newState(.notReachable)
                NSLog("Path update - no network")
            case .satisfied:
                // Online
                self.fNetworkStateKnown = true
                self.lastKnownNetworkStatus = path.isConstrained || path.isExpensive || path.availableInterfaces[0].type == .cellular ? .reachableViaWWAN : .reachableViaWifi
                NSLog("Path update - satisfied, but checking; type is \(self.lastKnownNetworkStatus == .reachableViaWifi ? "wifi" : "wwan")")
                // We trust...but verify
                DispatchQueue.global(qos: .background).async {
                    self.asyncResolveDNS()
                }
            default:
                break
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        networkMonitor.start(queue: queue)
    }
    
    @objc public convenience init(delegate d : NetworkManagementListener) {
        self.init()
        delegate = d
    }
    
    func asyncResolveDNS() {
        let ns = lastKnownNetworkStatus
        if (ns == .notReachable || ns == .reachableViaWifi) {
            // Reachability just returns a theoretical reachability.
            // We don't trust reachability for Wifi or for None (switching between Internet and Stratus, for example), so do a 2nd check.
            // Here, we do a DNS check to see if we can resolve.  This can force a recheck of reachability
            // If we are on a private WiFi network (such as Appareo Stratus), this will fail.
            NSLog("asyncResolveDNS: We don't trust the network change, so we'll do our own DNS check")
            let hostRef = CFHostCreateWithName(kCFAllocatorDefault, MFBHOSTNAME as CFString).takeRetainedValue()
            
            var fDNSSucceeded = CFHostStartInfoResolution(hostRef, .addresses, nil)  // pass an error instead of NULL here to find out why it failed
            if fDNSSucceeded {
                var result : DarwinBoolean = false
                CFHostGetAddressing(hostRef, &result)
                fDNSSucceeded = result.boolValue
            }
            // CFRelease(hostRef as! CFHost)
            
            if fDNSSucceeded {
                if ns == .notReachable {
                    fNetworkStateKnown = false    // we don't know what the state is so can't set wifi or WWan, but can say that we just don't know.
                    DispatchQueue.main.async {
                        self.delegate?.newState(.notReachable)
                        NSLog("asyncResolveDNS: Reachability resported no network, but we found one!")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.delegate?.newState(.reachableViaWifi)
                        NSLog("asyncResolveDNS: WiFi connectivity confirmed")
                    }
                }
            }
            else
            {
                if ns == .reachableViaWifi {
                    NSLog("asyncResolveDNS: wifi, but DNS failed")
                    lastKnownNetworkStatus = .notReachable
                }
                else {
                    NSLog("asyncResolveDNS: not-reachable confirmed")
                }
                self.delegate?.newState(.notReachable)
            }
        }
    }
}
