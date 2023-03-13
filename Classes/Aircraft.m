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
//  Aircraft.m
//  MFBSample
//
//  Created by Eric Berman on 12/20/09.
//

#import "Aircraft.h"
#import "MFBAppDelegate.h"

@interface Aircraft ()
@property (assign) int aircraftIDPreferred;
@property (nonatomic, readwrite) NSMutableDictionary<NSNumber *, NSNumber *> * dictHighWaterHobbs;
@property (nonatomic, readwrite) NSMutableDictionary<NSNumber *, NSNumber *> * dictHighWaterTach;
@end

@implementation Aircraft

NSString * const _szKeyPreferredAircraftId = @"PreferredAircraftID";
NSString * const _szKeyCachedAircraft = @"keyCacheAircraft";
NSString * const _szKeyCachedAircraftRetrievalDate = @"keyCacheAircraftDate";
NSString * const _szKeyCachedAircraftAuthToken = @"keyCacheAircraftAuthToken";

@synthesize rgAircraftForUser, errorString, aircraftIDPreferred, rgMakeModels, dictHighWaterHobbs, dictHighWaterTach;

#define CONTEXT_DELETE_AIRCRAFT 1085683
#define CONTEXT_AIRCRAFTFORUSER 8503832

#pragma mark Object Lifecycle
- (instancetype)init
{
    self = [super init];
	if (self != nil)
	{
		self.rgAircraftForUser = [self cachedAircraft];
        self.aircraftIDPreferred = self.DefaultAircraftID;
		self.errorString = @"";
        self.dictHighWaterHobbs = [NSMutableDictionary new];
        self.dictHighWaterTach = [NSMutableDictionary new];

		self.rgMakeModels = nil;
	}
	return self;
}

+ (NSString *) aircraftInstanceTypeDisplay:(MFBWebServiceSvc_AircraftInstanceTypes) instanceType {
    switch (instanceType) {
        default:
            return @"";
        case MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft:
            return NSLocalizedString(@"Real Aircraft", @"Indicates an actual aircraft");
        case MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator:
            return NSLocalizedString(@"Sim: Uncertified", @"Indicates an uncertified sim such as Microsoft Flight Simulator");
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD:
            return NSLocalizedString(@"Aviation Training Device (ATD)", @"Indiates an ATD (FAA training device type)");
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator:
            return NSLocalizedString(@"Sim: Log approaches", @"Indicates a training device where instrument approaches can count towards instrument currency");
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator:
            return NSLocalizedString(@"Sim: Log approaches, landings", @"Indicates a device where instrument approaches and landings count towards instrument currency and passenger carrying currency");
    }
}

+ (Aircraft *) sharedAircraft
{
    static dispatch_once_t pred;
    static Aircraft * shared = nil;
    dispatch_once(&pred, ^{
        shared = [[Aircraft alloc] init];
    });
    return shared;
}

- (void) clearAircraft
{
    self.rgAircraftForUser = [[NSMutableArray alloc] init];
}

#pragma mark Prefixes
+ (NSString *) PrefixSIM;
{
    return @"SIM";
}

