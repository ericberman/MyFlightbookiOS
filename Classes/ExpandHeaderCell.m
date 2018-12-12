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
//  ExpandHeaderCell.m
//  MFBSample
//
//  Created by Eric Berman on 5/27/12.
//  Copyright (c) 2012-2017 MyFlightbook LLC. All rights reserved.
//

#import "ExpandHeaderCell.h"
#import "MFBTheme.h"

@implementation ExpandHeaderCell

@synthesize HeaderLabel, ExpandCollapseLabel, isExpanded;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setExpanded:(BOOL) fExpanded
{
    if (isExpanded == fExpanded)
        return;
    
    isExpanded = fExpanded;

    if (self.ExpandCollapseLabel != nil)
        [UIView animateWithDuration:0.35f animations:^{
            self.ExpandCollapseLabel.transform = CGAffineTransformRotate(self.ExpandCollapseLabel.transform, fExpanded ? 3.14159265359 / 2.0 : -3.14159265359 / 2.0);
        }];
}

+ (ExpandHeaderCell *) getHeaderCell:(UITableView *) tableView withTitle:(NSString *) szTitle forSection:(NSInteger) section initialState:(BOOL) initExpanded
{
    static NSString *CellIdentifier = @"CellHeader";
    ExpandHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ExpandHeaderCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[ExpandHeaderCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [MFBTheme currentTheme].expandHeaderBackColor;
    cell.HeaderLabel.textColor = [MFBTheme currentTheme].expandHeaderTextColor;
    [MFBTheme.currentTheme applyThemedImageNamed:@"Collapsed.png" toImageView:cell.ExpandCollapseLabel];
    cell.HeaderLabel.text = szTitle;
    [cell setExpanded:initExpanded];
    return cell;
}
@end
