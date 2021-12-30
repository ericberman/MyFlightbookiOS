/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2014-2021 MyFlightbook, LLC
 
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
//  Telemetry.m
//  MFBSample
//
//  Created by Eric Berman on 10/2/14.
//
//

#import "Telemetry.h"
#import "MFBAppDelegate.h"
#import "NSDate+ISO8601Parsing.h"
#import "NSDate+ISO8601Unparsing.h"

@implementation CLMutableLocation

@synthesize latitude, longitude, speed, altitude, timeStamp, horizontalAccuracy, hasAlt, hasSpeed, hasTime;

- (instancetype) init
{
    if (self = [super init]) {
        self.hasAlt = self.hasSpeed = self.hasTime = NO;
        [self setInvalidLocation];
        self.speed = self.altitude = 0;
        self.horizontalAccuracy = INFERRED_HERROR;
        self.timeStamp = nil;
    }
    return self;
}

- (instancetype) initWithLatitude:(double) lat andLongitude:(double) lon
{
    if (self = [self init])
    {
        self.latitude = lat;
        self.longitude = lon;
    }
    return self;
}

- (void) addSpeed:(double) s
{
    self.speed = s;
    self.hasSpeed = YES;
}

- (void) addAlt:(double) a
{
    self.altitude = a;
    self.hasAlt = YES;
}

- (void) addTime:(NSDate *) d
{
    self.timeStamp = d;
    self.hasTime = YES;
}

- (CLLocation *) location
{
    return [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(self.latitude, self.longitude) altitude:self.hasAlt ? self.altitude : 0 horizontalAccuracy:self.horizontalAccuracy
                                 verticalAccuracy:0 course:0 speed:self.hasSpeed ? self.speed : 0 timestamp:self.hasTime ? self.timeStamp : nil];
}

- (void) setInvalidLocation
{
    self.latitude = self.longitude = -200;
}

- (BOOL) isValidLocation
{
    return (fabs(self.latitude) <= 90 || fabs(self.longitude) <= 180);
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%.6f, %.6f, %@, %@, %@",
            self.latitude,
            self.longitude,
            self.hasAlt ? [NSString stringWithFormat:@"%.2fm", self.altitude] : @"No altitude",
            self.hasSpeed ? [NSString stringWithFormat:@"%.2fkts", self.speed] : @"No Speed",
            self.timeStamp ? [self.timeStamp ISO8601DateString] : @"No Timestamp"];
}
@end

@interface Telemetry()
@property (strong, nonatomic) NSMutableArray * samplesToReturn;
@property (strong, nonatomic) CLMutableLocation * locInProgress;
@property (strong, nonatomic) NSMutableString * elementInProgress;
@property (strong, nonatomic) NSNumberFormatter * numberFormatter;
@end

@implementation Telemetry

@synthesize szRawData, samplesToReturn, elementInProgress, locInProgress, hasSpeed, metaData;

#pragma mark - Initialization
- (instancetype) init
{
    if (self = [super init])
    {
        self.hasSpeed = NO;
        self.lastError = @"";
        self.metaData = [NSMutableDictionary new];
    }
    return self;
}

