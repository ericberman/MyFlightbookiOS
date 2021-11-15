/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2021 MyFlightbook, LLC
 
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
//  Airports.m
//  MFBSample
//
//  Created by Eric Berman on 12/25/09.
//  Copyright 2009-2021, MyFlightbook LLC. All rights reserved.
//

#import "Airports.h"
#import "LocalAirports.h"
#import "MFBAppDelegate.h"

@implementation Airports

#define MIN_NAVAID_CODE_LENGTH  2
#define MIN_AIRPORT_CODE_LENGTH 3
#define MAX_AIRPORT_CODE_LENGTH 6

#define szNavaidPrefix @"@"

@synthesize errorString;
@synthesize rgAirports;

+ (NSString *) RegAdHocFix
{
    return [NSString stringWithFormat:@"%@%@", szNavaidPrefix, @"\\b\\d{1,2}(?:[\\.,]\\d*)?[NS]\\d{1,3}(?:[\\.,]\\d*)?[EW]\\b"];  // Must have a digit on the left side of the decimal
}

+ (NSString *) RegexAirports
{
    return [NSString stringWithFormat:@"((?:%@)|(?:@?\\b[A-Z0-9]{%d,%d}\\b))", [Airports RegAdHocFix], MIN(MIN_NAVAID_CODE_LENGTH, MIN_AIRPORT_CODE_LENGTH), MAX_AIRPORT_CODE_LENGTH];
}

static NSRegularExpression * _reAdhoc = nil;
static NSRegularExpression * _reAirports = nil;

+ (BOOL) isAdhocFix:(NSString *) sz
{
    NSError * err = NULL;
    if (_reAdhoc == nil)
        _reAdhoc = [[NSRegularExpression alloc] initWithPattern:[Airports RegAdHocFix] options:NSRegularExpressionCaseInsensitive error:&err];
    
    return [_reAdhoc numberOfMatchesInString:sz options:0 range:NSMakeRange(0, sz.length)];
}

- (instancetype)init
{
    self = [super init];
	if (self != nil)
	{
		self.rgAirports = [[NSMutableArray alloc] init];
		self.errorString = @"";
	}
	return self;
}

+ (MKCoordinateRegion) defaultRegionForPosition:(CLLocation *) loc
{
	double dlat = 1.0, dlon = 1.0;
	
	return MKCoordinateRegionMake(loc.coordinate, MKCoordinateSpanMake(dlat, dlon));
}

- (BOOL) loadAirportsNearPosition:(MKCoordinateRegion) loc limit:(NSInteger)max
{
	self.errorString = @"";
	
	if (!self.rgAirports)
		self.rgAirports = [[NSMutableArray alloc] init];
	[self.rgAirports removeAllObjects];
		
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
	
    LocalAirports * la = [[LocalAirports alloc] initWithLocation:loc withDB:app.db withLimit:max];
    if (la.rgAirports != nil)
        self.rgAirports = la.rgAirports;
    else
        self.errorString = NSLocalizedString(@"Local Airports initWithLocation found no airports.", "Error message for failure to find an airport in the db");

	return [self.errorString length] == 0;
}

+ (NSString *) appendAirport:(MFBWebServiceSvc_airport *)ap ToRoute:(NSString *) szRouteSoFar
{
	NSString * szReturn = szRouteSoFar;
    
    if (szReturn == nil || [szReturn length] == 0)
        return ap.Code;
	
	if (ap != nil && ap.Code != nil && [ap.Code length] > 0)
	{
		// check that this airport is not already at the end of the list
		NSString * szCurrent = szRouteSoFar;
		NSRange r = [szCurrent rangeOfString:ap.Code options:NSBackwardsSearch|NSCaseInsensitiveSearch];
		
		// if it's not at the end of the list OR szCurrent is still nil, append it.
		if (szCurrent == nil || r.location == NSNotFound || (r.location + r.length) < [szCurrent length])
		{
			NSString * newText = [NSString stringWithFormat:@"%@ %@", (szCurrent != nil) ? szCurrent : @"", ap.Code];
			szReturn = [newText uppercaseString];
		}
	}
	return szReturn;
}

