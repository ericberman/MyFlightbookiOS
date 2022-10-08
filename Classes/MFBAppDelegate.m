/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2022 MyFlightbook, LLC
 
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
//  MFBSampleAppDelegate.m
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//  Copyright 2009-2021 MyFlightbook LLC. All rights reserved.
//

#import "MFBAppDelegate.h"
#import "LEEditController.h"
#import "NearbyAirports.h"
#import "MyAircraft.h"
#import "RecentFlights.h"
#import "Currency.h"
#import "Totals.h"
#import "VisitedAirports.h"
#import "SunriseSunset.h"
#import "iRate.h"
#import "Telemetry.h"
#import "WPSAlertController.h"
#import "SynchronousCalls.h"
#import "MFBTheme.h"
#import "OptionKeys.h"
#import <UserNotifications/UserNotifications.h>

#ifdef DEBUG
#warning DEBUG BUILD!!.
#else
#warning RELEASE BUILD!
#endif

@interface MFBAppDelegate ()
@property (nonatomic, strong) NSTimer * timerSyncState;
@property (strong) IBOutlet UITabBarItem * tbiRecent;
@property (atomic, strong) Reachability * reachability;

@property (nonatomic, strong) NSMutableArray * notifyDataChanged;
@property (nonatomic, strong) NSMutableArray * notifyResetAll;
@property (nonatomic, strong) UIAlertController * progressAlert;

// Watch properties
@property (nonatomic, strong) WCSession * watchSession;
@property (nonatomic, readwrite) BOOL fSuppressWatchNotification;
@end

@implementation MFBAppDelegate

sqlite3 * _db;
BOOL fNetworkStateKnown;

@synthesize window, tabBarController, userProfile;
@synthesize leMain, timerSyncState, rgUnsubmittedFlights, tbiRecent, mfbloc, fDebugMode;
@synthesize reachability, lastKnownNetworkStatus, reachabilityDelegate;
@synthesize tabProfile, tabRecents, tabNewFlight;
@synthesize notifyDataChanged, notifyResetAll;
@synthesize watchSession, fSuppressWatchNotification;
@synthesize watchData;

NSString * const _szKeySelectedTab = @"_prefSelectedTab";
NSString * const _szKeyTabOrder = @"keyTabOrder2";

NSString * const _szNewFlightTitle = @"newFlight";
NSString * const _szMyAircraftTitle = @"MyAircraft";
NSString * const _szProfileTitle = @"Profile";
NSString * const _szNearestTitle = @"Nearest";
NSString * const _szMoreTitle = @"More";

NSString * const _szKeyHasSeenDisclaimer = @"keySeenDisclaimer";

BOOL gLogging = EXF_LOGGING;

#pragma mark Tab Management
- (BOOL) checkNoAircraft
{
	return ([[Aircraft sharedAircraft].rgAircraftForUser count] == 0);
}

// returns the index of the default tab to select
// if the user has airplanes, it's
- (UIViewController *) defaultTab
{
    return [self.userProfile isValid] ? self.tabNewFlight : self.tabProfile;
}

- (void) setCustomizableViewControllers
{
	self.tabBarController.customizableViewControllers = [NSArray arrayWithArray:self.tabBarController.viewControllers];
}

- (void) DefaultPage
{
	self.tabBarController.selectedViewController = [self defaultTab];
}

#pragma mark SaveState
- (void) saveTabState {
    // Remember the last-used tab, but not if it is the "More" tab (button #5)
    NSInteger i = self.tabBarController.selectedIndex;
    
    NSUserDefaults * def = NSUserDefaults.standardUserDefaults;

    [def setInteger:((i < 4) ? i : 0) forKey:_szKeySelectedTab];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
    // if iPad, override the above line - we can store any saved tab
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [def setInteger:i forKey:_szKeySelectedTab];
#endif
    [def synchronize];
}

- (void) saveState
{
	if (self.leMain != nil && ![self checkNoAircraft])
		[self.leMain saveState];

    if (NSThread.isMainThread)
        [self saveTabState];
    else
        [self performSelectorOnMainThread:@selector(saveTabState) withObject:nil waitUntilDone:NO];
	
    NSUserDefaults * def = NSUserDefaults.standardUserDefaults;
	// remember whether or not we were flying and recording flight data.
    [self.mfbloc saveState];
	[def setObject:[NSKeyedArchiver archivedDataWithRootObject:self.rgUnsubmittedFlights requiringSecureCoding:YES error:nil] forKey:_szKeyPrefUnsubmittedFlights];
	
	[def synchronize];
	NSLog(@"saveState - done and synchronized");
}

