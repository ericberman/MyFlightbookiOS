/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2018 MyFlightbook, LLC
 
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
//  MFBLocation.m
//  MFBSample
//
//  Created by Eric Berman on 5/17/12.
//  Copyright (c) 2012-2018 MyFlightbook LLC. All rights reserved.
//

#import "MFBAppDelegate.h"
#import "MFBLocation.h"
#import "SunriseSunset.h"
#import "Airports.h"
#import "Telemetry.h"

@interface MFBLocation()
@property (readwrite, strong) NSMutableString * flightTrackData;
@property (readwrite, nonatomic) BOOL fIsBlessed;   // Are we the "Blessed" global instance that gets to receive updates from the live GPS?
@end

@implementation MFBLocation

#ifdef USE_LOW_SPEED
#warning LOW_SPEED IS IN USE!!
#endif

#ifdef USE_FAKE_GPS
#warning GPS SIM IS ON!!!
#endif

@synthesize fRecordFlightData, fRecordHighRes, fRecordingIsPaused;
@synthesize flightTrackData;
@synthesize cSamplesSinceWaking, delegate;
@synthesize fIsBlessed;
@synthesize lastSeenLoc, currentLoc, locManager, rgAllSamples;

static int vTakeOff = TAKEOFF_SPEED_DEFAULT;
static int vLanding = LANDING_SPEED_DEFAULT;

#define _szKeyPrefFlightTrackData @"keyFlightTrackDataInProgress"
#define _szKeyPrefFlightSamples @"keyFlightSamples"
#define _szKeyPrefFlightState @"keyCurrentFlightState"

#pragma mark ObjectLifecycle
- (instancetype) init {
    self = [super init];
	if (self != nil)
    {
        self.cSamplesSinceWaking = 0;
        self.currentFlightState = fsOnGround;
        self.fRecordFlightData = NO;
        self.fRecordHighRes = [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefRecordHighRes];
        self.flightTrackData = [NSMutableString new];
        self.rgAllSamples = [NSMutableArray new];
        self.fIsBlessed = NO;
        [MFBLocation refreshTakeoffSpeed];
    }
    return self;
}

- (instancetype) initWithGPS
{
    if (self = [self init])
    {
        self.fIsBlessed = YES;
        [self setUpLocManager];
        [self restoreState];
    }
    return self;
}

#pragma mark StateManagement
- (void) saveState
{
	NSUserDefaults * def = [NSUserDefaults standardUserDefaults];

    [def setInteger:(int) self.currentFlightState forKey:_szKeyPrefFlightState];
	[def setBool:self.fRecordFlightData forKey:_szKeyPrefIsRecording];
    [def setValue:self.flightTrackData forKey:_szKeyPrefFlightTrackData];
    [def setValue:self.rgAllSamples forKeyPath:_szKeyPrefFlightSamples];
}

+ (void) refreshTakeoffSpeed
{
    // Initialize takeoff/landing speed
    vTakeOff = [AutodetectOptions TakeoffSpeed];
    if (vTakeOff < TAKEOFF_SPEED_MIN || vTakeOff > TAKEOFF_SPEED_MAX)
        vTakeOff = TAKEOFF_SPEED_DEFAULT;
    vLanding = (vTakeOff >= TAKEOFF_SPEED_SPREAD_BREAK) ? vTakeOff - TAKEOFF_LANDING_SPREAD_HIGH : vTakeOff - TAKEOFF_LANDING_SPREAD_LOW;
}

- (void) restoreState
{
  	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    self.currentFlightState = (FlightState) [defs integerForKey:_szKeyPrefFlightState];
	self.fRecordFlightData = [defs boolForKey:_szKeyPrefIsRecording];
    
    NSString * szFlightTrack = [defs stringForKey:_szKeyPrefFlightTrackData];
    self.flightTrackData = [NSMutableString stringWithString:szFlightTrack == nil ? @"" : szFlightTrack];
    
    NSArray * ar = [defs objectForKey:_szKeyPrefFlightSamples];
    self.rgAllSamples = [NSMutableArray arrayWithArray:ar == nil ? @[] : ar];
    
    self.fRecordHighRes = [defs boolForKey:_szKeyPrefRecordHighRes];

    [MFBLocation refreshTakeoffSpeed];
}

