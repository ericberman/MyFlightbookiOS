/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2023 MyFlightbook, LLC
 
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

@objc public class MFBAppDelegate : NSObject, UIApplicationDelegate, UITabBarControllerDelegate, WCSessionDelegate {    
    private static let _szKeySelectedTab = "_prefSelectedTab"
    private static let _szKeyTabOrder = "keyTabOrder2"
    private static let _szNewFlightTitle = "newFlight"
    private static let _szMyAircraftTitle = "MyAircraft"
    private static let _szProfileTitle = "Profile"
    private static let _szNearestTitle = "Nearest"
    private static let _szMoreTitle = "More"
    private static let _szKeyHasSeenDisclaimer = "keySeenDisclaimer"
    private static let _szKeyPrefUnsubmittedFlights = "keyPendingFlights"
    private static let _szKeyPrefLastInstalledVersion = "keyLastVersion"
    private static let _szKeyPrefDebugMode = "keyDebugMode"
    
    private static var urlLaunchURL : URL? = nil
    private static var fAppLaunchFinished = false
    
    @objc public var rgUnsubmittedFlights : NSMutableArray
    @objc public var mfbloc : MFBLocation
    @objc public var fDebugMode = false

    @IBOutlet weak public var window : UIWindow?
    @IBOutlet weak var tabBarController : UITabBarController!
    @IBOutlet weak var leMain : UITableViewController!
    @IBOutlet weak var tabNewFlight : UINavigationController!
    @IBOutlet weak var tabRecents : UINavigationController!
    @IBOutlet weak var tabProfile : UINavigationController!
    @IBOutlet weak var tabTotals : UINavigationController!
    @IBOutlet weak var tabCurrency : UINavigationController!
    @IBOutlet weak var tbiRecent : UITabBarItem!

    @objc public var watchData : SharedWatch? = nil
    
    @objc public var timerSyncState : Timer? = nil

    @objc public var notifyDataChanged : [Invalidatable] = []
    @objc public var notifyResetAll : [Invalidatable] = []
    @objc public var progressAlert : UIAlertController? = nil

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
            
    // MARK: Tab management
    private func checkNoAircraft() -> Bool {
        return (Aircraft.sharedAircraft.rgAircraftForUser ?? []).isEmpty
    }
    
    // returns the index of the default tab to select
    // if the user has airplanes, it's
    private func defaultTab() -> UIViewController {
        return MFBProfile.sharedProfile.isValid() ? tabNewFlight! : tabProfile!
    }

    private func setCustomizableViewControllers() {
        tabBarController!.customizableViewControllers = tabBarController.viewControllers
    }
    
    @objc public func DefaultPage()  {
        tabBarController!.selectedViewController = defaultTab()
    }
    
