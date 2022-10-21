/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2022 MyFlightbook, LLC
 
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
//  RecentFlights.m
//  MFBSample
//
//  Created by Eric Berman on 1/14/10.
//

#import "RecentFlights.h"
#import "MFBAppDelegate.h"
#import "MFBSoapCall.h"
#import "RecentFlightCell.h"
#import "DecimalEdit.h"
#import "FlightProps.h"
#import "iRate.h"
#import "WPSAlertController.h"
#import "PackAndGo.h"

@interface RecentFlights()
@property (atomic, strong) NSMutableDictionary * dictImages;
@property (atomic, assign) BOOL uploadInProgress;
@property (atomic, strong) NSIndexPath * ipSelectedCell;
@property (atomic, strong) id JSONObjToImport;
@property (nonatomic, strong) NSURL * urlTelemetry;
@property (readwrite, strong) NSMutableArray<MFBWebServiceSvc_LogbookEntry *> * rgFlights;
@property (readwrite, strong) NSMutableArray<MFBWebServiceSvc_PendingFlight *> * rgPendingFlights;
@property (readwrite, strong) NSString * errorString;
@property (readwrite, atomic) NSInteger callsAwaitingCompletion;
@property (readwrite, atomic) BOOL refreshOnResultsComplete;
@property (atomic, strong) NSMutableArray<NSNumber *> * activeSections;
@property (atomic, strong) NSMutableDictionary<NSString *, RecentFlightCell *> * offscreenCells;

- (BOOL) hasUnsubmittedFlights;
@end

@implementation RecentFlights

static const int cFlightsPageSize=15;   // number of flights to download at a time by default.

NSInteger iFlightInProgress, cFlightsToSubmit;
BOOL fCouldBeMoreFlights;

@synthesize rgFlights, errorString, fq, cellProgress, uploadInProgress, dictImages, ipSelectedCell, JSONObjToImport, urlTelemetry, rgPendingFlights, callsAwaitingCompletion, refreshOnResultsComplete, activeSections, offscreenCells;

- (void) asyncLoadThumbnailsForFlights:(NSArray *) flights {
    if (flights == nil || ![AutodetectOptions showFlightImages])
        return;
    
    @autoreleasepool {
        for (MFBWebServiceSvc_LogbookEntry * le in flights) {
            // crash if you store into a dictionary using nil key, so check for that
            if (le == nil || le.FlightID == nil || self.dictImages[le.FlightID] != nil)
                continue;
            
            CommentedImage * ci = [CommentedImage new];
            if ([le.FlightImages.MFBImageInfo count] > 0)
                ci.imgInfo = (MFBWebServiceSvc_MFBImageInfo *) (le.FlightImages.MFBImageInfo)[0];
            else  {
                // try to get an aircraft image.
                MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] AircraftByID:[le.AircraftID intValue]];
                if ([ac.AircraftImages.MFBImageInfo count] > 0)
                    ci.imgInfo = (MFBWebServiceSvc_MFBImageInfo *) (ac.AircraftImages.MFBImageInfo)[0];
                else
                    ci.imgInfo = nil;
            }
            
            [ci GetThumbnail];
            @synchronized (self) {
                self.dictImages[le.FlightID] = ci;  // TODO: this line is crashing sometimes.  EXC_BAD_ACCESS.  Why?
            }
        }
        [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark View lifecycle, management
- (void)viewDidLoad {
    [super viewDidLoad];
    
    fCouldBeMoreFlights = YES;
    self.callsAwaitingCompletion = 0;
    self.refreshOnResultsComplete = NO;
    
    self.cellProgress = [ProgressCell getProgressCell:self.tableView];
	
	self.rgFlights = [NSMutableArray new];
    self.rgPendingFlights = [NSMutableArray new];
    self.activeSections = [NSMutableArray new];
	self.errorString = @"";
    if (self.fq == nil)
        self.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    	
    // get notifications when the network is acquired.
    MFBAppDelegate * app = mfbApp();
    app.reachabilityDelegate = self;
    
    // get notifications when data is changed OR when user signs out
    [app registerNotifyDataChanged:self];
    [app registerNotifyResetAll:self];
    
    self.tableView.estimatedRowHeight = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad ? 80 : 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	// put the refresh button up IF we are the top controller
    // else, don't do anything with it because we need a way to navigate back
    if ((self.navigationController.viewControllers)[0] == self)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    else
        self.navigationItem.leftBarButtonItem = nil;
    self.navigationController.toolbarHidden = YES;

    if (self.dictImages == nil)
    {
        self.dictImages = [NSMutableDictionary new];
        if (mfbApp().isOnLine)
            [NSThread detachNewThreadSelector:@selector(asyncLoadThumbnailsForFlights:) toTarget:self withObject:self.rgFlights];
    }
    
    if (!mfbApp().isOnLine && (self.rgFlights == nil || self.rgFlights.count == 0) && PackAndGo.lastFlightsPackDate != nil) {
        self.rgFlights = [NSMutableArray arrayWithArray:PackAndGo.cachedFlights];
        [self warnPackedData:PackAndGo.lastVisitedPackDate];
    }
    
    [super viewWillAppear:animated];
}


- (void) flightUpdated:(LEEditController *) sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) warnPackedData:(NSDate *) dtLastPack {
    NSDateFormatter * df = NSDateFormatter.new;
    df.dateStyle = NSDateFormatterShortStyle;
    [self showError:[NSString stringWithFormat:NSLocalizedString(@"PackAndGoUsingCached", @"Pack and go - Using Cached"), [df stringFromDate:dtLastPack]] withTitle:NSLocalizedString(@"PackAndGoOffline", @"Pack and go - Using Cached")];
}