#pragma mark - Night flight options
+ (NSString *) nightFlightOptionName:(NightFlightOptions)nf {
    switch (nf) {
        case nfoSunset:
            return NSLocalizedString(@"NFSunset", @"Night flight starts sunset");
        case nfoCivilTwilight:
            return NSLocalizedString(@"NFCivilTwighlight", @"Night flight starts End of civil twilight");
        case nfoSunsetPlus15:
            return NSLocalizedString(@"NFSunsetPlus15", @"Night flight starts Sunset + 15 minutes");
        case nfoSunsetPlus30:
            return NSLocalizedString(@"NFSunsetPlus30", @"Night flight starts Sunset + 30 minutes");
        case nfoSunsetPlus60:
            return NSLocalizedString(@"NFSunsetPlus60", @"Night flight starts Sunset + 60 minutes");
        default:
            return @"";
    }
}
+ (NSString *) nightLandingOptionName:(NightLandingOptions)nl {
    switch (nl) {
        default:
            return @"";
        case nflNight:
            return NSLocalizedString(@"NFLNight", @"Night Landings: Night");
        case nflSunsetPlus60:
            return NSLocalizedString(@"NFLSunsetPlus1Hour", @"Night Landings: 60 minutes after sunset");
    }
}

- (int) NightFlightSunsetOffset {
    switch ([AutodetectOptions nightFlightPref]) {
        case nfoCivilTwilight:
        case nfoSunset:
        case nfoLast:
            return 0;
        case nfoSunsetPlus15:
            return 15;
        case nfoSunsetPlus30:
            return 30;
        case nfoSunsetPlus60:
            return 60;
    }
}

- (BOOL) IsNightForFlight:(SunriseSunset *) sst {
    // short circuit daytime
    if (sst == nil || !sst.isNight)
        return NO;
    
    switch ([AutodetectOptions nightFlightPref]) {
        case nfoCivilTwilight:
            return sst.isCivilNight;
        case nfoSunset:
            return true;    // we already verified that isNight is true above.
        case nfoSunsetPlus15:
        case nfoSunsetPlus30:
        case nfoSunsetPlus60:
            return sst.isWithinNightOffset;
        case nfoLast:
            return NO;
    }
}

#pragma mark CLLocation Management
- (void) setUpLocManager
{
    if (self.locManager == nil)
    {
        NSLog(@"SetUpLocManager");
        
        self.locManager = [[CLLocationManager alloc] init];
        if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
                [self.locManager requestAlwaysAuthorization];
        }
        
        if (![self isLocationServicesEnabled])
        {
            self.locManager = nil;
            return;
        }
        
        self.locManager.delegate = self;
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locManager.distanceFilter = kCLDistanceFilterNone;
        self.locManager.pausesLocationUpdatesAutomatically = YES;
        self.locManager.activityType = CLActivityTypeOtherNavigation;
    }
	
    [self.locManager startUpdatingLocation];
    if ([self.locManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        self.locManager.allowsBackgroundLocationUpdates = YES;
}
                
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.locManager startUpdatingLocation];
    if ([self.locManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)])
        self.locManager.allowsBackgroundLocationUpdates = YES;
}

- (BOOL) isLocationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL) isSignificantChangeMonitoringEnabled
{
    if ([CLLocationManager respondsToSelector:@selector(significantLocationChangeMonitoringAvailable)])
        return [CLLocationManager significantLocationChangeMonitoringAvailable];
    return NO;
}

- (void) recordLocation:(CLLocation *) loc withEvent:(NSString *) szEvent
{
	CLLocationSpeed s = loc.speed * MPS_TO_KNOTS;
	if (flightTrackData != nil && self.fRecordFlightData && !self.fRecordingIsPaused)
	{
		// write a header row if none present
		if ([self.flightTrackData length] == 0)
			[self.flightTrackData appendString:@"LAT,LON,PALT,SPEED,HERROR,DATE,TZOFFSET,COMMENT\r\n"];
		
		NSDateFormatter * df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        NSLocale * locNeutral = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
		NSString * szRow = [[NSString alloc] initWithFormat:@"%.8F,%.8F,%d,%.1F,%.1F,%@,%d,%@\r\n"
                            locale:locNeutral,
                            loc.coordinate.latitude,
                            loc.coordinate.longitude,
                            (int) (loc.altitude * METERS_TO_FEET),
                            s,
                            loc.horizontalAccuracy,
                            [df stringFromDate:loc.timestamp],
                            (int)  - df.timeZone.secondsFromGMT / 60,
                            szEvent];
		[self.flightTrackData appendString:szRow];
	}
}

- (BOOL) recordFlightDataOptionIsOn
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefRecordFlightData];
}

