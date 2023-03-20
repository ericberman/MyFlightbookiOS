/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2023 MyFlightbook, LLC
 
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
//  LEEditController.m
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//

#import "LEEditController.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ImageComment.h"
#import "FlightProperties.h"
#import "PropertyCell.h"
#import "ButtonCell.h"
#import "math.h"
#import "TextCell.h"

@interface LEEditController()
@property (nonatomic, strong) NSTimer * timerElapsed;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, PropertyCell *> * dictPropCells;
@property (nonatomic, strong) UIImage * digitizedSig;
@property (nonatomic, strong) NSArray<MFBWebServiceSvc_Aircraft *> * selectibleAircraft;
@property (nonatomic, strong) UIDatePicker * propDatePicker;

- (void) updatePausePlay;
- (void) updatePositionReport;
- (void) startEngine;
- (void) stopEngine;
- (void) startFlight;
- (void) stopFlight;
- (void) viewProperties:(UIView *) sender;
@end

@implementation LEEditController

@synthesize timerElapsed;
@synthesize dictPropCells;
@synthesize digitizedSig;
@synthesize selectibleAircraft;
@synthesize propDatePicker;

NSString * const _szKeyCachedImageArray = @"cachedImageArrayKey";
NSString * const _szkeyITCCollapseState = @"keyITCCollapseState";

enum sections {sectGeneral, sectInCockpit, sectTimes, sectProperties, sectSignature, sectImages, sectSharing, sectLast};
enum rows {
    rowGeneralFirst, rowDateTail = rowGeneralFirst, rowComments, rowRoute, rowLandings, rowGeneralLast=rowLandings,
    rowCockpitFirst, rowCockpitHeader = rowCockpitFirst, rowGPS, rowTachStart, rowHobbsStart, rowEngineStart, rowBlockOut, rowFlightStart, rowFlightEnd, rowBlockIn, rowEngineEnd, rowHobbsEnd, rowTachEnd,
    rowTimes,
    rowPropertiesHeader, rowAddProperties,
    rowSigFirst, rowSigHeader, rowSigState, rowSigComment, rowSigValidity, rowSigLast = rowSigValidity,
    rowImagesHeader,
    rowSharingHeader,
    rowSharing,
    rowImageFirst = 1000,
    rowPropertyFirst = 10000
};

CGFloat heightDateTail, heightComments, heightRoute, heightLandings, heightGPS, heightTimes, heightSharing;

#pragma mark - Object Life Cycle / initialization
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        // Custom initialization
    }
    return self;
}

- (void) asyncLoadDigitizedSig
{
    @autoreleasepool {
        NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/ViewSig.aspx?id=%d", MFBHOSTNAME, self.le.entryData.FlightID.intValue];
        self.digitizedSig = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:szURL]]];
        [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.flightProps = [[FlightProps alloc] init];

    // row heights seem to change for some strange reason.
    heightComments = self.cellComments.frame.size.height;
    heightDateTail = self.cellDateAndTail.frame.size.height;
    heightGPS = self.cellGPS.frame.size.height;
    heightLandings = self.cellLandings.frame.size.height;
    heightRoute = self.cellRoute.frame.size.height;
    heightSharing = self.cellSharing.frame.size.height;
    heightTimes = self.cellTimeBlock.frame.size.height;
    
    if (self.propDatePicker == nil)
        self.propDatePicker = [UIDatePicker new];
    
    // And set up remaining inputviews/accessory views
    self.idDate.inputView = self.datePicker;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        self.propDatePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    self.idPopAircraft.inputView = self.pickerView;
    self.idComments.inputAccessoryView = self.idRoute.inputAccessoryView = self.idDate.inputAccessoryView = self.idPopAircraft.inputAccessoryView = self.vwAccessory;
    self.idComments.delegate = self;
    self.idPopAircraft.delegate = self.idRoute.delegate = self;

	// self.le should be nil on first run, in which case we load up a flight
	// in progress or start a new one (if no saved state).
	// if self.le is already set up, we should be good to go with it.
	if (self.le == nil)
        [self restoreFlightInProgress];
    
    // Check to see if this is a pending flight
    BOOL fIsPendingFlight = [self.le.entryData isKindOfClass:[MFBWebServiceSvc_PendingFlight class]];
    
    // If we have an unknown aircraft and just popped from creating one, then reset preferred aircraft
    if ([self.le.entryData.AircraftID intValue] <= 0)
        [self setCurrentAircraft:[[Aircraft sharedAircraft] preferredAircraft]];
    
    MFBWebServiceSvc_Aircraft * ac = [Aircraft.sharedAircraft AircraftByID:self.le.entryData.AircraftID.intValue];
    self.activeTemplates = [NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> setWithArray: (ac.DefaultTemplates.int_.count > 0) ? [MFBWebServiceSvc_PropertyTemplate templatesWithIDs:ac.DefaultTemplates.int_] : MFBWebServiceSvc_PropertyTemplate.defaultTemplates];
    [self templatesUpdated:self.activeTemplates];
	
	[self initFormFromLE];
    
    [self refreshProperties];
    
    [self.expandedSections removeAllIndexes];
    if ([self.le.rgPicsForFlight count] > 0)
        [self.expandedSections addIndex:sectImages];
    if ([self.le.entryData isNewFlight])
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:_szkeyITCCollapseState])
            [self.expandedSections addIndex:sectInCockpit];
        [self.expandedSections addIndex:sectProperties];
    }
    if (self.le.entryData.isSigned)
        [self.expandedSections addIndex:sectSignature];
    
    [self.expandedSections addIndex:sectSharing];
    
    /* Set up toolbar and submit buttons */
    UIBarButtonItem * biSign = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"SignFlight", @"Let a CFI sign this flight")
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(signFlight:)];
    
    UIBarButtonItem * biSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * biOptions = [[UIBarButtonItem alloc]
                                    initWithTitle:NSLocalizedString(@"Options", @"Options button for autodetect, etc.")
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(configAutoDetect)];
    
	UIBarButtonItem * bbGallery = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImages:)];
	UIBarButtonItem * bbCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    UIBarButtonItem * bbSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendFlight:)];
    bbGallery.enabled = self.canUsePhotoLibrary;
    bbCamera.enabled = self.canUseCamera;
    
    bbGallery.style = bbCamera.style = bbSend.style = UIBarButtonItemStylePlain;
    
    NSMutableArray * ar = [[NSMutableArray alloc] init];
    if (fIsPendingFlight) {
        // Pending flight: Only option other than "Add" is "Add Pending"
        [ar addObject:bbSend];
    }
    else {
        if ([self.le.entryData isNewFlight])
            [ar addObject:biOptions];

        if (![self.le.entryData isNewOrAwaitingUpload] && self.le.entryData.CFISignatureState != MFBWebServiceSvc_SignatureState_Valid)
            [ar addObject:biSign];
        [ar addObject:bbSend];
        [ar addObject:biSpacer];
        [ar addObject:bbGallery];
        [ar addObject:bbCamera];
    }
    
    self.navigationController.toolbarHidden = NO;
    self.toolbarItems = ar;
    
    // Submit button
    UIBarButtonItem * bbSubmit = [[UIBarButtonItem alloc]
                                   initWithTitle:[self.le.entryData isNewOrAwaitingUpload] ? NSLocalizedString(@"Add", @"Generic Add") : NSLocalizedString(@"Update", @"Update")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(submitFlight:)];
    
    self.navigationItem.rightBarButtonItem = bbSubmit;
    
    if ([self.le.entryData isNewFlight])
    {
        self.timerElapsed = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updatePausePlay) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timerElapsed forMode:NSDefaultRunLoopMode];
    }

    self.dictPropCells = [[NSMutableDictionary alloc] init];
    
    if (self.le.entryData.isSigned && self.le.entryData.HasDigitizedSig)
        [NSThread detachNewThreadSelector:@selector(asyncLoadDigitizedSig) toTarget:self withObject:nil];
    
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    [mfbApp() registerNotifyResetAll:self];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	[self saveState]; // just in case...
	
	if ([self.le.rgPicsForFlight count] > 0)
		for (CommentedImage * ci in self.le.rgPicsForFlight)
			[ci flushCachedImage];
    self.selectibleAircraft = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[self initLEFromForm];
    self.navigationController.toolbarHidden = YES;
    [self.dictPropCells removeAllObjects];
    [self saveState];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;    
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    MFBAppDelegate * app = mfbApp();
    
    // Pick up an aircraft if one was added and none had been selected
    if ([self.idPopAircraft.text length] == 0)
    {
        MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] preferredAircraft];
        if (ac != nil)
        {
            self.idPopAircraft.text = ac.displayTailNumber;
            self.le.entryData.AircraftID = ac.AircraftID;
            self.le.entryData.TailNumDisplay = ac.displayTailNumber;
        }
    }
    
	[self initFormFromLE]; // pick up any potential changes
	
	[self saveState]; // keep things in sync with any changes
    
    // the option to record could have changed; if so, and if we are in-flight, need to start recording.
    if (app.mfbloc.fRecordFlightData && [self flightCouldBeInProgress])
        [app.mfbloc startRecordingFlightData];
    
    if (app.mfbloc.lastSeenLoc != nil)
    {
        [self newLocation:app.mfbloc.lastSeenLoc];
        [self updatePositionReport];
    }
    
    // enable/disable the add/update button based on sign-in state
    self.navigationItem.rightBarButtonItem.enabled = mfbApp().userProfile.isValid;
    
    // Initialize the list of selectibleAircraft and hold on to it
    // We do this on each view-will-appear so that we can pick up any aircraft that have been shown/hidden.
    self.selectibleAircraft = [Aircraft.sharedAircraft AircraftForSelection:self.le.entryData.AircraftID];

    // And reload the aircraft picker regardless, in case it changed too
    [self.pickerView reloadAllComponents];

    [self.tableView reloadData];
	[app ensureWarningShownForUser];
}

