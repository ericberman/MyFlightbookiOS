/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2018 MyFlightbook, LLC
 
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
//  Copyright 2010-2018 MyFlightbook LLC. All rights reserved.
//

#import "AutodetectOptions.h"
#import "TextCell.h"

#define szPrefAutoHobbs @"prefKeyAutoHobbs"
#define szPrefAutoTotal @"prefKeyAutoTotal"
#define szPrefKeyHHMM @"keyUseHHMM"
#define szPrefKeyRoundNearestTenth  @"keyRoundNearestTenth"
#define keyPrefSuppressUTC @"keySuppressUTC"
#define _szKeyPrefTakeOffSpeed @"keyPrefTakeOffSpeed"
#define keyIncludeHeliports @"keyIncludeHeliports"
#define keyMapMode @"keyMappingMode"
#define keyShowImages @"keyShowImages"
#define keyShowFlightTimes @"keyShowFlightTimes"
#define keyNightFlightPref @"keyNightFlightPref"
#define keyNightLandingPref @"keyNightLandingPref"

@implementation AutodetectOptions

@synthesize idswAutoDetect, idswRecordFlight, idswRecordHighRes, idswSegmentedHobbs, idswSegmentedTotal, idswTakeoffSpeed, idswUseHHMM, idswUseLocal, idswUseHeliports, idswMapOptions, idswRoundNearestTenth;
@synthesize cellAutoHobbs, cellAutoOptions, cellAutoTotal, cellHHMM, cellLocalTime, cellHeliports, cellWarnings, cellTOSpeed, cellMapOptions, cellImages;
@synthesize txtWarnings;

enum prefSections {sectAutoFill, sectTimes, sectGPSWarnings, sectAutoOptions, sectNightOptions, sectNightLandingOptions, sectAirports, sectMaps, sectImages, sectOnlineSettings, sectLast};
enum prefRows {rowWarnings, rowAutoDetect, rowTOSpeed, rowAutoHobbs, rowAutoTotal, rowLocal, rowHHMM, rowHeliports, rowMaps, rowShowFlightImages, rowOnlineSettings, rowNightFlightOptions, rowNightLandingOptions};

static int toSpeeds[] = {20, 40, 55, 70, 85, 100};

