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
//  NumPad.h
//  MFBSample
//
//  Created by Eric Berman on 3/3/13.
//
//

#import <UIKit/UIKit.h>
#import "DecimalEdit.h"

@interface NumPad : UIView <UIInputViewAudioFeedback>
@property (nonatomic, strong) IBOutlet UITextField * delegate;

@property (nonatomic, strong) IBOutlet UIButton * idBtnDec;
@property (nonatomic, strong) IBOutlet UIButton * idBtn6;
@property (nonatomic, strong) IBOutlet UIButton * idBtn7;
@property (nonatomic, strong) IBOutlet UIButton * idBtn8;
@property (nonatomic, strong) IBOutlet UIButton * idBtn9;
@property (nonatomic, assign) int NumberType;

- (IBAction) keyClicked: (UIButton *) sender;
- (IBAction) backspaceClicked:(UIButton *)sender;
- (IBAction) decimalClicked:(UIButton *)sender;

- (void) setTextDelegate:(UITextField *)delegate;
+ (NumPad *) getNumPad;
- (BOOL) stringOK:(NSString *) sz;
@end
