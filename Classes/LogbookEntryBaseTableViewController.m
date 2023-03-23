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
//  LogbookEntryTableViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 7/4/19.
//

#import "LogbookEntryBaseTableViewController.h"
#import "FlightProperties.h"
#import "NearbyAirports.h"
#import "MyAircraft.h"
#import "RecentFlights.h"
#import <MyFlightbook-Swift.h>

@interface LogbookEntryBaseTableViewController ()

@end

@implementation LogbookEntryBaseTableViewController

@synthesize le;
@synthesize activeTemplates;
@synthesize flightProps;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up longpress recognizers for times
    [self enableLongPressForField:self.idTotalTime withSelector:@selector(timeCalculator:)];
    [self enableLongPressForField:self.idDate withSelector:@selector(setToday:)];
    
    [self.idbtnAppendNearest addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(appendAdHoc:)]];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Issue #109 - stupid apple bug; button initially shows up as gray despite being enabled.
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    self.idRoute.placeholder = NSLocalizedString(@"Route", @"Entry field: Route");
    self.idPopAircraft.placeholder = NSLocalizedString(@"Aircraft", @"Entry field: Aircraft");
    
    // pick up any changes in the HHMM setting
    self.idXC.IsHHMM = self.idSIC.IsHHMM = self.idSimIMC.IsHHMM = self.idCFI.IsHHMM = self.idDual.IsHHMM =
    self.idGrndSim.IsHHMM = self.idIMC.IsHHMM = self.idNight.IsHHMM = self.idPIC.IsHHMM = self.idTotalTime.IsHHMM = UserPreferences.current.HHMMPref;
}

#pragma mark - Table view data source
// ALL DONE IN SUPER OR SUBCLASSES

NSString * const _szKeyCurrentFlight = @"keyCurrentNewFlight";

#pragma mark - Save State
- (void) saveState {
    // don't save anything if we are viewing an existing flight or a pending flight.
    if (self.le.entryData.isNewFlight && ![self.le.entryData isKindOfClass:MFBWebServiceSvc_PendingFlight.class]) {
        // LE should already be in sync with the UI.
        self.le.entryData.FlightData = MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString;
        
        NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
        NSError * err;
        [defs setObject:[NSKeyedArchiver archivedDataWithRootObject:@[self.le] requiringSecureCoding:YES error:&err] forKey:_szKeyCurrentFlight];
        [defs synchronize];
    }
}

- (void) restoreFlightInProgress {
    NSData * ar = (NSData *) [NSUserDefaults.standardUserDefaults objectForKey:_szKeyCurrentFlight];
    if (ar != nil) {
        NSError * err = nil;
        self.le = (LogbookEntry *) ((NSArray *)[NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[NSArray.class, LogbookEntry.class, NSDate.class, CommentedImage.class]] fromData:ar error:&err])[0];
        self.le.entryData.Date = [NSDate date]; // go with today
        if (le.entryData.FlightID == nil || err != nil)
            le.entryData.FlightID = @-1;    // if something screwed up in the unarchiving, set it up as a new flight.
    }
    else {
        self.le = [[LogbookEntry alloc] init];
        [self setupForNewFlight];
    }
}

