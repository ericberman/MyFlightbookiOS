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
//  LogbookEntry.m
//  MFBSample
//
//  Created by Eric Berman on 12/2/09.
//

#import "LogbookEntry.h"
#import "MFBAsyncOperation.h"
#import "CommentedImage.h"

@interface LogbookEntry ()
@property (strong) NSDate * stashedDate;
@end

@implementation LogbookEntry

@synthesize entryData;
@synthesize rgPicsForFlight;
@synthesize szAuthToken;
@synthesize errorString;
@synthesize rgPathLatLong;
@synthesize dtTotalPauseTime, dtTimeOfLastPause, accumulatedNightTime;
@synthesize fIsPaused;
@synthesize progressLabel;
@synthesize gpxPath;
@synthesize stashedDate;
@synthesize fShuntPending;

NSString * const _szKeyPendingFlightsArray = @"pref_pendingFlightsArray";

NSString * const _szkeyEntryData = @"_keyEntryData";
NSString * const _szkeyImages = @"_keyImageArray";

NSString * const _szkeyIsPaused = @"_keyIsPaused";
NSString * const _szkeyShuntPending = @"_keyShuntPending";
NSString * const _szkeyPausedTime = @"_pausedTime";
NSString * const _szkeyLastPauseTime = @"_lastPauseTime";
NSString * const _szkeyAccumulatedNightTime = @"_accumulatedNightTime";

#define CONTEXT_FLAG_COMMIT 40382

