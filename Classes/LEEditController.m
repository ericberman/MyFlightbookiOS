/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2018 MyFlightbook, LLC
 
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
//  FirstViewController.m
//  MFBSample
//
//  Created by Eric Berman on 11/28/09.
//

#import "LEEditController.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "HostedWebViewViewController.h"
#import "NearbyAirports.h"
#import "ImageComment.h"
#import "FlightProps.h"
#import "FlightProperties.h"
#import "PropertyCell.h"
#import "ButtonCell.h"
#import "math.h"
#import "RecentFlights.h"
#import "ApproachEditor.h"
#import "DecimalEdit.h"
#import "TextCell.h"

@interface LEEditController()
@property (nonatomic, strong) AccessoryBar * vwAccessory;
@property (nonatomic, strong) NSTimer * timerElapsed;
@property (nonatomic, strong) UITextField * activeTextField;
@property (strong) FlightProps * flightProps;
@property (nonatomic, strong) NSMutableDictionary * dictPropCells;
@property (nonatomic, strong) UIImage * digitizedSig;
@property (nonatomic, strong) NSArray<MFBWebServiceSvc_Aircraft *> * selectibleAircraft;


- (void) updatePausePlay;
- (void) updatePositionReport;
- (void) setDisplayDate:(NSDate *) dt;
- (void) setCurrentAircraft:(MFBWebServiceSvc_Aircraft *)ac;
- (BOOL) autoHobbs;
- (BOOL) autoTotal;
- (void) initFormFromLE;
- (void) initLEFromForm;
- (void) resetFlight;
- (void) submitFlight:(id)sender;
- (void) signFlight:(id)sender;
- (void) startEngine;
- (void) stopEngine;
- (void) startFlight;
- (void) stopFlight;
- (void) refreshProperties;
- (void) viewProperties:(UIView *) sender;
@end

@implementation LEEditController

@synthesize idDate, idRoute, idComments, idTotalTime, idPopAircraft, idApproaches, idHold, idLandings, idDayLandings, idNightLandings;
@synthesize idNight, idIMC, idSimIMC, idGrndSim, idXC, idDual, idCFI, idSIC, idPIC, idPublic, le, delegate;
@synthesize datePicker, pickerView;
@synthesize idLblStatus, idLblSpeed, idLblAltitude, idLblQuality, idimgRecording, idbtnPausePlay, idbtnAppendNearest, idlblElapsedTime, timerElapsed;
@synthesize lblLat, lblLon, lblSunset, lblSunrise;
@synthesize cellComments, cellDateAndTail, cellGPS, cellLandings, cellRoute, cellSharing, cellTimeBlock;
@synthesize vwAccessory, activeTextField, flightProps;
@synthesize dictPropCells, digitizedSig;
@synthesize selectibleAircraft;

NSString * const _szKeyCachedImageArray = @"cachedImageArrayKey";
NSString * const _szKeyFacebookState = @"keyFacebookState";
NSString * const _szKeyTwitterState = @"keyTwitterState";
NSString * const _szKeyCurrentFlight = @"keyCurrentNewFlight";
NSString * const _szkeyITCCollapseState = @"keyITCCollapseState";

enum sections {sectGeneral, sectInCockpit, sectTimes, sectProperties, sectSignature, sectImages, sectSharing, sectLast};
enum rows {
    rowGeneralFirst, rowDateTail = rowGeneralFirst, rowComments, rowRoute, rowLandings, rowGeneralLast=rowLandings,
    rowCockpitFirst, rowCockpitHeader = rowCockpitFirst, rowGPS, rowHobbsStart, rowEngineStart, rowFlightStart, rowFlightEnd, rowEngineEnd, rowHobbsEnd, rowCockpitLast = rowHobbsEnd,
    rowTimes,
    rowPropertiesHeader, rowAddProperties,
    rowSigFirst, rowSigHeader, rowSigState, rowSigComment, rowSigValidity, rowSigLast = rowSigValidity,
    rowImagesHeader,
    rowSharing,
    rowImageFirst = 1000,
    rowPropertyFirst = 10000
};

CGFloat heightDateTail, heightComments, heightRoute, heightLandings, heightGPS, heightTimes, heightSharing;

#pragma mark - LongPressCross-fill support
- (void) crossFillFrom:(UITextField *) src to:(UITextField *) dst
{
    // animate the source button onto the target, change the value, then restore the source
    [dst resignFirstResponder];
    
    CGRect rSrc = src.frame;
    CGRect rDst = dst.frame;
    
    UITextField * tfTemp = [[UITextField alloc] initWithFrame:rSrc];
    tfTemp.font = src.font;
    tfTemp.text = src.text;
    tfTemp.textAlignment = src.textAlignment;
    tfTemp.textColor = src.textColor;
    [src.superview addSubview:tfTemp];
    
    src.translatesAutoresizingMaskIntoConstraints = NO;
    [UIView animateWithDuration:0.5f animations:^{
        tfTemp.frame = rDst;
    }
     completion:^(BOOL finished) {
         dst.text = src.text;
         [UIView animateWithDuration:0.5f animations:^{
             tfTemp.frame = rSrc;
         }
          completion:^(BOOL finished) {
              [tfTemp removeFromSuperview];
          }];
     }];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) enableLongPressForField:(UITextField *) txt withSelector:(SEL) s
{
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

- (void) crossFillTotal:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
        [self crossFillFrom:self.idTotalTime to:(UITextField *)sender.view];
}

- (void) setHighWaterHobbs:(UILongPressGestureRecognizer *) sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UITextField * target = (UITextField *) sender.view;
        NSNumber * highWaterHobbs = [[Aircraft sharedAircraft] getHighWaterHobbsForAircraft:self.le.entryData.AircraftID];
        if (highWaterHobbs != nil && highWaterHobbs.doubleValue > 0) {
            target.value = self.le.entryData.HobbsStart = highWaterHobbs;
        }
    }
}

#pragma mark - Object Life Cycle / initialization
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        // Custom initialization
    }
    return self;
}

