/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2009-2022 MyFlightbook, LLC
 
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
//  MFBSoapCall.m
//  MFBSample
//
//  Created by Eric Berman on 12/20/09.
//  Copyright 2009-2019 MyFlightbook LLC. All rights reserved.
//

#import "MFBSoapCall.h"
#import "MFBAppDelegate.h"

@implementation MFBSoapCall

@synthesize delegate, logCallData, errorString, timeOut, contextFlag;

- (instancetype) init
{
    if (self = [super init])
    {
        self.logCallData = NO;
        self.errorString = nil;
        self.delegate = nil;
        self.timeOut = 0;
        self.contextFlag = 0;
    }
	return self;
}

#pragma mark Hack retain/release for async calls
// the wsdl2objc code treats the delegate as ASSIGN not RETAIN (to avoid cycles?) so we are not retained while the async operaiton completes.
// We hack retain ourselves by adding to a static array for the duration of the clal
static NSMutableArray * _rgHackRetain = nil;

+ (void) hackARCRetain:(MFBSoapCall *) sc
{
    if (_rgHackRetain == nil)
        _rgHackRetain = [NSMutableArray new];
    [_rgHackRetain addObject:sc];
}

+ (void) hackARCRelease:(MFBSoapCall *) sc
{
    if (_rgHackRetain == nil)
        return;
    [_rgHackRetain removeObject:sc];
}

#pragma mark Actual functionality
- (MFBWebServiceSoapBinding *) setUpBinding:(BOOL)fSecure
{
	if (![[MFBAppDelegate threadSafeAppDelegate] isOnLine])
	{
		self.errorString = NSLocalizedString(@"No access to the Internet", @"Error message if app cannot connect to the Internet");
		return nil;
	}
	
	MFBWebServiceSoapBinding * binding = [MFBWebServiceSvc MFBWebServiceSoapBinding];
	if (self.timeOut != 0)
        binding.timeout = self.timeOut;
    
    if (binding.timeout < 30)
        binding.timeout = 30; // at least 30 seconds for a timeout.
    
    // request the correct language/locale
    NSString * szPreferredLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString * szPreferredLanguage = [NSLocale preferredLanguages][0];
    
    NSArray * rgElem = [szPreferredLocale componentsSeparatedByString:@"_"];
    
    if ([rgElem count] >= 2)
    {
        NSString * szAcceptsHeader = [NSString stringWithFormat:@"%@-%@", szPreferredLanguage, rgElem[1]];
        [binding.customHeaders setValue:szAcceptsHeader forKey:@"Accept-Language"];
    }
	
    fSecure = YES;  // New with iOS 9 App Transport Security - default to secure connections
#ifdef DEBUG
	binding.logXMLInOut = self.logCallData;
	if ([MFBHOSTNAME hasPrefix:@"192."] || [MFBHOSTNAME hasPrefix:@"10."] || [MFBHOSTNAME hasPrefix:@"BERMAN"])
		fSecure = NO;
#endif
	
	NSURL *testAddress = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http%@://%@/logbook/public/WebService.asmx", (fSecure ? @"s" : @""), MFBHOSTNAME]];
	binding.address = testAddress;

    return binding;
}

- (BOOL) parseResponse:(MFBWebServiceSoapBindingResponse *) response
{
    BOOL retVal = YES;

    if (response != nil && [[response.error localizedDescription] length] > 0)
	{
		retVal = NO;
		self.errorString = [response.error localizedDescription];
		NSLog(@"MFBSoapCall.m - MakeCall - Error: %@", self.errorString);
	}
	
	NSArray * responseHeaders = response.headers;
	NSArray * responseBodyParts = response.bodyParts;
    
	for (id header in responseHeaders)
	{
		if (self.delegate != nil && [((NSObject *) self.delegate) respondsToSelector:@selector(HeaderReturned:)])
			[self.delegate HeaderReturned:header];
	}
	
	for (id bodyPart in responseBodyParts)
	{
		if ([bodyPart isKindOfClass:[SOAPFault class]])
		{
			SOAPFault * sf = (SOAPFault *) bodyPart;
			// strip off the preamble, if present, which is: "Server was unable to process request. --->"
			NSRange ns = [sf.faultstring rangeOfString:@"-->"];
			if (ns.location != NSNotFound)
				self.errorString = [sf.faultstring substringFromIndex:(ns.location+ ns.length)];
			else
				self.errorString = sf.faultstring;
			retVal = NO;
		}
		else 
            [self.delegate BodyReturned:bodyPart];
		
	}
    
    return retVal;
}