#pragma mark State Management
-(void) setDefaultAircraftID:(int) idAircraft
{
    self.aircraftIDPreferred = idAircraft;
	[[NSUserDefaults standardUserDefaults] setInteger:idAircraft forKey:_szKeyPreferredAircraftId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(int) DefaultAircraftID
{
	self.aircraftIDPreferred = (int) [[NSUserDefaults standardUserDefaults] integerForKey:_szKeyPreferredAircraftId];
    [self checkAircraftID];
    return self.aircraftIDPreferred;
}

- (void) checkAircraftID
{
    MFBWebServiceSvc_Aircraft * ac = [self AircraftByID:self.aircraftIDPreferred];
    if (ac == nil)
    {
        if (self.rgAircraftForUser == nil || self.rgAircraftForUser.count == 0)
            self.DefaultAircraftID = -1;
        else
        {
            NSArray * rgAvailable = [self.rgAircraftForUser filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL(MFBWebServiceSvc_Aircraft * evaluatedObject, NSDictionary *bindings)
                  { return !evaluatedObject.HideFromSelection.boolValue; }]];
            self.DefaultAircraftID = (rgAvailable == nil || rgAvailable.count == 0) ?
                ((MFBWebServiceSvc_Aircraft *) self.rgAircraftForUser[0]).AircraftID.intValue :
                ((MFBWebServiceSvc_Aircraft *) rgAvailable[0]).AircraftID.intValue;
        }
    }
}

- (void) cacheAircraft:(NSArray *) rgAircraft forUser:(NSString *) szAuthToken
{
    NSLog(@"Caching %d aircraft", (int) [rgAircraft count]);
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	[defs setObject:[NSKeyedArchiver archivedDataWithRootObject:rgAircraft requiringSecureCoding:YES error:nil] forKey:_szKeyCachedAircraft];
	[defs setValue:szAuthToken forKey:_szKeyCachedAircraftAuthToken];
	[defs setDouble:[[NSDate date] timeIntervalSince1970] forKey:_szKeyCachedAircraftRetrievalDate];
	[defs synchronize];
}

- (void) invalidateCachedAircraft
{
	NSLog(@"invalidateCachedAircraft");
	[[NSUserDefaults standardUserDefaults] setValue:0 forKey:_szKeyCachedAircraftRetrievalDate];
}

- (NSArray *) cachedAircraft
{
	NSData * rgArrayLastData = [[NSUserDefaults standardUserDefaults] objectForKey:_szKeyCachedAircraft];
    NSError * err = nil;
    if (rgArrayLastData != nil)
        return [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[NSArray.class, MFBWebServiceSvc_Aircraft.class, NSNumber.class, NSMutableArray.class, MFBWebServiceSvc_ArrayOfInt.class]] fromData:rgArrayLastData error:&err];
    return nil;
}

- (void) refreshIfNeeded
{
    [self setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        if ([sc.errorString length] == 0)
            [[Aircraft sharedAircraft] checkAircraftID];    // refresh the default aircraftID
        else
            [WPSAlertController presentAlertWithErrorMessage:sc.errorString];
    }];
    [self loadAircraftForUser:NO];
}

#pragma mark Soap Calls
- (int) cacheStatus:(NSString *) szAuthToken
{
	// see whether we have valid cached aircraft
    NSArray * rgAircraftCached = [self cachedAircraft];
    
    if (rgAircraftCached == nil)
        return CacheStatusInvalid;
    
    // ensure that the aircraft array is at least initialized
    if (self.rgAircraftForUser == nil)
        self.rgAircraftForUser = rgAircraftCached;
    
	NSTimeInterval timestampAircraftCache = [[NSUserDefaults standardUserDefaults] doubleForKey:_szKeyCachedAircraftRetrievalDate];
	NSString * szCachedToken = [[NSUserDefaults standardUserDefaults] stringForKey:_szKeyCachedAircraftAuthToken];
	
	NSTimeInterval timeSinceLastRefresh = [[NSDate date] timeIntervalSince1970] - timestampAircraftCache;
    
    // (a) we have a cached aircraft list,
	// (b) it was retrieved for this token, and
	// (c) less than the cache lifetime has passed.
	if (rgAircraftCached != nil && self.rgAircraftForUser != nil &&
		szCachedToken != nil && [szCachedToken compare:szAuthToken] == NSOrderedSame &&
		timeSinceLastRefresh < MFBConstants.CACHE_LIFETIME)
    {
        if (timeSinceLastRefresh < MFBConstants.CACHE_REFRESH || ![[MFBAppDelegate threadSafeAppDelegate] isOnLine])
            return CacheStatusValid;
        else
            return CacheStatusValidButRefresh;
    }

    return CacheStatusInvalid;
}

