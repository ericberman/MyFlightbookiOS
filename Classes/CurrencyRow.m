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
//  Copyright 2011-2018 MyFlightbook LLC. All rights reserved.
//

#import "CurrencyRow.h"
#import "CurrencyCategories.h"

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

+ (CurrencyRow *) rowForCurrency:(MFBWebServiceSvc_CurrencyStatusItem *) ci forTableView:tableView {
    static NSString *CellIdentifier = @"CurrencyCell";
    CurrencyRow * cell = (CurrencyRow *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CurrencyRow" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ( [firstObject isKindOfClass:[UITableViewCell class]] )
            cell = firstObject;
        else cell = topLevelObjects[1];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Set up the cell...
    cell.lblDescription.text = ci.formattedTitle;
    
    // Color the value red/blue/green depending on severity:
    cell.lblValue.text = ci.Value;
    switch (ci.Status) {
        case MFBWebServiceSvc_CurrencyState_OK:
            cell.lblValue.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
            break;
        case MFBWebServiceSvc_CurrencyState_GettingClose:
            cell.lblValue.textColor = [UIColor blueColor];
            break;
        case MFBWebServiceSvc_CurrencyState_NotCurrent:
            cell.lblValue.textColor = [UIColor redColor];
            break;
        case MFBWebServiceSvc_CurrencyState_NoDate:
        case MFBWebServiceSvc_CurrencyState_none:
        default:
            cell.lblValue.textColor = [UIColor blackColor];
            break;
    }
    
    cell.lblDiscrepancy.text = ci.Discrepancy;     // add any relevant discrepancy string
    
    [cell AdjustLayoutForValues];
    return cell;
}

@end