- (BOOL) makeCallAsync:(void (^)(MFBWebServiceSoapBinding * b, MFBSoapCall * sc)) callToMake asSecure:(BOOL) fSecure
{
    BOOL retVal = YES;
    
	MFBWebServiceSoapBinding * binding = [self setUpBinding:fSecure];
    if (binding != nil)
    {
         // need to make sure that we're still around to be the delegate when the call completes
        [MFBSoapCall hackARCRetain:self];
        
        // We do this on a background thread because even though the call is async, it can hit a semaphore.
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            callToMake(binding, self);
        });
    }
    else
        retVal = NO;
    
	return retVal;
}

- (BOOL) makeCallAsync:(void (^)(MFBWebServiceSoapBinding * b, MFBSoapCall * sc)) callToMake
{
    return [self makeCallAsync:callToMake asSecure:NO];
}

- (BOOL) makeCallAsyncSecure:(void (^)(MFBWebServiceSoapBinding * b, MFBSoapCall * sc)) callToMake
{
    return [self makeCallAsync:callToMake asSecure:YES];
}

// TODO: We should never be calling this any more.  Call only on background threads. 
- (BOOL) makeCallSynchronous:(MFBWebServiceSoapBindingResponse * (^)(MFBWebServiceSoapBinding * b)) callToMake asSecure:(BOOL) fSecure
{
    BOOL retVal = YES;
    
    NSAssert(!NSThread.isMainThread, @"NEVER call makeCallSynchronous on the main thread!");
    
    MFBWebServiceSoapBinding * binding = [self setUpBinding:fSecure];
    if (binding != nil)
    {
        MFBWebServiceSoapBindingResponse *response = callToMake(binding);
        retVal = [self parseResponse:response];
    }
    else
        retVal = NO;
    
    return retVal;
}


- (void) operation:(MFBWebServiceSoapBindingOperation *)operation completedWithResponse:(MFBWebServiceSoapBindingResponse *)response;
{
    // always call this on the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self parseResponse:response];
        if ([((NSObject *) self.delegate) respondsToSelector:@selector(ResultCompleted:)])
            [self.delegate ResultCompleted:self];
        // since we retained ourselves above.
        [MFBSoapCall hackARCRelease:self];
    });
}

// Inside a soap call, dates get converted to XML using their UTC equivalent.
// If we're dealing with a date in local form, we want to preserve that without regard
// to time zone.  E.g., if it is 10pm on March 3 in Seattle, that's 5am March 4 UTC, but
// we will want the date to pass as March 3.  So we must provide a UTC version of the date that will survive
// this process with the correct day/month/year.
// Due to daylight savings time issues, we do this by decomposing the local date into its constituent
// month/day/year.  THEN set the timezone to create a new UTC date that looks like that date/time
// we can then restore the timezone and return that date.  Note that we will do one timezone switch for each
// date that is reconfigured, and will 
+ (NSDate *) UTCDateFromLocalDate:(NSDate *) dt
{
	NSCalendar * cal = [NSCalendar currentCalendar];
	NSDateComponents * comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dt];
	// get the day/month/year.
	NSInteger year = comps.year;
	NSInteger month = comps.month;
	NSInteger day = comps.day;
	[comps setDay:day];
	[comps setMonth:month];
	[comps setYear:year];
	[comps setHour:12];  // same date everywhere in the world - just be safe!
	[comps setMinute:0];
	[comps setSecond:0];

	NSTimeZone * tzDefault = cal.timeZone;
	cal.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSDate * dtReturn = [cal dateFromComponents:comps];
	cal.timeZone = tzDefault;
	
	return dtReturn;
}

// Reverse of UTCDateFromLocalDate.
// Given a UTC date, produces a local date that looks the same.  E.g., if it is
// 8/25/2012 02:00 UTC, that is 8/24/2012 19:00 PDT.  We want this date to look
// like 8/25, though.
+ (NSDate *) LocalDateFromUTCDate:(NSDate *) dt
{
	NSCalendar * cal = [NSCalendar currentCalendar];
	NSTimeZone * tzDefault = cal.timeZone;
	cal.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	NSDateComponents * comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dt];
	// get the day/month/year.
	NSInteger year = comps.year;
	NSInteger month = comps.month;
	NSInteger day = comps.day;
	cal.timeZone = tzDefault;
	[comps setDay:day];
	[comps setMonth:month];
	[comps setYear:year];
	[comps setHour:12];  // same date everywhere in the world - just be safe!
	[comps setMinute:0];
	[comps setSecond:0];
    
	NSDate * dtReturn = [cal dateFromComponents:comps];
	
	return dtReturn;
}

@end