+ (NSString *) appendNearestAirport:(NSString *) szRouteSoFar
{
	Airports * ap = [[Airports alloc] init];
	
	MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
	
	if (app.mfbloc.lastSeenLoc == nil)
	{
#ifdef DEBUG
		NSLog(@"No current loc in appendNearestAirport");
#endif
		return szRouteSoFar;
	}
	
	[ap loadAirportsNearPosition:[Airports defaultRegionForPosition:app.mfbloc.lastSeenLoc] limit:1];
	
	if ([ap.rgAirports count] > 0)
	{
		MFBWebServiceSvc_airport * airport = (MFBWebServiceSvc_airport *) (ap.rgAirports)[0];
		return [Airports appendAirport:airport ToRoute:szRouteSoFar];
	}
	else
		return szRouteSoFar;
}

- (BOOL) loadAirportsFromRoute:(NSString *)szRoute; 
{
	NSLog(@"loadAirportsFromRoute");
	self.errorString = @"";
	
	if (!self.rgAirports)
		self.rgAirports = [[NSMutableArray alloc] init];
	[self.rgAirports removeAllObjects];

	MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
	
    LocalAirports * la = [[LocalAirports alloc] initWithAirportList:szRoute withDB:app.db fromLoc:app.mfbloc.lastSeenLoc.coordinate];
    if (la.rgAirports == nil)
        self.errorString = NSLocalizedString(@"Unable to initialize airport list", @"Error message when looking up airports in a route of flight");
    else
        self.rgAirports = la.rgAirports;
	
	return [self.errorString length] == 0;
}

- (double) maxDistanceOnRoute:(NSString *) szRoute;
{
    double dist = 0.0;
    
    [self loadAirportsFromRoute:szRoute];
    
    NSInteger cAirports = [self.rgAirports count];
    int i, j;
    // find the distance between each of the airports.
    for (i = 0; i < cAirports; i++)
    {
        MFBWebServiceSvc_airport * ap1 = (MFBWebServiceSvc_airport *) (self.rgAirports)[i];
        
        if (![ap1 isPort])
            continue;
        
        for (j = i + 1; j < cAirports; j++)
        {
            MFBWebServiceSvc_airport * ap2 = (MFBWebServiceSvc_airport *) (self.rgAirports)[j];
            
            if (![ap2 isPort])
                continue;
            
            double lat1rad = DEG2RAD([ap1.Latitude doubleValue]);
            double lon1 = [ap1.Longitude doubleValue];
            double lat2rad = DEG2RAD([ap2.Latitude doubleValue]);
            double lon2 = [ap2.Longitude doubleValue];
            double d = acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(DEG2RAD(lon2) - DEG2RAD(lon1))) * 3440.06479;
            if (d > dist)
                dist = d;
        }
    }
    
    return dist;
}

- (MKCoordinateRegion) defaultZoomRegionWithPath:(MFBWebServiceSvc_ArrayOfLatLong *) rgll
{
	LatLongBox * llb = [[LatLongBox alloc] init];
	
	CLLocationCoordinate2D loc;
	
	if ([self.rgAirports count] > 0)
	{
		for (MFBWebServiceSvc_airport * ap in self.rgAirports)
		{
			loc.latitude = [ap.Latitude doubleValue];
			loc.longitude = [ap.Longitude doubleValue];
			[llb addPoint:loc];
		}
	}
	
	if (rgll != nil && [rgll.LatLong count] > 0)
	{
		for (MFBWebServiceSvc_LatLong * ll in rgll.LatLong)
		{
			loc.latitude = [ll.Latitude doubleValue];
			loc.longitude = [ll.Longitude doubleValue];
			[llb addPoint:loc];
		}
	}

	return [llb getRegion];
}

