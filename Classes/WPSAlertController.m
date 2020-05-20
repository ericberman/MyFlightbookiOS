//
// WPSAlertController.m, from https://github.com/kirbyt/WPSKit/blob/master/WPSKit/UIKit/WPSAlertController.m
//
// Created by Kirby Turner.
// Copyright 2015 White Peak Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "WPSAlertController.h"
#import "MFBTheme.h"

@interface WPSAlertController ()
@property (nonatomic, strong) UIWindow *alertWindow;
@end

@implementation WPSAlertController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self alertWindow] setHidden:YES];
    [self setAlertWindow:nil];
}

- (void)show
{
    [self showAnimated:YES];
}

- (void)showAnimated:(BOOL)animated
{
    UIViewController *blankViewController = [[UIViewController alloc] init];
    [[blankViewController view] setBackgroundColor:[UIColor clearColor]];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [window setRootViewController:blankViewController];
    [window setBackgroundColor:[UIColor clearColor]];
    [window setWindowLevel:UIWindowLevelAlert + 1];
    [window makeKeyAndVisible];
    [self setAlertWindow:window];
    
    [blankViewController presentViewController:self animated:animated completion:nil];
}

+ (UIAlertController *) presentProgressAlertWithTitle:(nullable NSString *)message onViewController:(nullable UIViewController *) parent {
    UIAlertController * alert = (parent == nil) ?
        [WPSAlertController alertControllerWithTitle:message message:message preferredStyle:UIAlertControllerStyleAlert] :
        [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:MFBTheme.isDarkMode ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    UIViewController *customVC = [[UIViewController alloc] init];
    
    [customVC.view addSubview:spinner];
    
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterX
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterX
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    
    
    [customVC.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem: spinner
                                  attribute:NSLayoutAttributeCenterY
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:customVC.view
                                  attribute:NSLayoutAttributeCenterY
                                  multiplier:1.0f
                                  constant:0.0f]];
    
    
    [alert setValue:customVC forKey:@"contentViewController"];
    if (parent == nil)
        [((WPSAlertController *) alert) show];
    else
        [parent presentViewController:alert animated:YES completion:nil];

    return alert;
}

+ (void)presentOkayAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message button:(NSString *) buttonTitle {
    WPSAlertController *alertController = [WPSAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okayAction];
    
    [alertController show];

}

+ (void)presentOkayAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message {
    [[self class] presentOkayAlertWithTitle:title message:message button:NSLocalizedString(@"Close", @"Close button on error message")];
}

+ (void)presentAlertWithErrorMessage:(nullable NSString *)message
{
    [[self class] presentOkayAlertWithTitle:NSLocalizedString(@"Error", @"Title for generic error message") message:message];
}

+ (void)presentOkayAlertWithError:(nullable NSError *)error
{
    NSString *title = NSLocalizedString(@"Error", @"Title for generic error message");
    NSString *message = [error localizedDescription];
    [[self class] presentOkayAlertWithTitle:title message:message];
}

@end
