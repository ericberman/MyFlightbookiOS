/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2023 MyFlightbook, LLC
 
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
//  AutodetectOptions.m
//  MFBSample
//
//  Created by Eric Berman on 2/7/10.
//

#import "AutodetectOptions.h"
#import "TextCell.h"
#import "MultiValOptionSelector.h"

@implementation AutodetectOptions

@synthesize idswAutoDetect, idswRecordFlight, idswRecordHighRes, idswTakeoffSpeed, idswUseHHMM, idswUseLocal, idswUseHeliports, idswMapOptions, idswRoundNearestTenth;
@synthesize cellAutoOptions, cellHHMM, cellLocalTime, cellHeliports, cellWarnings, cellTOSpeed, cellMapOptions, cellImages;
@synthesize colorPath, colorRoute, lblRoutePrompt, lblPathPrompt;
@synthesize txtWarnings;

enum prefSections {sectAutoFill, sectTimes, sectGPSWarnings, sectAutoOptions, sectCockpit, sectAirports, sectMaps, sectUnits, sectImages, sectOnlineSettings, sectLast};
enum prefRows {rowWarnings,
    rowAutoDetect, rowTOSpeed, rowNightFlightOptions, rowAutoHobbs, rowAutoTotal, rowLocal, rowHHMM, rowHeliports,
    rowTach, rowHobbs, rowEngine, rowBlock, rowFlight,
    rowMaps, rowUnitsSpeed, rowUnitsAlt, rowShowFlightImages, rowOnlineSettings, rowManageAccount, rowDeleteAccount };


#pragma mark - View Lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cellWarnings makeTransparent];
    self.txtWarnings.text = NSLocalizedString(@"AutodetectWarning", @"Autodetect Warning");
    self.lblRoutePrompt.text = self.colorRoute.title = NSLocalizedString(@"routeColorPrompt", @"Prompt to pick a color for the route of flight");
    self.lblPathPrompt.text = self.colorPath.title = NSLocalizedString(@"pathColorPrompt", @"Prompt to pick a color for the path of flight");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
	self.idswAutoDetect.on = UserPreferences.current.autodetectTakeoffs;
    self.idswRecordFlight.on = UserPreferences.current.recordTelemetry;
    self.idswRecordHighRes.on = UserPreferences.current.recordHighRes;
    self.idswUseHeliports.on = UserPreferences.current.includeHeliports;
    self.idswUseHHMM.on = UserPreferences.current.HHMMPref;
    self.idswUseLocal.on = UserPreferences.current.UseLocalTime;
    self.idswRoundNearestTenth.on = UserPreferences.current.roundTotalToNearestTenth;
    self.idswShowImages.on = UserPreferences.current.showFlightImages;
    self.idswShowFlightTimes.selectedSegmentIndex = UserPreferences.current.showFlightTimes;
    
    self.colorRoute.selectedColor = UserPreferences.current.routeColor;
    self.colorPath.selectedColor = UserPreferences.current.pathColor;
    
    self.idswTakeoffSpeed.selectedSegmentIndex = 0;
    NSInteger toCurrent = UserPreferences.current.TakeoffSpeed;
    for (int i = 0; i < UserPreferences.toSpeeds.count; i++)
        if (UserPreferences.toSpeeds[i].intValue == toCurrent)
            self.idswTakeoffSpeed.selectedSegmentIndex = i;
    self.idswMapOptions.selectedSegmentIndex = (int) UserPreferences.current.mapType;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [UserPreferences.current commit];
    [super viewWillDisappear:animated];
}

#pragma mark - Names for autofill
- (NSString *) autoFillHobbsName:(autoHobbs) i {
    switch (i) {
        case autoHobbsNone:
            return NSLocalizedString(@"Off", @"No auto-fill");
        case autoHobbsFlight:
            return NSLocalizedString(@"Flight Time", @"Auto-fill based on time in the air");
        case autoHobbsEngine:
            return NSLocalizedString(@"Engine Time", @"Auto-fill based on engine time");
        case autoHobbsInvalidLast:
            @throw [NSException exceptionWithName:@"Invalid use of autoHobbsInvalidLast" reason:@"invalidLast is reserved for enumerating enums" userInfo:nil];
    }
}

- (NSString *) autoFillTotalName:(autoTotal) i {
    switch (i) {
        case autoTotalNone:
            return NSLocalizedString(@"Off", @"No auto-fill");
        case autoTotalFlight:
            return NSLocalizedString(@"Flight Time", @"Auto-fill based on time in the air");
        case autoTotalEngine:
            return NSLocalizedString(@"Engine Time", @"Auto-fill based on engine time");
        case autoTotalHobbs:
            return NSLocalizedString(@"Hobbs Time", @"Auto-fill total based on hobbs time");
        case autoTotalBlock:
            return NSLocalizedString(@"Block Time", @"Auto-fill total based on block time");
        case autoTotalFlightStartToEngineEnd:
            return NSLocalizedString(@"FlightEngine Time", @"Auto-fill total based on flight start to engine shutdown");
        case autoTotalInvalidLast:
            @throw [NSException exceptionWithName:@"Invalid use of autoTotalInvalidLast" reason:@"invalidLast is reserved for enumerating enums" userInfo:nil];
    }
}

