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
//  SharedWatch.h
//  MFBSample
//
//  Created by Eric Berman on 10/28/15.
//
//

#ifndef SharedWatch_h
#define SharedWatch_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MFBWebServiceSvc.h"

// Dictionary key for kinds of messages
#define WATCH_MESSAGE_REQUEST_DATA @"messageRequestData"
#define WATCH_MESSAGE_ACTION @"messageRequestAction"

// Dictionary key for data requests
#define WATCH_REQUEST_STATUS @"watchRequestStatus"
#define WATCH_REQUEST_CURRENCY @"watchRequestCurrency"
#define WATCH_REQUEST_TOTALS @"watchRequestTotals"
#define WATCH_REQUEST_RECENTS @"watchRequestRecents"
#define WATCH_REQUEST_GLANCE @"watchRequestGlance"

// Dictionary key for result data
#define WATCH_RESPONSE_STATUS  @"sharedwatchStatus"
#define WATCH_RESPONSE_CURRENCY @"sharedwatchCurrency"
#define WATCH_RESPONSE_TOTALS @"sharedwatchTotals"
#define WATCH_RESPONSE_RECENTS @"sharedWatchRecents"

// Dictionary key for requested actions
#define WATCH_ACTION_START @"actionStartFlight"
#define WATCH_ACTION_END @"actionEndFlight"
#define WATCH_ACTION_TOGGLE_PAUSE @"actionTogglePause"

// Possible states for the flight-in-progress
typedef enum : NSUInteger {
    flightStageUnknown,
    flightStageUnstarted,
    flightStageInProgress,
    flightStageDone
} NewFlightStages;

@interface SimpleCurrencyItem : NSObject <NSCoding, NSSecureCoding> {
}

@property (strong) NSString * attribute;
@property (strong) NSString * value;
@property (strong) NSString * discrepancy;
@property (readwrite) MFBWebServiceSvc_CurrencyState state;

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@interface SimpleTotalItem : NSObject <NSCoding, NSSecureCoding> {
}

@property (strong) NSString * title;
@property (strong) NSString * valueDisplay;
@property (strong) NSString * subDesc;

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@end

@interface SimpleLogbookEntry : NSObject <NSCoding, NSSecureCoding> {
}

@property (strong) NSString * Comment;
@property (strong) NSString * Route;
@property (strong) NSDate * Date;
@property (strong) NSString * TotalTimeDisplay;
@property (strong) NSString * TailNumDisplay;

@end

@interface SharedWatch : NSObject <NSCoding, NSSecureCoding> {
}

@property (strong) NSString * latDisplay;
@property (strong) NSString * lonDisplay;
@property (strong) NSString * speedDisplay;
@property (strong) NSString * altDisplay;
@property (strong) NSString * flightstatus;
@property (strong) SimpleLogbookEntry * latestFlight;
@property (nonatomic, readwrite) BOOL isPaused;
@property (nonatomic, readwrite) BOOL isRecording;
@property (nonatomic, readwrite) double elapsedSeconds;
@property (nonatomic, readwrite) NewFlightStages flightStage;
@end

#endif /* SharedWatch_h */
