/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  RouteAnnotation.m
//  MFBSample
//
//  Created by Eric Berman on 1/18/10.
//  Copyright 2010-2023 MyFlightbook LLC. All rights reserved.
//

#import "RouteAnnotation.h"
#import "AutodetectOptions.h"


@implementation RouteAnnotation

@synthesize center;
@synthesize lineColor = _lineColor;
 
- (CLLocationCoordinate2D) coordinate
{
	return self.center;
}

- (NSString *) title
{
	return NSStringFromClass([self class]);
}

- (CLLocationCoordinate2D) coordinateAtIndex:(NSInteger) index
{
    CLLocationCoordinate2D coord;
    coord.latitude = coord.longitude = 0;
    return coord;
}

- (NSInteger) numberOfCoordinates
{
	return 0;
}


+ (BOOL) SupportsGeoDesic
{
    return NSClassFromString(@"MKGeodesicPolyline") != nil;
}

- (MKPolyline *) polylineWithCoordinates: (CLLocationCoordinate2D *) rgCoords count:(int) cPoints
{
    return [MKPolyline polylineWithCoordinates:rgCoords count:cPoints];
}

- (MKPolyline *) getOverlay
{
	NSInteger cPoints = [self numberOfCoordinates];
    NSInteger cBytes = cPoints * sizeof(CLLocationCoordinate2D);
    CLLocationCoordinate2D * rgCoords = malloc(cBytes + 1); // allocate an extra byte to shut up the compiler warning.
    
    for (int i = 0; i < cPoints; i++)
        rgCoords[i] = [self coordinateAtIndex:i];
    
    MKPolyline * gpl = [self polylineWithCoordinates:rgCoords count:(int)cPoints];
    gpl.title = [self title];
    
    free(rgCoords);

    return gpl;
}

+ (UIColor *) colorForPolyline
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Called abstract function colorForPolyline; only use in subclasses" userInfo:nil];
}
@end

@implementation AirportRoute
@synthesize airports;

- (CLLocationCoordinate2D) coordinateAtIndex:(NSInteger) index
{
	MFBWebServiceSvc_airport * ap = (MFBWebServiceSvc_airport *) (self.airports.rgAirports)[index];
	return [ap coordinate];
}

- (NSInteger) numberOfCoordinates
{
	return [self.airports.rgAirports count];
}

- (MKPolyline *) polylineWithCoordinates: (CLLocationCoordinate2D *) rgCoords count:(int) cPoints
{
    if ([RouteAnnotation SupportsGeoDesic])
        return [MKGeodesicPolyline polylineWithCoordinates:rgCoords count:cPoints];
    else
        return [super polylineWithCoordinates:rgCoords count:cPoints];
}

+ (UIColor *) colorForPolyline {
    return UserPreferences.current.routeColor;
}
@end



@implementation FlightRoute
@synthesize rgll;

- (CLLocationCoordinate2D) coordinateAtIndex:(NSInteger) index
{
	MFBWebServiceSvc_LatLong * ll = (MFBWebServiceSvc_LatLong *) (self.rgll.LatLong)[index];
	CLLocationCoordinate2D coord;
	coord.latitude = [ll.Latitude doubleValue];
	coord.longitude = [ll.Longitude doubleValue];
	return coord;
}

- (NSInteger) numberOfCoordinates
{
	return [self.rgll.LatLong count];
}


+ (UIColor *) colorForPolyline {
    return UserPreferences.current.pathColor;
}
@end