#pragma mark Object Lifecycle
- (instancetype)init
{   
    self = [super init];
	if (self != nil)
	{
		self.entryData = [MFBWebServiceSvc_LogbookEntry getNewLogbookEntry];
		self.rgPathLatLong = nil;
		self.rgPicsForFlight = [[NSMutableArray alloc] init]; // No need to release earlier one, accessor method will release it and retain this one
		self.errorString = @"";
        self.fIsPaused = self.fShuntPending = NO;
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

#pragma mark - Autofill Utilities
- (BOOL) autoFillHobbs {
    NSTimeInterval dtHobbs = 0;
    NSTimeInterval dtFlight = 0;
    NSTimeInterval dtEngine = 0;
    NSTimeInterval dtPausedTime = self.totalTimePaused;
    double hobbsStart = self.entryData.HobbsStart.doubleValue;
    
    if (![NSDate isUnknownDate:self.entryData.FlightStart] && ![NSDate isUnknownDate:self.entryData.FlightEnd])
        dtFlight = [self.entryData.FlightEnd timeIntervalSinceDate:self.entryData.FlightStart];
    
    if (![NSDate isUnknownDate:self.entryData.EngineStart] && ![NSDate isUnknownDate:self.entryData.EngineEnd])
        dtEngine = [self.entryData.EngineEnd timeIntervalSinceDate:self.entryData.EngineStart];
    
    if (hobbsStart > 0) {
        switch (UserPreferences.current.autoHobbsMode)
        {
            case autoHobbsFlight:
                dtHobbs = dtFlight;
                break;
            case autoHobbsEngine:
                dtHobbs = dtEngine;
                break;
            case autoHobbsNone:
            default:
                break;
        }
        
        dtHobbs -= dtPausedTime;
        
        if (dtHobbs > 0)
        {
            double hobbsEnd = hobbsStart + (dtHobbs / 3600.0);
            // Issue #226 - round to nearest 10th of an hour if needed
            if (UserPreferences.current.roundTotalToNearestTenth)
                hobbsEnd = round(hobbsEnd * 10.0) / 10.0;
            self.entryData.HobbsEnd = @(hobbsEnd);
            return YES;
        }
    }
    return NO;
}

- (BOOL) autoCrossCountry:(NSTimeInterval) dtTotal {
    Airports * ap = [[Airports alloc] init];
    double maxDist = [ap maxDistanceOnRoute:self.entryData.Route];
    
    BOOL fIsCC = (maxDist >= MFBConstants.CROSS_COUNTRY_THRESHOLD);

    self.entryData.CrossCountry = @((fIsCC && dtTotal > 0) ? dtTotal : 0.0);
    return YES;
}

- (BOOL) autoFillTotal {
    NSTimeInterval dtPauseTime = self.totalTimePaused / 3600.0;  // pause time in hours
    NSTimeInterval dtTotal = 0;
    
    BOOL fIsRealAircraft = YES;
    
    MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] AircraftByID:self.entryData.AircraftID.intValue];
    if (ac != nil)
        fIsRealAircraft = ![ac isSim];
    
    switch (UserPreferences.current.autoTotalMode) {
        case autoTotalEngine:
        {
            if (![NSDate isUnknownDate:self.entryData.EngineStart] &&
                ![NSDate isUnknownDate:self.entryData.EngineEnd])
            {
                NSTimeInterval engineStart = [self.entryData.EngineStart timeIntervalSinceReferenceDate];
                NSTimeInterval engineEnd = [self.entryData.EngineEnd timeIntervalSinceReferenceDate];
                dtTotal = ((engineEnd - engineStart) / 3600.0) - dtPauseTime;
            }
        }
            break;
        case autoTotalFlight:
        {
            if (![NSDate isUnknownDate:self.entryData.FlightStart] &&
                ![NSDate isUnknownDate:self.entryData.FlightEnd])
            {
                NSTimeInterval flightStart = [self.entryData.FlightStart timeIntervalSinceReferenceDate];
                NSTimeInterval flightEnd = [self.entryData.FlightEnd timeIntervalSinceReferenceDate];
                dtTotal = ((flightEnd - flightStart) / 3600.0) - dtPauseTime;
            }
        }
            break;
        case autoTotalHobbs:
        {
            double hobbsStart = [self.entryData.HobbsStart doubleValue];
            double hobbsEnd = [self.entryData.HobbsEnd doubleValue];
            // NOTE: we do NOT subtract dtPauseTime here because hobbs should already have subtracted pause time,
            // whether from being entered by user (hobbs on airplane pauses on ground or with engine stopped)
            // or from this being called by autohobbs (which has already subtracted it)
            if (hobbsStart > 0 && hobbsEnd > 0)
                dtTotal = hobbsEnd - hobbsStart;
        }
            break;
        case autoTotalBlock: {
            NSDate * blockOut = nil;
            NSDate * blockIn = nil;
            
            for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.entryData.CustomProperties.CustomFlightProperty) {
                if (cfp.PropTypeID.integerValue == PropTypeIDBlockOut)
                    blockOut = cfp.DateValue;
                if (cfp.PropTypeID.integerValue == PropTypeIDBlockIn)
                    blockIn = cfp.DateValue;
            }
            
            if (![NSDate isUnknownDate:blockOut] && ![NSDate isUnknownDate:blockIn])
                dtTotal = ([blockIn timeIntervalSinceDate:blockOut] / 3600.0) - dtPauseTime;

        }
            break;
        case autoTotalFlightStartToEngineEnd: {
            if (![NSDate isUnknownDate:self.entryData.FlightStart] && ![NSDate isUnknownDate:self.entryData.EngineEnd])
                dtTotal = ([self.entryData.EngineEnd timeIntervalSinceDate:self.entryData.FlightStart] / 3600.0) - dtPauseTime;
        }
            break;
        case autoTotalNone:
        default:
            return NO;
    }

    if (dtTotal > 0)
    {
        if (UserPreferences.current.roundTotalToNearestTenth)
            dtTotal = round(dtTotal * 10.0) / 10.0;

        if (fIsRealAircraft)
        {
            self.entryData.TotalFlightTime = @(dtTotal);
            [self autoCrossCountry:dtTotal];
        }
        else
            self.entryData.GroundSim = @(dtTotal);
        
        return YES;
    }
    return NO;
}

