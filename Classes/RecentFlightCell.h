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
//  RecentFlightCell.h
//  MFBSample
//
//  Created by Eric Berman on 1/14/12.
//  Copyright (c) 2012-2018 MyFlightbook LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFBWebServiceSvc.h"
#import "CommentedImage.h"

@interface RecentFlightCell : UITableViewCell {
}

@property (nonatomic, strong) IBOutlet UIImageView * imgHasPics;
@property (nonatomic, strong) IBOutlet UIImageView * imgSigState;
@property (nonatomic, strong) IBOutlet UITextView * lblComments;

- (void) setFlight:(MFBWebServiceSvc_LogbookEntry *) le withImage:(CommentedImage *)ci withError:(NSString *) szErr;
@end
