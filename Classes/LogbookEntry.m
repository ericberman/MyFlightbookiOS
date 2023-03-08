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
#import "FlightProps.h"

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

// keys for preferences.
NSString * const _szkeyHasSavedState = @"pref_leSavedState";
NSString * const _szkeySavedLE = @"pref_savedLE2";
NSString * const _szkeyFlightID = @"pref_leFlightID";
NSString * const _szKeyPendingID = @"pref_lePendingID";
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
    
    BOOL fIsCC = (maxDist >= CROSS_COUNTRY_THRESHOLD);

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
                if (cfp.PropTypeID.integerValue == PropTypeID_BlockOut)
                    blockOut = cfp.DateValue;
                if (cfp.PropTypeID.integerValue == PropTypeID_BlockIn)
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
    
    double tachStart = [self.entryData getExistingProperty:@(PropTypeID_TachStart)].DecValue.doubleValue;
    double tachEnd = [self.entryData getExistingProperty:@(PropTypeID_TachEnd)].DecValue.doubleValue;
    double time = (self.entryData.HobbsEnd.doubleValue > self.entryData.HobbsStart.doubleValue && self.entryData.HobbsStart.doubleValue > 0) ?
        self.entryData.HobbsEnd.doubleValue - self.entryData.HobbsStart.doubleValue :
        (tachEnd > tachStart && tachStart > 0) ? tachEnd - tachStart : self.entryData.TotalFlightTime.doubleValue;
    
    if (time > 0) {
        double cost = rate * time;
        MFBWebServiceSvc_CustomFlightProperty * cfp = [self.entryData getExistingProperty:@(PropTypeID_FlightCost)];
        if (cfp == nil)
            cfp = [self.entryData addProperty:@(PropTypeID_FlightCost) withDecimal:@(cost)];
        else
            cfp.DecValue = @(cost);
    }
}