    // MARK: Save State
    private func saveTabState() {
        // Remember the last-used tab, but not if it is the "More" tab (button #5)
        let i = tabBarController!.selectedIndex
        
        let def = UserDefaults.standard

        // if iPad, override the above line - we can store any saved tab
        if UIDevice.current.userInterfaceIdiom == .pad {
            def.set(i, forKey: MFBAppDelegate._szKeySelectedTab)
        } else {
            def.set(i < 4 ? i : 0, forKey: MFBAppDelegate._szKeySelectedTab)
        }
        def.synchronize()
    }
    
    
    @objc private func saveState() {
        if !checkNoAircraft() {
            leProtocolHandler.saveState()
        }

        if Thread.isMainThread {
            saveTabState()
        } else {
            performSelector(onMainThread: #selector(saveState), with: nil, waitUntilDone: false)
        }

        let def = UserDefaults.standard
        // remember whether or not we were flying and recording flight data.
        mfbloc.saveState()
        try! def.set(NSKeyedArchiver.archivedData(withRootObject: rgUnsubmittedFlights, requiringSecureCoding: true), forKey: MFBAppDelegate._szKeyPrefUnsubmittedFlights)
        def.synchronize()
        NSLog("saveState - done and synchronized")
    }
                
    // MARK: App life cycle
    @objc public func ensureWarningShownForUser() {
        let defs = UserDefaults.standard
        let szUser = MFBProfile.sharedProfile.UserName
        
        if szUser.isEmpty {
            return
        }
        
        let szUserWarning = defs.string(forKey: MFBAppDelegate._szKeyHasSeenDisclaimer) ?? ""
        
        if szUser.compare(szUserWarning) != .orderedSame {
            WPSAlertController.presentOkayAlertWithTitle(String(localized: "Important", comment:"Disclaimer warning message title"),
                                                         message: String(localized: "Use of this during flight could be a distraction and could violate regulations, including 14 CFR 91.21 and 47 CFR 22.925.\r\nYou are responsible for the consequences of any use of this software.", comment: "Use in flight disclaimer"),
                                                         button: String(localized: "Accept", comment: "Disclaimer acceptance button title"))
            
            defs.set(szUser, forKey: MFBAppDelegate._szKeyHasSeenDisclaimer)
            defs.synchronize()
        }
    }
    
    @objc public func openURL(_ url : URL) {
        if (url.isFileURL) {
            NSLog("Loaded with URL: %@", url.absoluteString)
            tabBarController!.selectedViewController = tabRecents
            recentsView.addTelemetryFlight(url)
        }
        else if (url.host != nil) {
            let host = url.host!
            switch host {
            case "addFlights":
                var szJSON = url.path
                if !szJSON.isEmpty {
                    szJSON = String(szJSON[szJSON.index(szJSON.startIndex, offsetBy: 1)..<szJSON.endIndex]) as String
                }
                
                if !szJSON.isEmpty && szJSON.hasPrefix("{") {
                    tabBarController?.selectedViewController = tabRecents
                    recentsView.addJSONFlight(szJSON)
                }
            case "totals":
                tabBarController!.selectedViewController = tabTotals
            case "currency":
                tabBarController!.selectedViewController = tabCurrency
            case "newflight":
                tabBarController!.selectedViewController = tabNewFlight
            case "app.startEngine":
                leProtocolHandler.startEngineExternal()
            case "app.stopEngine":
                leProtocolHandler.stopEngineExternalNoSubmit()
            case "app.startFlight":
                leProtocolHandler.startFlightExternal()
            case "app.stopFlight":
                leProtocolHandler.stopFlightExternal()
            case "app.blockOut":
                leProtocolHandler.blockOutExternal()
            case "app.blockIn":
                leProtocolHandler.blockInExternal()
            case "app.resume":
                leProtocolHandler.resumeFlightExternal()
            case "app.pause":
                leProtocolHandler.pauseFlightExternal()
            case "app.togglePause":
                leProtocolHandler.toggleFlightPause()
            default:
                break
            }
        }
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "app.currency":
            if (MFBAppDelegate.fAppLaunchFinished) {
                tabBarController!.selectedViewController = tabCurrency
            } else {
                MFBAppDelegate.urlLaunchURL = URL(string: "myflightbook://currency")
            }
        case "app.totals":
            if (MFBAppDelegate.fAppLaunchFinished) {
                tabBarController!.selectedViewController = tabTotals
            } else {
                MFBAppDelegate.urlLaunchURL = URL(string: "myflightbook://totals")
            }
        case "app.current":
            if (MFBAppDelegate.fAppLaunchFinished) {
                tabBarController!.selectedViewController = tabNewFlight
            } else {
                MFBAppDelegate.urlLaunchURL = URL(string: "myflightbook://newflight")
            }
        case "app.startEngine":
            leProtocolHandler.startEngineExternal()
        case "app.stopEngine":
            leProtocolHandler.stopEngineExternalNoSubmit()
        case "app.resume", "app.pause":
            leProtocolHandler.toggleFlightPause()
        default:
            completionHandler(false)
            return
        }
        completionHandler(true)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("application:openURL: with %@, %@", url.absoluteString, MFBAppDelegate.fAppLaunchFinished ? "app launch is finished, opening" : "Queueing to open when launch is finished.")
        if (MFBAppDelegate.fAppLaunchFinished) {
            openURL(url)
        } else {
            MFBAppDelegate.urlLaunchURL = url
        }
        return true
    }
    
    // MARK: UIApplication delegate methods
    func createLocManager() {
        mfbloc.restoreState()
        mfbloc.delegate = leProtocolHandler
    }
    
    /*
     OBSOLETE - now doing this directly in iRate
     + (void) initialize
     {
         [iRate sharedInstance].eventsUntilPrompt = MIN_IRATE_EVENTS;
         [iRate sharedInstance].usesUntilPrompt = MIN_IRATE_USES;
         [iRate sharedInstance].daysUntilPrompt = MIN_IRATE_DAYS;
         [iRate sharedInstance].verboseLogging = YES;
         [iRate sharedInstance].ratingsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/myflightbook/id%d?mt=8&action=write-review", _appStoreID]];
     }
     */
    
    static var _mainApp : MFBAppDelegate? = nil
    @objc public static var threadSafeAppDelegate : MFBAppDelegate {
        return _mainApp!    // should ALWAYS be non-nil
    }
    
