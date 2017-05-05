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
//  Profile.h
//  MFBSample
//
//  Created by Eric Berman on 12/7/09.
//  Copyright 2009-2017 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBSoapCall.h"
#import "MFBAppDelegate.h"

@interface MFBProfile : NSObject <MFBSoapCallDelegate> {
@private
	NSString * _szUser;
	NSString * _szPass;
	NSString * _szAuthToken;
	NSString * _szError;	
}

- (BOOL) LoadPrefs;
- (BOOL) SavePrefs;
- (BOOL) GetAuthToken;
- (BOOL) isValid;
- (void) clearCache;
- (void) clearOldUserContent;
- (int) cacheStatus:(NSString *) szUser;
- (BOOL) createUser:(MFBWebServiceSvc_CreateUser *) cu;

@property (readwrite, strong) NSString * UserName;
@property (readwrite, strong) NSString * Password;
@property (readwrite, strong) NSString * AuthToken;
@property (readwrite, strong) NSString * ErrorString;

@end

@interface NewUserObject : MFBWebServiceSvc_CreateUser

@property (readwrite, strong) NSString * szEmail2;
@property (readwrite, strong) NSString * szPass2;
@property (readwrite, strong) NSString * szLastError;
@property (readwrite) BOOL IsOver14;

- (BOOL) isValid;
@end
