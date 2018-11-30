/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2011-2018 MyFlightbook, LLC
 
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
//  CurrencyRow.h
//  MFBSample
//
//  Created by Eric Berman on 6/17/11.
//  Copyright 2011-2017 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBWebServiceSvc.h"


@interface CurrencyRow : UITableViewCell {
    UILabel * lblDescription;
    UILabel * lblValue;
    UILabel * lblDiscrepancy;
}

@property (nonatomic, strong) IBOutlet UILabel * lblDescription;
@property (nonatomic, strong) IBOutlet UILabel * lblValue;
@property (nonatomic, strong) IBOutlet UILabel * lblDiscrepancy;

+ (CurrencyRow *) rowForCurrency:(MFBWebServiceSvc_CurrencyStatusItem *) ci forTableView:tableView;

@end

@interface MFBWebServiceSvc_CurrencyStatusItem (MFBToday)
- (NSString *) formattedTitle;
@end
