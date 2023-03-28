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
//  SwiftConversionHackBridge.h
//  MFBSample
//
//  Created by Eric Berman on 3/28/23.
//

#ifndef SwiftConversionHackBridge_h
#define SwiftConversionHackBridge_h
#import "MFBWebServiceSvc.h"

@interface SwiftConversionHackBridge : NSObject
+ (UIViewController *_Nonnull) recentFlightsWithQuery: ( MFBWebServiceSvc_FlightQuery * _Nonnull ) fq;
+ (UIViewController *_Nonnull) aircraftDetailsWithAircraft: (MFBWebServiceSvc_Aircraft * _Nonnull) ac;
@end

#endif /* SwiftConversionHackBridge_h */