- (void) autoFillCostOfFlight {
    // Fill in cost of flight.
    MFBWebServiceSvc_Aircraft * ac = [Aircraft.sharedAircraft AircraftByID:self.entryData.AircraftID.intValue];
    
    if (ac == nil)
        return;

    NSError * err = nil;
    NSRegularExpression * regCost = [NSRegularExpression regularExpressionWithPattern:@"#PPH:(\\d+(?:[.,]\\d+)?)#" options:NSRegularExpressionCaseInsensitive error:&err];
    NSTextCheckingResult *match = [regCost firstMatchInString:ac.PrivateNotes options:0 range:NSMakeRange(0, ac.PrivateNotes.length)];
    if (match == nil)
        return;
    

    NSRange rValue = [match rangeAtIndex:1];
    NSString * rCapture = [ac.PrivateNotes substringWithRange:rValue];
    double rate = [UITextField valueForString:rCapture withType:NumericTypeDecimal withHHMM:NO].doubleValue;
    
    if (rate == 0)
        return;
    
    double tachStart = [self.entryData getExistingProperty:@(PropTypeIDTachStart)].DecValue.doubleValue;
    double tachEnd = [self.entryData getExistingProperty:@(PropTypeIDTachEnd)].DecValue.doubleValue;
    double time = (self.entryData.HobbsEnd.doubleValue > self.entryData.HobbsStart.doubleValue && self.entryData.HobbsStart.doubleValue > 0) ?
        self.entryData.HobbsEnd.doubleValue - self.entryData.HobbsStart.doubleValue :
        (tachEnd > tachStart && tachStart > 0) ? tachEnd - tachStart : self.entryData.TotalFlightTime.doubleValue;
    
    if (time > 0) {
        double cost = rate * time;
        MFBWebServiceSvc_CustomFlightProperty * cfp = [self.entryData getExistingProperty:@(PropTypeIDFlightCost)];
        if (cfp == nil)
            cfp = [self.entryData addProperty:@(PropTypeIDFlightCost) withDecimal:@(cost)];
        else
            cfp.DecValue = @(cost);
    }
}

- (void) autoFillFuel {
    MFBWebServiceSvc_CustomFlightProperty * cfpFuelAtStart = [self.entryData getExistingProperty:@(PropTypeIDFuelAtStart)];
    MFBWebServiceSvc_CustomFlightProperty * cfpFuelAtEnd = [self.entryData getExistingProperty:@(PropTypeIDFuelAtEnd)];
    
    double fuelConsumed = MAX(cfpFuelAtStart.DecValue.doubleValue - cfpFuelAtEnd.DecValue.doubleValue, 0);
    if (fuelConsumed > 0) {
        MFBWebServiceSvc_CustomFlightProperty * cfp = [self.entryData getExistingProperty:@(PropTypeIDFuelConsumed)];
        if (cfp == nil)
            cfp = [self.entryData addProperty:@(PropTypeIDFuelConsumed) withDecimal:@(fuelConsumed)];
        else
            cfp.DecValue = @(fuelConsumed);
        
        if (self.entryData.TotalFlightTime.doubleValue > 0) {
            double burnRate = fuelConsumed / self.entryData.TotalFlightTime.doubleValue;
            cfp = [self.entryData getExistingProperty:@(PropTypeIDFuelBurnRate)];
            if (cfp == nil)
                cfp = [self.entryData addProperty:@(PropTypeIDFuelBurnRate) withDecimal:@(burnRate)];
            else
                cfp.DecValue = @(burnRate);
        }
    }
}

- (void) autoFillInstruction {
    // Check for ground instruction given or received
    double dual = self.entryData.Dual.doubleValue;
    double cfi = self.entryData.CFI.doubleValue;
    if ((dual > 0 && cfi == 0) || (cfi > 0 && dual == 0)) {
        MFBWebServiceSvc_CustomFlightProperty * cfpLessonStart = [self.entryData getExistingProperty:@(PropTypeIDLessonStart)];
        MFBWebServiceSvc_CustomFlightProperty * cfpLessonEnd = [self.entryData getExistingProperty:@(PropTypeIDLessonEnd)];
        
        if (cfpLessonEnd == nil || cfpLessonStart == nil || [cfpLessonEnd.DateValue compare:cfpLessonStart.DateValue] != NSOrderedDescending)
            return;

        NSTimeInterval tsLesson = [cfpLessonEnd.DateValue timeIntervalSinceDate:cfpLessonStart.DateValue];

        // pull out flight or engine time, whichever is greater
        NSTimeInterval tsFlight = self.entryData.isKnownFlightEnd && self.entryData.isKnownFlightStart && [self.entryData.FlightEnd compare:self.entryData.FlightStart] == NSOrderedDescending ? [self.entryData.FlightEnd timeIntervalSinceDate:self.entryData.FlightStart] : 0;
        NSTimeInterval tsEngine = self.entryData.isKnownEngineEnd && self.entryData.isKnownEngineStart && [self.entryData.EngineEnd compare:self.entryData.EngineStart] == NSOrderedDescending ? [self.entryData.EngineEnd timeIntervalSinceDate:self.entryData.EngineStart] : 0;
        
        NSTimeInterval tsNonGround = MAX(MAX(tsFlight, tsEngine), 0);
        
        double groundHours = (tsLesson - tsNonGround) / 3600.0;
        
        int idPropTarget = dual > 0 ? PropTypeIDGroundInstructionReceived : PropTypeIDGroundInstructionGiven;
        
        if (groundHours > 0) {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.entryData getExistingProperty:@(idPropTarget)];
            if (cfp == nil)
                cfp = [self.entryData addProperty:@(idPropTarget) withDecimal:@(groundHours)];
            else
                cfp.DecValue = @(groundHours);
        }
    }
}

