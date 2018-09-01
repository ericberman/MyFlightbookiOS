/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2018 MyFlightbook, LLC
 
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
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "MFBProfile.h"
#import "Aircraft.h"
#import "LocalAirports.h"
#import <sqlite3.h>
#import "Reachability.h"
#import "MFBLocation.h"
#import "AutodetectOptions.h"
#import "CollapsibleTable.h"
#import "SharedWatch.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "HostName.h"

#ifdef DEBUG
// 2 minute cache lifetime in debug
#define CACHE_LIFETIME (60 * 2)
// but after 30 seconds, attempt a refresh
#define CACHE_REFRESH (30)
#define EXF_LOGGING NO

// iRATE values:
#define MIN_IRATE_EVENTS    2
#define MIN_IRATE_DAYS  0.01
#define MIN_IRATE_USES  4
#else
// 14 day lifetime in retail
#define CACHE_LIFETIME (3600 * 24 * 14)
// Cache is valid for 2 weeks, but we will attempt refreshes after 3 days
#define CACHE_REFRESH (3600 * 24 * 3)
#define EXF_LOGGING NO
#define MIN_IRATE_EVENTS    5
#define MIN_IRATE_DAYS      10
#define MIN_IRATE_USES      10
#endif

#define MFBFLIGHTIMAGEUPLOADPAGE @"/logbook/public/uploadpicture.aspx"
#define MFBAIRCRAFTIMAGEUPLOADPAGE @"/logbook/public/uploadairplanepicture.aspx?id=1"
#define MFBAIRCRAFTIMAGEUPLOADPAGENEW @"/logbook/public/uploadairplanepicture.aspx"
#define MFB_KEYFLIGHTIMAGE @"idFlight"
#define MFB_KEYAIRCRAFTIMAGE @"txtAircraft"

#define MPS_TO_KNOTS 1.94384449
#define METERS_TO_FEET 3.2808399
#define METERS_IN_A_NM 1852.0
#define NM_IN_A_METER 0.000539956803
#define DEG2RAD(degrees) (degrees * 0.0174532925199433) // degrees * pi over 180

// Distance for Cross-country Flight (in nm)
#define CROSS_COUNTRY_THRESHOLD 50.0

// Cached credentials, aircraft durations
typedef enum _cacheStatus {cacheInvalid, cacheValid, cacheValidButRefresh} CacheStatus;

#define mfbApp() ((MFBAppDelegate *) [[UIApplication sharedApplication] delegate])

#define _szKeyPrefRecordFlightData @"keyAutoDetectRoute"
#define _szKeyPrefRecordHighRes @"keyRecordHighRes"
#define _szKeyPrefAutoDetect @"keyAutoDetectTakeOffAndLanding"
#define _szKeyPrefIsRecording @"keyPrefIsRecording"
#define _szKeyPrefPendingFlights @"keyPendingFlights"
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
@property (strong) NSMutableArray * rgPendingFlights;
@property (readwrite, strong) MFBLocation * mfbloc;
@property (readwrite) BOOL fDebugMode;
@property (nonatomic, strong) IBOutlet UINavigationController * tabNewFlight;
@property (nonatomic, strong) IBOutlet UINavigationController * tabRecents;
@property (nonatomic, strong) IBOutlet UINavigationController * tabProfile;
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
- (void) addBadgeForPendingFlights;
- (void) queueFlightForLater:(LogbookEntry *) le;
- (void) dequeuePendingFlight:(LogbookEntry *) le;
@end
