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
//  Airports.h
//  MFBSample
//
//  Created by Eric Berman on 12/25/09.
//  Copyright 2009-2017, MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"
#import "MFBSoapCall.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <sqlite3.h>

@interface LatLongBox : NSObject
{
	int cPoints;
	CLLocationDegrees latMin;
	CLLocationDegrees latMax;
	CLLocationDegrees longMin;
	CLLocationDegrees longMax;
}

- (BOOL) isValid;
- (BOOL) isInfinitessimal;
- (void) addPoint:(CLLocationCoordinate2D)loc;
- (MKCoordinateRegion) getRegion;

@end


#define szUSAirportPrefix @"K"

@interface Airports : NSObject {
	NSMutableArray * rgAirports;
	NSString * errorString;
}

@property (readwrite, strong) NSMutableArray * rgAirports;
@property (readwrite, strong) NSString * errorString;

- (BOOL) loadAirportsNearPosition:(MKCoordinateRegion) loc limit:(NSInteger) max;
- (BOOL) loadAirportsFromRoute:(NSString *)szRoute; 
- (double) maxDistanceOnRoute:(NSString *) szRoute;
- (MKCoordinateRegion) defaultZoomRegionWithPath:(MFBWebServiceSvc_ArrayOfLatLong *) rgll;
+ (MKCoordinateRegion) defaultRegionForPosition:(CLLocation *) loc;
+ (NSString *) appendNearestAirport:(NSString *) szRouteSoFar;
+ (NSString *) appendAirport:(MFBWebServiceSvc_airport *)ap ToRoute:(NSString *) szRouteSoFar;
+ (NSArray *) CodesFromString:(NSString *) szAirports;
+ (BOOL) isAdhocFix:(NSString *) sz;
@end

// Add methods to the MFBWebServiceSvc_aiport object (from WSDL) to make it comform to the MKAnnotate protocol, have a few other methods
@interface MFBWebServiceSvc_airport (Annotatable)
    - (instancetype) initFromRow:(sqlite3_stmt *) row;
	- (CLLocationCoordinate2D) coordinate;
	- (NSString *) title;
	- (NSString *) subtitle;	
	- (NSComparisonResult) compareDistance:(MFBWebServiceSvc_airport *) ap;
    - (BOOL) isPort;
    - (int) NavaidPriority;
    + (MFBWebServiceSvc_airport *) getAdHoc:(NSString *) szLatLon;
    - (BOOL) isAdhoc;
@end

@interface MFBWebServiceSvc_VisitedAirport (Sortable)
- (NSComparisonResult) compareName:(MFBWebServiceSvc_VisitedAirport *) va;
- (NSString *) AllCodes;
- (NSString *) description;
@end

@interface MFBWebServiceSvc_LatLong(Description)
- (NSString *) description;
+ (MFBWebServiceSvc_LatLong *) fromString:(NSString *)sz;
- (instancetype) initWithCoord:(CLLocationCoordinate2D) coord;
- (NSString *) toAdhocString;
- (CLLocationCoordinate2D) coordinate;
@end