    /*
     OBSOLETE - version 1.85 was ancient history...
     - (void) upgradeOldVersion {
         NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
         
         // Check for any upgrades that are needed.
         NSNumberFormatter * nf = [NSNumberFormatter new];
         [nf setDecimalSeparator:@"."]; // CFBundleVersion ALWAYS uses a decimal
         NSString * szCurVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
         double curVer = [[nf numberFromString:[szCurVer substringToIndex:3]] doubleValue];
         double lastVer = [defs doubleForKey:_szKeyPrefLastInstalledVersion];

         // post-1.85, cached imageinfo has fullURL;
         // ensure we reload aircraft, so images work
         if (lastVer <= 1.85)
         {
             NSLog(@"Last ver (%f) < 1.85, curVer = %f, invalidating cached aircraft", lastVer, curVer);
             [[Aircraft sharedAircraft] invalidateCachedAircraft];
             [self invalidateCachedTotals];
         }
         // don't do any upgrades next time.
         if (lastVer < curVer)
         {
             [defs setDouble:curVer forKey:_szKeyPrefLastInstalledVersion];
             [defs synchronize];
         }
     }
     */
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NSLog("MyFlightbook: hello - launch, baseURL is %@", MFBHOSTNAME)
        
        MFBAppDelegate._mainApp = self;
        MFBTheme.setMFBTheme()
        
        tabBarController!.moreNavigationController.navigationBar.tintColor = MFBTheme.MFBBrandColor()
        
        if let w = window {
            w.makeKeyAndVisible()
            w.frame = UIScreen.main.bounds
            w.rootViewController = tabBarController
            progressAlert = WPSAlertController.presentProgressAlertWithTitle(String(localized: "Loading; please wait...", comment:"Status message at app startup"),
                                                                             onViewController: tabBarController)
        }
        
        createLocManager()
        
        mfbloc.cSamplesSinceWaking = 0
        mfbloc.fRecordingIsPaused = false
                
        // Ensure that a profile object is set up
        let _ = MFBProfile.sharedProfile;
        
        // Apple Watch support
        watchData = SharedWatch()
        let _ = setUpWatchSession()
        
        leMain!.view = leMain!.view // force view to load to ensure it is valid.  Also initializes for shared watch.
        
        //        [self upgradeOldVersion];
        
        invalidateCachedTotals()
        