- (void) refresh:(BOOL) fSubmitUnsubmittedFlights
{
    NSDate * dtLastPack = PackAndGo.lastFlightsPackDate;
    if (!mfbApp().isOnLine) {
        if (dtLastPack != nil) {
            self.rgFlights = [NSMutableArray arrayWithArray:PackAndGo.cachedFlights];
            self.rgPendingFlights = [NSMutableArray new];   // no pending flights with pack-and-go
            [self.tableView reloadData];
            self.fIsValid = YES;
            [self warnPackedData:dtLastPack];
        }
        else {
            self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
            [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading recent flights", @"Title for error message on recent flights")];
        }
        return;
    }
    
    @synchronized (self) {
        if (self.dictImages == nil)
            self.dictImages = [NSMutableDictionary new];
        else
            [self.dictImages removeAllObjects];
    }
    self.rgFlights = [NSMutableArray new];
    self.rgPendingFlights = [NSMutableArray new];
    
    fCouldBeMoreFlights = YES;
	MFBAppDelegate * app = mfbApp();
	[app invalidateCachedTotals];
    
    // if we are forcing a resubmit, clear any errors and resubmit; this will cause 
    // loadFlightsForUser to be called (refreshing the existing flights.)
    // Otherwise, just do the refresh directly.
    if (fSubmitUnsubmittedFlights && self.hasUnsubmittedFlights)
    {
        // clear the errors from unsubmitted flights so that they can potentially go again.
        for (LogbookEntry * le in app.rgUnsubmittedFlights)
            le.errorString = @"";
        [self submitUnsubmittedFlights];
    }
    else
        [self.tableView reloadData];    // this should trigger refresh simply by displaying the trigger row.
}

- (void) refresh
{
    [self refresh:YES];
}

- (void) invalidateViewController
{
    self.rgFlights = [NSMutableArray new];
    self.rgPendingFlights = [NSMutableArray new];
    @synchronized (self) {
        if (self.dictImages == nil)
            self.dictImages = [NSMutableDictionary new];
        else
            [self.dictImages removeAllObjects];
    }
    fCouldBeMoreFlights = YES;
    self.fIsValid = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

	MFBAppDelegate * app = mfbApp();
    if ([app isOnLine] && ([self hasUnsubmittedFlights] || !self.fIsValid || self.rgFlights == nil))
        [self refresh];
    else
        [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	self.rgFlights = nil;
    self.rgPendingFlights = nil;
    @synchronized (self) {
        [self.dictImages removeAllObjects];
    }
	[((MFBAppDelegate *) [[UIApplication sharedApplication] delegate]) invalidateCachedTotals];
}

#pragma View a flight
- (LEEditController *) pushViewControllerForFlight:(LogbookEntry *) le
{
    LEEditController * leView = [[LEEditController alloc]
                                 initWithNibName:(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"LEEditController-iPad" : @"LEEditController"
                                 bundle:nil];
    leView.le = le;
    leView.delegate = self;
    [self.navigationController pushViewController:leView animated:YES];
    return leView;
}

#pragma mark Managing simultaneous calls
/*
 This is a bit of a hack, but because of committing flights and simultenous outstanding calls to pendingflights and flightswithquery, we can have multiple calls awaiting results.
 This can also lead to two race conditions.
 
 The first is just general badness where the pending flights call returns quickly and resets callInProgress, so the table reloads and because callInProgress is NO,
 it triggers a second (or third or fourth) call to flightsWithQuery.  ouch!
 
 The second is a race condition:
  - View appears, which causes reload, which causes flightsWithQuery call
  - Also needs to submit an unsubmittedflight, so it submits this
  - Submission returns quickly, so it calls refresh, but refresh no-ops because it already has a call outstanding.
 
 The fix for this is to count the number of outstanding requests.  For the latter, we'll also allow a flag saying "hey, when all requests finish, do one more refresh.  (That's the hack).
 */

- (void) addPendingCall {
    @synchronized (self) {
        self.callInProgress = YES;
        self.callsAwaitingCompletion++;
    }
}

- (void) removePendingCall {
    @synchronized (self) {
        self.callInProgress = (--self.callsAwaitingCompletion != 0);
        if (self.callsAwaitingCompletion < 0)
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"negative calls pending completion!" userInfo:nil];
    }
    if (!self.callInProgress && self.refreshOnResultsComplete) {
        self.refreshOnResultsComplete = NO;
        [self refresh:NO];
    }
}

#pragma mark Loading recent flights / infinite scroll
- (void) loadFlightsForUser
{
	self.errorString = @"";
	
    if (!fCouldBeMoreFlights || self.callInProgress)
        return;
    
    NSString * authtoken = mfbApp().userProfile.AuthToken;
	if ([authtoken length] == 0)
    {
		self.errorString = NSLocalizedString(@"You must be signed in to view recent flights.", @"Error - must be signed in to view flights");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading recent flights", @"Title for error message on recent flights")];
        fCouldBeMoreFlights = NO;
    }
    else if (![mfbApp() isOnLine])
    {
        self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading recent flights", @"Title for error message on recent flights")];
        fCouldBeMoreFlights = NO;
    }
	else
    {
        [self addPendingCall];

        MFBWebServiceSvc_FlightsWithQueryAndOffset * fbdSVC = [MFBWebServiceSvc_FlightsWithQueryAndOffset new];
        
        fbdSVC.szAuthUserToken = authtoken;
        fbdSVC.fq = self.fq;
        fbdSVC.offset = @((NSInteger) self.rgFlights.count);
        fbdSVC.maxCount = @(cFlightsPageSize);
        
        MFBSoapCall * sc = [[MFBSoapCall alloc] init];
        sc.logCallData = NO;
        sc.delegate = self;
        
        [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
            [b FlightsWithQueryAndOffsetAsyncUsingParameters:fbdSVC delegate:sc];
        }];
        
        // Get pending flights as well, but only on first refresh because we already have all of the pending flights from the previous (offset=0) call
        if (fbdSVC.offset.intValue == 0 && self.fq.isUnrestricted) {
            [self addPendingCall];
            MFBWebServiceSvc_PendingFlightsForUser * pfu = [MFBWebServiceSvc_PendingFlightsForUser new];
            pfu.szAuthUserToken = authtoken;
            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b PendingFlightsForUserAsyncUsingParameters:pfu delegate:sc];
            }];
        }
    }
}

