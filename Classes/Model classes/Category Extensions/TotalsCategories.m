/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018-2020 MyFlightbook, LLC
 
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

- (NSString *) GroupName {
    switch (self.Group) {
        case MFBWebServiceSvc_TotalsGroup_None:
        case MFBWebServiceSvc_TotalsGroup_none:
            return NSLocalizedString(@"TotalsGroupNone", @"TotalsGroup None");
        default:
        case MFBWebServiceSvc_TotalsGroup_Properties:
            return NSLocalizedString(@"TotalsGroupProperties", @"TotalsGroup Properties");
        case MFBWebServiceSvc_TotalsGroup_ICAO:
            return NSLocalizedString(@"TotalsGroupICAO", @"TotalsGroup ICAO");
        case MFBWebServiceSvc_TotalsGroup_CategoryClass:
            return NSLocalizedString(@"TotalsGroupCategoryClass", @"TotalsGroup Category/Class");
        case MFBWebServiceSvc_TotalsGroup_Model:
            return NSLocalizedString(@"TotalsGroupModel", @"TotalsGroup Model");
        case MFBWebServiceSvc_TotalsGroup_Capabilities:
            return NSLocalizedString(@"TotalsGroupCapabilities", @"TotalsGroup Capabilities");
        case MFBWebServiceSvc_TotalsGroup_CoreFields:
            return NSLocalizedString(@"TotalsGroupCore", @"TotalsGroup CoreFields");
        case MFBWebServiceSvc_TotalsGroup_Total:
            return NSLocalizedString(@"TotalsGroupTotal", @"TotalsGroup Total");
    }
}

+ (NSArray<NSArray<MFBWebServiceSvc_TotalsItem *> *> *) GroupItems:(NSArray<MFBWebServiceSvc_TotalsItem *> *) totalsItems {
    NSMutableDictionary<NSNumber *, NSMutableArray<MFBWebServiceSvc_TotalsItem *> *> * d = [NSMutableDictionary new];
    for (MFBWebServiceSvc_TotalsItem * ti in totalsItems) {
        NSNumber * key = [NSNumber numberWithInt:(int) ti.Group];
        if (d[key] == nil)
            d[key] = [NSMutableArray<MFBWebServiceSvc_TotalsItem *> new];
        
        [d[key] addObject:ti];
    }
    
    NSMutableArray<NSArray<MFBWebServiceSvc_TotalsItem *> *> * result = [NSMutableArray new];
    for (int i = 0; i <= (int) MFBWebServiceSvc_TotalsGroup_Total; i++) {
        NSNumber * key = [NSNumber numberWithInt:i];
        if (d[key] != nil)
            [result addObject:d[key]];
    }
    return result;
}
@end
