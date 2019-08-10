/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019 MyFlightbook, LLC
 
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
//  ConjunctionCell.h
//  MyFlightbook
//
//  Created by Eric Berman on 8/6/19.
//

#import <UIKit/UIKit.h>
#import "MFBWebServiceSvc.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConjunctionCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UISegmentedControl * segConjunction;
@property (nonatomic, readwrite) MFBWebServiceSvc_GroupConjunction conjunction;

+ (ConjunctionCell *) getConjunctionCell:(UITableView *) tableView withConjunction:(MFBWebServiceSvc_GroupConjunction) conj;
@end

NS_ASSUME_NONNULL_END
