/*
   MyFlightbook for iOS - provides native access to MyFlightbook
   pilot's logbook
Copyright (C) 2009-2020 MyFlightbook, LLC

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
//  PackAndGo.m
//  MyFlightbook
//
//  Created by Eric Berman on 5/19/20.
//

#import <Foundation/Foundation.h>
#import "PackAndGo.h"
#import "LogbookEntry.h"
#import "FlightProps.h"

@implementation PackAndGo

@synthesize authToken, errorString;

#define keyCurrency @"packedCurrencyKey"
#define keyTotals @"packedTotalsKey"
#define keyFlights @"packedFlightsKey"
#define keyAirports @"packedAirportsKey"
#define keyCurrencyDate @"packedCurrencyDate"
#define keyTotalsDate @"packedTotalsKeyDate"
#define keyFlightsDate @"packedFlightsKeyDate"
#define keyAirportsDate @"packedAirportsKeyDate"
#define keyPackedDate @"packedAllDate"

- (instancetype) init {
    if (self = [super init]) {
        self.authToken = self.errorString = @"";
    }
    return self;
}

#pragma mark - Storing/retrieving
+ (NSDate *) dateForKey:(NSString *) key {
    return (NSDate *) [NSUserDefaults.standardUserDefaults objectForKey:key];
}

+ (void) setDate: (NSDate *) dt forKey:(NSString *) key {
    NSUserDefaults * defs = NSUserDefaults.standardUserDefaults;
    [defs setObject:dt forKey:key];
    [defs synchronize];
}

+ (NSArray *) valuesForKey:(NSString *) key {
    return (NSArray *) [NSKeyedUnarchiver unarchiveObjectWithData:[NSUserDefaults.standardUserDefaults objectForKey:key]];
}

+ (void) setValues:(NSArray *) arr forKey:(NSString *) key {
    NSUserDefaults * defs = NSUserDefaults.standardUserDefaults;
    [defs setObject:[NSKeyedArchiver archivedDataWithRootObject:arr] forKey:key];
    [defs synchronize];
}

+ (void) clearPackedData {
    NSUserDefaults * defs = NSUserDefaults.standardUserDefaults;
    [defs setValue:nil forKey:keyCurrency];
    [defs setValue:nil forKey:keyTotals];
    [defs setValue:nil forKey:keyFlights];
    [defs setValue:nil forKey:keyAirports];
    [defs setValue:nil forKey:keyCurrencyDate];
    [defs setValue:nil forKey:keyTotalsDate];
    [defs setValue:nil forKey:keyFlightsDate];
    [defs setValue:nil forKey:keyAirportsDate];
    [defs setObject:nil forKey:keyPackedDate];
    [defs synchronize];
}

+ (NSDate *) lastPackDate {
    return (NSDate *) [NSUserDefaults.standardUserDefaults objectForKey:keyPackedDate];
}

+ (void) setLastPackDate:(NSDate *)dt {
    NSUserDefaults * defs = NSUserDefaults.standardUserDefaults;
    [defs setObject:dt forKey:keyPackedDate];
    [defs synchronize];
}

#pragma mark - Retrieving from WebServices
- (void) BodyReturned:(id)body {
    if ([body isKindOfClass:MFBWebServiceSvc_GetCurrencyForUserResponse.class]) {
        MFBWebServiceSvc_GetCurrencyForUserResponse * resp = (MFBWebServiceSvc_GetCurrencyForUserResponse *) body;
        [PackAndGo updateCurrency:resp.GetCurrencyForUserResult.CurrencyStatusItem];
    } else if ([body isKindOfClass:MFBWebServiceSvc_TotalsForUserWithQueryResponse.class]) {
        MFBWebServiceSvc_TotalsForUserWithQueryResponse * resp = (MFBWebServiceSvc_TotalsForUserWithQueryResponse *) body;
        [PackAndGo updateTotals:resp.TotalsForUserWithQueryResult.TotalsItem];
    } else if ([body isKindOfClass:[MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse class]]) {
        MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse * resp = (MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse *) body;
        [PackAndGo updateFlights:resp.FlightsWithQueryAndOffsetResult.LogbookEntry];
    } else if ([body isKindOfClass:[MFBWebServiceSvc_VisitedAirportsResponse class]]) {
        MFBWebServiceSvc_VisitedAirportsResponse * resp = (MFBWebServiceSvc_VisitedAirportsResponse *) body;
        [PackAndGo updateVisited:resp.VisitedAirportsResult.VisitedAirport];
    } else if ([body isKindOfClass:MFBWebServiceSvc_AircraftForUserResponse.class]) {
        MFBWebServiceSvc_AircraftForUserResponse * resp = (MFBWebServiceSvc_AircraftForUserResponse *) body;
        [Aircraft.sharedAircraft cacheAircraft:resp.AircraftForUserResult.Aircraft forUser:self.authToken];
    } else if ([body isKindOfClass:MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse.class]) {
        MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse * resp = (MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse *) body;
        [FlightProps.new cachePropsAndTemplates:resp];
    }
}

- (void) ResultCompleted:(MFBSoapCall *) sc {
    self.errorString = sc.errorString;
}

- (MFBSoapCall *) getSoapCall {
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.delegate = self;
    sc.timeOut = 60.0; // 60 second timeout
    return sc;
}

#pragma mark - Currency
- (BOOL) packCurrency {
    MFBWebServiceSvc_GetCurrencyForUser * currencyForUserSVC = [MFBWebServiceSvc_GetCurrencyForUser new];
    
    currencyForUserSVC.szAuthToken = self.authToken;
    
    MFBSoapCall * sc = [self getSoapCall];
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b GetCurrencyForUserUsingParameters:currencyForUserSVC];
    } asSecure:YES];
    self.errorString = sc.errorString;
    return self.errorString.length == 0;
}

+ (void) updateCurrency:(NSArray<MFBWebServiceSvc_CurrencyStatusItem *> *) currency {
    [PackAndGo setValues:currency forKey:keyCurrency];
    [PackAndGo setDate:[NSDate new] forKey:keyCurrencyDate];
}

+ (NSArray<MFBWebServiceSvc_CurrencyStatusItem *> *) cachedCurrency {
    return (NSArray<MFBWebServiceSvc_CurrencyStatusItem *> *) [PackAndGo valuesForKey:keyCurrency];
}

+ (NSDate *) lastCurrencyPackDate {
    return [PackAndGo dateForKey:keyCurrencyDate];
}

#pragma mark - Totals
- (BOOL) packTotals {
    MFBWebServiceSvc_TotalsForUserWithQuery * totalsForUserSVC = [MFBWebServiceSvc_TotalsForUserWithQuery new];
    totalsForUserSVC.szAuthToken = self.authToken;
    totalsForUserSVC.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery]; // always a blank query for all totals
    
    MFBSoapCall * sc = [self getSoapCall];
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b TotalsForUserWithQueryUsingParameters:totalsForUserSVC];
    } asSecure:YES];
    self.errorString = sc.errorString;
    return self.errorString.length == 0;
}

+ (void) updateTotals:(NSArray<MFBWebServiceSvc_TotalsItem *> *) totals {
    [PackAndGo setValues:totals forKey:keyTotals];
    [PackAndGo setDate:[NSDate new] forKey:keyTotalsDate];
}

+ (NSArray<MFBWebServiceSvc_TotalsItem *> *) cachedTotals {
    return (NSArray<MFBWebServiceSvc_TotalsItem *> *) [PackAndGo valuesForKey:keyTotals];
}

+ (NSDate *) lastTotalsPackDate {
    return [PackAndGo dateForKey:keyTotalsDate];
}

#pragma mark - flights
- (BOOL) packFlights {
    MFBWebServiceSvc_FlightsWithQueryAndOffset * fbdSVC = [MFBWebServiceSvc_FlightsWithQueryAndOffset new];
    
    fbdSVC.szAuthUserToken = self.authToken;
    fbdSVC.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    fbdSVC.offset = @0;
    fbdSVC.maxCount = @-1;
    
    MFBSoapCall * sc = [self getSoapCall];
    
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b FlightsWithQueryAndOffsetUsingParameters:fbdSVC];
    } asSecure:YES];
    self.errorString = sc.errorString;
    return self.errorString.length == 0;
}

+ (void) updateFlights:(NSArray<MFBWebServiceSvc_LogbookEntry *> *) flights {
    [PackAndGo setValues:flights forKey:keyFlights];
    [PackAndGo setDate:[NSDate new] forKey:keyFlightsDate];
}

+ (NSArray<MFBWebServiceSvc_LogbookEntry *> *) cachedFlights {
    return (NSArray<MFBWebServiceSvc_LogbookEntry *> *) [PackAndGo valuesForKey:keyFlights];
}

+ (NSDate *) lastFlightsPackDate {
    return [PackAndGo dateForKey:keyFlightsDate];
}

#pragma mark - Aircraft and Props
- (BOOL) packAircraft {
    MFBWebServiceSvc_AircraftForUser * acSvc = MFBWebServiceSvc_AircraftForUser.new;
    acSvc.szAuthUserToken = self.authToken;
    MFBSoapCall * sc =  [self getSoapCall];
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b AircraftForUserUsingParameters:acSvc];
    } asSecure:YES];

    self.errorString = sc.errorString;
    return self.errorString.length == 0;
}

- (BOOL) packProps {
    MFBWebServiceSvc_PropertiesAndTemplatesForUser * fpSvc = MFBWebServiceSvc_PropertiesAndTemplatesForUser.new;
     fpSvc.szAuthUserToken = self.authToken;
     MFBSoapCall * sc =  [self getSoapCall];
     [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
         return [b PropertiesAndTemplatesForUserUsingParameters:fpSvc];
     } asSecure:YES];

     self.errorString = sc.errorString;
     return self.errorString.length == 0;
}

#pragma mark - Visited
- (BOOL) packVisited {
    MFBWebServiceSvc_VisitedAirports * visitedAirportsSVC = [MFBWebServiceSvc_VisitedAirports new];

    visitedAirportsSVC.szAuthToken = self.authToken;

    MFBSoapCall * sc = [self getSoapCall];

    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b VisitedAirportsUsingParameters:visitedAirportsSVC];
    } asSecure:YES];
    self.errorString = sc.errorString;
    return self.errorString.length == 0;
}

+ (void) updateVisited:(NSArray<MFBWebServiceSvc_VisitedAirport *> *) visited {
    [PackAndGo setValues:visited forKey:keyAirports];
    [PackAndGo setDate:[NSDate new] forKey:keyAirportsDate];
}

+ (NSArray<MFBWebServiceSvc_VisitedAirport *> *) cachedVisited {
    return (NSArray<MFBWebServiceSvc_VisitedAirport *> *) [PackAndGo valuesForKey:keyAirports];
}

+ (NSDate *) lastVisitedPackDate {
    return [PackAndGo dateForKey:keyAirportsDate];
}
@end
