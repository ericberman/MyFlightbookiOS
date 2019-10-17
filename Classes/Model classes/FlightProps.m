/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2019 MyFlightbook, LLC
 
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
//  CustomPropertyType.m
//  MFBSample
//
//  Created by Eric Berman on 7/7/10.
//  Copyright 2010-2019 MyFlightbook LLC. All rights reserved.
//

#import "FlightProps.h"
#import "MFBAppDelegate.h"
#import "Util.h"

@interface FlightProps()
@property (readwrite, strong) NSMutableDictionary * dictLockedTypes;
+ (NSMutableDictionary *) lockedTypesFromPrefs;
@end

@implementation FlightProps
@synthesize errorString, rgFlightProps, dictLockedTypes;

static BOOL hasLoadedThisSession = NO;

NSString * const _szKeyPropID = @"keycfpPropID";
NSString * const _szKeyFlightID = @"keycfpFlightID";
NSString * const _szKeyPropTypeID = @"keycfpPropTypeID";
NSString * const _szKeyIntVal = @"keycfpIntVal";
NSString * const _szKeyBoolVal = @"keycfpBoolVal";
NSString * const _szKeyDecVal = @"keycfpDecVal";
NSString * const _szKeyTextVal = @"keycfpTextVal";
NSString * const _szKeyDateVal = @"keycfpDateVal";
NSString * const _szKeyCachedPropTypes = @"keyCachePropTypes";
NSString * const _szKeyCachedTemplates = @"keyCacheTemplates";
NSString * const _szKeyPropArray = @"keycfpPropArray";
NSString * const _szKeyPrefsLockedTypes = @"keyPrefsLockedTypes";

+ (NSMutableDictionary *) sharedLockedTypes
{
    static dispatch_once_t pred;
    static NSMutableDictionary * shared = nil;
    dispatch_once(&pred, ^{
        shared = [FlightProps lockedTypesFromPrefs];
        if (shared == nil)
            shared = [[NSMutableDictionary alloc] init];
        });
    return shared;
}

+ (NSMutableArray *) sharedPropTypes
{
    static dispatch_once_t pred;
    static NSMutableArray * shared = nil;
    dispatch_once(&pred, ^{ shared = [[NSMutableArray alloc] init];});
    return shared;
}

+ (NSMutableArray<MFBWebServiceSvc_PropertyTemplate *> *) sharedTemplates {
    static dispatch_once_t pred;
    static NSMutableArray<MFBWebServiceSvc_PropertyTemplate *> * shared = nil;
    dispatch_once(&pred, ^{
        NSData * data = [NSUserDefaults.standardUserDefaults objectForKey:_szKeyCachedTemplates];
        if (data != nil)
            shared = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        else
            shared = [NSMutableArray new];
    });
    return shared;
}

+ (void) saveTemplates {
    NSUserDefaults * defs = NSUserDefaults.standardUserDefaults;
    [defs setObject:[NSKeyedArchiver archivedDataWithRootObject:FlightProps.sharedTemplates] forKey:_szKeyCachedTemplates];
    [defs synchronize];
}

+ (void) updateTemplates:(NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> *) templates forAircraft:(MFBWebServiceSvc_Aircraft *) ac {
    NSArray * defaultTemplates = MFBWebServiceSvc_PropertyTemplate.defaultTemplates;
    MFBWebServiceSvc_PropertyTemplate * ptSim = MFBWebServiceSvc_PropertyTemplate.simTemplate;
    MFBWebServiceSvc_PropertyTemplate * ptAnon = MFBWebServiceSvc_PropertyTemplate.anonTemplate;
    if (ptSim != nil)
        [templates removeObject:ptSim];
    if (ptAnon != nil)
        [templates removeObject:ptAnon];

    // If there is an aircraft specified and it has templates specified, use them .
    if (ac != nil && ac.DefaultTemplates != nil && ac.DefaultTemplates.int_.count > 0) {
        [templates addObjectsFromArray:[MFBWebServiceSvc_PropertyTemplate templatesWithIDs:ac.DefaultTemplates.int_]];
    } else if (defaultTemplates != nil && defaultTemplates.count > 0) {
        // check for default templates and use them exclusively
        [templates addObjectsFromArray:defaultTemplates];
    }
    
    // Always add in sim/anon as needed
    if (ac.isSim && ptSim != nil)
        [templates addObject:ptSim];
    
    if (ac.isAnonymous && ptAnon != nil)
        [templates addObject:ptAnon];
}

