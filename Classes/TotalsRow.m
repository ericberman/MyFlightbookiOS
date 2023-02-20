/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  TotalsRow.m
//  MFBSample
//
//  Created by Eric Berman on 6/17/11.
//  Copyright 2011-2017 MyFlightbook LLC. All rights reserved.
//

#import <MyFlightbook-Swift.h>
#import "TotalsRow.h"

@implementation TotalsRow

@synthesize txtLabel, txtValue, txtSubDesc;

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
    if ([self.txtSubDesc.text length] == 0)
    {
        CGFloat h = (self.txtSubDesc.frame.origin.y + self.txtSubDesc.frame.size.height) - self.txtLabel.frame.origin.y;
        CGRect r = self.txtLabel.frame;
        r.size.height = h;
        self.txtLabel.frame = r;
        r = self.txtValue.frame;
        r.size.height = h;
        self.txtValue.frame = r;
    }
}

+ (TotalsRow *) rowForTotal:(MFBWebServiceSvc_TotalsItem *) ti forTableView:tableView usngHHMM: (BOOL) fHHMM {
    static NSString *CellIdentifier = @"TotalsRow";
    TotalsRow *cell = (TotalsRow *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TotalsRow" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ( [firstObject isKindOfClass:[UITableViewCell class]] )
            cell = firstObject;
        else cell = topLevelObjects[1];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    cell.txtLabel.text = ti.Description;
    cell.txtSubDesc.text = ti.SubDescription;
    cell.txtValue.text = [ti formattedValueWithFHHMM:fHHMM];
    cell.accessoryType = (ti.Query == nil) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    
    [cell AdjustLayoutForValues];
    return cell;
}

@end

