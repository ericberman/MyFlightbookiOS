/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019 MyFlightbook, LLC
 
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
//  FlightEditorBaseTableViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 6/23/19.
//

#import "FlightEditorBaseTableViewController.h"
#import "GPSDeviceViewTableViewController.h"
#import <ExternalAccessory/EAAccessory.h>
#import <ExternalAccessory/EAAccessoryManager.h>
#import <ExternalAccessory/ExternalAccessoryDefines.h>


@interface FlightEditorBaseTableViewController ()
@property (readwrite, strong) NSMutableArray<EAAccessory *> * externalAccessories;
@end

@implementation FlightEditorBaseTableViewController

@synthesize externalAccessories;

#pragma mark - Gesture support
- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) enableLongPressForField:(UITextField *) txt withSelector:(SEL) s {
    if (txt == nil)
        return;
    
    // Disable the existing long-press recognizer
    NSArray * currentGestures = [NSArray arrayWithArray:txt.gestureRecognizers];
    for (UIGestureRecognizer *recognizer in currentGestures)
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [txt removeGestureRecognizer:recognizer];
    
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:s];
    lpgr.minimumPressDuration = 0.7; // in seconds
    lpgr.delegate = self;
    [txt addGestureRecognizer:lpgr];
}

- (void) enableLabelClickForField:(UITextField *) txt {
    if (txt.tag <= 0)
        return;
    for (UIView * vw in txt.superview.subviews)
        if ([vw isKindOfClass:[UILabel class]] && ((UILabel *) vw).tag == txt.tag)
            [vw addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:txt action:@selector(becomeFirstResponder)]];
}

#pragma mark - External devices
- (void) deviceDidConnect:(NSNotification *) notification {
    EAAccessory * accessory = notification.userInfo[EAAccessoryKey];
    [self.externalAccessories addObject:accessory];
    
    [self.tableView reloadData];
}

- (void) deviceDidDisconnect:(NSNotification *) notification {
    self.externalAccessories = [NSMutableArray arrayWithArray:EAAccessoryManager.sharedAccessoryManager.connectedAccessories];
    [self.tableView reloadData];
}

- (BOOL) hasAccessories {
    return self.externalAccessories.count > 0;
}

- (void) viewAccessories {
    if (self.hasAccessories) {
        GPSDeviceViewTableViewController * gpsView = [GPSDeviceViewTableViewController new];
        gpsView.eaaccessory = self.externalAccessories[0];
        [self.navigationController pushViewController:gpsView animated:YES];
    }
}

#pragma mark - UIContentContainer
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    NSLog(@"New width: %f", size.width);
}

#pragma mark - Misc. Formatting utilities
- (NSString *) elapsedTimeDisplay:(NSTimeInterval) dt {
    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int) (dt / 3600), (int) ((((int) dt) % 3600) / 60), ((int) dt) % 60];
}

- (void) setLabelInflated:(BOOL) fInflate forEditCell:(EditCell *)ec {
    UIFont * font = fInflate ? [UIFont boldSystemFontOfSize:14.0] : [UIFont systemFontOfSize:12.0];
    ec.txt.font = ec.lbl.font = font;
}

#pragma mark - UIPopoverPresentationController functions
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverController {
    [self.tableView reloadData];
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverController {
    // let the property display know it is going to go away.
    [popoverController.presentedViewController viewWillDisappear:NO];
    return true;
}

#pragma mark - View lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.externalAccessories = [NSMutableArray<EAAccessory*> new];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [EAAccessoryManager.sharedAccessoryManager registerForLocalNotifications];
    self.externalAccessories = [NSMutableArray arrayWithArray:EAAccessoryManager.sharedAccessoryManager.connectedAccessories];
    NSNotificationCenter * notctr = NSNotificationCenter.defaultCenter;
    [notctr addObserver:self selector:@selector(deviceDidConnect:) name:EAAccessoryDidConnectNotification object:nil];
    [notctr addObserver:self selector:@selector(deviceDidDisconnect:) name:EAAccessoryDidDisconnectNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [EAAccessoryManager.sharedAccessoryManager unregisterForLocalNotifications];
    NSNotificationCenter * notctr = NSNotificationCenter.defaultCenter;
    [notctr removeObserver:self name:EAAccessoryDidConnectNotification object:nil];
    [notctr removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];
}

@end