#pragma mark database functions
static void distanceFunc(sqlite3_context * context, int argc, sqlite3_value **argv)
{
	// thanks to http://www.thismuchiknow.co.uk/?p=71 for this code & instructions.
	// check that we have four arguments (lat1, lon1, lat2, lon2)
	assert(argc == 4);
	// check that all four arguments are non-null
	if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
		sqlite3_result_null(context);
		return;
	}
	
	// get the four argument values
	double lat1 = sqlite3_value_double(argv[0]);
	double lon1 = sqlite3_value_double(argv[1]);
	double lat2 = sqlite3_value_double(argv[2]);
	double lon2 = sqlite3_value_double(argv[3]);
	
	// convert lat1 and lat2 into radians now, to avoid doing it twice below
	double lat1rad = DEG2RAD(lat1);
	double lat2rad = DEG2RAD(lat2);
	// apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
	// 6378.1 is the approximate radius of the earth in kilometres
	sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 3440.06479);
}

- (void) createCopyOfDatabaseIfNeeded
{
	// commented code below copies the database to the user's document directory.
	// this makes sense if we want read/write, but we don't need write capabilities,
	// so we can just use it in-situ.
	
	/*
	BOOL success = NO;
	NSFileManager * filemanager = [NSFileManager defaultManager];
	NSError * error;
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = [paths objectAtIndex:0];
	NSString * szDBPath = [documentsDirectory stringByAppendingPathComponent:@"mfb.sqlite"];
	success = [filemanager fileExistsAtPath:szDBPath];
	if (!success) // needs to be copied - should only ever need to do this once.
	{
		NSString * szDefault = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mfb.sqlite"];
		success = [filemanager copyItemAtPath:szDefault toPath:szDBPath error:&error];
	}
	
	if (success) // should be true here - now initialize the db
	{
		if (sqlite3_open([szDBPath UTF8String], &db) != SQLITE_OK)
		{
			NSLog(@"Failed to open database at path %@", szDBPath);
			sqlite3_close(db);
			db = nil;
		}	
	}
	else
		NSLog(@"Failed to create database file with message '%@'.", [error localizedDescription]);
  */
	
	NSString * szDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mfb.sqlite"];
	if (sqlite3_open([szDBPath UTF8String], &_db) != SQLITE_OK)
	{
		NSLog(@"Failed to open database at path %@", szDBPath);
		sqlite3_close(_db);
		_db = nil;
	}
    sqlite3_create_function(_db, "distance", 4, SQLITE_UTF8, NULL, &distanceFunc, NULL, NULL);
}

- (sqlite3 *) getdb
{
    @synchronized(self)
    {
    if (_db == nil)
        [self createCopyOfDatabaseIfNeeded];
    }
    return _db;
}

#pragma mark Unused
- (BOOL) supportsBackgroundUpdates
{
	UIDevice * device = [UIDevice currentDevice];
	BOOL backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	return backgroundSupported;
}

#pragma mark Network status
- (BOOL) isOnLine
{
    // There is a lag between when the reachability object is initialized and we get our first notification
    // So as a hack, we use a flag (fNetworkStateKnown) to indicate that we have not yet received a notification
    // and we optimistically assume we are ONLINE if we get that.  Once the app is running, we assume reachability
    // is valid.
    return self.lastKnownNetworkStatus != NotReachable || !fNetworkStateKnown;
}

- (void) notifyNetworkAcquired
{
    if ([self isOnLine] && self.reachabilityDelegate != nil)
        [self.reachabilityDelegate networkAcquired];
}

