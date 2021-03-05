/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2021 MyFlightbook, LLC
 
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
//  LogbookEntry.h
//  MFBSample
//
//  Created by Eric Berman on 12/2/09.
//  Copyright 2009-2019, MyFlightbook LLC All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"
#import "MFBSoapCall.h"
#import "MFBAppDelegate.h"

#define NEW_FLIGHT_ID @-1
#define PENDING_FLIGHT_ID @-2
#define QUEUED_FLIGHT_UNSUBMITTED @-3

@interface LogbookEntry : MFBAsyncOperation <MFBSoapCallDelegate, NSCoding, NSSecureCoding> {
	@private
	MFBWebServiceSvc_LogbookEntry * entryData;
	NSMutableArray * rgPicsForFlight;
    NSTimeInterval dtTotalPauseTime;
    NSTimeInterval dtTimeOfLastPause;

	NSString * szAuthToken;
	NSString * errorString;
	MFBWebServiceSvc_ArrayOfLatLong * rgPathLatLong;
    BOOL retVal;
}

// items to persist
@property (readwrite, strong) MFBWebServiceSvc_LogbookEntry * entryData;
@property (readwrite, strong) NSMutableArray * rgPicsForFlight;
@property (assign) BOOL fIsPaused;
@property (readwrite) BOOL fShuntPending;
@property (assign) NSTimeInterval dtTotalPauseTime;
@property (assign) NSTimeInterval dtTimeOfLastPause;
@property (readwrite) double accumulatedNightTime;

@property (readwrite, strong) MFBWebServiceSvc_ArrayOfLatLong * rgPathLatLong;
@property (readwrite, strong) NSString * szAuthToken;
@property (readwrite, strong) NSString * errorString;

@property (readwrite, strong) NSString * gpxPath;

// Progress label - NOT RETAINED
@property (weak) UILabel * progressLabel;

// Pause/unpause functionality
- (NSTimeInterval) timeSinceLastPaused;
- (NSTimeInterval) totalTimePaused;
- (void) pauseFlight;
- (void) unPauseFlight;


- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (void) commitFlight;
- (void) deleteFlight: (NSInteger) idFlight;
- (void) getFlightPath;
- (void) getGPXDataForFlight;

- (void) initNumerics;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (instancetype)initWithCoder:(NSCoder *)decoder;

+ (void) addPendingJSONFlights:(id) JSONObjToImport;

@end

@interface MFBWebServiceSvc_PendingFlight (MFBIPhone)
- (void)encodeWithCoderMFB:(NSCoder *)encoder;
- (instancetype)initWithCoderMFB:(NSCoder *)decoder;
@end

@interface MFBWebServiceSvc_LogbookEntry (AutodetectDelegate) <AutoDetectDelegate>
@end

@interface MFBWebServiceSvc_LogbookEntry (MFBIPhone)
- (BOOL) isNewFlight;
- (BOOL) isAwaitingUpload;
- (BOOL) isNewOrAwaitingUpload;
- (BOOL) isQueued;
- (BOOL) isInInitialState;  // checks to see if a flight is empty but for the starting hobbs
- (BOOL) isEmpty;           // checks to see if a flight is truly empty.
- (BOOL) isSigned; 
- (void)encodeWithCoderMFB:(NSCoder *)encoder;
- (instancetype)initWithCoderMFB:(NSCoder *)decoder;
+ (MFBWebServiceSvc_LogbookEntry *) getNewLogbookEntry;

- (BOOL) isKnownFlightStart;
- (BOOL) isKnownEngineStart;
- (BOOL) isKnownFlightEnd;
- (BOOL) isKnownEngineEnd;
- (BOOL) isKnownFlightTime;
- (BOOL) isKnownEngineTime;

- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withInteger:(NSNumber *) intVal;
- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withDecimal:(NSNumber *) decVal;
- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withString:(NSString *) sz;
- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withBool:(BOOL) fBool;
- (MFBWebServiceSvc_CustomFlightProperty *) addProperty:(NSNumber *) idPropType withDate:(NSDate *) dt;
- (void) addApproachDescription:(NSString *) description;
- (MFBWebServiceSvc_LogbookEntry *) clone;
- (MFBWebServiceSvc_LogbookEntry *) cloneAndReverse;
- (void) sendFlight;
- (void) shareFlight:(UIBarButtonItem *) sender fromViewController:(UIViewController *) source;

- (NSString *) fromJSONDictionary:(NSDictionary *) dict dateFormatter:(NSDateFormatter *) dfDate dateTimeFormatter:(NSDateFormatter *) dfDateTime;
@end

@interface MFBWebServiceSvc_FlightQuery (MFBIPhone)
+ (MFBWebServiceSvc_FlightQuery *) getNewFlightQuery;
- (BOOL) hasDate;
- (BOOL) hasText;
- (BOOL) hasFlightCharacteristics;
- (BOOL) hasAircraftCharacteristics;
- (BOOL) hasAirport;
- (BOOL) hasProperties;
- (BOOL) hasPropertyType:(MFBWebServiceSvc_CustomPropertyType *) cpt;
- (void) togglePropertyType:(MFBWebServiceSvc_CustomPropertyType *) cpt;
- (BOOL) hasAircraft;
- (BOOL) hasMakes;
- (BOOL) hasCatClasses;
- (BOOL) isUnrestricted;
@end