+ (void) flushTemplates {
    [FlightProps.sharedTemplates removeAllObjects];
    [FlightProps saveTemplates];
}

- (void) setPropTypeArray:(NSArray *) ar
{
    @synchronized([FlightProps sharedPropTypes])
    {
        [self.rgPropTypes removeAllObjects];
        [self.rgPropTypes addObjectsFromArray:ar];
        // Identify the locked ones
        for (MFBWebServiceSvc_CustomPropertyType * cpt in self.rgPropTypes)
            cpt.isLocked = [self isLockedPropertyType:cpt.PropTypeID.intValue];
    }
}

- (instancetype) init
{
    self = [super init];
	if (self != nil)
	{
        // Load the locked types before the proptypes so that we can set proptype locks correctly
        
        self.dictLockedTypes = [FlightProps sharedLockedTypes];
        self.rgPropTypes = [FlightProps sharedPropTypes];
        [self setPropTypeArray:[self cachedProps]];
        self.rgFlightProps = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
		self.errorString = @"";
	}
	return self;
}

- (NSArray<MFBWebServiceSvc_CustomPropertyType *> *) cachedProps
{
	NSData * rgArrayLastData = [[NSUserDefaults standardUserDefaults] objectForKey:_szKeyCachedPropTypes];	
	if (rgArrayLastData != nil)
		return [NSKeyedUnarchiver unarchiveObjectWithData:rgArrayLastData];
    else
        return nil;
}

// Clears "has loaded this session" so that a refresh can be attempted
- (void) setCacheRetry
{
    hasLoadedThisSession = NO;
}

- (int) cacheStatus
{
    if (self.rgPropTypes == nil || [self.rgPropTypes count] == 0)
        return cacheInvalid;
    
    return (hasLoadedThisSession ? cacheValid : cacheValidButRefresh);
}

- (NSMutableArray *) propertiesFromDB
{
    NSMutableArray * rgcpt = [[NSMutableArray alloc] init];
    
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
        
    sqlite3_stmt * sqlCpt = nil;
    
    NSString * szSql = @"SELECT * FROM custompropertytypes ORDER BY title ASC";
    
    if (sqlite3_prepare(app.db, [szSql cStringUsingEncoding:NSASCIIStringEncoding], -1, &sqlCpt, NULL) != SQLITE_OK)
        NSLog(@"Error: failed to prepare CPT query statement with message '%s'.", sqlite3_errmsg(app.db));
    
    while (sqlite3_step(sqlCpt) == SQLITE_ROW)
    {
        MFBWebServiceSvc_CustomPropertyType * cpt = [[MFBWebServiceSvc_CustomPropertyType alloc] initFromRow:sqlCpt];
        [rgcpt addObject:cpt];
         // slightly more efficient than autorelease
    }
    
    sqlite3_finalize(sqlCpt);
    
    return rgcpt;
}

- (void) cacheProps
{
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:[NSKeyedArchiver archivedDataWithRootObject:self.rgPropTypes] forKey:_szKeyCachedPropTypes];
    [defs synchronize];
    hasLoadedThisSession = YES; // we've initialized - no need to refresh the cache again this session.
    NSLog(@"Customproperty cache refreshed");    
}