- (void) autoFillFuel {
    MFBWebServiceSvc_CustomFlightProperty * cfpFuelAtStart = [self.entryData getExistingProperty:@(PropTypeID_FuelAtStart)];
    MFBWebServiceSvc_CustomFlightProperty * cfpFuelAtEnd = [self.entryData getExistingProperty:@(PropTypeID_FuelAtEnd)];
    
    double fuelConsumed = MAX(cfpFuelAtStart.DecValue.doubleValue - cfpFuelAtEnd.DecValue.doubleValue, 0);
    if (fuelConsumed > 0) {
        MFBWebServiceSvc_CustomFlightProperty * cfp = [self.entryData getExistingProperty:@(PropTypeID_FuelConsumed)];
        if (cfp == nil)
            cfp = [self.entryData addProperty:@(PropTypeID_FuelConsumed) withDecimal:@(fuelConsumed)];
        else
            cfp.DecValue = @(fuelConsumed);
        
        if (self.entryData.TotalFlightTime.doubleValue > 0) {
            double burnRate = fuelConsumed / self.entryData.TotalFlightTime.doubleValue;
            cfp = [self.entryData getExistingProperty:@(PropTypeID_FuelBurnRate)];
            if (cfp == nil)
                cfp = [self.entryData addProperty:@(PropTypeID_FuelBurnRate) withDecimal:@(burnRate)];
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
        MFBWebServiceSvc_CustomFlightProperty * cfpLessonStart = [self.entryData getExistingProperty:@(PropTypeID_LessonStart)];
        MFBWebServiceSvc_CustomFlightProperty * cfpLessonEnd = [self.entryData getExistingProperty:@(PropTypeID_LessonEnd)];
        
        if (cfpLessonEnd == nil || cfpLessonStart == nil || [cfpLessonEnd.DateValue compare:cfpLessonStart.DateValue] != NSOrderedDescending)
            return;

        NSTimeInterval tsLesson = [cfpLessonEnd.DateValue timeIntervalSinceDate:cfpLessonStart.DateValue];

        // pull out flight or engine time, whichever is greater
        NSTimeInterval tsFlight = self.entryData.isKnownFlightEnd && self.entryData.isKnownFlightStart && [self.entryData.FlightEnd compare:self.entryData.FlightStart] == NSOrderedDescending ? [self.entryData.FlightEnd timeIntervalSinceDate:self.entryData.FlightStart] : 0;
        NSTimeInterval tsEngine = self.entryData.isKnownEngineEnd && self.entryData.isKnownEngineStart && [self.entryData.EngineEnd compare:self.entryData.EngineStart] == NSOrderedDescending ? [self.entryData.EngineEnd timeIntervalSinceDate:self.entryData.EngineStart] : 0;
        
        NSTimeInterval tsNonGround = MAX(MAX(tsFlight, tsEngine), 0);
        
        double groundHours = (tsLesson - tsNonGround) / 3600.0;
        
        int idPropTarget = dual > 0 ? PropTypeID_GroundInstructionReceived : PropTypeID_GroundInstructionGiven;
        
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
            } toPage:MFBFLIGHTIMAGEUPLOADPAGE authString:self.szAuthToken keyName:MFB_KEYFLIGHTIMAGE keyValue:[self.entryData.FlightID stringValue]];

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

@implementation MFBWebServiceSvc_LogbookEntry (AutodetectDelegate)
- (void) autofillClosest
{
    self.Route = [Airports appendNearestAirport:self.Route];
}

- (NSString *) takeoffDetected;
{
    if (!self.isKnownFlightStart)
        self.FlightStart = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc.timestamp;
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
        self.FlightEnd = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc.timestamp;
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

@implementation MFBWebServiceSvc_PendingFlight (MFBIPhone)
- (void)encodeWithCoderMFB:(NSCoder *)encoder {
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.PendingID forKey:_szKeyPendingID];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    self.PendingID = [decoder decodeObjectOfClass:NSString.class forKey:_szKeyPendingID];
    return self;
}

- (MFBWebServiceSvc_LogbookEntry *) clone {
    self.PendingID = nil;
    return [super clone];
}

- (MFBWebServiceSvc_LogbookEntry *) cloneAndReverse {
    self.PendingID = nil;
    return [super cloneAndReverse];
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
    le.Nighttime = @0;
    le.PIC = @0;
    le.Landings = @0;
    le.NightLandings = @0;
    
    le.Approaches = @0;
    le.CFI =  @0;
    le.CrossCountry = @0;
    le.Dual = @0;
    le.FullStopLandings = @0;
    le.HobbsEnd = @0;
    le.HobbsStart = @0;
    le.IMC = @0;
    le.Nighttime = @0;
    le.SIC = @0;
    le.SimulatedIFR = @0;
    le.GroundSim = @0;
    le.TotalFlightTime = @0;
    
    le.fHoldingProcedures = [[USBoolean alloc] initWithBool:NO];
    le.fIsPublic = [[USBoolean alloc] initWithBool:NO];
    
    le.CatClassOverride = @0;
    
    return le;
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
        return [[[FlightProps getFlightPropsNoNet] distillList:self.CustomProperties.CustomFlightProperty includeLockedProps:NO includeTemplates:nil] count] == 0;
    
    return NO;
}

// isEmpty is a truly empty flight - ininitialstate AND empty hobbs start.
- (BOOL) isEmpty
{
    return self.HobbsStart.doubleValue == 0.0 && self.isInInitialState;
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
	self.AircraftID = [decoder decodeObjectOfClass:NSNumber.class forKey:@"AircraftID"];

	self.FlightID = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyFlightID];
	self.AircraftID = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyAircraftID];
	self.Approaches = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyApproaches];
	self.CFI = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyCFI];
	self.Comment = [decoder decodeObjectOfClass:NSString.class forKey:_szkeyComment];
	self.CrossCountry = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyCrossCountry];
	self.Date = [decoder decodeObjectOfClass:NSDate.class forKey:_szkeyDate];
	self.Dual = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyDual];
	self.EngineEnd = [decoder decodeObjectOfClass:NSDate.class forKey:_szkeyEngineEnd];
	self.EngineStart = [decoder decodeObjectOfClass:NSDate.class forKey:_szkeyEngineStart];
	self.FlightEnd = [decoder decodeObjectOfClass:NSDate.class forKey:_szkeyFlightEnd];
	self.FlightStart = [decoder decodeObjectOfClass:NSDate.class forKey:_szkeyFlightStart];
	self.FullStopLandings = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyFullStopLandings];
	self.HobbsEnd = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyHobbsEnd];
	self.HobbsStart = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyHobbsStart];
	self.IMC = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyIMC];
	self.Landings = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyLandings];
	self.NightLandings = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyNightLandings];
	self.Nighttime = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyNight];
	self.PIC = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyPIC];
	self.Route = [decoder decodeObjectOfClass:NSString.class forKey:_szkeyRoute];
	self.SIC = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeySIC];
	self.SimulatedIFR = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeySimulatedIFR];
	self.GroundSim = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyGroundSim];
	if (self.GroundSim == nil)
		self.GroundSim = @0.0;
	self.TotalFlightTime = [decoder decodeObjectOfClass:NSNumber.class forKey:_szkeyTotalFlight];
	self.User = [decoder decodeObjectOfClass:NSString.class forKey:_szkeyUser];
	self.FlightData = [decoder decodeObjectOfClass:NSString.class forKey:_szKeyFlightData];
	
    self.CustomProperties = [decoder decodeObjectOfClasses:[NSSet setWithArray:@[NSArray.class, MFBWebServiceSvc_CustomFlightProperty.class, MFBWebServiceSvc_ArrayOfCustomFlightProperty.class, MFBWebServiceSvc_CustomPropertyType.class]] forKey:_szKeyCustomProperties];

	self.fHoldingProcedures = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyHolding]];
	self.fIsPublic = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szkeyIsPublic]];
	
	self.CatClassOverride = [decoder decodeObjectOfClass:NSNumber.class forKey:_szKeyCatClassOverride];
	if (self.CatClassOverride == nil)
		self.CatClassOverride = @0;
	
	return self;
}