- (BOOL) flightCouldBeInProgress
{
    return self.le.entryData.flightCouldBeInProgress;
}

#pragma mark Pausing of flight and auto time
// TODO: time paused and the computation of elapsed time should be moved into LogbookEntry object, not here.  Can be consumed by watchkit directly then too.
- (NSTimeInterval) timePaused
{
    return [[NSDate date] timeIntervalSinceReferenceDate] - self.le.dtTimeOfLastPause;
}

- (NSTimeInterval) elapsedTime
{
    NSTimeInterval dtTotal = 0;
    NSTimeInterval dtFlight = 0;
    NSTimeInterval dtEngine = 0;
    
    if ([self.le.entryData isKnownFlightStart])
    {
        if ([NSDate isUnknownDate:self.le.entryData.FlightEnd]) // in flight
            dtFlight = [[NSDate date] timeIntervalSinceReferenceDate] - [self.le.entryData.FlightStart timeIntervalSinceReferenceDate];
        else
            dtFlight = [self.le.entryData.FlightEnd timeIntervalSinceReferenceDate] - [self.le.entryData.FlightStart timeIntervalSinceReferenceDate];
    }
    
    if ([self.le.entryData isKnownEngineStart])
    {
        if ([NSDate isUnknownDate:self.le.entryData.EngineEnd])
            dtEngine = [[NSDate date] timeIntervalSinceReferenceDate] - [self.le.entryData.EngineStart timeIntervalSinceReferenceDate];
        else
            dtEngine = [self.le.entryData.EngineEnd timeIntervalSinceReferenceDate] - [self.le.entryData.EngineStart timeIntervalSinceReferenceDate];
    }
    
    autoTotal totalsMode = UserPreferences.current.autoTotalMode;
    
    // if totals mode is FLIGHT TIME, then elapsed time is based on flight time if/when it is known.
    // OTHERWISE, we use engine time (if known) or else flight time.
    if (totalsMode == autoTotalFlight)
        dtTotal = [self.le.entryData isKnownFlightStart] ? dtFlight : 0;
    else
        dtTotal = [self.le.entryData isKnownEngineStart] ? dtEngine : dtFlight;
    
    dtTotal -= [self.le totalTimePaused];
    if (dtTotal <= 0)
        dtTotal = 0; // should never happen
    
    return dtTotal;
}

- (void) updatePausePlay
{
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;

    [self.idbtnPausePlay setImage:[UIImage imageNamed:self.le.fIsPaused ? @"Play.png" : @"Pause.png"] forState:0];
    BOOL fCouldBeFlying = ([self.le.entryData isKnownEngineStart] || [self.le.entryData isKnownFlightStart]) && ![self.le.entryData isKnownEngineEnd];
    BOOL fShowPausePlay = app.mfbloc.currentFlightState != FlightStateFsInFlight && fCouldBeFlying;
    self.idbtnPausePlay.hidden = !fShowPausePlay;

    self.idlblElapsedTime.text = [self elapsedTimeDisplay:self.elapsedTime];
    
    app.mfbloc.fRecordingIsPaused = self.le.fIsPaused;
    
    // Update any data that the watch might poll
    app.watchData.elapsedSeconds = self.elapsedTime;
    app.watchData.isPaused = self.le.fIsPaused;
    if (self.le.entryData.isKnownEngineEnd)
        app.watchData.flightStage = flightStageDone;
    else if (fCouldBeFlying)
        app.watchData.flightStage = flightStageInProgress;
    else
        app.watchData.flightStage = flightStageUnstarted;
}

- (void) toggleFlightPause
{
    autoTotal totalsMode = UserPreferences.current.autoTotalMode;
    
    // don't pause or play if we're not flying/engine started
    if ([self.le.entryData isKnownFlightStart] ||
         (totalsMode != autoTotalFlight && [self.le.entryData isKnownEngineStart]))
    {
        if (self.le.fIsPaused)
            [self.le unPauseFlight];
        else
            [self.le pauseFlight];
    }
    else
    {
        [self.le unPauseFlight];
        self.le.dtTotalPauseTime = 0;
    }

    [self updatePausePlay];
    [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
}

- (void) pauseFlightExternal {
    if (!self.le.fIsPaused)
        [self toggleFlightPause];
}

- (void) resumeFlightExternal {
    if (self.le.fIsPaused)
        [self toggleFlightPause];
}

#pragma mark - Read/Write Form

- (void) initFormFromLE:(BOOL) fReloadTable
{
    [super initFormFromLE];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray<CommentedImage *> * rgCiLocal = [NSMutableArray new];
        for (CommentedImage * ci in self.le.rgPicsForFlight)
            if (!ci.imgInfo.livesOnServer)
                [rgCiLocal addObject:ci];
        NSMutableArray * rgPics = [NSMutableArray new];
        if ([CommentedImage initCommentedImagesFromMFBII:self.le.entryData.FlightImages.MFBImageInfo toArray:rgPics]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.le.rgPicsForFlight = rgPics;
                [rgPics addObjectsFromArray:rgCiLocal];
                [self.tableView reloadData];
                if (self.self.le.rgPicsForFlight.count > 0 && ![self isExpanded:sectImages])
                    [self expandSection:sectImages];
            });
        }
    });
    
    [self updatePausePlay];
    
    self.idimgRecording.hidden = !mfbApp().mfbloc.fRecordFlightData || ![self flightCouldBeInProgress];
    mfbApp().watchData.isRecording = !self.idimgRecording.hidden;
    
    if (fReloadTable)
        [self.tableView reloadData];
}

- (void) initFormFromLE {
    [self initFormFromLE:YES];
}

#pragma mark "Next" button inflation
enum nextTime {timeHobbsStart, timeEngineStart, timeFlightStart, timeFlightEnd, timeEngineEnd, timeHobbsEnd, timeNone};

