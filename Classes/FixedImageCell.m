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
//  FixedImageCell.m
//  MFBSample
//
//  Created by Eric Berman on 6/10/12.
//  Copyright (c) 2012-2017 MyFlightbook LLC. All rights reserved.
//

#import "FixedImageCell.h"

@implementation FixedImageCell

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

#define MARGIN 3.0

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect f = self.contentView.frame;
    // x, y, width, height
    CGFloat dxWidth = f.size.height * 1.2;
    CGFloat dxHeight = f.size.height;
    
    CGFloat dxAccessory = 0;
    
    CGRect rImage = CGRectMake(MARGIN, 1.0, dxWidth - 2 * MARGIN, dxHeight - 1.0);
    self.imageView.frame = rImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat xLabels = rImage.origin.x + rImage.size.width + MARGIN;
    
    CGRect rText = CGRectMake(xLabels, self.textLabel.frame.origin.y, f.size.width - xLabels - dxAccessory - 2 * MARGIN, self.textLabel.frame.size.height);
    self.textLabel.frame = rText;
    
    CGRect rDetail = CGRectMake(xLabels, self.detailTextLabel.frame.origin.y, f.size.width - xLabels - dxAccessory -2 * MARGIN, self.detailTextLabel.frame.size.height);
    self.detailTextLabel.frame = rDetail;
}

@end
