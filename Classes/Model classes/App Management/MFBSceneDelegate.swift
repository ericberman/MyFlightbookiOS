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
//  MFBSceneDelegate.swift
//  MFBSample
//
//  Created by Eric Berman on 9/21/25.
//

import WatchConnectivity
import WidgetKit

public class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate {

    public var window : UIWindow?
    public var tabBarController : MFBTabBarController!
    public var timerSyncState : Timer? = nil
    var progressAlert : UIAlertController? = nil

    private static let _szKeySelectedTab = "_prefSelectedTab"
    private static let _szKeyTabOrder = "keyTabOrder2"
    public static let _szKeyPrefUnsubmittedFlights = "keyPendingFlights"
    
    var recentsView : RecentFlightsProtocol {
        let rf = tabBarController!.tabRecents!.viewControllers.first! // definitely want to crash if this is null!
        if !rf.isViewLoaded {   // force the view to load if needed.
            var v = rf.view
            if (v != nil) {
                v = nil
            }
        }
        return rf as! RecentFlightsProtocol
    }
    
    // MARK: - Scene stuff

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
  
        // Load the correct XIB (iPad vs iPhone)
        let nibName = UIDevice.current.userInterfaceIdiom == .pad ? "MainWindow-iPad" : "MainWindow"
        let nibObjects = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)

        // Grab your tab bar controller from the nib
        guard let tc = nibObjects?.first(where: { $0 is MFBTabBarController }) as? MFBTabBarController else {
            fatalError("Could not load MFBTabBarController from \(nibName).xib")
        }
        
        tabBarController = tc
        tabBarController.moreNavigationController.navigationBar.tintColor = MFBTheme.MFBBrandColor()
        setCustomizableViewControllers()
        tabBarController.delegate = self
            
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
        
        setCustomizableViewControllers()
        
        progressAlert = WPSAlertController.presentProgressAlertWithTitle(String(localized: "Loading; please wait...", comment:"Status message at app startup"),                                                                             onViewController: tabBarController)
        // reload persisted state of tabs, if needed.
        if let rgPresistedTabs = UserDefaults.standard.object(forKey: SceneDelegate._szKeyTabOrder) as? [String] {
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
                tabBarController.viewControllers = rg
            }
            setCustomizableViewControllers()
        }
        
        // recover unsubmitted flights (for count to add to recent-flights tab)
        if let ar = UserDefaults.standard.object(forKey: SceneDelegate._szKeyPrefUnsubmittedFlights) as? Data {
            try! MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights = NSMutableArray(array: NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSString.self, NSNumber.self, NSMutableString.self, LogbookEntry.self, MFBWebServiceSvc_PendingFlight.self, MFBWebServiceSvc_LogbookEntry.self],
                                                                                            from: ar) as! NSArray)
        }

        let app = MFBAppDelegate.threadSafeAppDelegate
        app.ensureWarningShownForUser()
        
        app.createLocManager()
        
        app.mfbloc.cSamplesSinceWaking = 0
        app.mfbloc.fRecordingIsPaused = false
                
        // Ensure that a profile object is set up
        let _ = MFBProfile.sharedProfile;
                
        let leMain = tabBarController.leMain;
        leMain!.view = leMain!.view // force view to load to ensure it is valid.  Also initializes for shared watch.
        
        // set a badge for the # of unsubmitted flights.
        app.addBadgeForUnsubmittedFlights()
        
        var rgImages = Array(leProtocolHandler.le.rgPicsForFlight)

        // Now get any additional images
        for lbe in MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights as! [LogbookEntry] {
            rgImages.append(contentsOf: lbe.rgPicsForFlight)
        }
        CommentedImage.cleanupObsoleteFiles(rgImages as! [CommentedImage])
        
        if progressAlert != nil {
            tabBarController?.dismiss(animated: true, completion: {
                if MFBProfile.sharedProfile.isValid() {
                    let iTab = UserDefaults.standard.integer(forKey: SceneDelegate._szKeySelectedTab)
                    if (iTab == 0 && self.checkNoAircraft()) {
                        self.DefaultPage()
                    } else {
                        self.tabBarController!.selectedIndex = iTab
                    }
                } else {
                    self.tabBarController!.selectedViewController = self.tabBarController.tabProfile
                }
                
            })
            progressAlert = nil
        }
    }
    
    // Programmatic alternative to set up tabs, but this is not yet localized
    /*
    func setupTabBarController() -> MFBTabBarController {
        let tc = MFBTabBarController()

        // MARK: - Create each tab
        let newFlightVC = LEEditController(nibName: "LEEditController", bundle: nil)
        let navNewFlight = UINavigationController(rootViewController: newFlightVC)
        navNewFlight.tabBarItem = UITabBarItem(title: "New Flight", image: UIImage(named: "newflight.png"), selectedImage: nil)

        let recentVC = RecentFlights(nibName: "RecentFlights", bundle: nil)
        let navRecent = UINavigationController(rootViewController: recentVC)
        navRecent.tabBarItem = UITabBarItem(tabBarSystemItem: .recents, tag: 1)

        let myAircraftVC = MyAircraft(nibName: "MyAircraft", bundle: nil)
        let navMyAircraft = UINavigationController(rootViewController: myAircraftVC)
        navMyAircraft.tabBarItem = UITabBarItem(title: "My Aircraft", image: UIImage(named: "aircraft.png"), selectedImage: nil)

        let profileVC = SignInControllerViewController(nibName: "SignInControllerViewController", bundle: nil)
        let navProfile = UINavigationController(rootViewController: profileVC)
        navProfile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile.png"), selectedImage: nil)

        let totalsVC = Totals(nibName: "Totals", bundle: nil)
        let navTotals = UINavigationController(rootViewController: totalsVC)
        navTotals.tabBarItem = UITabBarItem(title: "Totals", image: UIImage(named: "totals.png"), selectedImage: nil)

        let currencyVC = Currency(nibName: "Currency", bundle: nil)
        let navCurrency = UINavigationController(rootViewController: currencyVC)
        navCurrency.tabBarItem = UITabBarItem(title: "Currency", image: UIImage(named: "currency.png"), selectedImage: nil)

        let nearestVC = NearbyAirports(nibName: "NearbyAirports", bundle: nil)
        let navNearest = UINavigationController(rootViewController: nearestVC)
        navNearest.tabBarItem = UITabBarItem(title: "Nearest", image: UIImage(named: "runway.png"), selectedImage: nil)

        let visitedVC = VisitedAirports(nibName: "VisitedAirports", bundle: nil)
        let navVisited = UINavigationController(rootViewController: visitedVC)
        navVisited.tabBarItem = UITabBarItem(title: "Visited", image: UIImage(named: "airporttab.png"), selectedImage: nil)

        let trainingVC = Training(nibName: "Training", bundle: nil)
        let navTraining = UINavigationController(rootViewController: trainingVC)
        navTraining.tabBarItem = UITabBarItem(title: "Training", image: UIImage(named: "training.png"), selectedImage: nil)

        // MARK: - Strong references in tab bar controller
        tc.leMain = newFlightVC
        tc.tabNewFlight = navNewFlight
        tc.tabRecents = navRecent
        tc.tbiRecent = navRecent.tabBarItem
        tc.tabProfile = navProfile
        tc.tabTotals = navTotals
        tc.tabCurrency = navCurrency

        // Assign all view controllers
        tc.viewControllers = [
            navNewFlight, navRecent, navMyAircraft, navProfile,
            navTotals, navCurrency, navNearest, navVisited, navTraining
        ]

        // Explicitly set customizable view controllers
        tc.customizableViewControllers = tc.viewControllers

        // More tab tint color
        tc.moreNavigationController.navigationBar.tintColor = MFBTheme.MFBBrandColor()

        //  Set delegate after everything is ready
        tc.delegate = self

        return tc
    }
     */

    
    public func sceneDidEnterBackground(_ scene: UIScene) {
        saveState()
        timerSyncState?.invalidate()
        
        // call the old application level items
        MFBAppDelegate.threadSafeAppDelegate.applicationDidEnterBackground(UIApplication.shared)
    }

    public func sceneWillEnterForeground(_ scene: UIScene) {
        // Restore app state if needed
        // set a timer to save state every 5 minutes or so
        timerSyncState = Timer(fireAt: Date.init(timeIntervalSinceNow: 300),
                               interval: 300,
                               target: self,
                               selector: #selector(saveState),
                               userInfo: nil,
                               repeats: true)

        RunLoop.current.add(timerSyncState!, forMode: .default)
        
        // call the old application level items.
        MFBAppDelegate.threadSafeAppDelegate.applicationWillEnterForeground(UIApplication.shared)
    }
    
    public func sceneDidBecomeActive(_ scene: UIScene) {
        MFBAppDelegate.threadSafeAppDelegate.applicationDidBecomeActive(UIApplication.shared)
    }
    
    public func sceneWillResignActive(_ scene: UIScene) {
        saveState()
        HTTPCookieStorage.shared.saveToUserDefaults()     // save any cookies.
        WidgetCenter.shared.reloadAllTimelines()    // in case anything changed, force the widgets to reload.
    }
    
    public func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        switch shortcutItem.type {
        case "app.currency":
            tabBarController!.selectedViewController = tabBarController!.tabCurrency
        case "app.totals":
            tabBarController!.selectedViewController = tabBarController!.tabTotals
        case "app.current":
            tabBarController!.selectedViewController = tabBarController!.tabNewFlight
        case "app.blockOut":
            leProtocolHandler.blockOutExternal()
        case "app.blockIn":
            leProtocolHandler.blockInExternal()
        case "app.startEngine":
            leProtocolHandler.startEngineExternal()
        case "app.stopEngine":
            leProtocolHandler.stopEngineExternalNoSubmit()
        case "app.resume", "app.pause":
            leProtocolHandler.toggleFlightPause()
        default:
            completionHandler(false)
        }
        completionHandler(true)
    }
    
    public func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        for (_, urlc) in URLContexts.enumerated() {
            let url = urlc.url
            if (url.isFileURL) {
                NSLog("Loaded with URL: %@", url.absoluteString)
                tabBarController!.selectedViewController = tabBarController!.tabRecents
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
                        tabBarController.selectedViewController = tabBarController?.tabRecents
                        recentsView.addJSONFlight(szJSON)
                    }
                case "totals":
                    tabBarController!.selectedViewController = tabBarController!.tabTotals
                case "currency":
                    tabBarController!.selectedViewController = tabBarController!.tabCurrency
                case "newflight":
                    tabBarController!.selectedViewController = tabBarController!.tabNewFlight
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
    }
    
    // MARK: - Scene utilities
    // returns the index of the default tab to select
    // if the user has airplanes, it's
    private func defaultTab() -> UIViewController {
        return MFBProfile.sharedProfile.isValid() ? tabBarController.tabNewFlight! : tabBarController.tabProfile!
    }

    public func setCustomizableViewControllers() {
        if #available(iOS 26.0, *) {
            tabBarController!.customizableViewControllers = []  // TODO: Remove this when Apple fixes their buggy shitty software
        } else {
            tabBarController!.customizableViewControllers = tabBarController.viewControllers
        }
    }
    
    @objc public func DefaultPage()  {
        tabBarController!.selectedViewController = defaultTab()
    }
    
    private func saveTabState() {
        // Remember the last-used tab, but not if it is the "More" tab (button #5)
        let i = tabBarController!.selectedIndex
        
        let def = UserDefaults.standard

        // if iPad, override the above line - we can store any saved tab
        if UIDevice.current.userInterfaceIdiom == .pad {
            def.set(i, forKey: SceneDelegate._szKeySelectedTab)
        } else {
            def.set(i < 4 ? i : 0, forKey: SceneDelegate._szKeySelectedTab)
        }
        def.synchronize()
    }
    
    // TODO: Combine this with MFBAppDelegate?
    var leProtocolHandler : LEControllerProtocol {
        return tabBarController!.leMain as! LEControllerProtocol   // this should always succeed; bad juju if not.
    }
    
    @objc public func saveState() {
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
        MFBAppDelegate.threadSafeAppDelegate.mfbloc.saveState()
        try! def.set(NSKeyedArchiver.archivedData(withRootObject: MFBAppDelegate.threadSafeAppDelegate.rgUnsubmittedFlights, requiringSecureCoding: true), forKey: SceneDelegate._szKeyPrefUnsubmittedFlights)
        def.synchronize()
        NSLog("saveState - done and synchronized")
    }
    
    // MARK: Tab management
    private func checkNoAircraft() -> Bool {
        return (Aircraft.sharedAircraft.rgAircraftForUser ?? []).isEmpty
    }
    
    // MARK: - TabBarControllerDelegate
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
            
            UserDefaults.standard.set(rgIndices, forKey: SceneDelegate._szKeyTabOrder)
            UserDefaults.standard.synchronize()

            setCustomizableViewControllers()
        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        
        if let vcs = tabBarController.viewControllers {
            print("=== Tab hierarchy dump ===")
            for (i, vc) in vcs.enumerated() {
                print("Tab[\(i)]:", type(of: vc), "title:", vc.title ?? "nil")
                print("  view:", vc.view ?? "no view yet")
                if let nav = vc as? UINavigationController {
                    for (j, root) in (nav.viewControllers).enumerated() {
                        print("    Root[\(j)]:", type(of: root), "title:", root.title ?? "nil")
                    }
                }
            }
        }
    }
    
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController ==  self.tabBarController.tabNewFlight && checkNoAircraft() {
            WPSAlertController.presentOkayAlertWithTitle(String(localized: "No Aircraft", comment: "Title for No Aircraft error"),
                                                         message: String(localized: "You must set up at least one aircraft before you can enter flights", comment: "No aircraft error message"))
        }
        
        return true
    }
}