#pragma mark - In The Cockpit customization
- (NSNumber *) propIDFromCockpitRow:(NSInteger) row {
    switch (row) {
        case rowBlockIn:
            return @(PropTypeIDBlockIn);
        case rowBlockOut:
            return @(PropTypeIDBlockOut);
        case rowTachStart:
            return @(PropTypeIDTachStart);
        case rowTachEnd:
            return @(PropTypeIDTachEnd);
        default:
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"row %li doesn't correspond to a property row", (long)row] userInfo:nil];
    }
}

static NSArray * rgAllCockpitRows = nil;

- (NSArray<NSNumber *> *) cockpitRows {
    if (rgAllCockpitRows == nil)
        rgAllCockpitRows = @[@(rowCockpitHeader), @(rowGPS),@(rowTachStart),@(rowHobbsStart),@(rowEngineStart),@(rowBlockOut),@(rowFlightStart),@(rowFlightEnd),@(rowBlockIn),@(rowEngineEnd),@(rowHobbsEnd),@(rowTachEnd)];
    
    MFBWebServiceSvc_LogbookEntry * l = self.le.entryData;
    return [rgAllCockpitRows filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSNumber *  _Nullable row, NSDictionary<NSString *,id> * _Nullable bindings) {
        switch (row.intValue) {
            case rowTachStart:
            case rowTachEnd:
                return UserPreferences.current.showTach;
            case rowHobbsStart:
            case rowHobbsEnd:
                // Have to show hobbs if present since it won't show in properties
                return UserPreferences.current.showHobbs || l.HobbsStart.doubleValue > 0.0 || l.HobbsEnd.doubleValue > 0.0;
            case rowEngineStart:
            case rowEngineEnd:
                // Have to show engine if present since it won't show in properties
                return UserPreferences.current.showEngine || l.isKnownEngineStart || l.isKnownEngineEnd;
            case rowBlockOut:
            case rowBlockIn:
                return UserPreferences.current.showBlock;
            case rowFlightStart:
            case rowFlightEnd:
                // Have to show flight if present since it won't show in properties
                return UserPreferences.current.showFlight || l.isKnownFlightStart || l.isKnownFlightEnd;
            case rowGPS:
                return self.le.entryData.isNewFlight;
            default:
                return YES;
        }
    }]];
}

// Return the set of properties that should show in the properties section.  Excludes block times if in-the-cockpit block option is on, excludes tach if tach option is on
- (NSArray<MFBWebServiceSvc_CustomFlightProperty *> *) propsForPropsSection {
    return [self.le.entryData.CustomProperties.CustomFlightProperty filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MFBWebServiceSvc_CustomFlightProperty * _Nullable cfp, NSDictionary<NSString *,id> * _Nullable bindings) {
        switch (cfp.PropTypeID.intValue) {
            case PropTypeIDBlockOut:
            case PropTypeIDBlockIn:
                return !UserPreferences.current.showBlock;
            case PropTypeIDTachStart:
            case PropTypeIDTachEnd:
                return !UserPreferences.current.showTach;
            default:
                return YES;
        }
    }]];
}

#pragma mark - TableViewDatasource
- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) ip
{
    NSInteger row = ip.row;
    
    switch (ip.section)
    {
        case sectGeneral:
            return rowGeneralFirst + row;
        case sectImages:
            return (row == 0) ? rowImagesHeader : rowImageFirst + row;
        case sectInCockpit:
            // cockpit rows should be a complete set of rows, including header.
            return self.cockpitRows[row].intValue;
        case sectProperties:
            return (row == 0) ? rowPropertiesHeader : ((row == self.propsForPropsSection.count + 1) ? rowAddProperties : rowPropertyFirst + row);
        case sectSharing:
            return (row == 0) ? rowSharingHeader : rowSharing;
        case sectTimes:
            return rowTimes;
        case sectSignature:
            return rowSigHeader + row;
        default:
            return 0;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectLast;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case sectGeneral:
            return rowGeneralLast - rowGeneralFirst + 1;
        case sectImages:
            return ([self.le.rgPicsForFlight count] == 0) ? 0 : 1 + ([self isExpanded:sectImages] ? ([self.le.rgPicsForFlight count]) : 0);
        case sectInCockpit:
            return [self isExpanded:sectInCockpit] ? self.cockpitRows.count : 1;
        case sectProperties:
            return 1 + ([self isExpanded:sectProperties] ? self.propsForPropsSection.count + 1 : 0);
        case sectSharing:
            return [self isExpanded:sectSharing] ? 2 : 1;
        case sectTimes:
            return 1;
        case sectSignature:
            return self.le.entryData.isSigned ? ([self isExpanded:sectSignature] ? rowSigLast - rowSigFirst : 1) : 0;
        default:
            return 0;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case sectSignature:
            return self.le.entryData.CFISignatureState == MFBWebServiceSvc_SignatureState_None ? nil : @"";
        default:
            return @"";
    }
}

- (void) hobbsChanged:(UITextField *) sender
{
    EditCell * ec = [self owningCell:sender];
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:ec]];
    if (row == rowHobbsStart)
        self.le.entryData.HobbsStart = sender.value;
    else
        self.le.entryData.HobbsEnd = sender.value;
}