+ (NSArray *) CodesFromString:(NSString *) szAirports
{
    NSMutableArray * rgResult = [NSMutableArray new];
    NSError * err = NULL;
    if (_reAirports == nil)
        _reAirports = [[NSRegularExpression alloc] initWithPattern:[Airports RegexAirports] options:NSRegularExpressionCaseInsensitive error:&err];
    szAirports = [szAirports uppercaseString];
    NSArray * rgMatches = [_reAirports matchesInString:szAirports options:0 range:NSMakeRange(0, szAirports.length)];
    for (NSTextCheckingResult * tcr in rgMatches)
        [rgResult addObject:[szAirports substringWithRange:tcr.range]];

    return rgResult;
}
@end

@implementation LatLongBox

- (instancetype)init
{
    self = [super init];
	if (self != nil)
	{
		latMin = latMax = longMin = longMax = 0.0;
		cPoints = 0;
	}
	return self;
}

- (BOOL) isValid
{
	return cPoints > 0;
}

- (BOOL) isInfinitessimal
{
	return (latMax == latMax || longMin == longMax);
}

- (void) addPoint:(CLLocationCoordinate2D)loc
{
	if (cPoints == 0) // 1st point
	{
		latMin = latMax = loc.latitude;
		longMin = longMax = loc.longitude;
	}
	else 
	{
		if (loc.latitude < latMin)
			latMin = loc.latitude;
		if (loc.latitude > latMax)
			latMax = loc.latitude;
		if (loc.longitude < longMin)
			longMin = loc.longitude;
		if (loc.longitude > longMax)
			longMax = loc.longitude;
	}

	cPoints++;
}

- (MKCoordinateRegion) getRegion
{
	MKCoordinateRegion mcr;
	mcr.span.latitudeDelta = mcr.span.longitudeDelta = 0.0;
	mcr.center.latitude = mcr.center.longitude = 0.0;

	if ([self isValid])
	{
		if ([self isInfinitessimal])
		{
			latMin -= 0.5;
			latMax += 0.5;
			longMin -= 0.5;
			longMax += 0.5;			
		}
		
		mcr.center.latitude = (latMax + latMin) / 2.0;
		mcr.center.longitude = (longMax + longMin) / 2.0;
		mcr.span.latitudeDelta = (latMax - latMin);
		mcr.span.longitudeDelta = (longMax - longMin);
	}

	return mcr;
}
@end

@implementation MFBWebServiceSvc_airport (Annotatable)
- (instancetype) initFromRow:(sqlite3_stmt *) row
{
    self.Code = @((char *)sqlite3_column_text(row, 0));
    self.Name = @((char *)sqlite3_column_text(row, 1));
    self.LatLong = [MFBWebServiceSvc_LatLong new];
    self.LatLong.Latitude = @(sqlite3_column_double(row, 4));
    self.LatLong.Longitude = @(sqlite3_column_double(row, 5));
    self.Latitude = self.LatLong.Latitude.stringValue;
    self.Longitude = self.LatLong.Longitude.stringValue;
    self.FacilityTypeCode = @((char *)sqlite3_column_text(row, 2));
    // column 3 is sourceusername - ignore it.
    // column 6 is preferred - ignore it
    const char * sz = (char *) sqlite3_column_text(row, 7);
    self.Country = (sz == NULL) ? @"" : @(sz);
    sz = (char *) sqlite3_column_text(row, 8);
    self.Admin1 = (sz == NULL) ? @"" : @(sz);
    self.DistanceFromPosition = @(sqlite3_column_double(row, 9));
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
    if (self.LatLong != nil)
        return CLLocationCoordinate2DMake(self.LatLong.Latitude.doubleValue, self.LatLong.Longitude.doubleValue);
    else
        return CLLocationCoordinate2DMake(self.Latitude.doubleValue, self.Longitude.doubleValue);
}

