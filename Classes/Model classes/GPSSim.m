/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2022 MyFlightbook, LLC
 
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
//  GPSSim.m
//  MFBSample
//
//  Created by Eric Berman on 7/29/11.
//  Copyright 2011-2021 MyFlightbook LLC. All rights reserved.
//

#import "GPSSim.h"
#import "FlightProps.h"
#import "Airports.h"
#import "MFBAppDelegate.h"
#import "Telemetry.h"
#import "LogbookEntry.h"
#import "Airports.h"

@interface GPSSim()
@property (strong) MFBLocation * mfbloc;
@property (strong) MFBWebServiceSvc_LogbookEntry * leDelegate;
@property (nonatomic) BOOL noDelayOnBackground;
@end

@implementation GPSSim
@synthesize mfbloc, leDelegate;
@synthesize noDelayOnBackground;

- (instancetype) init
{
    if (self = [super init])
    {
        self.mfbloc = [MFBAppDelegate threadSafeAppDelegate].mfbloc;
        self.leDelegate = nil;
        self.noDelayOnBackground = NO;
    }
    return self;
}

- (instancetype) initWithLoc:(MFBLocation *) loc delegate:(MFBWebServiceSvc_LogbookEntry *) delegate
{
    if (self = [self init])
    {
        self.mfbloc = loc;
        [self.mfbloc stopUpdatingLocation];
        self.leDelegate = delegate;
        self.mfbloc.delegate = self.leDelegate;
    }
    return self;
}

- (void) FeedEvent:(CLLocation *) loc
{
    [self.mfbloc feedEvent:loc];
}

- (NSDate *) FeedEventsFromTelemetry:(Telemetry *) t
{
    @autoreleasepool {
        NSArray<CLLocation *> * rgCoords = t.samples;
        
        if (t.lastError.length > 0 || rgCoords.count == 0)
            return nil;
        
        // Push the current MFBLocation "onto the stack" as it were - replace the global one for the duration.
        MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
        MFBLocation * globalLoc = app.mfbloc;
        if (self.mfbloc != nil)
            app.mfbloc = self.mfbloc;
        
        // make sure we don't get spurious location updates from the real GPS
        [self.mfbloc stopUpdatingLocation];
        self.mfbloc.currentLoc = self.mfbloc.lastSeenLoc = nil;  // so that dates in the past work when using sim.
        
        if (self.leDelegate != nil)
        {
            CLLocation * firstLoc = (CLLocation *) rgCoords[0];
            self.mfbloc.currentLoc = self.mfbloc.lastSeenLoc = firstLoc;
            
            // start the flight on the first sample
            if (t.hasSpeed)
                // Issue #151: drop seconds from engine start/end
                self.leDelegate.Date = self.leDelegate.EngineStart = firstLoc.timestamp.dateByTruncatingSeconds;
            else
            {
                self.leDelegate.Date = [NSDate date];
                self.leDelegate.Route = [Airports appendNearestAirport:@""];
            }
        }

        BOOL fIsMainThread = [NSThread isMainThread];   // save a method call on each iteration.
        NSLog(@"GPSSim: Starting telemetry feed %@", fIsMainThread ? @" on main thread " : @" on background thread");
        
        for (CLLocation * loc in rgCoords)
        {
            globalLoc.lastSeenLoc = loc;
            if (self.leDelegate != nil)
                globalLoc.currentLoc = loc;
            if (fIsMainThread || self.noDelayOnBackground)
                [self FeedEvent:loc];
            else
            {
                [self performSelectorOnMainThread:@selector(FeedEvent:) withObject:loc waitUntilDone:YES];
                [NSThread sleepForTimeInterval:0.05];
            }
        }
        
        NSLog(@"GPSSim: Ending telemetry feed");
        
        if (self.leDelegate != nil)
        {
            CLLocation * lastLoc = (CLLocation *) rgCoords[rgCoords.count - 1];
            if (t.hasSpeed)
            {
                // Issue #151: drop seconds from engine start/end
                self.leDelegate.EngineEnd = lastLoc.timestamp.dateByTruncatingSeconds;
                self.leDelegate.FlightData = self.mfbloc.flightDataAsString;
            }
            else
            {
                self.leDelegate.Route = [Airports appendNearestAirport:self.leDelegate.Route];
                self.leDelegate.FlightData = t.szRawData;
            }
        }

        // restore the global Location manager.
        self.mfbloc = nil;
        MFBAppDelegate.threadSafeAppDelegate.mfbloc = globalLoc;    // restore the prior loc manager (which could be what we've been using!)
        [globalLoc startUpdatingLocation]; // and resume updates
        
        return rgCoords[rgCoords.count - 1].timestamp;
    }
}

