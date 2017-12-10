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
//  LocalAirports.m
//  MFBSample
//
//  Created by Eric Berman on 6/2/10.
//  Copyright 2010-2017, MyFlightbook LLC. All rights reserved.
//

#import "LocalAirports.h"
#import "Airports.h"
#import "MFBAppDelegate.h"
#import <math.h>

@implementation LocalAirports

@synthesize rgAirports, database;


- (NSString *) distanceColumnFromLoc:(CLLocationCoordinate2D)loc
{
    return [NSString stringWithFormat:@"distance(ap.latitude, ap.longitude, %.8f, %.8f) AS Distance", 
            loc.latitude, loc.longitude];
}

// DO NOT CALL THIS - it simply removes a warning from the compiler
- (instancetype) init
{
    return [self initWithAirportList:nil withDB:nil fromLoc:CLLocationCoordinate2DMake(0, 0)];
}

- (instancetype) initWithLocation:(MKCoordinateRegion) loc withDB:(sqlite3 *) db withLimit:(NSInteger) limit
{
    self = [super init];
	if (self)
	{
		self.database = db;
		self.rgAirports = [[NSMutableArray alloc] init];
		
		// if the span is more than about 4 degrees in either direction, return
		// an empty set - we're too far zoomed out to be meaningful.
		if (loc.span.latitudeDelta > 4.0 || loc.span.longitudeDelta > 4.0)
			return self;
		
		sqlite3_stmt * sqlAirportsNearPosition = nil;
		double minLat, maxLat, minLong, maxLong;
		double lat, lon;
		
		lat = loc.center.latitude;
		lon = loc.center.longitude;
			
		// BUG: this doesn't work if we cross 180 degrees, but there are so few airports there that it shouldn't matter
		minLat = MAX(lat - (loc.span.latitudeDelta / 2.0), -90.0);
		maxLat = MIN(lat + (loc.span.latitudeDelta / 2.0), 90.0);
		minLong = lon - (loc.span.longitudeDelta / 2.0);
		maxLong = lon + (loc.span.longitudeDelta / 2.0);
		// we don't bother correcting lon's below -180 or above +180 for reason above

		MFBAppDelegate * app = mfbApp();
		CLLocationCoordinate2D curLoc = (app.mfbloc.lastSeenLoc == nil) ? loc.center : app.mfbloc.lastSeenLoc.coordinate;
        
		BOOL fHeliports = [AutodetectOptions includeHeliports];
		
		NSString * szSql = [NSString stringWithFormat:@"SELECT ap.*, %@ FROM airports ap WHERE ap.latitude BETWEEN %.8F AND %.8F AND ap.longitude BETWEEN %.8F AND %.8F AND Type IN %@ ORDER BY ROUND(Distance, 2) ASC, Preferred DESC, length(AirportID) DESC %@",
                            [self distanceColumnFromLoc:curLoc],
							minLat, maxLat, minLong, maxLong,
							(fHeliports) ? @"('H', 'A', 'S')" : @"('A', 'S')",
                            (limit > 0) ? [NSString stringWithFormat:@"LIMIT %d", (int) limit] : @""];
			
		if (sqlite3_prepare(self.database, [szSql cStringUsingEncoding:NSASCIIStringEncoding], -1, &sqlAirportsNearPosition, NULL) != SQLITE_OK)
			NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));

		while (sqlite3_step(sqlAirportsNearPosition) == SQLITE_ROW)
		{
			MFBWebServiceSvc_airport * ap = [[MFBWebServiceSvc_airport alloc] initFromRow:sqlAirportsNearPosition];
			[self.rgAirports addObject:ap];
			 // slightly more efficient than autorelease
		}
		
		sqlite3_finalize(sqlAirportsNearPosition);
	}
	return self;
}

- (BOOL) isUSAirport:(NSString *) szAirport
{
    return ([szAirport length] == 4) && ([szAirport hasPrefix:szUSAirportPrefix]);
}

- (NSString *) USAirportPrefix:(NSString *) szAirport
{
    return ([self isUSAirport:szAirport]) ? [szAirport substringFromIndex:1] : szAirport;
}