// re-initializes a flight but DOES NOT update any UI.
- (void) setupForNewFlight
{
	NSNumber * endingHobbs = self.le.entryData.HobbsEnd; // remember ending hobbs for last flight...
	
	self.le	= [[LogbookEntry alloc] init];
	self.le.entryData.Date = [NSDate date];	
	self.le.entryData.FlightID = NEW_FLIGHT_ID;
    // Add in any locked properties - but don't hit the web.
    FlightProps * fp = [FlightProps getFlightPropsNoNet];
    [self.le.entryData.CustomProperties setProperties:[fp defaultPropList]];
	
	MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] preferredAircraft];
	[self setCurrentAircraft:ac];
	
    MFBLocation * mfbloc = mfbApp().mfbloc;
	[mfbloc stopRecordingFlightData];
    [mfbloc resetFlightData]; // clean up any old flight-tracking data
	
	[self.le initNumerics];
	
	// ...and start the starting hobbs to be the previous flight's ending hobbs.  If it was nil, we're fine.
	self.le.entryData.HobbsStart = endingHobbs;
	[self saveState]; // clean up any old state
    [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
}

- (void) resetFlight
{
    [self setupForNewFlight];
    [self initFormFromLE];
}

- (void) resetFlightWithConfirmation
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"Are you sure you want to reset this flight?  This CANNOT be undone", @"Reset Flight confirmation") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self resetFlight];
        mfbApp().watchData.flightStage = flightStageUnstarted;
        [mfbApp() updateWatchContext];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) invalidateViewController
{
    [self performSelectorOnMainThread:@selector(resetFlight) withObject:nil waitUntilDone:NO];
}

- (void) setNumericField:(UITextField *) txt toType:(int) nt
{
    txt.NumberType = nt;
    txt.keyboardType = nt == ntInteger ? UIKeyboardTypeNumberPad : UIKeyboardTypeNumbersAndPunctuation;
    txt.autocorrectionType = UITextAutocorrectionTypeNo;
    txt.inputAccessoryView = self.vwAccessory;
    txt.delegate = self;
}

- (void) enableLabelClickForField:(UITextField *) txt
{
    if (txt.tag <= 0)
        return;
    for (UIView * vw in txt.superview.subviews)
        if ([vw isKindOfClass:[UILabel class]] && ((UILabel *) vw).tag == txt.tag)
            [vw addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:txt action:@selector(becomeFirstResponder)]];
}

- (void) asyncLoadDigitizedSig
{
    @autoreleasepool {
        NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/ViewSig.aspx?id=%d", MFBHOSTNAME, self.le.entryData.FlightID.intValue];
        self.digitizedSig = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:szURL]]];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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

    // Set the accessory view and the inputview for our various text boxes.
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    // Set numeric fields
    [self setNumericField:self.idLandings toType:ntInteger];
    [self setNumericField:self.idDayLandings toType:ntInteger];
    [self setNumericField:self.idNightLandings toType:ntInteger];
    [self setNumericField:self.idApproaches toType:ntInteger];

    [self setNumericField:self.idXC toType:ntTime];
    [self setNumericField:self.idSIC toType:ntTime];
    [self setNumericField:self.idSimIMC toType:ntTime];
    [self setNumericField:self.idCFI toType:ntTime];
    [self setNumericField:self.idDual toType:ntTime];
    [self setNumericField:self.idGrndSim toType:ntTime];
    [self setNumericField:self.idIMC toType:ntTime];
    [self setNumericField:self.idNight toType:ntTime];
    [self setNumericField:self.idPIC toType:ntTime];
    [self setNumericField:self.idTotalTime toType:ntTime];
    
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
    
    [self.idbtnAppendNearest addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(appendAdHoc:)]];

    // And set up remaining inputviews/accessory views
    self.idDate.inputView = self.datePicker;
    self.idPopAircraft.inputView = self.pickerView;
    self.idComments.inputAccessoryView = self.idRoute.inputAccessoryView = self.idDate.inputAccessoryView = self.idPopAircraft.inputAccessoryView = self.vwAccessory;
    self.idPopAircraft.delegate = self.idComments.delegate = self.idRoute.delegate = self;

	// self.le should be nil on first run, in which case we load up a flight
	// in progress or start a new one (if no saved state).
	// if self.le is already set up, we should be good to go with it.
	if (self.le == nil)
	{
		NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
		NSData * ar = (NSData *) [defs objectForKey:_szKeyCurrentFlight];
		if (ar != nil)
		{
			self.le = (LogbookEntry *) ((NSArray *)[NSKeyedUnarchiver unarchiveObjectWithData:ar])[0];
			self.le.entryData.Date = [NSDate date]; // go with today
		}
		else 
		{
			self.le = [[LogbookEntry alloc] init];
			[self setupForNewFlight];
		}
	}
    
    // If we have an unknown aircraft and just popped from creating one, then reset preferred aircraft
    if ([self.le.entryData.AircraftID intValue] <= 0)
        [self setCurrentAircraft:[[Aircraft sharedAircraft] preferredAircraft]];
	
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
    
    /* Set up toolbar and submit buttons */
    UIBarButtonItem * biSign = [[UIBarButtonItem alloc]
                                 initWithTitle:NSLocalizedString(@"SignFlight", @"Let a CFI sign this flight")
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(signFlight:)];
    
    UIBarButtonItem * biSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem * biReset = [[UIBarButtonItem alloc] 
                                  initWithTitle:NSLocalizedString(@"Reset", @"Reset button on flight entry") 
                                  style:UIBarButtonItemStylePlain
                                  target:self 
                                  action:@selector(resetFlightWithConfirmation)];
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
    
    bbGallery.style = bbCamera.style = UIBarButtonItemStylePlain;
    
    NSMutableArray * ar = [[NSMutableArray alloc] init];
    if ([self.le.entryData isNewFlight]) {
        [ar addObject:biOptions];
        [ar addObject:biReset];
    }
    if (![self.le.entryData isNewOrPending] && self.le.entryData.CFISignatureState != MFBWebServiceSvc_SignatureState_Valid)
        [ar addObject:biSign];
    if (![self.le.entryData isNewOrPending])
        [ar addObject:bbSend];
    [ar addObject:biSpacer];
    [ar addObject:bbGallery];
    [ar addObject:bbCamera];
    
    self.toolbarItems = ar;
    
    // Submit button
    UIBarButtonItem * bbSubmit = [[UIBarButtonItem alloc]
                                   initWithTitle:[self.le.entryData isNewOrPending] ? NSLocalizedString(@"Add", @"Generic Add") : NSLocalizedString(@"Update", @"Update")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(submitFlight:)];
    
    self.navigationItem.rightBarButtonItem = bbSubmit;
    
    if ([self.le.entryData isNewFlight])
    {
        self.timerElapsed = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updatePausePlay) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timerElapsed forMode:NSDefaultRunLoopMode];
    }
    
    // Set up longpress recognizers for times
    [self enableLongPressForField:self.idNight withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idSimIMC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idIMC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idXC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idDual withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idGrndSim withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idCFI withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idSIC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idPIC withSelector:@selector(crossFillTotal:)];
    [self enableLongPressForField:self.idTotalTime withSelector:@selector(timeCalculator:)];

    // Make the checkboxes checkboxes
    [self.idHold setIsCheckbox];
    [self.idPublic setIsCheckbox];
    self.idHold.contentHorizontalAlignment = self.idPublic.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    self.dictPropCells = [[NSMutableDictionary alloc] init];
    
    if (self.le.entryData.isSigned && self.le.entryData.HasDigitizedSig)
        [NSThread detachNewThreadSelector:@selector(asyncLoadDigitizedSig) toTarget:self withObject:nil];
    
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

