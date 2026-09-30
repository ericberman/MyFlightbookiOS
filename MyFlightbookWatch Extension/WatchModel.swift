/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2015-2026 MyFlightbook, LLC
 
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
//  WatchModel.swift
//  MyFlightbookWatch
//
//  Owns the WatchConnectivity session and all data received from the iPhone.
//

import Foundation
import WatchConnectivity

struct RemoteList<Item> {
    static var forceRefreshInterval : TimeInterval { 3600.0 } // one hour forces a refresh

    var items : [Item]?
    var lastUpdate : Date?
    var error : String?

    var isExpired : Bool {
        guard let last = lastUpdate else { return true }
        return last.timeIntervalSinceNow < -Self.forceRefreshInterval
    }
}

final class WatchModel : NSObject, ObservableObject, WCSessionDelegate {
    @Published var status : SharedWatch?
    @Published var statusUpdated : Date?
    @Published var cockpitError : String?
    @Published var showFlightSubmitted = false
    @Published var totals = RemoteList<SimpleTotalItem>()
    @Published var recents = RemoteList<SimpleLogbookEntry>()
    @Published var currency = RemoteList<SimpleCurrencyItem>()

    private var session : WCSession?
    private var pendingUntilActivated = [() -> Void]()
    private let secureClasses : [AnyClass] = [NSArray.self, NSString.self, NSNumber.self, NSDate.self, SharedWatch.self, SimpleLogbookEntry.self, SimpleTotalItem.self, SimpleCurrencyItem.self]

    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    // MARK: - Cockpit
    func didBecomeActive() {
        if let s = session, s.activationState != .activated {
            s.activate()
        }
        requestStatus()
    }

    /// Asks the phone for the current status. The phone may answer with an empty reply (or be unreachable) right after launch, so retry a few times.
    func requestStatus(attempt : Int = 0) {
        send([WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_STATUS], reportUnreachable: false) { [weak self] reply in
            guard let self = self else { return }
            if !self.bindStatus(reply) && attempt < 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { self.requestStatus(attempt: attempt + 1) }
            }
        }
    }

    func startFlight() {
        sendAction(WATCH_ACTION_START)
    }

    func endFlight() {
        sendAction(WATCH_ACTION_END)
        showFlightSubmitted = true
    }

    func pausePlay() {
        sendAction(WATCH_ACTION_TOGGLE_PAUSE)
    }

    private func sendAction(_ action : String) {
        send([WATCH_MESSAGE_ACTION : action], reportUnreachable: false) { [weak self] reply in
            self?.bindStatus(reply)
        }
    }

    /// Elapsed seconds for the flight, extrapolated from the last update while the clock is running.
    func elapsedSeconds(at date : Date) -> Double {
        guard let s = status else { return 0 }
        var elapsed = s.elapsedSeconds
        if !s.isPaused && s.flightStage == .inprogress, let updated = statusUpdated {
            elapsed += date.timeIntervalSince(updated)
        }
        return elapsed
    }

    @discardableResult private func bindStatus(_ dict : [String : Any]) -> Bool {
        guard let data = dict[WATCH_RESPONSE_STATUS] as? Data, let s : SharedWatch = decode(data) else { return false }
        status = s
        statusUpdated = Date()
        return true
    }

    // MARK: - Lists
    func refreshTotals() {
        refresh(\.totals, request: WATCH_REQUEST_TOTALS, response: WATCH_RESPONSE_TOTALS)
    }

    func refreshRecents() {
        refresh(\.recents, request: WATCH_REQUEST_RECENTS, response: WATCH_RESPONSE_RECENTS)
    }

    func refreshCurrency() {
        refresh(\.currency, request: WATCH_REQUEST_CURRENCY, response: WATCH_RESPONSE_CURRENCY)
    }

    private func refresh<Item : NSObject>(_ keyPath : ReferenceWritableKeyPath<WatchModel, RemoteList<Item>>, request : String, response : String) {
        self[keyPath: keyPath].error = nil
        send([WATCH_MESSAGE_REQUEST_DATA : request], reportUnreachable: true, onError: { [weak self] message in
            self?[keyPath: keyPath].error = message
        }) { [weak self] reply in
            guard let self = self, let data = reply[response] as? Data else { return }
            if let items : [Item] = self.decode(data) {
                self[keyPath: keyPath] = RemoteList(items: items, lastUpdate: Date(), error: nil)
            }
        }
    }

    // MARK: - Messaging
    private func decode<T>(_ data : Data) -> T? {
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClasses: secureClasses, from: data) as? T
        } catch {
            NSLog("MFBWatch: Failed to unarchive \(T.self): \(error)")
            return nil
        }
    }

    /// Sends a request to the phone; replies and errors are delivered on the main queue.
    private func send(_ request : [String : String], reportUnreachable : Bool, onError : ((String) -> Void)? = nil, onReply : @escaping ([String : Any]) -> Void) {
        guard let session = session else { return }
        let fail = { (message : String) in
            NSLog("MFBWatch: \(message)")
            if let onError = onError {
                onError(message)
            } else {
                self.cockpitError = message
            }
        }

        if session.activationState != .activated {
            // Retry once activation completes.
            pendingUntilActivated.append { [weak self] in
                self?.send(request, reportUnreachable: reportUnreachable, onError: onError, onReply: onReply)
            }
            session.activate()
            return
        }

        guard session.isReachable else {
            if reportUnreachable {
                fail(NSLocalizedString("WatchNoReach", comment: "Watch - Unreachable"))
            }
            return
        }

        session.sendMessage(request, replyHandler: { reply in
            DispatchQueue.main.async { onReply(reply) }
        }, errorHandler: { error in
            DispatchQueue.main.async { fail(error.localizedDescription) }
        })
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            NSLog("MFBWatch: Error in activation of session: %@", error.localizedDescription)
        }
        DispatchQueue.main.async {
            guard activationState == .activated else { return }
            let pending = self.pendingUntilActivated
            self.pendingUntilActivated.removeAll()
            self.requestStatus()
            pending.forEach { $0() }
        }
    }

    // The phone is often not reachable yet when we first ask (e.g. at launch), so retry once it is.
    func sessionReachabilityDidChange(_ session: WCSession) {
        guard session.isReachable else { return }
        DispatchQueue.main.async {
            self.requestStatus()
            if self.totals.error != nil { self.refreshTotals() }
            if self.recents.error != nil { self.refreshRecents() }
            if self.currency.error != nil { self.refreshCurrency() }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        NSLog("MFBWatch: didReceiveApplicationContext")
        DispatchQueue.main.async {
            if session.isReachable {
                // The context may be stale (it is the last one the phone pushed, possibly from before this launch); ask for the current status.
                self.requestStatus()
            } else {
                self.bindStatus(applicationContext)
            }
        }
    }
}
