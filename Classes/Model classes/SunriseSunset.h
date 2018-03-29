/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2018 MyFlightbook, LLC
 
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
//  SunriseSunset.h
//  MFBSample
//
//  Created by Eric Berman on 8/15/11.
//  Copyright 2011-2018 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface SunriseSunset : NSObject {
    BOOL isCivilNight;
    double solarAngle;
}

@property (nonatomic, strong) NSDate * Sunrise;
@property (nonatomic, strong) NSDate * Sunset;
@property (nonatomic, readwrite) double Latitude;
@property (nonatomic, readwrite) double Longitude;
@property (nonatomic, strong) NSDate * Date;
@property (nonatomic, readwrite) BOOL isNight;
@property (nonatomic, readwrite) BOOL isFAANight;
@property (nonatomic, readwrite) BOOL isCivilNight;
@property (nonatomic, readwrite) BOOL isWithinNightOffset;
@property (nonatomic, readwrite) int NightLandingOffset;
@property (nonatomic, readwrite) int NightFlightOffset;
@property (nonatomic, readwrite) double solarAngle;

- (SunriseSunset *) initWithDate:(NSDate *) dt Latitude:(double) latitude Longitude:(double) longitude nightOffset:(int) nightOffset NS_DESIGNATED_INITIALIZER;
- (void) ComputeTimesAtLocation:(NSDate *) dt;

@end
