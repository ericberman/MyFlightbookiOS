//
//  HostedWebViewViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 10/20/17.
//

#import "HostedWebViewViewController.h"

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
        self.szurl = szURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.preferences.javaScriptEnabled = YES;
    
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
        [self.navigationController setToolbarHidden:NO];
        
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

- (void) webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void) webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code == NSURLErrorCancelled)
        return;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Title for generic error message") message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"Close", @"Close button on error message") otherButtonTitles:nil];
    [av show];
}
@end
