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
//  AutodetectOptions.h
//  MFBSample
//
//  Created by Eric Berman on 2/7/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBAppDelegate.h"
#import "CollapsibleTable.h"

@interface AutodetectOptions : CollapsibleTable {
	UISwitch * idswAutoDetect;
	UISwitch * idswRecordFlight;
	UISegmentedControl * idswSegmentedHobbs;
	UISegmentedControl * idswSegmentedTotal;
}

enum autoHobbs {
	autoHobbsNone = 0, autoHobbsFlight, autoHobbsEngine
};
enum autoTotal {autoTotalNone = 0, autoTotalFlight, autoTotalEngine, autoTotalHobbs};

@property (nonatomic, strong) IBOutlet UISwitch * idswAutoDetect;
@property (nonatomic, strong) IBOutlet UISwitch * idswRecordFlight;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseHHMM;
@property (nonatomic, strong) IBOutlet UISwitch * idswRoundNearestTenth;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseLocal;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseHeliports;
@property (nonatomic, strong) IBOutlet UISwitch * idswShowImages;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswTakeoffSpeed;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswSegmentedHobbs;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswSegmentedTotal;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswMapOptions;

@property (nonatomic, strong) IBOutlet UITableViewCell * cellAutoOptions;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellAutoHobbs;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellAutoTotal;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellHHMM;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellLocalTime;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellHeliports;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellWarnings;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellTOSpeed;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellMapOptions;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellImages;
@property (nonatomic, strong) IBOutlet UITextView * txtWarnings;

- (IBAction) autoDetectClicked:(UISwitch *)sender;
- (IBAction) recordFlightClicked:(UISwitch *)sender;
- (IBAction) roundNearestTenthClicked:(UISwitch *) sender;
- (IBAction) useHHMMClicked:(UISwitch *)sender;
- (IBAction) useLocalClicked:(UISwitch *)sender;
- (IBAction) useHeliportsChanged:(UISwitch *)sender;
- (IBAction) autoHobbsChanged:(UISegmentedControl *)sender;
- (IBAction) autoTotalChanged:(UISegmentedControl *)sender;
- (IBAction) takeOffSpeedCanged:(UISegmentedControl *)sender;
- (IBAction) mapTypeChanged:(UISegmentedControl *)sender;
- (IBAction) showImagesClicked:(UISwitch *) sender;

+ (int) autoTotalMode;
+ (BOOL) roundTotalToNearestTenth;
+ (int) autoHobbsMode;
+ (int) TakeoffSpeed;
+ (BOOL) HHMMPref;
+ (BOOL) UseLocalTime;
+ (BOOL) autodetectTakeoffs;
+ (BOOL) recordTelemetry;
+ (BOOL) includeHeliports;
+ (BOOL) showFlightImages;
+ (MKMapType) mapType;
@end
