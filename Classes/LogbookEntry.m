/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  LogbookEntry.m
//  MFBSample
//
//  Created by Eric Berman on 12/2/09.
//  Copyright 2009-2017, MyFlightbook LLC. All rights reserved.
//

#import "LogbookEntry.h"
#import "MFBAsyncOperation.h"
#import "CommentedImage.h"
#import "FlightProps.h"
#import "Util.h"
#import "Airports.h"
#import "DecimalEdit.h"

@interface LogbookEntry ()
@end

@implementation LogbookEntry

@synthesize entryData;
@synthesize rgPicsForFlight;
@synthesize szAuthToken;
@synthesize errorString;
@synthesize rgPathLatLong;
@synthesize dtTotalPauseTime, dtTimeOfLastPause, accumulatedNightTime;
@synthesize fIsPaused;
@synthesize postingOptions;
@synthesize progressLabel;
@synthesize propsHaveBeenDownloaded;
@synthesize gpxPath;

// keys for preferences.
NSString * const _szkeyHasSavedState = @"pref_leSavedState";
NSString * const _szkeySavedLE = @"pref_savedLE2";
NSString * const _szkeyFlightID = @"pref_leFlightID";
NSString * const _szkeyAircraftID = @"pref_leAircraftID";
NSString * const _szkeyApproaches = @"pref_leApproaches";
NSString * const _szkeyCFI = @"pref_leCFI";
NSString * const _szkeyComment = @"pref_leComment";
NSString * const _szkeyCrossCountry = @"pref_leCrossCountry";
NSString * const _szkeyDate = @"pref_leDate";
NSString * const _szkeyDual = @"pref_leDual";
NSString * const _szkeyEngineEnd = @"pref_leengineEnd";
NSString * const _szkeyEngineStart = @"pref_leengineStart";
NSString * const _szkeyFlightEnd = @"pref_leflightEnd";
NSString * const _szkeyFlightStart = @"pref_leflightStart";
NSString * const _szkeyFullStopLandings = @"pref_lefullStopLandings";
NSString * const _szkeyHobbsEnd = @"pref_lehobbsEnd";
NSString * const _szkeyHobbsStart = @"pref_lehobbsStart";
NSString * const _szkeyIMC = @"pref_leactualIMC";
NSString * const _szkeyLandings = @"pref_letotalLandings";
NSString * const _szkeyNight = @"pref_leNight";
NSString * const _szkeyNightLandings = @"pref_lenightLandings";
NSString * const _szkeyPIC = @"pref_lePIC";
NSString * const _szkeyRoute = @"pref_leRoute";
NSString * const _szkeySIC = @"pref_leSIC";
NSString * const _szkeySimulatedIFR = @"pref_lesimIFR";
NSString * const _szkeyGroundSim = @"pref_leGroundSim";
NSString * const _szkeyTotalFlight = @"pref_letotalFlight";
NSString * const _szkeyUser = @"pref_leUser";
NSString * const _szkeyHolding = @"pref_lefHolding";
NSString * const _szkeyIsPublic = @"pref_leisPublic";
NSString * const _szKeyFlightData = @"pref_leFlightData";
NSString * const _szKeyCatClassOverride = @"pref_leCatClassOverride";
NSString * const _szKeyCustomProperties = @"pref_leCustProperties";

NSString * const _szKeyPendingFlightsArray = @"pref_pendingFlightsArray";

NSString * const _szkeyEntryData = @"_keyEntryData";
NSString * const _szkeyTweet = @"_keyTweet";
NSString * const _szkeyFaceBook = @"_keyFacebook";
NSString * const _szkeyImages = @"_keyImageArray";

NSString * const _szkeyIsPaused = @"_keyIsPaused";
NSString * const _szkeyPausedTime = @"_pausedTime";
NSString * const _szkeyLastPauseTime = @"_lastPauseTime";
NSString * const _szkeyAccumulatedNightTime = @"_accumulatedNightTime";

// Posting options
NSString * const _szkeyPostingOptions = @"_poPostingOptions";
NSString * const _szkeyPOFacebook = @"_poPostFacebook";
NSString * const _szkeyPOTwitter = @"_poPostTwitter";

#define CONTEXT_FLAG_COMMIT 40382

#pragma mark Object Lifecycle
- (instancetype)init
{   
    self = [super init];
	if (self != nil)
	{
		self.entryData = [MFBWebServiceSvc_LogbookEntry getNewLogbookEntry];
        self.postingOptions = [MFBWebServiceSvc_PostingOptions new];
        self.postingOptions.PostToFacebook = [[USBoolean alloc] initWithBool:NO];
        self.postingOptions.PostToTwitter = [[USBoolean alloc] initWithBool:NO];
		self.rgPathLatLong = nil;
		self.rgPicsForFlight = [[NSMutableArray alloc] init]; // No need to release earlier one, accessor method will release it and retain this one
		self.errorString = @"";
        self.fIsPaused = NO;
        self.dtTotalPauseTime = self.dtTimeOfLastPause = 0;
        self.accumulatedNightTime = 0.0;
	}
	return self;
}


#pragma mark Pause flight
- (NSTimeInterval) timeSinceLastPaused
{
    if (self.fIsPaused)
        return [[NSDate date] timeIntervalSinceReferenceDate] - self.dtTimeOfLastPause;
    else
        return 0;
}

- (NSTimeInterval) totalTimePaused
{
    return self.dtTotalPauseTime + [self timeSinceLastPaused];
}

