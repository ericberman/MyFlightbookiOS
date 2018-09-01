//
// WPSAlertController.h
//
// Created by Kirby Turner, from https://github.com/kirbyt/WPSKit/blob/master/WPSKit/UIKit/WPSAlertController.h
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

#import <UIKit/UIKit.h>

/**
 `WPSAlertController` is a replacement for the deprecated `UIAlertView`. With `WPSAlertController`, you can display an alert without using a view controller.
 */
@interface WPSAlertController : UIAlertController

/**
 Show the alert view.
 
 This is the same as calling `showAnimated:YES`;
 */
- (void)show;

/**
 Show the alert view.
 
 @param animated Set to `YES` to animate the alert display.
 */
- (void)showAnimated:(BOOL)animated;

/**
 Displays an alert with a spinner and a title, no button.
 @param message The title to show
 @param parent Optional parent view controller
 
 Returns the alert so that the caller can change the message as needed (e.g., for progress.)
 */
+ (UIAlertController * _Nonnull) presentProgressAlertWithTitle:(nullable NSString *)message onViewController:(nullable UIViewController *) parent;

/**
 Displays an alert with an OK button.
 
 @param title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
 @param message Descriptive text that provides additional details about the reason for the alert.
 @param buttonTitle Title for the button to dismiss the alert.
 */
+ (void)presentOkayAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message button:(nullable NSString *) buttonTitle;

/**
 Displays an alert with an OK button.
 
 @param title The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
 @param message Descriptive text that provides additional details about the reason for the alert.
 */
+ (void)presentOkayAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

/**
 Displays an alert with an OK button and a localized "Error" title
 
 @param message Descriptive text that provides additional details about the reason for the alert.
 */
+ (void)presentAlertWithErrorMessage:(nullable NSString *)message;

/**
 Displays the `localizedDescription` of the provided error in an alert.
 
 @param error The error to display.
 */
+ (void)presentOkayAlertWithError:(nullable NSError *)error;

@end
