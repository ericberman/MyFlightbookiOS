/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2023 MyFlightbook, LLC
 
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
//  SwiftConversionHackBridge.m
//  MyFlightbook
//
//  Created by Eric Berman on 3/28/23.
//

#import <Foundation/Foundation.h>
#import <MyFlightbook-Swift.h>
#import "SwiftConversionHackBridge.h"
#import "RecentFlights.h"
#import "AircraftViewController.h"
#import "NewAircraftViewController.h"

// Below are stubs for things that we can't call from swift (because we'd have to expose them in the bridging header,
// but they in turn pull in references to swift objects that are defined in swift.h, causing circularity
// Until they get converted, we can bypass that by having this simple, clean (dependeny free) bridging file
@implementation SwiftConversionHackBridge

+ (UIViewController *_Nonnull) recentFlightsWithQuery: ( MFBWebServiceSvc_FlightQuery * _Nonnull ) fq {
    RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
    rf.fq = fq;
    [rf refresh];
    return rf;
}

+ (UIViewController *_Nonnull) aircraftDetailsWithAircraft: (MFBWebServiceSvc_Aircraft * _Nonnull) ac {
    return ac.isNew ? [[NewAircraftViewController alloc] initWithAircraft:ac] : [[AircraftViewController alloc] initWithAircraft:ac];
}

+ (UIViewController *_Nonnull) aircraftDetailsWithAircraft: (MFBWebServiceSvc_Aircraft * _Nonnull) ac delegate:(id _Nullable) d {
    AircraftViewControllerBase * vc = ac.isNew ? [[NewAircraftViewController alloc] initWithAircraft:ac] : [[AircraftViewController alloc] initWithAircraft:ac];
    
    if (d != nil && [d conformsToProtocol:@protocol(AircraftViewControllerDelegate)])
        vc.delegate = (id<AircraftViewControllerDelegate>)d;
    return vc;
}
@end