- (void) asyncResolveDNS
{
    NetworkStatus ns = self.lastKnownNetworkStatus;
    if (ns == NotReachable || ns == ReachableViaWiFi)
    {
        // Reachability just returns a theoretical reachability.
        // We don't trust reachability for Wifi or for None (switching between Internet and Stratus, for example), so do a 2nd check.
        // Here, we do a DNS check to see if we can resolve.  This can force a recheck of reachability
        // If we are on a private WiFi network (such as Appareo Stratus), this will fail.
        Boolean fDNSSucceeded = FALSE;
        NSLog(@"asyncResolveDNS: We don't trust the network change, so we'll do our own DNS check");
        CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (CFStringRef)MFBHOSTNAME);
        if (hostRef) {
            fDNSSucceeded = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
            if (fDNSSucceeded == TRUE)
                CFHostGetAddressing(hostRef, &fDNSSucceeded);
            CFRelease(hostRef);
        }
        if (fDNSSucceeded)
        {
            if (ns == NotReachable)
            {
                fNetworkStateKnown = NO;    // we don't know what the state is so can't set wifi or WWan, but can say that we just don't know.
                NSLog(@"asyncResolveDNS: Reachability resported no network, but we found one!");
            }
            else
                NSLog(@"asyncResolveDNS: WiFi connectivity confirmed");
        }
        else
        {
            if (ns == ReachableViaWiFi)
            {
                NSLog(@"asyncResolveDNS: wifi, but DNS failed");
                self.lastKnownNetworkStatus = NotReachable;
            }
            else
                NSLog(@"asyncResolveDNS: not-reachable confirmed");
        }
    }
    
    [self performSelectorOnMainThread:@selector(notifyNetworkAcquired) withObject:nil waitUntilDone:NO];
}

// This is called whenever the system changes network state - this is the result of the observer call.
- (void) handleNetworkChange:(NSNotification *) notice
{
    NetworkStatus nsOld = self.lastKnownNetworkStatus;
    NetworkStatus nsNew = [self.reachability currentReachabilityStatus];
    self.lastKnownNetworkStatus = nsNew;
    fNetworkStateKnown = YES;
    
    NSLog(@"Network status change: %@==>%@",
          [Reachability reachabilityDesc:nsOld],
          [Reachability reachabilityDesc:nsNew]);
    
    [NSThread detachNewThreadSelector:@selector(asyncResolveDNS) toTarget:self withObject:nil];
}

#pragma mark App setup/teardown/wakeup
- (void) ensureWarningShownForUser
{
	MFBAppDelegate * app = mfbApp();
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	NSString * szUser = app.userProfile.UserName;
	
	if (szUser == nil || [szUser length] == 0)
		return;
	
	NSString * szUserWarning = [defs stringForKey:_szKeyHasSeenDisclaimer];
	if (szUserWarning == nil || [szUser compare:szUserWarning] != NSOrderedSame)
	{
        [WPSAlertController presentOkayAlertWithTitle:NSLocalizedString(@"Important", @"Disclaimer warning message title")
                                              message:NSLocalizedString(@"Use of this during flight could be a distraction and could violate regulations, including 14 CFR 91.21 and 47 CFR 22.925.\r\nYou are responsible for the consequences of any use of this software.", @"Use in flight disclaimer")
                                            button:NSLocalizedString(@"Accept", @"Disclaimer acceptance button title")];
		
		[defs setValue:szUser forKey:_szKeyHasSeenDisclaimer];
		[defs synchronize];
	}
}

static NSURL * urlLaunchURL = nil;
static BOOL fAppLaunchFinished = NO;

- (void) openURL:(NSURL *) url
{
    if (url.isFileURL)
    {
        NSLog(@"Loaded with URL: %@", url.absoluteString);
        self.tabBarController.selectedViewController = self.tabRecents;
        [self.recentsView addTelemetryFlight:url];
    }
    else if (url.host != nil) {
        if ([url.host compare:@"addFlights"] == NSOrderedSame) {
            NSString * szJSON = url.path;
            if (szJSON.length > 0)
                szJSON = [szJSON substringFromIndex:1];
        
            if (szJSON.length > 0 && [szJSON hasPrefix:@"{"])
            {
                self.tabBarController.selectedViewController = self.tabRecents;
                [[self recentsView] addJSONFlight:szJSON];
            }
        } else if ([url.host compare:@"totals"] == NSOrderedSame) {
            self.tabBarController.selectedViewController = self.tabTotals;
        } else if ([url.host compare:@"currency"] == NSOrderedSame) {
            self.tabBarController.selectedViewController = self.tabCurrency;
        } else if ([url.host compare:@"newflight"] == NSOrderedSame) {
            self.tabBarController.selectedViewController = self.tabNewFlight;
        }
    }
}

