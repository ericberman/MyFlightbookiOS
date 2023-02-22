/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  HostedWebViewViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 10/20/17.
//

#import "HostedWebViewViewController.h"
#import <MyFlightbook-Swift.h>
#import "Util.h"

@interface HostedWebViewViewController ()

@property (strong, nonatomic) NSString * szurl;
@end

@implementation HostedWebViewViewController

@synthesize szurl;

- (WKWebView *) webview {
    if ([self.view isKindOfClass:[WKWebView class]])
        return (WKWebView *) self.view;
    return nil;
}

- (instancetype) initWithURL:(NSString *)szURL
{
    if (self = [super init]) {
        NSMutableString * sz = [[NSMutableString alloc] initWithString:szURL];
        if (MFBTheme.isDarkMode) {
            if (![sz containsString:@"night="])
                [sz appendString:[sz containsString:@"?"] ? @"&night=yes" : @"?night=no"];
        }
        self.szurl = sz;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    
    self.view = [[WKWebView alloc] initWithFrame:self.view.frame configuration:conf];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    
    NSURL *nsurl=[NSURL URLWithString:self.szurl];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webview loadRequest:nsrequest];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController != nil)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.toolbar.translucent = NO;
        self.navigationController.toolbarHidden = NO;
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void) stopLoading {
    [self.webview stopLoading];
}

- (void) reload {
    [self.webview reload];
}

- (void) goBack {
    if (self.webview.canGoBack)
        [self.webview goBack];
}

- (void) goForward {
    if (self.webview.canGoForward)
        [self.webview goForward];
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response.MIMEType compare:@"text/calendar"] == NSOrderedSame) {
        decisionHandler(WKNavigationResponsePolicyCancel);
        [[UIApplication sharedApplication] openURL:navigationResponse.response.URL options:@{} completionHandler:nil];
    } else
        decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(true);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(false);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled)
        return;
    [self showErrorAlertWithMessage:error.localizedDescription];
}
@end
