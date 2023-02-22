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
//  CollapsibleTable.h
//  MFBSample
//
//  Created by Eric Berman on 3/19/13.
//
//

#import <UIKit/UIKit.h>
#import "EditCell.h"
#import "CommentedImage.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AccessoryBar.h"
#import "ExpandHeaderCell.h"

@protocol Invalidatable
- (void) invalidateViewController;
@end

@interface CollapsibleTable : UITableViewController<UIImagePickerControllerDelegate, AccessoryBarDelegate, Invalidatable, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (readwrite, strong) NSMutableIndexSet * expandedSections;
@property (nonatomic, strong) NSIndexPath * ipActive;
@property (atomic, assign) BOOL fIsValid;
@property (nonatomic, assign) CGFloat defSectionHeaderHeight;
@property (nonatomic, assign) CGFloat defSectionFooterHeight;

- (void) collapseSection:(NSInteger) section forTable:(UITableView *) tableView;
- (void) expandSection:(NSInteger) section forTable:(UITableView *) tableView;
- (void) toggleSection:(NSInteger) section forTable:(UITableView *) tableView;
- (void) collapseSection:(NSInteger) section;
- (void) expandSection:(NSInteger) section;
- (void) toggleSection:(NSInteger) section;
- (BOOL) isExpanded:(NSInteger) section;
- (void) collapseAll;
- (void) expandAll:(UITableView *) tableView;
- (void) reload;

- (NSIndexPath *) nextNavCell:(NSIndexPath *) ip;
- (NSIndexPath *) prevNavCell:(NSIndexPath *) ip;
- (BOOL) canNext;
- (BOOL) canPrev;
- (BOOL) isNavigableRow:(NSIndexPath *) ip;
- (void) enableNextPrev:(AccessoryBar *) vwAccessory;

- (EditCell *) owningCell:(UIView *) vw;
- (UITableViewCell *) owningCellGeneric:(UIView *)vw;
- (void) addImage:(CommentedImage *)ci;
- (void) setBackground:(NSString *) szImageName;

- (BOOL) canUseCamera;
- (BOOL) canUsePhotoLibrary;

- (IBAction) pickImages:(id) sender;
- (IBAction) takePicture:(id) sender;

@end