- (void) application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if ([shortcutItem.type compare:@"app.currency"] == NSOrderedSame) {
        if (fAppLaunchFinished)
            self.tabBarController.selectedViewController = self.tabCurrency;
        else
            urlLaunchURL = [[NSURL alloc] initWithString:@"myflightbook://currency"];
    }
    else if ([shortcutItem.type compare:@"app.totals"] == NSOrderedSame) {
        if (fAppLaunchFinished)
            self.tabBarController.selectedViewController = self.tabTotals;
        else
            urlLaunchURL = [[NSURL alloc] initWithString:@"myflightbook://totals"];
    }
    else if ([shortcutItem.type compare:@"app.current"] == NSOrderedSame) {
        if (fAppLaunchFinished)
            self.tabBarController.selectedViewController = self.tabNewFlight;
        else
            urlLaunchURL = [[NSURL alloc] initWithString:@"myflightbook://newflight"];
    }
    else if ([shortcutItem.type compare:@"app.startEngine"] == NSOrderedSame)
        [self.leMain startEngineExternal];
    else if ([shortcutItem.type compare:@"app.stopEngine"] == NSOrderedSame)
        [self.leMain stopEngineExternalNoSubmit];
    else if ([shortcutItem.type compare:@"app.resume"] == NSOrderedSame  || [shortcutItem.type compare:@"app.pause"] == NSOrderedSame)
        [self.leMain toggleFlightPause];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:options
{
    @synchronized(self)
    {
        NSLog(@"application:openURL: with %@, %@", url.absoluteString, fAppLaunchFinished ? @"app launch is finished, opening" : @"Queueing to open when launch is finished.");
        if (fAppLaunchFinished)
            [self openURL:url];
        else
            urlLaunchURL = url;
    }
    return YES;
}

#pragma mark UIApplication delegate methods
- (void) createLocManager
{
    if (self.mfbloc == nil)
        self.mfbloc = [[MFBLocation alloc] initWithGPS];
    else
        [self.mfbloc restoreState];
    self.mfbloc.delegate = self.leMain;
}

+ (void) initialize
{
    [iRate sharedInstance].eventsUntilPrompt = MIN_IRATE_EVENTS;
    [iRate sharedInstance].usesUntilPrompt = MIN_IRATE_USES;
    [iRate sharedInstance].daysUntilPrompt = MIN_IRATE_DAYS;
    [iRate sharedInstance].verboseLogging = YES;
    [iRate sharedInstance].ratingsURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/myflightbook/id%@?mt=8&action=write-review", _appStoreID]];
}

