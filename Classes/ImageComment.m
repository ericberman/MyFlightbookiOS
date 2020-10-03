/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2020 MyFlightbook, LLC
 
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

@interface ImageComment()
@property (nonatomic, strong) IBOutlet WKWebView * vwWebImage;
@end

@implementation ImageComment

@synthesize ci, txtComment, vwWebImage, vwWebHost;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.txtComment.placeholder = NSLocalizedString(@"Add a comment for this image", @"Add a comment for this image");

    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.preferences.javaScriptEnabled = YES;
    conf.allowsInlineMediaPlayback = YES;
    conf.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
    
    self.vwWebImage = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.vwWebHost.frame.size.width, self.vwWebHost.frame.size.height) configuration:conf];
    self.vwWebImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.vwWebHost addSubview:self.vwWebImage];

    self.vwWebImage.navigationDelegate = self;
    self.vwWebImage.UIDelegate = self;
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
        [self.vwWebImage loadRequest:[NSURLRequest requestWithURL:self.ci.LocalFileURL]];
    else
    {
        szURL = [NSString stringWithFormat:@"file://%@", [self.ci FullFilePathName]];
        [self.vwWebImage loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:szURL]]];
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

#pragma mark -- WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

@end
