/*
*  EXFGPSLoc.m
 *  
 *
 *  Created by steve woodcock on 30/03/2008.
 *  Copyright 2008. All rights reserved.
 *
 * A set of fractions that represent the 3 rational numbers that make up the 
 * GPS Location. these are:
 * Degrees
 * Minutes
 * Seconds
 *
 * The EXF Specification suggests the location should be displayed as 3 rationals. ALthough we use fractions 
 * to actually represent any stored number without getting precision errors.
*/

#import "EXFGPS.h"
#import "EXFUtils.h"

@implementation EXFGPSLoc

@synthesize degrees;
@synthesize minutes;
@synthesize seconds;

-(NSString*) description{
    return [NSString stringWithFormat:@"%@\xC2\xB0 %@' %@\"",degrees, minutes,seconds];
}


-(double) descriptionAsDecimal{
                                return ((double)degrees.numerator/degrees.denominator) +(((double)minutes.numerator/ minutes.denominator)/60) + (((double)seconds.numerator /seconds.denominator)/3600) ;
}

-(void) dealloc{
    self.degrees =nil;
    self.minutes=nil;
    self.seconds =nil;
    
    [super dealloc];
}


// EXIF helper utilities, from http://iphone-land.blogspot.com
// Helper methods for location conversion
+(NSMutableArray*) createLocArray:(double) val{
    val = fabs(val);
    NSMutableArray* array = [[NSMutableArray alloc] init];
    double deg = (int)val;
    [array addObject:@(deg)];
    val = val - deg;
    val = val*60;
    double minutes = (int) val;
    [array addObject:@(minutes)];
    val = val - minutes;
    val = val *60;
    double seconds = val;
    [array addObject:@(seconds)];
    return array;
}

+(void) populateGPS: (EXFGPSLoc*)gpsLoc :(NSArray*) locArray{
    long numDenumArray[2];
    long* arrPtr = numDenumArray;
    [EXFUtils convertRationalToFraction:&arrPtr :locArray[0]];
    EXFraction* fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
    gpsLoc.degrees = fract;
    [EXFUtils convertRationalToFraction:&arrPtr :locArray[1]];
    fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
    gpsLoc.minutes = fract;
    [EXFUtils convertRationalToFraction:&arrPtr :locArray[2]];
    fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
    gpsLoc.seconds = fract;
}
// end of helper methods
@end

@implementation EXFGPSTimeStamp

@synthesize hours;
@synthesize minutes;
@synthesize seconds; 

-(NSString*) description{
    
                                NSString* hoursStr = [NSString stringWithFormat:@"%i", (int)(hours.numerator/hours.denominator)];
                                NSString* minutesStr = [NSString stringWithFormat:@"%i", (int)(minutes.numerator/minutes.denominator)];
                                NSString* secondsStr = [NSString stringWithFormat:@"%i", (int)(seconds.numerator/seconds.denominator)];
                                
                                if ([hoursStr length] ==1){
                                                                hoursStr =  [NSString stringWithFormat:@"0%@", hoursStr];
                                }
                                if ([minutesStr length] ==1){
                                                                minutesStr =  [NSString stringWithFormat:@"0%@", minutesStr];
                                }
                                if ([secondsStr length] ==1){
                                                                secondsStr =  [NSString stringWithFormat:@"0%@", secondsStr];
                                }
                                
                                                        
    return [NSString stringWithFormat:@"%@:%@:%@",hoursStr,minutesStr,secondsStr];
}

-(void) dealloc{
    self.hours =nil;
    self.minutes=nil;
    self.seconds =nil;
    
    [super dealloc];
}
@end