- (void) loadCustomPropertyTypes
{
	NSLog(@"loadCustomPropertyTypes");
	self.errorString = @"";
    
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
	
	BOOL fNetworkAvail = [app isOnLine];
	
    // checking cache above will initialize self.rgPropTypes
    CacheStatus cs = self.cacheStatus;
    switch (cs)
    {
        case cacheValid:
            NSLog(@"loadCustomPropertyTypes - Using cached properties");
            return;
        case cacheValidButRefresh:
            if (!fNetworkAvail)
                return;
            NSLog(@"loadCustomPropertyTypes - cache is valid, but going to refresh");
            break;
        case cacheInvalid:
            // Use from DB by default - in case we are off-line, or there is some other failure
            if (self.rgPropTypes == nil || self.rgPropTypes.count == 0) {
                [self setPropTypeArray:[self propertiesFromDB]];
                if (self.rgPropTypes != nil && self.rgPropTypes.count > 0)  // should always be true.
                    [self cacheProps];
            }
            // Fall through - we will fetch them below
            break;
    }
    
	// we now have a cached set array of property types OR network available; try a refresh, use this on failure.
	if (fNetworkAvail)
	{
		NSLog(@"Attempting to refresh cached property types");
		
        MFBWebServiceSvc_PropertiesAndTemplatesForUser * cptSvc = [MFBWebServiceSvc_PropertiesAndTemplatesForUser new];
        cptSvc.szAuthUserToken = app.userProfile.AuthToken;

		MFBSoapCall * sc = [MFBSoapCall new];
		sc.logCallData = NO;
		sc.timeOut = 10;
		sc.delegate = self;

        [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
            [b PropertiesAndTemplatesForUserAsyncUsingParameters:cptSvc delegate:sc];
        }];
    }
}

- (void) deleteProperty:(MFBWebServiceSvc_CustomFlightProperty *) fp forUser:(NSString *) szAuthToken
{
	NSLog(@"deleteProperty");
	
	// new property - nothing to delete
	if (fp.PropID == nil || [fp.PropID intValue] <= 0 || fp.FlightID == nil || [fp.FlightID intValue] <= 0)
		return;
	
	BOOL fNetworkAvail = [mfbApp() isOnLine];
	if (!fNetworkAvail)
	{
		self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"No connection to the Internet is available");
		return;
	}

	MFBWebServiceSvc_DeletePropertiesForFlight * dpSvc = [MFBWebServiceSvc_DeletePropertiesForFlight new];
	dpSvc.idFlight = fp.FlightID;
	dpSvc.szAuthUserToken = szAuthToken;
	dpSvc.rgPropIds = [MFBWebServiceSvc_ArrayOfInt new];
	[dpSvc.rgPropIds.int_ addObject:fp.PropID];

	MFBSoapCall * sc = [MFBSoapCall new];
	sc.logCallData = NO;
	sc.timeOut = 10;
	sc.delegate = self;
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b DeletePropertiesForFlightAsyncUsingParameters:dpSvc delegate:sc];
    }];
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse class]])
	{
		MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse * resp = (MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse *) body;
        MFBWebServiceSvc_TemplatePropTypeBundle * bundle = resp.PropertiesAndTemplatesForUserResult;
		MFBWebServiceSvc_ArrayOfCustomPropertyType * rgCpt = bundle.UserProperties;
		
        if (rgCpt != nil && rgCpt.CustomPropertyType != nil && rgCpt.CustomPropertyType.count > 0) {
            [self setPropTypeArray:rgCpt.CustomPropertyType];
            [self cacheProps];
        }
        else
            [self setPropTypeArray:[self propertiesFromDB]]; // update from the DB since refresh didn't work.
        
        if (bundle.UserTemplates != nil && bundle.UserTemplates.PropertyTemplate != nil) {
            [FlightProps.sharedTemplates removeAllObjects];
            [FlightProps.sharedTemplates addObjectsFromArray:bundle.UserTemplates.PropertyTemplate];
            [FlightProps saveTemplates];
        }
	}
}

- (MFBWebServiceSvc_CustomPropertyType *) PropTypeFromID:(NSNumber *) id
{
	for (MFBWebServiceSvc_CustomPropertyType * cpt in self.rgPropTypes)
	{
		if ([cpt.PropTypeID intValue] == [id intValue])
			return cpt;
	}
	
	return nil;
}

