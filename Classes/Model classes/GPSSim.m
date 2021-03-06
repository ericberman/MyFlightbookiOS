/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2019 MyFlightbook, LLC
 
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
//  Copyright 2011-2019 MyFlightbook LLC. All rights reserved.
//

#import "GPSSim.h"
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

- (void) FeedEventsFromTelemetry:(Telemetry *) t
{
    @autoreleasepool {
        NSArray * rgCoords = t.samples;
        
        if (t.lastError.length > 0 || rgCoords.count == 0)
            return;
        
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

+ (LogbookEntry *) ImportTelemetry:(NSURL *) url
{
    LogbookEntry * le = [LogbookEntry new];
    le.entryData = [MFBWebServiceSvc_LogbookEntry getNewLogbookEntry];
    le.entryData.AircraftID = [NSNumber numberWithInteger:Aircraft.sharedAircraft.DefaultAircraftID];
    Telemetry * t = [Telemetry telemetryWithURL:url];
    if (t == nil)
        return nil;
    MFBLocation * loc = [MFBLocation new];
    loc.fUpdatesTheme = NO;
    GPSSim * sim = [[GPSSim alloc] initWithLoc:loc delegate:le.entryData];
    sim.noDelayOnBackground = YES;
    [sim FeedEventsFromTelemetry:t];
    if (t.lastError.length > 0)
        le.errorString = t.lastError;
    
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
@end