- (void) viewWillDisappear:(BOOL)animated
{
	[self initLEFromForm];
    self.navigationController.toolbarHidden = YES;
    [self.dictPropCells removeAllObjects];
    [self saveState];
	[super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    MFBAppDelegate * app = mfbApp();
    
    [self autoBlock];
    
    // pick up any changes in the HHMM setting
    self.idXC.IsHHMM = self.idSIC.IsHHMM = self.idSimIMC.IsHHMM = self.idCFI.IsHHMM = self.idDual.IsHHMM =
    self.idGrndSim.IsHHMM = self.idIMC.IsHHMM = self.idNight.IsHHMM = self.idPIC.IsHHMM = self.idTotalTime.IsHHMM = [AutodetectOptions HHMMPref];

    // Pick up an aircraft if one was added and none had been selected
    if ([self.idPopAircraft.text length] == 0)
    {
        MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] preferredAircraft];
        if (ac != nil)
        {
            self.idPopAircraft.text = ac.TailNumber;
            self.le.entryData.AircraftID = ac.AircraftID;
        }
    }
    // And reload the aircraft picker regardless, in case it changed too
    [self.pickerView reloadAllComponents];
    
	[self initFormFromLE]; // pick up any potential changes
	
	[self.navigationController setToolbarHidden:NO];
    
	[self saveState]; // keep things in sync with any changes
    
    // the option to record could have changed; if so, and if we are in-flight, need to start recording.
    if (app.mfbloc.fRecordFlightData && [self flightCouldBeInProgress])
        [app.mfbloc startRecordingFlightData];
    
    if (app.mfbloc.lastSeenLoc != nil)
    {
        [self newLocation:app.mfbloc.lastSeenLoc];
        [self updatePositionReport];
    }
    
    // Initialize the list of selectibleAircraft and hold on to it
    // We do this on each view-will-appear so that we can pick up any aircraft that have been shown/hidden.
    self.selectibleAircraft = [Aircraft.sharedAircraft AircraftForSelection:self.le.entryData.AircraftID];
	
    [self.tableView reloadData];
	[app ensureWarningShownForUser];
}

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"New width: %f", size.width);
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
    
    int totalsMode = [AutodetectOptions autoTotalMode];
    
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

- (NSString *) elapsedTimeDisplay:(NSTimeInterval) dt
{
    return [NSString stringWithFormat:@"%02d:%02d:%02d", (int) (dt / 3600), (int) ((((int) dt) % 3600) / 60), ((int) dt) % 60];
}

- (void) updatePausePlay
{
    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;

    [self.idbtnPausePlay setImage:[UIImage imageNamed:self.le.fIsPaused ? @"Play.png" : @"Pause.png"] forState:0];
    BOOL fCouldBeFlying = ([self.le.entryData isKnownEngineStart] || [self.le.entryData isKnownFlightStart]) && ![self.le.entryData isKnownEngineEnd];
    BOOL fShowPausePlay = app.mfbloc.currentFlightState != fsInFlight && fCouldBeFlying;
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
    int totalsMode = [AutodetectOptions autoTotalMode];
    
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

#pragma mark - Save State
- (void) saveState
{
	// don't save anything if we are viewing an existing flight
	if ([self.le.entryData isNewFlight])
	{
		// LE should already be in sync with the UI.
		self.le.entryData.FlightData = [MFBAppDelegate threadSafeAppDelegate].mfbloc.flightDataAsString;
		
		NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
		[defs setObject:[NSKeyedArchiver archivedDataWithRootObject:@[le]] forKey:_szKeyCurrentFlight];
		[defs synchronize];
	}
}

#pragma mark - Read/Write Form
- (void) initLEFromForm
{
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

    self.le.postingOptions.PostToTwitter = [[USBoolean alloc] initWithBool:NO];
    self.le.postingOptions.PostToFacebook = [[USBoolean alloc] initWithBool:NO];
}

- (void) setCurrentAircraft: (MFBWebServiceSvc_Aircraft *) ac
{
    if (ac == nil)
    {
        self.le.entryData.AircraftID = @0;
        self.idPopAircraft.text = @"";
    }
    else if (self.idPopAircraft != nil)
	{
        self.idPopAircraft.text = ac.TailNumber;
		self.le.entryData.AircraftID = ac.AircraftID;
	}
}

- (void) setDisplayDate: (NSDate *) dt
{
	if (self.idDate != nil)
        self.idDate.text = [dt dateString];
}

- (void) initFormFromLE:(BOOL) fReloadTable
{	
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
	
	[CommentedImage initCommentedImagesFromMFBII:entryData.FlightImages.MFBImageInfo toArray:self.le.rgPicsForFlight];
		    
    [self updatePausePlay];
	
    self.idimgRecording.hidden = !mfbApp().mfbloc.fRecordFlightData || ![self flightCouldBeInProgress];
    mfbApp().watchData.isRecording = !self.idimgRecording.hidden;
    
    if (fReloadTable)
        [self.tableView reloadData];
}

- (void) initFormFromLE
{
    [self initFormFromLE:YES];
}

#pragma mark Flight Submission
- (IBAction) newAircraft
{
    [MyAircraft pushNewAircraftOnViewController:self.navigationController];    
}

// Called after a flight is EITHER successfully posted to the site OR successfully queued for later.
- (void) submitFlightSuccessful
{
    MFBAppDelegate * app = mfbApp();
    // set the preferred aircraft
    [Aircraft sharedAircraft].DefaultAircraftID = self.le.entryData.AircraftID.intValue;
        
    // invalidate any cached totals and currency, since the newly entered flight renders them obsolete
    [app invalidateCachedTotals];
    UIView * targetView = [app recentsView].view;
    
    // and let any delegate know that the flight has updated
    if (self.delegate != nil && [delegate respondsToSelector:@selector(flightUpdated:)])
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
                 mfbApp().tabBarController.selectedViewController = mfbApp().tabRecents;
                 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
             }
         }];
    }

    // clear the form for another entry
    [self setupForNewFlight];
    [self initFormFromLE];
}