- (void) tachChanged:(UITextField *) sender {
    EditCell * ec = [self owningCell:sender];
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:ec]];
    NSNumber * propTypeID = (row == rowTachStart) ? @(PropTypeIDTachStart) : @(PropTypeIDTachEnd);
    if (sender.value.intValue == 0) {
        NSError * err = nil;
        [self.le.entryData removeProperty:propTypeID withServerAuth:mfbApp().userProfile.AuthToken deleteSvc:self.flightProps error:&err]; // delete if default value
    }
    else
        [self.le.entryData setPropertyValue:propTypeID withDecimal:sender.value];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    
    switch (row)
    {
        case rowCockpitHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"In the Cockpit", @"In the Cockpit") forSection:sectInCockpit initialState:[self isExpanded:sectInCockpit]];
        case rowImagesHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"Images", @"Images Header") forSection:sectImages initialState:[self isExpanded:sectImages]];
        case rowPropertiesHeader: {
            ExpandHeaderCell * cell = [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"Properties", @"Properties Header") forSection:sectProperties initialState:[self isExpanded:sectProperties]];
            if (FlightProps.sharedTemplates.count > 0) {
                cell.DisclosureButton.hidden = NO;
                [cell.DisclosureButton addTarget:self action:@selector(pickTemplates:) forControlEvents:UIControlEventTouchDown];
            }
            return cell;
        }
        case rowSigHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"sigHeader", @"Signature Section Title") forSection:sectSignature initialState:YES];
        case rowDateTail:
            return self.cellDateAndTail;
        case rowComments:
            return self.cellComments;
        case rowRoute:
            return self.cellRoute;
        case rowLandings:
            return self.cellLandings;
        case rowGPS:
            self.cellGPS.accessoryType = self.hasAccessories ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            return self.cellGPS;
        case rowHobbsStart: {
            EditCell * dcell = [self decimalCell:tableView withPrompt:NSLocalizedString(@"Hobbs Start:", @"Hobbs Start prompt") andValue:self.le.entryData.HobbsStart selector:@selector(hobbsChanged:) andInflation:NO];
            [self enableLongPressForField:dcell.txt withSelector:@selector(setHighWaterHobbs:)];
            return dcell;
        }
        case rowHobbsEnd:
            return [self decimalCell:tableView withPrompt:NSLocalizedString(@"Hobbs End:", @"Hobbs End prompt") andValue:self.le.entryData.HobbsEnd selector:@selector(hobbsChanged:) andInflation:NO];
        case rowEngineStart:
            return [self dateCell:self.le.entryData.EngineStart withPrompt:NSLocalizedString(@"Engine Start:", @"Engine Start prompt") forTableView:self.tableView inflated:NO];
        case rowEngineEnd:
            return [self dateCell:self.le.entryData.EngineEnd withPrompt:NSLocalizedString(@"Engine Stop:", @"Engine Stop prompt") forTableView:self.tableView inflated:NO];
        case rowFlightStart:
            return [self dateCell:self.le.entryData.FlightStart withPrompt:NSLocalizedString(@"First Takeoff:", @"First Takeoff prompt") forTableView:self.tableView inflated:NO];
        case rowFlightEnd:
            return [self dateCell:self.le.entryData.FlightEnd withPrompt:NSLocalizedString(@"Last Landing:", @"Last Landing prompt") forTableView:self.tableView inflated:NO];
        case rowTachStart: {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDTachStart)];
            EditCell * dcell = [self decimalCell:tableView withPrompt:NSLocalizedString(@"TachStart", @"Tach Start prompt") andValue:(cfp == nil) ? @(0) : cfp.DecValue selector:@selector(tachChanged:) andInflation:NO];
            [self enableLongPressForField:dcell.txt withSelector:@selector(setHighWaterTach:)];
            return dcell;
        }
        case rowTachEnd: {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDTachEnd)];
            return [self decimalCell:tableView withPrompt:NSLocalizedString(@"TachEnd", @"Tach End prompt") andValue:(cfp == nil) ? @(0) : cfp.DecValue selector:@selector(tachChanged:) andInflation:NO];
        }
        case rowBlockOut: {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDBlockOut)];
            return [self dateCell:cfp.DateValue withPrompt:NSLocalizedString(@"BlockOut", @"Block Out prompt") forTableView:tableView inflated:NO];
        }
        case rowBlockIn: {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDBlockIn)];
            return [self dateCell:cfp.DateValue withPrompt:NSLocalizedString(@"BlockIn", @"Block In prompt") forTableView:tableView inflated:NO];
        }
        case rowTimes:
            return self.cellTimeBlock;
        case rowSharingHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"Sharing", @"Sharing Header") forSection:sectSharing initialState:[self isExpanded:sectSharing]];
        case rowSharing:
            return self.cellSharing;
        case rowAddProperties:
        {
            static NSString * cellID = @"EditPropsCell";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"Flight Properties", @"Flight Properties");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case rowSigState:
        {
            static NSString * cellID = @"SigStateCell";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            NSDateFormatter * df = [NSDateFormatter new];
            df.dateStyle = NSDateFormatterShortStyle;
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"sigStateTemplate1", @"Signature Status - date and CFI"), [df stringFromDate:self.le.entryData.CFISignatureDate], self.le.entryData.CFIName];
            if (self.le.entryData.CFIExpiration)
            cell.detailTextLabel.text = [NSDate isUnknownDate:self.le.entryData.CFIExpiration] ?
                [NSString stringWithFormat:NSLocalizedString(@"sigStateTemplate2NoExp", @"Signature Status - certificate & No Expiration"), self.le.entryData.CFICertificate] :
                [NSString stringWithFormat:NSLocalizedString(@"sigStateTemplate2", @"Signature Status - certificate & Expiration"), self.le.entryData.CFICertificate, [df stringFromDate:self.le.entryData.CFIExpiration]];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageView.image = [UIImage imageNamed:self.le.entryData.CFISignatureState == MFBWebServiceSvc_SignatureState_Valid ? @"sigok" : @"siginvalid"];
            return cell;
        }
            break;
        case rowSigComment:
        {
            TextCell * tc = [TextCell getTextCell:tableView];
            tc.accessoryType = UITableViewCellAccessoryNone;
            tc.txt.text = self.le.entryData.CFIComments;
            tc.selectionStyle = UITableViewCellSelectionStyleNone;
            tc.txt.adjustsFontSizeToFitWidth = YES;
            return tc;
        }
            break;
            
        case rowSigValidity:
        {
            static NSString * cellID = @"SigValidityCell";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = (self.le.entryData.CFISignatureState == MFBWebServiceSvc_SignatureState_Valid) ? NSLocalizedString(@"sigStateValid", @"Signature Valid") : NSLocalizedString(@"sigStateInvalid", @"Signature Invalid");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.imageView.image = self.digitizedSig;
            return cell;
        }
            break;
        default:
            if (indexPath.section == sectImages)
            {
                // TODO: This is common with aircraft; should be moved to util or somesuch.
                static NSString *CellIdentifier = @"cellImage";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                NSInteger imageIndex = indexPath.row - 1;
                if (imageIndex >= 0 && imageIndex < [self.le.rgPicsForFlight count])
                {
                    CommentedImage * ci = (CommentedImage *) (self.le.rgPicsForFlight)[imageIndex];
                    cell.indentationLevel = 1;
                    cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    cell.textLabel.text = ci.imgInfo.Comment;
                    cell.textLabel.numberOfLines = 3;
                    if (ci.hasThumbnailCache)
                        cell.imageView.image = [ci GetThumbnail];
                    else
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [ci GetThumbnail];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        });
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.indentationWidth = 10.0;
                }
                return cell;

            }
            else if (indexPath.section == sectProperties)
            {
                MFBWebServiceSvc_CustomFlightProperty * cfp = self.propsForPropsSection[indexPath.row - 1];
                MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps propTypeFromID:cfp.PropTypeID];
                PropertyCell * pc = (PropertyCell *) (self.dictPropCells)[cpt.PropTypeID];
                if (pc == nil)
                {
                    pc = [PropertyCell getPropertyCell:tableView withCPT:cpt andFlightProperty:cfp];
                    (self.dictPropCells)[cpt.PropTypeID] = pc;
                }
                else
                    pc.cfp = cfp;
                pc.txt.delegate = self;
                pc.flightPropDelegate = self.flightProps;
                [pc configureCell:self.vwAccessory andDatePicker:self.propDatePicker defValue:[self.le.entryData xfillValueForPropType:cpt]];
                return pc;
            }
    }
    @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in LEEditController with invalid indexpath" userInfo:@{@"indexpath":indexPath}];
}

