//
//  HostedWebViewViewController.h
//  MyFlightbook
//
//  Created by Eric Berman on 10/20/17.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface HostedWebViewViewController : UIViewController<WKUIDelegate, WKNavigationDelegate>
- (instancetype) initWithURL:(NSString *) szURL;
@end
