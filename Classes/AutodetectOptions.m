/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2022 MyFlightbook, LLC
 
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
#import "OptionKeys.h"
#import "TextCell.h"
#import "MultiValOptionSelector.h"
#import "HostedWebViewViewController.h"

@implementation AutodetectOptions

@synthesize idswAutoDetect, idswRecordFlight, idswRecordHighRes, idswTakeoffSpeed, idswUseHHMM, idswUseLocal, idswUseHeliports, idswMapOptions, idswRoundNearestTenth;
@synthesize cellAutoOptions, cellHHMM, cellLocalTime, cellHeliports, cellWarnings, cellTOSpeed, cellMapOptions, cellImages;
@synthesize txtWarnings;

enum prefSections {sectAutoFill, sectTimes, sectGPSWarnings, sectAutoOptions, sectAirports, sectMaps, sectUnits, sectImages, sectOnlineSettings, sectLast};
enum prefRows {rowWarnings, rowAutoDetect, rowTOSpeed, rowNightFlightOptions, rowAutoHobbs, rowAutoTotal, rowLocal, rowHHMM, rowHeliports, rowMaps, rowUnitsSpeed, rowUnitsAlt, rowShowFlightImages, rowOnlineSettings, rowManageAccount, rowDeleteAccount };

static int toSpeeds[] = {20, 40, 55, 70, 85, 100};

#pragma mark - View Lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cellWarnings makeTransparent];
    self.txtWarnings.text = NSLocalizedString(@"AutodetectWarning", @"Autodetect Warning");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
	self.idswAutoDetect.on = [AutodetectOptions autodetectTakeoffs];
    self.idswRecordFlight.on = [AutodetectOptions recordTelemetry];
    self.idswRecordHighRes.on = [AutodetectOptions recordHighRes];
    self.idswUseHeliports.on = [AutodetectOptions includeHeliports];
    self.idswUseHHMM.on = [AutodetectOptions HHMMPref];
    self.idswUseLocal.on = [AutodetectOptions UseLocalTime];
    self.idswRoundNearestTenth.on = [AutodetectOptions roundTotalToNearestTenth];
    self.idswShowImages.on = [AutodetectOptions showFlightImages];
    self.idswShowFlightTimes.selectedSegmentIndex = [AutodetectOptions showFlightTimes];
    
    self.idswTakeoffSpeed.selectedSegmentIndex = 0;
    int toCurrent = [AutodetectOptions TakeoffSpeed];
    for (int i = 0; i < (sizeof(toSpeeds)/sizeof(int)); i++)
        if (toSpeeds[i] == toCurrent)
            self.idswTakeoffSpeed.selectedSegmentIndex = i;
    self.idswMapOptions.selectedSegmentIndex = (int) [AutodetectOptions mapType];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    }
}

- (NSString *) altUnitName:(unitsAlt) i {
    switch (i) {
        case altUnitMeters:
            return NSLocalizedString(@"UnitsMeters", @"Units - Meters");
        case altUnitFt:
            return NSLocalizedString(@"UnitsFeet", @"Units - Feet");
    }
}

- (NSString *) speedUnitName:(unitsSpeed) i {
    switch (i) {
        case speedUnitKts:
            return NSLocalizedString(@"UnitsKnots", @"Units - Knots");
        case speedUnitKph:
            return NSLocalizedString(@"UnitsKph", @"Units - KPH");
        case speedUnitMph:
            return NSLocalizedString(@"UnitsMph", @"Units - MPH");
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
            cell.detailTextLabel.text = (row == rowAutoHobbs) ? [self autoFillHobbsName:AutodetectOptions.autoHobbsMode] : [self autoFillTotalName:AutodetectOptions.autoTotalMode];
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
            cell.detailTextLabel.text = (row == rowUnitsSpeed) ? [self speedUnitName:AutodetectOptions.speedUnits] : [self altUnitName:AutodetectOptions.altitudeUnits];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            
    }
    @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in AutodetectOptions with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
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
            for (int i = nfoCivilTwilight; i < nfoLast; i++)
                [flightOptionNames addObject:[MFBLocation nightFlightOptionName:i]];
            
            NSMutableArray<NSString *> * landingOptionNames = [[NSMutableArray alloc] init];
            for (int i = nflSunsetPlus60; i < nflLast; i++)
                [landingOptionNames addObject:[MFBLocation nightLandingOptionName:i]];
                        
            mvos.optionGroups = @[
                                  [[OptionSelection alloc] initWithTitle:NSLocalizedString(@"NightFlightStarts", @"Night flight options") forOptionKey:keyNightFlightPref options:flightOptionNames],
                                  [[OptionSelection alloc] initWithTitle:NSLocalizedString(@"NightLandingsStart", @"Night Landing options") forOptionKey:keyNightLandingPref options:landingOptionNames]
                                  ];
            
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowAutoHobbs: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"Ending Hobbs", @"Option for auto-fill of ending Hobbs");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i <= autoHobbsLast; i++)
                [optionNames addObject:[self autoFillHobbsName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:szPrefAutoHobbs options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowAutoTotal: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"Total Time", @"Option for auto-fill total time");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i <= autoTotalLast; i++)
                [optionNames addObject:[self autoFillTotalName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:szPrefAutoTotal options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowUnitsSpeed:{
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"UnitsSpeed", @"Units - Speed Header");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i <= speedUnitLast; i++)
                [optionNames addObject:[self speedUnitName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:keySpeedUnitPref options:optionNames]];
            [self.navigationController pushViewController:mvos animated:YES];
        }
            break;
        case rowUnitsAlt: {
            MultiValOptionSelector * mvos = [[MultiValOptionSelector alloc] init];
            mvos.title = NSLocalizedString(@"UnitsAlt", @"Units - Altitude Header");
            NSMutableArray<NSString *> * optionNames = [[NSMutableArray alloc] init];
            for (int i = 0; i <= altUnitLast; i++)
                [optionNames addObject:[self altUnitName:i]];
            mvos.optionGroups = @[[[OptionSelection alloc] initWithTitle:@"" forOptionKey:keyAltUnitPref options:optionNames]];
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
            HostedWebViewViewController * vwWeb = [[HostedWebViewViewController alloc] initWithURL:[mfbApp().userProfile authRedirForUser:@"d=bigredbuttons"]];
            
            // ...and then sign out in anticipation of deletion.
            MFBAppDelegate * app = mfbApp();
            app.userProfile.UserName = app.userProfile.Password = app.userProfile.AuthToken = @"";
            [app.userProfile clearCache];
            [app.userProfile clearOldUserContent];
            [app.userProfile SavePrefs];

            [self.navigationController pushViewController:vwWeb animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Received Actions
- (IBAction) autoDetectClicked:(UISwitch *)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:_szKeyPrefAutoDetect];
}