#pragma mark - Resetting flights
// re-initializes a flight but DOES NOT update any UI.
- (void) setupForNewFlight {
    NSNumber * endingHobbs = self.le.entryData.HobbsEnd; // remember ending hobbs for last flight...
    NSNumber * endingTach = [self.le.entryData getExistingProperty:@(PropTypeIDTachEnd)].DecValue;
    
    self.le    = [[LogbookEntry alloc] init];
    self.le.entryData.Date = [NSDate date];
    self.le.entryData.FlightID = LogbookEntry.NEW_FLIGHT_ID;
    // Add in any locked properties - but don't hit the web.
    FlightProps * fp = [FlightProps getFlightPropsNoNet];
    [self.le.entryData.CustomProperties setProperties:[fp defaultPropList]];
    
    MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] preferredAircraft];
    
    // Initialize the active templates to the defaults, either for this aircraft or the ones you've indicated you want to use by default.
    self.activeTemplates = [NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> setWithArray: (ac.DefaultTemplates.int_.count > 0) ? [MFBWebServiceSvc_PropertyTemplate templatesWithIDs:ac.DefaultTemplates.int_] : MFBWebServiceSvc_PropertyTemplate.defaultTemplates];
    [self templatesUpdated:self.activeTemplates];
    
    [self setCurrentAircraft:ac];
    
    MFBLocation * mfbloc = MFBAppDelegate.threadSafeAppDelegate.mfbloc;
    [mfbloc stopRecordingFlightData];
    [mfbloc resetFlightData]; // clean up any old flight-tracking data
    
    [self.le initNumerics];
    
    // ...and start the starting hobbs to be the previous flight's ending hobbs.  If it was nil, we're fine.
    self.le.entryData.HobbsStart = endingHobbs;
    if (endingTach != nil && endingTach.doubleValue > 0)
        [self.le.entryData setPropertyValue:@(PropTypeIDTachStart) withDecimal:endingTach];
    [self saveState]; // clean up any old state
    [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
}

- (void) resetFlight {
    [self setupForNewFlight];
    [self initFormFromLE];
}

