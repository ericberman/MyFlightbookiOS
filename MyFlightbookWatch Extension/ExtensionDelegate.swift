/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  ExtensionDelegate.swift
//  MyFlightbookWatch Extension
//
//  Created by Eric Berman on 10/27/15.
//
//

import WatchKit
import WatchConnectivity
import Foundation

public protocol SessionResponder {
    func handleData(_ dictResult: [String : AnyObject])
}

public protocol ActivationResponder {
    func handleActivation(_ session:WCSession)
}

open class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    var session : WCSession!
    var messageHandlers = [String : SessionResponder]()
    var activationHandlers = [String : ActivationResponder]()
    
    open func applicationDidFinishLaunching() {

        // Perform any final initialization of your application.
        initSession()
    }
    
    func initSession() {
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session.delegate = self
            session.activate()
        }
    }
    
    open func setHandler(_ handler: SessionResponder?, forMessage:String) {
        if let h = handler {
            messageHandlers[forMessage] = h
        }
        else {
            messageHandlers.removeValue(forKey: forMessage)
        }
    }
    
    open func setActivationHandler(_ handler: ActivationResponder?, forClient:String) {
        if let h = handler {
            activationHandlers[forClient] = h
        } else {
            activationHandlers.removeValue(forKey: forClient)
        }
    }

    open func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog("MFBWatch: application became active")

        if (session.delegate !== self) {
            NSLog("MFBWatch: DELEGATE WAS CHANGED!")
        }
        
        if (session.activationState != WCSessionActivationState.activated) {
            NSLog("MFBWatch: Session not active any more!")
            session.activate()
        }
    }
    
    open func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        NSLog("MFBWatch: didReceiveApplicationContext")

        // dispatch each message
        for (key, _) in applicationContext {
            if let handler = messageHandlers[key] {
                NSLog("MFBWatch: handler found for this message")
                handler.handleData(applicationContext as [String : AnyObject])
            }
        }
    }
    
    open func session(_ s: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        self.session = s
        if let err = error {
            NSLog("MFBWatch: Error in activation of session: %@", err.localizedDescription)
        }
        for (_, handler) in activationHandlers {
            handler.handleActivation(s)
        }
    }

    open func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }
}