#pragma mark - View Lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.cellWarnings makeTransparent];
    [self.cellAutoHobbs makeTransparent];
    [self.cellAutoTotal makeTransparent];
    self.txtWarnings.text = NSLocalizedString(@"AutodetectWarning", @"Autodetect Warning");
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.idswAutoDetect = self.idswRecordFlight = self.idswRecordHighRes = self.idswUseHHMM = self.idswUseLocal = self.idswUseHeliports = self.idswRoundNearestTenth = nil;
	self.idswSegmentedHobbs = self.idswSegmentedTotal = self.idswTakeoffSpeed = self.idswMapOptions = nil;
    self.cellLocalTime = self.cellHHMM = self.cellAutoTotal = self.cellAutoOptions = self.cellTOSpeed = self.cellAutoHobbs = self.cellHeliports = self.cellWarnings = self.cellImages = nil;
    self.cellTOSpeed = self.cellMapOptions = nil;
    self.txtWarnings = nil;
    [super viewDidUnload];
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
    self.idswShowFlightTimes.on = [AutodetectOptions showFlightTimes];
    
    self.idswTakeoffSpeed.selectedSegmentIndex = 0;
    int toCurrent = [AutodetectOptions TakeoffSpeed];
    for (int i = 0; i < (sizeof(toSpeeds)/sizeof(int)); i++)
        if (toSpeeds[i] == toCurrent)
            self.idswTakeoffSpeed.selectedSegmentIndex = i;
	self.idswSegmentedHobbs.selectedSegmentIndex = [AutodetectOptions autoHobbsMode];
	self.idswSegmentedTotal.selectedSegmentIndex = [AutodetectOptions autoTotalMode];
    self.idswMapOptions.selectedSegmentIndex = (int) [AutodetectOptions mapType];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super viewWillDisappear:animated];
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
            return rowOnlineSettings;
        case sectImages:
            return rowShowFlightImages;
        case sectNightOptions:
            return rowNightFlightOptions;
        case sectNightLandingOptions:
            return rowNightLandingOptions;
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
            return 2;
        case sectAutoFill:
            return 2;
        case sectTimes:
            return 2;
        case sectAirports:
            return 1;
        case sectMaps:
            return 1;
        case sectOnlineSettings:
            return 1;
        case sectImages:
            return 1;
        case sectNightOptions:
            return nfoLast;
        case sectNightLandingOptions:
            return nflLast;
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
        case sectNightOptions:
            return NSLocalizedString(@"NightFlightStarts", @"Night flight options");
        case sectNightLandingOptions:
            return NSLocalizedString(@"NightLandingsStart", @"Night Landing options");
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
        case rowAutoHobbs:
            return self.cellAutoHobbs.frame.size.height;
        case rowAutoTotal:
            return self.cellAutoTotal.frame.size.height;
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
            return ceil(size.height + 40);  // account for margins on all sides + rounding.
        }
        case rowMaps:
            return self.cellMapOptions.frame.size.height;
        default:
            return UITableViewAutomaticDimension;
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
        case rowAutoHobbs:
            return self.cellAutoHobbs;
        case rowAutoTotal:
            return self.cellAutoTotal;
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
        {
            static NSString *CellIdentifier = @"CellNormal";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"AdditionalOptions", @"Link to additional preferences");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case rowNightLandingOptions: {
            static NSString *CellIdentifier = @"CellCheckmark";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [MFBLocation nightLandingOptionName:indexPath.row];
            cell.accessoryType = [AutodetectOptions nightLandingPref] == indexPath.row ? UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone;
            return cell;
        }
        case rowNightFlightOptions:{
            static NSString *CellIdentifier = @"CellCheckmark";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [MFBLocation nightFlightOptionName:indexPath.row];
            cell.accessoryType = [AutodetectOptions nightFlightPref] == indexPath.row ? UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone;
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
        case rowNightLandingOptions:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:keyNightLandingPref];
            [self.tableView reloadData];
            break;
        case rowNightFlightOptions:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:keyNightFlightPref];
            [self.tableView reloadData];
            break;
        case rowOnlineSettings:
        {
            NSString * szURLTemplate = @"%@://%@/logbook/public/authredir.aspx?u=%@&p=%@&d=profile";
            NSString * szProtocol = @"https";
#ifdef DEBUG
            if ([MFBHOSTNAME hasPrefix:@"192."] || [MFBHOSTNAME hasPrefix:@"10."])
                szProtocol = @"http";
#endif
            MFBProfile * pf = mfbApp().userProfile;
            
            NSString * szURL = [NSString stringWithFormat:szURLTemplate,
                                szProtocol, MFBHOSTNAME, [pf.UserName stringByURLEncodingString], [pf.Password stringByURLEncodingString]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:szURL]];
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

- (IBAction) autoHobbsChanged:(UISegmentedControl *)sender;
{
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:szPrefAutoHobbs];
}

- (IBAction) autoTotalChanged:(UISegmentedControl *)sender
{
	[[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:szPrefAutoTotal];
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

- (IBAction)showFlightTimesClicked:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:!sender.on forKey:keyShowFlightTimes];
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

+ (int) autoHobbsMode
{
    return (int) [[NSUserDefaults standardUserDefaults] integerForKey:szPrefAutoHobbs];
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

+ (BOOL) showFlightTimes
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:keyShowFlightTimes];
}

+ (NightFlightOptions) nightFlightPref {
    return [[NSUserDefaults standardUserDefaults] integerForKey:keyNightFlightPref];
}

+ (NightLandingOptions) nightLandingPref {
    return [[NSUserDefaults standardUserDefaults] integerForKey:keyNightLandingPref];
}
@end