#pragma mark - Clone/Reverse
- (MFBWebServiceSvc_LogbookEntry *) clone {
    // A bit of a hack for a deep copy: encode it then decode it.
    NSError * err = nil;
    NSData * thisArchived = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:&err];
    MFBWebServiceSvc_LogbookEntry * leNew = [NSKeyedUnarchiver unarchivedObjectOfClass:MFBWebServiceSvc_LogbookEntry.class fromData:thisArchived error:&err];
    leNew.FlightID = NEW_FLIGHT_ID;
    
    if (leNew.CustomProperties != nil)
        for (MFBWebServiceSvc_CustomFlightProperty * cfp in leNew.CustomProperties.CustomFlightProperty) {
            cfp.FlightID = NEW_FLIGHT_ID;
            cfp.PropID = NEW_PROP_ID;
        }
    
    leNew.Date = [NSDate new];
    leNew.EngineStart = [NSDate distantPast];
    leNew.EngineEnd = [NSDate distantPast];
    leNew.FlightStart = [NSDate distantPast];
    leNew.FlightEnd = [NSDate distantPast];
    leNew.HobbsEnd = @0.0;
    leNew.HobbsStart = @0.0;
    leNew.FlightData = @"";
    leNew.FlightImages = [[MFBWebServiceSvc_ArrayOfMFBImageInfo alloc] init];
    
    return leNew;
}

- (MFBWebServiceSvc_LogbookEntry *) cloneAndReverse {
    MFBWebServiceSvc_LogbookEntry * leNew = [self clone];
    NSArray<NSString *> * ar = [Airports CodesFromString:leNew.Route];
    NSMutableString * s = [[NSMutableString alloc] init];
    for (long i = ar.count - 1; i >= 0; i--)
        [s appendFormat:@"%@ ", ar[i]];
    leNew.Route = s;
    return leNew;
}

#pragma mark - Known/Unknown Times

- (MFBWebServiceSvc_CustomFlightProperty *) getNewProperty:(NSNumber *) idPropType
{
    MFBWebServiceSvc_CustomFlightProperty * fp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
    fp.FlightID = self.FlightID;
    fp.PropTypeID = idPropType;
    return fp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) getExistingProperty:(NSNumber *) idPropType
{
    for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.CustomProperties.CustomFlightProperty)
        if (cfp.PropTypeID.intValue == idPropType.intValue)
            return cfp;
    return nil;
}

///Like RemoveProperty but deletes from the server if necessary (i.e., if it has a PropID > 0)
- (void) removeProperty:(NSNumber *)idPropType withServerAuth:(NSString *) szAuthToken deleteSvc:(FlightProps *) fp {
    int idProp = idPropType.intValue;
    NSArray<MFBWebServiceSvc_CustomFlightProperty *> * r = [self.CustomProperties.CustomFlightProperty filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MFBWebServiceSvc_CustomFlightProperty *  _Nullable cfp, NSDictionary<NSString *,id> * _Nullable bindings) {
        return cfp.PropTypeID.intValue == idProp;
    }]];
    if (r.count > 1)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Multiple properties found with the same ID" userInfo:nil];
    if (r.count == 1 && r[0].PropID.intValue > 0) {
        if (szAuthToken == nil || szAuthToken.length == 0 || fp == nil)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Removing a property with a positive ID but no authtoken or flight props service provided; delete the property instead" userInfo:nil];
        [fp deleteProperty:r[0] forUser:szAuthToken];   // kick off thread to delete on the server
    }
    [self.CustomProperties.CustomFlightProperty removeObjectsInArray:r];
}

