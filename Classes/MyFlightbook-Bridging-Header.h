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
//  MyFlightbook-Bridging-Header.h
//  MFBSample
//
//  Created by Eric Berman on 6/1/16.
//
//

#ifndef MyFlightbook_Bridging_Header_h
#define MyFlightbook_Bridging_Header_h

//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

// Cached credentials, aircraft durations
typedef enum _cacheStatus {cacheInvalid, cacheValid, cacheValidButRefresh} CacheStatus;

#ifdef DEBUG
// 2 minute cache lifetime in debug
#define CACHE_LIFETIME (60 * 2)
// but after 30 seconds, attempt a refresh
#define CACHE_REFRESH (30)
#define EXF_LOGGING NO

// iRATE values:
#define MIN_IRATE_EVENTS    2
#define MIN_IRATE_DAYS  0.01
#define MIN_IRATE_USES  4
#else
// 14 day lifetime in retail
#define CACHE_LIFETIME (3600 * 24 * 14)
// Cache is valid for 2 weeks, but we will attempt refreshes after 3 days
#define CACHE_REFRESH (3600 * 24 * 3)
#define EXF_LOGGING NO
#define MIN_IRATE_EVENTS    5
#define MIN_IRATE_DAYS      10
#define MIN_IRATE_USES      10
#endif

#define MFBFLIGHTIMAGEUPLOADPAGE @"/logbook/public/uploadpicture.aspx"
#define MFBAIRCRAFTIMAGEUPLOADPAGE @"/logbook/public/uploadairplanepicture.aspx?id=1"
#define MFBAIRCRAFTIMAGEUPLOADPAGENEW @"/logbook/public/uploadairplanepicture.aspx"
#define MFB_KEYFLIGHTIMAGE @"idFlight"
#define MFB_KEYAIRCRAFTIMAGE @"txtAircraft"

#define MPS_TO_KNOTS 1.94384449
#define KTS_TO_KPH 1.852
#define KTS_TO_MPH 1.15078
#define METERS_TO_FEET 3.2808399
#define METERS_IN_A_NM 1852.0
#define NM_IN_A_METER 0.000539956803
#define DEG2RAD(degrees) (degrees * 0.0174532925199433) // degrees * pi over 180

// Distance for Cross-country Flight (in NM)
#define CROSS_COUNTRY_THRESHOLD 50.0

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "MFBWebServiceSvc.h"
#import "NSDate+ISO8601Unparsing.h"
#import "NSDate+ISO8601Parsing.h"
#import "SharedWatch.h"
#import "HostName.h"
#import "SwiftHackBridge.h"
#import "ApiKeys.h"
#endif /* MyFlightbook_Bridging_Header_h */
