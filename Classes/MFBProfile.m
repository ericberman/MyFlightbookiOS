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
//  Profile.m
//  MFBSample
//
//  Created by Eric Berman on 12/7/09.
//  Copyright 2009-2019 MyFlightbook LLC. All rights reserved.
//

#import "MFBProfile.h"
#import "MFBWebServiceSvc.h"
#import "MFBAppDelegate.h"
#import "ApiKeys.h"

@interface MFBProfile ()
@property (readwrite) MFBWebServiceSvc_AuthStatus authStatus;
@end

@implementation MFBProfile

@synthesize UserName=_szUser;
@synthesize Password=_szPass;
@synthesize AuthToken=_szAuthToken;
@synthesize ErrorString = _szError;
@synthesize authStatus;

NSString * const _szPrefsPath = @"MyFlightbookDataPrefs";
NSString * const _szKeyUser = @"UserKey";
NSString * const _szKeyPass = @"PassKey";
NSString * const _szKeyAuth = @"AuthKey";
NSString * const _szKeyPrefEmail = @"keyEmail";
NSString * const _szKeyPrefPass = @"keyPass";

NSString * const _szKeyCachedToken = @"keyCacheAuthToken";
NSString * const _szKeyCachedUser = @"keyCacheAuthUser";
NSString * const _szKeyCachedTokenRetrievalDate = @"keyCacheTokenDate";

- (instancetype)init
{
    self=[super init];
    if (self != nil) {
		self.ErrorString = @"";
        
        // set up initial values
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        self.UserName = [defs stringForKey:_szKeyPrefEmail];
        self.Password = [defs stringForKey:_szKeyPrefPass];
        self.AuthToken = [defs stringForKey:_szKeyCachedToken];
    }

	return self;
}

-(BOOL) SavePrefs
{
	[[NSUserDefaults standardUserDefaults] setValue:self.UserName forKey:_szKeyPrefEmail];
	[[NSUserDefaults standardUserDefaults] setValue:self.Password forKey:_szKeyPrefPass];
	return YES;
}

- (void) cacheAuthCreds
{
	// cache the results
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	[defs setValue:self.AuthToken forKey:_szKeyCachedToken];
	[defs setValue:self.UserName forKey:_szKeyCachedUser];
	[defs setDouble:[[NSDate date] timeIntervalSince1970] forKey:_szKeyCachedTokenRetrievalDate];
	
	// And save the ultimately used creds
	[self SavePrefs];
	[defs synchronize];
    
    defs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.myflightbook.mfbapps"];
    [defs setValue:self.AuthToken forKey:_szKeyCachedToken];
}


- (void) clearCache
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	[defs setValue:nil forKey:_szKeyCachedUser];
	[defs setValue:nil forKey:_szKeyCachedToken];

    defs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.myflightbook.mfbapps"];
    [defs setValue:nil forKey:_szKeyCachedToken];

    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    [app invalidateCachedTotals];
}

- (void) clearOldUserContent
{
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    Aircraft * ac = [Aircraft sharedAircraft];
    [ac invalidateCachedAircraft];
    ac.DefaultAircraftID = -1;
    [app invalidateAll];
}

- (int) cacheStatus:(NSString *) szUser;
{
    // initialize from the cache, if necessary...
    if (self.AuthToken == nil)
        self.AuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:_szKeyCachedToken];

    // invalid cache if we have no username/password, no valid authtoken already, or this is for a different user
	NSString * szUserCached = [[NSUserDefaults standardUserDefaults] stringForKey:_szKeyCachedUser];
    if ([self.UserName length] == 0 ||
        [self.Password length] == 0 || 
        ![self isValid] ||
        [szUserCached compare:self.UserName] != NSOrderedSame)
        return cacheInvalid;

	NSTimeInterval timestampAuthCache = [[NSUserDefaults standardUserDefaults] doubleForKey:_szKeyCachedTokenRetrievalDate];
	NSTimeInterval timeSinceLastAuth = [[NSDate date] timeIntervalSince1970] - timestampAuthCache;
    
	// credentials are valid if
	// (a) we have a cached auth token,
	// (b) it is still valid.
	if (self.AuthToken != nil && [self.AuthToken length] > 0 && timeSinceLastAuth < CACHE_LIFETIME)
    {
        if (timeSinceLastAuth < CACHE_REFRESH || ![[MFBAppDelegate threadSafeAppDelegate] isOnLine])
            return cacheValid;
        else
            return cacheValidButRefresh;
    }
    
    return cacheInvalid;
}