- (IBAction) recordFlightClicked:(UISwitch *)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:_szKeyPrefRecordFlightData];
	mfbApp().mfbloc.fRecordFlightData = self.idswRecordFlight.on;
}

- (IBAction) recordHighResClicked:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:_szKeyPrefRecordHighRes];
    mfbApp().mfbloc.fRecordHighRes = sender.on;
}

- (IBAction) useHHMMClicked:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:szPrefKeyHHMM];
    [[[NSUserDefaults alloc] initWithSuiteName:@"group.com.myflightbook.mfbapps"] setBool:sender.on forKey:szPrefKeyHHMM];
}

- (IBAction) roundNearestTenthClicked:(UISwitch *) sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:szPrefKeyRoundNearestTenth];
}

- (IBAction) useLocalClicked:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:keyPrefSuppressUTC];
}

- (IBAction) useHeliportsChanged:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:keyIncludeHeliports];
}

- (IBAction) takeOffSpeedCanged:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:toSpeeds[sender.selectedSegmentIndex] forKey:_szKeyPrefTakeOffSpeed];
    [MFBLocation refreshTakeoffSpeed];
}

- (IBAction) mapTypeChanged:(UISegmentedControl *)sender
{
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex + 1 forKey:keyMapMode];
}

- (IBAction) showImagesClicked:(UISwitch *) sender
{
    [[NSUserDefaults standardUserDefaults] setBool:!sender.on forKey:keyShowImages];
}

- (IBAction)showFlightTimesClicked:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:keyShowFlightTimes];
}

#pragma mark - GetCurrentSettings
+ (BOOL) HHMMPref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:szPrefKeyHHMM];
}

+ (BOOL) UseLocalTime
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyPrefSuppressUTC];
}

+ (int) TakeoffSpeed
{
    int i = (int) [[NSUserDefaults standardUserDefaults] integerForKey:_szKeyPrefTakeOffSpeed];
    return (i == 0) ? toSpeeds[2] : i;
}

+ (int) autoTotalMode
{
    return (int) [[NSUserDefaults standardUserDefaults] integerForKey:szPrefAutoTotal];
}

+ (int) autoHobbsMode
{
    return (int) [[NSUserDefaults standardUserDefaults] integerForKey:szPrefAutoHobbs];
}

+ (BOOL) roundTotalToNearestTenth
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:szPrefKeyRoundNearestTenth];
}

+ (BOOL) autodetectTakeoffs
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefAutoDetect];
}

+ (BOOL) recordTelemetry
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefRecordFlightData];
}

+ (BOOL) recordHighRes
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:_szKeyPrefRecordHighRes];
}

+ (BOOL) includeHeliports
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:keyIncludeHeliports];
}

+ (MKMapType) mapType
{
    int i = (int) [[NSUserDefaults standardUserDefaults] integerForKey:keyMapMode] - 1;
    if (i < 0)
        return MKMapTypeHybrid;
    else
        return (MKMapType) i;
}

+ (BOOL) showFlightImages
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:keyShowImages];
}

+ (flightTimeDetail) showFlightTimes
{
    return (flightTimeDetail) [[NSUserDefaults standardUserDefaults] integerForKey:keyShowFlightTimes];
}

+ (NightFlightOptions) nightFlightPref {
    return [[NSUserDefaults standardUserDefaults] integerForKey:keyNightFlightPref];
}

+ (NightLandingOptions) nightLandingPref {
    return [[NSUserDefaults standardUserDefaults] integerForKey:keyNightLandingPref];
}

+ (unitsSpeed) speedUnits {
    return [NSUserDefaults.standardUserDefaults integerForKey:keySpeedUnitPref];
}
+ (unitsAlt) altitudeUnits {
    return [NSUserDefaults.standardUserDefaults integerForKey:keyAltUnitPref];
}

@end