- (instancetype) initWithAirportList:(NSString *) szAirports withDB:(sqlite3 *) db fromLoc:(CLLocationCoordinate2D) loc
{
    self = [super init];
	if (self)
	{
		self.database = db;
		self.rgAirports = [[NSMutableArray alloc] init];

        NSMutableDictionary * dictAp = [[NSMutableDictionary alloc] init];
		sqlite3_stmt * sqlResolveAirports = nil;
		
        // Break up the string into constituent airports
        NSArray * rgCodes = [Airports CodesFromString:szAirports];
		if ([rgCodes count] == 0)
			return self;
		
        // Find any matches in the database.
        // Need to strip any leading "@" for the actual search; we'll apply this logic further below.
		NSMutableString * szAirportSet = [[NSMutableString alloc] init];		
		for (__strong NSString * airportCode in rgCodes)
		{
            // If it's an ad-hoc fix, just add it directly to the dictionary
            if ([Airports isAdhocFix:airportCode])
            {
                MFBWebServiceSvc_airport * apAdhoc = [MFBWebServiceSvc_airport getAdHoc:airportCode];
                if (apAdhoc != nil)
                    [dictAp setValue:apAdhoc forKey:airportCode];
                continue;
            }

            // Strip the leading "@" if necessary:
            if ([airportCode hasPrefix:@"@"])
                airportCode = [airportCode substringFromIndex:1];
            [szAirportSet appendFormat:@"%@\"%@\"", ([szAirportSet length] > 0) ? @", " : @"", airportCode];
            if ([self isUSAirport:airportCode])
                [szAirportSet appendFormat:@"%@\"%@\"", ([szAirportSet length] > 0) ? @", " : @"", [self USAirportPrefix:airportCode]];
		}


		NSString * szSql = [NSString stringWithFormat:@"SELECT ap.*, %@ FROM airports ap WHERE ap.airportID in (%@)",
                            [self distanceColumnFromLoc:loc],
							szAirportSet];
		
		if (sqlite3_prepare(self.database, [szSql cStringUsingEncoding:NSASCIIStringEncoding], -1, &sqlResolveAirports, NULL) != SQLITE_OK)
			NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(self.database));

        // Read the results and put them into a dictionary by their code
		while (sqlite3_step(sqlResolveAirports) == SQLITE_ROW)
		{
			MFBWebServiceSvc_airport * ap = [[MFBWebServiceSvc_airport alloc] initFromRow:sqlResolveAirports];
            
            // if it's an airport/heliport/seaport, store it using its code
            if ([ap isPort])
                [dictAp setValue:ap forKey:ap.Code];
            else
            {
                // else store it using the navaid key (prefix "@"), replacing any lower priority (higher navaid priority) navaid
                NSString * szKey = [NSString stringWithFormat:@"@%@", ap.Code];
                MFBWebServiceSvc_airport * ap2 = (MFBWebServiceSvc_airport *) dictAp[szKey];
                if (ap2 == nil || [ap NavaidPriority] < [ap2 NavaidPriority])
                    [dictAp setValue:ap forKey:szKey];
            }
			 // slightly more efficient than autorelease
		}
        sqlite3_finalize(sqlResolveAirports);

        // We now have in dictAp an dictionary of the typed airports, in no particular order and effectively deduped by the database
		// Now we need to add the airports to rgairports in the order in which they were typed.
		for (NSString * szTypedCode in rgCodes)
		{
            MFBWebServiceSvc_airport * ap = (MFBWebServiceSvc_airport *) dictAp[szTypedCode];
            
            // if not found, see if it is under the navaid
            if (ap == nil)
                ap = (MFBWebServiceSvc_airport *) dictAp[[NSString stringWithFormat:@"@%@", szTypedCode]];
            
            // if that didn't work, try seeing if it's there without the "K" prefix
            if (ap == nil)
                ap = (MFBWebServiceSvc_airport *) dictAp[[self USAirportPrefix:szTypedCode]];
            
            if (ap != nil)
                [self.rgAirports addObject:ap];
		}		
	}
	return self;
}


@end
