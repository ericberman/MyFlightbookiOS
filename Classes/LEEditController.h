/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2019 MyFlightbook, LLC
 
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
//  LEEditController
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//  Copyright-2019 MyFlightbook LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogbookEntryBaseTableViewController.h"
#import "LogbookEntry.h"
#import "MFBProfile.h"
#import "NearbyAirports.h"
#import "CommentedImage.h"
#import "AutodetectOptions.h"
#import "MyAircraft.h"
#import "GPSSim.h"
#import "SunriseSunset.h"
#import "CollapsibleTable.h"
#import "FlightProperties.h"

@interface LEEditController : LogbookEntryBaseTableViewController <NearbyAirportsDelegate, EditPropertyDelegate, AutoDetectDelegate, UIAlertViewDelegate, UIPickerViewDataSource, TotalsCalculatorDelegate> {
}

// Cockpit view IBActions
- (IBAction) viewClosest;
- (IBAction) autofillClosest;
- (IBAction) toggleFlightPause;
- (IBAction) newAircraft;
- (IBAction)dateChanged:(UIDatePicker *)sender;

- (NSTimeInterval) elapsedTime;

- (void) startEngineExternal;
- (void) stopEngineExternal;
- (void) stopEngineExternalNoSubmit;

- (BOOL) autoTotal;
- (BOOL) autoHobbs;

- (void) saveState;
@end