- (void) loadAircraftForUser:(BOOL) forceRefresh
{
	NSLog(@"loadAircraftForUser");
	self.errorString = @"";
    NSString * szAuthToken = MFBAppDelegate.threadSafeAppDelegate.userProfile.AuthToken;

    switch ([self cacheStatus:szAuthToken])
    {
        case CacheStatusValid:
            NSLog(@"Cached aircraft are valid; using cached aircraft");
            if (!forceRefresh)
            {
                [self operationCompleted:nil];
                return;
            }
            break;
        case CacheStatusValidButRefresh:
            NSLog(@"Cached aircraft list is valid, but a refresh attempt will be made.");
            break;
        default:
        case CacheStatusInvalid:
            NSLog(@"loadAircraftForUser - cache not valid");
            break;
    }
    
	MFBWebServiceSvc_AircraftForUser * aircraftForUserSvc = [MFBWebServiceSvc_AircraftForUser new];
	aircraftForUserSvc.szAuthUserToken = szAuthToken;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.logCallData = NO;
	sc.timeOut = 10;
	sc.delegate = self;
    sc.contextFlag = CONTEXT_AIRCRAFTFORUSER;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b AircraftForUserAsyncUsingParameters:aircraftForUserSvc delegate:sc];
    }];
}

- (void) deleteAircraft:(NSNumber *) idAircraft forUser:(NSString *) szAuthToken
{
	NSLog(@"deleteAircraft");
	self.errorString = @"";
	
    MFBWebServiceSvc_DeleteAircraftForUser * deleteAircraft = [MFBWebServiceSvc_DeleteAircraftForUser new];
    deleteAircraft.szAuthUserToken = szAuthToken;
    deleteAircraft.idAircraft = idAircraft;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.logCallData = NO;
	sc.delegate = self;
    sc.contextFlag = CONTEXT_DELETE_AIRCRAFT;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b DeleteAircraftForUserAsyncUsingParameters:deleteAircraft delegate:sc];
    }];
}

- (void) addAircraft:(MFBWebServiceSvc_Aircraft *) ac ForUser:(NSString *) szAuthToken
{
	NSLog(@"addAircraft");
	self.errorString = @"";
	
	MFBWebServiceSvc_AddAircraftForUser * addAircraft = [MFBWebServiceSvc_AddAircraftForUser new];
	
    addAircraft.idInstanceType = [ac instanceTypeIDFromInstanceType:ac.InstanceType];
	addAircraft.idModel = ac.ModelID;
	addAircraft.szTail = ac.TailNumber;
	addAircraft.szAuthUserToken = szAuthToken;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.logCallData = NO;
	sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b AddAircraftForUserAsyncUsingParameters:addAircraft delegate:sc];
    }];
}

- (void) updateAircraft:(MFBWebServiceSvc_Aircraft *) ac ForUser:(NSString *) szAuthToken
{
	NSLog(@"updateAircraft");
	self.errorString = @"";

    MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * updAircraft = [MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes new];
	updAircraft.ac = ac;
	updAircraft.szAuthUserToken = szAuthToken;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.logCallData = NO;
	sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b UpdateMaintenanceForAircraftWithFlagsAndNotesAsyncUsingParameters:updAircraft delegate:sc];
    }];
}