- (NSString *) altUnitName:(unitsAlt) i {
    switch (i) {
        case unitsAltMeters:
            return NSLocalizedString(@"UnitsMeters", @"Units - Meters");
        case unitsAltFeet:
            return NSLocalizedString(@"UnitsFeet", @"Units - Feet");
        case unitsAltInvalidLast:
            @throw [NSException exceptionWithName:@"Invalid use of unitsAltInvalidLast" reason:@"invalidLast is reserved for enumerating enums" userInfo:nil];
    }
}

- (NSString *) speedUnitName:(unitsSpeed) i {
    switch (i) {
        case unitsSpeedKts:
            return NSLocalizedString(@"UnitsKnots", @"Units - Knots");
        case unitsSpeedKph:
            return NSLocalizedString(@"UnitsKph", @"Units - KPH");
        case unitsSpeedMph:
            return NSLocalizedString(@"UnitsMph", @"Units - MPH");
        case unitsSpeedInvalidLast:
            @throw [NSException exceptionWithName:@"Invalid use of unitsSpeedInvalidLast" reason:@"invalidLast is reserved for enumerating enums" userInfo:nil];
    }
}

#pragma mark - tableViewDataSource
- (NSInteger) cellIDFromIndexPath:(NSIndexPath *)ip
{
    switch (ip.section)
    {
        case sectGPSWarnings:
            return rowWarnings;
        case sectAutoOptions:
            return rowAutoDetect + ip.row;
        case sectAutoFill:
            return rowAutoHobbs + ip.row;
        case sectTimes:
            return rowLocal + ip.row;
        case sectAirports:
            return rowHeliports;
        case sectCockpit:
            return rowTach + ip.row;
        case sectMaps:
            return rowMaps + ip.row;
        case sectOnlineSettings:
            return rowOnlineSettings + ip.row;
        case sectImages:
            return rowShowFlightImages;
        case sectUnits:
            return rowUnitsSpeed + ip.row;
        default:
            return 0;
    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case sectGPSWarnings:
            return 1;
        case sectAutoOptions:
            return 3;
        case sectAutoFill:
            return 2;
        case sectTimes:
            return 2;
        case sectCockpit:
            return 5;
        case sectAirports:
            return 1;
        case sectMaps:
            return 1;
        case sectOnlineSettings:
            return 3;
        case sectUnits:
            return 2;
        case sectImages:
            return 1;
        default:
            return 0;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectLast;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case sectAutoFill:
            return NSLocalizedString(@"Auto-Fill", @"Auto-Fill");;
        case sectTimes:
            return NSLocalizedString(@"Entering Times", @"Entering Times");
        case sectAirports:
            return NSLocalizedString(@"Nearest Airports", @"Nearest Airports");
        case sectCockpit:
            return NSLocalizedString(@"InTheCockpit", @"In-the-cockpit");
        case sectMaps:
            return NSLocalizedString(@"MapOptions", @"Maps");
        case sectOnlineSettings:
            return NSLocalizedString(@"OnlineSettingsExplanation", @"Explanation about additional functionality on MyFlightbook");
        case sectImages:
            return NSLocalizedString(@"ImageOptions", @"Image Options");
        case sectUnits:
            return NSLocalizedString(@"Units", @"Units - Section Header");
        case sectAutoOptions:
        case sectGPSWarnings:
        default:
            return @"";
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row)
    {
        case rowAutoDetect:
            return self.cellAutoOptions.frame.size.height;
        case rowTOSpeed:
            return self.cellTOSpeed.frame.size.height;
        case rowLocal:
            return self.cellLocalTime.frame.size.height;
        case rowHHMM:
            return self.cellHHMM.frame.size.height;
        case rowShowFlightImages:
            return self.cellImages.frame.size.height;
        case rowHeliports:
            return self.cellHeliports.frame.size.height;
        case rowWarnings:
        {
            CGSize size = [self.txtWarnings.text boundingRectWithSize:CGSizeMake(self.txtWarnings.frame.size.width
                                                                                 , 10000)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                         attributes:@{NSFontAttributeName:self.txtWarnings.font}
                                                            context:nil].size;
            self.txtWarnings.frame = CGRectMake(self.txtWarnings.frame.origin.x, self.txtWarnings.frame.origin.y, self.tableView.frame.size.width - 20, ceil(size.height));
            self.txtWarnings.text = self.txtWarnings.text;  // force a relayout
            return ceil(size.height + 20);  // account for margins on all sides + rounding.
        }
        case rowMaps:
            return self.cellMapOptions.frame.size.height;
        default:
            return UITableViewAutomaticDimension;
    }
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    if (row == rowWarnings) {
        self.txtWarnings.backgroundColor = [UIColor clearColor];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row)
    {
        case rowAutoDetect:
            return self.cellAutoOptions;
        case rowTOSpeed:
            return self.cellTOSpeed;
        case rowAutoTotal:
        case rowAutoHobbs: {
            static NSString * CellIdentifier = @"CellNormal2";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = (row == rowAutoHobbs) ? NSLocalizedString(@"Ending Hobbs", @"Option for auto-fill of ending Hobbs") : NSLocalizedString(@"Total Time", @"Option for auto-fill total time");
            cell.detailTextLabel.text = (row == rowAutoHobbs) ? [self autoFillHobbsName:UserPreferences.current.autoHobbsMode] : [self autoFillTotalName:UserPreferences.current.autoTotalMode];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case rowLocal:
            return self.cellLocalTime;
        case rowHHMM:
            return self.cellHHMM;
        case rowHeliports:
            return self.cellHeliports;
        case rowWarnings:
            return self.cellWarnings;
        case rowMaps:
            return self.cellMapOptions;
        case rowShowFlightImages:
            return self.cellImages;
        case rowOnlineSettings:
        case rowManageAccount:
        case rowDeleteAccount:
        case rowNightFlightOptions: {
            static NSString *CellIdentifier = @"CellNormal";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = (row == rowOnlineSettings) ? NSLocalizedString(@"AdditionalOptions", @"Link to additional preferences") :
                (row == rowManageAccount) ? NSLocalizedString(@"ManageAccount", @"Link to manage your account") :
                 (row == rowDeleteAccount) ? NSLocalizedString(@"DeleteAccount", @"Link to delete your account because Apple fucking sucks and requires it ") :
                  NSLocalizedString(@"NightOptions", @"Night Section");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case rowUnitsSpeed:
        case rowUnitsAlt: {
            static NSString * CellIdentifier = @"CellNormal3";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.textLabel.text = (row == rowUnitsSpeed) ? NSLocalizedString(@"UnitsSpeed", @"Units - Speed Header") : NSLocalizedString(@"UnitsAlt", @"Units - Altitude Header");
            cell.detailTextLabel.text = (row == rowUnitsSpeed) ? [self speedUnitName:UserPreferences.current.speedUnits] : [self altUnitName:UserPreferences.current.altitudeUnits];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case rowTach:
            return [self cockpitToggleCell:UserPreferences.current.showTach withLabel:NSLocalizedString(@"InTheCockpitTach", @"Cockpit: Tach")];
        case rowHobbs:
            return [self cockpitToggleCell:UserPreferences.current.showHobbs withLabel:NSLocalizedString(@"InTheCockpitHobbs", @"Cockpit: Hobbs")];
        case rowBlock:
            return [self cockpitToggleCell:UserPreferences.current.showBlock withLabel:NSLocalizedString(@"InTheCockpitBlock", @"Cockpit: Block")];
        case rowEngine:
            return [self cockpitToggleCell:UserPreferences.current.showEngine withLabel:NSLocalizedString(@"InTheCockpitEngine", @"Cockpit: Engine")];
        case rowFlight:
            return [self cockpitToggleCell:UserPreferences.current.showFlight withLabel:NSLocalizedString(@"InTheCockpitFlight", @"Cockpit: Flight")];
    }
    @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in AutodetectOptions with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
}

- (UITableViewCell *) cockpitToggleCell:(BOOL) isChecked withLabel: (NSString *) label {
    static NSString * CellIdentifier = @"CellCockpit";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.textLabel.text = label;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row)
    {
        case rowNightFlightOptions: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"NightOptions", @"Night Section");
            
            NSMutableArray<NSString *> * flightOptionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < nightFlightOptionsInvalidLast; i++)
                [flightOptionNames addObject:[MFBLocation nightFlightOptionName:i]];
            
            NSMutableArray<NSString *> * landingOptionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < nightLandingOptionsInvalidLast; i++)
                [landingOptionNames addObject:[MFBLocation nightLandingOptionName:i]];
                        
            mvos.optionGroups = @[
                                  [[OptionSelection alloc] initWithTitle:NSLocalizedString(@"NightFlightStarts", @"Night flight options") forOptionKey:UserPreferences.current.keyNightFlightPref options:flightOptionNames],
                                  [[OptionSelection alloc] initWithTitle:NSLocalizedString(@"NightLandingsStart", @"Night Landing options") forOptionKey:UserPreferences.current.keyNightLandingPref options:landingOptionNames]
                                  ];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowAutoHobbs: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"Ending Hobbs", @"Option for auto-fill of ending Hobbs");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < autoHobbsInvalidLast; i++)
                [optionNames addObject:[self autoFillHobbsName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:UserPreferences.current.szPrefAutoHobbs options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowAutoTotal: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"Total Time", @"Option for auto-fill total time");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < autoTotalInvalidLast; i++)
                [optionNames addObject:[self autoFillTotalName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:UserPreferences.current.szPrefAutoTotal options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowUnitsSpeed:{
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"UnitsSpeed", @"Units - Speed Header");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < unitsSpeedInvalidLast; i++)
                [optionNames addObject:[self speedUnitName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:UserPreferences.current.keySpeedUnitPref options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowUnitsAlt: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"UnitsAlt", @"Units - Altitude Header");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i < unitsAltInvalidLast; i++)
                [optionNames addObject:[self altUnitName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:UserPreferences.current.keyAltUnitPref options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowOnlineSettings:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mfbApp().userProfile authRedirForUser:@"d=profile"]] options:@{} completionHandler:nil];
            break;
        case rowManageAccount:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[mfbApp().userProfile authRedirForUser:@"d=account"]] options:@{} completionHandler:nil];
            break;
        case rowDeleteAccount: {
            // get the sign-out URL while still signed in...
            HostedWebViewController * vwWeb = [[HostedWebViewController alloc] initWithUrl:[mfbApp().userProfile authRedirForUser:@"d=bigredbuttons"]];
            
            // ...and then sign out in anticipation of deletion.
            MFBAppDelegate * app = mfbApp();
            app.userProfile.UserName = app.userProfile.Password = app.userProfile.AuthToken = @"";
            [app.userProfile clearCache];
            [app.userProfile clearOldUserContent];
            [app.userProfile SavePrefs];

            [self.navigationController pushViewController:vwWeb animated:YES];
        }
            break;
        case rowTach:
            UserPreferences.current.showTach = !UserPreferences.current.showTach;
            [self reload];
            break;
        case rowHobbs:
            UserPreferences.current.showHobbs = !UserPreferences.current.showHobbs;
            [self reload];
            break;
        case rowBlock:
            UserPreferences.current.showBlock = !UserPreferences.current.showBlock;
            [self reload];
            break;
        case rowEngine:
            UserPreferences.current.showEngine = !UserPreferences.current.showEngine;
            [self reload];
            break;
        case rowFlight:
            UserPreferences.current.showFlight = !UserPreferences.current.showFlight;
            [self reload];
            break;
        default:
            break;
    }
}

