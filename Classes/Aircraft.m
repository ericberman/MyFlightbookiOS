/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2018 MyFlightbook, LLC
 
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
//  Copyright 2009-2017, MyFlightbook LLC. All rights reserved.
//

#import "Aircraft.h"
#import "MFBAppDelegate.h"
#import "WPSAlertController.h"
#import "Util.h"
#import "CountryCode.h"

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

@synthesize rgAircraftForUser, errorString, aircraftIDPreferred, rgAircraftInstanceTypes, rgMakeModels, dictHighWaterHobbs, dictHighWaterTach;

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

		self.rgAircraftInstanceTypes = @[NSLocalizedString(@"Real Aircraft", @"Indicates an actual aircraft"),
            NSLocalizedString(@"Sim: Uncertified", @"Indicates an uncertified sim such as Microsoft Flight Simulator"),
            NSLocalizedString(@"Sim: Log approaches", @"Indicates a training device where instrument approaches can count towards instrument currency"),
            NSLocalizedString(@"Sim: Log approaches, landings", @"Indicates a device where instrument approaches and landings count towards instrument currency and passenger carrying currency"),
            NSLocalizedString(@"Aviation Training Device (ATD)", @"Indiates an ATD (FAA training device type)")];
		
		self.rgMakeModels = nil;
	}
	return self;
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

+ (NSString *) PrefixAnonymous
{
    return @"#";
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
	[defs setObject:[NSKeyedArchiver archivedDataWithRootObject:rgAircraft] forKey:_szKeyCachedAircraft];
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
    if (rgArrayLastData != nil)
        return [NSKeyedUnarchiver unarchiveObjectWithData:rgArrayLastData];
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
        return cacheInvalid;
    
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
		timeSinceLastRefresh < CACHE_LIFETIME)
    {
        if (timeSinceLastRefresh < CACHE_REFRESH || ![[MFBAppDelegate threadSafeAppDelegate] isOnLine])
            return cacheValid;
        else
            return cacheValidButRefresh;
    }

    return cacheInvalid;
}