- (void) startRecordingFlightData
{
	if ([self recordFlightDataOptionIsOn])
	{
		if (self.flightTrackData == nil)
			self.flightTrackData = [[NSMutableString alloc] init];
        if (self.rgAllSamples == nil)
            self.rgAllSamples = [NSMutableArray new];
		
		self.fRecordFlightData = YES;
	}
}

- (void) stopRecordingFlightData
{
	NSLog(@"stopRecordingFlightData \r\n");
	self.fRecordFlightData = NO;
}

// Call to cause a state transition.  Don't call multiple times in a row!!
- (FlightState) setFlightState:(FlightState) fs atNight:(BOOL)fIsNightForLandings withNotes:(NSMutableString *) szNotes
{
    if (fs == self.currentFlightState)
        return fs;

    switch (fs) {
        case fsInFlight:
            NSLog(@"setFlightState: Takeoff detected!");
            self.currentFlightState = fsInFlight;
            if (self.delegate != nil)
            {
                if ([self.delegate flightCouldBeInProgress])
                {
                    [szNotes appendFormat:@" %@",[self.delegate takeoffDetected]];
                    if (fIsNightForLandings)
                        [szNotes appendFormat:@" %@",[self.delegate nightTakeoffDetected]];
                }
            }
            break;
        case fsJustLanded:
            if (self.currentFlightState == fsInFlight) // can only come into this state from in-flight.
            {
                self.currentFlightState = fsJustLanded;
                NSLog(@"setFlightState: Landing detected!");
                if (self.delegate != nil && [self.delegate flightCouldBeInProgress])
                    [szNotes appendFormat:@" %@",[self.delegate landingDetected]];
            }
            break;
        case fsOnGround:
            if (self.currentFlightState == fsJustLanded)    // can only come into this state from just landed
            {
                NSLog(@"setFlightState: Full-stop landing!");
                self.currentFlightState = fsOnGround;
                if (self.delegate != nil && [self.delegate flightCouldBeInProgress])
                    [szNotes appendFormat:@" %@",[self.delegate fsLandingDetected:fIsNightForLandings]];
            }
            break;
    }
    return fs;
}

