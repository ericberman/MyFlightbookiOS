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
//  ViewFlightWebPage.m
//  MFBSample
//
//  Created by Eric Berman on 1/15/10.
//  Copyright 2010-2017 MyFlightbook LLC. All rights reserved.
//

#import "ViewFlightWebPage.h"
#import "MFBAppDelegate.h"


@implementation ViewFlightWebPage

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
	((UIWebView *) self.view).delegate = self;

}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.navigationController != nil)
	{
		[self.navigationController setToolbarHidden:NO];
        [((UIWebView *) self.view) setScalesPageToFit:YES];
		
		UIImage * imgBack = [UIImage imageNamed:@"btnBack.png"];
		UIImage * imgForward = [UIImage imageNamed:@"btnForward.png"];
		
		UIBarButtonItem * bbSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
		UIBarButtonItem * bbStop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self.view action:@selector(stopLoading)];
		UIBarButtonItem * bbReload = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.view action:@selector(reload)];
		UIBarButtonItem * bbBack = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self.view action:@selector(goBack)];
		UIBarButtonItem * bbForward = [[UIBarButtonItem alloc] initWithImage:imgForward style:UIBarButtonItemStylePlain target:self.view action:@selector(goForward)];
		
		bbStop.style = bbReload.style = UIBarButtonItemStylePlain;
		
		self.toolbarItems = @[bbBack, bbForward, bbSpacer, bbStop, bbReload];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewWebPage:(NSString *) szURL
{
	[((UIWebView *) self.view) loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:szURL]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
@end