- (BOOL) autoFillFinish {
    [self autoFillCostOfFlight];
    [self autoFillFuel];
    [self autoFillInstruction];
    
    return YES;
}

#pragma mark Commit/delete/retrieve flight
-(void) commitFlight
{
	NSLog(@"CommitFlight called");
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
    
    BOOL fIsPendingFlight = [self.entryData isKindOfClass:MFBWebServiceSvc_PendingFlight.class];
    BOOL fIsExistingFlight = !self.entryData.isNewOrAwaitingUpload;
    
    MFBWebServiceSvc_PendingFlight * pf = fIsPendingFlight ? (MFBWebServiceSvc_PendingFlight *) self.entryData : nil;

    /*
        Scenarios:
         - fShuntPending is false, Regular flight, new or existing: call CommitFlightWithOptions
         - fShuntPending is false, Pending flight without a pending ID call CommitFlightWithOptions.  Shouldn't happen, but no big deal if it does
         - fShuntPending is false, Pending flight with a Pending ID: call MFBWebServiceSvc_CommitPendingFlight to commit it
         - fShuntPending is false, Pending flight without a pending ID: THROW EXCEPTION, how did this happen?
     
         - fShuntPending is true, Regular flight that is not new/pending (sorry about ambiguous "pending"): THROW EXCEPTION; this is an error
         - fShuntPending is true, Regular flight that is NEW: call MFBWebServiceSvc_CreatePendingFlight
         - fShuntPending is true, PendingFlight without a PendingID: call MFBWebServiceSvc_CreatePendingFlight.  Shouldn't happen, but no big deal if it does
         - fShuntPending is true, PendingFlight with a PendingID: call MFBWebServiceSvc_UpdatePendingFlight
     */
    

    // So...with the above said:
    if (self.fShuntPending) {
        if (fIsExistingFlight)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempting to save a flight already in the logbook into pending flights" userInfo:nil];
        
        // if it's a new logbookentry OR it's a pending flight without a pending ID, add it as a new pending flight
        if (!fIsPendingFlight || pf.PendingID.length == 0) {
            NSLog(@"Add pending flight");
           
            MFBSoapCall * sc = [[MFBSoapCall alloc] init];
            sc.delegate = self;
            
            MFBWebServiceSvc_CreatePendingFlight * addPF = [MFBWebServiceSvc_CreatePendingFlight new];
            addPF.szAuthUserToken = self.szAuthToken;
            addPF.le = self.entryData;
            
            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b CreatePendingFlightAsyncUsingParameters:addPF delegate:sc];
            }];
        } else {
            // Else it MUST be a pending flight and it MUST have a pending ID - update
            NSLog(@"Update Pending Flight");
            
            if (![self.entryData isKindOfClass:MFBWebServiceSvc_PendingFlight.class])
                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"updatePendingFlight called on something other than a pending flight!" userInfo:nil];
            
            MFBSoapCall * sc = [[MFBSoapCall alloc] init];
            sc.delegate = self;
            
            MFBWebServiceSvc_UpdatePendingFlight * updPF = [MFBWebServiceSvc_UpdatePendingFlight new];
            updPF.szAuthUserToken = self.szAuthToken;
            updPF.pf = (MFBWebServiceSvc_PendingFlight *) self.entryData;
            
            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b UpdatePendingFlightAsyncUsingParameters:updPF delegate:sc];
            }];
        }
    } else {
        // we're going to try to save it as a regular flight.
        if (fIsPendingFlight) {
            if (fIsExistingFlight || pf.PendingID.length == 0)
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Attempting to save a flight already in the logbook into pending flights, or save pending flight with no pendingID" userInfo:nil];
            
            MFBWebServiceSvc_CommitPendingFlight * commitPF = [MFBWebServiceSvc_CommitPendingFlight new];
            commitPF.szAuthUserToken = self.szAuthToken;
            commitPF.pf = (MFBWebServiceSvc_PendingFlight *) self.entryData;
            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b CommitPendingFlightAsyncUsingParameters:commitPF delegate:sc];
            }];
        } else {
            // check for videos without WiFi
            if (![CommentedImage canSubmitImages:self.rgPicsForFlight])
            {
                self.errorString = NSLocalizedString(@"ErrorNeedWifiForVids", @"Can't upload with videos unless on wifi");
                [self operationCompleted:sc];
                return;
            }
            
            MFBWebServiceSvc_CommitFlightWithOptions * commitFlight = [[MFBWebServiceSvc_CommitFlightWithOptions alloc] init];

            commitFlight.le = self.entryData;
            commitFlight.po = nil;
            commitFlight.szAuthUserToken = self.szAuthToken;
            
            // Date in the entry data was done in local time; will be converted here to UTC, which could be different from
            // actual date of flight.
            // We only really have to do this because we have a mix of UTC and "local" dates
            // SOOO....
            // adjust the date to a UTC date that looks like the right date
            self.stashedDate = self.entryData.Date;
            commitFlight.le.Date = [MFBSoapCall UTCDateFromLocalDate:commitFlight.le.Date];
            
            sc.contextFlag = CONTEXT_FLAG_COMMIT;

            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b CommitFlightWithOptionsAsyncUsingParameters:commitFlight delegate:sc];
            }];
        }
    }
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_CommitFlightWithOptionsResponse class]])
	{
		MFBWebServiceSvc_CommitFlightWithOptionsResponse * resp = (MFBWebServiceSvc_CommitFlightWithOptionsResponse *) body;
		self.entryData = resp.CommitFlightWithOptionsResult;
        self.stashedDate = nil;
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
    if ([body isKindOfClass:MFBWebServiceSvc_CommitPendingFlightResponse.class]) {
        retVal = YES;
    }
    if ([body isKindOfClass:MFBWebServiceSvc_UpdatePendingFlightResponse.class]) {
        MFBWebServiceSvc_UpdatePendingFlightResponse * resp = (MFBWebServiceSvc_UpdatePendingFlightResponse *) body;
        NSMutableArray<MFBWebServiceSvc_PendingFlight *> * arr = resp.UpdatePendingFlightResult.PendingFlight;
        NSString * szPending = ((MFBWebServiceSvc_PendingFlight *) entryData).PendingID;
        for (MFBWebServiceSvc_PendingFlight * pf in arr) {
            if ([pf.PendingID compare:szPending] == NSOrderedSame) {
                self.entryData = pf;
                break;
            }
        }
        retVal = YES;
    }
    if ([body isKindOfClass:MFBWebServiceSvc_CreatePendingFlightResponse.class]) {
        // Nothing to do here, really; flights will be picked up in a subsequent call
        retVal = YES;
    }
}

