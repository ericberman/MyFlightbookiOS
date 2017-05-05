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
//  CheckboxCell.m
//  MFBSample
//
//  Created by Eric Berman on 3/17/13.
//
//

#import "CheckboxCell.h"

@implementation CheckboxCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CheckboxCell *) getButtonCell:(UITableView *) tableView
{
    static NSString *CellTextIdentifier = @"cellCheckButton";
    CheckboxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[CheckboxCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
    }
    return cell;
}
@end
