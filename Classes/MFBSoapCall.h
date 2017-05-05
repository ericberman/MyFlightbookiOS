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
//  MFBSoapCall.h
//  MFBSample
//
//  Created by Eric Berman on 12/20/09.
//  Copyright 2009-2017 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"

@class MFBSoapCall;

@protocol MFBSoapCallDelegate

- (void) BodyReturned:(id) body;
@optional
- (void) HeaderReturned:(id) header;
- (void) ResultCompleted:(MFBSoapCall *) sc;
@end


@interface MFBSoapCall : NSObject <MFBWebServiceSoapBindingResponseDelegate> {
	id<MFBSoapCallDelegate> delegate;
	BOOL logCallData;
	NSString * errorString;
	NSTimeInterval timeOut;
}

@property (readwrite, strong) id<MFBSoapCallDelegate> delegate;
@property (readwrite, nonatomic) BOOL logCallData;
@property (readwrite, strong) NSString * errorString;
@property (readwrite) NSTimeInterval timeOut;
@property (readwrite) NSInteger contextFlag;

- (BOOL) makeCallAsync:(void (^)(MFBWebServiceSoapBinding * b, MFBSoapCall * sc)) callToMake;
- (BOOL) makeCallAsyncSecure:(void (^)(MFBWebServiceSoapBinding * b, MFBSoapCall * sc)) callToMake;
- (BOOL) makeCallSynchronous:(MFBWebServiceSoapBindingResponse * (^)(MFBWebServiceSoapBinding * b)) callToMake asSecure:(BOOL) fSecure;

+ (NSDate *) UTCDateFromLocalDate:(NSDate *) dt;
+ (NSDate *) LocalDateFromUTCDate:(NSDate *) dt;

@end
