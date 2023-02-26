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
//  MFBSampleAppDelegate.h
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//  Copyright MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MyFlightbook-Swift.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "Aircraft.h"
#import <sqlite3.h>
#import "Reachability.h"
#import "MFBLocation.h"
#import "CollapsibleTable.h"
#import "SharedWatch.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "HostName.h"

#define mfbApp() ((MFBAppDelegate *) [[UIApplication sharedApplication] delegate])

#define _szKeyPrefIsRecording @"keyPrefIsRecording"
#define _szKeyPrefUnsubmittedFlights @"keyPendingFlights"
#define _szKeyPrefLastInstalledVersion @"keyLastVersion"
#define _szKeyPrefDebugMode @"keyDebugMode"

@class LEEditController;
@class LogbookEntry;
@class MFBProfile;
@class RecentFlights;

@protocol ReachabilityDelegate
- (void) networkAcquired;
@end

@interface MFBAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, WCSessionDelegate> {
	BOOL fDebugMode;
}

@property (readonly, getter=getdb) sqlite3 * db;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (readwrite, strong) MFBProfile * userProfile;
@property (nonatomic, strong) IBOutlet LEEditController * leMain;
@property (strong) NSMutableArray * rgUnsubmittedFlights;
@property (readwrite, strong) MFBLocation * mfbloc;
@property (readwrite) BOOL fDebugMode;
@property (nonatomic, strong) IBOutlet UINavigationController * tabNewFlight;
@property (nonatomic, strong) IBOutlet UINavigationController * tabRecents;
@property (nonatomic, strong) IBOutlet UINavigationController * tabProfile;
@property (nonatomic, strong) IBOutlet UINavigationController * tabTotals;
@property (nonatomic, strong) IBOutlet UINavigationController * tabCurrency;
@property (nonatomic, strong) id<ReachabilityDelegate> reachabilityDelegate;
@property (assign, atomic) NetworkStatus lastKnownNetworkStatus;
@property (strong) SharedWatch * watchData;

- (void) invalidateCachedTotals;
- (void) invalidateAll;
- (void) DefaultPage;

- (void) registerNotifyDataChanged:(id<Invalidatable>)sender;
- (void) registerNotifyResetAll:(id<Invalidatable>)sender;

- (BOOL) isOnLine;
+ (MFBAppDelegate *) threadSafeAppDelegate;

- (RecentFlights *) recentsView;

- (void) updateWatchContext;

// Various tests of system functionality
- (void) ensureWarningShownForUser;
- (void) addBadgeForUnsubmittedFlights;
- (void) queueFlightForLater:(LogbookEntry *) le;
- (void) dequeueUnsubmittedFlight:(LogbookEntry *) le;
@end