+ (NSString *) stringValueForProperty:(MFBWebServiceSvc_CustomFlightProperty *) fp withType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
    NSString * szValue = @"";
	
	switch (cpt.Type) {
		case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
			szValue = (fp.BoolValue.boolValue) ? NSLocalizedString(@"Yes", @"True for a true/false property (e.g., flight was a checkride: yes/no)") : NSLocalizedString(@"No", @"False for a true/false property (e.g., flight was a checkride: yes/no");
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
		case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
		{
			NSNumberFormatter * nfDecimal = [[NSNumberFormatter alloc] init];
			[nfDecimal setNumberStyle:NSNumberFormatterDecimalStyle];
			[nfDecimal setMinimumFractionDigits:(cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpCurrency) ? 2 : 1];
			[nfDecimal setMaximumFractionDigits:2];
			szValue = [nfDecimal stringFromNumber:fp.DecValue];
		}
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
			szValue = [fp.IntValue stringValue];
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpString:
			szValue = fp.TextValue;
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpDate:
            szValue = [fp.DateValue dateString];
            break;
		case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            szValue = [fp.DateValue utcString];
		default:
			break;
	}
	
	return szValue;
}

- (NSString *) stringValueForProperty:(MFBWebServiceSvc_CustomFlightProperty *) fp
{
	MFBWebServiceSvc_CustomPropertyType * cpt = [self PropTypeFromID:fp.PropTypeID];
	if (cpt == nil)
		return @"";
	
    return [FlightProps stringValueForProperty:fp withType:cpt];
}

/*
  Returns a distillation of the provided list to only those items which are non-default AND not locked AND not in the specified templates
*/
- (NSMutableArray *) distillList:(NSMutableArray *) rgFp includeLockedProps:(BOOL) fIncludeLock includeTemplates:(NSSet<MFBWebServiceSvc_PropertyTemplate *> *) templates
{
    NSMutableArray * rgResult = [[NSMutableArray alloc] init];
    
    NSSet<NSNumber *> * templatedProps = (templates == nil) ? [NSSet<NSNumber *> new] : [MFBWebServiceSvc_PropertyTemplate propListForSets:templates];
    
    if (rgFp != nil)
        for (MFBWebServiceSvc_CustomFlightProperty * cfp in rgFp)
        {
            MFBWebServiceSvc_CustomPropertyType * cpt = [self PropTypeFromID:cfp.PropTypeID];
            if (cpt != nil && ((fIncludeLock && cpt.isLocked) || [templatedProps containsObject:cpt.PropTypeID] || ![cfp isDefaultForType:cpt]))
                [rgResult addObject:cfp];
        }
    
    return rgResult;
}

/*
 Provides a fully expanded list of properties, one item per property type, initialized with values from the supplied array
*/
- (NSMutableArray *) crossProduct:(NSMutableArray *) rgFp
{
    NSMutableArray * rgResult = [[NSMutableArray alloc] init];

    for (MFBWebServiceSvc_CustomPropertyType * cpt in self.rgPropTypes)
    {
        MFBWebServiceSvc_CustomFlightProperty * cfp = nil;
        
        for (MFBWebServiceSvc_CustomFlightProperty * fp in rgFp)
        {
            if ([fp.PropTypeID intValue] == [cpt.PropTypeID intValue])
            {
                cfp = fp;
                break;
            }
        }
        
        if (cfp == nil)
        {
            cfp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
            cfp.PropTypeID = cpt.PropTypeID;
            [cfp setDefaultForType:cpt];
        }
        
        [rgResult addObject:cfp];
    }
    
    return rgResult;    
}

- (NSMutableArray *) defaultPropList
{
    NSMutableArray * rgResult = [[NSMutableArray alloc] init];
    for (MFBWebServiceSvc_CustomPropertyType * cpt in self.rgPropTypes)
        if (cpt.isLocked)
        {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
            cfp.PropTypeID = cpt.PropTypeID;
            [cfp setDefaultForType:cpt];
            [rgResult addObject:cfp];
        }
    return rgResult;
}

+ (FlightProps *) getFlightPropsNoNet
{
    FlightProps * fp = [[FlightProps alloc] init];
    if ([fp cacheStatus] == cacheInvalid)
        [fp setPropTypeArray:[fp propertiesFromDB]];
    else
        [fp setPropTypeArray:[fp cachedProps]];
    return fp;
}

