//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"

#define REFRESH_HEADER_HEIGHT 60.0f


@implementation PullRefreshTableViewController

@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner, callInProgress;

- (instancetype)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self addPullToRefreshHeader];
}

- (void)setupStrings{    
    self.textPull = NSLocalizedString(@"Pull to refresh...", @"Displayed when pulling to refresh");
    self.textRelease = NSLocalizedString(@"Release to refresh", @"Displayed after pulling to indicate that a release will refresh");
    self.textLoading = NSLocalizedString(@"Loading...", @"Loading... prompt");
}

- (void)addPullToRefreshHeader {
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];

    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;

    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 18) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 18) / 2),
                                    36, 36);

    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;

    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.tableView addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.3 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else { // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;

    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];

    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;

    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        tableContentInset.top = 0.0;
        self.tableView.contentInset = tableContentInset;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
        }
         completion:^(BOOL finished) {
             [self stopLoadingComplete:nil finished:nil context:nil];
     }];
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}


#pragma mark Progress indicator utilities
- (void) startCall
{
    self.callInProgress = YES;
    [self.tableView reloadData];
}

- (void) endCall
{
    self.callInProgress = NO;
    [self.tableView reloadData];
}

- (WaitCell *) waitCellWithText:(NSString *) s
{
    static NSString *CellTextIdentifier = @"CellWait";
    WaitCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WaitCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[WaitCell class]] )
            cell = firstObject;     
        else 
            cell = topLevelObjects[1];
    }
    cell.Prompt.text = s;
    [cell.ActivityIndicator startAnimating];
    return cell;   
}

#pragma mark Error handling
- (void) showError:(NSString *) szMsg withTitle:(NSString *) szTitle
{
    UIAlertView * av = [[UIAlertView alloc] 
                         initWithTitle:szTitle 
                         message:szMsg 
                         delegate:nil 
                         cancelButtonTitle:NSLocalizedString(@"Close", @"Close button on error message") 
                         otherButtonTitles:nil];
    [av show];
    if (isLoading)
        [self stopLoading];
    self.callInProgress = NO;
    [self.tableView reloadData];
}
@end