- (void) loadAircraftForUser:(BOOL) forceRefresh
{
	NSLog(@"loadAircraftForUser");
	self.errorString = @"";
    NSString * szAuthToken = mfbApp().userProfile.AuthToken;

    switch ([self cacheStatus:szAuthToken])
    {
        case cacheValid:
            NSLog(@"Cached aircraft are valid; using cached aircraft");
            if (!forceRefresh)
            {
                [self operationCompleted:nil];
                return;
            }
            break;
        case cacheValidButRefresh:
            NSLog(@"Cached aircraft list is valid, but a refresh attempt will be made.");
            break;
        default:
        case cacheInvalid:
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
	
	addAircraft.idInstanceType = ac.InstanceTypeID;
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
            if ([self cacheStatus:mfbApp().userProfile.AuthToken] != cacheInvalid && self.rgAircraftForUser != nil)
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
    return rg;
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

#pragma mark Extensions for SimpleMakeModel
// These are kind of a hack on the syntax of the simple make/model Description, which is "Manufacturer (model and other info)"
@implementation MFBWebServiceSvc_SimpleMakeModel (MFBExtensions)
- (NSString *) subDesc
{
    NSInteger iFirstParen = [self.Description rangeOfString:@"("].location;
    NSInteger iLastParen = [self.Description rangeOfString:@")" options:NSBackwardsSearch].location;
    NSInteger iLastHyphen = [self.Description rangeOfString:@"- " options:NSBackwardsSearch].location + 1;
    
    if (iFirstParen > 0 && iLastParen > iFirstParen && iLastHyphen > iLastParen)
        return [self.Description substringFromIndex:iFirstParen];
    else
        return self.Description;
}

- (NSString *) manufacturerName
{
    NSInteger iFirstParen = [self.Description rangeOfString:@"("].location;
    NSInteger iLastParen = [self.Description rangeOfString:@")" options:NSBackwardsSearch].location;
    NSInteger iLastHyphen = [self.Description rangeOfString:@"- " options:NSBackwardsSearch].location + 1;
    
    if (iFirstParen > 0 && iLastParen > iFirstParen && iLastHyphen > iLastParen)
        return [self.Description substringToIndex:iFirstParen];
    else
        return self.Description;
}
@end

#pragma mark NSCodingSupport for underlying SOAP object
@implementation MFBWebServiceSvc_Aircraft (NSCodingSupport)
- (void)encodeWithCoderMFB:(NSCoder *)encoder
{
	[encoder encodeObject:self.AircraftID forKey:@"AircraftID"];
	[encoder encodeObject:self.InstanceTypeID forKey:@"InstanceTypeID"];
	[encoder encodeObject:self.Last100 forKey:@"Last100"];
	[encoder encodeObject:self.LastAltimeter forKey:@"LastAltimeter"];
	[encoder encodeObject:self.LastAnnual forKey:@"LastAnnual"];
	[encoder encodeObject:self.LastELT forKey:@"LastELT"];
	[encoder encodeObject:self.LastNewEngine forKey:@"LastNewEngine"];
	[encoder encodeObject:self.LastOilChange forKey:@"LastOilChange"];
	[encoder encodeObject:self.LastStatic forKey:@"LastStatic"];
	[encoder encodeObject:self.LastTransponder forKey:@"LastTransponder"];
	[encoder encodeObject:self.LastVOR forKey:@"LastVOR"];
    [encoder encodeObject:self.RegistrationDue forKey:@"RegistrationDue"];
	[encoder encodeObject:self.ModelCommonName forKey:@"ModelCommonName"];
	[encoder encodeObject:self.ModelDescription forKey:@"ModelDescription"];
	[encoder encodeObject:self.ModelID forKey:@"ModelID"];
	[encoder encodeObject:self.TailNumber forKey:@"TailNumber"];
	[encoder encodeObject:self.AircraftImages forKey:@"AircraftImages"];
    [encoder encodeBool:self.HideFromSelection.boolValue forKey:@"HideFromSelectionBOOL"];
    [encoder encodeInt:(int) self.RoleForPilot forKey:@"RoleForPilot"];
    [encoder encodeObject:self.DefaultImage forKey:@"DefaultImage"];
}
	 
- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	
	self.AircraftID = [decoder decodeObjectForKey:@"AircraftID"];
	self.InstanceTypeID = [decoder decodeObjectForKey:@"InstanceTypeID"];
	self.Last100 = [decoder decodeObjectForKey:@"Last100"];
	self.LastAltimeter = [decoder decodeObjectForKey:@"LastAltimeter"];
	self.LastAnnual = [decoder decodeObjectForKey:@"LastAnnual"];
	self.LastELT = [decoder decodeObjectForKey:@"LastELT"];
	self.LastNewEngine = [decoder decodeObjectForKey:@"LastNewEngine"];
	self.LastOilChange = [decoder decodeObjectForKey:@"LastOilChange"];
	self.LastStatic = [decoder decodeObjectForKey:@"LastStatic"];
	self.LastTransponder = [decoder decodeObjectForKey:@"LastTransponder"];
	self.LastVOR = [decoder decodeObjectForKey:@"LastVOR"];
    self.RegistrationDue = [decoder decodeObjectForKey:@"RegistrationDue"];
	self.ModelCommonName = [decoder decodeObjectForKey:@"ModelCommonName"];
	self.ModelDescription = [decoder decodeObjectForKey:@"ModelDescription"];
	self.ModelID = [decoder decodeObjectForKey:@"ModelID"];
	self.TailNumber = [decoder decodeObjectForKey:@"TailNumber"];
	self.AircraftImages = [decoder decodeObjectForKey:@"AircraftImages"];
    self.HideFromSelection = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:@"HideFromSelectionBOOL"]];
    self.RoleForPilot = [decoder decodeIntForKey:@"RoleForPilot"];
    if (self.RoleForPilot == MFBWebServiceSvc_PilotRole_none)
        self.RoleForPilot = MFBWebServiceSvc_PilotRole_None;
    self.DefaultImage = [decoder decodeObjectForKey:@"DefaultImage"];
	
	return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ - %@, ID=%d", self.TailNumber, self.ModelCommonName, self.AircraftID.intValue];
}