- (void) loadMakeModels
{
	NSLog(@"loadMakeModels");
	self.errorString = @"";
		
	MFBWebServiceSvc_MakesAndModels * makesAndModels = [MFBWebServiceSvc_MakesAndModels new];

	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.logCallData = NO;
	sc.delegate = self;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b MakesAndModelsAsyncUsingParameters:makesAndModels delegate:sc];
    }];
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;
    
    if (sc.contextFlag == CONTEXT_AIRCRAFTFORUSER)
    {
        if ([self.errorString length] == 0) // success!
            [self cacheAircraft:self.rgAircraftForUser forUser:mfbApp().userProfile.AuthToken];
        else
        {
            // see if this was a refresh attempt.  If so, and if we have a set of aircraft to fall back upon, then we can fall
            // back on the cache and treat it as a non-error
            if ([self cacheStatus:MFBAppDelegate.threadSafeAppDelegate.userProfile.AuthToken] != CacheStatusInvalid && self.rgAircraftForUser != nil)
                self.errorString = @"";
        }
    }
    else if (sc.contextFlag == CONTEXT_DELETE_AIRCRAFT)
    {
        if ([self.errorString length] == 0)
            [self cacheAircraft:self.rgAircraftForUser forUser:mfbApp().userProfile.AuthToken];
    }
    
    [self operationCompleted:sc];
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_AircraftForUserResponse class]])
	{
		MFBWebServiceSvc_AircraftForUserResponse * resp = (MFBWebServiceSvc_AircraftForUserResponse *) body;
		MFBWebServiceSvc_ArrayOfAircraft * rgAc = resp.AircraftForUserResult;
        self.rgAircraftForUser = rgAc.Aircraft;
        [self checkAircraftID];
	}
	else if ([body isKindOfClass:[MFBWebServiceSvc_MakesAndModelsResponse class]])
	{
		MFBWebServiceSvc_MakesAndModelsResponse * resp = (MFBWebServiceSvc_MakesAndModelsResponse *) body;
		
		self.rgMakeModels = resp.MakesAndModelsResult.SimpleMakeModel;
        [NSNotificationCenter.defaultCenter postNotificationName:@"makesLoaded" object:self];
	} 
	else if ([body isKindOfClass:[MFBWebServiceSvc_AddAircraftForUserResponse class]])
	{
		MFBWebServiceSvc_AddAircraftForUserResponse * resp = (MFBWebServiceSvc_AddAircraftForUserResponse *) body;
		
		if (resp.AddAircraftForUserResult != nil && 
			resp.AddAircraftForUserResult.Aircraft != nil &&
			[resp.AddAircraftForUserResult.Aircraft count] > 0)
			self.rgAircraftForUser = resp.AddAircraftForUserResult.Aircraft;
        [self checkAircraftID];
	}
    else if ([body isKindOfClass:[MFBWebServiceSvc_DeleteAircraftForUserResponse class]])
    {
        MFBWebServiceSvc_DeleteAircraftForUserResponse * resp = (MFBWebServiceSvc_DeleteAircraftForUserResponse *) body;
        if (resp.DeleteAircraftForUserResult != nil &&
            resp.DeleteAircraftForUserResult.Aircraft != nil &&
            [resp.DeleteAircraftForUserResult.Aircraft count] > 0)
            self.rgAircraftForUser = resp.DeleteAircraftForUserResult.Aircraft;
        [self checkAircraftID];
    }
}

#pragma mark Misc. Utility
- (MFBWebServiceSvc_Aircraft *) preferredAircraft
{
    if (self.rgAircraftForUser == nil || self.rgAircraftForUser.count == 0)
        return nil;
    
    MFBWebServiceSvc_Aircraft * ac = nil;
    
	if (self.aircraftIDPreferred <= 0 || (ac = [self AircraftByID:self.aircraftIDPreferred]) == nil)
        [self checkAircraftID];
    
    return (ac == nil) ? [self AircraftByID:self.aircraftIDPreferred] : ac;
}

- (NSInteger) indexOfAircraftID:(int) idAircraft
{
	NSInteger result = (NSInteger) -1;
	
	if (idAircraft > 0)
	{
		for (NSInteger i = [self.rgAircraftForUser count] - 1; i >= 0; i--)
		{
			MFBWebServiceSvc_Aircraft * ac = (self.rgAircraftForUser)[i];
			if ([ac.AircraftID intValue] == idAircraft) {
				result = i;
				break;
			}
		}
	}
	
	return result;
}

- (MFBWebServiceSvc_Aircraft *) AircraftByID:(int) idAircraft
{
    for (MFBWebServiceSvc_Aircraft * ac in self.rgAircraftForUser)
    {
        if ([ac.AircraftID intValue] == idAircraft)
            return ac;
    }
    return nil;
}

- (MFBWebServiceSvc_Aircraft *) AircraftByTail:(NSString *) szTail
{
    for (MFBWebServiceSvc_Aircraft * ac in self.rgAircraftForUser)
    {
        if ([ac.TailNumber caseInsensitiveCompare:szTail] == NSOrderedSame)
            return ac;
    }
    return nil;
}

