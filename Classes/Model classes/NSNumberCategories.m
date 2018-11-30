/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018 MyFlightbook, LLC
 
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
//  NSNumberCategories.m
//  MyFlightbook
//
//  Created by Eric Berman on 11/29/18.
//

#import "NSNumberCategories.h"

@implementation NSNumber(MFBAdditions)

static NSNumberFormatter * _nf = nil;

- (NSString *) formatAsInteger {
    return [NSString stringWithFormat:@"%d", self.intValue];
}

- (NSString *) formatAsTime:(BOOL) fHHMM useGrouping:(BOOL) fGroup {
    if (fHHMM) {
        double val = self.doubleValue;
        val = round(val * 60.0) / 60.0; // fix any rounding by getting precise minute
        int hours = (int) trunc(val);
        int minutes = (int) round((val - hours) * 60);
        return [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    } else {
        if (_nf == nil)
        {
            _nf = [[NSNumberFormatter alloc] init];
            _nf.numberStyle = NSNumberFormatterDecimalStyle;
            _nf.maximumFractionDigits = 2;
            _nf.minimumFractionDigits = 1;
        }
        
        _nf.usesGroupingSeparator = fGroup; // necessary for round-trip.
        
        return [_nf stringFromNumber:self];
    }
}

- (NSString *) formatAsType:(int) nt inHHMM:(BOOL) fHHMM useGrouping:(BOOL) fGroup {
    switch (nt) {
        case ntInteger:
            return self.formatAsInteger;
        case ntTime:
            return [self formatAsTime:fHHMM useGrouping:fGroup];
        case ntDecimal:
            return [self formatAsTime:false useGrouping:fGroup];
    }
    return @"";
}

@end