#pragma mark - TableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row)
    {
        case rowDateTail:
            return heightDateTail;
        case rowComments:
            return heightComments;
        case rowRoute:
            return heightRoute;
        case rowLandings:
            return heightLandings;
        case rowGPS:
            return heightGPS;
        case rowTimes:
            return heightTimes;
        case rowSharing:
            return heightSharing;
        case rowSigComment:
            if ([self cellIDFromIndexPath:indexPath] == rowSigComment && self.le.entryData.CFIComments.length == 0)
                return 0;
            else
                return UITableViewAutomaticDimension;
        default:
            if (indexPath.section == sectImages && indexPath.row > 0)
                return 100;
            else if (indexPath.section == sectProperties && row != rowPropertiesHeader && row != rowAddProperties)
                return 57;
            return UITableViewAutomaticDimension;
    }
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    if (indexPath.section == sectImages && row >= rowImageFirst)
        return YES;
    if (indexPath.section == sectProperties && row >= rowPropertyFirst)
    {
        MFBWebServiceSvc_CustomFlightProperty * cfp = self.propsForPropsSection[indexPath.row - 1];
        MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps propTypeFromID:cfp.PropTypeID];
        return !cpt.isLocked;
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NSLocalizedString(@"Delete", @"Title for 'delete' button in image list");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
        if (indexPath.section == sectImages)
        {
            CommentedImage * ci = (CommentedImage *) (self.le.rgPicsForFlight)[indexPath.row - 1];
            [ci deleteImage:(mfbApp()).userProfile.AuthToken];
            
            // then remove it from the array
            [self.le.rgPicsForFlight removeObjectAtIndex:indexPath.row - 1];
            NSMutableArray * ar = [[NSMutableArray alloc] initWithObjects:indexPath, nil];
            // If deleting the last image we will delete the whole section, so delete the header row too
            if ([self.le.rgPicsForFlight count] == 0)
                [ar addObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
            [tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationFade];
        }
        else if (indexPath.section == sectProperties)
        {
            NSError * err = nil;
            [self.le.entryData removeProperty:self.propsForPropsSection[indexPath.row - 1].PropTypeID withServerAuth:mfbApp().userProfile.AuthToken deleteSvc:self.flightProps error:&err];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectImages && indexPath.row > 0)
    {
        [self.tableView endEditing:YES];
        ImageComment * ic = [[ImageComment alloc] initWithNibName:@"ImageComment" bundle:nil];
        ic.ci = (CommentedImage *) (self.le.rgPicsForFlight)[indexPath.row - 1];
        [self.navigationController pushViewController:ic animated:YES];
        return;
    }
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    switch ([self cellIDFromIndexPath:indexPath])
    {
        case rowAddProperties:
            [self viewProperties:cell];
            break;
        case rowPropertiesHeader:
        case rowCockpitHeader:
        case rowImagesHeader:
        case rowSharingHeader:
            [self toggleSection:indexPath.section];
            // preserve the state of ITC expansion
            if ([self.le.entryData isNewFlight])
            {
                [[NSUserDefaults standardUserDefaults] setBool:![self isExpanded:indexPath.section] forKey:_szkeyITCCollapseState];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case rowSigHeader:
            [self toggleSection:indexPath.section];
            break;
        case rowHobbsEnd:
        case rowHobbsStart:
        case rowEngineStart:
        case rowEngineEnd:
        case rowFlightEnd:
        case rowFlightStart:
        case rowComments:
        case rowRoute:
        {
            [((NavigableCell *) [self.tableView cellForRowAtIndexPath:indexPath]).firstResponderControl becomeFirstResponder];
            return;
        }
        case rowGPS:
            [self viewAccessories];
            break;
        default:
        {
            // We've already excluded propheader and add properties above.
            if (indexPath.section == sectProperties)
            {
                PropertyCell * pc = (PropertyCell *) [self.tableView cellForRowAtIndexPath:indexPath];
                if ([pc handleClick])
                {
                    [self.flightProps propValueChanged:pc.cfp];
                    if ([pc.cfp isDefaultForType:pc.cpt] && !pc.cpt.isLocked && ![[MFBWebServiceSvc_PropertyTemplate propListForSets:self.activeTemplates] containsObject:pc.cpt.PropTypeID]) {
                        [self.le.entryData removeProperty:pc.cfp.PropTypeID];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    else
                        [self.tableView reloadData];
                }
            }
        }
    }
    
    [self.tableView endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL) dateClick:(NSDate *) dt onInit:(void (^)(NSDate *))completionBlock
{
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }

    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];

    // see if this is a "Tap for today" click - if so, set to today and resign.
    if ([ec.txt.text length] == 0 || [NSDate isUnknownDate:dt])
    {
        BOOL fWasUnknownEngineStart = [NSDate isUnknownDate:self.le.entryData.EngineStart];
        BOOL fWasUnknownFlightStart = [NSDate isUnknownDate:self.le.entryData.FlightStart];
        BOOL fWasUnknownBlockOut = [NSDate isUnknownDate:[self.le.entryData getExistingProperty:@(PropTypeIDBlockOut)].DateValue];
        
        // Since we don't display seconds, truncate them; this prevents odd looking math like
        // an interval from 12:13:59 to 12:15:01, which is a 1:02 but would display as 12:13-12:15 (which looks like 2 minutes)
        // By truncating the time, we go straight to 12:13:00 and 12:15:00, which will even yield 2 minutes.
        if (dt == nil || [NSDate isUnknownDate:dt])
            self.datePicker.date = dt = NSDate.date.dateByTruncatingSeconds;
        
        completionBlock(dt);
        ec.txt.text = [NSDate isUnknownDate:dt] ? @"" : [dt utcString:UserPreferences.current.UseLocalTime];
        [self.tableView endEditing:YES];
        
        NSInteger row = [self cellIDFromIndexPath:self.ipActive];
        switch (row)
        {
            case rowEngineStart:
                [self startEngine];
                if (fWasUnknownEngineStart && self.le.entryData.isNewFlight)
                    [self resetDateOfFlight];
                break;
            case rowEngineEnd:
                [self stopEngine];
                break;
            case rowFlightStart:
                [self startFlight];
                if (fWasUnknownEngineStart && fWasUnknownFlightStart && self.le.entryData.isNewFlight)
                    [self resetDateOfFlight];
                break;
            case rowFlightEnd:
                [self stopFlight];
                break;
            case rowBlockOut:
                if (fWasUnknownBlockOut)
                    [self resetDateOfFlight];
                break;
            case rowBlockIn:
                break;
        }
        return NO;
    }
    
    self.datePicker.date = dt;
    self.datePicker.timeZone = UserPreferences.current.UseLocalTime ? [NSTimeZone systemTimeZone] : [NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.locale = UserPreferences.current.UseLocalTime ? [NSLocale currentLocale] : [NSLocale localeWithLocaleIdentifier:@"en-GB"];
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL fShouldEdit = YES;
    UITableViewCell * tc = [self owningCellGeneric:textField];
    self.ipActive = [self.tableView indexPathForCell:tc];
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    
    [self enableNextPrev:self.vwAccessory];
    // fix up where enableNextPrev can fail
    self.vwAccessory.btnPrev.enabled = (textField != self.idDate);
    if ([tc isKindOfClass:[NavigableCell class]] && textField != ((NavigableCell *)tc).lastResponderControl)
        self.vwAccessory.btnNext.enabled = YES;
    self.vwAccessory.btnDelete.enabled = (textField != self.idDate && textField != self.idPopAircraft);
    
    // see if it's an engine/flight date
    switch (row)
    {
        case rowEngineStart:
        {
            [self dateClick:self.le.entryData.EngineStart onInit:^void (NSDate * d) { self.le.entryData.EngineStart = d;}];
        }
            break;
        case rowEngineEnd:
        {
            [self dateClick:self.le.entryData.EngineEnd onInit:^void (NSDate * d) { self.le.entryData.EngineEnd = d;}];
        }
            break;
        case rowFlightStart:
        {
            [self dateClick:self.le.entryData.FlightStart onInit:^void (NSDate * d) { self.le.entryData.FlightStart = d;}];
        }
            break;
        case rowFlightEnd:
        {
            [self dateClick:self.le.entryData.FlightEnd onInit:^void (NSDate * d) { self.le.entryData.FlightEnd = d;}];
        }
            break;
        case rowBlockOut:
        case rowBlockIn: {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:[self propIDFromCockpitRow:row]];
            [self dateClick:cfp == nil ? NSDate.distantPast : cfp.DateValue onInit:^(NSDate * d) {
                [self.le.entryData setPropertyValue:[self propIDFromCockpitRow:row] withDate:d];
            }];
            break;
        }
        default:
            if (self.ipActive.section == sectProperties && row >= rowPropertyFirst) {
                PropertyCell * pc = (PropertyCell *) tc;
                fShouldEdit = [pc prepForEditing];
                if (!fShouldEdit)
                {
                    if (pc.cfp.PropTypeID.intValue == PropTypeIDBlockOut)
                        [self dateOfFlightShouldReset:pc.cfp.DateValue];
                    if (pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime)
                        [self propertyUpdated:pc.cpt];
                }
            }
            break;
    }
    
    if (textField == self.idDate)
    {
        self.datePicker.date = self.le.entryData.Date;
        self.datePicker.datePickerMode = UIDatePickerModeDate;
    }
    else if (textField == self.idPopAircraft)
    {
        if (self.le.entryData.AircraftID.intValue > 0){
            for (int i = 0; i < self.selectibleAircraft.count; i++) {
                if (self.selectibleAircraft[i].AircraftID.integerValue == self.le.entryData.AircraftID.integerValue) {
                    [self.pickerView selectRow:i inComponent:0 animated:YES];
                    break;
                }
            }
        }
    }
    self.activeTextField = textField;
    return fShouldEdit;
}

- (void) textViewDidChange:(UITextView *)textView {
    // issue #267 - for inexplicable reasons, textview delegate is not the same as textfield delegate.
    self.le.entryData.Comment = textView.text;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    // to check if total changed
    double oldTotal = self.le.entryData.TotalFlightTime.doubleValue;
    
    // catch any changes from retained fields
    [self initLEFromForm];

    UITableViewCell * tc = [self owningCellGeneric:textField];
    NSIndexPath * ip = [self.tableView indexPathForCell:tc];
    
    // If the cell is off-screen (hidden), we need to get its index path by position.
    if (ip == nil && tc != nil)
        ip = [self.tableView indexPathForRowAtPoint:tc.center];
    
    // Issue #164: See if this was the aircraft field, in which case we need to update templates
    if (textField == self.idPopAircraft) {
        // switching aircraft - update the templates, starting fresh.
        MFBWebServiceSvc_Aircraft * ac = [Aircraft.sharedAircraft AircraftByID:self.le.entryData.AircraftID.intValue];
        NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> * original = [[NSMutableSet alloc] initWithSet:self.activeTemplates];
        if (ac.DefaultTemplates.int_.count > 0)
            [self.activeTemplates removeAllObjects];
        [self updateTemplatesForAircraft:ac];
        
        // call templatesUpdated, but only if there's actually been a change
        NSInteger originalCount = original.count;
        [original minusSet:self.activeTemplates];
        if (originalCount != self.activeTemplates.count || original.count != 0)
            [self templatesUpdated:self.activeTemplates];
    } else if (textField == self.idTotalTime) {
        // Issue #159: if total time changes, need to reset properties cross-fill value.
        if (oldTotal != self.idTotalTime.value.doubleValue)
            [self.tableView reloadData];
    }
    
    NSInteger row = [self cellIDFromIndexPath:ip];
    if (row >= rowPropertyFirst)
    {
        PropertyCell * pc = (PropertyCell *) tc;
        [pc handleTextUpdate:textField];
        [self propertyUpdated:pc.cpt];
        [self.flightProps propValueChanged:pc.cfp];
        if ([pc.cfp isDefaultForType:pc.cpt] && !pc.cpt.isLocked && ![[MFBWebServiceSvc_PropertyTemplate propListForSets:self.activeTemplates] containsObject:pc.cpt.PropTypeID]) {
            [self.le.entryData removeProperty:pc.cfp.PropTypeID];
            [self.tableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    else if (ip.section == sectInCockpit)
    {
        // fNeedsReInit says if we need to update the other fields based on possible changes from autohobbs/autototals.
        // do autohobbs if this WASN'T an explicit edit of the hobbs times.
        BOOL fNeedsReInit = NO;

        switch (row)
        {
            case rowHobbsEnd:
                self.le.entryData.HobbsEnd = textField.value;
                break;
            case rowHobbsStart:
                self.le.entryData.HobbsStart = textField.value;
                // fall through
            default:
                fNeedsReInit = [self autoHobbs];
                break;
        }

        if ([self autoTotal] || fNeedsReInit)
            [self initFormFromLE:NO]; // don't reload the table because it could mess up our editing.
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.idRoute)
        return YES;

    // Hack, but for in-line editing of free-form text properties, need to allow arbitrary text and support autocomplete
    for (UIView * vw = textField.superview; vw != nil; vw = vw.superview)
    {
        if ([vw isKindOfClass:[PropertyCell class]])
        {
            PropertyCell * pc = (PropertyCell *) vw;
            if (pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpString)
                return [pc textField:textField shouldChangeCharactersInRange:range replacementString:string];
            break;
        }
    }
    
    // OK, at this point we have a number - either integer, decimal, or HH:MM.  Allow it if the result makes sense.
    return [textField isValidNumber:[textField.text stringByReplacingCharactersInRange:range withString:string]];
}

#pragma mark In the Cockpit
- (void) startEngine
{
    if (self.le.entryData.isNewFlight)
    {
        if (!self.le.entryData.isKnownEngineStart)
            [self resetDateOfFlight];
        if (UserPreferences.current.autodetectTakeoffs)
            [self autofillClosest];
    }
	
	[self initFormFromLE];
    
    if (!self.le.entryData.isNewFlight)
        return;
    
    mfbApp().mfbloc.currentFlightState = FlightStateFsOnGround;
    [mfbApp() updateWatchContext];

    if (MFBLocation.USE_FAKE_GPS) {
        [GPSSim BeginSim];
    }
}

- (void) startEngineExternal
{
    if (!self.le.entryData.isKnownEngineStart)
    {
        [self resetDateOfFlight];
        self.le.entryData.EngineStart = [NSDate date];
        [self startEngine];
    }
}

- (BOOL) autoTotal {
    if (self.le.autoFillTotal) {
        self.idTotalTime.value = self.le.entryData.TotalFlightTime;
        self.idGrndSim.value = self.le.entryData.GroundSim;
        self.idXC.value = self.le.entryData.CrossCountry;
        return YES;
    }
    return NO;
}

- (BOOL) autoHobbs {
    if (self.le.autoFillHobbs) {
        // get the index path of the hobbs end cell
        // this is a bit of a hack, but it's robust to the cell changing position
        NSInteger iRow = [self tableView:self.tableView numberOfRowsInSection:sectInCockpit];
        NSIndexPath * ip = nil;
        while (--iRow >= 0)
        {
            ip = [NSIndexPath indexPathForRow:iRow inSection:sectInCockpit];
            if ([self cellIDFromIndexPath:ip] == rowHobbsEnd)
                break;
        }
        if (ip != nil && iRow >= 0)
        {
            EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:ip];
            if (ec != nil)
                ec.txt.value = self.le.entryData.HobbsEnd;
        }

        // do the total time too, if appropriate
        if (UserPreferences.current.autoTotalMode == autoTotalHobbs)
            [self autoTotal];
        return YES;
    }
    return NO;
}

- (void) stopEngine
{
    if (UserPreferences.current.autodetectTakeoffs)
        [self autofillClosest];

    [self autoHobbs];
    [self autoTotal];

    if (!self.le.entryData.isNewFlight)
        return;

	[mfbApp().mfbloc stopRecordingFlightData];
	self.idimgRecording.hidden = YES;
	[self initFormFromLE];
    [self.le unPauseFlight];
    [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
}

- (void) stopEngineExternal {
    if (!self.le.entryData.isKnownEngineEnd) {
        self.le.entryData.EngineEnd = [NSDate date];
        [self stopEngine];
        self.le.entryData.FlightID = LogbookEntry.QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
        [MFBAppDelegate.threadSafeAppDelegate queueFlightForLater:self.le];
        [self resetFlight];
        [self updatePausePlay];
        [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
    }
}

- (void) stopEngineExternalNoSubmit {
    if (!self.le.entryData.isKnownEngineEnd) {
        self.le.entryData.EngineEnd = [NSDate date];
        [self stopEngine];
    }
}

- (void) startFlight
{
    if (self.le.entryData.isNewFlight)
    {
        if (![self.le.entryData isKnownEngineStart] && ![self.le.entryData isKnownFlightStart])
            [self resetDateOfFlight];
        
        if (UserPreferences.current.autodetectTakeoffs)
            [self autofillClosest];
        
        [mfbApp().mfbloc startRecordingFlightData]; // will ignore recording if not set to do so.
        [mfbApp() updateWatchContext];
    }

	[self initFormFromLE];
}

- (void) stopFlight
{
    [self initFormFromLE];
    [self autoHobbs];
    [self autoTotal];
    [mfbApp() updateWatchContext];
}


- (void) afterDataModified {
    [self autoHobbs];
    [self autoTotal];
    [self initFormFromLE];
    [mfbApp() updateWatchContext];
}

- (void) startFlightExternal {
    if ([NSDate isUnknownDate:self.le.entryData.FlightStart]) {
        self.le.entryData.FlightStart = NSDate.date;
        [self startFlight];
        [self afterDataModified];
    }
}

- (void) stopFlightExternal
{
    if ([NSDate isUnknownDate:self.le.entryData.FlightEnd]) {
        self.le.entryData.FlightEnd = NSDate.date;
        [self stopFlight];
    }
}

- (void) blockOutExternal {
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDBlockOut)];
    if (cfp != nil && ![NSDate isUnknownDate:cfp.DateValue])
        return;
    
    [self.le.entryData setPropertyValue:@(PropTypeIDBlockOut) withDate:NSDate.date];
    if (![self.le.entryData isKnownEngineStart] && ![self.le.entryData isKnownFlightStart])
        [self resetDateOfFlight];
    
    [self afterDataModified];
}

- (void) blockInExternal {
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self.le.entryData getExistingProperty:@(PropTypeIDBlockIn)];
    if (cfp != nil && ![NSDate isUnknownDate:cfp.DateValue])
        return;

    [self.le.entryData setPropertyValue:@(PropTypeIDBlockIn) withDate:NSDate.date];

    [self afterDataModified];
}
#pragma mark Autodetection delegates
- (NSString *) takeoffDetected
{
    [self.le.entryData takeoffDetected];
    
    [self initFormFromLE];
    [self.le unPauseFlight]; // if we're flying, we're not paused.
    
    [self saveState];
    // in case cockpit view is visible, have it update
    return mfbApp().fDebugMode ? [NSString stringWithFormat:@"Route is %@ landings=%d FS Landings=%d",
                                  self.le.entryData.Route,
                                  self.le.entryData.Landings.intValue,
                                  self.le.entryData.FullStopLandings.intValue] : @"";
}

- (NSString *) nightTakeoffDetected
{    
    // don't modify the flight if engine is ended.
    if ([self.le.entryData isKnownEngineEnd])
        return @"";

    [self.le.entryData nightTakeoffDetected];   // let the logbookentry handle this

    [self.tableView reloadData];
    [self saveState];
    return @"";
}

- (NSString *) landingDetected
{
    // don't modify the flight if engine is ended.
    if ([self.le.entryData isKnownEngineEnd])
        return @"";
    
    NSString * szRouteOrigin = [NSString stringWithString:self.le.entryData.Route];
    int landingsOrigin = self.le.entryData.Landings.intValue;

	if (![NSDate isUnknownDate:self.le.entryData.FlightStart])
	{
        [self.le.entryData landingDetected];    // delegate further to the logbook entry.
        self.idLandings.value = self.le.entryData.Landings;
        self.idRoute.text = self.le.entryData.Route;
		[self.tableView reloadData];
	}
    
    [self saveState];
    
    return mfbApp().fDebugMode ? [NSString stringWithFormat:@"Route was: %@ Now: %@; landings were: %d Now: %d",
                                  szRouteOrigin,
                                  self.le.entryData.Route,
                                  landingsOrigin, 
                                  self.le.entryData.Landings.intValue] : @"";
}

- (NSString *) fsLandingDetected:(BOOL) fIsNight
{
    // don't modify the flight if engine is ended.
    if ([self.le.entryData isKnownEngineEnd])
        return @"";
    
    int fsLandingsOrigin = fIsNight ? self.le.entryData.NightLandings.intValue : self.le.entryData.FullStopLandings.intValue;
    
    [self.le.entryData fsLandingDetected:fIsNight]; // delegate to logbookentry
    self.idNightLandings.value = self.le.entryData.NightLandings;
    self.idDayLandings.value = self.le.entryData.FullStopLandings;
    
    [self saveState];
    
    // NOTE: we don't pass this on to the sub-view because otherwise we would double count!
    // Also note that above already has updated this form.
    return mfbApp().fDebugMode ? [NSString stringWithFormat:@" FS %@ Landing: was: %d now: %d",
                                  fIsNight ? @"Night" : @"", 
                                  fsLandingsOrigin,
                                  fIsNight ? self.le.entryData.NightLandings.intValue : self.le.entryData.FullStopLandings.intValue] : @"";
}

- (void) addNightTime:(double) t
{
    if (self.le.fIsPaused)
        return;
    
    double accumulatedNight = (self.le.accumulatedNightTime += t);
    
    if (UserPreferences.current.roundTotalToNearestTenth)
        accumulatedNight = round(accumulatedNight * 10.0) / 10.0;
    self.idNight.value = self.le.entryData.Nighttime = @(accumulatedNight);
}

#pragma mark Location Manager Delegates

static NSDateFormatter * dfSunriseSunset = nil;

- (void) updatePositionReport
{
    MFBAppDelegate * app = mfbApp();
    
    CLLocation * loc = app.mfbloc.lastSeenLoc;
    if (loc == nil)
        return;
    
    double lat = loc.coordinate.latitude;
    double lon = loc.coordinate.longitude;
    if (self.lblLat != nil && self.lblLon != nil)
    {
        self.lblLat.text = [MFBLocation latitudeDisplay:lat];
        self.lblLon.text = [MFBLocation longitudeDisplay:lon];
    }
    
    if (self.lblSunrise != nil && self.lblSunset != nil)
    {
        SunriseSunset * s = [[SunriseSunset alloc] initWithDate:[NSDate date] Latitude:lat Longitude:lon nightOffset:0];
        if (dfSunriseSunset == nil)
        {
            dfSunriseSunset = [[NSDateFormatter alloc] init];
            [dfSunriseSunset setDateFormat:@"hh:mm a z"];
        }
        self.lblSunrise.text = [dfSunriseSunset stringFromDate:s.Sunrise];
        self.lblSunset.text = [dfSunriseSunset stringFromDate:s.Sunset];
    }
    // issue #272: show an icon of the world instead of information disclosure.
    // But let's show Americas if Latitude < -20, otherwise show eastern hemisphere.
    [self.btnViewRoute setTitle:(lon < -20) ? @"🌎" : @"🌍" forState:UIControlStateNormal];
}

// Location manager delegates
- (void) newLocation:(CLLocation *)newLocation
{	
	CLLocationSpeed s = newLocation.speed * MFBConstants.MPS_TO_KNOTS;
	BOOL fValidSpeed = (s >= 0);
	BOOL fValidQuality = NO;
	CLLocationAccuracy acc = newLocation.horizontalAccuracy;

	if (self.idLblQuality != nil)
	{
		if (acc > MFBLocation.MIN_ACCURACY || acc < 0) 
		{
			self.idLblQuality.text = NSLocalizedString(@"Poor", @"Poor GPS quality");
			fValidQuality = NO;
		}
		else
		{
			self.idLblQuality.text = (acc < (MFBLocation.MIN_ACCURACY / 2)) ? NSLocalizedString(@"Excellent", @"Excellent GPS quality") : NSLocalizedString(@"Good", @"Good GPS quality");
			fValidQuality = YES;
		}
	}
	
	MFBAppDelegate * app = mfbApp();
    
    if ([self.le.entryData isKnownEngineEnd] && app.mfbloc.currentFlightState != FlightStateFsOnGround) // can't fly with engine off
    {
        app.mfbloc.currentFlightState = FlightStateFsOnGround;
        NSLog(@"Engine is off so forced currentflightstate to OnGround");
    }
    
    FlightState fs = app.mfbloc.currentFlightState;
    self.idLblStatus.text = [MFBLocation flightStateDisplay:fs];
    if (fs == FlightStateFsInFlight)
        [self.le unPauseFlight];
    NSString * szInvalid = @"";
    self.idLblSpeed.text = (fValidSpeed && fValidQuality) ? [MFBLocation speedDisplay:s] : szInvalid;
    self.idLblAltitude.text = (fValidSpeed && fValidQuality) ? [MFBLocation altitudeDisplay:newLocation] : szInvalid;
    self.idimgRecording.hidden = !app.mfbloc.fRecordFlightData || ![self flightCouldBeInProgress];
    
    [self updatePausePlay]; // ensure that this is visible if we're not flying

    // update position, sunrise/sunset
    [self updatePositionReport];
}

#pragma mark EditPropertyDelegate
- (void) propertyUpdated:(MFBWebServiceSvc_CustomPropertyType *)cpt {
    NSInteger propID = cpt.PropTypeID.integerValue;
    
    if (UserPreferences.current.autoTotalMode == autoTotalBlock)
    {
        // Autoblock if editing a block time start or stop
        if (propID == PropTypeIDBlockOut || propID == PropTypeIDBlockIn)
            [self autoTotal];
    }
}

- (void) dateOfFlightShouldReset:(NSDate *) dt {
    if (![NSDate isUnknownDate:dt])
        [self resetDateOfFlight];
}

#pragma mark View Properties
- (void) viewProperties:(UIView *) sender
{
    FlightProperties * vwProps = [[FlightProperties alloc] initWithNibName:@"FlightProperties" bundle:nil];
    vwProps.le = self.le;
    vwProps.activeTemplates = self.activeTemplates;
    vwProps.delegate = self;

    [self pushOrPopView:vwProps fromView:sender withDelegate:self];
}

#pragma mark - Data Source - aircraft picker
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger selectible = self.selectibleAircraft.count;
    return (selectible == 0 || selectible == Aircraft.sharedAircraft.rgAircraftForUser.count) ? selectible : selectible + 1;
}

- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    if (view == nil) {
        UILabel * l = [UILabel new];
        l.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1];
        l.textAlignment = NSTextAlignmentCenter;
        view = l;
    }
    
    ((UILabel *) view).attributedText = [self pickerView:pickerView attributedTitleForRow:row forComponent:component];
    return view;
}

