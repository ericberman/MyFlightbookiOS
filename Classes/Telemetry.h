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
//  Telemetry.h
//  MFBSample
//
//  Created by Eric Berman on 10/2/14.
//
//

#import <Foundation/Foundation.h>
#import "MFBAppDelegate.h"

typedef NS_ENUM(int, ImportedFileType) {GPX, KML, CSV, Unknown};

#define INFERRED_HERROR     5   // arbitrary value for HERROR
#define MIN_TIME_FOR_SPEED  4   // 4 seconds to derive speed

/* Abstract class */
@interface Telemetry : NSObject<NSXMLParserDelegate>

@property (strong, nonatomic) NSString * szRawData;
@property (strong, nonatomic) NSString * lastError;
@property (nonatomic) BOOL hasSpeed;

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithURL:(NSURL *) url;
- (instancetype) initWithString:(NSString *) sz;

- (NSArray *) samples;
+ (NSString *) serializeFromPath:(NSArray *) arSamples;
- (NSString *) serializeAs:(enum ImportedFileType) ft;
+ (enum ImportedFileType) typeFromURL:(NSURL *) url;
+ (Telemetry *) telemetryWithURL:(NSURL *) url;
@end

/* Concrete subclasses */
@interface KMLTelemetry : Telemetry

@end

@interface GPXTelemetry : Telemetry

@end

@interface CSVTelemetry : Telemetry

@end

@interface CLMutableLocation : NSObject

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithLatitude:(double) lat andLongitude:(double) lon;
- (CLLocation *) location;
- (void) addSpeed:(double) s;
- (void) addAlt:(double) a;
- (void) addTime:(NSDate *) d;
- (void) setInvalidLocation;
- (BOOL) isValidLocation;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) double altitude;
@property (nonatomic) double speed;
@property (nonatomic) double horizontalAccuracy;
@property (strong, nonatomic) NSDate * timeStamp;
@property (nonatomic) BOOL hasSpeed;
@property (nonatomic) BOOL hasAlt;
@property (nonatomic) BOOL hasTime;
@end

