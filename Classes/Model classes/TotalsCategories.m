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
//  TotalsCategories.m
//  MyFlightbook
//
//  Created by Eric Berman on 11/29/18.
//

#import <Foundation/Foundation.h>
#import "TotalsCategories.h"
#import "NSNumberCategories.h"

@implementation MFBWebServiceSvc_TotalsItem (MFBToday)
- (NSString *) formattedValue:(BOOL) fHHMM {
    switch (self.NumericType)
    {
        default:
        case MFBWebServiceSvc_NumType_Integer:
            return [NSString stringWithFormat:@"%d", [self.Value intValue]];
            break;
        case MFBWebServiceSvc_NumType_Currency:
        {
            NSNumberFormatter * nsf = [[NSNumberFormatter alloc] init];
            [nsf setNumberStyle:NSNumberFormatterCurrencyStyle];
            return [nsf stringFromNumber:self.Value];
        }
            break;
        case MFBWebServiceSvc_NumType_Decimal:
            return [self.Value formatAsType:ntDecimal inHHMM:NO useGrouping:YES];
            break;
        case MFBWebServiceSvc_NumType_Time:
            return [self.Value formatAsType:ntTime inHHMM:fHHMM useGrouping:YES];
            break;
    }
}
@end
