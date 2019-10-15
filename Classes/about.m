/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2019 MyFlightbook, LLC
 
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
//  about.m
//  MFBSample
//
//  Created by Eric Berman on 1/11/10.
//  Copyright 2010-2019 MyFlightbook LLC. All rights reserved.
//

#import "about.h"
#import "MFBAppDelegate.h"

@implementation about

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
#ifdef DEBUG
    if (lblAbout != nil)
        lblAbout.text = [NSString stringWithFormat:@"%@%@", lblAbout.text, @" - DEBUG VERSION"];
#endif
    if (lblDetails != nil)
        lblDetails.text = [NSString stringWithFormat:@"%@, %d, %d, %@", MFBHOSTNAME, [MFBLocation TakeOffSpeed], [MFBLocation LandingSpeed], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    lblDetailedText.text = NSLocalizedString(@"AboutMyFlightbook", @"About MyFlightbook");
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
@end
