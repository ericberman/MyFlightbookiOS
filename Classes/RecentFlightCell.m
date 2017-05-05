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
//  RecentFlightCell.m
//  MFBSample
//
//  Created by Eric Berman on 1/14/12.
//  Copyright (c) 2012-2017 MyFlightbook LLC. All rights reserved.
//

#import "RecentFlightCell.h"

@implementation RecentFlightCell

@synthesize imgHasPics, imgSigState, lblComments, lblRoute, lblTitle;

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
    
    if (self.imgHasPics.hidden) {
        dxWidth = MARGIN;
        dxHeight = 0;
    }
    CGRect rImage = CGRectMake(MARGIN, 1.0, dxWidth - 2 * MARGIN, dxHeight - 1.0);
    self.imgHasPics.frame = rImage;
    self.imgHasPics.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat xLabels = rImage.origin.x + rImage.size.width + MARGIN;
    CGFloat dxSig =  (self.imgSigState.hidden ? 0 : self.imgSigState.frame.size.width);
    
    CGRect rTitle = CGRectMake(xLabels, self.lblTitle.frame.origin.y, f.size.width - xLabels - 2 * MARGIN - dxSig, self.lblTitle.frame.size.height);
    self.lblTitle.frame = rTitle;
    
    CGRect rRoute = CGRectMake(xLabels, self.lblRoute.frame.origin.y, f.size.width - xLabels -2 * MARGIN - dxSig, self.lblRoute.frame.size.height);
    self.lblRoute.frame = rRoute;

    CGRect rComments = CGRectMake(xLabels, self.lblComments.frame.origin.y, f.size.width - xLabels -2 * MARGIN - dxSig, self.lblComments.frame.size.height);
    self.lblComments.frame = rComments;
}


@end
