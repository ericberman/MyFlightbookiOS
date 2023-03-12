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
//  LogbookEntry.h
//  MFBSample
//
//  Created by Eric Berman on 12/2/09.
//

#import <Foundation/Foundation.h>
#import "MFBAppDelegate.h"

// Conveninence methods to reduce objective-C churn
#define NEW_FLIGHT_ID MFBWebServiceSvc_LogbookEntry.idNewFlight
#define PENDING_FLIGHT_ID MFBWebServiceSvc_LogbookEntry.idPendingFlight
#define QUEUED_FLIGHT_UNSUBMITTED MFBWebServiceSvc_LogbookEntry.idQueuedFlight

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

- (BOOL) autoFillHobbs;
- (BOOL) autoFillTotal;
- (BOOL) autoCrossCountry:(NSTimeInterval) dtTotal;
- (BOOL) autoFillFinish;

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

@interface MFBWebServiceSvc_LogbookEntry (MFBIPhone)
- (NSNumber *) xfillValueForPropType:(MFBWebServiceSvc_CustomPropertyType *) cpt;
- (NSString *) fromJSONDictionary:(NSDictionary *) dict dateFormatter:(NSDateFormatter *) dfDate dateTimeFormatter:(NSDateFormatter *) dfDateTime;
@end
