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
//  DateRangeViewController.h
//  MFBSample
//
//  Created by Eric Berman on 3/11/13.
//
//

#import <UIKit/UIKit.h>
#import "AccessoryBar.h"

@protocol DateRangeChanged
- (void) setStartDate:(NSDate *) dtStart andEndDate:(NSDate *) dtEnd;
@end

@interface DateRangeViewController : UITableViewController<UITextFieldDelegate, AccessoryBarDelegate>

@property (nonatomic, strong) id<DateRangeChanged> delegate;
@property (nonatomic, strong) NSDate * dtStart;
@property (nonatomic, strong) NSDate * dtEnd;
@property (nonatomic, strong) IBOutlet UIDatePicker * vwDatePicker;

- (IBAction) dateChanged:(UIDatePicker *) sender;
@end