static MFBAppDelegate * _mainApp = nil;
+ (MFBAppDelegate *) threadSafeAppDelegate
{
    return _mainApp;
}

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"MyFlightbook: hello - launch, baseURL is %@", MFBHOSTNAME);
    
    _mainApp = self;
    self.notifyDataChanged = [[NSMutableArray alloc] init];
    self.notifyResetAll = [[NSMutableArray alloc] init];
    
    [MFBTheme setMFBTheme];
    self.tabBarController.moreNavigationController.navigationBar.tintColor = MFBTheme.MFBBrandColor;

	if (self.window)
	{
        [self.window makeKeyAndVisible];
        self.window.frame = [[UIScreen mainScreen] bounds];
        self.window.rootViewController = self.tabBarController;
        self.progressAlert = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Loading; please wait...", @"Status message at app startup") onViewController:self.tabBarController];
	}
    
    [self createLocManager];
    self.mfbloc.cSamplesSinceWaking = 0;
    self.mfbloc.fRecordingIsPaused = NO;

    // Start reachability notifier
    self.reachability = [Reachability reachabilityWithHostName:MFBHOSTNAME];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    [self.reachability startNotifier];
    self.lastKnownNetworkStatus = [self.reachability currentReachabilityStatus];
    fNetworkStateKnown = YES;
    
    // Ensure that a profile object is set up
    self.userProfile = [MFBProfile new];

    // Apple Watch support
    self.watchData = [SharedWatch new];
    [self setUpWatchSession];
    self.leMain.view = self.leMain.view; // force view to load to ensure it is valid.  Also initializes for shared watch.
    
    [self upgradeOldVersion];
    
    [self invalidateCachedTotals];
    
    // recover unsubmitted flights (for count to add to recent-flights tab)
    NSData * ar = (NSData *) [NSUserDefaults.standardUserDefaults objectForKey:_szKeyPrefUnsubmittedFlights];
    NSError * err = nil;
    if (ar != nil)
        self.rgUnsubmittedFlights = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[NSArray.class, NSString.class, NSNumber.class, NSMutableString.class, LogbookEntry.class, MFBWebServiceSvc_PendingFlight.class, MFBWebServiceSvc_LogbookEntry.class]] fromData:ar error:&err]];
    else
        self.rgUnsubmittedFlights = [[NSMutableArray alloc] init];
    // set a badge for the # of unsubmitted flights.
    [self addBadgeForUnsubmittedFlights];
    
    // reload persisted state of tabs, if needed.
    NSArray * rgPresistedTabs = [[NSUserDefaults standardUserDefaults] objectForKey:_szKeyTabOrder];
    if (rgPresistedTabs != nil)
    {
        NSArray * controllers = self.tabBarController.viewControllers;
        
        NSMutableArray * rg = [[NSMutableArray alloc] init];
        
        for (NSString * szTitle in rgPresistedTabs) {
            // find the view with this title in the viewcontrollers array
            for (UIViewController * vw in controllers) {
                NSString * szVwTitle = vw.title;
                if ([szVwTitle isEqualToString:szTitle]) {
                    [rg addObject:vw];
                    break;
                }
            }
        }
        
        // if somehow things didn't mesh up, don't try to restore the tabs!!!
        if ([rg count] == [controllers count])
            self.tabBarController.viewControllers = rg;
        [self setCustomizableViewControllers];
    }
    
    NSMutableArray * rgImages = [NSMutableArray arrayWithArray:self.leMain.le.rgPicsForFlight];
    // Now get any additional images
    for (LogbookEntry * lbe in self.rgUnsubmittedFlights)
        [rgImages addObjectsFromArray:lbe.rgPicsForFlight];
    [CommentedImage cleanupObsoleteFiles:rgImages];
    
    // set a timer to save state every 5 minutes or so
    self.timerSyncState = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:300]
                                                   interval:300
                                                     target:self
                                                   selector:@selector(saveState)
                                                   userInfo:nil
                                                    repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timerSyncState forMode:NSDefaultRunLoopMode];
    
    [self ensureWarningShownForUser];
    
    if (self.progressAlert != nil) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
            if ([self.userProfile isValid])
            {
                NSInteger iTab = [[NSUserDefaults standardUserDefaults] integerForKey:_szKeySelectedTab];
                if (iTab == 0 && [self checkNoAircraft])
                    [self DefaultPage];
                else
                    self.tabBarController.selectedIndex = iTab;
            } else
                self.tabBarController.selectedViewController = self.tabProfile;

            fAppLaunchFinished = YES;
            if (urlLaunchURL != nil)
            {
                NSLog(@"Opening URL from AppLaunchWorkerUITasks");
                [self openURL:urlLaunchURL];
                urlLaunchURL = nil;
            }
        }];
        self.progressAlert = nil;
    }
    
    // set the default in-the-cockpit values.
    [NSUserDefaults.standardUserDefaults registerDefaults:@{ keyShowHobbs : @YES, keyShowEngine: @YES, keyShowFlight: @YES }];

	return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"MyFlightbook terminating");
	[self saveState];
	if (_db != nil)
		sqlite3_close(_db);
    _mainApp = nil;
}

- (void) updateShortCutItems {
    // Update 3D touch actions
    
    NSMutableArray<UIApplicationShortcutItem *> * rgShortcuts = [[NSMutableArray alloc] init];
    
    // If a flight is in progress, add stop engine and pause/play as appropriate
    if ([self.leMain flightCouldBeInProgress]) {
        [rgShortcuts addObject:[[UIApplicationShortcutItem alloc] initWithType:@"app.stopEngine" localizedTitle:NSLocalizedString(@"StopEngine", @"Shortcut - Stop Engine") localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithSystemImageName:@"stop.fill"] userInfo:nil]];
        if (self.leMain.le.fIsPaused)
            [rgShortcuts addObject:[[UIApplicationShortcutItem alloc] initWithType:@"app.resume" localizedTitle:NSLocalizedString(@"WatchPlay", @"Watch - Resume") localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay] userInfo:nil]];
        else
            [rgShortcuts addObject:[[UIApplicationShortcutItem alloc] initWithType:@"app.pause" localizedTitle:NSLocalizedString(@"WatchPause", @"Watch - Pause") localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePause] userInfo:nil]];
    }
    else if (!self.leMain.le.entryData.isKnownEngineEnd)
        // flight not in progress - just add start flight
        [rgShortcuts addObject:[[UIApplicationShortcutItem alloc] initWithType:@"app.startEngine" localizedTitle:NSLocalizedString(@"StartEngine", @"Shortcut - Start Engine") localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay] userInfo:nil]];
    else    // completed flight waiting for submission
        [rgShortcuts addObject:[[UIApplicationShortcutItem alloc] initWithType:@"app.current" localizedTitle:NSLocalizedString(@"CurrentFlight", @"Shortcut - Current Flight") localizedSubtitle:@"" icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"newflight.png"] userInfo:nil]];

    [[UIApplication sharedApplication] setShortcutItems:rgShortcuts];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Entered Background");
    
    // To save power, stop receiving updates if we don't need them.
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    BOOL fAutoDetect = [defs boolForKey:_szKeyPrefAutoDetect];
    BOOL fRecord = [defs boolForKey:_szKeyPrefRecordFlightData];
    
    if ((!fAutoDetect && !fRecord) || ![self.leMain flightCouldBeInProgress])
    {
        [self.mfbloc stopUpdatingLocation];
    }
    
    [self updateShortCutItems];
}