#pragma mark - Received Actions
- (IBAction) autoDetectClicked:(UISwitch *)sender {
    UserPreferences.current.autodetectTakeoffs = sender.on;
}

- (IBAction) recordFlightClicked:(UISwitch *)sender {
    UserPreferences.current.recordTelemetry = sender.on;
	mfbApp().mfbloc.fRecordFlightData = self.idswRecordFlight.on;
}

- (IBAction) recordHighResClicked:(UISwitch *)sender{
    UserPreferences.current.recordHighRes = sender.on;
    mfbApp().mfbloc.fRecordHighRes = sender.on;
}

- (IBAction) useHHMMClicked:(UISwitch *)sender {
    UserPreferences.current.HHMMPref = sender.on;
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.myflightbook.mfbapps"] setBool:sender.on forKey:UserPreferences.current.szPrefKeyHHMM];
}

- (IBAction) roundNearestTenthClicked:(UISwitch *) sender {
    UserPreferences.current.roundTotalToNearestTenth = sender.on;
}

- (IBAction) useLocalClicked:(UISwitch *)sender {
    UserPreferences.current.UseLocalTime = sender.on;
}

- (IBAction) useHeliportsChanged:(UISwitch *)sender {
    UserPreferences.current.includeHeliports = sender.on;
}

- (IBAction) takeOffSpeedCanged:(UISegmentedControl *)sender {
    UserPreferences.current.TakeoffSpeed = UserPreferences.toSpeeds[sender.selectedSegmentIndex].intValue;
    [MFBLocation refreshTakeoffSpeed];
}

- (IBAction) mapTypeChanged:(UISegmentedControl *)sender {
    UserPreferences.current.mapType = sender.selectedSegmentIndex;
}

- (IBAction) routeColorChanged:(UIColorWell *)sender {
    UserPreferences.current.routeColor = sender.selectedColor;
}

- (IBAction) pathColorChanged:(UIColorWell *)sender {
    UserPreferences.current.pathColor = sender.selectedColor;
}

- (IBAction) showImagesClicked:(UISwitch *) sender {
    UserPreferences.current.showFlightImages = sender.on;
}

- (IBAction)showFlightTimesClicked:(UISegmentedControl *)sender {
    UserPreferences.current.showFlightTimes = sender.selectedSegmentIndex;
}

@end