- (void) propValueChanged:(MFBWebServiceSvc_CustomFlightProperty *) fp
{
	// see if the property was deleted (set to default value); if so, remove it.
    if ([fp isDefaultForType:[self PropTypeFromID:fp.PropTypeID]])
    {
        // Make a copy of this to delete (so that we don't have a collision in multi-threading
        MFBWebServiceSvc_CustomFlightProperty * cfp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
        cfp.PropTypeID = @([fp.PropTypeID intValue]);
        cfp.PropID = @([fp.PropID intValue]);
        cfp.FlightID = @([fp.FlightID intValue]);
        cfp.IntValue = @1;
        cfp.DecValue = @1.0;
        cfp.BoolValue = [[ USBoolean alloc] initWithBool:YES];
        cfp.DateValue = [NSDate date];
        cfp.TextValue = @" ";
        
        [self deleteProperty:cfp forUser:mfbApp().userProfile.AuthToken];
        
        // And now reset the actual object in the array
        [fp setDefaultForType:[self PropTypeFromID:fp.PropTypeID]];
        fp.PropID = nil;  // make it a "new" property again.
    }
}

#pragma mark - Locked properties
+ (NSMutableDictionary *) lockedTypesFromPrefs
{
    NSMutableDictionary * dict = [((NSDictionary *) [[NSUserDefaults standardUserDefaults] objectForKey:_szKeyPrefsLockedTypes]) mutableCopy];
    if (dict == nil)
        dict = [[NSMutableDictionary alloc] init];
    return dict;
}

+ (void) saveLockedPropTypes:(NSDictionary *) d
{
    [[NSUserDefaults standardUserDefaults] setObject:d forKey:_szKeyPrefsLockedTypes];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) keyForID:(int) propTypeID
{
    return [NSString stringWithFormat:@"%d", propTypeID];
}

+ (NSNumber *) objectForID:(int) propTypeID
{
    return @(propTypeID);
}

- (void) setPropLock:(BOOL) fLock forPropTypeID:(NSInteger) propTypeID
{
    if (fLock)
        (self.dictLockedTypes)[[FlightProps keyForID:(int)propTypeID]] = @((int)propTypeID);
    else
        [self.dictLockedTypes removeObjectForKey:[FlightProps keyForID:(int)propTypeID]];
    
    // Update the relevant propertytype
    for (MFBWebServiceSvc_CustomPropertyType * cpt in self.rgPropTypes)
        if (cpt.PropTypeID.intValue == propTypeID)
        {
            cpt.isLocked = fLock;
            break;
        }
    [FlightProps saveLockedPropTypes:self.dictLockedTypes];
}

- (BOOL) isLockedPropertyType:(NSInteger) propTypeID
{
    return ((self.dictLockedTypes)[[FlightProps keyForID:(int)propTypeID]] != nil);
}

@end

@implementation MFBWebServiceSvc_CustomFlightProperty (Utility)

+ (MFBWebServiceSvc_CustomFlightProperty *) getNewFlightProperty
{
    MFBWebServiceSvc_CustomFlightProperty * cfp = [[MFBWebServiceSvc_CustomFlightProperty alloc] init];
    cfp.PropTypeID = @-1;
    cfp.PropID = @-1;
    cfp.FlightID = @-1;
    cfp.IntValue = @0;
    cfp.DecValue = @0.0;
    cfp.BoolValue = [[ USBoolean alloc] initWithBool:NO];
    cfp.DateValue = nil;
    cfp.TextValue = @"";
    return cfp;
}

- (BOOL) isDefaultForType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
	switch (cpt.Type) {
		case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
			return (self.BoolValue == nil || !self.BoolValue.boolValue);
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
		case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
			return (self.DecValue == nil || [self.DecValue doubleValue] == 0.0);
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
			return (self.IntValue == nil || [self.IntValue intValue] == 0);
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpString:
			return (self.TextValue == nil || [self.TextValue length] == 0);
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
		case MFBWebServiceSvc_CFPPropertyType_cfpDate:
			return self.DateValue == nil;
			break;
		default:
			break;
	}
	return NO;
}

- (void) setDefaultForType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
	switch (cpt.Type) {
		case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
			self.BoolValue = [[USBoolean alloc] initWithBool:NO];
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
		case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
			self.DecValue = @0.0;
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
			self.IntValue = @0;
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpString:
			self.TextValue = @"";
			break;
		case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
		case MFBWebServiceSvc_CFPPropertyType_cfpDate:
			self.DateValue = nil;
			break;
		default:
			break;
	}	
}