- (void) pauseFlight
{
    self.dtTimeOfLastPause = [[NSDate date] timeIntervalSinceReferenceDate];
    self.fIsPaused = YES;
}

- (void) unPauseFlight
{
    if (self.fIsPaused)
    {
        self.dtTotalPauseTime += [self timeSinceLastPaused];
        self.fIsPaused = NO; // do this AFTER calling [self timeSinceLastPaused]
    }
}

#pragma mark Commit/delete/retrieve flight
-(void) commitFlight
{
	NSLog(@"CommitFlight called");
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	
    // check for videos without WiFi
    if (![CommentedImage canSubmitImages:self.rgPicsForFlight])
    {
        self.errorString = NSLocalizedString(@"ErrorNeedWifiForVids", @"Can't upload with videos unless on wifi");
        [self operationCompleted:sc];
        return;
    }
    
	MFBWebServiceSvc_CommitFlightWithOptions * commitFlight = [[MFBWebServiceSvc_CommitFlightWithOptions alloc] init];

	commitFlight.le = self.entryData;
	commitFlight.po = self.postingOptions;
	commitFlight.szAuthUserToken = self.szAuthToken;
    
	// Date in the entry data was done in local time; will be converted here to UTC, which could be different from
	// actual date of flight.
	// We only really have to do this because we have a mix of UTC and "local" dates
	// SOOO....
	// adjust the date to a UTC date that looks like the right date
	commitFlight.le.Date = [MFBSoapCall UTCDateFromLocalDate:commitFlight.le.Date];
    
    sc.contextFlag = CONTEXT_FLAG_COMMIT;

    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b CommitFlightWithOptionsAsyncUsingParameters:commitFlight delegate:sc];
    }];
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_CommitFlightWithOptionsResponse class]])
	{
		MFBWebServiceSvc_CommitFlightWithOptionsResponse * resp = (MFBWebServiceSvc_CommitFlightWithOptionsResponse *) body;
		self.entryData = resp.CommitFlightWithOptionsResult;
		retVal = YES;
	}
	if ([body isKindOfClass:[MFBWebServiceSvc_DeleteLogbookEntryResponse class]])
	{
		MFBWebServiceSvc_DeleteLogbookEntryResponse * resp = (MFBWebServiceSvc_DeleteLogbookEntryResponse *) body;
		retVal = resp.DeleteLogbookEntryResult.boolValue;
	}
	if ([body isKindOfClass:[MFBWebServiceSvc_FlightPathForFlightResponse class]])
	{
		MFBWebServiceSvc_FlightPathForFlightResponse * resp = (MFBWebServiceSvc_FlightPathForFlightResponse *) body;
		self.rgPathLatLong = resp.FlightPathForFlightResult;
		retVal = YES;
	}
    if ([body isKindOfClass:[MFBWebServiceSvc_FlightPathForFlightGPXResponse class]])
    {
        MFBWebServiceSvc_FlightPathForFlightGPXResponse * resp = (MFBWebServiceSvc_FlightPathForFlightGPXResponse *) body;
        self.gpxPath = resp.FlightPathForFlightGPXResult;
        retVal = YES;
    }
}

- (void) submitImagesWorker:(MFBSoapCall *) sc
{
    @autoreleasepool {
        if ([sc.errorString length] == 0)
        {
            [CommentedImage uploadImages:self.rgPicsForFlight withStatusLabel:self.progressLabel toPage:MFBFLIGHTIMAGEUPLOADPAGE authString:self.szAuthToken keyName:MFB_KEYFLIGHTIMAGE	keyValue:[self.entryData.FlightID stringValue]];
            // If this was a pending flight, it will be in the pending flight list.  Remove it, if so.
            [[MFBAppDelegate threadSafeAppDelegate] dequeuePendingFlight:self];
        }
        [self performSelectorOnMainThread:@selector(operationCompleted:) withObject:sc waitUntilDone:NO];
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;

    if (sc.contextFlag == CONTEXT_FLAG_COMMIT)
        [NSThread detachNewThreadSelector:@selector(submitImagesWorker:) toTarget:self withObject:sc];
    else
        [self operationCompleted:sc];
}

- (void) deleteFlight:(NSInteger)idFlight
{
	NSLog(@"deleteFlight called");

	retVal = NO;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	
	MFBWebServiceSvc_DeleteLogbookEntry * de = [[MFBWebServiceSvc_DeleteLogbookEntry alloc] init];
	de.szAuthUserToken = self.szAuthToken;
	de.idFlight = @(idFlight);

    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b DeleteLogbookEntryAsyncUsingParameters:de delegate:sc];
    }];
}

- (void) getPathFromInProgressTelemetry:(NSString *) szTelemetry
{
    if (szTelemetry == nil)
        return;

    self.rgPathLatLong = [[MFBWebServiceSvc_ArrayOfLatLong alloc] init];
    
    NSArray * rgRows = [szTelemetry componentsSeparatedByString:@"\n"];
    
    if (rgRows == nil || [rgRows count] == 0)
        return;
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    [nf setDecimalSeparator:@"."];
    
    @try {
        for (NSString * szRow in rgRows)
        {
            if ([szRow length] > 0)
            {
                NSArray * rgItems = [szRow componentsSeparatedByString:@","];
                if ([rgItems count] > 2)
                {
                    MFBWebServiceSvc_LatLong * ll = [[MFBWebServiceSvc_LatLong alloc] init];
                    ll.Latitude = [nf numberFromString:rgItems[0]];
                    ll.Longitude = [nf numberFromString:rgItems[1]];
                    
                    // this will skip the first row and any other bogus rows.
                    if (ll.Latitude != nil && ll.Longitude != nil)
                        [self.rgPathLatLong.LatLong addObject:ll];
                }
            }
        }
        return;
    }
    @catch (NSException *exception) {
        self.rgPathLatLong = nil;
    }
    @finally {
    }  
}

