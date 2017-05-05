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
//  SynchronousCalls.m
//  MFBSample
//
//  Created by Eric Berman on 10/30/15.
//
//

#import "SynchronousCalls.h"
#import "Util.h"
#import "AutodetectOptions.h"
#import "LogbookEntry.h"

@implementation SynchronousCalls

@synthesize returnedBody;

#pragma mark MFBSoapDelegate
- (MFBSoapCall *) getSoapCall
{
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.delegate = self;
    sc.timeOut = 20.0; // 20 second timeout
    return sc;
}

- (id) resultFromBody
{
    if ([self.returnedBody isKindOfClass:[MFBWebServiceSvc_GetCurrencyForUserResponse class]])
    {
        MFBWebServiceSvc_GetCurrencyForUserResponse * resp = (MFBWebServiceSvc_GetCurrencyForUserResponse *) self.returnedBody;
        MFBWebServiceSvc_ArrayOfCurrencyStatusItem * rgCs = resp.GetCurrencyForUserResult;
        
        return [MFBWebServiceSvc_CurrencyStatusItem toSimpleItems:rgCs.CurrencyStatusItem];
    }
    else if ([self.returnedBody isKindOfClass:[MFBWebServiceSvc_TotalsForUserResponse class]])
    {
        MFBWebServiceSvc_TotalsForUserResponse * resp = (MFBWebServiceSvc_TotalsForUserResponse *) self.returnedBody;
        MFBWebServiceSvc_ArrayOfTotalsItem * rgti = resp.TotalsForUserResult;
        return [MFBWebServiceSvc_TotalsItem toSimpleItems:rgti.TotalsItem];
    }
    else if ([self.returnedBody isKindOfClass:[MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse class]])
    {
        MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse * resp = (MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse *) self.returnedBody;
        MFBWebServiceSvc_ArrayOfLogbookEntry * rgle = resp.FlightsWithQueryAndOffsetResult;
        return [MFBWebServiceSvc_LogbookEntry toSimpleItems:rgle.LogbookEntry];
    }
    return nil;
}

- (NSArray *) currencyForUserSynchronous:(NSString *) szAuthToken
{
    if (szAuthToken == nil || szAuthToken.length == 0)
        return nil;
    
    MFBWebServiceSvc_GetCurrencyForUser * curSvc = [MFBWebServiceSvc_GetCurrencyForUser new];
    curSvc.szAuthToken = szAuthToken;
    
    [self.getSoapCall makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b GetCurrencyForUserUsingParameters:curSvc];
    } asSecure:YES];
    return (NSArray *) self.resultFromBody;
}

- (NSArray *) totalsForUserSynchronous: (NSString *) szAuthToken
{
    if (szAuthToken == nil || szAuthToken.length == 0)
        return nil;
    
    MFBWebServiceSvc_TotalsForUser * totSvc = [MFBWebServiceSvc_TotalsForUser new];
    totSvc.szAuthToken = szAuthToken;
    
    [self.getSoapCall makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b TotalsForUserUsingParameters:totSvc];
    } asSecure:YES];
    return (NSArray *) self.resultFromBody;
}

- (NSArray *) recentsForUserSynchronous: (NSString *) szAuthToken
{
    if (szAuthToken == nil || szAuthToken.length == 0)
        return nil;
    
    MFBWebServiceSvc_FlightsWithQueryAndOffset * recSvc = [MFBWebServiceSvc_FlightsWithQueryAndOffset new];
    recSvc.szAuthUserToken = szAuthToken;
    recSvc.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    recSvc.offset = @0;
    recSvc.maxCount = @10;

    [self.getSoapCall makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b FlightsWithQueryAndOffsetUsingParameters:recSvc];
    } asSecure:YES];
    return (NSArray *) self.resultFromBody;
}

- (void) BodyReturned:(id)body
{
    returnedBody = body;
}

- (void) ResultCompleted:(MFBSoapCall *) sc
{
}

@end