- (void)encodeWithCoderMFB:(NSCoder *)encoder
{
	[encoder encodeObject:self.PropID forKey:_szKeyPropID];
	[encoder encodeObject:self.FlightID forKey:_szKeyFlightID];
	[encoder encodeObject:self.PropTypeID forKey:_szKeyPropTypeID];
	[encoder encodeObject:self.IntValue forKey:_szKeyIntVal];
	[encoder encodeBool:[self.BoolValue boolValue] forKey:_szKeyBoolVal];
	[encoder encodeObject:self.DecValue forKey:_szKeyDecVal];
	[encoder encodeObject:self.TextValue forKey:_szKeyTextVal];
	[encoder encodeObject:self.DateValue forKey:_szKeyDateVal];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	self.PropID = [decoder decodeObjectForKey:_szKeyPropID];
	self.FlightID = [decoder decodeObjectForKey:_szKeyFlightID];
	self.PropTypeID = [decoder decodeObjectForKey:_szKeyPropTypeID];
	self.IntValue = [decoder decodeObjectForKey:_szKeyIntVal];
	self.BoolValue = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:_szKeyBoolVal]];
	self.DecValue = [decoder decodeObjectForKey:_szKeyDecVal];
	self.TextValue = [decoder decodeObjectForKey:_szKeyTextVal];
	self.DateValue = [decoder decodeObjectForKey:_szKeyDateVal];
	return self;
}
@end

@implementation MFBWebServiceSvc_ArrayOfCustomFlightProperty (NSCodingSupport)
- (void)encodeWithCoderMFB:(NSCoder *)encoder
{
	[encoder encodeObject:self.CustomFlightProperty forKey:_szKeyPropArray];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	NSArray * rgProps = (NSArray *) [decoder decodeObjectForKey:_szKeyPropArray];
	for (MFBWebServiceSvc_CustomFlightProperty * cfp in rgProps)
		[self addCustomFlightProperty:cfp];

	return self;
}

- (void) setProperties:(NSMutableArray *) ar
{
    [self.CustomFlightProperty removeAllObjects];
    [self.CustomFlightProperty addObjectsFromArray:ar];
}
@end

@implementation MFBWebServiceSvc_CustomPropertyType (NSCodingSupport)
@dynamic isLocked;

static char UIB_ISLOCKED_KEY;