- (void) deletePendingFlight:(MFBWebServiceSvc_PendingFlight *) pf {
    if (self.callInProgress)
        return;
    
    NSString * authtoken = mfbApp().userProfile.AuthToken;
    if ([authtoken length] == 0)
    {
        self.errorString = NSLocalizedString(@"You must be signed in to perform this action", @"Error - must be signed in");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading recent flights", @"Title for error message on recent flights")];
    }
    else if (![mfbApp() isOnLine])
    {
        self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error deleting flight", @"Title for error message when flight delete fails")];
    }
    else
    {
        [self addPendingCall];
        
        MFBWebServiceSvc_DeletePendingFlight * dpfSvc = [MFBWebServiceSvc_DeletePendingFlight new];
        dpfSvc.szAuthUserToken = authtoken;
        dpfSvc.idpending = pf.PendingID;
        
        MFBSoapCall * sc = [[MFBSoapCall alloc] init];
        sc.logCallData = NO;
        sc.delegate = self;
        
        [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
            [b DeletePendingFlightAsyncUsingParameters:dpfSvc delegate:sc];
        }];
    }
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse class]])
	{
		MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse * resp = (MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse *) body;
        NSArray * rgIncrementalResults = resp.FlightsWithQueryAndOffsetResult.LogbookEntry;
        fCouldBeMoreFlights = (rgIncrementalResults.count >= cFlightsPageSize);
        if (self.rgFlights == nil)
            self.rgFlights = [NSMutableArray arrayWithArray:rgIncrementalResults];
        else
            [self.rgFlights addObjectsFromArray:rgIncrementalResults];
        
        // Update any high-water mark tach/hobbs
        Aircraft * aircraft = [Aircraft sharedAircraft];
        for (MFBWebServiceSvc_LogbookEntry * le in self.rgFlights) {
            [aircraft setHighWaterHobbs:le.HobbsEnd forAircraft:le.AircraftID];
            if (le.CustomProperties != nil && le.CustomProperties.CustomFlightProperty != nil) {
                for(MFBWebServiceSvc_CustomFlightProperty * cfp in le.CustomProperties.CustomFlightProperty) {
                    if (cfp.PropTypeID.intValue == PropTypeID_TachEnd) {
                        [aircraft setHighWaterTach:cfp.DecValue forAircraft:le.AircraftID];
                        break;
                    }
                }
            }
        }
            
        [NSThread detachNewThreadSelector:@selector(asyncLoadThumbnailsForFlights:) toTarget:self withObject:rgIncrementalResults];
    } else if ([body isKindOfClass:[MFBWebServiceSvc_PendingFlightsForUserResponse class]]) {
        MFBWebServiceSvc_PendingFlightsForUserResponse * resp = (MFBWebServiceSvc_PendingFlightsForUserResponse *) body;
        self.rgPendingFlights = [NSMutableArray arrayWithArray:resp.PendingFlightsForUserResult.PendingFlight];
    } else if ([body isKindOfClass:[MFBWebServiceSvc_DeletePendingFlightResponse class]]) {
        MFBWebServiceSvc_DeletePendingFlightResponse * resp = (MFBWebServiceSvc_DeletePendingFlightResponse *) body;
        self.rgPendingFlights = [NSMutableArray arrayWithArray:resp.DeletePendingFlightResult.PendingFlight];
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;
 	if ([self.errorString length] > 0)
    {
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading recent flights", @"Title for error message on recent flights")];
        fCouldBeMoreFlights = NO;
    }
    [self removePendingCall];
    
	self.fIsValid = YES;
    
    if (isLoading)
        [self stopLoading];
    
    [self.tableView reloadData];
    
    // update the glance.
    if (self.fq.isUnrestricted && self.rgFlights.count > 0)
        mfbApp().watchData.latestFlight = [((MFBWebServiceSvc_LogbookEntry *) self.rgFlights[0]) toSimpleItem];
}

