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
//  ButtonCell.m
//  MFBSample
//
//  Created by Eric Berman on 3/16/13.
//
//

#import "ButtonCell.h"

@implementation ButtonCell

@synthesize btn;

- (void) setTransparent
{
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setTransparent];
    }
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self setTransparent];
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self setTransparent];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (ButtonCell *) getButtonCell:(UITableView *) tableView
{
    static NSString *CellTextIdentifier = @"cellButton";
    ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ButtonCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[ButtonCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
    }
    return cell;
}

@end
