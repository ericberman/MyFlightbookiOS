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
//  CountryCode.m
//  MFBSample
//
//  Created by Eric Berman on 11/7/14.
//
//

#import "CountryCode.h"
#import "MFBAppDelegate.h"
#import "Util.h"
#import <sqlite3.h>

@implementation CountryCode

@synthesize LocaleCode, CountryName, Prefix, ID;

static NSMutableArray * rgAllCountryCodes = nil;

- (instancetype) initFromRow:(sqlite3_stmt *) row
{
    if (self = [super init])
    {
        self.ID = sqlite3_column_int(row, 0);
        self.Prefix = [NSString stringFromCharsThatCouldBeNull:(char *) sqlite3_column_text(row, 1)];
        self.LocaleCode = [NSString stringFromCharsThatCouldBeNull:(char *) sqlite3_column_text(row, 2)];
        self.CountryName = [NSString stringFromCharsThatCouldBeNull:(char *) sqlite3_column_text(row, 3)];
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"%ld: %@ %@ %@", (long) self.ID, self.Prefix, self.LocaleCode, self.CountryName];
}

+ (NSArray *) AllCountryCodes
{
    if (rgAllCountryCodes != nil)
        return rgAllCountryCodes;

    rgAllCountryCodes = [[NSMutableArray alloc] init];
    sqlite3 * db = mfbApp().getdb;
    sqlite3_stmt * sqlCountryCodes = nil;
    if (sqlite3_prepare(db, [@"SELECT * FROM countrycodes " cStringUsingEncoding:NSASCIIStringEncoding], -1, &sqlCountryCodes, NULL) != SQLITE_OK)
        NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
    
    while (sqlite3_step(sqlCountryCodes) == SQLITE_ROW)
        [rgAllCountryCodes addObject:[[CountryCode alloc] initFromRow:sqlCountryCodes]];
    
    sqlite3_finalize(sqlCountryCodes);
    return rgAllCountryCodes;
}

+ (CountryCode *) BestGuessForLocale:(NSString *) locale
{
    NSArray * rg = [CountryCode AllCountryCodes];

    if (locale != nil && locale.length > 1)
    {
        for (CountryCode * cc in rg)
            if ([cc.LocaleCode compare:locale options:NSCaseInsensitiveSearch] == NSOrderedSame)
                return cc;
    }
    
    return rg[0];
}

+ (CountryCode *) BestGuessForCurrentLocale
{
    return [CountryCode BestGuessForLocale:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
}

// return the longest country code that is a prefix for the given tail number
+ (CountryCode *) BestGuessPrefixForTail:(NSString *) szTail
{
    CountryCode * result = nil;
    NSInteger maxLength = 0;
    
    NSArray * rg = [CountryCode AllCountryCodes];
    for (NSInteger i = [rg count] - 1; i >= 0; i--)
    {
        CountryCode * cc = ((CountryCode *) rg[i]);
        NSString * szPref = cc.Prefix;
        if ([szTail hasPrefix:szPref] && [szPref length] > maxLength)
        {
            result = cc;
            maxLength = [szPref length];
        }
    }
    
    return result;
}

@end