- (void) submitImagesWorker:(MFBSoapCall *) sc
{
    @autoreleasepool {
        if ([sc.errorString length] == 0)
        {
            [CommentedImage uploadImages:self.rgPicsForFlight progressUpdate:^(NSString * sz) {
                self.progressLabel.text = sz;
            } toPage:MFBConstants.MFBFLIGHTIMAGEUPLOADPAGE authString:self.szAuthToken keyName:MFBConstants.MFB_KEYFLIGHTIMAGE keyValue:[self.entryData.FlightID stringValue]];

            // If this was a pending flight, it will be in the pending flight list.  Remove it, if so.
            [[MFBAppDelegate threadSafeAppDelegate] dequeueUnsubmittedFlight:self];
        }
        [self performSelectorOnMainThread:@selector(operationCompleted:) withObject:sc waitUntilDone:NO];
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;
    
    if (self.stashedDate != nil) {
        self.entryData.Date = self.stashedDate;
        self.stashedDate = nil;
    }

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
    
    Telemetry * t = [Telemetry telemetryWithString:szTelemetry];
    if (t == nil)
        return;
    
    NSArray<CLLocation *> * samples = t.samples;
    
    self.rgPathLatLong = [[MFBWebServiceSvc_ArrayOfLatLong alloc] init];
    
    @try {
        for (CLLocation * loc in samples) {
            MFBWebServiceSvc_LatLong * ll = [[MFBWebServiceSvc_LatLong alloc] init];
            ll.Latitude = @(loc.coordinate.latitude);
            ll.Longitude = @(loc.coordinate.longitude);
            [self.rgPathLatLong.LatLong addObject:ll];
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
	
	if ([self.entryData isNewOrAwaitingUpload])
    {
        [self getPathFromInProgressTelemetry:(self.entryData.isNewFlight) ? MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString : self.entryData.FlightData];
        [self operationCompleted:nil];
        return;
    }
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	
	MFBWebServiceSvc_FlightPathForFlight * fp = [[MFBWebServiceSvc_FlightPathForFlight alloc] init];
	MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
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

	MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
	fp.szAuthUserToken = app.userProfile.AuthToken;
	fp.idFlight = entryData.FlightID;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b FlightPathForFlightGPXAsyncUsingParameters:fp delegate:sc];
    }];
}

