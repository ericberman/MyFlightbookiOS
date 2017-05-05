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
//  AccessoryBar.h
//  MFBSample
//
//  Created by Eric Berman on 3/5/13.
//
//

#import <UIKit/UIKit.h>

@protocol AccessoryBarDelegate
- (void) nextClicked;
- (void) prevClicked;
- (void) deleteClicked;
- (void) doneClicked;
@end

@interface AccessoryBar : UIToolbar <AccessoryBarDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem * btnNext;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * btnPrev;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * btnDelete;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * btnDone;

- (IBAction) nextClicked;
- (IBAction) prevClicked;
- (IBAction) deleteClicked;
- (IBAction) doneClicked;

+ (AccessoryBar *) getAccessoryBar:(id<AccessoryBarDelegate>)d;
@end