#pragma mark - IsLocked
- (void) setIsLocked:(BOOL)isLocked
{
    NSString * szVal = (isLocked ? @"Y" : @"N");
    objc_setAssociatedObject(self, &UIB_ISLOCKED_KEY, szVal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL) isLocked
{
    NSString * sz = (NSString *) objc_getAssociatedObject(self, &UIB_ISLOCKED_KEY);
    return (sz != nil && [sz compare:@"Y"] == NSOrderedSame);
}

#pragma mark - Coding support
- (void)encodeWithCoderMFB:(NSCoder *)encoder
{
	[encoder encodeInt32:self.Type forKey:@"cptType"];
	[encoder encodeObject:self.Title forKey:@"cptTitle"];
    [encoder encodeObject:self.SortKey forKey:@"cptSortKey"];
	[encoder encodeObject:self.PropTypeID forKey:@"cptPropTypeID"];
	[encoder encodeObject:self.FormatString forKey:@"cptFormatString"];
    [encoder encodeObject:self.Description forKey:@"cptDescription"];
    [encoder encodeObject:self.PreviousValues forKey:@"cptPrevValues"];
	[encoder encodeObject:self.Flags forKey:@"cptFlags"];
    [encoder encodeBool:self.IsFavorite.boolValue forKey:@"cptFavoriteBOOL"];
    [encoder encodeBool:self.isLocked forKey:@"_cptLocked"];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	
	self.Type = (MFBWebServiceSvc_CFPPropertyType) [decoder decodeInt32ForKey:@"cptType"];
	self.Title = [decoder decodeObjectForKey:@"cptTitle"];
    self.SortKey = [decoder decodeObjectForKey:@"cptSortKey"];
	self.PropTypeID = [decoder decodeObjectForKey:@"cptPropTypeID"];
	self.FormatString = [decoder decodeObjectForKey:@"cptFormatString"];
    self.Description = [decoder decodeObjectForKey:@"cptDescription"];
    self.PreviousValues = [decoder decodeObjectForKey:@"cptPrevValues"];
	self.Flags = [decoder decodeObjectForKey:@"cptFlags"];
    self.IsFavorite = [[USBoolean alloc] initWithBool:[decoder decodeBoolForKey:@"cptFavoriteBOOL"]];
    self.isLocked = [decoder decodeBoolForKey:@"_cptLocked"];
    
    // handle upgrade from pre-favorites gracefully
    if (self.IsFavorite == nil)
        self.IsFavorite = [[USBoolean alloc] initWithBool:NO];
	
	return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ (%d)%@", self.Title, self.PropTypeID.intValue, self.isLocked ? @" LOCKED" : @""];
}

- (instancetype) initFromRow:(sqlite3_stmt *) row
{
    self = [self init];
    
    if (self != nil && row != NULL)
    {
        self.PropTypeID = @(sqlite3_column_int(row, 0));
        self.Title = @((char *)sqlite3_column_text(row, 1));
        self.SortKey = sqlite3_column_text(row, 2) == NULL ? @"" : @((char *) sqlite3_column_text(row, 2));
        if (self.SortKey == nil || self.SortKey.length == 0)
            self.SortKey = self.Title;
        self.FormatString = @((char *) sqlite3_column_text(row, 3));
        self.Type = (MFBWebServiceSvc_CFPPropertyType) sqlite3_column_int(row, 4) + 1;
        self.Flags = @(sqlite3_column_int(row, 5));
        char * descString = (char *)sqlite3_column_text(row, 6);
        self.Description = (descString == NULL) ? @"" : @(descString);
        self.IsFavorite = [[USBoolean alloc] initWithBool:NO];
        self.PreviousValues = [MFBWebServiceSvc_ArrayOfString new];
    }
    
    return self;
}
@end

@implementation MFBWebServiceSvc_PropertyTemplate(Utility)
NSString * const _szKeyTemplateID = @"keyTemplID";
NSString * const _szKeyTemplateName = @"keyTemplName";
NSString * const _szKeyTemplateDesc = @"keyTemplDesc";
NSString * const _szKeyTemplateGroup = @"keyTemplGroup";
NSString * const _szKeyTemplateDefault = @"keyTemplDefault";
NSString * const _szKeyTemplatePropTypes = @"keyTemplTypes";

- (void)encodeWithCoderMFB:(NSCoder *)encoder {
    [encoder encodeObject:self.ID_ forKey:_szKeyTemplateID];
    [encoder encodeObject:self.Name forKey:_szKeyTemplateName];
    [encoder encodeObject:self.Description forKey:_szKeyTemplateDesc];
    [encoder encodeObject:self.GroupAsInt forKey:_szKeyTemplateGroup];
    [encoder encodeObject:self.IsDefault forKey:_szKeyTemplateDefault];
    [encoder encodeObject:self.PropertyTypes forKey:_szKeyTemplatePropTypes];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder {
    self = [self init];
    self.ID_ = [decoder decodeObjectForKey:_szKeyTemplateID];
    self.Name = [decoder decodeObjectForKey:_szKeyTemplateName];
    self.Description = [decoder decodeObjectForKey:_szKeyTemplateDesc];
    self.GroupAsInt = [decoder decodeObjectForKey:_szKeyTemplateGroup];
    self.IsDefault = [decoder decodeObjectForKey:_szKeyTemplateDefault];
    self.PropertyTypes = [decoder decodeObjectForKey:_szKeyTemplatePropTypes];
    return self;
}

+ (MFBWebServiceSvc_PropertyTemplate *) templateWithID:(NSUInteger) idProp {
    for (MFBWebServiceSvc_PropertyTemplate * pt in FlightProps.sharedTemplates)
        if (pt.ID_.intValue == idProp)
            return pt;
    return nil;
}

+ (MFBWebServiceSvc_PropertyTemplate *) simTemplate {
    return [MFBWebServiceSvc_PropertyTemplate templateWithID:ID_SIM];
}

+ (MFBWebServiceSvc_PropertyTemplate *) anonTemplate {
    return [MFBWebServiceSvc_PropertyTemplate templateWithID:ID_ANON];
}

+ (NSArray<MFBWebServiceSvc_PropertyTemplate *> *) defaultTemplates {
    return [FlightProps.sharedTemplates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MFBWebServiceSvc_PropertyTemplate * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.IsDefault.boolValue;
    }]];
}