        // recover unsubmitted flights (for count to add to recent-flights tab)
        if let ar = UserDefaults.standard.object(forKey: MFBAppDelegate._szKeyPrefUnsubmittedFlights) as? Data {
            try! rgUnsubmittedFlights = NSMutableArray(array: NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self, NSNumber.self, NSMutableString.self, LogbookEntry.self, MFBWebServiceSvc_PendingFlight.self, MFBWebServiceSvc_LogbookEntry.self],
                                                                                            from: ar) as! NSArray)
        }
        
        // set a badge for the # of unsubmitted flights.
        addBadgeForUnsubmittedFlights()
        
        // reload persisted state of tabs, if needed.
        
        if let rgPresistedTabs = UserDefaults.standard.object(forKey: MFBAppDelegate._szKeyTabOrder) as? [String] {
            let controllers = tabBarController!.viewControllers!
            var rg : [UIViewController] = []
            
            for szTitle in rgPresistedTabs {
                // find the view with this title in the viewcontrollers array
                if let vw = controllers.first(where: { vc in
                    return vc.title == szTitle
                }) {
                    rg.append(vw)
                }
            }
            
            // if somehow things didn't mesh up, don't try to restore the tabs!!!
            if rg.count == controllers.count {
                tabBarController?.viewControllers = rg
            }
            setCustomizableViewControllers()
        }
        
        var rgImages = Array(leProtocolHandler.le.rgPicsForFlight)

        // Now get any additional images
        for lbe in self.rgUnsubmittedFlights as! [LogbookEntry] {
            rgImages.append(contentsOf: lbe.rgPicsForFlight)
        }
        CommentedImage.cleanupObsoleteFiles(rgImages as! [CommentedImage])
        
        // set a timer to save state every 5 minutes or so
        timerSyncState = Timer(fireAt: Date.init(timeIntervalSinceNow: 300),
                               interval: 300,
                               target: self,
                               selector: #selector(saveState),
                               userInfo: nil,
                               repeats: true)

        RunLoop.current.add(timerSyncState!, forMode: .default)
        
        ensureWarningShownForUser()

        if progressAlert != nil {
            tabBarController?.dismiss(animated: true, completion: {
                if MFBProfile.sharedProfile.isValid() {
                    let iTab = UserDefaults.standard.integer(forKey: MFBAppDelegate._szKeySelectedTab)
                    if (iTab == 0 && self.checkNoAircraft()) {
                        self.DefaultPage()
                    } else {
                        self.tabBarController!.selectedIndex = iTab
                    }
                } else {
                    self.tabBarController!.selectedViewController = self.tabProfile
                }
                
                MFBAppDelegate.fAppLaunchFinished = true
                if MFBAppDelegate.urlLaunchURL != nil {
                    NSLog("Opening URL from AppDidFinishLaunching")
                    self.openURL(MFBAppDelegate.urlLaunchURL!)
                    MFBAppDelegate.urlLaunchURL = nil
                }
            })
            progressAlert = nil
        }
        
        // set the default in-the-cockpit values.
        let up = UserPreferences.current;
        UserDefaults.standard.register(defaults: [up.keyShowHobbs : true,
                                                  up.keyShowEngine : true,
                                                  up.keyShowFlight : true,
                                                  up.keyShowImages : false])  // images are really a "hide images" flag for backwards compatibility.

        return true
    }
    
    public func applicationWillTerminate(_ application: UIApplication) {
        NSLog("MyFlightbook terminating")
        saveState()
        MFBSqlLite.closeDB()
        MFBAppDelegate._mainApp = nil
    }
    
    @objc public func updateShortCutItems() {
        // Update 3D touch actions
        var rgShortcuts : [UIApplicationShortcutItem] = []
        
        if MFBProfile.sharedProfile.isValid() {
            // If a flight is in progress, add stop engine and pause/play as appropriate
            if leProtocolHandler.flightCouldBeInProgress() {
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.stopEngine",
                                                             localizedTitle: String(localized: "StopEngine", comment:"Shortcut - Stop Engine"),
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
            } else if !leProtocolHandler.le.entryData.isKnownEngineEnd() {
                // flight not in progress - just add start flight
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.startEngine",
                                                             localizedTitle: String(localized: "StartEngine", comment: "Shortcut - Start Engine"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .play)))
            } else {
                // completed flight waiting for submission
                rgShortcuts.append(UIApplicationShortcutItem(type: "app.current",
                                                             localizedTitle: String(localized: "CurrentFlight", comment: "Shortcut - Current Flight"),
                                                             localizedSubtitle: "", icon: UIApplicationShortcutIcon(systemImageName: "newflight.png")))
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
    
    public func applicationWillResignActive(_ application: UIApplication) {
        saveState()
        HTTPCookieStorage.shared.saveToUserDefaults()     // save any cookies.
        WidgetCenter.shared.reloadAllTimelines()    // in case anything changed, force the widgets to reload.
    }
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
    
    // MARK: TabBarController delegate
    public func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        if (changed) {
            // we would get each of the views, in order, but not all of the views have been loaded.
            // hence, we cannot rely on their titles.
            // Instead, we will get the tags of the first few tab bar items, and pad out the list with the leftovers.
            // Get the titles of the views, in their current order
            var rgIndices : [String] = []

            for vw in tabBarController.viewControllers! {
                let szTitle = vw.title;
                if (szTitle == nil) {
                    NSLog("Can't persist tabs with a nil title")
                    return
                }
                rgIndices.append(szTitle!)
            }
            
            UserDefaults.standard.set(rgIndices, forKey: MFBAppDelegate._szKeyTabOrder)
            UserDefaults.standard.synchronize()

            setCustomizableViewControllers()
        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == tabNewFlight && checkNoAircraft() {
            WPSAlertController.presentOkayAlertWithTitle(String(localized: "No Aircraft", comment: "Title for No Aircraft error"),
                                                         message: String(localized: "You must set up at least one aircraft before you can enter flights", comment: "No aircraft error message"))
        }
        
        return true
    }
    
    // MARK: Object Lifecycle
    deinit {
        timerSyncState?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Misc.
    var recentsView : RecentFlightsProtocol {
        let rf = tabRecents!.viewControllers.first! // definitely want to crash if this is null!
        if !rf.isViewLoaded {   // force the view to load if needed.
            var v = rf.view
            if (v != nil) {
                v = nil
            }
        }
        return rf as! RecentFlightsProtocol
    }
    
    var leProtocolHandler : LEControllerProtocol {
        return leMain as! LEControllerProtocol  // this should always succeed; bad juju if not.
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
        if tbiRecent != nil {
            self.tbiRecent!.badgeValue = (cUnsubmittedFlights == 0) ? nil : String(format: "%ld", cUnsubmittedFlights)
        }
        UIApplication.shared.applicationIconBadgeNumber = cUnsubmittedFlights
    }
    
    @objc func addBadgeForUnsubmittedFlights() {
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
            saveState()
            performSelector(onMainThread: #selector(addBadgeForUnsubmittedFlights), with: nil, waitUntilDone: false)
        }
    }
    
    @objc public func dequeueUnsubmittedFlight(_ le : LogbookEntry) {
        rgUnsubmittedFlights.remove(le)
        // force a reload
        invalidateCachedTotals()
        saveState()
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