- (void) getFlightPath
{
	NSLog(@"getFlightPath called");
	
	if ([self.entryData isNewOrPending])
    {
        [self getPathFromInProgressTelemetry:(self.entryData.isNewFlight) ? mfbApp().mfbloc.flightDataAsString : self.entryData.FlightData];
        [self operationCompleted:nil];
        return;
    }
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	
	MFBWebServiceSvc_FlightPathForFlight * fp = [[MFBWebServiceSvc_FlightPathForFlight alloc] init];
	MFBAppDelegate * app = mfbApp();
	fp.szAuthUserToken = app.userProfile.AuthToken;
	fp.idFlight = entryData.FlightID;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b FlightPathForFlightAsyncUsingParameters:fp delegate:sc];
    }];
}

- (void) getGPXDataForFlight
{
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
    
    MFBWebServiceSvc_FlightPathForFlightGPX * fp = [MFBWebServiceSvc_FlightPathForFlightGPX new];

	MFBAppDelegate * app = mfbApp();
	fp.szAuthUserToken = app.userProfile.AuthToken;
	fp.idFlight = entryData.FlightID;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b FlightPathForFlightGPXAsyncUsingParameters:fp delegate:sc];
    }];
}

#pragma Persistence
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.entryData forKey:_szkeyEntryData];
	[encoder encodeBool:self.postingOptions.PostToTwitter.boolValue forKey:_szkeyTweet];
	[encoder encodeBool:self.postingOptions.PostToFacebook.boolValue forKey:_szkeyFaceBook];
	[encoder encodeObject:self.rgPicsForFlight forKey:_szkeyImages];
    [encoder encodeBool:self.fIsPaused forKey:_szkeyIsPaused];
    [encoder encodeDouble:self.dtTotalPauseTime forKey:_szkeyPausedTime];
    [encoder encodeDouble:self.dtTimeOfLastPause forKey:_szkeyLastPauseTime];
    [encoder encodeDouble:self.accumulatedNightTime forKey:_szkeyAccumulatedNightTime];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	self.entryData = [decoder decodeObjectForKey:_szkeyEntryData];
    if (self.postingOptions == nil)
        self.postingOptions = [MFBWebServiceSvc_PostingOptions new];
	self.postingOptions.PostToTwitter = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyTweet]];
	self.postingOptions.PostToFacebook = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyFaceBook]];
	self.rgPicsForFlight = [NSMutableArray arrayWithArray:[decoder decodeObjectForKey:_szkeyImages]];
    self.fIsPaused = [decoder decodeBoolForKey:_szkeyIsPaused];
    self.dtTotalPauseTime = [decoder decodeDoubleForKey:_szkeyPausedTime];
    self.dtTimeOfLastPause = [decoder decodeDoubleForKey:_szkeyLastPauseTime];
    
    @try
    {
        self.accumulatedNightTime = [decoder decodeDoubleForKey:_szkeyAccumulatedNightTime];
    }
    @catch (NSException * ex) { }
    @finally { }
	
	return self;
}

- (void) initNumerics
{
	
	entryData.Approaches = @0;
	entryData.Landings = @0;
	entryData.NightLandings = @0;
	entryData.FullStopLandings = @0;
	
	entryData.CFI = @0.0;
	entryData.CrossCountry = @0.0;
	entryData.Dual = @0.0;
	entryData.IMC = @0.0;
	entryData.Nighttime = @0.0;
	entryData.PIC = @0.0;
	entryData.SIC = @0.0;
	entryData.SimulatedIFR = @0.0;
	entryData.GroundSim = @0.0;
	entryData.TotalFlightTime = @0.0;
	
	entryData.CatClassOverride = @0;
}

- (void) savePendingFlights:(NSMutableArray *) rgFlights
{
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:[NSKeyedArchiver archivedDataWithRootObject:rgFlights] forKey:_szKeyPendingFlightsArray];
	[defs synchronize];
}

- (NSMutableArray *) getPendingFlights
{
	NSData * rgPendingFlights = [[NSUserDefaults standardUserDefaults] objectForKey:_szKeyPendingFlightsArray];
	
	NSArray * cachedArray = nil;
	if (rgPendingFlights != nil)
		cachedArray = [NSKeyedUnarchiver unarchiveObjectWithData:rgPendingFlights];
	if (cachedArray != nil)
		return [NSMutableArray arrayWithArray:cachedArray];
	
	return nil;
}