- (void) newLocation:(CLLocation *)newLocation
{
	CLLocationSpeed s = newLocation.speed * MPS_TO_KNOTS;
	CLLocationAccuracy acc = newLocation.horizontalAccuracy;
    NSMutableString * szEvent = [NSMutableString new];
	BOOL fValidSpeed = (s >= 0);
	BOOL fValidQuality = (acc > 0 && acc < MIN_ACCURACY);
	BOOL fValidTime = YES;  // see if enough time has elapsed to record this.
    NSTimeInterval dt = 0;
    BOOL fEnoughSamples = (++self.cSamplesSinceWaking >= BOGUS_SAMPLE_COUNT);
    BOOL fForceRecord = NO; // true to record even a sample that we would otherwise discard.
    static CLLocation * PreviousLoc = nil;
    static BOOL fPreviousLocWasNight = NO;
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    
	self.lastSeenLoc = newLocation; // keep this, even if it's noisy (still useful for nearby airports)
	if (self.currentLoc != nil)
	{
		// get the time interval since the last location
		dt = [newLocation.timestamp timeIntervalSinceDate:self.currentLoc.timestamp];
        NSTimeInterval dtLimit = (self.currentFlightState == fsInFlight) ? MIN_SAMPLE_RATE_AIRBORNE : MIN_SAMPLE_RATE_TAXI;
        fValidTime = (dt > dtLimit);
	}
	else
		self.currentLoc = newLocation; // Initialize with current position if this is our first.
    
    // Sometimes we get bogus speed even with a high reported accuracy; this results in bogus landings.
    // We will reset the samplessincewaking if this happens, to let the GPS catch up.
    // There are two conditions where this is a concern:
    // a) If we are in the FLYING state and we get a 0 speed.
    // b) If we are in the FLYING state and we get a speed under the landing speed, we will do a quick acceleration test.
    //    If we are below the landing speed and the acceleration would imply more than 2G's.
    //    1G = 9.8m/s2 (meter per second squared)
    CLLocationSpeed sLanding = [MFBLocation LandingSpeed];
    FlightState fs = [self currentFlightState];
    if (fs == fsInFlight && s < sLanding && dt > 0 && fEnoughSamples && (s == 0 || fabs((newLocation.speed - currentLoc.speed) / dt) > 2 * 9.8))
    {
        if (s == 0)
            [szEvent appendString:@"Speed of 0.0kts is suspect - discarding "];
        else
            [szEvent appendFormat:@"Acceleration of %0.3f seems suspect ", fabs((newLocation.speed - currentLoc.speed) / dt)];
        fValidQuality = NO;
    }
    
    BOOL fValidSample = fValidSpeed && fValidQuality && fEnoughSamples;
    
	if (fValidSample)
	{
        SunriseSunset * sst = [[SunriseSunset alloc] initWithDate:self.lastSeenLoc.timestamp Latitude:self.lastSeenLoc.coordinate.latitude Longitude:self.lastSeenLoc.coordinate.longitude nightOffset:self.NightFlightSunsetOffset];
        BOOL fAutodetect = [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefAutoDetect];
        
        BOOL fIsNightForFlight = [self IsNightForFlight:sst];
        BOOL fIsNightForLandings = ([AutodetectOptions nightLandingPref] == nflNight) ? fIsNightForFlight : sst.isFAANight;

        if (PreviousLoc != nil && fPreviousLocWasNight && fIsNightForFlight && fAutodetect)
        {
            NSTimeInterval t = [newLocation.timestamp timeIntervalSinceDate:PreviousLoc.timestamp] / 3600.0;    // time is in seconds, convert it to hours
            if (t < .5 && self.delegate.flightCouldBeInProgress)	// limit of half an hour between samples for night time
                [self.delegate addNightTime:t];
        }
        fPreviousLocWasNight = fIsNightForFlight;
        PreviousLoc = lastSeenLoc;

        
        // Autodetection of takeoff/landing
		if (fAutodetect)
		{
            switch (fs)
            {
                case fsInFlight: // In flight - look for a drop below landing speed for a landing
                    if (s < sLanding)
                    {
                        [szEvent appendString:NSLocalizedString(@"Landing", @"In flight telemetry, this is shown next to a landing event")];
                        fs = [self setFlightState:fsJustLanded atNight:fIsNightForLandings withNotes:szEvent];
                        fForceRecord = YES;  // enable recording of this event in telemetry
                    }
                    break;
                case fsJustLanded: // on the ground (touch & go or full stop) - look for a take-off
                case fsOnGround:
                    if (s > [MFBLocation TakeOffSpeed])
                    {
                        [szEvent appendString:NSLocalizedString(@"Takeoff", @"In flight telemetry, this is shown to indicate a takeoff event")];
                        [self startRecordingFlightData];
                        fs = [self setFlightState:fsInFlight atNight:fIsNightForLandings withNotes:szEvent];
                        fForceRecord = YES;  // enable recording of this event in telemetry
                    }
                    break;
            }
            
            // see if we've had a full-stop landing
            if (fs == fsJustLanded && s < FULL_STOP_SPEED)
            {
                [szEvent appendFormat:NSLocalizedString(@"Full-stop %@landing", @"If a full-stop landing is detected, this is written into the comments for flight telemetry.  the %@ is replaced either with nothing or with 'night' to indicate a night landing"), fIsNightForLandings ? NSLocalizedString(@"night ", @"Night as an adjective - i.e., a night landing") : @""];
                fs = [self setFlightState:fsOnGround atNight:fIsNightForLandings withNotes:szEvent];
                fForceRecord = YES;  // enable recording of this event in telemetry
            }
		}
        
        if (app.fDebugMode)
        {
            if ([szEvent length] == 0)
                [szEvent appendFormat:@"%@ %@",
                           (fs == fsInFlight) ? @"Flying" : (fs == fsJustLanded ? @"Landed" : @"Taxiing"),
                           fValidTime ? @"" : @"---"];
        }
	}
    else
        [szEvent appendFormat:@"DEBUG - BOGUS SAMPLE: speed %.1f acc=%.1f samples: %ld", s, acc, (long)self.cSamplesSinceWaking];
    
    BOOL fRecordable = [self.delegate flightCouldBeInProgress] && self.fRecordFlightData;
    
    // record this if appropriate - we do the valid time check here to avoid too tightly clustered
    // samples, but any event (landing/takeoff) will set it to be true.
    if (app.fDebugMode || self.fRecordHighRes || (fRecordable && (fForceRecord || (fValidTime && fValidSample))))
        [self recordLocation:newLocation withEvent:szEvent];
    
    if (fRecordable)
        [self.rgAllSamples addObject:[NSString stringWithFormat:@"%.8F\t%.8F\t%.1F\t%.2F\t%F", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.altitude, newLocation.speed, [newLocation.timestamp timeIntervalSince1970]]];
    
    if (fForceRecord)
        [self saveState];
    
    // update to the new location if it was a good sample and valid time
    if (fValidTime && fValidSample)
        self.currentLoc = newLocation;
	
	// pass on the update event to any location delegate, regardless of quality
	if (self.delegate != nil)
		[self.delegate newLocation:newLocation];
    
    // Update watch data
    SharedWatch * sw = app.watchData;
    BOOL fSendUpdate = (sw.latDisplay == nil || sw.latDisplay.length == 0);
    sw.latDisplay = [MFBLocation latitudeDisplay:lastSeenLoc.coordinate.latitude];
    sw.lonDisplay = [MFBLocation longitudeDisplay:lastSeenLoc.coordinate.longitude];
    sw.flightstatus = [MFBLocation flightStateDisplay:self.currentFlightState];
    sw.speedDisplay = [MFBLocation speedDisplay:lastSeenLoc.speed * MPS_TO_KNOTS];
    sw.altDisplay = [MFBLocation altitudeDisplay:lastSeenLoc];
    if (fSendUpdate)
        [app updateWatchContext];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation * loc in locations)
    {
#ifdef DEBUG
        if (self.fIsBlessed)
            NSLog(@"Received REAL location %8f, %8f", loc.coordinate.latitude, loc.coordinate.longitude);
#endif
        [self newLocation:loc];
    }
}