- (void) removeProperty:(NSNumber *) idPropType {
    [self removeProperty:idPropType withServerAuth:nil deleteSvc:nil];
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

- (MFBWebServiceSvc_CustomFlightProperty *) setPropertyValue:(NSNumber *) idPropType withDecimal:(NSNumber *) decVal {
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self getExistingProperty:idPropType];
    if (cfp == nil)
        return [self addProperty:idPropType withDecimal:decVal];
    else
        cfp.DecValue = decVal;
    return cfp;
}

- (MFBWebServiceSvc_CustomFlightProperty *) setPropertyValue:(NSNumber *) idPropType withDate:(NSDate *) dt {
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self getExistingProperty:idPropType];
    if (cfp == nil)
        return [self addProperty:idPropType withDate:dt];
    else
        cfp.DateValue = dt;
    return cfp;
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

// Return the default (cross-fill) value to use for a long press on a given property, nil if none
- (NSNumber *) xfillValueForPropType:(MFBWebServiceSvc_CustomPropertyType *) cpt {
    if (cpt.PropTypeID.integerValue == PropTypeID_TachStart)
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

- (void) addApproachDescription:(NSString *) description {
    if (self.CustomProperties == nil)
        self.CustomProperties = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
    
    // See if the flight has an approach description attached.  If not, add it.
    MFBWebServiceSvc_CustomFlightProperty * fpDescription = nil;
    for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.CustomProperties.CustomFlightProperty)
        if ([cfp.PropTypeID intValue] == PropTypeID_ApproachName)
        {
            fpDescription = cfp;
            break;
        }
    
    if (fpDescription == nil)
        [self addProperty:@PropTypeID_ApproachName withString:description];
    else
        fpDescription.TextValue = [[NSString stringWithFormat:@"%@ %@", fpDescription.TextValue, description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
        [self addProperty:@PropTypeID_IPC withBool:dict[@"flight_instrumentProficiencyCheck"] != nil];
        [self addProperty:@PropTypeID_BFR withBool:dict[@"flight_review"] != nil];
        [self addProperty:@PropTypeID_NightTakeOff withInteger:[self parseNum:dict[@"flight_nightTakeoffs"] numType:NumericTypeInteger]];
        [self addProperty:@PropTypeID_Solo withDecimal:[self parseNum:dict[@"flight_solo"] numType:NumericTypeTime]];
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

- (void) sendFlight {
    if (self.SendFlightLink.length == 0)
        return;
    
    NSString * szEncodedSubject = [NSLocalizedString(@"flightActionSendSubject", @"Flight Action - Send Subject") stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * szEncodedBody = [[NSString stringWithFormat:NSLocalizedString(@"flightActionSendBody", @"Flight Action - Send Body"), self.SendFlightLink] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * szURL = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
                        szEncodedSubject,
                        szEncodedBody];
    
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: szURL] options:@{} completionHandler:nil];
}

- (void) shareFlight:(UIBarButtonItem *) sender fromViewController:(UIViewController *) source {
    if (self.SocialMediaLink.length == 0)
        return;
    
    NSString * szComment = [[NSString stringWithFormat:@"%@ %@", self.Comment, self.Route] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSURL * url = [NSURL URLWithString:self.SocialMediaLink];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:@[szComment, url] applicationActivities:nil];
    
    UIBarButtonItem * bbi = (UIBarButtonItem *) sender;
    UIView * bbiView = [bbi valueForKey:@"view"];
    avc.popoverPresentationController.sourceView = bbiView;
    avc.popoverPresentationController.sourceRect = bbiView.frame;
    
    avc.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                  UIActivityTypePrint,
                                  UIActivityTypeAssignToContact,
                                  UIActivityTypeSaveToCameraRoll,
                                  UIActivityTypeAddToReadingList,
                                  UIActivityTypePostToFlickr,
                                  UIActivityTypePostToVimeo];
    
    [source presentViewController:avc animated:YES completion:nil];
}

@end

