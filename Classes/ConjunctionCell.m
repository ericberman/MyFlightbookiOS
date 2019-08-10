/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019 MyFlightbook, LLC
 
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
//  ConjunctionCell.m
//  MyFlightbook
//
//  Created by Eric Berman on 8/6/19.
//

#import "ConjunctionCell.h"

@interface ConjunctionCell()
@end

@implementation ConjunctionCell

@synthesize segConjunction;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setConjunction:(MFBWebServiceSvc_GroupConjunction) conj {
    self.segConjunction.selectedSegmentIndex = (conj - MFBWebServiceSvc_GroupConjunction_none) - 1;
}

- (MFBWebServiceSvc_GroupConjunction) conjunction {
    return MFBWebServiceSvc_GroupConjunction_none + (MFBWebServiceSvc_GroupConjunction) (1 + self.segConjunction.selectedSegmentIndex);
}

+ (ConjunctionCell *) getConjunctionCell:(UITableView *) tableView withConjunction:(MFBWebServiceSvc_GroupConjunction) conj
{
    static NSString *CellTextIdentifier = @"ConjunctionCell";
    ConjunctionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ConjunctionCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[ConjunctionCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
    }
    
    cell.conjunction = conj;
    
    return cell;
}
@end