#pragma unsubmittedFlights
- (BOOL) hasUnsubmittedFlights {
	return [mfbApp().rgUnsubmittedFlights count] > 0;
}

- (void) submitUnsubmittedFlightsCompleted:(MFBSoapCall *) sc fromCaller:(LogbookEntry *) le {
    MFBAppDelegate * app = mfbApp();
    if ([le.errorString length] == 0 && !le.entryData.isQueued) { // success
        [app dequeueUnsubmittedFlight:le];
        [[iRate sharedInstance] logEvent:NO];   // ask user to rate the app if they have saved the requesite # of flights
        NSLog(@"iRate eventCount: %ld, uses: %ld", (long) [iRate sharedInstance].eventCount, (long) [iRate sharedInstance].usesCount);
        [self.tableView reloadData];
    }
    
    iFlightInProgress++;
    
    if (iFlightInProgress >= cFlightsToSubmit) {
        NSLog(@"No more flights to submit");
        self.uploadInProgress = NO;
        if (self.callInProgress)
            self.refreshOnResultsComplete = YES;
        else
            [self refresh:NO];
    }
    else
        [self submitUnsubmittedFlight];
}

- (void) submitUnsubmittedFlight {
    float progressValue = ((float) iFlightInProgress + 1.0) / ((float) cFlightsToSubmit);
    if (self.cellProgress == nil)
        self.cellProgress = [ProgressCell getProgressCell:self.tableView];

    self.cellProgress.progressBar.progress =  progressValue;
    NSString * flightTemplate = NSLocalizedString(@"Flight %d of %d", @"Progress message when uploading unsubmitted flights");
    self.cellProgress.progressLabel.text = [NSString stringWithFormat:flightTemplate, iFlightInProgress + 1, cFlightsToSubmit];
    self.cellProgress.progressDetailLabel.text = @"";

    // Take this off of the BACK of the array, since we're going to remove it if successful and don't want to screw up
    // the other indices.
    MFBAppDelegate * app = mfbApp();
    NSInteger index = cFlightsToSubmit - iFlightInProgress - 1;
    NSLog(@"iFlight=%ld, cFlights=%ld, rgCount=%lu, index=%ld", (long) iFlightInProgress, (long) cFlightsToSubmit, (long) app.rgUnsubmittedFlights.count, (long) index);
    if (app.rgUnsubmittedFlights == nil || index >= app.rgUnsubmittedFlights.count) // should never happen.
        return;
    
    LogbookEntry * le = (LogbookEntry *) (app.rgUnsubmittedFlights)[index];
    
    if (!le.entryData.isQueued && le.errorString.length == 0) { // no holdover error
        le.szAuthToken = app.userProfile.AuthToken;
        le.progressLabel = self.cellProgress.progressDetailLabel;
        [le setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
            [self removePendingCall];
            [self submitUnsubmittedFlightsCompleted:sc fromCaller:(LogbookEntry *) ao];
        }];
        [self addPendingCall];
        [le commitFlight];
    }
    else // skip the commit on this; it needs to be fixed - just go on to the next one.
        [self submitUnsubmittedFlightsCompleted:nil fromCaller:le];
}

