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
//  PackAndGo.h
//  MFBSample
//
//  Created by Eric Berman on 5/19/20.
//

#ifndef PackAndGo_h
#define PackAndGo_h

#import "MFBWebServiceSvc.h"
#import <MyFlightbook-Swift.h>

@interface PackAndGo : NSObject<MFBSoapCallDelegate> {
}

- (BOOL) packAircraft;
- (BOOL) packProps;
- (BOOL) packCurrency;
+ (void) updateCurrency:(NSArray<MFBWebServiceSvc_CurrencyStatusItem *> *) currency;
+ (NSArray<MFBWebServiceSvc_CurrencyStatusItem *> *) cachedCurrency;
+ (NSDate *) lastCurrencyPackDate;
- (BOOL) packTotals;
+ (void) updateTotals:(NSArray<MFBWebServiceSvc_TotalsItem *> *) totals;
+ (NSArray<MFBWebServiceSvc_TotalsItem *> *) cachedTotals;
+ (NSDate *) lastTotalsPackDate;
- (BOOL) packFlights;
+ (void) updateFlights:(NSArray<MFBWebServiceSvc_LogbookEntry *> *) flights;
+ (NSArray<MFBWebServiceSvc_LogbookEntry *> *) cachedFlights;
+ (NSDate *) lastFlightsPackDate;
- (BOOL) packVisited;
+ (void) updateVisited:(NSArray<MFBWebServiceSvc_VisitedAirport *> *) visited;
+ (NSArray<MFBWebServiceSvc_VisitedAirport *> *) cachedVisited;
+ (NSDate *) lastVisitedPackDate;
+ (void) clearPackedData;

+ (NSDate *) lastPackDate;
+ (void) setLastPackDate:(NSDate *)dt;

@property (strong) NSString * authToken;
@property (strong) NSString * errorString;

@end


#endif /* PackAndGo_h */
