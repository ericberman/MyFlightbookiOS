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
//  EditCell.m
//  MFBSample
//
//  Created by Eric Berman on 5/25/12.
//  Copyright (c) 2012-2017 MyFlightbook LLC. All rights reserved.
//

#import "EditCell.h"

@implementation EditCell

@synthesize txt, txtML, lbl, lblDetail;

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


- (void) setLabelToFit:(NSString *) sz
{
    UIFont * fnt = self.lbl.font;
    CGFloat ptSize = fnt.pointSize;
    CGRect rFrame = self.lbl.frame;
    
    while (ptSize > 0.0)
    {
        fnt = [UIFont systemFontOfSize:ptSize];
        CGSize size = [sz boundingRectWithSize:CGSizeMake(rFrame.size.width - 20 - 30, 10000)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:fnt}
                                                        context:nil].size;
        if (size.height <= rFrame.size.height) break;
        ptSize -= 1.0;
    }
    
    self.lbl.font = fnt;
    self.lbl.numberOfLines = 0;
    self.lbl.adjustsFontSizeToFitWidth = NO;
    self.lbl.lineBreakMode = NSLineBreakByWordWrapping;
    self.lbl.text = sz;
}

+ (EditCell *) getEditCell:(UITableView *)tableView withAccessory:(AccessoryBar *)vwAccessory fromNib:(NSString *) nibName withID:(NSString *) cellID
{
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[EditCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
    }
    if (cell.txt != nil)
    {
        cell.txt.secureTextEntry = NO;
        cell.txt.inputAccessoryView = vwAccessory;
        cell.txt.placeholder = @"";
        cell.firstResponderControl = cell.lastResponderControl = cell.txt;
    }
    if (cell.txtML != nil)
    {
        cell.txtML.secureTextEntry = NO;
        cell.txtML.inputAccessoryView = vwAccessory;
        cell.txtML.editable = YES;
        cell.firstResponderControl = cell.lastResponderControl = cell.txtML;
    }
    cell.lblDetail.text = @"";
    return cell;
}

+ (EditCell *) getEditCell:(UITableView *)tableView withAccessory:(AccessoryBar *)vwAccessory
{
    static NSString *CellTextIdentifier = @"CellEdit";
    return [EditCell getEditCell:tableView withAccessory:vwAccessory fromNib:@"EditCell" withID:CellTextIdentifier];
}

+ (EditCell *) getEditCellDetail:(UITableView *)tableView withAccessory:(AccessoryBar *)vwAccessory
{
    static NSString *CellTextIdentifier = @"CellEditDetail";
    return [EditCell getEditCell:tableView withAccessory:vwAccessory fromNib:@"EditCellDetail" withID:CellTextIdentifier];
}

+ (EditCell *) getEditCellNoLabel:(UITableView *) tableView withAccessory:(AccessoryBar *)vwAccessory
{
    static NSString *CellTextIdentifier = @"CellEditNoLabel";
    return [EditCell getEditCell:tableView withAccessory:vwAccessory fromNib:@"EditCellNoLabel" withID:CellTextIdentifier];
}

+ (EditCell *) getEditCellMultiLine:(UITableView *) tableView withAccessory:(AccessoryBar *)vwAccessory
{
    static NSString *CellTextIdentifier = @"CellEditMultiLine";
    return [EditCell getEditCell:tableView withAccessory:vwAccessory fromNib:@"EditCellML" withID:CellTextIdentifier];
}

@end