+ (void) BeginSim
{
    enum ImportedFileType ft = CSV;
    NSString * szCSVFilePath = @"";
    Telemetry * t = nil;
    switch (ft)
    {
        default:
        case Unknown:
        case CSV:
            szCSVFilePath = [[NSBundle mainBundle] pathForResource:@"GPSSamples" ofType:@"csv"];
            t = [[CSVTelemetry alloc] initWithString:[NSString stringWithContentsOfFile:szCSVFilePath encoding:NSUTF8StringEncoding error:nil]];
            break;
        case GPX:
            szCSVFilePath = [[NSBundle mainBundle] pathForResource:@"tracklog" ofType:@"gpx"];
            t = [[GPXTelemetry alloc] initWithString:[NSString stringWithContentsOfFile:szCSVFilePath encoding:NSUTF8StringEncoding error:nil]];
            break;
        case KML:
            szCSVFilePath = [[NSBundle mainBundle] pathForResource:@"tracklog" ofType:@"kml"];
            t = [[KMLTelemetry alloc] initWithString:[NSString stringWithContentsOfFile:szCSVFilePath encoding:NSUTF8StringEncoding error:nil]];
            break;
    }
    
    GPSSim * sim = [[GPSSim alloc] init];
    [NSThread detachNewThreadSelector:@selector(FeedEventsFromTelemetry:) toTarget:sim withObject:t];
}

+ (NSDate *) autoFill:(LogbookEntry *) le fromTelemetry: (Telemetry *) t allowRecording:(BOOL) fAllowRecord {
    MFBLocation * loc = [MFBLocation new];
    loc.fUpdatesTheme = NO;
    if (!fAllowRecord)
        loc.fSuppressAllRecording = YES;

    GPSSim * sim = [[GPSSim alloc] initWithLoc:loc delegate:le.entryData];
    sim.noDelayOnBackground = YES;
    NSDate * final = [sim FeedEventsFromTelemetry:t];
    if (t.lastError.length > 0)
        le.errorString = t.lastError;
    return final;
}

+ (LogbookEntry *) ImportTelemetry:(NSURL *) url {
    LogbookEntry * le = [LogbookEntry new];
    le.entryData = [MFBWebServiceSvc_LogbookEntry getNewLogbookEntry];
    le.entryData.AircraftID = [NSNumber numberWithInteger:Aircraft.sharedAircraft.DefaultAircraftID];
    Telemetry * t = [Telemetry telemetryWithURL:url];
    if (t == nil)
        return nil;
    
    [GPSSim autoFill:le fromTelemetry:t allowRecording:YES];
    
    if (t.metaData[TELEMETRY_META_AIRCRAFT_TAIL] != nil) {
        Aircraft * aircraft = [Aircraft sharedAircraft];
        MFBWebServiceSvc_Aircraft * ac = [aircraft AircraftByTail:(NSString *) t.metaData[TELEMETRY_META_AIRCRAFT_TAIL]];
        if (ac != nil)
            le.entryData.AircraftID = ac.AircraftID;
    }

    le.entryData.FlightID = QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
    [MFBAppDelegate.threadSafeAppDelegate performSelectorOnMainThread:@selector(queueFlightForLater:) withObject:le waitUntilDone:NO];

    return le;
}

