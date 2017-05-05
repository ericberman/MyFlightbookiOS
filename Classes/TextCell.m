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
//  TextCell.m
//  MFBSample
//
//  Created by Eric Berman on 3/17/13.
//
//

#import "TextCell.h"
#import "Util.h"

@implementation TextCell
@synthesize txt;

- (void) makeTransparent
{
    self.txt.backgroundColor = [UIColor clearColor];
    [super makeTransparent];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


+ (TextCell *) getTextCell:(UITableView *) tableView
{
    static NSString *CellTextIdentifier = @"CellTextID";
    TextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TextCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[TextCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

+ (TextCell *) getTextCellTransparent:(UITableView *) tableView
{
    TextCell * tc = [TextCell getTextCell:tableView];
    [tc makeTransparent];
    return tc;
}
@end
