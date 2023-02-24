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
//  AutodetectOptions.h
//  MFBSample
//
//  Created by Eric Berman on 2/7/10.
//  Copyright 2010-2023 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBAppDelegate.h"
#import "CollapsibleTable.h"
#import "MFBLocation.h"

@interface AutodetectOptions : CollapsibleTable {
	UISwitch * idswAutoDetect;
	UISwitch * idswRecordFlight;
	UISegmentedControl * idswSegmentedHobbs;
	UISegmentedControl * idswSegmentedTotal;
}


@property (nonatomic, strong) IBOutlet UISwitch * idswAutoDetect;
@property (nonatomic, strong) IBOutlet UISwitch * idswRecordFlight;
@property (nonatomic, strong) IBOutlet UISwitch * idswRecordHighRes;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseHHMM;
@property (nonatomic, strong) IBOutlet UISwitch * idswRoundNearestTenth;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseLocal;
@property (nonatomic, strong) IBOutlet UISwitch * idswUseHeliports;
@property (nonatomic, strong) IBOutlet UISwitch * idswShowImages;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswShowFlightTimes;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswTakeoffSpeed;
@property (nonatomic, strong) IBOutlet UISegmentedControl * idswMapOptions;

@property (nonatomic, strong) IBOutlet UITableViewCell * cellAutoOptions;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellHHMM;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellLocalTime;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellHeliports;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellWarnings;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellTOSpeed;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellMapOptions;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellImages;
@property (nonatomic, strong) IBOutlet UILabel * txtWarnings;
@property (nonatomic, strong) IBOutlet UIColorWell * colorRoute;
@property (nonatomic, strong) IBOutlet UIColorWell * colorPath;
@property (nonatomic, strong) IBOutlet UILabel * lblPathPrompt;
@property (nonatomic, strong) IBOutlet UILabel * lblRoutePrompt;

- (IBAction) autoDetectClicked:(UISwitch *)sender;
- (IBAction) recordFlightClicked:(UISwitch *)sender;
- (IBAction) recordHighResClicked:(UISwitch *)sender;
- (IBAction) roundNearestTenthClicked:(UISwitch *) sender;
- (IBAction) useHHMMClicked:(UISwitch *)sender;
- (IBAction) useLocalClicked:(UISwitch *)sender;
- (IBAction) useHeliportsChanged:(UISwitch *)sender;
- (IBAction) takeOffSpeedCanged:(UISegmentedControl *)sender;
- (IBAction) mapTypeChanged:(UISegmentedControl *)sender;
- (IBAction) showImagesClicked:(UISwitch *) sender;
- (IBAction) showFlightTimesClicked:(UISegmentedControl *)sender;
- (IBAction) routeColorChanged:(UIColorWell *)sender;
- (IBAction) pathColorChanged:(UIColorWell *)sender;
@end
