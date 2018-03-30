/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2015-2018 MyFlightbook, LLC
 
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
//  RefreshableData.swift
//  MFBSample
//
//  Created by Eric Berman on 11/1/15.
//
//
import WatchKit
import WatchConnectivity
import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class RefreshableTableController : WKInterfaceController {
    @IBOutlet weak var table : WKInterfaceTable!
    @IBOutlet weak var lblError : WKInterfaceLabel!
    
    var lastUpdate : Date?
    let timeIntervalForceRefresh = 3600.0 // one hour (3600 seconds) forces a refresh

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        lblError.setHidden(true)
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let session = getSession()
        if (session.activationState != WCSessionActivationState.activated) {
            session.activate()
            return;
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func dataIsExpired() -> Bool {
        return lastUpdate == nil || lastUpdate?.timeIntervalSinceNow < -timeIntervalForceRefresh
    }
    
    func updateTable() {
        // Overridden by the subclass
        preconditionFailure("This method must be overridden")
    }
    
    func refreshRequest() -> [String: String] {
        // Overridden by the subclass
        preconditionFailure("This method must be overridden")
    }
    
    func bindRefreshResult(_ dictResult: NSDictionary!) {
        // Overridden by the subclass
        preconditionFailure("This method must be overridden")
    }
    
    func getSession() -> WCSession {
        let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        return watchDelegate.session
    }
    
    @IBAction func refresh() {
        if (WCSession.isSupported()) {
            let session = getSession()
            if (session.activationState != WCSessionActivationState.activated) {
                session.activate()
                return;
            }
            if (session.isReachable) {
                self.lblError.setHidden(true)
                let requestData = refreshRequest()
                session.sendMessage(requestData, replyHandler: { (dictResult:[String : Any]) -> Void in
                    self.bindRefreshResult(dictResult as NSDictionary?)
                    },
                errorHandler: {  (error ) -> Void in
                    print("We got an error from our watch device : " + error.localizedDescription)
                    self.lblError.setText(error.localizedDescription)
                    self.lblError.setHidden(false)
                })
            }
            else {
                self.lblError.setText(NSLocalizedString("WatchNoReach", comment: "Watch - Unreachable"))
                self.lblError.setHidden(false)
            }
        }
    }
}