- (void) submitUnsubmittedFlights {
    if (![self hasUnsubmittedFlights] || ![mfbApp() isOnLine])
        return;
    
    cFlightsToSubmit = mfbApp().rgUnsubmittedFlights.count;
    
    if (cFlightsToSubmit == 0)
        return;
    
    self.uploadInProgress = YES;
    iFlightInProgress = 0;
    [self.tableView reloadData];
    
    [self submitUnsubmittedFlight];
}

#pragma mark Table view methods
typedef enum {sectFlightQuery, sectUploadInProgress, sectUnsubmittedFlights, sectPendingFlights, sectExistingFlights} RecentSection;

- (RecentSection) sectionFromIndexPathSection:(NSInteger) section {
    return self.activeSections[section].intValue;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /*
     Layout is:
            FlightQuery  - always visible
            (upload progress)
            (unsubmittedflights)
            (pendingflights)
            Existing flights
     
     We refresh this and cache in self.activeSessions because unsubmittedflihts or uploadinprogress can change between calls to numberofsectionsintableview and sectionfromindexpathsection.
     */

    [self.activeSections removeAllObjects];
    [self.activeSections addObject:@(sectFlightQuery)]; // Query - always visible
    
    if (self.uploadInProgress)
        [self.activeSections addObject:@(sectUploadInProgress)];
    if (self.hasUnsubmittedFlights)
        [self.activeSections addObject:@(sectUnsubmittedFlights)];
    if (self.rgPendingFlights.count > 0 && self.fq.isUnrestricted)  // don't show pending flights if we have an active query.
        [self.activeSections addObject:@(sectPendingFlights)];
    [self.activeSections addObject:@(sectExistingFlights)];

    return self.activeSections.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ([self sectionFromIndexPathSection:section]) {
        case sectFlightQuery:
            return mfbApp().isOnLine ? 1 : 0;
        case sectUploadInProgress:
            return self.uploadInProgress ? 1 : 0;
        case sectUnsubmittedFlights:
            return mfbApp().rgUnsubmittedFlights.count;
        case sectPendingFlights:
            return self.fq.isUnrestricted ? self.rgPendingFlights.count : 0;
        case sectExistingFlights:
            return self.rgFlights.count + (mfbApp().isOnLine && ((self.callInProgress || fCouldBeMoreFlights)) ? 1 : 0);
        default:
            NSAssert(NO, @"Unknown section requested");
            return 0;
    }
}

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section
{
    switch ([self sectionFromIndexPathSection:section]) {
        case sectExistingFlights:
            if ([self.rgFlights count] > 0)
                return NSLocalizedString(@"Recent Flights", @"Title for list of recent flights");
            else
                return NSLocalizedString(@"No flights found for selected dates.", @"No flights found in date range");
        case sectUnsubmittedFlights:
            return NSLocalizedString(@"Flights awaiting upload", @"Title for list of flights awaiting upload");
        case  sectPendingFlights:
            return NSLocalizedString(@"PendingFlightsHeader", @"Title for list of pending flights");
        case sectUploadInProgress:
        case sectFlightQuery:
            return @"";
    }
}

- (MFBWebServiceSvc_LogbookEntry *) flightForIndexPath:(NSIndexPath *) indexPath {
    int section = [self sectionFromIndexPathSection:indexPath.section];
    if (section == sectPendingFlights)
        return self.rgPendingFlights[indexPath.row];
    else if (section == sectExistingFlights && indexPath.row < self.rgFlights.count)
        return (MFBWebServiceSvc_LogbookEntry *) (self.rgFlights)[indexPath.row];
    else
        return nil;
}


