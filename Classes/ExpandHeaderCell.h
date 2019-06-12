/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2012-2019 MyFlightbook, LLC
 
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
//  ExpandHeaderCell.h
//  MFBSample
//
//  Created by Eric Berman on 5/27/12.
//  Copyright (c) 2012-2019 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandHeaderCell : UITableViewCell
{
    BOOL isExpanded;
}

- (void) setExpanded:(BOOL) fExpanded;
+ (ExpandHeaderCell *) getHeaderCell:(UITableView *) tableView withTitle:(NSString *) szTitle forSection:(NSInteger) section initialState:(BOOL) isExpanded;

@property (nonatomic, strong) IBOutlet UILabel * HeaderLabel;
@property (nonatomic, strong) IBOutlet UIImageView * ExpandCollapseLabel;
@property (nonatomic, strong) IBOutlet UIButton * DisclosureButton;
@property (nonatomic, readonly) BOOL isExpanded;
@end
