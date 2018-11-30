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
//  CurrencyCategories.h
//  MFBSample
//
//  Created by Eric Berman on 11/29/18.
//

#import "MFBWebServiceSvc.h"

#ifndef CurrencyCategories_h
#define CurrencyCategories_h

@interface MFBWebServiceSvc_CurrencyStatusItem (MFBToday)
- (NSString *) formattedTitle;
@end

#endif /* CurrencyCategories_h */