- (void) resetFlightWithConfirmation {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Are you sure you want to reset this flight?  This CANNOT be undone", @"Reset Flight confirmation") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self resetFlight];
        MFBAppDelegate.threadSafeAppDelegate.watchData.flightStage = flightStageUnstarted;
        [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) invalidateViewController {
    [self performSelectorOnMainThread:@selector(resetFlight) withObject:nil waitUntilDone:NO];
}

#pragma mark Flight Submission
// Called after a flight is EITHER successfully posted to the site OR successfully queued for later.
- (void) submitFlightSuccessful
{
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
    // set the preferred aircraft
    [Aircraft sharedAircraft].DefaultAircraftID = self.le.entryData.AircraftID.intValue;
    
    // invalidate any cached totals and currency, since the newly entered flight renders them obsolete
    [app invalidateCachedTotals];
    UIView * targetView = app.tabRecents.viewControllers[0].view;
    
    // and let any delegate know that the flight has updated
    if (self.delegate != nil)
        [self.delegate flightUpdated:self];
    else {
        [UIView transitionFromView:self.navigationController.view
                            toView:targetView
                          duration:0.75
                           options:UIViewAnimationOptionTransitionCurlUp
                        completion:^(BOOL finished)
         {
             if (finished)
             {
                 // Could this be where the recents view isn't loaded?
                 MFBAppDelegate.threadSafeAppDelegate.tabBarController.selectedViewController = MFBAppDelegate.threadSafeAppDelegate.tabRecents;
                 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
         }];
    }
    
    // clear the form for another entry
    [self setupForNewFlight];
    [self initFormFromLE];
}

- (void) submitFlightInternal:(BOOL) asPending {
    [self.tableView endEditing:YES];
    // Basic validation
    // make sure we have the latest of everything - this should be unnecessary
    [self initLEFromForm];
    
    if ([self.le.entryData.AircraftID intValue] <= 0)
    {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Aircraft", @"Title for No Aircraft error")
                                                                        message:NSLocalizedString(@"Each flight must specify an aircraft.  Create one now?", @"Error - must have aircraft")
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Create", @"Button title to create an aircraft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self newAircraft];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (self.le.entryData.isNewFlight || self.le.entryData.CFISignatureState != MFBWebServiceSvc_SignatureState_Valid)
        [self submitFlightConfirmed:asPending];
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ConfirmEdit", @"Confirm edit")
                                                                        message:NSLocalizedString(@"ConfirmModifySignedFlight", @"Modify signed flight confirmation")
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self submitFlightConfirmed:asPending];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
}

- (void) submitFlightConfirmed:(BOOL) asPending {
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
    MFBProfile * pf = MFBProfile.sharedProfile;
    if (!pf.isValid) // should never happen - app delegate should have prevented this page from showing.
        return;
    
    self.le.szAuthToken = pf.AuthToken;
    self.le.entryData.User = pf.UserName;
    
    // Determine if this is going to logbook or to pending flights
    self.le.fShuntPending = asPending;
    
    BOOL fIsNew = [self.le.entryData isNewFlight];
    
    // get flight telemetry
    [app.mfbloc stopRecordingFlightData];
    if (fIsNew)
        self.le.entryData.FlightData = [app.mfbloc flightDataAsString];
    else if (![self.le.entryData isNewOrAwaitingUpload]) // for existing flights, don't send up flighttrackdata
        self.le.entryData.FlightData = nil;
    
    // remove any non-default properties from the list.
    [self.le.entryData.CustomProperties setProperties:[self.flightProps distillList:self.le.entryData.CustomProperties.CustomFlightProperty includeLockedProps:NO includeTemplates:nil]];
    
    self.le.errorString = @""; // assume no error
    
    // if it's a new flight, queue it.  We set the id to -2 to distinguish it from a new flight.
    // If it's unsubmitted, we just no-op and tell the user it's still queued.
    if (self.le.entryData.isNewOrAwaitingUpload)
        self.le.entryData.FlightID = LogbookEntry.PENDING_FLIGHT_ID;
    
    // add it to the pending flight queue - it will start submitting when recent flights are viewed
    [app queueFlightForLater:self.le];
    [self submitFlightSuccessful];
}

- (void) submitFlight:(id) sender {
    [self submitFlightInternal:NO];
}

- (void) submitPending:(id) sender {
    [self submitFlightInternal:YES];
}

#pragma mark - Binding data to UI
- (void) initLEFromForm {
    // make sure view has actually loaded!
    if (self.idRoute == nil) // should always have a route.
        return;
    
    MFBWebServiceSvc_LogbookEntry * entryData = self.le.entryData;
    
    // Set _le properties that have not been auto-set already
    if (entryData.FlightID == nil)
        entryData.FlightID = @-1;
    entryData.Route = self.idRoute.text;
    entryData.Comment = self.idComments.text;
    entryData.Approaches = self.idApproaches.value;
    entryData.fHoldingProcedures = [[USBoolean alloc] initWithBool:self.idHold.selected];
    entryData.FullStopLandings = self.idDayLandings.value;
    entryData.NightLandings = self.idNightLandings.value;
    entryData.Landings = self.idLandings.value;
    
    entryData.CFI = self.idCFI.value;
    entryData.SIC = self.idSIC.value;
    entryData.PIC = self.idPIC.value;
    entryData.Dual = self.idDual.value;
    entryData.CrossCountry = self.idXC.value;
    entryData.IMC = self.idIMC.value;
    entryData.SimulatedIFR = self.idSimIMC.value;
    entryData.GroundSim = self.idGrndSim.value;
    entryData.Nighttime = self.idNight.value;
    entryData.TotalFlightTime = self.idTotalTime.value;
    
    entryData.fIsPublic = [[USBoolean alloc] initWithBool:self.idPublic.selected];
}

- (void) setDisplayDate: (NSDate *) dt {
    if (self.idDate != nil)
        self.idDate.text = dt.dateString;
}

- (void) resetDateOfFlight {
    if (!self.le.entryData.isNewFlight)
        return;
    
    NSDate * dt = [NSDate date];
    
    if (self.le.entryData.isKnownEngineStart && [self.le.entryData.EngineStart compare:dt] == NSOrderedAscending)
        dt = self.le.entryData.EngineStart;
    if (self.le.entryData.isKnownFlightStart && [self.le.entryData.FlightStart compare:dt] == NSOrderedAscending)
        dt = self.le.entryData.FlightStart;
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDBlockOut)];
    if (cfp != nil && [cfp.DateValue compare:dt] == NSOrderedAscending)
        dt = cfp.DateValue;
    [self setDisplayDate:(le.entryData.Date = dt)];
}

- (void) setCurrentAircraft: (MFBWebServiceSvc_Aircraft *) ac {
    if (ac == nil) {
        self.le.entryData.AircraftID = @0;
        self.le.entryData.TailNumDisplay = self.idPopAircraft.text = @"";
    }
    else {
        BOOL fChanged = ac.AircraftID.integerValue != self.le.entryData.AircraftID.integerValue;
        if (self.idPopAircraft != nil) {
            self.le.entryData.TailNumDisplay = self.idPopAircraft.text = ac.displayTailNumber;
            self.le.entryData.AircraftID = ac.AircraftID;
        }
        
        if (fChanged)
            [self updateTemplatesForAircraft:ac];
    }
}

