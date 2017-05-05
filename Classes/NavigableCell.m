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
//  NavigableCell.m
//  MFBSample
//
//  Created by Eric Berman on 3/27/13.
//
//

#import "NavigableCell.h"

@implementation NavigableCell

@synthesize firstResponderControl, lastResponderControl;

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


#pragma mark - Navigation within the cell
- (NSMutableArray *) sortedTextFields
{
    if (![self.firstResponderControl isKindOfClass:[UITextField class]])
        return nil;
    
    NSMutableArray * ar = [[NSMutableArray alloc] init];
    for (UIView * vw in ((UITextField *) self.firstResponderControl).superview.subviews)
        if ([vw isKindOfClass:[UITextField class]])
            [ar addObject:vw];
    [ar sortUsingComparator:^(UITextField * a, UITextField * b)
            {return (a.tag < b.tag) ? NSOrderedAscending : ((a.tag == b.tag) ? NSOrderedSame : NSOrderedDescending);}];
    return ar;
}
- (BOOL) navNext:(UITextField *) txtCurrent
{
    NSArray * ar = [self sortedTextFields];
    NSInteger index = [ar indexOfObject:txtCurrent];
    if (index != NSNotFound && index < [ar count] -1)
    {
        [((UITextField *) ar[index + 1]) becomeFirstResponder];
        return YES;
    }
    return NO;
}

- (BOOL) navPrev:(UITextField *) txtCurrent
{
    NSArray * ar = [self sortedTextFields];
    NSInteger index = [ar indexOfObject:txtCurrent];
    if (index != NSNotFound && index > 0)
    {
        [((UITextField *) ar[index - 1]) becomeFirstResponder];
        return YES;
    }
    return NO;    
}
@end