- (void) applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Entered foreground");
    
    _mainApp = self;
    // ALWAYS start updating location in foreground
    [self.mfbloc startUpdatingLocation];
    
    [self setUpWatchSession];
    
    // Launch any refresh tasks, but don't wait for response
    Aircraft * aircraft = Aircraft.sharedAircraft;
    if ([aircraft cacheStatus:self.userProfile.AuthToken] != cacheValid && [self isOnLine])
        [NSThread detachNewThreadSelector:@selector(refreshIfNeeded) toTarget:aircraft withObject:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    _mainApp = self;
	NSLog(@"ApplicationDidBecomeActive\r\n");
    
    // restore the state of recording data.
    [self createLocManager];
    
#ifdef DEBUG
    self.fDebugMode = [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefDebugMode];
#else
    self.fDebugMode = NO;
#endif
    
    if ([self.mfbloc isLocationServicesEnabled])
	{
		// we could be stopped, in which case an update will have zero speed and be rejected
		// so clear currentloc.  This will cause it to be stored, which is enough
		// to initialize with and work with nearest.
		// self.mfbloc.currentLoc = nil;
		// force an updated location to be sent.
		[self.mfbloc stopUpdatingLocation];
		[self.mfbloc startUpdatingLocation];
	}
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] loadFromUserDefaults];   // sync any cookies.

    // refreah authtoken if needed and if online with a valid profile 
    if (self.userProfile != nil && self.userProfile.UserName.length > 0 && self.isOnLine)
        [self.userProfile RefreshAuthToken];
}

- (void) applicationWillResignActive:(UIApplication *)application
{
	[self saveState];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] saveToUserDefaults];     // save any cookies.
}

- (UIInterfaceOrientationMask) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window  // iOS 6
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark TabBarController delegate
- (void)tabBarController:(UITabBarController *)tbc didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	if (changed)
	{
		// we would get each of the views, in order, but not all of the views have been loaded.
		// hence, we cannot rely on their titles.
		// Instead, we will get the tags of the first few tab bar items, and pad out the list with the leftovers.
		// Get the titles of the views, in their current order
		NSMutableArray * rgIndices = [[NSMutableArray alloc] init];
		for (UIViewController * vw in tbc.viewControllers) {
			NSString * szTitle = vw.title;
			if (szTitle == nil)
			{
				NSLog(@"Can't persist tabs with a nil title");
				return;
			}
			[rgIndices addObject:szTitle];
		}
		
		[[NSUserDefaults standardUserDefaults] setObject:rgIndices forKey:_szKeyTabOrder];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self setCustomizableViewControllers];
	}
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if (viewController == self.tabNewFlight && [self checkNoAircraft])
        [WPSAlertController presentOkayAlertWithTitle:NSLocalizedString(@"No Aircraft", @"Title for No Aircraft error") message:NSLocalizedString(@"You must set up at least one aircraft before you can enter flights", @"No aircraft error message")];
	
	return YES;
}

// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController 
{
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/

#pragma mark Object Lifecycle
- (void)dealloc {
	[self.timerSyncState invalidate];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark Misc.
- (RecentFlights *) recentsView
{
    RecentFlights * rf = (RecentFlights *) (self.tabRecents.viewControllers)[0];
    if (!rf.isViewLoaded)   // force the view to load if needed.
    {
        UIView * v = rf.view;
        if (v != nil)
            v = nil;
    }
    return rf;
}

- (void) registerNotifyDataChanged:(id<Invalidatable>)sender
{
    [self.notifyDataChanged addObject:sender];
}

- (void) registerNotifyResetAll:(id<Invalidatable>)sender
{
    [self.notifyResetAll addObject:sender];
}


- (void) invalidateAll
{
    for (id<Invalidatable> vc in self.notifyResetAll)
        [vc invalidateViewController];
}

- (void) invalidateCachedTotals
{
    for (id<Invalidatable> vc in self.notifyDataChanged)
        [vc invalidateViewController];
}

#pragma mark Unsubmitted Flights
- (void) setBadgeCount {
    NSInteger cUnsubmittedFlights = self.rgUnsubmittedFlights.count;
    if (self.tbiRecent != nil)
        self.tbiRecent.badgeValue = (cUnsubmittedFlights == 0) ? nil : [NSString stringWithFormat:@"%ld", (long) cUnsubmittedFlights];;
    [UIApplication sharedApplication].applicationIconBadgeNumber = cUnsubmittedFlights;
}

- (void) addBadgeForUnsubmittedFlights
{
    [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.badgeSetting == UNNotificationSettingEnabled)
            [self performSelectorOnMainThread:@selector(setBadgeCount) withObject:nil waitUntilDone:NO];
        else if (self.rgUnsubmittedFlights.count > 0)
            // Request notification permission to show the badge for unsubmitted flights.
            [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (granted)
                    [self performSelectorOnMainThread:@selector(setBadgeCount) withObject:nil waitUntilDone:NO];
            }];
    }];
}

- (void) queueFlightForLater:(LogbookEntry *) le
{
    if (![self.rgUnsubmittedFlights containsObject:le])
    {
        [self.rgUnsubmittedFlights addObject:le];
        [self invalidateCachedTotals];
        [self saveState];
        [self performSelectorOnMainThread:@selector(addBadgeForUnsubmittedFlights) withObject:nil waitUntilDone:NO];
    }
}

- (void) dequeueUnsubmittedFlight:(LogbookEntry *) le
{
	[self.rgUnsubmittedFlights removeObject:le];
    // force a reload
	[self invalidateCachedTotals];
	[self saveState];
    [self performSelectorOnMainThread:@selector(addBadgeForUnsubmittedFlights) withObject:nil waitUntilDone:NO];
}

#pragma mark Watchkit
// define the minimum interval between watch context updates
#define WATCHKIT_CONTEXT_UPDATE_MIN_PERIOD 1.0
- (void) updateWatchContext
{
    if (self.fSuppressWatchNotification) {
        return;
    }

    // Check that:
    // a) we have a session (or that it successfully initializes)
    // b) we are paired
    // c) app is installed
    if (self.watchSession == nil || !! !self.watchSession.isPaired || !self.watchSession.reachable || !self.watchSession.watchAppInstalled) {
//        NSLog(@"MFBWatch: no session, not paired, not reachable, or not installed");
        return;
    }
    
    if (self.watchSession.activationState != WCSessionActivationStateActivated)
        [self.watchSession activateSession];

    if (self.watchSession.activationState != WCSessionActivationStateActivated) {
//        NSLog(@"MFBWatch - session no longer activated!!");
        return;
    }
    
    NSLog(@"MFBWatch: (iOS): Updating watch context");

    // self.watchSesion should not be nil here
    NSError * e;
    [self.watchSession updateApplicationContext:[self replyForMessage:@{WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_STATUS}] error:&e];
    if (e != nil) {
        NSLog(@"MFBWatch: (iOS): Error updating watch: %@", e.localizedDescription);
    }
}

- (WCSession *) setUpWatchSession {
    self.fSuppressWatchNotification = NO;

    if (![WCSession isSupported]) {
        return nil;
    }
    if (self.watchSession == nil)
        self.watchSession = [WCSession defaultSession];
    
    if (self.watchSession.delegate != self)
        self.watchSession.delegate = self;
    
    // Activate the session if (a) it responds to activateSession AND (EITHER it doesn't respond to ActivationState OR it isn't activated)
    if ([self.watchSession respondsToSelector:@selector(activateSession)] &&
        (![self.watchSession respondsToSelector:@selector(activationState)] || self.watchSession.activationState != WCSessionActivationStateActivated))
            [self.watchSession activateSession];
    
    return self.watchSession;
}