+ (NSArray<MFBWebServiceSvc_PropertyTemplate *> *) templatesWithIDs:(NSArray<NSNumber *> *) rgIds {
    return [FlightProps.sharedTemplates filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MFBWebServiceSvc_PropertyTemplate *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        for (NSNumber * ID in rgIds)
            if (ID.intValue == evaluatedObject.ID_.intValue)
                return YES;
        return NO;
    }]];
}

- (NSSet<NSNumber *> *) propTypesAsSet {
    return [NSMutableSet<NSNumber *> setWithArray:self.PropertyTypes.int_];
}

+ (NSSet<NSNumber *> *) propListForSets:(NSSet<MFBWebServiceSvc_PropertyTemplate *> *) rgTemplates {
    NSMutableSet * set = [NSMutableSet<NSNumber *> new];
    for (MFBWebServiceSvc_PropertyTemplate * pt in rgTemplates)
        [set unionSet:pt.propTypesAsSet];
    return set;
}

- (BOOL) isEqual:(id)object {
    if (object == nil)
        return self == nil;
    if (![object isKindOfClass:self.class])
        return false;
    return self.ID_.integerValue == ((MFBWebServiceSvc_PropertyTemplate *) object).ID_.integerValue;
}

- (NSUInteger)hash {
    return [self.ID_ hash];
}

+ (NSArray<NSDictionary<NSString *, id> *> *) groupTemplates:(NSArray<MFBWebServiceSvc_PropertyTemplate *> *) rgTemplates {
    NSMutableArray * result = [NSMutableArray new];
    
    // sort the array by group, then by name
    NSArray * sorted = [rgTemplates sortedArrayUsingComparator:^NSComparisonResult(MFBWebServiceSvc_PropertyTemplate *  _Nonnull obj1, MFBWebServiceSvc_PropertyTemplate *  _Nonnull obj2) {
        if (obj1.GroupAsInt.integerValue == obj2.GroupAsInt.integerValue) {
            if (obj1.GroupAsInt.integerValue == GROUP_ID_AUTOMATIC)
                return [obj2.ID_ compare:obj1.ID_];
            else
                return [obj1.Name compare:obj2.Name options:NSCaseInsensitiveSearch];
        } else if (obj1.GroupAsInt.integerValue == GROUP_ID_AUTOMATIC)
            return NSOrderedAscending;
        else if (obj2.GroupAsInt.integerValue == GROUP_ID_AUTOMATIC)
            return NSOrderedDescending;
        else
            return [obj1.GroupDisplayName compare:obj2.GroupDisplayName options:NSCaseInsensitiveSearch];
    }];
    
    NSString * currentGroupName = @"";
    NSMutableArray<MFBWebServiceSvc_PropertyTemplate *> * currentItems;
    
    for (MFBWebServiceSvc_PropertyTemplate * pt in sorted) {
        if ([pt.GroupDisplayName compare:currentGroupName] != NSOrderedSame) {
            currentGroupName = pt.GroupDisplayName;
            currentItems = [NSMutableArray<MFBWebServiceSvc_PropertyTemplate *> new];
            NSMutableDictionary<NSString *, id> * dict = [NSMutableDictionary<NSString *, id> new];
            [dict setObject:currentGroupName forKey:KEY_GROUPNAME];
            [dict setObject:currentItems forKey:KEY_PROPSFORGROUP];
            [result addObject:dict];
        }
        [currentItems addObject:pt];
    }
    
    return result;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"%d: %@ %@", self.ID_.intValue, self.Name, self.IsDefault.boolValue ? @"(Default)" : @""];
}
@end

