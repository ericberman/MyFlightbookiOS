/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2020 MyFlightbook, LLC
 
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
//  SharedWatch.m
//  MFBSample
//
//  Created by Eric Berman on 10/29/15.
//
//

#import "SharedWatch.h"

#define keyWatchLatitude @"LAT"
#define keyWatchLongitude @"LON"
#define keyWatchSpeed @"SPEED"
#define keyWatchAlt @"ALT"
#define keyWatchFlightStatus @"FLIGHTSTATUS"
#define keyWatchElapsed @"FLIGHTELAPSED"
#define keyWatchIsPaused @"FLIGHTPAUSED"
#define keyWatchIsRecording @"FLIGHTRECORDING"
#define keyWatchFlightStage @"FlightStage"
#define keyWatchLatestFlight @"LASTFLIGHT"

@implementation SharedWatch

@synthesize latDisplay, lonDisplay, speedDisplay, altDisplay, flightstatus, isPaused, isRecording, elapsedSeconds, flightStage;

- (instancetype) init {
    if (self = [super init])
    {
        self.latDisplay = self.lonDisplay = self.speedDisplay = self.altDisplay = self.flightstatus = @"";
        self.isPaused = self.isRecording = NO;
        self.flightStage = flightStageUnknown;
        self.latestFlight = nil;
    }
    return self;
}

-(void) dealloc{
    self.latDisplay = self.lonDisplay = self.speedDisplay = self.altDisplay = self.flightstatus = nil;
}

+ (BOOL)supportsSecureCoding {return YES;}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self.latDisplay = [aDecoder decodeObjectForKey:keyWatchLatitude];
    self.lonDisplay = [aDecoder decodeObjectForKey:keyWatchLongitude];
    self.altDisplay = [aDecoder decodeObjectForKey:keyWatchAlt];
    self.speedDisplay = [aDecoder decodeObjectForKey:keyWatchSpeed];
    self.flightstatus = [aDecoder decodeObjectForKey:keyWatchFlightStatus];
    self.latestFlight = [aDecoder decodeObjectForKey:keyWatchLatestFlight];
    self.isPaused = [aDecoder decodeBoolForKey:keyWatchIsPaused];
    self.isRecording = [aDecoder decodeBoolForKey:keyWatchIsRecording];
    self.elapsedSeconds = [aDecoder decodeDoubleForKey:keyWatchElapsed];
    self.flightStage = [aDecoder decodeIntegerForKey:keyWatchFlightStage];
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.latDisplay forKey:keyWatchLatitude];
    [aCoder encodeObject:self.lonDisplay forKey:keyWatchLongitude];
    [aCoder encodeObject:self.altDisplay forKey:keyWatchAlt];
    [aCoder encodeObject:self.speedDisplay forKey:keyWatchSpeed];
    [aCoder encodeObject:self.flightstatus forKey:keyWatchFlightStatus];
    [aCoder encodeObject:self.latestFlight forKey:keyWatchLatestFlight];
    [aCoder encodeBool:self.isPaused forKey:keyWatchIsPaused];
    [aCoder encodeBool:self.isRecording forKey:keyWatchIsRecording];
    [aCoder encodeDouble:self.elapsedSeconds forKey:keyWatchElapsed];
    [aCoder encodeInteger:self.flightStage forKey:keyWatchFlightStage];
}
@end

#pragma mark SimpleCurrencyItem
#define keyCurAttribute @"curAttribute"
#define keyCurValue @"curValue"
#define keyCurDiscrepancy @"curDiscrepancy"
#define keyCurState @"curState"

@implementation SimpleCurrencyItem

@synthesize attribute, value, discrepancy, state;

- (instancetype) init {
    if (self = [super init])
    {
        self.attribute = self.value = self.discrepancy = @"";
        self.state = MFBWebServiceSvc_CurrencyState_none;
    }
    return self;
}

+ (BOOL)supportsSecureCoding {return YES;}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.attribute forKey:keyCurAttribute];
    [aCoder encodeObject:self.value forKey:keyCurValue];
    [aCoder encodeObject:self.discrepancy forKey:keyCurDiscrepancy];
    [aCoder encodeInteger:self.state forKey:keyCurState];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self.attribute = [aDecoder decodeObjectForKey:keyCurAttribute];
    self.value = [aDecoder decodeObjectForKey:keyCurValue];
    self.discrepancy = [aDecoder decodeObjectForKey:keyCurDiscrepancy];
    self.state =  (MFBWebServiceSvc_CurrencyState) [aDecoder decodeIntegerForKey:keyCurState];
    return self;
}

@end

#pragma mark SimpleTotalItem

#define keyTotalTitle @"totTitle"
#define keyTotalValue @"totValue"
#define keyTotalSubDesc @"totSubDesc"

@implementation SimpleTotalItem

@synthesize title, valueDisplay, subDesc;

- (instancetype) init {
    if (self = [super init])
    {
        self.title = self.valueDisplay = self.subDesc = @"";
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:keyTotalTitle];
    [aCoder encodeObject:self.valueDisplay forKey:keyTotalValue];
    [aCoder encodeObject:self.subDesc forKey:keyTotalSubDesc];
}

+ (BOOL)supportsSecureCoding {return YES;}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self.title = [aDecoder decodeObjectForKey:keyTotalTitle];
    self.valueDisplay = [aDecoder decodeObjectForKey:keyTotalValue];
    self.subDesc = [aDecoder decodeObjectForKey:keyTotalSubDesc];
    return self;
}

@end

#pragma mark SimpleLogbookEntry

#define keyLEComment @"LEComment"
#define keyLERoute @"LERoute"
#define keyLEDate @"LEDate"
#define keyLETotal @"LETotal"
#define keyLETailDisplay @"LETail"

@implementation SimpleLogbookEntry

@synthesize Comment, Route, Date, TotalTimeDisplay, TailNumDisplay;

- (instancetype) init {
    if (self = [super init]) {
        self.Comment = self.Route = self.TotalTimeDisplay = @"";
        self.Date = [NSDate date];
    }
    return self;
}

+ (BOOL)supportsSecureCoding {return YES;}


- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.Comment forKey:keyLEComment];
    [aCoder encodeObject:self.Route forKey:keyLERoute];
    [aCoder encodeObject:self.Date forKey:keyLEDate];
    [aCoder encodeObject:self.TotalTimeDisplay forKey:keyLETotal];
    [aCoder encodeObject:self.TailNumDisplay forKey:keyLETailDisplay];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self.Comment = [aDecoder decodeObjectForKey:keyLEComment];
    self.Route = [aDecoder decodeObjectForKey:keyLERoute];
    self.Date = [aDecoder decodeObjectForKey:keyLEDate];
    self.TotalTimeDisplay = [aDecoder decodeObjectForKey:keyLETotal];
    self.TailNumDisplay = [aDecoder decodeObjectForKey:keyLETailDisplay];
    return self;
}
@end