- (recentRowType) rowTypeForFlight:(MFBWebServiceSvc_LogbookEntry *) le {
    BOOL fShowImages = AutodetectOptions.showFlightImages;
    BOOL fShowSig = le.CFISignatureState == MFBWebServiceSvc_SignatureState_Valid || le.CFISignatureState == MFBWebServiceSvc_SignatureState_Invalid;
    return fShowImages ? (fShowSig ? textSigAndImage : textAndImage) : (fShowSig ? textAndSig : textOnly);
}

- (NSString *) reuseIDForRowType:(recentRowType) rt {
    static NSString * RFCellIdentifierText = @"recentFlightCellText";
    static NSString * RFCellIdentifierSig = @"recentFlightCellSig";
    static NSString * RFCellIdentifierImg = @"recentFlightCellImg";
    static NSString * RFCellIdentifierImgSig = @"recentflightcellSigAndImg";

    switch (rt) {
        case textOnly:
            return RFCellIdentifierText;
        case textAndSig:
            return RFCellIdentifierSig;
        case textAndImage:
            return RFCellIdentifierImg;
        case textSigAndImage:
        default:
            return RFCellIdentifierImgSig;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBWebServiceSvc_LogbookEntry * le = nil;
    CommentedImage * ci = nil;
    NSString * szErr = @"";
    
    int section = [self sectionFromIndexPathSection:indexPath.section];
    switch (section) {
        case sectFlightQuery: {
            static NSString * CellQuerySelector = @"querycell";
            UITableViewCell *cellSelector = [tableView dequeueReusableCellWithIdentifier:CellQuerySelector];
            if (cellSelector == nil) {
                cellSelector = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellQuerySelector];
                cellSelector.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            NSAssert(cellSelector, @"cellSelector (flight query) is nil, we are about to crash");
            cellSelector.textLabel.text = NSLocalizedString(@"FlightSearch", @"Choose Flights");
            cellSelector.detailTextLabel.text = [self.fq isUnrestricted] ? NSLocalizedString(@"All Flights", @"All flights are selected") : NSLocalizedString(@"Not all flights", @"Not all flights are selected");
            cellSelector.imageView.image = [UIImage imageNamed:@"search.png"];
            return cellSelector;
        }
        case sectUploadInProgress: {
            if (self.cellProgress == nil)
                self.cellProgress = [ProgressCell getProgressCell:self.tableView];
            NSAssert(self.cellProgress, @"cellProgress is nil, we are about to crash");
            return self.cellProgress;
        }
        case sectPendingFlights:
            le = [self flightForIndexPath:indexPath];
            break;
        case sectUnsubmittedFlights: {
            // We could have a race condition where we are fetching a flight after it has been submitted.
            LogbookEntry * l;
            
            @try {
                l = (LogbookEntry *) (mfbApp().rgUnsubmittedFlights)[indexPath.row];
            }
            @catch (NSException * ex) {
                // shouldn't happen, but if it does, just create a dummy entry
                l = [[LogbookEntry alloc] init];
                l.entryData.Date = [NSDate date];
                l.entryData.TailNumDisplay = @"...";
                l.errorString = ex.debugDescription;
            }
            
            szErr = l.errorString;

            ci = (l.rgPicsForFlight != nil && l.rgPicsForFlight.count > 0) ? (CommentedImage *) (l.rgPicsForFlight)[0] : nil;
            le = l.entryData;
            NSAssert(le != nil, @"NULL le in unsbmitted flights - we are going to crash!!!");
            break;
        }
        case sectExistingFlights: {
            BOOL fIsTriggerRow = (indexPath.row >= self.rgFlights.count);   // is this the row to trigger the next batch of flights?
            if (fIsTriggerRow)
            {
                [self loadFlightsForUser];  // get the next batch
                return [self waitCellWithText:NSLocalizedString(@"Getting Recent Flights...", @"Progress - getting recent flights")];
            }
            
            le = [self flightForIndexPath:indexPath];
            @synchronized (self) {
                ci = (le == nil || le.FlightID == nil) ? nil : (CommentedImage *) (self.dictImages)[le.FlightID];
            }
            
            NSAssert(le != nil, @"NULL le in existing flights - we are going to crash!!!"); // TODO: still crash here sometimes.  Why?
            break;
        }
    }
    
    NSAssert(le != nil, @"NULL le - we are going to crash!!!");
    
    // If we are here, we are showing actual flights.
    recentRowType rt = [self rowTypeForFlight:le];
    NSString * identifier = [self reuseIDForRowType:rt];
    RecentFlightCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
        cell = [RecentFlightCell newRecentFlightCell:rt];
    NSAssert(cell != nil, @"nil flight cell - we are going to crash!!!");
    
    if (le.TailNumDisplay == nil)
        le.TailNumDisplay = [[Aircraft sharedAircraft] AircraftByID:[le.AircraftID intValue]].TailNumber;
    
    // this will force a layout
    [cell setFlight:le withImage:ci errorString:szErr forTable:tableView];

    if (@available(iOS 13.0, *)) {
        if (section == sectUnsubmittedFlights || section == sectPendingFlights)
            cell.backgroundColor = UIColor.systemGray4Color;
        else
            cell.backgroundColor = UIColor.systemBackgroundColor;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return default heights if it's OTHER than a pending flight or existing flight - which we can tell by nil le
    MFBWebServiceSvc_LogbookEntry * le = [self flightForIndexPath:indexPath];
    if (le == nil)
        return tableView.rowHeight;
    
    CommentedImage * ci = nil;
    @synchronized (self) {
        ci = (le == nil || le.FlightID == nil || [le.class isKindOfClass:MFBWebServiceSvc_PendingFlight.class]) ? nil : (CommentedImage *) (self.dictImages)[le.FlightID];
    }
    
    // Determine which reuse identifier should be used for the cell at this
    // index path.
    recentRowType rt = [self rowTypeForFlight:le];
    NSString * reuseIdentifier = [self reuseIDForRowType:rt];

    // Use a dictionary of offscreen cells to get a cell for the reuse
    // identifier, creating a cell and storing it in the dictionary if one
    // hasn't already been added for the reuse identifier. WARNING: Don't
    // call the table view's dequeueReusableCellWithIdentifier: method here
    // because this will result in a memory leak as the cell is created but
    // never returned from the tableView:cellForRowAtIndexPath: method!
    if (self.offscreenCells == nil)
        self.offscreenCells = [NSMutableDictionary new];
    
    RecentFlightCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [RecentFlightCell newRecentFlightCell:rt];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    // Configure the cell with content for the given indexPath.  This will force a layout
    [cell setFlight:le withImage:ci errorString:@"" forTable:tableView];

    // Get the actual height required for the cell's contentView
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;

    // Add an extra point to the height to account for the cell separator,
    // which is added between the bottom of the cell's contentView and the
    // bottom of the table view cell.
    height += 1.0;

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.callInProgress || isLoading)
        return;

	LogbookEntry * le = nil;
	
    switch ([self sectionFromIndexPathSection:indexPath.section]) {
        case sectFlightQuery: {
            NSAssert(indexPath.row == 0, @"Flight query row must only have one row!");
            FlightQueryForm * fqf = [FlightQueryForm new];
            fqf.delegate = self;
            [fqf setQuery:self.fq];
            [self.navigationController pushViewController:fqf animated:YES];
            return;
        }
        case sectUploadInProgress:
            return;
        case sectExistingFlights:
            le = [[LogbookEntry alloc] init];
            if (self.rgFlights == nil || indexPath.row >= self.rgFlights.count) // should never happen.
                return;
            le.entryData = (self.rgFlights)[indexPath.row];
            break;
        case sectPendingFlights:
            le = [[LogbookEntry alloc] init];
            le.entryData = self.rgPendingFlights[indexPath.row];
            break;
        case sectUnsubmittedFlights:
            le = (mfbApp().rgUnsubmittedFlights)[indexPath.row];
            break;
    }

    NSAssert(le != nil, @"Unable to find the flight to display!");
    [self pushViewControllerForFlight:le];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self sectionFromIndexPathSection:indexPath.section]) {
        case sectFlightQuery:
        case sectUploadInProgress:
            return NO;
        case sectExistingFlights:
            return indexPath.row < self.rgFlights.count;    // don't allow delete of the "Getting additional flights" row
        case sectUnsubmittedFlights:
            return !self.callInProgress;    // Issue #245: don't allow deletion of flight being uploaded
        case sectPendingFlights:
            return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
        self.ipSelectedCell = indexPath;
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Confirm Deletion", @"Title of confirm message to delete a flight")
                                                                        message:NSLocalizedString(@"Are you sure you want to delete this flight?  This CANNOT be undone!", @"Delete Flight confirmation") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
            LogbookEntry * le = [[LogbookEntry alloc] init];
            
            NSIndexPath * ip = self.ipSelectedCell;
            
            RecentSection rs = [self sectionFromIndexPathSection:ip.section];
            
            if (rs == sectExistingFlights) {
                // deleting an existing flight
                le.szAuthToken = app.userProfile.AuthToken;
                MFBWebServiceSvc_LogbookEntry * leToDelete = (MFBWebServiceSvc_LogbookEntry *) (self.rgFlights)[ip.row];
                int idFlightToDelete = [leToDelete.FlightID intValue];
                @synchronized (self) {
                    [self.dictImages removeObjectForKey:leToDelete.FlightID];
                }
                [self.rgFlights removeObjectAtIndex:ip.row];
                [le setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
                    if ([sc.errorString length] == 0)
                        [self refresh]; // will call invalidatecached totals
                    else {
                        NSString * szError = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Unable to delete the flight.", @"Error deleting flight"), sc.errorString];
                        [self showAlertWithTitle:NSLocalizedString(@"Error deleting flight", @"Title for error message when flight delete fails") message:szError];
                    }
                }];
                [le deleteFlight:idFlightToDelete];
            }
            else if (rs == sectUnsubmittedFlights)
                [app dequeueUnsubmittedFlight:(LogbookEntry *) (app.rgUnsubmittedFlights)[ip.row]];
            else if (rs == sectPendingFlights) {
                [self deletePendingFlight:self.rgPendingFlights[ip.row]];
            }
            self.ipSelectedCell = nil;
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
	}
}

