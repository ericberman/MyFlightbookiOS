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
//  RouteAnnotation.h
//  MFBSample
//
//  Created by Eric Berman on 1/18/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"
#import "Airports.h"

// An annotation on top of the map
@interface RouteAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D center;
	UIColor* _lineColor;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D center;
@property (nonatomic, strong) UIColor* lineColor;

- (CLLocationCoordinate2D) coordinateAtIndex:(NSInteger) index;
- (NSInteger) numberOfCoordinates;
- (NSString *) title;

+ (BOOL) SupportsGeoDesic;
- (MKPolyline *) polylineWithCoordinates: (CLLocationCoordinate2D *) rgCoords count:(int) cPoints;
- (MKPolyline *) getOverlay;
+ (UIColor *) colorForPolyline;
@end


// Airport Route - a connect-the-dots routeannotation of airport-to-airport (straight line)
@interface AirportRoute : RouteAnnotation {
	Airports * airports;
}
@property (nonatomic, strong) Airports * airports;
@end


// Flight Route - a continuous path of lat/lon coordinates (arbitrarily curved)
@interface FlightRoute : RouteAnnotation {
	MFBWebServiceSvc_ArrayOfLatLong * rgll;
}
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfLatLong * rgll;
@end
