/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  PropertyCell.h
//  MFBSample
//
//  Created by Eric Berman on 3/3/13.
//
//

#import <UIKit/UIKit.h>
#import "MFBAppDelegate.h"
#import "NavigableCell.h"

@interface PropertyCell : NavigableCell <UITextFieldDelegate, CAAnimationDelegate>

@property (nonatomic, strong) IBOutlet UILabel * lbl;
@property (nonatomic, strong) IBOutlet UILabel * lblDescription;
@property (nonatomic, strong) IBOutlet UIView * lblDescriptionBackground;
@property (nonatomic, strong) IBOutlet UITextField * txt;
@property (nonatomic, strong) IBOutlet UIImageView * imgLocked;
@property (nonatomic, strong) IBOutlet UIButton * btnShowDescription;
@property (nonatomic, strong) MFBWebServiceSvc_CustomFlightProperty * cfp;
@property (nonatomic, strong) MFBWebServiceSvc_CustomPropertyType * cpt;
@property (nonatomic, strong) FlightProps * flightPropDelegate;
- (IBAction) dateChanged:(UIDatePicker *)sender;
- (IBAction) showDescription:(id)sender;
- (void) setNoText;
+ (PropertyCell *) getPropertyCell:(UITableView *) tableView withCPT:(MFBWebServiceSvc_CustomPropertyType *) cpt andFlightProperty:(MFBWebServiceSvc_CustomFlightProperty *) cfp;
- (void) styleLabelAsDefault:(BOOL) fIsDefault;
- (void) configureCell:(UIView *) vwAcc andDatePicker:(UIDatePicker *) dp defValue:(NSNumber *) num;
- (BOOL) handleClick;
- (BOOL) handleTextUpdate:(UITextField *) textField;
- (BOOL) prepForEditing;
@end