#pragma mark QueryDelegate
- (void) queryUpdated:(MFBWebServiceSvc_FlightQuery *) f
{
    self.fq = f;
    [self refresh];
}

#pragma mark Reachability Delegate
- (void) networkAcquired
{
    if (self.uploadInProgress)
        return;
    
    NSLog(@"RecentFlights: Network acquired - submitting any unsubmitted flights");
    fCouldBeMoreFlights = YES;
    [self performSelectorOnMainThread:@selector(submitUnsubmittedFlights) withObject:nil waitUntilDone:NO];
}

#pragma mark Import
- (void) importFlightFinished:(LogbookEntry *) le {
    // dismiss the progress indicator
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (le == nil)
        return;
    
    LEEditController * lev = [self pushViewControllerForFlight:le];
    
    // Check for an existing new flight in-progress.
    // If the new flight screen is sitting with an initial hobbs but otherwise empty, then use its starting hobbs and then reset it.
    MFBWebServiceSvc_LogbookEntry * leActiveNew = mfbApp().leMain.le.entryData;
    BOOL fIsInInitialState = leActiveNew.isInInitialState;
    NSNumber * initHobbs = fIsInInitialState ? leActiveNew.HobbsStart : @0.0;
    
    lev.le.entryData.HobbsStart = initHobbs;
    [lev autoHobbs];
    [lev autoTotal];
    
    /// Carry over the ending hobbs as the new starting hobbs for the flight.
    if (fIsInInitialState)
        mfbApp().leMain.le.entryData.HobbsStart = lev.le.entryData.HobbsEnd;
    
    self.urlTelemetry = nil;
    [self.tableView reloadData];
}