- (void) initFormFromLE {
    MFBWebServiceSvc_LogbookEntry * entryData = self.le.entryData;
    
    [self setDisplayDate:entryData.Date];
    
    [self setCurrentAircraft:[[Aircraft sharedAircraft] AircraftByID:entryData.AircraftID.intValue]];
    self.idRoute.text = entryData.Route;
    self.idComments.text = entryData.Comment;
    [self.idApproaches setValue:entryData.Approaches withDefault:@0.0];
    [self.idLandings setValue:entryData.Landings withDefault:@0.0];
    [self.idDayLandings setValue:entryData.FullStopLandings withDefault:@0.0];
    [self.idNightLandings setValue:entryData.NightLandings withDefault:@0.0];
    
    [self.idTotalTime setValue:entryData.TotalFlightTime withDefault:@0.0];
    [self.idCFI setValue:entryData.CFI withDefault:@0.0];
    [self.idSIC setValue:entryData.SIC withDefault:@0.0];
    [self.idPIC setValue:entryData.PIC withDefault:@0.0];
    [self.idDual setValue:entryData.Dual withDefault:@0.0];
    [self.idXC setValue:entryData.CrossCountry withDefault:@0.0];
    [self.idIMC setValue:entryData.IMC withDefault:@0.0];
    [self.idSimIMC setValue:entryData.SimulatedIFR withDefault:@0.0];
    [self.idGrndSim setValue:entryData.GroundSim withDefault:@0.0];
    [self.idNight setValue:entryData.Nighttime withDefault:@0.0];
    [self.idHold setCheckboxValue:entryData.fHoldingProcedures.boolValue];
    
    // sharing options
    [self.idPublic setCheckboxValue:entryData.fIsPublic.boolValue];
}

#pragma mark - send actions for a flight
- (void) repeatFlight:(BOOL) fReverse {
    LogbookEntry * leNew = [[LogbookEntry alloc] init];
    
    leNew.entryData  = fReverse ? [self.le.entryData cloneAndReverse] : [self.le.entryData clone];
    leNew.entryData.FlightID = LogbookEntry.QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
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
        
    // New flights
    if (self.le.entryData.isNewFlight || self.le.entryData.isAwaitingUpload || [self.le.entryData isKindOfClass:MFBWebServiceSvc_PendingFlight.class]) {
        [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionAutoFill", @"Flight Action Autofill") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self initLEFromForm];
            if (self.le.entryData.isNewFlight && self.le.entryData.FlightData.length == 0)
                self.le.entryData.FlightData = MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString;
            [GPSSim autoFill:self.le];
            [self initFormFromLE];
        }]];

        if ([self.le.entryData isKindOfClass:MFBWebServiceSvc_PendingFlight.class]) {
            [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionRepeatFlight", @"Flight Action - repeat a flight") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self repeatFlight:NO];
            }]];
            
            [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionReverseFlight", @"Flight Action - repeat and reverse flight") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self repeatFlight:YES];
            }]];
        }
        
        [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"flightActionSavePending", @"Flight Action - Save Pending") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self submitPending:sender];
        }]];
        
        if (self.le.entryData.isNewFlight) {
            [uac addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset", @"Reset button on flight entry") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self resetFlightWithConfirmation];
            }]];
        }
    } else {
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

#pragma mark - New Aircraft
- (IBAction) newAircraft {
    [MyAircraft pushNewAircraftOnViewController:self.navigationController];
}


#pragma mark - Signing flights
- (void) signFlight:(id)sender {
    NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/SignEntry.aspx?idFlight=%d&auth=%@&naked=1",
                        MFBHOSTNAME,
                        [self.le.entryData.FlightID intValue],
                        MFBProfile.sharedProfile.AuthToken.stringByURLEncodingString];
    
    HostedWebViewController * vwWeb = [[HostedWebViewController alloc] initWithUrl:szURL];
    [MFBAppDelegate.threadSafeAppDelegate invalidateCachedTotals];   // this flight could now be invalid
    [self.navigationController pushViewController:vwWeb animated:YES];
}