- (BOOL) RefreshAuthToken {
    int cacheStat = [self cacheStatus:self.UserName];

    if (cacheStat == cacheValid)    // nothing to do
        return YES;

    // Cache is either invalid or valid but want to refresh.  Either way, we'll try a refresh, but only if we can do so
    if (self.UserName.length == 0 || self.Password.length == 0 || self.AuthToken.length == 0 || !MFBAppDelegate.threadSafeAppDelegate.isOnLine)
        return NO;
    
    NSLog(@"RefreshAuthToken - cache isn't valid but we have information required to refresh, so refreshing");
        
    MFBWebServiceSvc_RefreshAuthToken * refreshSvc = [MFBWebServiceSvc_RefreshAuthToken new];
    refreshSvc.szAppToken = _szKeyAppToken;
    refreshSvc.szUser = self.UserName;
    refreshSvc.szPass = self.Password;
    refreshSvc.szPreviousToken = self.AuthToken;
    
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.delegate = self;
    sc.timeOut = 10.0; // 10 second timeout
    
    // Make async call - result will be cached asynchronously, so we can simply return.
    [sc makeCallAsyncSecure:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b RefreshAuthTokenAsyncUsingParameters:refreshSvc delegate:sc];
    }];

    return YES;
}

- (MFBWebServiceSvc_AuthStatus) GetAuthToken:(NSString *) sz2FACode
{
	NSLog(@"GetAuthToken");
    self.ErrorString = @"";
    
    if (NSThread.isMainThread)
        NSLog(@"GetAuthToken called from main thread - naughty!  We will crash");
    
	if ([self.UserName length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide an email address.", @"Create Account validation - no email");
		return NO;
	}
	if ([self.Password length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide a password.", @"Validation - Missing Password");
		return NO;
	}
    
	NSString * szUserCached = [[NSUserDefaults standardUserDefaults] stringForKey:_szKeyCachedUser];
	
	// clear the cache if requesting for a different user
	if (szUserCached != nil && [szUserCached compare:self.UserName] != NSOrderedSame) {
		NSLog(@"Cached credentials being cleared because of new username");
		[self clearCache];
	}
	
	MFBWebServiceSvc_AuthTokenForUserNew * authTokSvc = [MFBWebServiceSvc_AuthTokenForUserNew new];
	authTokSvc.szAppToken = _szKeyAppToken;
	authTokSvc.szUser = self.UserName;
	authTokSvc.szPass = self.Password;
    authTokSvc.sz2FactorAuth = sz2FACode;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	sc.timeOut = 10.0; // 10 second timeout
	
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b AuthTokenForUserNewUsingParameters:authTokSvc];
    } asSecure:YES];
	self.ErrorString = sc.errorString;
    
    if ([self.ErrorString length] == 0 && [self.AuthToken length] > 0 && self.authStatus == MFBWebServiceSvc_AuthStatus_Success) {
		NSLog(@"Authtoken successfully retrieved - updating cache");
		[self cacheAuthCreds];
        if (szUserCached == nil || [szUserCached compare:self.UserName] != NSOrderedSame) // signed in as someone new
            [self performSelectorOnMainThread:@selector(clearOldUserContent) withObject:nil waitUntilDone:YES];
        return self.authStatus;
	} else if ([self.AuthToken length] == 0 && self.ErrorString.length == 0)  // if we didn't get any actual error, but didn't get an auth string, that's also an error
		self.ErrorString = NSLocalizedString(@"Unable to authenticate.  Please check your email address and password and ensure that you have Internet access", @"Error - authentication failure");
	
    return self.authStatus;
}

