/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2025 MyFlightbook, LLC
 
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
//  MFBAppDelegate.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/20/23.
//

import Foundation
import WatchConnectivity
import WidgetKit

#if DEBUG
#warning("DEBUG BUILD")
#else
#warning("RELEASE BUILD")
#endif


@objc public protocol Invalidatable {
    @objc func invalidateViewController()
}

@objc public class MFBAppDelegate : NSObject, UIApplicationDelegate, WCSessionDelegate {
    private static let _szKeyHasSeenDisclaimer = "keySeenDisclaimer"
    private static let _szKeyPrefDebugMode = "keyDebugMode"
    
    @objc public var rgUnsubmittedFlights : NSMutableArray
    @objc public var mfbloc : MFBLocation
    @objc public var fDebugMode = false

    @objc public var watchData : SharedWatch? = nil
    
    private var notifyDataChanged : [Invalidatable] = []
    private var notifyResetAll : [Invalidatable] = []

    // Watch properties
    @objc public var watchSession : WCSession? = nil
    @objc public var fSuppressWatchNotification = false

    // MARK: Initialization
    @objc public override init() {
        mfbloc = MFBLocation(withGPS: true)
        rgUnsubmittedFlights = NSMutableArray()
        super.init()
        MFBAppDelegate._mainApp = self
        
        // Make sure that Network Management is started
        let _ = MFBNetworkManager.shared
    }
    
    // MARK: - connect to active scene
    public func getActiveScene() -> UIWindowScene? {
        return UIApplication.shared.connectedScenes.first as? UIWindowScene
    }
    
    public func getActiveSceneDelegate() -> SceneDelegate? {
        return (getActiveScene()?.delegate) as? SceneDelegate
    }
    
    public func getActiveTabBar() -> MFBTabBarController? {
        return getActiveSceneDelegate()?.tabBarController
    }
    
    // MARK: App life cycle
    @objc public func ensureWarningShownForUser(_ viewController : UIViewController) {
        let defs = UserDefaults.standard
        let szUser = MFBProfile.sharedProfile.UserName
        
        if szUser.isEmpty {
            return
        }
        
        let szUserWarning = defs.string(forKey: MFBAppDelegate._szKeyHasSeenDisclaimer) ?? ""
        
        if szUser.compare(szUserWarning) != .orderedSame {
            viewController.presentAlert(title: String(localized: "Important", comment:"Disclaimer warning message title"),
                                        message: String(localized: "Use of this during flight could be a distraction and could violate regulations, including 14 CFR 91.21 and 47 CFR 22.925.\r\nYou are responsible for the consequences of any use of this software.", comment: "Use in flight disclaimer"),
                                        buttonTitle: String(localized: "Accept", comment: "Disclaimer acceptance button title"),
                onOK: { uaa in
                defs.set(szUser, forKey: MFBAppDelegate._szKeyHasSeenDisclaimer)
                defs.synchronize()
            })
        }
    }

    
    // MARK: UIApplication delegate methods
    public func createLocManager() {
        mfbloc.restoreState()
        mfbloc.delegate = leProtocolHandler
    }
        
    static var _mainApp : MFBAppDelegate? = nil
    @objc public static var threadSafeAppDelegate : MFBAppDelegate {
        return _mainApp!    // should ALWAYS be non-nil
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("MyFlightbook: hello - launch, baseURL is %@", MFBHOSTNAME)
        
        MFBAppDelegate._mainApp = self;
        MFBTheme.setMFBTheme()
                      
        // Apple Watch support
        watchData = SharedWatch()
        let _ = setUpWatchSession()

        invalidateCachedTotals()
        
        return true
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        NSLog("MyFlightbook terminating")
        getActiveSceneDelegate()?.saveState()
        MFBSqlLite.closeDB()
        MFBAppDelegate._mainApp = nil
    }
    