// JSON format here is described at Support the LogTen Pro API format for a “myflightbook://“ url scheme, as defined at
// http://s3.amazonaws.com/entp-tender-production/assets/f9e264a74a0b287577bf3035c4f400204336d84d/LogTen_Pro_API.pdf
+ (void) addPendingJSONFlights:(id) JSONObjToImport
{
    // Get the metadata
    if ([JSONObjToImport isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * dictRoot = (NSDictionary *) JSONObjToImport;
        NSDictionary * dictMeta = (NSDictionary *) dictRoot[@"metadata"];
        NSArray * rgFlights = (NSArray *) dictRoot[@"flights"];
        // TODO: Error handling, messages
        
        NSDateFormatter * dfDate = [NSDateFormatter new];
        NSDateFormatter * dfDateTime = [NSDateFormatter new];
        
        if (dictMeta[@"dateFormat"] != nil)
            [dfDate setDateFormat:dictMeta[@"dateFormat"]];
        if (dictMeta[@"dateAndTimeFormat"] != nil)
            [dfDateTime setDateFormat:dictMeta[@"dateAndTimeFormat"]];
        BOOL fZulu = (dictMeta[@"timesAreZulu"] == nil) ? true : [dictMeta[@"timesAreZulu"] compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame;
        NSTimeZone * tzZulu = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dfDate setTimeZone:[NSTimeZone localTimeZone]];    // Dates are always local
        [dfDateTime setTimeZone:fZulu ? tzZulu : [NSTimeZone localTimeZone]];
        
        for (NSDictionary * d in rgFlights)
        {
            LogbookEntry * le = [[LogbookEntry alloc] init];
            le.entryData.FlightID = PENDING_FLIGHT_ID;

            le.errorString = [le.entryData fromJSONDictionary:d dateFormatter:dfDate dateTimeFormatter:dfDateTime];
            
            [mfbApp() queueFlightForLater:le];
        }
    }
}
@end

@implementation MFBWebServiceSvc_LogbookEntry (AutodetectDelegate)
- (void) autofillClosest
{
    self.Route = [Airports appendNearestAirport:self.Route];
}

- (NSString *) takeoffDetected;
{
    if (!self.isKnownFlightStart)
        self.FlightStart = mfbApp().mfbloc.lastSeenLoc.timestamp;
    [self autofillClosest];
    return @"";
}

- (NSString *) nightTakeoffDetected
{
    if (self.CustomProperties == nil)
        self.CustomProperties = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
    
    // See if the flight has a night-time take-off property attached.  If not, add it.
    MFBWebServiceSvc_CustomFlightProperty * fpTakeoff = nil;
    for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.CustomProperties.CustomFlightProperty)
        if ([cfp.PropTypeID intValue] == PropTypeID_NightTakeOff)
        {
            fpTakeoff = cfp;
            break;
        }
    
    if (fpTakeoff == nil)
        [self addProperty:@PropTypeID_NightTakeOff withInteger:@1];
    else
        fpTakeoff.IntValue = @([fpTakeoff.IntValue intValue] + 1);
    return @"";
}

- (NSString *) landingDetected
{
    if ([self isKnownEngineEnd])
        return @"";
    
    if (![NSDate isUnknownDate:self.FlightStart])
    {
        self.FlightEnd = mfbApp().mfbloc.lastSeenLoc.timestamp;
        self.Landings = @(self.Landings.integerValue + 1);
        [self autofillClosest];
    }
    return @"";
}

- (NSString *) fsLandingDetected:(BOOL) fIsNight
{
    if ([self isKnownEngineEnd])
        return @"";

    if (fIsNight)
        self.NightLandings = @(self.NightLandings.intValue + 1);
    else
        self.FullStopLandings = @(self.FullStopLandings.intValue + 1);
    return @"";
}


- (void) addNightTime:(double) t
{
    self.Nighttime = @(self.Nighttime.doubleValue + t);
}

- (BOOL) flightCouldBeInProgress
{
    // Could be in progress if (EITHER engine or flight start is known) AND EngineEnd is unknown.
    return ((self.isKnownFlightStart || self.isKnownEngineStart) && !self.isKnownEngineEnd);
}

- (void) newLocation:(CLLocation *)newLocation
{
    // don't care
}
@end

@implementation MFBWebServiceSvc_LogbookEntry (MFBIPhone)
+ (MFBWebServiceSvc_LogbookEntry *) getNewLogbookEntry
{
    MFBWebServiceSvc_LogbookEntry * le = [[MFBWebServiceSvc_LogbookEntry alloc] init];
    le.FlightID = @-1;
    le.CustomProperties = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
    le.Comment = @"";
    le.Route = @"";
    return le;
}

- (BOOL) isNewFlight
{
	return (self.FlightID == nil || [self.FlightID intValue] == -1);
}

- (BOOL) isPending
{
	return (self.FlightID != nil && [self.FlightID intValue] < -1);
}

- (BOOL) isNewOrPending
{
	return (self.FlightID != nil && [self.FlightID intValue] < 0);
}

// isInitialState means a basically empty flight, but it COULD have a pre-initialized hobbs starting time.
- (BOOL) isInInitialState
{
    if ((self.Comment == nil || [self.Comment length] == 0) &&
        (self.Route == nil || [self.Route length] == 0) &&
        [self.Approaches intValue] == 0 &&
        [self.CFI doubleValue] == 0.0 &&
        [self.CrossCountry doubleValue] == 0.0 &&
        [self.Dual doubleValue] == 0.0 &&
        [self.FullStopLandings intValue] == 0 &&
        [self.HobbsEnd doubleValue] == 0.0 &&
        [self.IMC doubleValue] == 0.0 &&
        [self.Landings intValue] == 0 &&
        [self.NightLandings intValue] == 0 &&
        [self.Nighttime doubleValue] == 0.0 &&
        [self.PIC doubleValue] == 0.0 &&
        [self.SIC doubleValue] == 0.0 &&
        [self.SimulatedIFR doubleValue] == 0.0 &&
        [self.TotalFlightTime doubleValue] == 0.0 &&
        [self.CustomProperties.CustomFlightProperty count] == 0)
        return YES;

    // see if any properties are empty
    if ([self.CustomProperties.CustomFlightProperty count] > 0)
        return [[[FlightProps getFlightPropsNoNet] distillList:self.CustomProperties.CustomFlightProperty includeLockedProps:NO] count] == 0;
    
    return NO;
}

