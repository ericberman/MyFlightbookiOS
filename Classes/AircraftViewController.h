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
//  AircraftViewController.h
//  MFBSample
//
//  Created by Eric Berman on 3/19/13.
//
//

#import <UIKit/UIKit.h>
#import "MFBAppDelegate.h"
#import "CommentedImage.h"
#import "AccessoryBar.h"
#import "CollapsibleTable.h"

@protocol AircraftViewControllerDelegate
- (void) aircraftListChanged;
@end

@interface AircraftViewController : CollapsibleTable<UIPickerViewDataSource, UIPickerViewDelegate, AccessoryBarDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIDatePicker * datePicker;
@property (nonatomic, strong) IBOutlet UIPickerView * picker;
@property (nonatomic, strong) id<AircraftViewControllerDelegate> delegate;

- (void) setAircraft:(MFBWebServiceSvc_Aircraft *)aircraft;
@end