- (void) submitFlight:(id) sender
{
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
    
	MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
	if (![app.userProfile isValid]) // should never happen - app delegate should have prevented this page from showing.
		return;
    
	self.le.szAuthToken = app.userProfile.AuthToken;
	self.le.entryData.User = app.userProfile.UserName;
		
	BOOL fIsNew = [self.le.entryData isNewFlight];
    
    // get flight telemetry
	[app.mfbloc stopRecordingFlightData];
	if (fIsNew)
		self.le.entryData.FlightData = [app.mfbloc flightDataAsString];
	else if (![self.le.entryData isNewOrPending]) // for existing flights, don't send up flighttrackdata
		self.le.entryData.FlightData = nil;
    
    // remove any non-default properties from the list.
    [self.le.entryData.CustomProperties setProperties:[self.flightProps distillList:self.le.entryData.CustomProperties.CustomFlightProperty includeLockedProps:NO]];
    
    self.le.errorString = @""; // assume no error

    // if it's a new flight, queue it.  We set the id to -2 to distinguish it from a new flight.
    // If it's pending, we just no-op and tell the user it's still queued.
    if (self.le.entryData.isNewOrPending)
        self.le.entryData.FlightID = PENDING_FLIGHT_ID;
    
    // add it to the pending flight queue - it will start submitting when recent flights are viewed
    [app queueFlightForLater:self.le];
    [self submitFlightSuccessful];
}

#pragma mark "Next" button inflation
enum nextTime {timeHobbsStart, timeEngineStart, timeFlightStart, timeFlightEnd, timeEngineEnd, timeHobbsEnd, timeNone};

// Return the latest unknown time.
- (int) nextTimeToHighlight
{
    MFBWebServiceSvc_LogbookEntry * l = self.le.entryData;
    if ([l.HobbsEnd doubleValue] > 0)
        return timeNone;
    if ([l isKnownEngineEnd])
        return timeHobbsEnd;
    if ([l isKnownFlightEnd])
        return timeEngineEnd;
    if ([l isKnownFlightStart])
        return timeFlightEnd;
    if ([l isKnownEngineStart])
        return timeFlightStart;
    if ([l.HobbsStart doubleValue] > 0)
        return timeEngineStart;
    return timeHobbsStart;
}

- (void) setLabelInflated:(BOOL) fInflate forEditCell:(EditCell *)ec
{
    UIFont * font = fInflate ? [UIFont boldSystemFontOfSize:14.0] : [UIFont systemFontOfSize:12.0];
    ec.txt.font = ec.lbl.font = font;
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
            return rowCockpitFirst + row + (([self.le.entryData isNewFlight] || row < (rowGPS - rowCockpitFirst)) ? 0: 1);
        case sectProperties:
            return (row == 0) ? rowPropertiesHeader : ((row == [self.le.entryData.CustomProperties.CustomFlightProperty count] + 1) ? rowAddProperties : rowPropertyFirst + row);
        case sectSharing:
            return rowSharing;
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
            return [self isExpanded:sectInCockpit] ? (rowCockpitLast + 1 - rowCockpitFirst - ([self.le.entryData isNewFlight] ? 0 : 1)) : 1;
        case sectProperties:
            return 1 + ([self isExpanded:sectProperties] ? [self.le.entryData.CustomProperties.CustomFlightProperty count] + 1 : 0);
        case sectSharing:
            return 1;
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
        case sectSharing:
            return NSLocalizedString(@"Sharing", @"Sharing Header");
        case sectSignature:
            return self.le.entryData.CFISignatureState == MFBWebServiceSvc_SignatureState_None ? nil : @"";
        default:
            return @"";
    }
}