// isEmpty is a truly empty flight - ininitialstate AND empty hobbs start.
- (BOOL) isEmpty
{
    return self.HobbsStart.doubleValue == 0.0 && self.isInInitialState;
}

- (BOOL) isSigned
{
    return self.CFISignatureState == MFBWebServiceSvc_SignatureState_Valid || self.CFISignatureState == MFBWebServiceSvc_SignatureState_Invalid;
}

- (void)encodeWithCoderMFB:(NSCoder *)encoder
{
	[encoder encodeObject:self.FlightID forKey:_szkeyFlightID];
	[encoder encodeObject:self.AircraftID forKey:_szkeyAircraftID];
	[encoder encodeObject:self.Approaches forKey:_szkeyApproaches];
	[encoder encodeObject:self.CFI forKey:_szkeyCFI];
	[encoder encodeObject:self.Comment forKey:_szkeyComment];
	[encoder encodeObject:self.CrossCountry forKey:_szkeyCrossCountry];
	[encoder encodeObject:self.Date forKey:_szkeyDate];
	[encoder encodeObject:self.Dual forKey:_szkeyDual];
	[encoder encodeObject:self.EngineEnd forKey:_szkeyEngineEnd];
	[encoder encodeObject:self.EngineStart forKey:_szkeyEngineStart];
	[encoder encodeObject:self.FlightEnd forKey:_szkeyFlightEnd];
	[encoder encodeObject:self.FlightStart forKey:_szkeyFlightStart];
	[encoder encodeObject:self.FullStopLandings forKey:_szkeyFullStopLandings];
	[encoder encodeObject:self.HobbsEnd forKey:_szkeyHobbsEnd];
	[encoder encodeObject:self.HobbsStart forKey:_szkeyHobbsStart];
	[encoder encodeObject:self.IMC forKey:_szkeyIMC];
	[encoder encodeObject:self.Landings forKey:_szkeyLandings];
	[encoder encodeObject:self.NightLandings forKey:_szkeyNightLandings];
	[encoder encodeObject:self.Nighttime forKey:_szkeyNight];
	[encoder encodeObject:self.PIC forKey:_szkeyPIC];
	[encoder encodeObject:self.Route forKey:_szkeyRoute];
	[encoder encodeObject:self.SIC forKey:_szkeySIC];
	[encoder encodeObject:self.SimulatedIFR forKey:_szkeySimulatedIFR];
	[encoder encodeObject:self.GroundSim forKey:_szkeyGroundSim];
	[encoder encodeObject:self.TotalFlightTime forKey:_szkeyTotalFlight];
	[encoder encodeObject:self.User forKey:_szkeyUser];
	[encoder encodeObject:self.FlightData forKey:_szKeyFlightData];

	[encoder encodeObject:self.CustomProperties forKey:_szKeyCustomProperties];
	
	[encoder encodeBool:self.fHoldingProcedures.boolValue forKey:_szkeyHolding];
	[encoder encodeBool:self.fIsPublic.boolValue forKey:_szkeyIsPublic];
	
	[encoder encodeObject:self.CatClassOverride forKey:_szKeyCatClassOverride];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	self.AircraftID = [decoder decodeObjectForKey:@"AircraftID"];	

	self.FlightID = [decoder decodeObjectForKey:_szkeyFlightID];
	self.AircraftID = [decoder decodeObjectForKey:_szkeyAircraftID];
	self.Approaches = [decoder decodeObjectForKey:_szkeyApproaches];
	self.CFI = [decoder decodeObjectForKey:_szkeyCFI];
	self.Comment = [decoder decodeObjectForKey:_szkeyComment];
	self.CrossCountry = [decoder decodeObjectForKey:_szkeyCrossCountry];
	self.Date = [decoder decodeObjectForKey:_szkeyDate];
	self.Dual = [decoder decodeObjectForKey:_szkeyDual];
	self.EngineEnd = [decoder decodeObjectForKey:_szkeyEngineEnd];
	self.EngineStart = [decoder decodeObjectForKey:_szkeyEngineStart];
	self.FlightEnd = [decoder decodeObjectForKey:_szkeyFlightEnd];
	self.FlightStart = [decoder decodeObjectForKey:_szkeyFlightStart];
	self.FullStopLandings = [decoder decodeObjectForKey:_szkeyFullStopLandings];
	self.HobbsEnd = [decoder decodeObjectForKey:_szkeyHobbsEnd];
	self.HobbsStart = [decoder decodeObjectForKey:_szkeyHobbsStart];
	self.IMC = [decoder decodeObjectForKey:_szkeyIMC];
	self.Landings = [decoder decodeObjectForKey:_szkeyLandings];
	self.NightLandings = [decoder decodeObjectForKey:_szkeyNightLandings];
	self.Nighttime = [decoder decodeObjectForKey:_szkeyNight];
	self.PIC = [decoder decodeObjectForKey:_szkeyPIC];
	self.Route = [decoder decodeObjectForKey:_szkeyRoute];
	self.SIC = [decoder decodeObjectForKey:_szkeySIC];
	self.SimulatedIFR = [decoder decodeObjectForKey:_szkeySimulatedIFR];
	self.GroundSim = [decoder decodeObjectForKey:_szkeyGroundSim];
	if (self.GroundSim == nil)
		self.GroundSim = @0.0;
	self.TotalFlightTime = [decoder decodeObjectForKey:_szkeyTotalFlight];
	self.User = [decoder decodeObjectForKey:_szkeyUser];
	self.FlightData = [decoder decodeObjectForKey:_szKeyFlightData];
	
	self.CustomProperties = [decoder decodeObjectForKey:_szKeyCustomProperties];

	self.fHoldingProcedures = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyHolding]];
	self.fIsPublic = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyIsPublic]];
	
	self.CatClassOverride = [decoder decodeObjectForKey:_szKeyCatClassOverride];
	if (self.CatClassOverride == nil)
		self.CatClassOverride = @0;
	
	return self;
}	

