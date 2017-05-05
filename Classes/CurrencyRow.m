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
//  CurrencyRow.m
//  MFBSample
//
//  Created by Eric Berman on 6/17/11.
//  Copyright 2011-2017 MyFlightbook LLC. All rights reserved.
//

#import "CurrencyRow.h"


@implementation CurrencyRow

@synthesize lblValue, lblDescription, lblDiscrepancy;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) AdjustLayoutForValues
{
    if ([self.lblDiscrepancy.text length] == 0)
    {
        CGFloat h = (self.lblDiscrepancy.frame.origin.y + self.lblDiscrepancy.frame.size.height) - self.lblValue.frame.origin.y;
        CGRect r = self.lblValue.frame;
        r.size = CGSizeMake(r.size.width, h);
        self.lblValue.frame = r;
    }
}

@end