- (NSInteger) indexOfModelID:(NSInteger) idModel
{
	
	NSInteger result = -1;
	
	for (NSInteger i = [self.rgMakeModels count] - 1; i >= 0; i--)
	{
		MFBWebServiceSvc_SimpleMakeModel * smm = (self.rgMakeModels)[i];
		if ([smm.ModelID intValue] == idModel) {
			result = i;
			break;
		}
	}
	
	return result;
}

- (NSString *) descriptionOfModelId:(NSInteger) idModel
{
	for (MFBWebServiceSvc_SimpleMakeModel * smm in self.rgMakeModels) {
		if ([smm.ModelID intValue] == idModel)
			return smm.Description;
	}
	return @"";
}

- (BOOL) validateAircraftForUser:(MFBWebServiceSvc_Aircraft *) ac
{
    int idAircraft = [ac.AircraftID intValue];
    for (MFBWebServiceSvc_Aircraft * acUser in self.rgAircraftForUser)
        if (idAircraft == [acUser.AircraftID intValue])
            return YES;
    return NO;
}

// Return all of the user aircraft that are not hidden from selection
// BUT ensure that acToInclude is included
- (NSArray *) AircraftForSelection:(NSNumber *) acIDToInclude
{
    NSMutableArray * rg = [[NSMutableArray alloc] init];
    for (MFBWebServiceSvc_Aircraft * ac in self.rgAircraftForUser)
    {
        if (!ac.HideFromSelection.boolValue || (acIDToInclude != nil && (ac.AircraftID.intValue == acIDToInclude.intValue)))
            [rg addObject:ac];
    }
    return rg.count == 0 ? self.rgAircraftForUser : rg; // if it yielded no aircraft, then show them all.
}

- (NSArray *) modelsInUse
{
    NSMutableDictionary * dictMM = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * dictMakesUsed = [[NSMutableDictionary alloc] init];

    // build a dictionary of all makes/models, keyed by id
    for (MFBWebServiceSvc_SimpleMakeModel * smm in self.rgMakeModels)
        dictMM[smm.ModelID] = smm;
    
    // now build a dictionary of all makes/models, keyed by id, from the aircraft in the user's list
    for (MFBWebServiceSvc_Aircraft * acUser in self.rgAircraftForUser)
    {
        id obj = dictMM[acUser.ModelID];
        if (obj != nil)         // test for nil in case there is an aircraft in the list that has a model that is not in the list of models.
            dictMakesUsed[acUser.ModelID] = obj;
    }
    
    // now return an array from that
    return [[dictMakesUsed allValues] sortedArrayUsingComparator:^NSComparisonResult(MFBWebServiceSvc_SimpleMakeModel * obj1, MFBWebServiceSvc_SimpleMakeModel * obj2) {
        return [obj1.Description compare:obj2.Description];
    }];
}

#pragma mark - tach/hobbs high-water
- (void) setHighWaterTach:(NSNumber *) tach forAircraft:(NSNumber *) aircraftID {
    if (tach == nil || tach.doubleValue == 0)
        return;
    
    if ([self getHighWaterTachForAircraft:aircraftID].doubleValue < tach.doubleValue)
        self.dictHighWaterTach[aircraftID] = tach;
}

- (NSNumber *) getHighWaterTachForAircraft:(NSNumber *) aircraftID {
    return self.dictHighWaterTach[aircraftID];
}

- (void) setHighWaterHobbs:(NSNumber *) hobbs forAircraft:(NSNumber *) aircraftID {
    if (hobbs == nil || hobbs.doubleValue == 0)
        return;
    
    if ([self getHighWaterHobbsForAircraft:aircraftID].doubleValue < hobbs.doubleValue)
        self.dictHighWaterHobbs[aircraftID] = hobbs;
}

- (NSNumber *) getHighWaterHobbsForAircraft:(NSNumber *) aircraftID {
    return self.dictHighWaterHobbs[aircraftID];
}

@end