- (void) importFlightWorker
{
    LogbookEntry * le = [GPSSim ImportTelemetry:self.urlTelemetry];
    [self performSelectorOnMainThread:@selector(importFlightFinished:) withObject:le waitUntilDone:NO];
}

#pragma mark Add flight via URL
- (void) addJSONFlight:(NSString *)szJSON
{
    NSError * error = nil;
    
    self.JSONObjToImport = [NSJSONSerialization JSONObjectWithData:[szJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil)
    {
        [self showErrorAlertWithMessage:error.localizedDescription];
        self.JSONObjToImport = nil;
        return;
    }

    // get the name of the requesting app.
    NSDictionary * dictRoot = (NSDictionary *) self.JSONObjToImport;
    NSDictionary * dictMeta = (NSDictionary *) dictRoot[@"metadata"];
    NSString * szApplication = (NSString *) dictMeta[@"application"];
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:[NSString stringWithFormat:NSLocalizedString(@"AddFlightPrompt", @"Import Flight"), szApplication] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [LogbookEntry addPendingJSONFlights:self.JSONObjToImport];
        self.JSONObjToImport = nil;
        [self.tableView reloadData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark Add flight via Telemetry
- (void) addTelemetryFlight:(NSURL *) url
{
    self.urlTelemetry = url;
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"InitFromTelemetry", @"Import Flight Telemetry") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"ActivityInProgress", @"Activity In Progress") onViewController:self];
        [NSThread detachNewThreadSelector:@selector(importFlightWorker) toTarget:self withObject:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