#pragma mark Location Information
+ (int) TakeOffSpeed
{
    return vTakeOff;
}

+ (int) LandingSpeed
{
    return vLanding;
}

#pragma mark FlightData
- (void) resetFlightData
{
    self.flightTrackData = [[NSMutableString alloc] init];
    self.rgAllSamples = [NSMutableArray new];
    self.currentFlightState = fsOnGround;
    [self saveState];
}

- (NSString *) flightDataAsString
{
    return [NSString stringWithString:self.flightTrackData];
}

#pragma mark GPX
- (NSString *)gpxFilePath
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"log_%@.gpx", dateString];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

- (NSString *)gpxData
{
    NSMutableArray * arCoords = [NSMutableArray new];
    
    // gpx > trk > trkseg > trkpt
    for (NSString * szCoord in self.rgAllSamples)
    {
        NSArray * rgCoords = [szCoord componentsSeparatedByString:@"\t"];
        if (rgCoords.count == 5)
        {
            double lat = ((NSString *)rgCoords[0]).doubleValue;
            double lon = ((NSString *)rgCoords[1]).doubleValue;
            double alt = ((NSString *)rgCoords[2]).doubleValue;
            double speed = ((NSString *)rgCoords[3]).doubleValue;
            NSDate * dt = [NSDate dateWithTimeIntervalSince1970:((NSString *)rgCoords[4]).doubleValue];
            
            CLLocation * cl = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(lat, lon) altitude:alt horizontalAccuracy:0 verticalAccuracy:0 course:0 speed:speed timestamp:dt];
            [arCoords addObject:cl];
        }
    }
    
    return [GPXTelemetry serializeFromPath:arCoords];
}

- (NSString *) writeToFile:(NSString *) szData
{
    // write gpx to file
    NSError *error;
    NSString *filePath = [self gpxFilePath];
    if (![szData writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (error) {
            NSLog(@"error, %@", error);
        }
        
        return nil;
    }
    
    return filePath;
}


#pragma mark Display
+ (NSString *) altitudeDisplay:(CLLocation *) loc
{
    return [NSString localizedStringWithFormat:@"%d%@",  (int) round(loc.altitude * METERS_TO_FEET), NSLocalizedString(@"ft", "Feet")];
}

+ (NSString *) speedDisplay: (CLLocationSpeed) s
{
    // Negative speeds are stupid.
    if (s < 0)
        s = 0;
    return [NSString localizedStringWithFormat:NSLocalizedString(@"%.1fkts", @"Speed in knots.  '%.1f' is replaced by the actual speed; leave it there."), s];
}

+ (NSString *) latitudeDisplay:(double) lat
{
    return [NSString stringWithFormat:@"%.3f°%@", ABS(lat), lat > 0 ? @"N" : @"S"];
}

+ (NSString *) longitudeDisplay: (double) lon
{
    return [NSString stringWithFormat:@"%.3f°%@", ABS(lon), lon > 0 ? @"E" : @"W"];
}


+ (NSString *) flightStateDisplay: (FlightState) fs
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefAutoDetect])
    {
        switch (fs)
        {
            case fsInFlight:
                return NSLocalizedString(@"In Flight", @"Flight status");
                break;
            case fsOnGround:
            case fsJustLanded:
                return NSLocalizedString(@"On Ground", @"Flight status");
                break;
        }
    }
    else
        return NSLocalizedString(@"(unknown)", @"Not sure if we are in flight or on the ground");
    
}
@end
