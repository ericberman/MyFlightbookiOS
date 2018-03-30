/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018 MyFlightbook, LLC
 
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
//  NightFlight.m
//  MyFlightbook
//
//  Created by Eric Berman on 3/30/18.
//

#import "NightFlight.h"
#import "AutodetectOptions.h"
#import "OptionKeys.h"
#import "MFBLocation.h"

@interface NightFlight ()

@end

@implementation NightFlight

enum nightOptionSections { sectNightOptions, sectNightLandingOptions, sectLast };

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectLast;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case sectNightOptions:
            return nfoLast;
        case sectNightLandingOptions:
            return nflLast;
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case sectNightOptions:
            return NSLocalizedString(@"NightFlightStarts", @"Night flight options");
        case sectNightLandingOptions:
            return NSLocalizedString(@"NightLandingsStart", @"Night Landing options");
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellCheckmark";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if (indexPath.section == sectNightOptions) {
        cell.textLabel.text = [MFBLocation nightFlightOptionName:(NightFlightOptions) indexPath.row];
        cell.accessoryType = AutodetectOptions.nightFlightPref == indexPath.row ? UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone;
    } else {
        cell.textLabel.text = [MFBLocation nightLandingOptionName:(NightLandingOptions) indexPath.row];
        cell.accessoryType = AutodetectOptions.nightLandingPref == indexPath.row ? UITableViewCellAccessoryCheckmark :UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case sectNightOptions:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:keyNightFlightPref];
            [self.tableView reloadData];
            break;
        case sectNightLandingOptions:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:keyNightLandingPref];
            [self.tableView reloadData];
            break;
        default:
            break;
    }
}

@end
