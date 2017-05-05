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
//  imageSelector.h
//  MFBSample
//
//  Created by Eric Berman on 1/10/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentedImage.h"
#import "ImageComment.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
@interface imageSelector : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate> {
#else
@interface imageSelector : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
#endif
	id popoverControl;
	NSMutableArray * rgImages;
}

@property (nonatomic, strong) id popoverControl;
@property (nonatomic, strong) NSMutableArray * rgImages;
	
- (IBAction) pickImages:(id) sender;
- (IBAction) takePicture:(id) sender;
@end
