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
//  LogbookEntryBaseViewControllerTableViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 7/4/19.
//

#import "LogbookEntryBaseViewControllerTableViewController.h"
#import "FlightProperties.h"
#import "HostedWebViewViewController.h"
#import "MFBTheme.h"
#import "DecimalEdit.h"
#import "NearbyAirports.h"

@interface LogbookEntryBaseViewControllerTableViewController ()

@end

@implementation LogbookEntryBaseViewControllerTableViewController

@synthesize le;
@synthesize activeTemplates;
@synthesize flightProps;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up longpress recognizers for times
    [self enableLongPressForField:self.idTotalTime withSelector:@selector(timeCalculator:)];
}

#pragma mark - Table view data source
// ALL DONE IN SUPER OR SUBCLASSES

#pragma mark - send actions for a flight
- (void) repeatFlight:(BOOL) fReverse {
    LogbookEntry * leNew = [[LogbookEntry alloc] init];
    
    leNew.entryData  = fReverse ? [self.le.entryData cloneAndReverse] : [self.le.entryData clone];
    leNew.entryData.FlightID = QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    [app queueFlightForLater:leNew];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"flightActionComplete", @"Flight Action Complete Title") message:NSLocalizedString(@"flightActionRepeatComplete", @"Flight Action - repeated flight created") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.delegate != nil)
            [self.delegate flightUpdated:self];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) sendFlightToPilot {
    [self.le.entryData sendFlight];
}

- (void) shareFlight:(id) sender {
    [self.le.entryData shareFlight:sender fromViewController:self];
}


- (void) sendFlight:(id) sender {
    UIAlertController * uac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"flightActionMenuPrompt", @"Actions for this flight") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionRepeatFlight", @"Flight Action - repeat a flight") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self repeatFlight:NO];
    }]];
    
    [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionReverseFlight", @"Flight Action - repeat and reverse flight") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self repeatFlight:YES];
    }]];
    
    if (self.le.entryData.SendFlightLink.length > 0) {
        [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionSend", @"Flight Action - Send") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self sendFlightToPilot];
        }]];
    }
    
    if (self.le.entryData.SocialMediaLink.length > 0) {
        [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionShare", @"Flight Action - Share") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self shareFlight:sender];
        }]];
    }
    
    [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [uac dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    UIBarButtonItem * bbi = (UIBarButtonItem *) sender;
    UIView * bbiView = [bbi valueForKey:@"view"];
    uac.popoverPresentationController.sourceView = bbiView;
    uac.popoverPresentationController.sourceRect = bbiView.frame;
    
    [self presentViewController:uac animated:YES completion:nil];
}

#pragma mark - Signing flights
- (void) signFlight:(id)sender {
    NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/SignEntry.aspx?idFlight=%d&auth=%@&naked=1&night=%@",
                        MFBHOSTNAME,
                        [self.le.entryData.FlightID intValue],
                        [(mfbApp()).userProfile.AuthToken stringByURLEncodingString],
                        MFBTheme.currentTheme.Type == themeNight ? @"yes" : @"no"];
    
    HostedWebViewViewController * vwWeb = [[HostedWebViewViewController alloc] initWithURL:szURL];
    [mfbApp() invalidateCachedTotals];   // this flight could now be invalid
    [self.navigationController pushViewController:vwWeb animated:YES];
}

#pragma mark - Templates
- (void) updateTemplatesForAircraft:(MFBWebServiceSvc_Aircraft *) ac {
    [FlightProps updateTemplates:self.activeTemplates forAircraft:ac];
}

- (void) templatesUpdated:(NSSet<MFBWebServiceSvc_PropertyTemplate *> *) templateSet {
    self.activeTemplates = [NSMutableSet setWithSet:templateSet];
    NSMutableArray * rgAllProps = [self.flightProps crossProduct:self.le.entryData.CustomProperties.CustomFlightProperty];
    [self.le.entryData.CustomProperties setProperties:[self.flightProps distillList:rgAllProps includeLockedProps:YES includeTemplates:self.activeTemplates]];
    [self.tableView reloadData];
}

- (void) pickTemplates:(id) sender {
    SelectTemplates * st = [SelectTemplates new];
    st.templateSet = self.activeTemplates;
    st.delegate = self;
    if (sender != nil && [sender isKindOfClass:UIView.class])
        [self pushOrPopView:st fromView:sender withDelegate:self];
    else
        [self.navigationController pushViewController:st animated:YES];
}

#pragma mark - Approach Helper
- (IBAction) addApproach:(id) sender {
    ApproachEditor * editor = [ApproachEditor new];
    editor.delegate = self;
    [editor setAirports:[Airports CodesFromString:self.idRoute.text]];
    [self pushOrPopView:editor fromView:sender withDelegate:self];
}

- (void) addApproachDescription:(ApproachDescription *) approachDescription {
    [self.le.entryData addApproachDescription:approachDescription.description];
    
    if (approachDescription.addToTotals)
        self.idApproaches.value = self.le.entryData.Approaches = @(self.le.entryData.Approaches.integerValue + approachDescription.approachCount);
    [self.tableView reloadData];
}

#pragma mark - Time Calculator
- (void) timeCalculator:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.idTotalTime resignFirstResponder];
        self.le.entryData.TotalFlightTime = self.idTotalTime.value;
        TotalsCalculator * tc = [TotalsCalculator new];
        tc.delegate = self;
        [tc setInitialTotal:self.le.entryData.TotalFlightTime];
        [self pushOrPopView:tc fromView:self.idTotalTime withDelegate:self];
    }
}

- (void) updateTotal:(NSNumber *)value {
    self.le.entryData.TotalFlightTime = value;
    self.idTotalTime.value = value;
}

#pragma mark Options
- (void) configAutoDetect {
    AutodetectOptions * vwAutoOptions = [[AutodetectOptions alloc] initWithNibName:@"AutodetectOptions" bundle:nil];
    [self.navigationController pushViewController:vwAutoOptions animated:YES];
}

#pragma mark - LongPressCross-fill support
- (void) setHighWaterHobbs:(UILongPressGestureRecognizer *) sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UITextField * target = (UITextField *) sender.view;
        NSNumber * highWaterHobbs = [[Aircraft sharedAircraft] getHighWaterHobbsForAircraft:self.le.entryData.AircraftID];
        if (highWaterHobbs != nil && highWaterHobbs.doubleValue > 0) {
            target.value = self.le.entryData.HobbsStart = highWaterHobbs;
        }
    }
}
@end
