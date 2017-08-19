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
//  CockpitInterfaceController.swift
//  MyFlightbookWatch Extension
//
//  Created by Eric Berman on 10/27/15.
//
//

import WatchKit
import WatchConnectivity
import Foundation

class CockpitInterfaceController: WKInterfaceController, WCSessionDelegate, SessionResponder, ActivationResponder {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // TODO: do something here
    }


    // Status labels
    @IBOutlet weak var lblStatus : WKInterfaceLabel!
    @IBOutlet weak var lblTimer: WKInterfaceLabel!
    @IBOutlet weak var btnStart : WKInterfaceButton!
    @IBOutlet weak var btnEnd : WKInterfaceButton!
    @IBOutlet weak var btnPausePlay : WKInterfaceButton!
    @IBOutlet weak var imgRecording : WKInterfaceImage!
    @IBOutlet weak var imgPausePlay : WKInterfaceImage!
    @IBOutlet weak var lblLat: WKInterfaceLabel!
    @IBOutlet weak var lblLon: WKInterfaceLabel!
    @IBOutlet weak var lblSpeed: WKInterfaceLabel!
    @IBOutlet weak var lblAlt: WKInterfaceLabel!
    @IBOutlet weak var grpUnstarted : WKInterfaceGroup!
    @IBOutlet weak var grpInProgress : WKInterfaceGroup!
    @IBOutlet weak var grpFinished : WKInterfaceGroup!
    
    var latestData : SharedWatch?
    var latestUpdate : Date?
    var timer : Timer?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
     }
    
    func getSession() -> WCSession {
        let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        return watchDelegate.session
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        // make sure that the extension delegate calls us for WATCH_RESPONSE_STATUS
        let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        watchDelegate.setHandler(self, forMessage: WATCH_RESPONSE_STATUS)
        watchDelegate.setActivationHandler(self, forClient: WATCH_RESPONSE_STATUS)
        
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)

        let session = getSession()
        if (session.activationState == WCSessionActivationState.activated) {
            refresh([WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_STATUS])
        }
        else {
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        let watchDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        watchDelegate.setHandler(nil, forMessage: WATCH_RESPONSE_STATUS)
        watchDelegate.setHandler(nil, forMessage: WATCH_RESPONSE_STATUS)
        self.timer?.invalidate()
    }
    
    func handleActivation(_ session:WCSession) {
        refresh([WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_STATUS]);
    }
    
    @IBAction func startFlight() {
        refresh([WATCH_MESSAGE_ACTION: WATCH_ACTION_START])
    }
    
    @IBAction func endFlight() {
        refresh([WATCH_MESSAGE_ACTION: WATCH_ACTION_END])
    }
    
    @IBAction func pausePlay() {
        refresh([WATCH_MESSAGE_ACTION: WATCH_ACTION_TOGGLE_PAUSE])
    }
    
    func updateTime(_:Timer) {
        if let wd = latestData {
            if (!wd.isPaused && wd.flightStage == flightStageInProgress) {
                if let dtLast = self.latestUpdate {
                    let offset = Date().timeIntervalSince(dtLast)
                    updateElapsedDisplay(wd.elapsedSeconds + Double(offset))
                }
            }
        }
    }
    
    func updateElapsedDisplay(_ seconds : Double) {
        let elapsedSeconds = Int(seconds)
        lblTimer.setText(NSString(format: "%02d:%02d:%02d", elapsedSeconds / 3600, (elapsedSeconds % 3600) / 60, elapsedSeconds % 60) as String!)
    }
    
    func updateMainMenus(_ watchData : SharedWatch)
    {
        self.clearAllMenuItems()
        if (watchData.flightStage == flightStageInProgress) {
            if (watchData.isPaused) {
                self.addMenuItem(withImageNamed: "Play", title: NSLocalizedString("WatchPlay", comment: "Watch - Resume"), action: #selector(CockpitInterfaceController.pausePlay))
            }
            else {
                self.addMenuItem(withImageNamed: "Pause", title: NSLocalizedString("WatchPause", comment: "Watch - Pause"), action: #selector(CockpitInterfaceController.pausePlay))
            }
        }
    }
    
    func updateScreen(_ watchData : SharedWatch!) {
        lblLat.setText(watchData.latDisplay)
        lblLon.setText(watchData.lonDisplay)
        lblStatus.setText(watchData.flightstatus)
        lblSpeed.setText(watchData.speedDisplay)
        lblAlt.setText(watchData.altDisplay)
        imgPausePlay.setImageNamed(watchData.isPaused ? "Play.png" : "Pause.png" )
        updateElapsedDisplay(watchData.elapsedSeconds)
        grpFinished.setHidden(watchData.flightStage != flightStageDone)
        grpInProgress.setHidden(watchData.flightStage != flightStageInProgress)
        grpUnstarted.setHidden(watchData.flightStage != flightStageUnstarted)
        imgRecording.setHidden(!watchData.isRecording)
        
        self.performSelector(onMainThread:#selector(updateMainMenus(_:)), with: watchData, waitUntilDone: false)
    }
    
    func updateStatusMessage(_ dictResult: [String : Any]) {
        NSLog("MFBWatch: Update Status Message")
        if let statusData = dictResult[WATCH_RESPONSE_STATUS] as? Data {
            if let status = NSKeyedUnarchiver.unarchiveObject(with: statusData) as? SharedWatch {
                self.latestData = status
                self.updateScreen(status)
                self.latestUpdate = Date()
            }
        }
    }
    
    func handleData(_ dictResult: [String : AnyObject]) {
        NSLog("MFBWatch: handleData called in Cockpit")
        self.updateStatusMessage(dictResult)
    }
    
    func refresh(_ req: [String: String]) {
        NSLog("MFBWatch: Refresh called")
        let session = getSession()
        if (session.activationState != WCSessionActivationState.activated) {
            session.activate()
            return;
        }
        
        if (session.isReachable) {
            session.sendMessage(req, replyHandler: { (dictResult:[String : Any]) -> Void in
                NSLog("MFBWatch: response received!!!")
                self.updateStatusMessage(dictResult)
            },
            errorHandler: {  (error ) -> Void in
                print("MFBWatch: We got an error from our watch device : " + error.localizedDescription)
                NSLog("MFBWatch: We got an error from our watch device : " + error.localizedDescription)
                let cancelAction = WKAlertAction(title: "Cancel", style: WKAlertActionStyle.cancel) {}
                self.presentAlert(withTitle: NSLocalizedString("Error", comment: "Title for generic error message"), message: error.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions: [cancelAction])
            })
        }
    }
}