#pragma mark - Known/Unknown Times
- (BOOL) isKnownFlightStart
{
    return ![NSDate isUnknownDate:self.FlightStart];
}

- (BOOL) isKnownEngineStart
{
    return ![NSDate isUnknownDate:self.EngineStart];
}

- (BOOL) isKnownFlightEnd
{
    return ![NSDate isUnknownDate:self.FlightEnd];
}

- (BOOL) isKnownEngineEnd
{
    return ![NSDate isUnknownDate:self.EngineEnd];
}

- (BOOL) isKnownFlightTime
{
    return [self isKnownFlightStart] && [self isKnownFlightEnd];
}

- (BOOL) isKnownEngineTime
{
    return [self isKnownEngineStart] && [self isKnownEngineEnd];
}

- (MFBWebServiceSvc_CustomFlightProperty *) getNewProperty:(NSNumber *) idPropType
{
    MFBWebServiceSvc_CustomFlightProperty * fp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
    fp.FlightID = self.FlightID;
    fp.PropTypeID = idPropType;
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withInteger:(NSNumber *) intVal
{
    if (intVal == nil || intVal.integerValue == 0)
        return nil;
    MFBWebServiceSvc_CustomFlightProperty * fp = [self getNewProperty:idPropType];
    fp.IntValue = intVal;
    [self.CustomProperties.CustomFlightProperty addObject:fp];
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withDecimal:(NSNumber *) decVal
{
    if (decVal == nil || decVal.doubleValue == 0.0)
        return nil;
    MFBWebServiceSvc_CustomFlightProperty * fp = [self getNewProperty:idPropType];
    fp.DecValue = decVal;
    [self.CustomProperties.CustomFlightProperty addObject:fp];
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withString:(NSString *) sz
{
    if (sz == nil)
        return nil;
    MFBWebServiceSvc_CustomFlightProperty * fp = [self getNewProperty:idPropType];
    fp.TextValue = sz;
    [self.CustomProperties.CustomFlightProperty addObject:fp];
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withBool:(BOOL) fBool;
{
    if (!fBool)
        return nil;
    MFBWebServiceSvc_CustomFlightProperty * fp = [self getNewProperty:idPropType];
    fp.BoolValue = [[USBoolean alloc] initWithBool:fBool];
    [self.CustomProperties.CustomFlightProperty addObject:fp];
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withDate:(NSDate *) dt
{
    if (dt == nil)
        return nil;
    MFBWebServiceSvc_CustomFlightProperty * fp = [self getNewProperty:idPropType];
    fp.DateValue = dt;
    [self.CustomProperties.CustomFlightProperty addObject:fp];
    return fp;
}

- (NSNumber *) parseNum:(id) s numType:(int) nt
{
    if (s == nil)
        return @0;
    
    if ([s isKindOfClass:[NSNumber class]])
        return s;
    
    NSString * sz = (NSString *) s;
    if (sz.length == 0)
        return @0;
    
    // Logten spec allows for "+" in addition to ":"
    sz = [sz stringByReplacingOccurrencesOfString:@"+" withString:@":"];
    
    NSRange r = [sz rangeOfString:@":"];
    BOOL fIsHHMM = r.location != NSNotFound;
    return [UITextField valueForString:sz withType:nt withHHMM:fIsHHMM];
}

- (NSDate *) parseDate:(id) szdt withFormatter:(NSDateFormatter *) df
{
    NSDate * dt = nil;
    if (szdt != nil)
    {
        @try {
            if ([szdt isKindOfClass:[NSDate class]])
                return szdt;
            if ([szdt isKindOfClass:[NSNumber class]])
                dt = [NSDate dateWithTimeIntervalSince1970:((NSNumber *)szdt).integerValue];
            else if ([szdt isKindOfClass:[NSString class]])
                dt = [df dateFromString:szdt];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    return dt;
}

// Utility macros for parsing JSON-derived dictionary
#define AddNumber(f, v, nt) f = [self parseNum:v numType:nt]
#define AddString(f, v) f = (v == nil) ? @"" : (NSString *) v

- (NSString *) fromJSONDictionary:(NSDictionary *) dict dateFormatter:(NSDateFormatter *) dfDate dateTimeFormatter:(NSDateFormatter *) dfDateTime;
{
    NSString * szResult = @"";
    
    @try {
        AddString(self.Comment, dict[@"flight_remarks"]);
        NSString * szFrom, *szTo, *szRoute;
        AddString(szFrom, dict[@"flight_from"]);
        AddString(szTo, dict[@"flight_to"]);
        AddString(szRoute, dict[@"flight_route"]);
        self.Route = [NSString stringWithFormat:@"%@ %@ %@", szFrom, szRoute, szTo];
        self.Route = [self.Route stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        AddNumber(self.HobbsStart, dict[@"flight_hobbsStart"], ntDecimal);
        AddNumber(self.HobbsEnd, dict[@"flight_hobbsStop"], ntDecimal);
        
        self.Date = [self parseDate:dict[@"flight_flightDate"] withFormatter:dfDate];
        self.FlightStart = [self parseDate:dict[@"flight_takeoffTime"] withFormatter:dfDateTime];
        self.FlightEnd = [self parseDate:dict[@"flight_landingTime"] withFormatter:dfDateTime];
        
        AddNumber(self.CrossCountry, dict[@"flight_crossCountry"], ntTime);
        AddNumber(self.Nighttime, dict[@"flight_night"], ntTime);
        AddNumber(self.SimulatedIFR, dict[@"flight_simulatedInstrument"], ntTime);
        AddNumber(self.IMC, dict[@"flight_actualInstrument"], ntTime);
        AddNumber(self.GroundSim, dict[@"flight_simulator"], ntTime);
        AddNumber(self.Dual, dict[@"flight_dualReceived"], ntTime);
        AddNumber(self.CFI, dict[@"flight_dualGiven"], ntTime);
        AddNumber(self.SIC, dict[@"flight_sic"], ntTime);
        AddNumber(self.PIC, dict[@"flight_pic"], ntTime);
        AddNumber(self.TotalFlightTime, dict[@"flight_totalTime"], ntTime);
        
        AddNumber(self.NightLandings, dict[@"flight_nightLandings"], ntInteger);
        AddNumber(self.FullStopLandings, dict[@"flight_dayLandings"], ntInteger);
        AddNumber(self.Landings, dict[@"flight_totalLandings"], ntInteger);
        
        if (dict[@"flight_holds"] != nil)
            self.fHoldingProcedures = [[USBoolean alloc] initWithBool:((NSString *) dict[@"flight_holds"]).integerValue > 0];
        self.fIsPublic = [[USBoolean alloc] initWithBool:NO];
        AddNumber(self.Approaches, dict[@"flight_totalApproaches"], ntInteger);
        
        // Now add a few properties that match to known property types
        [self addProperty:@PropTypeID_IPC withBool:dict[@"flight_instrumentProficiencyCheck"] != nil];
        [self addProperty:@PropTypeID_BFR withBool:dict[@"flight_review"] != nil];
        [self addProperty:@PropTypeID_NightTakeOff withInteger:[self parseNum:dict[@"flight_nightTakeoffs"] numType:ntInteger]];
        [self addProperty:@PropTypeID_Solo withDecimal:[self parseNum:dict[@"flight_solo"] numType:ntTime]];
        [self addProperty:@PropTypeID_NameOfPIC withString:dict[@"flight_selectedCrewPIC"]];
        [self addProperty:@PropTypeID_NameOfSIC withString:dict[@"flight_selectedCrewSIC"]];
        [self addProperty:@PropTypeID_NameOfCFI withString:dict[@"flight_selectedCrewInstructor"]];
        [self addProperty:@PropTypeID_NameOfStudent withString:dict[@"flight_selectedCrewStudent"]];

        self.AircraftID = @-1;
        MFBWebServiceSvc_Aircraft * ac;
        if (dict[@"flight_selectedAircraftID"] == nil || (ac = [[Aircraft sharedAircraft] AircraftByTail:dict[@"flight_selectedAircraftID"]]) == nil)
            szResult = NSLocalizedString(@"No Aircraft", @"Title for No Aircraft error");
        else
            self.AircraftID = ac.AircraftID;
    }
    @catch (NSException *exception) {
        szResult = exception.reason;
    }
    @finally {
    }


    return szResult;
}
@end

@implementation MFBWebServiceSvc_FlightQuery (MFBIPhone)
+ (MFBWebServiceSvc_FlightQuery *) getNewFlightQuery
{
    MFBWebServiceSvc_FlightQuery * f = [MFBWebServiceSvc_FlightQuery new];
    f.AircraftList = [MFBWebServiceSvc_ArrayOfAircraft new];
    f.PropertyTypes = [MFBWebServiceSvc_ArrayOfCustomPropertyType new];
    f.AirportList = [MFBWebServiceSvc_ArrayOfString new];
    f.MakeList = [MFBWebServiceSvc_ArrayOfMakeModel new];
    f.CatClasses = [MFBWebServiceSvc_ArrayOfCategoryClass new];
    f.DateRange = MFBWebServiceSvc_DateRanges_AllTime;
    f.Distance = MFBWebServiceSvc_FlightDistance_AllFlights;
    f.DateMin = [MFBSoapCall UTCDateFromLocalDate:[NSDate date]];
    f.DateMax = [MFBSoapCall UTCDateFromLocalDate:[NSDate date]];
    
    f.HasApproaches = [[USBoolean alloc] initWithBool:NO];
    f.HasCFI = [[USBoolean alloc] initWithBool:NO];
    f.HasDual = [[USBoolean alloc] initWithBool:NO];
    f.HasDual = [[USBoolean alloc] initWithBool:NO];
    f.HasFlaps = [[USBoolean alloc] initWithBool:NO];
    f.HasFullStopLandings = [[USBoolean alloc] initWithBool:NO];
    f.HasLandings = [[USBoolean alloc] initWithBool:NO];
    f.HasGroundSim = [[USBoolean alloc] initWithBool:NO];
    f.HasHolds = [[USBoolean alloc] initWithBool:NO];
    f.HasIMC = [[USBoolean alloc] initWithBool:NO];
    f.HasAnyInstrument = [[USBoolean alloc] initWithBool:NO];
    f.HasNight = [[USBoolean alloc] initWithBool:NO];
    f.HasNightLandings = [[USBoolean alloc] initWithBool:NO];
    f.HasPIC = [[USBoolean alloc] initWithBool:NO];
    f.HasSIC = [[USBoolean alloc] initWithBool:NO];
    f.HasTotalTime = [[USBoolean alloc] initWithBool:NO];
    f.HasSimIMCTime = [[USBoolean alloc] initWithBool:NO];
    f.HasTelemetry = [[USBoolean alloc] initWithBool:NO];
    f.HasImages = [[USBoolean alloc] initWithBool:NO];
    f.HasXC = [[USBoolean alloc] initWithBool:NO];
    f.IsComplex = [[USBoolean alloc] initWithBool:NO];
    f.IsConstantSpeedProp = [[USBoolean alloc] initWithBool:NO];
    f.IsGlass = [[USBoolean alloc] initWithBool:NO];
    f.IsHighPerformance = [[USBoolean alloc] initWithBool:NO];
    f.IsPublic = [[USBoolean alloc] initWithBool:NO];
    f.IsRetract = [[USBoolean alloc] initWithBool:NO];
    f.IsTailwheel = [[USBoolean alloc] initWithBool:NO];
    f.IsTechnicallyAdvanced = [[USBoolean alloc] initWithBool:NO];
    f.IsTurbine = [[USBoolean alloc] initWithBool:NO];
    f.IsSigned = [[USBoolean alloc] initWithBool:NO];
    f.IsMotorglider = [[USBoolean alloc] initWithBool:NO];
    f.EngineType = MFBWebServiceSvc_EngineTypeRestriction_AllEngines;
    f.AircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft;
    f.ModelName = [NSString new];
    f.TypeNames = [MFBWebServiceSvc_ArrayOfString new];
    return f;
}

- (BOOL) hasDate
{
    return (self.DateRange != MFBWebServiceSvc_DateRanges_AllTime && self.DateRange != MFBWebServiceSvc_DateRanges_none);
}

- (BOOL) hasText
{
    return [self.GeneralText length] > 0;
}

- (BOOL) hasFlightCharacteristics
{
    return (self.HasApproaches.boolValue || self.HasCFI.boolValue || self.HasDual.boolValue || self.HasFullStopLandings.boolValue || self.HasLandings.boolValue || self.HasAnyInstrument.boolValue || self.HasTotalTime.boolValue ||
            self.HasGroundSim.boolValue || self.HasHolds.boolValue || self.HasIMC.boolValue || self.HasNight.boolValue || self.HasNightLandings.boolValue ||
            self.HasPIC.boolValue || self.IsPublic.boolValue || self.HasSIC.boolValue || self.HasSimIMCTime.boolValue || self.HasTelemetry.boolValue || self.HasImages.boolValue || self.HasXC.boolValue || self.IsSigned.boolValue);
}

- (BOOL) hasAircraftCharacteristics
{
    return (self.IsComplex.boolValue || self.IsConstantSpeedProp.boolValue || self.IsGlass.boolValue || self.IsHighPerformance.boolValue || self.IsMotorglider.boolValue ||
            self.IsTurbine.boolValue || self.IsRetract.boolValue || self.IsTailwheel.boolValue || self.IsTechnicallyAdvanced.boolValue || self.HasFlaps.boolValue ||
            self.AircraftInstanceTypes > MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft ||
            self.EngineType > MFBWebServiceSvc_EngineTypeRestriction_AllEngines);
}

- (BOOL) hasAirport
{
    return [self.AirportList.string count] > 0 || 
    (self.Distance != MFBWebServiceSvc_FlightDistance_AllFlights && self.Distance != MFBWebServiceSvc_FlightDistance_none);
}

- (BOOL) hasProperties
{
    return [self.PropertyTypes.CustomPropertyType count] > 0;
}

- (BOOL) hasPropertyType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
    for (MFBWebServiceSvc_CustomPropertyType * cpt2 in self.PropertyTypes.CustomPropertyType)
        if (cpt2.PropTypeID.integerValue == cpt.PropTypeID.integerValue)
            return YES;
    return NO;
}

- (void) togglePropertyType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
    MFBWebServiceSvc_CustomPropertyType * cptFound = nil;
    
    for (MFBWebServiceSvc_CustomPropertyType * cpt2 in self.PropertyTypes.CustomPropertyType)
        if (cpt2.PropTypeID.integerValue == cpt.PropTypeID.integerValue)
        {
            cptFound = cpt2;
            break;
        }
    
    if (cptFound == nil)
        [self.PropertyTypes.CustomPropertyType addObject:cpt];
    else
        [self.PropertyTypes.CustomPropertyType removeObject:cptFound];
}

- (BOOL) hasAircraft
{
    return [self.AircraftList.Aircraft count] > 0;
}

- (BOOL) hasMakes
{
    return [self.MakeList.MakeModel count] > 0 || self.ModelName.length > 0 || self.TypeNames.string.count > 0;
}

- (BOOL) hasCatClasses
{
    return [self.CatClasses.CategoryClass count] > 0;
}

- (BOOL) isUnrestricted
{
    if ([self hasDate] ||
        [self hasText] ||
        [self hasFlightCharacteristics] ||
        [self hasAircraftCharacteristics] || 
        [self hasAirport] ||
        [self hasProperties] || 
        [self hasAircraft] ||
        [self hasMakes] ||
        [self hasCatClasses])
        return NO;
    
    return YES;
}
@end