- (BOOL) createUser:(MFBWebServiceSvc_CreateUser *) cu
{
	NSLog(@"CreateUser");
	
	if ([cu.szEmail length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide an email address.", @"Create Account validation - no email");
		return NO;
	}
	if ([cu.szPass length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide a password.", @"Validation - Missing Password");
		return NO;
	}
	if ([cu.szPass length] < 6)
	{
		self.ErrorString = NSLocalizedString(@"Password must be at least 6 characters long.", @"Create Account validation - password too short");
		return NO;
	}
	if ([cu.szQuestion length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide a password question.", @"Create Account validation - no password question");
		return NO;
	}
	
	if ([cu.szAnswer length] == 0)
	{
		self.ErrorString = NSLocalizedString(@"Please provide an answer to the password question.", @"Create Account validation - no secret answer");
		return NO;
	}
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = self;
	sc.timeOut = 10.0; // 10 second timeout
	
	cu.szAppToken = _szKeyAppToken;
	
    [sc makeCallSynchronous:^MFBWebServiceSoapBindingResponse *(MFBWebServiceSoapBinding *b) {
        return [b CreateUserUsingParameters:cu];
    } asSecure:YES];
	self.ErrorString = sc.errorString;
	
	if ([self.ErrorString length] == 0 && [self.AuthToken length] > 0)
	{
		NSLog(@"Account successfully created");
		// Now, sign in.
		self.UserName = cu.szEmail;
		self.Password = cu.szPass;
		[self cacheAuthCreds];
        [self clearOldUserContent];
	}
		
	return [self.ErrorString length] == 0;
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_AuthTokenForUserNewResponse class]])
	{
		MFBWebServiceSvc_AuthTokenForUserNewResponse * resp = (MFBWebServiceSvc_AuthTokenForUserNewResponse *) body;
        self.authStatus = resp.AuthTokenForUserNewResult.Result;
        if (self.authStatus == MFBWebServiceSvc_AuthStatus_Success) {
            self.AuthToken = resp.AuthTokenForUserNewResult.AuthToken;
            if ([self.AuthToken length] > 0)
                self.ErrorString = @"";
        }
	}
	else if ([body isKindOfClass:[MFBWebServiceSvc_CreateUserResponse class]])
	{
		MFBWebServiceSvc_CreateUserResponse * resp = (MFBWebServiceSvc_CreateUserResponse *) body;
		self.AuthToken = resp.CreateUserResult.szAuthToken;
    } else if ([body isKindOfClass:MFBWebServiceSvc_RefreshAuthTokenResponse.class]) {
        MFBWebServiceSvc_RefreshAuthTokenResponse * resp = (MFBWebServiceSvc_RefreshAuthTokenResponse *) body;
        NSString * szAuth = resp.RefreshAuthTokenResult;
        if (szAuth.length > 0) {
            self.AuthToken = szAuth;
            [self cacheAuthCreds];
        }
    }
}


- (BOOL) isValid
{
	return ([self.AuthToken length] > 0);
}

- (NSString *) authRedirForUser:(NSString *) params {
    return [NSString stringWithFormat:@"https://%@/logbook/public/authredir.aspx?u=%@&p=%@&%@",
            MFBHOSTNAME, self.UserName.stringByURLEncodingString, self.Password.stringByURLEncodingString, params];
}
@end

@implementation NewUserObject
@synthesize szEmail2, szPass2, szLastError;


- (BOOL) isValid
{
    self.szLastError = @"";
    
	if ([self.szPass length] == 0 || [self.szPass compare:self.szPass2] != NSOrderedSame)
		self.szLastError = NSLocalizedString(@"Please enter your password twice.", @"Create Account validation - passwords don't match");
	if ([self.szEmail length] == 0 || [self.szEmail compare:self.szEmail2] != NSOrderedSame)
		self.szLastError = NSLocalizedString(@"Please enter your email address twice.", @"Create Account validation - emails don't match");

    return ([self.szLastError length] == 0);
}
@end
