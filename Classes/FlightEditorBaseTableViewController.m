/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019-2023 MyFlightbook, LLC
 
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
#import <MyFlightbook-Swift.h>
#import "AutodetectOptions.h"
#import "GPSDeviceViewTableViewController.h"
#import <ExternalAccessory/EAAccessory.h>
#import <ExternalAccessory/EAAccessoryManager.h>
#import <ExternalAccessory/ExternalAccessoryDefines.h>

@interface FlightEditorBaseTableViewController ()
@property (readwrite, strong) NSMutableArray<EAAccessory *> * externalAccessories;
@end

@implementation FlightEditorBaseTableViewController

@synthesize externalAccessories;
@synthesize idDate, idRoute, idComments, idTotalTime, idPopAircraft, idApproaches, idHold, idLandings, idDayLandings, idNightLandings;
@synthesize idNight, idIMC, idSimIMC, idGrndSim, idXC, idDual, idCFI, idSIC, idPIC, idPublic, btnViewRoute;
@synthesize datePicker, pickerView;
@synthesize idLblStatus, idLblSpeed, idLblAltitude, idLblQuality, idimgRecording, idbtnPausePlay, idbtnAppendNearest, idlblElapsedTime;
@synthesize lblLat, lblLon, lblSunset, lblSunrise;
@synthesize cellComments, cellDateAndTail, cellGPS, cellLandings, cellRoute, cellSharing, cellTimeBlock;
@synthesize vwAccessory;
@synthesize activeTextField;

#pragma mark - UI / UITableViewCell Helpers
- (void) setNumericField:(UITextField *) txt toType:(NumericType) nt {
    [txt setNumberType:nt inHHMM:UserPreferences.current.HHMMPref];
    txt.autocorrectionType = UITextAutocorrectionTypeNo;
    txt.inputAccessoryView = self.vwAccessory;
    txt.delegate = self;
}

- (EditCell *) decimalCell:(UITableView *) tableView withPrompt:(NSString *)szPrompt andValue:(NSNumber *)val selector:(SEL)sel andInflation:(BOOL) fIsInflated {
    EditCell * ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
    [self setNumericField:ec.txt toType:NumericTypeDecimal];
    [ec.txt addTarget:self action:sel forControlEvents:UIControlEventEditingChanged];
    [ec.txt setValue:val withDefault:@0.0];
    ec.lbl.text = szPrompt;
    [self setLabelInflated:fIsInflated forEditCell:ec];
    return ec;
}

- (EditCell *) dateCell:(NSDate *) dt withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView inflated:(BOOL) fInflated {
    EditCell * ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
    ec.txt.inputView = self.datePicker;
    ec.txt.placeholder = NSLocalizedString(@"(Tap for Now)", @"Prompt UTC Date/Time that is currently un-set (tapping sets it to NOW in UTC)");
    ec.txt.delegate = self;
    ec.lbl.text = szPrompt;
    ec.txt.clearButtonMode = UITextFieldViewModeNever;
    ec.txt.text = [NSDate isUnknownDate:dt] ? @"" : [dt utcString:UserPreferences.current.UseLocalTime];
    [self setLabelInflated:fInflated forEditCell:ec];
    
    return ec;
}

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

- (void) crossFillTotal:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
        [(UITextField *) sender.view crossFillFrom:self.idTotalTime];
}

- (void) crossFillLanding:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan)
        [(UITextField *) sender.view crossFillFrom:self.idLandings];
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
- (void)presentationControllerDidDismiss:(UIPresentationController *)popoverController {
    [self.tableView reloadData];
}

#pragma mark - CollapsibleTable
- (void) nextClicked {
    UITableViewCell * cell = [self owningCellGeneric:self.activeTextField];
    if ([cell isKindOfClass:[NavigableCell class]] && [((NavigableCell *) cell) navNext:self.activeTextField])
        return;
    [super nextClicked];
}

- (void) prevClicked {
    UITableViewCell * cell = [self owningCellGeneric:self.activeTextField];
    if ([cell isKindOfClass:[NavigableCell class]] && [((NavigableCell *) cell) navPrev:self.activeTextField])
        return;
    [super prevClicked];
}

- (void) doneClicked {
    self.activeTextField = nil;
    [super doneClicked];
}

#pragma mark - UITextViewDelegate
- (BOOL) textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    self.activeTextField = nil;
    return YES;
}

#pragma mark - View lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set the accessory view and the inputview for our various text boxes.
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];

    self.externalAccessories = [NSMutableArray<EAAccessory*> new];
    
    // Set numeric fields
    [self setNumericField:self.idLandings toType:NumericTypeInteger];
    [self setNumericField:self.idDayLandings toType:NumericTypeInteger];
    [self setNumericField:self.idNightLandings toType:NumericTypeInteger];
    [self setNumericField:self.idApproaches toType:NumericTypeInteger];
    
    [self setNumericField:self.idXC toType:NumericTypeTime];
    [self setNumericField:self.idSIC toType:NumericTypeTime];
    [self setNumericField:self.idSimIMC toType:NumericTypeTime];
    [self setNumericField:self.idCFI toType:NumericTypeTime];
    [self setNumericField:self.idDual toType:NumericTypeTime];
    [self setNumericField:self.idGrndSim toType:NumericTypeTime];
    [self setNumericField:self.idIMC toType:NumericTypeTime];
    [self setNumericField:self.idNight toType:NumericTypeTime];
    [self setNumericField:self.idPIC toType:NumericTypeTime];
    [self setNumericField:self.idTotalTime toType:NumericTypeTime];
    
    [self enableLabelClickForField:self.idLandings];
    [self enableLabelClickForField:self.idNightLandings];
    [self enableLabelClickForField:self.idDayLandings];
    [self enableLabelClickForField:self.idApproaches];
    
    [self enableLabelClickForField:self.idNight];
    [self enableLabelClickForField:self.idSimIMC];
    [self enableLabelClickForField:self.idIMC];
    [self enableLabelClickForField:self.idXC];
    [self enableLabelClickForField:self.idDual];
    [self enableLabelClickForField:self.idGrndSim];
    [self enableLabelClickForField:self.idCFI];
    [self enableLabelClickForField:self.idSIC];
    [self enableLabelClickForField:self.idPIC];
    [self enableLabelClickForField:self.idTotalTime];
    
    [self enableLongPressForField:self.idNight withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idSimIMC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idIMC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idXC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idDual withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idGrndSim withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idCFI withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idSIC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idPIC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idDayLandings withSelector:@selector(crossFillLanding:)];
    [self enableLongPressForField:self.idNightLandings withSelector:@selector(crossFillLanding:)];
    
    // Make the checkboxes checkboxes
    [self.idHold setIsCheckbox];
    [self.idPublic setIsCheckbox];
    self.idHold.contentHorizontalAlignment = self.idPublic.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
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
