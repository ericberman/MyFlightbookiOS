/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2012-2023 MyFlightbook, LLC
 
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
//  MFBLocation.h
//  MFBSample
//
//  Created by Eric Berman on 5/17/12.
//  Copyright (c) 2012-2021 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MyFlightbook-Swift.h>

// use low speeds for debug, use high-speeds for fake GPS or release
#ifdef USE_FAKE_GPS
#undef USE_FAKE_GPS
#endif

#ifdef DEBUG
#if (TARGET_IPHONE_SIMULATOR)
#define USE_FAKE_GPS
#endif // if simulator
#endif // if debug

// speeds for distinguishing takeoff/landing
// we want some hysteresis here, so set the take-off speed higher than the landing speed
#define TAKEOFF_SPEED_DEFAULT 55
#define LANDING_SPEED_DEFAULT 40
#define MIN_DISTANCE  10
#define MIN_SAMPLE_RATE_TAXI 4
#define MIN_SAMPLE_RATE_AIRBORNE 6.0

#define TAKEOFF_SPEED_MIN   20
#define TAKEOFF_SPEED_MAX   100
#define TAKEOFF_SPEED_SPREAD_BREAK 50
#define TAKEOFF_LANDING_SPREAD_LOW  10
#define TAKEOFF_LANDING_SPREAD_HIGH  15
#define FULL_STOP_SPEED 8

// minimum horizontal accuracy for us not to throw things out.
#define MIN_ACCURACY  50

// Number of supposedly valid GPS samples to ignore after a wake-up
#define BOGUS_SAMPLE_COUNT 2

// Flight states
typedef NS_ENUM(NSInteger, FlightState) {
    fsOnGround, fsInFlight, fsJustLanded
} ;

@protocol AutoDetectDelegate
- (NSString *) takeoffDetected;
- (NSString *) landingDetected;
- (NSString *) fsLandingDetected:(BOOL) fIsNight;
- (void) addNightTime:(double) t;
- (NSString *) nightTakeoffDetected;
- (BOOL) flightCouldBeInProgress;
- (void) newLocation:(CLLocation *)newLocation;
@end

@interface MFBLocation : NSObject <CLLocationManagerDelegate>
{
    BOOL fHasPendingLanding;

@private
    NSMutableString * flightTrackData;
	BOOL fRecordFlightData;
	NSInteger cSamplesSinceWaking;
}

@property (readwrite) BOOL fRecordFlightData;
@property (readwrite) BOOL fRecordHighRes;
@property (readwrite) BOOL fRecordingIsPaused;
@property (readwrite) BOOL fSuppressAllRecording;
@property (assign) NSInteger cSamplesSinceWaking;
@property (readwrite, strong) id<AutoDetectDelegate> delegate;
@property (strong) CLLocation * lastSeenLoc; // most recently seen location, regardless of quality
@property (strong) CLLocation * currentLoc; // most recently seen location with decent quality.
@property (strong) NSMutableArray * rgAllSamples;
@property (readwrite, nonatomic) FlightState currentFlightState;
@property (readwrite, nonatomic) BOOL fUpdatesTheme;

- (instancetype) init NS_DESIGNATED_INITIALIZER;    // initializes the object but does NOT start receiving GPS events
- (instancetype) initWithGPS;                       // initializes and DOES start receiving GPS

- (void) setUpLocManager;
- (BOOL) isLocationServicesEnabled;
+ (BOOL) isSignificantChangeMonitoringEnabled;
- (void) saveState;
- (void) restoreState;
+ (void) refreshTakeoffSpeed;
- (void) startRecordingFlightData;
- (void) stopRecordingFlightData;
+ (NSString *) nightFlightOptionName:(nightFlightOptions)nf;
+ (NSString *) nightLandingOptionName:(nightLandingOptions)nl;

+ (int) TakeOffSpeed;
+ (int) LandingSpeed;

- (void) resetFlightData;
- (NSString *) flightDataAsString;

+ (NSString *) altitudeDisplay:(CLLocation *) loc;
+ (NSString *) speedDisplay: (CLLocationSpeed) s;
+ (NSString *) flightStateDisplay: (FlightState) fs;
+ (NSString *) latitudeDisplay:(double) loc;
+ (NSString *) longitudeDisplay: (double) loc;

- (NSString *)gpxData;
- (NSString *) writeToFile:(NSString *) szData;

- (void) stopUpdatingLocation;
- (void) startUpdatingLocation;
- (void) feedEvent:(CLLocation *) loc;
@end