- (NSString *) title
{
    double dist = [self.DistanceFromPosition doubleValue];
 
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;

    if (dist == 0.0 && app.mfbloc.lastSeenLoc != nil)
    {
        // try to compute the distance
        CLLocationCoordinate2D cloc = app.mfbloc.lastSeenLoc.coordinate;
        if (cloc.latitude != 0.0 && cloc.longitude != 0.0)
            dist = NM_IN_A_METER * [app.mfbloc.lastSeenLoc distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.Latitude.doubleValue longitude:self.Longitude.doubleValue]];
    }
    NSString * szDistance = [NSString localizedStringWithFormat:NSLocalizedString(@" (%.1fNM away)", @"Distance to airport - %.1f is replaced by the distance in nautical miles"), dist];
    
    return [NSString stringWithFormat:@"%@%@", self.Code, ((dist == 0.0) ? @"" : szDistance)];
}

- (NSComparisonResult) compareDistance:(MFBWebServiceSvc_airport *) ap
{
	if ([ap.DistanceFromPosition doubleValue] > [self.DistanceFromPosition doubleValue])
		return NSOrderedAscending;
	else if ([ap.DistanceFromPosition doubleValue] < [self.DistanceFromPosition doubleValue])
		return NSOrderedDescending;
	else
		return NSOrderedSame;

}

- (NSString *) subtitle
{
    NSString * szLocale = (Country == nil || Country.length == 0 || [Country hasPrefix:@"--"]) ? @"" :
        [[NSString stringWithFormat:@"%@%@", (Admin1 == nil || Admin1.length == 0) ? Country : [NSString stringWithFormat:@"%@, ", Admin1], Country] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
	
    return szLocale.length == 0 ? self.Name : [NSString stringWithFormat:@"%@ (%@)", self.Name, szLocale];
}

+ (MFBWebServiceSvc_airport *) getAdHoc:(NSString *) szLatLon;
{
    MFBWebServiceSvc_airport * ap = [MFBWebServiceSvc_airport new];
    MFBWebServiceSvc_LatLong * ll = [MFBWebServiceSvc_LatLong fromString:szLatLon];
    if (ll == nil)
        return nil;
    MFBLocation * loc = MFBAppDelegate.threadSafeAppDelegate.mfbloc;
    ap.LatLong = ll;
    ap.Latitude = ll.Latitude.stringValue;
    ap.Longitude = ll.Longitude.stringValue;
    ap.FacilityType = ap.FacilityTypeCode = @"FX";
    ap.DistanceFromPosition = @(NM_IN_A_METER * (loc.lastSeenLoc == nil ? 0 : [loc.lastSeenLoc distanceFromLocation:[[CLLocation alloc] initWithLatitude:ll.Latitude.doubleValue longitude:ll.Longitude.doubleValue]]));
    ap.Name = [ll description];
    ap.Code = szLatLon;
    ap.UserName = @"";
    return ap;
}

- (BOOL) isAdhoc
{
    return [Airports isAdhocFix:[szNavaidPrefix stringByAppendingString:self.Code]];
}

- (BOOL) isPort
{
    return ([self.FacilityTypeCode compare:@"A"] == NSOrderedSame || 
            [self.FacilityTypeCode compare:@"H"] == NSOrderedSame || 
            [self.FacilityTypeCode compare:@"S"] == NSOrderedSame);
}

// Returns a priority for different navaids in disambiguation; lower is higher priority
- (int) NavaidPriority
{
    // Airports ALWAYS have priority
    if ([self isPort])
        return 0;

    // Otherwise, give priority to VOR/VORTAC/etc., else NDB, else GPS fix, else everything else
    // VOR Types:
    if ([self.FacilityTypeCode compare:@"V"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"C"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"D"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"T"] == NSOrderedSame)
        return 1;
    
    // NDB Types:
    if ([self.FacilityTypeCode compare:@"R"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"RD"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"M"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"MD"] == NSOrderedSame || 
        [self.FacilityTypeCode compare:@"U"] == NSOrderedSame)
        return 2;
    
    // Generic fix
    if ([self.FacilityTypeCode compare:@"FX"] == NSOrderedSame)
        return 3;
    
    return 4;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%@ (%@) %@", self.FacilityTypeCode, self.Code, self.Name];
}

@end

@implementation MFBWebServiceSvc_VisitedAirport(Sortable)
- (NSComparisonResult) compareName:(MFBWebServiceSvc_VisitedAirport *) va
{
    return [self.Airport.Name compare:va.Airport.Name options:NSCaseInsensitiveSearch];    
}

- (NSString *) AllCodes
{
    if (Aliases == nil)
        return Code;
    return [NSString stringWithFormat:@"%@,%@", Code, Aliases];
}

- (NSString *) description
{
    return self.Airport.description;
}

// Allow a visited airport to be annotatable based on the underlying airport.
- (CLLocationCoordinate2D) coordinate { return self.Airport.coordinate;}
- (NSString *) title {return self.Airport.title;}
- (NSString *) subtitle {return self.Airport.subtitle;}
@end

@implementation MFBWebServiceSvc_LatLong(Description)
- (NSString *) description
{
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    nf.maximumFractionDigits = 8;
    return [NSString stringWithFormat:@"%@, %@", [nf stringFromNumber:self.Latitude], [nf stringFromNumber:self.Longitude]];
}

- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(self.Latitude.doubleValue, self.Longitude.doubleValue);
}