- (EditCell *) dateCell:(NSDate *) dt withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView inflated:(BOOL) fInflated
{
    EditCell * ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
    ec.txt.inputView = self.datePicker;
    ec.txt.placeholder = NSLocalizedString(@"(Tap for Now)", @"Prompt UTC Date/Time that is currently un-set (tapping sets it to NOW in UTC)");
    ec.txt.delegate = self;
    ec.lbl.text = szPrompt;
    ec.txt.clearButtonMode = UITextFieldViewModeNever;
    ec.txt.text = [NSDate isUnknownDate:dt] ? @"" : [dt utcString];
    [self setLabelInflated:fInflated forEditCell:ec];

    return ec;
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

- (EditCell *) decimalCell:(UITableView *) tableView withPrompt:(NSString *)szPrompt andValue:(NSNumber *)val selector:(SEL)sel andInflation:(BOOL) fIsInflated
{
    EditCell * ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
    [self setNumericField:ec.txt toType:ntDecimal];
    [ec.txt addTarget:self action:sel forControlEvents:UIControlEventEditingChanged];
    [ec.txt setValue:val withDefault:@0.0];
    ec.lbl.text = szPrompt;
    [self setLabelInflated:fIsInflated forEditCell:ec];
    return ec;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    
    int nt = [self nextTimeToHighlight];
    
    switch (row)
    {
        case rowCockpitHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"In the Cockpit", @"In the Cockpit") forSection:sectInCockpit initialState:[self isExpanded:sectInCockpit]];
        case rowImagesHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"Images", @"Images Header") forSection:sectImages initialState:[self isExpanded:sectImages]];
        case rowPropertiesHeader:
            return [ExpandHeaderCell getHeaderCell:tableView withTitle:NSLocalizedString(@"Properties", @"Properties Header") forSection:sectProperties initialState:[self isExpanded:sectProperties]];
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
            return self.cellGPS;
        case rowHobbsStart: {
            EditCell * dcell = [self decimalCell:tableView withPrompt:NSLocalizedString(@"Hobbs Start:", @"Hobbs Start prompt") andValue:self.le.entryData.HobbsStart selector:@selector(hobbsChanged:) andInflation:(nt == timeHobbsStart)];
            [self enableLongPressForField:dcell.txt withSelector:@selector(setHighWaterHobbs:)];
            return dcell;
        }
        case rowHobbsEnd:
            return [self decimalCell:tableView withPrompt:NSLocalizedString(@"Hobbs End:", @"Hobbs End prompt") andValue:self.le.entryData.HobbsEnd selector:@selector(hobbsChanged:) andInflation:(nt == timeHobbsEnd)];
        case rowEngineStart:
            return [self dateCell:self.le.entryData.EngineStart withPrompt:NSLocalizedString(@"Engine Start:", @"Engine Start prompt") forTableView:self.tableView inflated:(nt == timeEngineStart)];
        case rowEngineEnd:
            return [self dateCell:self.le.entryData.EngineEnd withPrompt:NSLocalizedString(@"Engine Stop:", @"Engine Stop prompt") forTableView:self.tableView inflated:(nt == timeEngineEnd)];
        case rowFlightStart:
            return [self dateCell:self.le.entryData.FlightStart withPrompt:NSLocalizedString(@"First Takeoff:", @"First Takeoff prompt") forTableView:self.tableView inflated:(nt == timeFlightStart)];
        case rowFlightEnd:
            return [self dateCell:self.le.entryData.FlightEnd withPrompt:NSLocalizedString(@"Last Landing:", @"Last Landing prompt") forTableView:self.tableView inflated:(nt == timeFlightEnd)];
        case rowTimes:
            return self.cellTimeBlock;
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
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"sigStateTemplate2", @"Signature Status - certificate & Expiration"), self.le.entryData.CFICertificate, [df stringFromDate:self.le.entryData.CFIExpiration]];
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
                    cell.imageView.image = [ci GetThumbnail];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.indentationWidth = 10.0;
                }
                return cell;

            }
            else if (indexPath.section == sectProperties)
            {
                MFBWebServiceSvc_CustomFlightProperty * cfp = (self.le.entryData.CustomProperties.CustomFlightProperty)[indexPath.row - 1];
                MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps PropTypeFromID:cfp.PropTypeID];
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
                [pc configureCell:self.vwAccessory andDatePicker:self.datePicker defValue:(cpt.PropTypeID.intValue == PropTypeID_TachStart) ? [[Aircraft sharedAircraft] getHighWaterTachForAircraft:self.le.entryData.AircraftID] : self.le.entryData.TotalFlightTime];
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
        MFBWebServiceSvc_CustomFlightProperty * cfp = (MFBWebServiceSvc_CustomFlightProperty *) (self.le.entryData.CustomProperties.CustomFlightProperty)[indexPath.row - 1];
        MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps PropTypeFromID:cfp.PropTypeID];
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
            [self.le.entryData.CustomProperties.CustomFlightProperty removeObjectAtIndex:indexPath.row - 1];
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
        default:
        {
            // We've already excluded propheader and add properties above.
            if (indexPath.section == sectProperties)
            {
                PropertyCell * pc = (PropertyCell *) [self.tableView cellForRowAtIndexPath:indexPath];
                if ([pc handleClick])
                {
                    [self.flightProps propValueChanged:pc.cfp];
                    if (!pc.cpt.isLocked && [pc.cfp isDefaultForType:pc.cpt])
                    {
                        [self.le.entryData.CustomProperties.CustomFlightProperty removeObject:pc.cfp];
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
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];

    // see if this is a "Tap for today" click - if so, set to today and resign.
    if ([ec.txt.text length] == 0 || [NSDate isUnknownDate:dt])
    {
        BOOL fWasUnknownEngineStart = [NSDate isUnknownDate:self.le.entryData.EngineStart];
        BOOL fWasUnknownFlightStart = [NSDate isUnknownDate:self.le.entryData.FlightStart];
        
        // Since we don't display seconds, truncate them; this prevents odd looking math like
        // an interval from 12:13:59 to 12:15:01, which is a 1:02 but would display as 12:13-12:15 (which looks like 2 minutes)
        // By truncating the time, we go straight to 12:13:00 and 12:15:00, which will even yield 2 minutes.
        if (dt == nil)
        {
            dt = [NSDate date];
            NSTimeInterval time = floor([dt timeIntervalSinceReferenceDate] / 60.0) * 60.0;
            self.datePicker.date = dt = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
        }
        
        completionBlock(self.datePicker.date);
        ec.txt.text = [self.datePicker.date dateString];
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
        }
        return NO;
    }
    
    self.datePicker.date = dt;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.timeZone = [AutodetectOptions UseLocalTime] ? [NSTimeZone systemTimeZone] : [NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.locale = [AutodetectOptions UseLocalTime] ? [NSLocale currentLocale] : [NSLocale localeWithLocaleIdentifier:@"en-GB"];
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
        default:
            if (self.ipActive.section == sectProperties && row >= rowPropertyFirst)
                fShouldEdit = [((PropertyCell *) tc) prepForEditing];
            [self autoBlock];
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

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    self.activeTextField = nil;
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    // catch any changes from retained fields
    [self autoBlock];
    [self initLEFromForm];

    UITableViewCell * tc = [self owningCellGeneric:textField];
    NSIndexPath * ip = [self.tableView indexPathForCell:tc];
    NSInteger row = [self cellIDFromIndexPath:ip];
    if (row >= rowPropertyFirst)
    {
        PropertyCell * pc = (PropertyCell *) tc;
        [pc handleTextUpdate:textField];
        [self.flightProps propValueChanged:pc.cfp];
        if (!pc.cpt.isLocked && [pc.cfp isDefaultForType:pc.cpt])
        {
            [self.le.entryData.CustomProperties.CustomFlightProperty removeObject:pc.cfp];
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

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ((textField == self.idComments || textField == self.idRoute))
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
- (void) resetDateOfFlight
{
    [self setDisplayDate:(le.entryData.Date = [NSDate date])];
}

- (void) startEngine
{
    if (self.le.entryData.isNewFlight)
    {
        if (!self.le.entryData.isKnownEngineStart)
            [self resetDateOfFlight];
        if ([AutodetectOptions autodetectTakeoffs])
            [self autofillClosest];
    }
	
	[self initFormFromLE];
    
    if (!self.le.entryData.isNewFlight)
        return;
    
    mfbApp().mfbloc.currentFlightState = fsOnGround;
    [mfbApp() updateWatchContext];

#ifdef USE_FAKE_GPS
    [GPSSim BeginSim];
#endif
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

- (void) autoCrossCountry:(NSTimeInterval) dtTotal
{
    Airports * ap = [[Airports alloc] init];
    double maxDist = [ap maxDistanceOnRoute:self.le.entryData.Route];
    
    BOOL fIsCC = (maxDist >= CROSS_COUNTRY_THRESHOLD);

    self.idXC.value = self.le.entryData.CrossCountry = @((fIsCC && dtTotal > 0) ? dtTotal : 0.0);
}

- (BOOL) autoTotal
{
    NSTimeInterval dtPauseTime = [self.le totalTimePaused] / 3600.0;  // pause time in hours
    NSTimeInterval dtTotal = 0;
    
    BOOL fIsRealAircraft = YES;
    
    MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] AircraftByID:self.le.entryData.AircraftID.intValue];
    if (ac != nil)
        fIsRealAircraft = ![ac isSim];
    
    // TODO: this autototal stuff should move into logbookentry.
    switch ([AutodetectOptions autoTotalMode]) {
        case autoTotalEngine:
        {
            if (![NSDate isUnknownDate:self.le.entryData.EngineStart] &&
                ![NSDate isUnknownDate:self.le.entryData.EngineEnd])
            {
                NSTimeInterval engineStart = [self.le.entryData.EngineStart timeIntervalSinceReferenceDate];
                NSTimeInterval engineEnd = [self.le.entryData.EngineEnd timeIntervalSinceReferenceDate];
                dtTotal = ((engineEnd - engineStart) / 3600.0) - dtPauseTime;
            }
        }
            break;
        case autoTotalFlight:
        {
            if (![NSDate isUnknownDate:self.le.entryData.FlightStart] &&
                ![NSDate isUnknownDate:self.le.entryData.FlightEnd])
            {
                NSTimeInterval flightStart = [self.le.entryData.FlightStart timeIntervalSinceReferenceDate];
                NSTimeInterval flightEnd = [self.le.entryData.FlightEnd timeIntervalSinceReferenceDate];
                dtTotal = ((flightEnd - flightStart) / 3600.0) - dtPauseTime;
            }
        }
            break;
        case autoTotalHobbs:
        {
            double hobbsStart = [self.le.entryData.HobbsStart doubleValue];
            double hobbsEnd = [self.le.entryData.HobbsEnd doubleValue];
            // NOTE: we do NOT subtract dtPauseTime here because hobbs should already have subtracted pause time,
            // whether from being entered by user (hobbs on airplane pauses on ground or with engine stopped)
            // or from this being called by autohobbs (which has already subtracted it)
            if (hobbsStart > 0 && hobbsEnd > 0)
                dtTotal = hobbsEnd - hobbsStart;
        }
            break;
        case autoTotalBlock: {
            NSDate * blockOut = nil;
            NSDate * blockIn = nil;
            
            for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.le.entryData.CustomProperties.CustomFlightProperty) {
                if (cfp.PropTypeID.integerValue == PropTypeID_BlockOut)
                    blockOut = cfp.DateValue;
                if (cfp.PropTypeID.integerValue == PropTypeID_BlockIn)
                    blockIn = cfp.DateValue;
            }
            
            if (![NSDate isUnknownDate:blockOut] && ![NSDate isUnknownDate:blockIn])
                dtTotal = ([blockIn timeIntervalSinceDate:blockOut] / 3600.0) - dtPauseTime;
        }
            break;
        case autoTotalFlightStartToEngineEnd: {
            if (![NSDate isUnknownDate:self.le.entryData.FlightStart] && ![NSDate isUnknownDate:self.le.entryData.EngineEnd])
                dtTotal = ([self.le.entryData.EngineEnd timeIntervalSinceDate:self.le.entryData.FlightStart] / 3600.0) - dtPauseTime;
        }
            break;
        case autoTotalNone:
        default:
            return NO;
            break;
    }

    if (dtTotal > 0)
    {
        if ([AutodetectOptions roundTotalToNearestTenth])
            dtTotal = round(dtTotal * 10.0) / 10.0;

        if (fIsRealAircraft)
        {
            self.idTotalTime.value = self.le.entryData.TotalFlightTime = @(dtTotal);
            [self autoCrossCountry:dtTotal];
        }
        else
            self.idGrndSim.value = self.le.entryData.GroundSim = @(dtTotal);
        
        return YES;
    }
    
    return NO;
}

// autototal based on block is a bit trickier because block is a property, so this checks if we are in block mode and lets us do some extra auto-totals.
- (void) autoBlock {
    if (AutodetectOptions.autoTotalMode == autoTotalBlock)
        [self autoTotal];
}


- (BOOL) autoHobbs
{
	NSTimeInterval dtHobbs = 0;
	NSTimeInterval dtFlight = 0;
	NSTimeInterval dtEngine = 0;
    NSTimeInterval dtPausedTime = [self.le totalTimePaused];
    double hobbsStart = [self.le.entryData.HobbsStart doubleValue];
	
	if (![NSDate isUnknownDate:self.le.entryData.FlightStart] && ![NSDate isUnknownDate:self.le.entryData.FlightEnd])
		dtFlight = [self.le.entryData.FlightEnd timeIntervalSinceReferenceDate] - [self.le.entryData.FlightStart timeIntervalSinceReferenceDate];
	
	if (![NSDate isUnknownDate:self.le.entryData.EngineStart] && ![NSDate isUnknownDate:self.le.entryData.EngineEnd])
		dtEngine = [self.le.entryData.EngineEnd timeIntervalSinceReferenceDate] - [self.le.entryData.EngineStart timeIntervalSinceReferenceDate];
	
	if (hobbsStart > 0)
	{
		switch ([AutodetectOptions autoHobbsMode]) 
		{
			case autoHobbsFlight:
				dtHobbs = dtFlight;
				break;
			case autoHobbsEngine:
				dtHobbs = dtEngine;
				break;
			case autoHobbsNone:
			default:
				break;
		}
        
        dtHobbs -= dtPausedTime;
		
		if (dtHobbs > 0)
        {
			self.le.entryData.HobbsEnd = @(hobbsStart + (dtHobbs / 3600.0));
            
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
            if ([AutodetectOptions autoTotalMode] == autoTotalHobbs)
                [self autoTotal];
            return YES;
        }
	}
    
    return NO;
}

- (void) stopEngine
{
    if ([AutodetectOptions autodetectTakeoffs])
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
        self.le.entryData.FlightID = QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
        [MFBAppDelegate.threadSafeAppDelegate queueFlightForLater:self.le];
        [self resetFlight];
        [self updatePausePlay];
        [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
    }
}

- (void) startFlight
{
    if (self.le.entryData.isNewFlight)
    {
        if (![self.le.entryData isKnownEngineStart] && ![self.le.entryData isKnownFlightStart])
            [self resetDateOfFlight];
        
        if ([AutodetectOptions autodetectTakeoffs])
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

#pragma mark NearbyAirportsDelegate
- (void) airportClicked:(MFBWebServiceSvc_airport *) ap
{
	if (ap != nil)
	{
		NSString * newRoute = [Airports appendAirport:ap ToRoute:((self.idRoute == nil) ? self.le.entryData.Route : self.idRoute.text)];
		self.le.entryData.Route = newRoute;
		if (self.idRoute != nil)
			self.idRoute.text = newRoute;
	}
}

- (void) routeUpdated:(NSString *)newRoute
{
    self.idRoute.text = self.le.entryData.Route = newRoute;
}

#pragma mark autofill
- (IBAction) autofillClosest
{
	NSString * szRoute = [Airports appendNearestAirport:self.le.entryData.Route];
	self.le.entryData.Route = self.idRoute.text = szRoute;
}

- (void) appendAdHoc:(id) sender
{
    NSString * szLatLong = [[[MFBWebServiceSvc_LatLong alloc] initWithCoord:mfbApp().mfbloc.lastSeenLoc.coordinate] toAdhocString];
    NSString * szRoute = [Airports appendAirport:[MFBWebServiceSvc_airport getAdHoc:szLatLong] ToRoute:self.le.entryData.Route];
    self.le.entryData.Route = self.idRoute.text = szRoute;
}

- (IBAction) viewClosest
{
	if (self.navigationController != nil)
	{        
        [self initLEFromForm];
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
            self.le.gpxPath = mfbApp().mfbloc.gpxData;
        
        for (CommentedImage * ci in self.le.rgPicsForFlight)
        {
            if (ci.imgInfo.Location != nil && ci.imgInfo.Location.Latitude != nil && ci.imgInfo.Location.Longitude != nil)
                [vwNearbyAirports.rgImages addObject:ci];
        }
        
        if (self.navigationController != nil)
            [self.navigationController pushViewController:vwNearbyAirports animated:YES];
	}
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
    double accumulatedNight = (self.le.accumulatedNightTime += t);
    
    if ([AutodetectOptions roundTotalToNearestTenth])
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
        lblLat.text = [MFBLocation latitudeDisplay:lat];
        lblLon.text = [MFBLocation longitudeDisplay:lon];
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
}

// Location manager delegates
- (void) newLocation:(CLLocation *)newLocation
{	
	CLLocationSpeed s = newLocation.speed * MPS_TO_KNOTS;
	BOOL fValidSpeed = (s >= 0);
	BOOL fValidQuality = NO;
	CLLocationAccuracy acc = newLocation.horizontalAccuracy;

	if (self.idLblQuality != nil)
	{
		if (acc > MIN_ACCURACY || acc < 0) 
		{
			self.idLblQuality.text = NSLocalizedString(@"Poor", @"Poor GPS quality");
			fValidQuality = NO;
		}
		else
		{
			self.idLblQuality.text = (acc < (MIN_ACCURACY / 2)) ? NSLocalizedString(@"Excellent", @"Excellent GPS quality") : NSLocalizedString(@"Good", @"Good GPS quality");
			fValidQuality = YES;
		}
	}
	
	MFBAppDelegate * app = mfbApp();
    
    if ([self.le.entryData isKnownEngineEnd] && app.mfbloc.currentFlightState != fsOnGround) // can't fly with engine off
    {
        app.mfbloc.currentFlightState = fsOnGround;
        NSLog(@"Engine is off so forced currentflightstate to OnGround");
    }
    
    FlightState fs = app.mfbloc.currentFlightState;
    self.idLblStatus.text = [MFBLocation flightStateDisplay:fs];
    if (fs == fsInFlight)
        [self.le unPauseFlight];
    NSString * szInvalid = NSLocalizedString(@"--", @"Invalid GPS data");
    self.idLblSpeed.text = (fValidSpeed && fValidQuality) ? [MFBLocation speedDisplay:s] : szInvalid;
    self.idLblAltitude.text = (fValidSpeed && fValidQuality) ? [MFBLocation altitudeDisplay:newLocation] : szInvalid;
    self.idimgRecording.hidden = !app.mfbloc.fRecordFlightData || ![self flightCouldBeInProgress];
    
    [self updatePausePlay]; // ensure that this is visible if we're not flying

    // update position, sunrise/sunset
    [self updatePositionReport];
}

#pragma mark Options
- (void) configAutoDetect
{
	AutodetectOptions * vwAutoOptions = [[AutodetectOptions alloc] initWithNibName:@"AutodetectOptions" bundle:nil];
    [self.navigationController pushViewController:vwAutoOptions animated:YES];
}

- (void) signFlight:(id)sender
{
	NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/SignEntry.aspx?idFlight=%d&auth=%@&naked=1",
						MFBHOSTNAME,
						[self.le.entryData.FlightID intValue],
						[(mfbApp()).userProfile.AuthToken stringByURLEncodingString]];
	
    HostedWebViewViewController * vwWeb = [[HostedWebViewViewController alloc] initWithURL:szURL];
    [mfbApp() invalidateCachedTotals];   // this flight could now be invalid
	[self.navigationController pushViewController:vwWeb animated:YES];
}

#pragma mark View Properties
- (void) viewProperties:(UIView *) sender
{
    FlightProperties * vwProps = [[FlightProperties alloc] initWithNibName:@"FlightProperties" bundle:nil];
    vwProps.le = self.le;

    [self pushOrPopView:vwProps fromView:sender withDelegate:self];
}

#pragma mark - UIPopoverPresentationController functions
// UIPopoverPresentationController functions
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverController
{
    [self.tableView reloadData];
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverController
{
    // let the property display know it is going to go away.
    [popoverController.presentedViewController viewWillDisappear:NO];
    return true;
}

- (void) refreshPropertiesWorker
{
    @autoreleasepool {    
    FlightProps * fp = [[FlightProps alloc] init];
    BOOL fError = NO;
    
    // We have two tasks here:
    // (a) refresh the property cache if necessary
    // (b) download the properties for the flight, if necessary
    
    // loadCustomPropertyTypes will use the cache if necessary.
    [fp loadCustomPropertyTypes];
    
    // if this flight lives on the web, need to pull down its properties.
    if ([self.le.entryData isNewOrPending])
    {
        if (self.le.entryData.CustomProperties == nil)
            self.le.entryData.CustomProperties = [[MFBWebServiceSvc_ArrayOfCustomFlightProperty alloc] init];
    }
    else
    {
        if (self.le.entryData.CustomProperties == nil || (self.le.entryData.CustomProperties.CustomFlightProperty.count == 0 && !self.le.propsHaveBeenDownloaded))
        {
            if ((self.le.propsHaveBeenDownloaded = [fp loadPropertiesForFlight:self.le.entryData.FlightID forUser:[MFBAppDelegate threadSafeAppDelegate].userProfile.AuthToken]))
                self.le.entryData.CustomProperties = fp.rgFlightProps;
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showErrorAlertWithMessage:fp.errorString];
                });
                fError = YES;
            }
        }
    }
    
    if (!fError)
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (void) refreshProperties
{
    // We will hit the web if the cache is not fully valid OR if the flight is not local
    int cs = [self.flightProps cacheStatus];
    BOOL fIsLocal = [self.le.entryData isNewOrPending];
    BOOL fHitWeb = (cs != cacheValid || !fIsLocal);

    if (fHitWeb)
        [NSThread detachNewThreadSelector:@selector(refreshPropertiesWorker) toTarget:self withObject:nil];
}

#pragma mark - Data Source - picker
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.selectibleAircraft.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    MFBWebServiceSvc_Aircraft * ac = self.selectibleAircraft[row];
    if (ac.isAnonymous)
        return ac.displayTailNumber;
    return [NSString stringWithFormat:@"%@ (%@)", ac.TailNumber, ac.ModelDescription];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    MFBWebServiceSvc_Aircraft * ac = self.selectibleAircraft[row];
    self.le.entryData.AircraftID = ac.AircraftID;
    self.idPopAircraft.text = ac.displayTailNumber;
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
        ec.txt.text = [sender.date utcString];
        switch (row)
        {
            case rowDateTail:
                return;
            case rowEngineStart:
                self.le.entryData.EngineStart = sender.date;
                break;
            case rowEngineEnd:
                self.le.entryData.EngineEnd = sender.date;
                break;
            case rowFlightStart:
                self.le.entryData.FlightStart = sender.date;
                break;
            case rowFlightEnd:
                self.le.entryData.FlightEnd = sender.date;
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
        case rowPropertiesHeader:
        case rowAddProperties:
            return NO;
        default:
            if (ip.section == sectProperties && ip.row > 0)
            {
                MFBWebServiceSvc_CustomFlightProperty * cfp = (MFBWebServiceSvc_CustomFlightProperty *) (self.le.entryData.CustomProperties.CustomFlightProperty)[ip.row - 1];
                MFBWebServiceSvc_CustomPropertyType * cpt = [self.flightProps PropTypeFromID:cfp.PropTypeID];
                return cpt.Type != MFBWebServiceSvc_CFPPropertyType_cfpBoolean;
            }
            return NO;
    }
}

- (void) nextClicked
{
    UITableViewCell * cell = [self owningCellGeneric:self.activeTextField];
    if ([cell isKindOfClass:[NavigableCell class]] && [((NavigableCell *) cell) navNext:self.activeTextField])
        return;
    [super nextClicked];
}

- (void) prevClicked
{
    UITableViewCell * cell = [self owningCellGeneric:self.activeTextField];
    if ([cell isKindOfClass:[NavigableCell class]] && [((NavigableCell *) cell) navPrev:self.activeTextField])
        return;
    [super prevClicked];
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
        }
        [self autoHobbs];
        [self autoTotal];
        if (row != rowHobbsStart)
            [self.tableView endEditing:YES];
    }
    [self initLEFromForm];
}