- (BOOL) isNew
{
    return self.AircraftID == nil || [self.AircraftID intValue] < 0;
}

- (BOOL) isSim
{
    return [self.InstanceTypeID intValue] != MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft;
}

- (BOOL) isAnonymous
{
    return [self.TailNumber hasPrefix:[Aircraft PrefixAnonymous]];
}

- (NSString *) displayTailNumber
{
    if (self.isAnonymous)
    {
        if (self.ModelCommonName.length > 0)
            return [NSString stringWithFormat:@"(%@)", self.ModelDescription];
    }
    return self.TailNumber;
}

- (BOOL) hasMaintenance
{
    return (self.Last100.intValue > 0 || self.LastOilChange.intValue > 0 || self.LastNewEngine.intValue > 0 ||
            ![NSDate isUnknownDate:self.LastVOR] ||
            ![NSDate isUnknownDate:self.LastAltimeter] ||
            ![NSDate isUnknownDate:self.LastAnnual] ||
            ![NSDate isUnknownDate:self.LastELT] ||
            ![NSDate isUnknownDate:self.LastStatic] ||
            ![NSDate isUnknownDate:self.LastTransponder]);
}

- (NSDate *) nextVOR
{
    return [NSDate isUnknownDate:self.LastVOR] ? self.LastVOR : [self.LastVOR dateByAddingTimeInterval:24 * 3600 * 30];
}

- (NSDate *) nextAnnual
{
    return [NSDate isUnknownDate:self.LastAnnual] ? self.LastAnnual : [self.LastAnnual dateByAddingCalendarMonths:12];
}

- (NSDate *) nextELT
{
    return [NSDate isUnknownDate:self.LastELT] ? self.LastELT : [self.LastELT dateByAddingCalendarMonths:12];
}

- (NSDate *) nextAltimeter
{
    return [NSDate isUnknownDate:self.LastAltimeter] ? self.LastAltimeter : [self.LastAltimeter dateByAddingCalendarMonths:24];
}

- (NSDate *) nextPitotStatic
{
    return [NSDate isUnknownDate:self.LastStatic] ? self.LastStatic : [self.LastStatic dateByAddingCalendarMonths:24];
}

- (NSDate *) nextTransponder
{
    return [NSDate isUnknownDate:self.LastTransponder] ? self.LastTransponder : [self.LastTransponder dateByAddingCalendarMonths:24];
}

+ (MFBWebServiceSvc_Aircraft *) getNewAircraft
{
    MFBWebServiceSvc_Aircraft * ac = [[MFBWebServiceSvc_Aircraft alloc] init];
    ac.TailNumber = [CountryCode BestGuessForCurrentLocale].Prefix; // initialize with just "N" or whatever is appropriate for this locale.
	ac.AircraftID = @-1;
	ac.InstanceTypeID = @(MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft);
	ac.Last100 = @0;
	ac.LastAltimeter = [NSDate distantPast];
	ac.LastAnnual = [NSDate distantPast];
	ac.LastELT = [NSDate distantPast];
	ac.LastNewEngine = @0;
	ac.LastOilChange = @0;
	ac.LastStatic = [NSDate distantPast];
	ac.LastTransponder = [NSDate distantPast];
	ac.LastVOR = [NSDate distantPast];
	ac.ModelCommonName = @"";
	ac.ModelDescription = @"";
	ac.ModelID = @-1;
    ac.HideFromSelection = [[USBoolean alloc] initWithBool:NO];
    ac.RoleForPilot = MFBWebServiceSvc_PilotRole_None;
    ac.DefaultImage = @"";
    return ac;
}
@end