#pragma Persistence
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    // Be sure NOT to encode this with the UTCDateFromLocalDate version from commitFlight
    // So if there is a stashed date, use that.
    NSDate * dtTemp = self.entryData.Date;
    if (self.stashedDate != nil)
        self.entryData.Date = self.stashedDate;
	[encoder encodeObject:self.entryData forKey:_szkeyEntryData];
    self.entryData.Date = dtTemp;
	[encoder encodeObject:self.rgPicsForFlight forKey:_szkeyImages];
    [encoder encodeBool:self.fIsPaused forKey:_szkeyIsPaused];
    [encoder encodeBool:self.fShuntPending forKey:_szkeyShuntPending];
    [encoder encodeDouble:self.dtTotalPauseTime forKey:_szkeyPausedTime];
    [encoder encodeDouble:self.dtTimeOfLastPause forKey:_szkeyLastPauseTime];
    [encoder encodeDouble:self.accumulatedNightTime forKey:_szkeyAccumulatedNightTime];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
    self.entryData = [decoder decodeObjectOfClass:MFBWebServiceSvc_LogbookEntry.class forKey:_szkeyEntryData];
    self.rgPicsForFlight = [NSMutableArray arrayWithArray:[decoder decodeObjectOfClasses:[NSSet setWithArray:@[NSArray.class, NSMutableArray.class, CommentedImage.class, MFBWebServiceSvc_MFBImageInfo.class]] forKey:_szkeyImages]];
    self.fIsPaused = [decoder decodeBoolForKey:_szkeyIsPaused];
    self.dtTotalPauseTime = [decoder decodeDoubleForKey:_szkeyPausedTime];
    self.dtTimeOfLastPause = [decoder decodeDoubleForKey:_szkeyLastPauseTime];
    
    @try
    {
        self.accumulatedNightTime = [decoder decodeDoubleForKey:_szkeyAccumulatedNightTime];
        self.fShuntPending = [decoder decodeBoolForKey:_szkeyShuntPending];
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
            le.entryData.FlightID = QUEUED_FLIGHT_UNSUBMITTED;

            le.errorString = [le.entryData fromJSONDictionary:d dateFormatter:dfDate dateTimeFormatter:dfDateTime];
            
            [MFBAppDelegate.threadSafeAppDelegate queueFlightForLater:le];
        }
    }
}
@end

@implementation MFBWebServiceSvc_LogbookEntry (MFBIPhone)