- (NSArray *) refreshRecents {
    NSArray * ar = [[SynchronousCalls new] recentsForUserSynchronous:self.userProfile.AuthToken];
    if (ar.count > 0)
        self.watchData.latestFlight = ar[0];    // cache the latest flight for good measure.
    return ar;
}

- (void)application:(UIApplication *)application
handleWatchKitExtensionRequest:(NSDictionary *)userInfo
              reply:(void (^)(NSDictionary *replyInfo))reply
{
    NSLog(@"handleWatchKitExtensionRequest called");
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithName:@"MyTask" expirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;

    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Do the work associated with the task, preferably in chunks.
        reply([self replyForMessage:userInfo]);
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}

- (NSDictionary *) replyForMessage:(NSDictionary<NSString *,id> *)message
{
    NSString * request = message[WATCH_MESSAGE_REQUEST_DATA];
    NSMutableDictionary * dictResponse = [NSMutableDictionary new];
    
    if (request != nil) // request for data
    {
        if ([request compare:WATCH_REQUEST_STATUS] == NSOrderedSame) {
            dictResponse[WATCH_RESPONSE_STATUS] = [NSKeyedArchiver archivedDataWithRootObject:self.watchData requiringSecureCoding:YES error:nil];
        }
        else if ([request compare:WATCH_REQUEST_CURRENCY] == NSOrderedSame) {
            dictResponse[WATCH_RESPONSE_CURRENCY] = [NSKeyedArchiver archivedDataWithRootObject:[[SynchronousCalls new] currencyForUserSynchronous:self.userProfile.AuthToken] requiringSecureCoding:YES error:nil];
        }
        else if ([request compare:WATCH_REQUEST_TOTALS] == NSOrderedSame) {
            dictResponse[WATCH_RESPONSE_TOTALS] = [NSKeyedArchiver archivedDataWithRootObject:[[SynchronousCalls new] totalsForUserSynchronous:self.userProfile.AuthToken] requiringSecureCoding:YES error:nil];
        }
        else if ([request compare:WATCH_REQUEST_RECENTS] == NSOrderedSame) {
            NSArray * ar = [self refreshRecents];
            dictResponse[WATCH_RESPONSE_RECENTS] = [NSKeyedArchiver archivedDataWithRootObject:ar requiringSecureCoding:YES error:nil];
        }
    }
    else if ((request = message[WATCH_MESSAGE_ACTION]) != nil)
    {
        self.fSuppressWatchNotification = YES;  // don't allow any outbound messages while we are refreshing here.
        NSLog(@"Action requested - %@...", request);
        if ([request compare:WATCH_ACTION_START] == NSOrderedSame) {
            [self.mfbloc startUpdatingLocation];
            [self.leMain performSelectorOnMainThread:@selector(startEngineExternal) withObject:nil waitUntilDone:YES];
        }
        else if ([request compare:WATCH_ACTION_END] == NSOrderedSame) {
            [self.leMain performSelectorOnMainThread:@selector(stopEngineExternal) withObject:nil waitUntilDone:YES];
        }
        else if ([request compare:WATCH_ACTION_TOGGLE_PAUSE] == NSOrderedSame) {
            [self.leMain performSelectorOnMainThread:@selector(toggleFlightPause) withObject:nil waitUntilDone:YES];
        }
        NSLog(@"Action request complete");
        dictResponse[WATCH_RESPONSE_STATUS] = [NSKeyedArchiver archivedDataWithRootObject:self.watchData requiringSecureCoding:YES error:nil];
        self.fSuppressWatchNotification = NO;
        
        [self updateShortCutItems];
    }
    
    return dictResponse;
}

- (void) session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    NSLog(@"didReceiveMessage called");
    if (!session.isPaired || !session.isReachable) {
        NSLog(@"Session is %@paired, %@reachable", session.isPaired ? @"" : @"NOT ", session.isReachable ? @"" : @"NOT ");
        replyHandler([NSMutableDictionary new]);
    } else
        replyHandler([self replyForMessage:message]);
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    self.watchSession = session;
    if (error != nil)
        NSLog(@"MFBWatch: Error activating session: %@", error.localizedDescription);
    
    // update status
    if (self.watchSession.isReachable)
        [self updateWatchContext];
}

- (void) sessionDidBecomeInactive:(WCSession *)session {
    NSLog(@"MFBWatch: Session is inactive");
}

- (void) sessionDidDeactivate:(WCSession *)session {
    NSLog(@"MFBWatch: Session deactivated");
}
@end

