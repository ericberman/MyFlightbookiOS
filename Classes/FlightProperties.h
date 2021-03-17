/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2021 MyFlightbook, LLC
 
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
//  FlightProperties.h
//  MFBSample
//
//  Created by Eric Berman on 7/8/10.
//  Copyright 2010-2021 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogbookEntry.h"
#import "FlightProps.h"
#import "MFBWebServiceSvc.h"
#import "MFBAppDelegate.h"
#import "PullRefreshTableViewController.h"
#import "AccessoryBar.h"

@protocol EditPropertyDelegate
- (void) propertyUpdated:(MFBWebServiceSvc_CustomPropertyType *) cpt;
- (void) dateOfFlightShouldReset:(NSDate *) dt;
@end

@interface FlightProperties : PullRefreshTableViewController <UITextFieldDelegate, AccessoryBarDelegate, UISearchBarDelegate> {
}

@property (strong, readwrite) LogbookEntry * le;
@property (strong, readwrite) IBOutlet UIDatePicker * datePicker;
@property (nonatomic, strong) IBOutlet UISearchBar * searchBar;
@property (nonatomic, strong) NSSet<MFBWebServiceSvc_PropertyTemplate *> * activeTemplates;
@property (nonatomic, strong) id<EditPropertyDelegate> delegate;
@end