- (NSAttributedString *) pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    CGFloat size = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1].pointSize;
    if (row == self.selectibleAircraft.count)   // "Show all"
        return [NSAttributedString attributedStringFromMarkDown:[NSString stringWithFormat:@"_%@_", NSLocalizedString(@"ShowAllAircraft", @"Show all aircraft")] size:size];
    
    MFBWebServiceSvc_Aircraft * ac = self.selectibleAircraft[row];
    if (ac.isAnonymous)
        return [NSAttributedString attributedStringFromMarkDown:[NSString stringWithFormat:@"*%@*", ac.displayTailNumber] size:size];
    
    return [NSAttributedString attributedStringFromMarkDown:[NSString stringWithFormat:@"*%@* (%@)", ac.TailNumber, ac.ModelDescription] size:size];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == self.selectibleAircraft.count) {  // show all
        self.selectibleAircraft = [NSArray arrayWithArray:Aircraft.sharedAircraft.rgAircraftForUser];
        [pickerView reloadAllComponents];
        [pickerView selectRow:0 inComponent:0 animated:YES];
    }
    else {
    MFBWebServiceSvc_Aircraft * ac = self.selectibleAircraft[row];
    self.le.entryData.AircraftID = ac.AircraftID;
    self.le.entryData.TailNumDisplay = self.idPopAircraft.text = ac.displayTailNumber;
    }
}