+ (MFBWebServiceSvc_LatLong *) fromString:(NSString *)sz
{
    NSError * err = NULL;
    sz = [sz uppercaseString];
    NSRegularExpression * reAirports = [[NSRegularExpression alloc] initWithPattern:@"@?([^a-zA-Z]+)([NS]) *([^a-zA-Z]+)([EW])" options:NSRegularExpressionCaseInsensitive error:&err];
    NSArray * rgMatches = [reAirports matchesInString:sz options:0 range:NSMakeRange(0, sz.length)];
    if (rgMatches.count > 0)
    {
        NSTextCheckingResult * tcr = rgMatches[0];
        @try {
            MFBWebServiceSvc_LatLong * ll = [MFBWebServiceSvc_LatLong new];
            NSString * szLatString = [sz substringWithRange:[tcr rangeAtIndex:1]];
            NSString * szLatNS = [sz substringWithRange:[tcr rangeAtIndex:2]];
            NSString * szLonString = [sz substringWithRange:[tcr rangeAtIndex:3]];
            NSString * szLonEW = [sz substringWithRange:[tcr rangeAtIndex:4]];
            ll.Latitude = [NSNumber numberWithDouble:[szLatString doubleValue] * (([szLatNS compare:@"N"] == NSOrderedSame) ? 1 : -1)];
            ll.Longitude = [NSNumber numberWithDouble:[szLonString doubleValue] * (([szLonEW compare:@"E"] == NSOrderedSame) ? 1 : -1)];
            return ll;
        }
        @catch (NSException * ex)
        {
            return nil;
        }
        return nil;
    }
    return nil;
}

- (instancetype) initWithCoord:(CLLocationCoordinate2D) coord
{
    self.Latitude = @(coord.latitude);
    self.Longitude = @(coord.longitude);
    return self;
}

- (NSString *) toAdhocString
{
    NSNumberFormatter * nf = [NSNumberFormatter new];
    nf.maximumFractionDigits = 4;

    return [NSString stringWithFormat:@"%@%@%@%@%@",
            szNavaidPrefix,
            [nf stringFromNumber:@(ABS(Latitude.doubleValue))],
            Latitude.doubleValue > 0 ? @"N" : @"S",
            [nf stringFromNumber:@(ABS(Longitude.doubleValue))],
            Longitude.doubleValue > 0 ? @"E" : @"W"];
}
@end