+ (void) autoFill:(LogbookEntry *) le {
    if (le == nil || le.entryData == nil)
        return;
    
    Telemetry * t = nil;
    
    NSDate * blockOut = nil;
    NSDate * blockIn = nil;
    
    for (MFBWebServiceSvc_CustomFlightProperty * cfp in le.entryData.CustomProperties.CustomFlightProperty) {
        if (cfp.PropTypeID.integerValue == PropTypeID_BlockOut)
            blockOut = cfp.DateValue;
        if (cfp.PropTypeID.integerValue == PropTypeID_BlockIn)
            blockIn = cfp.DateValue;
    }
    
    // blockIn / blockOut here is not strictly block in/out, it's just "Best guess start / end"
    if (blockOut == nil)
        blockOut = le.entryData.isKnownEngineStart ? le.entryData.EngineStart : (le.entryData.isKnownFlightStart ? le.entryData.FlightStart : nil);

    if (blockIn == nil)
        blockIn = le.entryData.isKnownEngineEnd ? le.entryData.EngineEnd : (le.entryData.isKnownFlightEnd ? le.entryData.FlightEnd : nil);
    
    BOOL fSetXC = NO;
    BOOL fSyntheticPath = NO;
    BOOL fSetNight = NO;
    
    if (le.entryData.FlightData == nil || le.entryData.FlightData.length == 0) {
        if (blockOut != nil && blockIn != nil) {
            // generate synthetic path IF we have exactly two airports
            Airports * ap = [Airports new];
            fSetXC = ([ap maxDistanceOnRoute:le.entryData.Route] > CROSS_COUNTRY_THRESHOLD);    // maxDistanceOnRoute will call loadAirports.
            
            // issue #286: don't do a synthetic path if autodetection is off because it will clear a bunch of fields but won't fill them back in.
            if (ap.rgAirports.count == 2 && AutodetectOptions.autodetectTakeoffs) {
                t = [Telemetry synthesizePathFrom:ap.rgAirports[0].LatLong.coordinate to:ap.rgAirports[1].LatLong.coordinate start:blockOut end:blockIn];
                fSyntheticPath = (t != nil);
                if (fSyntheticPath) {
                    if (!le.entryData.isKnownEngineStart)
                        le.entryData.EngineStart = [NSDate dateWithTimeInterval:0 sinceDate:blockOut];  // use datewithtimeinterval to create a new copy, not a reference.
                }
            }
        }
    } else {
        t = [Telemetry telemetryWithString:le.entryData.FlightData];
        le.entryData.FlightStart = le.entryData.FlightEnd = nil;    // we will recompute these
    }
    
    // We now have telemetry (either measured or synthesized).
    if (t != nil) {
        // Clear all of the things that can be computed
        NSDate * dtEngineSaved = le.entryData.EngineEnd;    // clear this so that flight will appear to be in progress
        le.entryData.EngineEnd = nil;
        le.entryData.Route = @"";
        le.entryData.TotalFlightTime = @(0.0);
        le.entryData.CrossCountry = @(0.0);
        le.entryData.Nighttime = @(0.0);
        le.entryData.Landings = @(0);
        le.entryData.FullStopLandings = @(0);
        le.entryData.NightLandings = @(0);
        [le.entryData removeProperty:@PropTypeID_NightTakeOff];
        fSetNight = YES;
        
        NSString * szDataSaved = le.entryData.FlightData;
        NSDate * tsFinal = [GPSSim autoFill:le fromTelemetry:t allowRecording:NO];
        
        // close off engine end if we don't have one that we saved.
        if ([NSDate isUnknownDate:dtEngineSaved])
            dtEngineSaved = tsFinal;
        le.entryData.EngineEnd = dtEngineSaved;   // restore engine end.  If synthetic path, this will be overwritten below anyhow.
        le.entryData.FlightData = szDataSaved;    // Restore flight data.  If synthetic path, this will be overwritten below anyhow.
    }
    
    if (fSyntheticPath) {
        le.entryData.FlightData = @"";
        if (!le.entryData.isKnownEngineEnd)
            le.entryData.EngineEnd = [NSDate dateWithTimeInterval:0 sinceDate:blockIn];
    }

    // Autototal based on any of the above
    double dtTotal = (le.entryData.HobbsEnd.doubleValue > le.entryData.HobbsStart.doubleValue && le.entryData.HobbsStart.doubleValue > 0) ?
        // hobbs has priority, if present
        le.entryData.HobbsEnd.doubleValue - le.entryData.HobbsStart.doubleValue :
        ((blockIn != nil && blockOut != nil && [blockIn compare:blockOut] == NSOrderedDescending) ? [blockIn timeIntervalSinceDate:blockOut] / 3600.0 : 0.0);
    
    if ([AutodetectOptions roundTotalToNearestTenth]) {
        dtTotal = round(dtTotal * 10.0) / 10.0;
        if (fSetNight)
            le.entryData.Nighttime = @(round(le.entryData.Nighttime.doubleValue * 10.0) / 10.0);
    }

    if (le.entryData.TotalFlightTime.doubleValue == 0)
        le.entryData.TotalFlightTime = @(dtTotal);
    
    // And autohobbs, if appropriate.
    [le autoFillHobbs];
    
    if (fSetXC)
        le.entryData.CrossCountry = @(le.entryData.TotalFlightTime.doubleValue);
    
    [le autoFillFinish];
}
@end