#pragma mark - DatePicker
- (IBAction)dateChanged:(UIDatePicker *)sender
{
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    if (row == rowDateTail)
    {
        self.le.entryData.Date = sender.date;
        self.idDate.text = [sender.date dateString];
        return;
    }

    if (self.ipActive.section == sectInCockpit)
    {
        EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
        ec.txt.text = [sender.date  utcString:UserPreferences.current.UseLocalTime];
        switch (row)
        {
            case rowDateTail:
                return;
            case rowEngineStart:
                self.le.entryData.EngineStart = sender.date;
                [self resetDateOfFlight];
                break;
            case rowEngineEnd:
                self.le.entryData.EngineEnd = sender.date;
                break;
            case rowFlightStart:
                self.le.entryData.FlightStart = sender.date;
                [self resetDateOfFlight];
                break;
            case rowFlightEnd:
                self.le.entryData.FlightEnd = sender.date;
                break;
            case rowBlockOut:
            case rowBlockIn:
                if ([NSDate isUnknownDate:sender.date]) {
                    NSError * err = nil;
                    [self.le.entryData removeProperty:[self propIDFromCockpitRow:row] withServerAuth:mfbApp().userProfile.AuthToken deleteSvc:self.flightProps error: &err];
                }
                else {
                    [self.le.entryData setPropertyValue:[self propIDFromCockpitRow:row] withDate:sender.date];
                    if (row == rowBlockOut)
                        [self resetDateOfFlight];
                }
                break;

        }
        [self autoHobbs];
        [self autoTotal];
    }
}

