/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2018 MyFlightbook, LLC
 
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
//  ImageComment.m
//  MFBSample
//
//  Created by Eric Berman on 2/5/10.
//

#import "ImageComment.h"
#import "MFBAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MFBTheme.h"

@implementation ImageComment

@synthesize ci, txtComment, vwWebImage;

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
    self.txtComment.attributedPlaceholder = [MFBTheme.currentTheme formatAsPlaceholder:NSLocalizedString(@"Add a comment for this image", @"Add a comment for this image")];
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

- (void) viewWillAppear:(BOOL)animated
{
	self.txtComment.text = (self.ci.imgInfo == nil || self.ci.imgInfo.Comment == nil) ? @"" : self.ci.imgInfo.Comment;
    
	// use the full-size image if it's available to show, not the thumbnail.
    NSString * szURL;
	if ([self.ci.imgInfo livesOnServer] && [self.ci.imgInfo.URLFullImage length] > 0)
    {
		szURL = [NSString stringWithFormat:@"https://%@%@", MFBHOSTNAME, self.ci.imgInfo.URLFullImage];
        [self.vwWebImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:szURL]]];
    }
    else if (self.ci.IsVideo)
    {
        self.vwWebImage.mediaPlaybackRequiresUserAction = YES;
        [self.vwWebImage loadRequest:[NSURLRequest requestWithURL:self.ci.LocalFileURL]];
    }
    else
    {
        szURL = [NSString stringWithFormat:@"file://%@", [self.ci FullFilePathName]];
        [self.vwWebImage loadHTMLString:[NSString stringWithFormat:@"<html><body><img src=\"%@\"></body></html>", szURL] baseURL:nil];
	}

	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
	// see if the comment has changed; if so, update the annotation syncrhonously
	if ([self.txtComment.text compare:self.ci.imgInfo.Comment] != NSOrderedSame)
	{
		self.ci.imgInfo.Comment = self.txtComment.text;
		[self.ci updateAnnotation:mfbApp().userProfile.AuthToken];
	}
	[super viewWillDisappear:animated];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

@end