#pragma mark - Templates
- (void) updateTemplatesForAircraft:(MFBWebServiceSvc_Aircraft *) ac {
    [FlightProps updateTemplates:self.activeTemplates forAircraft:ac];
}

- (void) templatesUpdated:(NSSet<MFBWebServiceSvc_PropertyTemplate *> *) templateSet {
    self.activeTemplates = [NSMutableSet setWithSet:templateSet];
    [self updateTemplatesForAircraft:[Aircraft.sharedAircraft AircraftByID:self.le.entryData.AircraftID.intValue]];
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

#pragma mark - Set Today
- (void) setToday:(UILongPressGestureRecognizer *) sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.idDate resignFirstResponder];
        [self resetDateOfFlight];
    }
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

- (void) setHighWaterTach:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UITextField * target = (UITextField *) sender.view;
        NSNumber * highWaterTach = [[Aircraft sharedAircraft] getHighWaterTachForAircraft:self.le.entryData.AircraftID];
        if (highWaterTach != nil && highWaterTach.doubleValue > 0)
            [self.le.entryData setPropertyValue:@(PropTypeIDTachStart) withDecimal:(target.value = highWaterTach)];
    }
}

#pragma mark NearbyAirportsDelegate
- (void) airportClicked:(MFBWebServiceSvc_airport *) ap {
    if (ap != nil) {
        NSString * newRoute = [Airports appendAirport:ap ToRoute:((self.idRoute == nil) ? self.le.entryData.Route : self.idRoute.text)];
        self.le.entryData.Route = newRoute;
        if (self.idRoute != nil)
            self.idRoute.text = newRoute;
    }
}

- (void) routeUpdated:(NSString *)newRoute {
    self.idRoute.text = self.le.entryData.Route = newRoute;
}

#pragma mark Nearest airports and autofill
- (IBAction) autofillClosest {
    self.le.entryData.Route = self.idRoute.text = [Airports appendNearestAirport:self.idRoute.text];
}

- (void) appendAdHoc:(id) sender {
    NSString * szLatLong = [[[MFBWebServiceSvc_LatLong alloc] initWithCoord:MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc.coordinate] toAdhocString];
    self.le.entryData.Route = self.idRoute.text = [Airports appendAirport:[MFBWebServiceSvc_airport getAdHoc:szLatLong] ToRoute:self.idRoute.text];
}

- (IBAction) viewClosest {
    if (self.navigationController != nil) {
        self.le.entryData.Route = self.idRoute.text;
        NearbyAirports * vwNearbyAirports =[[NearbyAirports alloc] init];
        
        Airports * ap = [[Airports alloc] init];
        [ap loadAirportsFromRoute:self.le.entryData.Route];
        vwNearbyAirports.pathAirports = ap;
        vwNearbyAirports.routeText = self.le.entryData.Route;
        vwNearbyAirports.delegateNearest = ([self.le.entryData isNewFlight] ? self : nil);
        
        vwNearbyAirports.associatedFlight = self.le;
        [vwNearbyAirports getPathForLogbookEntry];
        
        vwNearbyAirports.rgImages = [[NSMutableArray alloc] init];
        
        if (self.le.entryData.isNewFlight)
            self.le.gpxPath = MFBAppDelegate.threadSafeAppDelegate.mfbloc.gpxData;
        
        for (CommentedImage * ci in self.le.rgPicsForFlight)
        {
            if (ci.imgInfo.Location != nil && ci.imgInfo.Location.Latitude != nil && ci.imgInfo.Location.Longitude != nil)
                [vwNearbyAirports.rgImages addObject:ci];
        }
        
        if (self.navigationController != nil)
            [self.navigationController pushViewController:vwNearbyAirports animated:YES];
    }
}

#pragma mark - UIPopoverPresentationController functions
- (void) refreshProperties {
    if (self.le.entryData.isNewOrAwaitingUpload && self.le.entryData.CustomProperties == nil)
        self.le.entryData.CustomProperties = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FlightProps * fp = [FlightProps new];
        [fp loadCustomPropertyTypes];
    });
}
@end