- (instancetype) initWithURL:(NSURL *)url
{
    if (self = [self init]) {
        self.szRawData = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (instancetype) initWithString:(NSString *)sz
{
    if (self = [self init]) {
        self.szRawData = sz;
    }
    return self;
}

#pragma mark - Abstract methods
- (NSArray *) samples
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (NSString *) serializeFromPath:(NSArray *) arSamples
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Class-level functions
+ (enum ImportedFileType) typeFromURL:(NSURL *) url
{
    enum ImportedFileType ft = Unknown;
    
    if (url.isFileURL)
    {
        NSString * szExt = url.absoluteString.uppercaseString.pathExtension;
        
        if ([szExt compare:@"GPX"] == NSOrderedSame)
            ft = GPX;
        else if ([szExt compare:@"KML"] == NSOrderedSame)
            ft = KML;
        else if ([szExt compare:@"CSV"] == NSOrderedSame)
            ft = CSV;
        else if ([szExt compare:@"NMEA"] == NSOrderedSame)
            ft = NMEA;
    }
    return ft;
}

+ (enum ImportedFileType) typeFromString:(NSString *) szTelemetry {
    if ([szTelemetry containsString:@"<gpx"])
        return GPX;
    if ([szTelemetry containsString:@"<kml"])
        return KML;
    if ([szTelemetry containsString:@"$GP"])
        return NMEA;
    
    return CSV;
}

+ (Telemetry *) telemetryWithURL:(NSURL *)url
{
    enum ImportedFileType ft = [Telemetry typeFromURL:url];
    
    switch (ft) {
        case GPX:
            return [[GPXTelemetry alloc] initWithURL:url];
        case KML:
            return [[KMLTelemetry alloc] initWithURL:url];
        case CSV:
            return [[CSVTelemetry alloc] initWithURL:url];
        case NMEA:
            return [[NMEATelemetry alloc] initWithURL:url];
        case Unknown:
        default:
            return nil;
    }
}

+ (Telemetry *) telemetryWithString:(NSString *) szTelemetry {
    enum ImportedFileType ft = [Telemetry typeFromString:szTelemetry];
    switch (ft) {
        case GPX:
            return [[GPXTelemetry alloc] initWithString:szTelemetry];
        case KML:
            return [[KMLTelemetry alloc] initWithString:szTelemetry];
        case CSV:
            return [[CSVTelemetry alloc] initWithString:szTelemetry];
        case NMEA:
            return [[NMEATelemetry alloc] initWithString:szTelemetry];
        case Unknown:
        default:
            return nil;
    }
}

#pragma mark - Synthetic Path
+ (CLLocation *) locationAtLat:(double) lat Lon:(double) lon Time:(NSDate *) dt Speed:(double) speed {
    CLLocationCoordinate2D coord;
    coord.latitude = lat;
    coord.longitude = lon;
    
    return [[CLLocation alloc] initWithCoordinate:coord altitude:0 horizontalAccuracy:INFERRED_HERROR verticalAccuracy:0 course:0 speed:speed timestamp:dt];
}

/*
 Returns a synthesized path between two points, even spacing, between the two timestamps.
         ///
         /// Can be used to estimate night flight, for example, or draw a great-circle path between two points.
         ///
         /// From http://www.movable-type.co.uk/scripts/latlong.html
         /// Formula:
         ///     a = sin((1−f)⋅δ) / sin δ
         ///     b = sin(f⋅δ) / sin δ
         ///     x = a ⋅ cos φ1 ⋅ cos λ1 + b ⋅ cos φ2 ⋅ cos λ2
         ///     y = a ⋅ cos φ1 ⋅ sin λ1 + b ⋅ cos φ2 ⋅ sin λ2
         ///     z = a ⋅ sin φ1 + b ⋅ sin φ2
         ///     φi = atan2(z, √x² + y²)
         ///     λi = atan2(y, x)
         /// where f is fraction along great circle route (f=0 is point 1, f=1 is point 2), δ is the angular distance d/R between the two points.
 */
+ (Telemetry *) synthesizePathFrom:(CLLocationCoordinate2D) fromLoc to:(CLLocationCoordinate2D)toLoc start:(NSDate *) dtStart end:(NSDate *) dtEnd {
    if ([NSDate isUnknownDate:dtEnd] || [NSDate isUnknownDate:dtStart] || [dtStart compare:dtEnd] != NSOrderedAscending)
        return nil;

    NSMutableArray<CLLocation *> * lst = [NSMutableArray new];

    double rlat1 = M_PI * (fromLoc.latitude / 180.0);
    double rlon1 = M_PI * (fromLoc.longitude / 180.0);
    double rlat2 = M_PI * (toLoc.latitude / 180.0);
    double rlon2 = M_PI * (toLoc.longitude / 180.0);

    double dLon = rlon2 - rlon1;

    double delta = atan2(sin(dLon) * cos(rlat2), cos(rlat1) * sin(rlat2) - sin(rlat1) * cos(rlat2) * cos(dLon));
    double sin_delta = sin(delta);

    // Compute path at 1-minute intervals, subtracting off one minute since we'll add a few "full-stop" samples below.
    NSTimeInterval ts = [dtEnd timeIntervalSinceDate:dtStart];
    double minutes = (ts / 60.0) - 1;

    if (minutes > 48 * 60 || minutes <= 0)  // don't do paths more than 48 hours, or negative times.
        return nil;

    CLLocation * clFrom = [[CLLocation alloc] initWithLatitude:fromLoc.latitude longitude:fromLoc.longitude];
    CLLocation * clTo = [[CLLocation alloc] initWithLatitude:toLoc.latitude longitude:toLoc.longitude];
    // We need to derive an average speed.  But no need to compute - just assume constant speed.  This is in nm
    double distanceM = [clFrom distanceFromLocation:clTo];
    double speedMS = distanceM / ts;    // distance in meters divided by time in seconds.  We know ts > 0 because of check for date order above
    double distanceNM = NM_IN_A_METER * distanceM;

    // low distance (< 1nm) is probably pattern work - just pick a decent speed.  If you actually go somewhere, then derive a speed.
    double speedKts = (distanceNM < 1.0) ? 150 : speedMS * MPS_TO_KNOTS;
        
    // Add a few stopped fields at the end to make it clear that there's a full-stop.  Separate them by a few seconds each.
    NSArray<CLLocation *> * rgPadding = @[
        [Telemetry locationAtLat:toLoc.latitude Lon:toLoc.longitude Time:[dtEnd dateByAddingTimeInterval:3] Speed:0.1],
        [Telemetry locationAtLat:toLoc.latitude Lon:toLoc.longitude Time:[dtEnd dateByAddingTimeInterval:6] Speed:0.1],
        [Telemetry locationAtLat:toLoc.latitude Lon:toLoc.longitude Time:[dtEnd dateByAddingTimeInterval:9] Speed:0.1]
    ];

    [lst addObject:[Telemetry locationAtLat:fromLoc.latitude Lon:fromLoc.longitude Time:dtStart Speed:0]];

    for (long minute = 0; minute <= minutes; minute++)
    {
        if (distanceNM < 1.0)
            [lst addObject:[Telemetry locationAtLat:fromLoc.latitude Lon:fromLoc.longitude Time:[dtStart dateByAddingTimeInterval:60*minute] Speed:speedKts]];
        else
        {
            double f = ((double)minute) / minutes;
            double a = sin((1.0 - f) * delta) / sin_delta;
            double b = sin(f * delta) / sin_delta;
            double x = a * cos(rlat1) * cos(rlon1) + b * cos(rlat2) * cos(rlon2);
            double y = a * cos(rlat1) * sin(rlon1) + b * cos(rlat2) * sin(rlon2);
            double z = a * sin(rlat1) + b * sin(rlat2);

            double rlat = atan2(z, sqrt(x * x + y * y));
            double rlon = atan2(y, x);

            double dlat = 180 * (rlat / M_PI);
            double dlon = 180 * (rlon / M_PI);
            [lst addObject:[Telemetry locationAtLat:dlat Lon:dlon Time:[dtStart dateByAddingTimeInterval:60*minute] Speed:speedKts]];
        }
    }
    
    [lst addObjectsFromArray:rgPadding];

    return [Telemetry telemetryWithString:[CSVTelemetry serializeFromPath:lst]];
}

#pragma mark - Conversion
- (NSString *) serializeAs:(enum ImportedFileType) ft
{
    switch (ft)
    {
        case GPX:
            if ([self isKindOfClass:[GPXTelemetry class]])
                return self.szRawData;
            else
                return [GPXTelemetry serializeFromPath:[self samples]];
        case KML:
            if ([self isKindOfClass:[KMLTelemetry class]])
                return self.szRawData;
            else
                return [KMLTelemetry serializeFromPath:[self samples]];
        case CSV:
            if ([self isKindOfClass:[CSVTelemetry class]])
                return self.szRawData;
            else
                return [CSVTelemetry serializeFromPath:[self samples]];
        case Unknown:
        default:
            return @"";
    }
}

#pragma mark - NSXMLParser
- (NSMutableArray *) parse
{
    self.samplesToReturn = [NSMutableArray new];
    NSXMLParser * xmlp = [[NSXMLParser alloc] initWithData:[self.szRawData dataUsingEncoding:NSUTF8StringEncoding]];
    xmlp.delegate = self;
    
    // Subclass must implement the actual handling.
    if ([xmlp parse])
        return self.samplesToReturn;
    else
        return nil;
}

- (void) initLocationInProgress
{
    self.elementInProgress = nil;
    self.locInProgress = [[CLMutableLocation alloc] init];
}

// Compute speed in m/s, if needed.
- (void) computeSpeed
{
    if (self.locInProgress.speed <= 0 && self.locInProgress.hasTime && [self.locInProgress isValidLocation] && self.samplesToReturn.count > 0)
    {
        CLLocation * cl = nil;
        double t = 0;
        // Find the reference sample to use - since timestamps in GPX/KML have only whole-second resolution, go back at least MIN_TIME_FOR_SPEED to find a sample to use.
        for (long i = (long) self.samplesToReturn.count - 1; i >= 0; i--)
        {
            cl = (CLLocation *) self.samplesToReturn[i];
            if (cl.timestamp != nil)
            {
                double t2 = [self.locInProgress.timeStamp timeIntervalSinceDate:cl.timestamp];
                if (t2 >= MIN_TIME_FOR_SPEED)
                {
                    t = t2;
                    break;
                }
            }
        }
        
        if (t > 0)
        {
            double dist = [cl distanceFromLocation:[[CLLocation alloc] initWithLatitude:self.locInProgress.latitude longitude:self.locInProgress.longitude]];
            double speed = dist / t;
            [self.locInProgress addSpeed:speed];
            self.hasSpeed = YES;
        }
    }
}

+ (NSNumberFormatter *) getPosixNumberFormatter
{
    NSNumberFormatter * nf = [NSNumberFormatter new];
    [nf setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    return nf;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    [self initLocationInProgress];
    self.numberFormatter = [Telemetry getPosixNumberFormatter];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    self.numberFormatter = nil;
    self.locInProgress = nil;
    self.elementInProgress = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (self.elementInProgress == nil)
        self.elementInProgress = [[NSMutableString alloc] initWithString:string];
    else
        [self.elementInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.lastError = [NSString stringWithFormat:@"%@: %@ (%@)", parseError.localizedDescription, parseError.localizedFailureReason, parseError.localizedRecoverySuggestion];
    NSLog(@"ERROR: %@", self.lastError);
}
@end

NS_ENUM(int, KMLArrayContext) {None, Accuracy, Speed};

@interface KMLTelemetry ()
@property (strong, nonatomic) NSCharacterSet * tupleDelimiters;
@end

@implementation KMLTelemetry

@synthesize tupleDelimiters;

int currentGXValueIndex;
BOOL fHasTrack;
enum KMLArrayContext currentContext;

- (instancetype) init
{
    if (self = [super init])
    {
        currentContext = None;
        currentGXValueIndex = 0;
        fHasTrack = NO;
        self.tupleDelimiters = [NSCharacterSet characterSetWithCharactersInString:@" ,"];
    }
    return self;
}

- (NSArray *) samples
{
    fHasTrack = NO; // assume no track, yet.
    [self parse];
    // self.samplesToReturn now has CLMutableLocations, NOT CLLocations.
    // Need to do a speed check
    NSArray * rgMutableLocations = self.samplesToReturn;
    self.samplesToReturn = [NSMutableArray new];
    BOOL fNeedsSpeed = !self.hasSpeed;  // save this value since computing the 1st speed modifies self.hasSpeed
    for (CLMutableLocation * cml in rgMutableLocations) {
        if (fNeedsSpeed)
        {
            self.locInProgress = cml;
            [self computeSpeed];
        }
        [self.samplesToReturn addObject:cml.location];
    }
    self.locInProgress = nil;
    
    return self.samplesToReturn;
}

- (BOOL) parseTuple:(NSString *) sz
{
    NSArray * rgLine = [sz componentsSeparatedByCharactersInSet:self.tupleDelimiters];
    if (rgLine.count < 2)
        return NO;
    self.locInProgress.longitude = [self.numberFormatter numberFromString:rgLine[0]].doubleValue;
    self.locInProgress.latitude = [self.numberFormatter numberFromString:rgLine[1]].doubleValue;
    if (rgLine.count >= 3)
        [self.locInProgress addAlt:[self.numberFormatter numberFromString:rgLine[2]].doubleValue];
    return YES;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    self.elementInProgress = nil;
    if ([elementName compare:@"gx:SimpleArrayData"] == NSOrderedSame)
    {
        currentContext = None;
        currentGXValueIndex = 0;
        NSString * szDataType = (NSString *) attributeDict[@"name"];
        if ([szDataType compare:@"speedKts"] == NSOrderedSame)
            currentContext = Speed;
        else if ([szDataType compare:@"accuracyHorizontal"] == NSOrderedSame)
            currentContext = Accuracy;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Case #1: basic KML just has coordinates element - lame, because no speed is possible.
    if ([elementName compare:@"coordinates" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        if (fHasTrack)  // we've seen a gx:track element - don't parse the placemark coordinates!!!
            return;

        // This is a set of space-delimited tuples of longitude, latitude, altitude
        NSArray * rgLines = [[self.elementInProgress stringByReplacingOccurrencesOfString:@"\r" withString:@""] componentsSeparatedByString:@"\n"];
        
        for (NSString * sz in rgLines) {
            if ([self parseTuple:sz]) {
                [self.samplesToReturn addObject:self.locInProgress];
                [self initLocationInProgress];
            }
        }
    }
    // Case #2 (preferred)
    else if ([elementName compare:@"when" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        [self.locInProgress addTime:[NSDate dateWithISO8601String:self.elementInProgress]];
    else if ([elementName compare:@"gx:coord" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        fHasTrack = YES;
        if ([self parseTuple:self.elementInProgress])
            [self.samplesToReturn addObject:self.locInProgress];
        else
            NSLog(@"Error reading tuple: %@", self.elementInProgress);
        // set up for the next sample
        [self initLocationInProgress];
    }
    else if ([elementName compare:@"gx:value"] == NSOrderedSame)
    {
        if (currentGXValueIndex < self.samplesToReturn.count)
        {
            CLMutableLocation * cml = (CLMutableLocation *) self.samplesToReturn[currentGXValueIndex++];
            switch (currentContext)
            {
                case Accuracy:
                    {
                    double acc = [self.numberFormatter numberFromString:self.elementInProgress].doubleValue;
                    cml.horizontalAccuracy = (acc == 0) ? INFERRED_HERROR : acc;
                    }
                    break;
                case Speed:
                {
                    double speedInKts = [self.numberFormatter numberFromString:self.elementInProgress].doubleValue;
                    [cml addSpeed:speedInKts / MPS_TO_KNOTS];
                    self.hasSpeed = YES;
                }
                default:
                    break;
            }
        }
    }
    else if ([elementName compare:@"gx:SimpleArrayData"] == NSOrderedSame)
    {
        currentContext = None;
        currentGXValueIndex = 0;
    }
}

+ (NSString *) serializeFromPath:(NSArray *)arSamples
{
    // Hack - this is brute force writing, not proper generation of XML.  But it works...
    // We are also assuming valid timestamps (i.e., we're using gx:Track)
    NSMutableString * szKML = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">"
                            "<Document>\r\n<open>1</open>\r\n<visibility>1</visibility>\r\n<Placemark>\r\n\r\n<gx:Track>\r\n<extrude>1</extrude>\r\n<altitudeMode>absolute</altitudeMode>\r\n"];
    
    NSNumberFormatter * nf = [Telemetry getPosixNumberFormatter];
    for (CLLocation * cl in arSamples)
        [szKML appendFormat:@"<when>%@</when>\r\n<gx:coord>%@ %@ %@</gx:coord>\r\n",
         [cl.timestamp ISO8601DateString], [nf stringFromNumber:@(cl.coordinate.longitude)], [nf stringFromNumber:@(cl.coordinate.latitude)], [nf stringFromNumber:@(cl.altitude)]];

    [szKML appendString:@"</gx:Track></Placemark></Document></kml>"];
    return szKML;
}
@end

@implementation GPXTelemetry
- (NSArray *) samples
{
    return self.parse;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    self.elementInProgress = nil;
    if ([elementName compare:@"trkpt" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [self initLocationInProgress];
        NSString * szLat = attributeDict[@"lat"];
        NSString * szLon = attributeDict[@"lon"];
        
        if (szLat != nil && szLon != nil)
        {
            self.locInProgress.latitude = [self.numberFormatter numberFromString:szLat].doubleValue;
            self.locInProgress.longitude = [self.numberFormatter numberFromString:szLon].doubleValue;
        }
    } else if ([elementName compare:@"name" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        NSString * szTail = attributeDict[TELEMETRY_META_AIRCRAFT_TAIL];
        if (szTail != nil && szTail.length > 0)
            self.metaData[TELEMETRY_META_AIRCRAFT_TAIL] = szTail;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([self.locInProgress isValidLocation])
    {
        if ([elementName compare:@"trkpt" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            // Close it out!
            [self computeSpeed];
            [self.samplesToReturn addObject:self.locInProgress.location];
        }
        else
        {
            if ([elementName compare:@"time" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                [self.locInProgress addTime:[NSDate dateWithISO8601String:self.elementInProgress]];
            else if ([elementName compare:@"ele" options:NSCaseInsensitiveSearch] == NSOrderedSame)
                [self.locInProgress addAlt:[self.numberFormatter numberFromString:self.elementInProgress].doubleValue];
            else if ([elementName compare:@"speed" options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                [self.locInProgress addSpeed:[self.numberFormatter numberFromString:self.elementInProgress].doubleValue];
                self.hasSpeed = YES;
            }
            else if ([elementName compare:@"badelf:speed" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [self.locInProgress addSpeed:[self.numberFormatter numberFromString:self.elementInProgress].doubleValue];
                self.hasSpeed = YES;
            }
            else if ([elementName compare:@"acc_horiz"] == NSOrderedSame)
                self.locInProgress.horizontalAccuracy = [self.numberFormatter numberFromString:self.elementInProgress].doubleValue;
        }
    }
}

+ (NSString *) serializeFromPath:(NSArray *)arSamples
{
    // Hack - this is brute force writing, not proper generation of XML.  But it works...
    NSMutableString * szGPX = [NSMutableString stringWithString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<gpx creator=\"http://myflightbook.com\" version=\"1.1\" xmlns=\"http://www.topografix.com/GPX/1/1\">" ];
    [szGPX appendString:@"\r\n<trk>\r\n\t\t<name />\r\n\t\t<trkseg>]"];
    
    NSString * szFmtTrackPoint = @"\r\n\t\t\t<trkpt lat=\"%8f\" lon=\"%.8f\">\r\n\t\t\t\t<ele>%.8f</ele>\r\n\t\t\t\t<time>%@</time>\r\n\t\t\t\t<speed>%.4f</speed>\r\n\t\t\t</trkpt>";
    
    NSDateFormatter * df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // gpx > trk > trkseg > trkpt
    for (CLLocation * cl in arSamples)
        [szGPX appendFormat:szFmtTrackPoint, cl.coordinate.latitude, cl.coordinate.longitude, cl.altitude, [df stringFromDate:cl.timestamp], cl.speed];
    
    [szGPX appendString:@"\r\n\t\t</trkseg>\r\n\t</trk>\r\n</gpx>"];
    
    return szGPX;
}
@end

@implementation CSVTelemetry

- (NSArray *) samples
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    // get an array of lines
    NSArray * rgLines = [[self.szRawData stringByReplacingOccurrencesOfString:@"\r" withString:@""] componentsSeparatedByString:@"\n"];
    
    NSMutableArray * ar = [NSMutableArray new];
    
    int iLine = 0;
    
    for (NSString * sz in rgLines) {
        NSArray * rgLine = [sz componentsSeparatedByString:@","];
        
        if ([rgLine count] < 6)
            continue;
        
        // skip the header line
        if (iLine++ == 0)
            continue;
        
        double Latitude = ((NSString *) rgLine[0]).doubleValue;
        double Longitude = ((NSString *) rgLine[1]).doubleValue;
        double Altitude = ((NSString *) rgLine[2]).doubleValue;
        double Speed = ((NSString *) rgLine[3]).doubleValue / MPS_TO_KNOTS;
        double HError = ((NSString *) rgLine[4]).doubleValue;
        NSDate * dt = [df dateFromString:(NSString *) rgLine[5]];
        // NSString * Comment = (NSString *) [rgLine objectAtIndex:6];
        
        // NSLog(@"%d: Lat=%.8f, Lon=%.8f, Alt=%.1f, Speed=%.1f, Err=%.0f, date=%s\n", ++iSample, Latitude, Longitude, Altitude, Speed, HError, [(NSString *) [rgLine objectAtIndex:5] UTF8String]);
        
        CLLocationCoordinate2D coord;
        coord.latitude = Latitude;
        coord.longitude = Longitude;
        
        CLLocation * loc = [[CLLocation alloc] initWithCoordinate:coord altitude:Altitude horizontalAccuracy:HError verticalAccuracy:HError
                                                           course:0 speed:Speed timestamp:dt];
        
        [ar addObject:loc];
    }
    
    self.hasSpeed = YES;
    
    return ar;
}

+ (NSString *) serializeFromPath:(NSArray *)arSamples
{
    NSMutableString * sz = [[NSMutableString alloc] initWithString:@"LAT,LON,PALT,SPEED,HERROR,DATE\r\n"];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    for (CLLocation * cl in arSamples)
    {
        [sz appendFormat:@"%.8F,%.8F,%d,%.1F,%.1F,%@\r\n",
         cl.coordinate.latitude,
         cl.coordinate.longitude,
         (int) (cl.altitude * METERS_TO_FEET),
         cl.speed,
         cl.horizontalAccuracy,
         [df stringFromDate:cl.timestamp]];
    }
    
    return sz;
}

@end

@implementation NMEATelemetry
- (NSArray *) samples {
    NSMutableArray<CLLocation *> * results = [NSMutableArray new];
    
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSArray<NSString *> * sentences = [self.szRawData componentsSeparatedByCharactersInSet:separator];

    double lastAltitudeSeen = 0.0;
    self.hasSpeed = NO;
    for (NSString * sentence in sentences) {
        NSObject * result = [NMEAParser parseSentence:sentence];
        if (result != nil && [result isKindOfClass:[CLMutableLocation class]]) {
            CLMutableLocation * loc = (CLMutableLocation *) result;
            if (loc.hasAlt)
                lastAltitudeSeen = loc.altitude;    // GPGGA has altitude, but not date or speed; just take altitude here and wait for the GPRMC.
            else {
                self.hasSpeed = self.hasSpeed || loc.hasSpeed;
                [loc addAlt:lastAltitudeSeen];
                [results addObject:loc.location];
            }
        }
    }
    
    return results;
}
@end

@implementation NMEASatelliteStatus
@synthesize HDOP, VDOP, PDOP, satellites, Mode;

- (instancetype) init {
    if (self = [super init]) {
        self.VDOP = self.HDOP = self.PDOP = 0;
        self.satellites = [NSMutableSet new];
        self.Mode = @"";
    }
    return self;
}
@end

@implementation NMEAParser
+ (CLMutableLocation *) parseGPRMC:(NSArray<NSString *> *) words {
    if (words.count < 12)
        return nil;
    
    // UTC Time in hhmmss
    if (words[1].length < 6)
        return nil;
    int hour = [words[1] substringWithRange:NSMakeRange(0, 2)].intValue;
    int min = [words[1] substringWithRange:NSMakeRange(2, 2)].intValue;
    int sec = [words[1] substringWithRange:NSMakeRange(4, 2)].intValue;
    int day = [words[9] substringWithRange:NSMakeRange(0, 2)].intValue;
    int month = [words[9] substringWithRange:NSMakeRange(2, 2)].intValue;
    int year = [words[9] substringWithRange:NSMakeRange(4, 2)].intValue + 2000;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:year];
    [dateComponents setMonth:month];
    [dateComponents setDay:day];
    [dateComponents setHour:hour];
    [dateComponents setMinute:min];
    [dateComponents setSecond:sec];
    [dateComponents setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    if ([words[2] compare:@"A" options:NSCaseInsensitiveSearch] != NSOrderedSame)
        return nil;
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    nf.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    double lat = [words[3] substringWithRange:NSMakeRange(0, 2)].intValue + [nf numberFromString:[words[3] substringFromIndex:2]].doubleValue / 60.0;
    if ([words[4] compare:@"S" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        lat = -lat;
    double lon = [words[5] substringWithRange:NSMakeRange(0,3)].intValue + [nf numberFromString:[words[5] substringFromIndex:3]].doubleValue / 60.0;
    if ([words[6] compare:@"W" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        lon = -lon;
    double speed = [nf numberFromString:words[7]].doubleValue;
    
    CLMutableLocation * loc = [[CLMutableLocation alloc] initWithLatitude:lat andLongitude:lon];
    [loc addSpeed:speed];
    [loc addTime:date];
    
    return loc;
}

+ (CLMutableLocation *) parseGPGGA:(NSArray<NSString *> *) words {
    if (words.count < 15)
        return nil;
    
    // UTC Time in hhmmss
    if (words[1].length < 6)
        return nil;
    int hour = [words[1] substringWithRange:NSMakeRange(0, 2)].intValue;
    int min = [words[1] substringWithRange:NSMakeRange(2, 2)].intValue;
    int sec = [words[1] substringWithRange:NSMakeRange(4, 2)].intValue;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSDateComponents *compsNow = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate nowInUTC]];
    [dateComponents setYear:compsNow.year];
    [dateComponents setMonth:compsNow.month];
    [dateComponents setDay:compsNow.day];
    [dateComponents setHour:hour];
    [dateComponents setMinute:min];
    [dateComponents setSecond:sec];
    [dateComponents setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [calendar dateFromComponents:dateComponents];
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    nf.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    double lat = [words[2] substringWithRange:NSMakeRange(0, 2)].intValue + [nf numberFromString:[words[2] substringFromIndex:2]].doubleValue / 60.0;
    if ([words[3] compare:@"S" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        lat = -lat;
    double lon = [words[4] substringWithRange:NSMakeRange(0,3)].intValue + [nf numberFromString:[words[4] substringFromIndex:3]].doubleValue / 60.0;
    if ([words[5] compare:@"W" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        lon = -lon;
    double alt = [nf numberFromString:words[9]].doubleValue;
    
    CLMutableLocation * loc = [[CLMutableLocation alloc] initWithLatitude:lat andLongitude:lon];
    [loc addAlt:alt];
    [loc addTime:date];
    
    return loc;
}

+ (NMEASatelliteStatus * ) parseGPGSA:(NSArray<NSString *> *) words {
    if (words.count < 18)
        return nil;
    
    NMEASatelliteStatus * status = [NMEASatelliteStatus new];
    switch (words[2].integerValue) {
        case 1:
            status.Mode = @"No fix";
            break;
        case 2:
            status.Mode = @"2-D";
            break;
        case 3:
            status.Mode = @"3-D";
            break;
        default:
            status.Mode = @"";
    }
    
    for (int i = 3; i <= 14; i++) {
        if (words[i].length > 0)
            [status.satellites addObject:[NSNumber numberWithInteger:i]];
    }
    
    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
    nf.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];

    status.PDOP = [nf numberFromString:words[15]].doubleValue;
    status.HDOP = [nf numberFromString:words[16]].doubleValue;
    
    NSString * szVDOP = words[17];
    NSRange r = [szVDOP rangeOfString:@"*"];
    if (r.location != NSNotFound)
        szVDOP = [szVDOP substringToIndex:r.location];
    status.VDOP = [nf numberFromString:szVDOP].doubleValue;
    
    return status;
}

+ (NSObject *) parseSentence:(NSString *) sentence {
    if (sentence == nil || ![sentence hasPrefix:@"$GP"])
        return nil;
    
    NSArray<NSString *> * words = [sentence componentsSeparatedByString:@","];
    
    if ([sentence hasPrefix:@"$GPRMC"]) {
        return [NMEAParser parseGPRMC:words];
    } else if ([sentence hasPrefix:@"$GPGGA"]) {
        return [NMEAParser parseGPGGA:words];
    } else if ([sentence hasPrefix:@"$GPGSA"]) {
        return [NMEAParser parseGPGSA:words];
    }
    
    return nil;
}
@end