- (void) doneClicked
{
    self.activeTextField = nil;
    [super doneClicked];
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

#pragma mark - Approach Helper
- (IBAction) addApproach:(id) sender
{
    ApproachEditor * editor = [ApproachEditor new];
    editor.delegate = self;
    [editor setAirports:[Airports CodesFromString:self.idRoute.text]];
    [self pushOrPopView:editor fromView:sender withDelegate:self];
}

- (void) addApproachDescription:(ApproachDescription *) approachDescription
{
    [self.le.entryData addApproachDescription:approachDescription.description];

    if (approachDescription.addToTotals)
        self.idApproaches.value = self.le.entryData.Approaches = @(self.le.entryData.Approaches.integerValue + approachDescription.approachCount);
    [self.tableView reloadData];
}

#pragma mark - Time Calculator
- (void) timeCalculator:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.idTotalTime resignFirstResponder];
        [self initLEFromForm];
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

#pragma mark - Send actions
- (void) repeatFlight:(BOOL) fReverse {
    LogbookEntry * leNew = [[LogbookEntry alloc] init];

    leNew.entryData  = fReverse ? [self.le.entryData cloneAndReverse] : [self.le.entryData clone];
    leNew.entryData.FlightID = QUEUED_FLIGHT_UNSUBMITTED;   // don't auto-submit this flight!
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    [app queueFlightForLater:leNew];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"flightActionComplete", @"Flight Action Complete Title") message:NSLocalizedString(@"flightActionRepeatComplete", @"Flight Action - repeated flight created") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(flightUpdated:)])
            [self.delegate flightUpdated:self];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) sendFlightToPilot {
    if (self.le.entryData.SendFlightLink.length == 0)
        return;
    
    NSString * szEncodedSubject = [NSLocalizedString(@"flightActionSendSubject", @"Flight Action - Send Subject") stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * szEncodedBody = [[NSString stringWithFormat:NSLocalizedString(@"flightActionSendBody", @"Flight Action - Send Body"), self.le.entryData.SendFlightLink] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString * szURL = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
                        szEncodedSubject,
                        szEncodedBody];
    
    [[UIApplication sharedApplication]  openURL: [NSURL URLWithString: szURL]];
}

- (void) shareFlight:(id) sender {
    if (self.le.entryData.SocialMediaLink.length == 0)
        return;
    
    NSString * szComment = [[NSString stringWithFormat:@"%@ %@", self.le.entryData.Comment, self.le.entryData.Route] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSURL * url = [NSURL URLWithString:self.le.entryData.SocialMediaLink];
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:@[szComment, url] applicationActivities:nil];
    
    avc.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    [self presentViewController:avc animated:YES completion:nil];
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
@end