// Return the default (cross-fill) value to use for a long press on a given property, nil if none
- (NSNumber *) xfillValueForPropType:(MFBWebServiceSvc_CustomPropertyType *) cpt {
    if (cpt.PropTypeID.integerValue == PropTypeIDTachStart)
        return [Aircraft.sharedAircraft getHighWaterTachForAircraft:self.AircraftID];
    
    // if it's a decimal but not a basic decimal
    if (cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDecimal && (cpt.Flags.intValue & 0x00200000) == 0)
        return self.TotalFlightTime;
    
    if (cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpInteger) {
        if ((cpt.Flags.intValue & 0x08000000) == 0x08000000)
            return self.Landings;
        if ((cpt.Flags.intValue & 0x00001000) == 0x00001000)
            return self.Approaches;
    }
    
    return nil;
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
        
        AddNumber(self.HobbsStart, dict[@"flight_hobbsStart"], NumericTypeDecimal);
        AddNumber(self.HobbsEnd, dict[@"flight_hobbsStop"], NumericTypeDecimal);
        
        self.Date = [self parseDate:dict[@"flight_flightDate"] withFormatter:dfDate];
        self.FlightStart = [self parseDate:dict[@"flight_takeoffTime"] withFormatter:dfDateTime];
        self.FlightEnd = [self parseDate:dict[@"flight_landingTime"] withFormatter:dfDateTime];
        
        AddNumber(self.CrossCountry, dict[@"flight_crossCountry"], NumericTypeTime);
        AddNumber(self.Nighttime, dict[@"flight_night"], NumericTypeTime);
        AddNumber(self.SimulatedIFR, dict[@"flight_simulatedInstrument"], NumericTypeTime);
        AddNumber(self.IMC, dict[@"flight_actualInstrument"], NumericTypeTime);
        AddNumber(self.GroundSim, dict[@"flight_simulator"], NumericTypeTime);
        AddNumber(self.Dual, dict[@"flight_dualReceived"], NumericTypeTime);
        AddNumber(self.CFI, dict[@"flight_dualGiven"], NumericTypeTime);
        AddNumber(self.SIC, dict[@"flight_sic"], NumericTypeTime);
        AddNumber(self.PIC, dict[@"flight_pic"], NumericTypeTime);
        AddNumber(self.TotalFlightTime, dict[@"flight_totalTime"], NumericTypeTime);
        
        AddNumber(self.NightLandings, dict[@"flight_nightLandings"], NumericTypeInteger);
        AddNumber(self.FullStopLandings, dict[@"flight_dayLandings"], NumericTypeInteger);
        AddNumber(self.Landings, dict[@"flight_totalLandings"], NumericTypeInteger);
        
        if (dict[@"flight_holds"] != nil)
            self.fHoldingProcedures = [[USBoolean alloc] initWithBool:((NSString *) dict[@"flight_holds"]).integerValue > 0];
        self.fIsPublic = [[USBoolean alloc] initWithBool:NO];
        AddNumber(self.Approaches, dict[@"flight_totalApproaches"], NumericTypeInteger);
        
        // Now add a few properties that match to known property types
        [self addProperty:@(PropTypeIDIPC) withBool:dict[@"flight_instrumentProficiencyCheck"] != nil];
        [self addProperty:@(PropTypeIDBFR) withBool:dict[@"flight_review"] != nil];
        [self addProperty:@(PropTypeIDNightTakeOff) withInteger:[self parseNum:dict[@"flight_nightTakeoffs"] numType:NumericTypeInteger]];
        [self addProperty:@(PropTypeIDSolo) withDecimal:[self parseNum:dict[@"flight_solo"] numType:NumericTypeTime]];
        [self addProperty:@(PropTypeIDNameOfPIC) withString:dict[@"flight_selectedCrewPIC"]];
        [self addProperty:@(PropTypeIDNameOfSIC) withString:dict[@"flight_selectedCrewSIC"]];
        [self addProperty:@(PropTypeIDNameOfCFI) withString:dict[@"flight_selectedCrewInstructor"]];
        [self addProperty:@(PropTypeIDNameOfStudent) withString:dict[@"flight_selectedCrewStudent"]];

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

