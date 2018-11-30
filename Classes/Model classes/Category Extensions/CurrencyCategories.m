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
//  CurrencyCategories.m
//  MyFlightbook
//
//  Created by Eric Berman on 11/29/18.
//

#import <Foundation/Foundation.h>
#import "CurrencyCategories.h"

@implementation MFBWebServiceSvc_CurrencyStatusItem (MFBToday)
- (NSString *) formattedTitle {
    // some attributes are hyperlinks.  Strip out the hyperlink part.
    NSRange range = [self.Attribute rangeOfString:@"<a href" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound)
    {
        NSCharacterSet * csHtmlTag = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
        NSArray * a = [self.Attribute componentsSeparatedByCharactersInSet:csHtmlTag];
        return [NSString stringWithFormat:@"%@%@", (NSString *) a[2], (NSString *) a[4]];
    }
    return self.Attribute;
}
@end
