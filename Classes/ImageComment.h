/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2020 MyFlightbook, LLC
 
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
//  ImageComment.h
//  MFBSample
//
//  Created by Eric Berman on 2/5/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#include "CommentedImage.h"

@interface ImageComment : UIViewController <UITextFieldDelegate, WKUIDelegate, WKNavigationDelegate> {
}

@property (nonatomic, strong) CommentedImage * ci;
@property (nonatomic, strong) IBOutlet UITextField * txtComment;
@property (nonatomic, strong) IBOutlet UIView * vwWebHost;
@end