    @objc func updateShortCutItems() {
        // Update 3D touch actions
        var rgShortcuts : [UIApplicationShortcutItem] = []
        
        if MFBProfile.sharedProfile.isValid() {
            // If a flight is in progress, add stop engine and pause/play as appropriate
            if leProtocolHandler.flightCouldBeInProgress() {
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.stopEngine",
                                                             localizedTitle: String(localized: "StopEngine", comment:"Shortcut - Stop Engine"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "stop.fill")))
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.blockIn",
                                                             localizedTitle: String(localized: "BlockInShortCut", comment: "Shortcut - Block In"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "stop.fill")))
                if leProtocolHandler.le.fIsPaused {
                    rgShortcuts.append(UIApplicationShortcutItem(type: "app.resume",
                                                                 localizedTitle: String(localized: "WatchPlay", comment: "Watch - Resume"),
                                                                 localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .play)))
                } else {
                    rgShortcuts.append(UIApplicationShortcutItem(type: "app.pause",
                                                                 localizedTitle: String(localized: "WatchPause", comment: "Watch - Pause"),
                                                                 localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .pause)))
                    
                }
            } else if leProtocolHandler.le.entryData.isKnownEngineEnd() || leProtocolHandler.le.entryData.isKnownBlockIn() {
                // completed flight waiting for submission
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.current",
                                                             localizedTitle: String(localized: "CurrentFlight", comment: "Shortcut - Current Flight"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "newflight.png")))
            } else {
                // flight not in progress but also not awaiting submission - just add start flight and block out
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.startEngine",
                                                             localizedTitle: String(localized: "StartEngine", comment: "Shortcut - Start Engine"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .play)))
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.blockOut",
                                                             localizedTitle: String(localized: "BlockOutShortcut", comment: "Shortcut - Block Out"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .play)))
            }
            
            rgShortcuts.append(UIApplicationShortcutItem(type: "app.currency",
                                                         localizedTitle: String(localized: "Currency", comment: "Shortcut Currency"),
                                                         localizedSubtitle: "",
                                                         icon: UIApplicationShortcutIcon(systemImageName: "currency.png")
                                                        ))
            
            rgShortcuts.append(UIApplicationShortcutItem(type: "app.totals",
                                                         localizedTitle: String(localized: "Totals", comment: "Shortcut Totals"),
                                                         localizedSubtitle: "",
                                                         icon: UIApplicationShortcutIcon(systemImageName: "totals.png")
                                                        ))
        }
        
        UIApplication.shared.shortcutItems = rgShortcuts
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("Entered Background")
        
        // To save power, stop receiving updates if we don't need them.
        let up = UserPreferences.current
        let fAutoDetect = up.autodetectTakeoffs
        let fRecord = up.recordTelemetry
        
        if ((!fAutoDetect && !fRecord) || !leProtocolHandler.flightCouldBeInProgress()) {
            mfbloc.stopUpdatingLocation()
        }

        updateShortCutItems()
    }
    
    public func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("Entered foreground")
        
        MFBAppDelegate._mainApp = self
        // ALWAYS start updating location in foreground
        mfbloc.startUpdatingLocation()
        
        let _ = setUpWatchSession()
        
        // Launch any refresh tasks, but don't wait for response
        let aircraft = Aircraft.sharedAircraft
        if aircraft.cacheStatus(MFBProfile.sharedProfile.AuthToken) != .valid && MFBNetworkManager.shared.isOnLine {
            Thread.detachNewThread {
                aircraft.refreshIfNeeded()
            }
        }
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        MFBAppDelegate._mainApp = self
        NSLog("ApplicationDidBecomeActive\r\n");
        
        UserPreferences.invalidate() // reload preferences - they may have changed externally.

        // restore the state of recording data.
        createLocManager()
        
    #if DEBUG
        fDebugMode = UserDefaults.standard.bool(forKey: MFBAppDelegate._szKeyPrefDebugMode)
    #else
        fDebugMode = false
    #endif
        
        if mfbloc.isLocationServicesEnabled {
            // we could be stopped, in which case an update will have zero speed and be rejected
            // so clear currentloc.  This will cause it to be stored, which is enough
            // to initialize with and work with nearest.
            // self.mfbloc.currentLoc = nil;
            // force an updated location to be sent.
            mfbloc.stopUpdatingLocation()
            mfbloc.startUpdatingLocation()
        }

        HTTPCookieStorage.shared.loadFromUserDefaults()   // sync any cookies.

        // refreah authtoken if needed and if online with a valid profile
        if !MFBProfile.sharedProfile.UserName.isEmpty && MFBNetworkManager.shared.isOnLine {
            MFBProfile.sharedProfile.RefreshAuthToken()
        }
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
    
    // MARK: Object Lifecycle
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Misc.
    var leProtocolHandler : LEControllerProtocol {
        return getActiveTabBar()!.leMain as! LEControllerProtocol  // this should always succeed; bad juju if not.
    }
    
    @objc public func registerNotifyDataChanged(_ sender : Invalidatable) {
        notifyDataChanged.append(sender)
    }
    
    @objc public func registerNotifyResetAll(_ sender : Invalidatable) {
        notifyResetAll.append(sender)
    }
    
    @objc public func invalidateAll() {
        // only call this on the main thread, so shunt other calls over there.
        if Thread.isMainThread {
            for vc in notifyResetAll {
                vc.invalidateViewController()
            }
        } else {
            performSelector(onMainThread: #selector(invalidateAll), with: self, waitUntilDone: false)
        }
    }
    
    @objc public func invalidateCachedTotals() {
        for vc in notifyDataChanged {
            vc.invalidateViewController()
        }
    }
    
    // MARK: Unsubmitted Flights
    @objc func setBadgeCount() {
        let cUnsubmittedFlights = rgUnsubmittedFlights.count
        getActiveTabBar()?.tbiRecent?.badgeValue = (cUnsubmittedFlights == 0) ? nil : String(format: "%ld", cUnsubmittedFlights)
        UIApplication.shared.applicationIconBadgeNumber = cUnsubmittedFlights
    }
    
    @objc public func addBadgeForUnsubmittedFlights() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.badgeSetting == .enabled {
                self.performSelector(onMainThread: #selector(self.setBadgeCount), with: nil, waitUntilDone: false)
            }
            else if self.rgUnsubmittedFlights.count > 0 {
                // Request notification permission to show the badge for unsubmitted flights.
                UNUserNotificationCenter.current().requestAuthorization(options: .badge) {granted, err in
                    if granted {
                        self.performSelector(onMainThread: #selector(self.setBadgeCount), with: nil, waitUntilDone: false)
                    }
                }
            }
        }
    }
    
    @objc public func queueFlightForLater(_ le : LogbookEntry) {
        if !rgUnsubmittedFlights.contains(le) {
            rgUnsubmittedFlights.add(le)
            invalidateCachedTotals()
            getActiveSceneDelegate()?.saveState()
            performSelector(onMainThread: #selector(addBadgeForUnsubmittedFlights), with: nil, waitUntilDone: false)
        }
    }
    
    @objc public func dequeueUnsubmittedFlight(_ le : LogbookEntry) {
        rgUnsubmittedFlights.remove(le)
        // force a reload
        invalidateCachedTotals()
        getActiveSceneDelegate()?.saveState()
        performSelector(onMainThread: #selector(addBadgeForUnsubmittedFlights), with: nil, waitUntilDone: false)
    }
    
    // MARK: Watchkit
    // define the minimum interval between watch context updates
    let WATCHKIT_CONTEXT_UPDATE_MIN_PERIOD = 1.0
    
    @objc public func updateWatchContext() {
        if fSuppressWatchNotification || watchSession == nil {
            return;
        }

        let ws = watchSession!  // we know it's non-nill by here.
        
        // Check that:
        // a) we have a session (or that it successfully initializes)
        // b) we are paired
        // c) app is installed
        if !ws.isPaired || !ws.isReachable || !ws.isWatchAppInstalled {
    //        NSLog("MFBWatch: no session, not paired, not reachable, or not installed")
            return
        }
        
        if ws.activationState != .activated {
            ws.activate()
        }

        if ws.activationState != .activated {
    //        NSLog(@"MFBWatch - session no longer activated!!");
            return
        }
        
        NSLog("MFBWatch: (iOS): Updating watch context")

        // self.watchSesion should not be nil here
        do {
            try ws.updateApplicationContext(replyForMessage([WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_STATUS]))
        }
        catch {
            NSLog("MFBWatch: (iOS): Error updating watch: %@", error.localizedDescription)
        }
    }

    func setUpWatchSession() -> WCSession? {
        fSuppressWatchNotification = false
        if !WCSession.isSupported() {
            return nil
        }
        if (watchSession == nil) {
            watchSession = WCSession.default
        }
        
        watchSession!.delegate = self
        
        // Activate the session if (a) it responds to activateSession AND (EITHER it doesn't respond to ActivationState OR it isn't activated)
        if watchSession!.responds(to: #selector(WCSession.activate)) &&
            (!watchSession!.responds(to: #selector(getter: WCSession.activationState)) || watchSession!.activationState != .activated) {
            watchSession!.activate()
        }
        
        return watchSession
    }
    
    func refreshRecents() -> [SimpleLogbookEntry] {
        let ar = SynchronousCalls().recents(forUserSynchronous: MFBProfile.sharedProfile.AuthToken) ?? []
        if !ar.isEmpty {
            watchData?.latestFlight = ar[0]
        }
        return ar
    }
    
    private var bgTask = UIBackgroundTaskIdentifier.invalid
    
    public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
        NSLog("handleWatchKitExtensionRequest called")

        bgTask = application.beginBackgroundTask(withName: "myTask") {
            application.endBackgroundTask(self.bgTask)
            self.bgTask = .invalid
        }

        DispatchQueue.main.async {
            // Do the work associated with the task, preferably in chunks.
            reply(self.replyForMessage(userInfo))
            application.endBackgroundTask(self.bgTask)
            self.bgTask = .invalid
        }
    }
    
    func replyForMessage(_ message : [AnyHashable : Any]?) -> [String : Any] {
        let request = message?[WATCH_MESSAGE_REQUEST_DATA]
        var dictResponse : [String : Any] = [:]
        
        if request != nil {
            do {
                // request for data
                switch request as? String {
                case WATCH_REQUEST_STATUS:
                    dictResponse[WATCH_RESPONSE_STATUS] = try NSKeyedArchiver.archivedData(withRootObject: watchData!, requiringSecureCoding: true)
                case WATCH_REQUEST_CURRENCY:
                    dictResponse[WATCH_RESPONSE_CURRENCY] = try NSKeyedArchiver.archivedData(withRootObject: SynchronousCalls().currency(forUserSynchronous: MFBProfile.sharedProfile.AuthToken)!, requiringSecureCoding: true)
                case WATCH_REQUEST_TOTALS:
                    dictResponse[WATCH_RESPONSE_TOTALS] = try NSKeyedArchiver.archivedData(withRootObject: SynchronousCalls().totals(forUserSynchronous: MFBProfile.sharedProfile.AuthToken)!, requiringSecureCoding: true)
                case WATCH_REQUEST_RECENTS:
                    dictResponse[WATCH_RESPONSE_RECENTS] = try NSKeyedArchiver.archivedData(withRootObject: refreshRecents(), requiringSecureCoding:true)
                default:
                    break;
                }
            } catch {
                NSLog("Error in request for data from the watch: \(error.localizedDescription)")
            }
        } else if let request = message?[WATCH_MESSAGE_ACTION] as? String {
            fSuppressWatchNotification = true  // don't allow any outbound messages while we are refreshing here.
            
            NSLog("Action requested - %@...", request)
            
            let group = DispatchGroup()
            group.enter()
            
            // we may be called on a background thread, but the actions below must be on main.
            DispatchQueue.main.async {
                switch request {
                case WATCH_ACTION_START:
                    self.mfbloc.startUpdatingLocation()
                    self.leProtocolHandler.startEngineExternal()
                case WATCH_ACTION_END:
                    self.leProtocolHandler.stopEngineExternal()
                case WATCH_ACTION_TOGGLE_PAUSE:
                    self.leProtocolHandler.toggleFlightPause()
                default:
                    break;
                }
                NSLog("Action request complete")
                
                group.leave()
            }
            
            group.wait()
            
            do {
                dictResponse[WATCH_RESPONSE_STATUS] = try NSKeyedArchiver.archivedData(withRootObject: watchData!, requiringSecureCoding: true)
            } catch {
                NSLog("Error in action request  for data from the watch: \(error.localizedDescription)")
            }
            self.fSuppressWatchNotification = false
            
            performSelector(onMainThread: #selector(updateShortCutItems), with: nil, waitUntilDone: false)
        }
        
        return dictResponse
    }
    
    public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("didReceiveMessage called")
        if (!session.isPaired || !session.isReachable) {
            NSLog("Session is %@paired, %@reachable", session.isPaired ? "" : "NOT ", session.isReachable ? "" : "NOT ")
            replyHandler([:])
        } else {
            replyHandler(replyForMessage(message))
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        watchSession = session;
        if (error != nil) {
            NSLog("MFBWatch: Error activating session: %@", error!.localizedDescription)
        }
        
        // update status
        if (watchSession?.isReachable ?? false) {
            updateWatchContext()
        }
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("MFBWatch: Session is inactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        NSLog("MFBWatch: Session deactivated");
    }
}