#pragma mark - AccessoryBar Delegate
- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    NSInteger row = [self cellIDFromIndexPath:ip];
    switch (row)
    {
        case rowComments:
        case rowRoute:
        case rowHobbsEnd:
        case rowHobbsStart:
        case rowTachStart:
        case rowTachEnd:
        case rowTimes:
        case rowLandings:
        case rowDateTail:
            return YES;
        case rowEngineEnd:
            return ![NSDate isUnknownDate:self.le.entryData.EngineEnd];
        case rowEngineStart:
            return ![NSDate isUnknownDate:self.le.entryData.EngineStart];
        case rowFlightEnd:
            return ![NSDate isUnknownDate:self.le.entryData.FlightEnd];
        case rowFlightStart:
            return ![NSDate isUnknownDate:self.le.entryData.FlightStart];
        case rowBlockOut:
        case rowBlockIn:
            return ![NSDate isUnknownDate:[self.le.entryData getExistingProperty:[self propIDFromCockpitRow:row]].DateValue];
        case rowPropertiesHeader:
        case rowAddProperties:
            return NO;
        default:
            if (ip.section == sectProperties && ip.row > 0)
            {
                MFBWebServiceSvc_CustomFlightProperty * cfp = self.propsForPropsSection[ip.row - 1];
                MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps propTypeFromID:cfp.PropTypeID];
                return cpt.Type != MFBWebServiceSvc_CFPPropertyType_cfpBoolean;
            }
            return NO;
    }
}

- (void) deleteClicked
{
    self.activeTextField.text = @"";
    if (self.ipActive.section == sectInCockpit)
    {
        NSInteger row = [self cellIDFromIndexPath:self.ipActive];
        switch (row)
        {
            case rowHobbsStart:
                self.le.entryData.HobbsStart = self.activeTextField.value;
                break;
            case rowHobbsEnd:
                // Could affect total, but DON'T auto-hobbs or we undo the delete.
                self.le.entryData.HobbsEnd = self.activeTextField.value;
                [self autoTotal];
                return;
            case rowDateTail:
                return;
            case rowEngineStart:
                self.le.entryData.EngineStart = nil;
                break;
            case rowEngineEnd:
                self.le.entryData.EngineEnd = nil;
                break;
            case rowFlightStart:
                self.le.entryData.FlightStart = nil;
                break;
            case rowFlightEnd:
                self.le.entryData.FlightEnd = nil;
                break;
            case rowBlockOut:
            case rowBlockIn:
            case rowTachStart:
            case rowTachEnd: {
                NSError * err = nil;
                [self.le.entryData removeProperty:[self propIDFromCockpitRow:row] withServerAuth:mfbApp().userProfile.AuthToken deleteSvc:self.flightProps error:&err];
            }
                break;
        }
        [self autoHobbs];
        [self autoTotal];
        if (row != rowHobbsStart)
            [self.tableView endEditing:YES];
    }
    [self initLEFromForm];
}

#pragma mark - Add Image
- (void) addImage:(CommentedImage *)ci
{
    [self.le.rgPicsForFlight addObject:ci];
    [self.tableView reloadData];
    [super addImage:ci];
    if (![self isExpanded:sectImages])
        [self expandSection:sectImages];
}
@end
