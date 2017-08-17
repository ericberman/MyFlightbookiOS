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
//  WaitView.m
//  MFBSample
//
//  Created by Eric Berman on 2/5/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import "WaitView.h"
#import <math.h>

@implementation WaitView

@synthesize lblPrompt;
@synthesize activityIndicator;

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.lblPrompt = nil;
	self.activityIndicator = nil;
    [super viewDidUnload];
}

- (void) setOrientation:(UIInterfaceOrientation) o;
{
	// figure out the right start and target frame in window coordinates and transform for the current orientation
	double pi = acos(-1);
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame ];
	
	switch (o) {
		default:
			NSLog(@"Waitview: Unknown orientation: %ld!", (long) o);
            self.view.transform = CGAffineTransformIdentity;
            break;
			// now fall through.
		case UIDeviceOrientationPortrait:
			self.view.transform = CGAffineTransformIdentity;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			self.view.transform = CGAffineTransformMakeRotation(pi);
			break;
		case UIDeviceOrientationLandscapeLeft:
			self.view.transform = CGAffineTransformMakeRotation(pi / 2.0);
			break;
		case UIDeviceOrientationLandscapeRight:
			self.view.transform = CGAffineTransformMakeRotation(pi * 3.0 / 2.0);
			break;
	}
	
	self.view.frame = screenRect;
}


- (void) setUpForView:(UIView *) v withLabel:(NSString *) sz inOrientation:(UIInterfaceOrientation) o
{
    self.view.frame = v.frame;
    [v addSubview:self.view];
    if ([UIDevice currentDevice].systemVersion.floatValue < 8)
        [self setOrientation:o];
    self.view.hidden = NO; // failsafe.
    self.lblPrompt.text = sz;
    [self.activityIndicator startAnimating];
}

- (void) tearDown
{
    [self.activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
    if (self.view.superview != nil)
        [self.view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
}
@end
