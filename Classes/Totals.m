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
//  Totals.m
//  MFBSample
//
//  Created by Eric Berman on 12/22/09.
//

#import "Totals.h"
#import "MFBAppDelegate.h"
#import "RecentFlights.h"
#import "PackAndGo.h"

@interface Totals()
@property (nonatomic, strong) NSArray<NSArray<MFBWebServiceSvc_TotalsItem *> *> * rgTotalsGroups;
@property (nonatomic, strong) NSString * errorString;
@end

@implementation Totals

@synthesize errorString;
@synthesize fq;
@synthesize rgTotalsGroups;

#pragma mark View Management
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

    self.rgTotalsGroups = [NSArray new];
    self.fIsValid = NO;
	self.errorString = [NSString new];
    self.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    
    MFBAppDelegate * app = mfbApp();
    [app registerNotifyDataChanged:self];
    [app registerNotifyResetAll:self];
}

- (void) viewWillAppear:(BOOL)animated
{	
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void) invalidateViewController
{
    self.rgTotalsGroups = nil;
    self.fIsValid = NO;
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	if (self.rgTotalsGroups == nil || !self.fIsValid)
	{
		[self refresh];
        [self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    self.rgTotalsGroups = nil;
	[mfbApp() invalidateCachedTotals];
}

#pragma mark DateRangeDelegate
- (void) refresh
{    	
	NSLog(@"LoadTotalsForUser");
	self.errorString = @"";
    
    self.tableView.allowsSelection = YES;
	
    NSString * authToken = mfbApp().userProfile.AuthToken;
	if ([authToken length] == 0)
    {
		self.errorString = NSLocalizedString(@"You must be signed in to view totals.",nil);
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
    }
    else if (![mfbApp() isOnLine])
    {
        NSDate * dtLastPack = PackAndGo.lastTotalsPackDate;
        if (dtLastPack != nil) {
            NSDateFormatter * df = NSDateFormatter.new;
            df.dateStyle = NSDateFormatterShortStyle;
            self.rgTotalsGroups = [MFBWebServiceSvc_TotalsItem GroupWithItems:PackAndGo.cachedTotals];
            [self.tableView reloadData];
            self.fIsValid = YES;
            self.tableView.allowsSelection = NO;
            [self showError:[NSString stringWithFormat:NSLocalizedString(@"PackAndGoUsingCached", @"Pack and go - Using Cached"), [df stringFromDate:dtLastPack]] withTitle:NSLocalizedString(@"PackAndGoOffline", @"Pack and go - Using Cached")];
        }
        else {
            self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
            [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
        }
    }
    else
    {
        if (self.callInProgress)
            return;
        
        [self startCall];

        MFBWebServiceSvc_TotalsForUserWithQuery * totalsForUserSvc = [MFBWebServiceSvc_TotalsForUserWithQuery new];
        
        totalsForUserSvc.szAuthToken = authToken;
        totalsForUserSvc.fq = self.fq;
        
        MFBSoapCall * sc = [[MFBSoapCall alloc] init];
        sc.delegate = self;
        sc.logCallData = NO;
        
        [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
            [b TotalsForUserWithQueryAsyncUsingParameters:totalsForUserSvc delegate:sc];
        }];
    }
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_TotalsForUserWithQueryResponse class]])
	{
		MFBWebServiceSvc_TotalsForUserWithQueryResponse * resp = (MFBWebServiceSvc_TotalsForUserWithQueryResponse *) body;
        if (self.fq.isUnrestricted)
            [PackAndGo updateTotals:resp.TotalsForUserWithQueryResult.TotalsItem];
        self.rgTotalsGroups = [MFBWebServiceSvc_TotalsItem GroupWithItems:resp.TotalsForUserWithQueryResult.TotalsItem];
        self.fIsValid = YES;
	}
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;
	if ([self.errorString length] > 0)
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
    else
        [self.tableView reloadData];

    if (isLoading)
        [self stopLoading];
    [self endCall];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + (self.callInProgress ? 1 : (self.rgTotalsGroups.count == 0 ? 1 : self.rgTotalsGroups.count));
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return mfbApp().isOnLine ? 1 : 0;
    else
    {
        if (self.callInProgress)
            return 1;
        return (self.rgTotalsGroups.count == 0) ? 0 : self.rgTotalsGroups[section - 1].count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"";
    else if (section == 1 && self.rgTotalsGroups.count == 0)
        return NSLocalizedString(@"No totals are available.", @"No totals retrieved");
    else
        return self.rgTotalsGroups[section - 1][0].GroupName;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifierSelector = @"CellSelector";
    if (indexPath.section == 0) // Filter
    {
        UITableViewCell *cellSelector = [tableView dequeueReusableCellWithIdentifier:CellIdentifierSelector];
        if (cellSelector == nil)
        {
            cellSelector = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierSelector];
            cellSelector.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cellSelector.textLabel.text = NSLocalizedString(@"FlightSearch", @"Choose Flights");
        cellSelector.detailTextLabel.text = [self.fq isUnrestricted] ? 
            NSLocalizedString(@"All Flights", @"All flights are selected") :
            NSLocalizedString(@"Not all flights", @"Not all flights are selected");
        cellSelector.imageView.image = [UIImage imageNamed:@"search.png"];
        return cellSelector;
    }
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Getting Totals...", @"progress indicator")];

    MFBWebServiceSvc_TotalsItem * ti = self.rgTotalsGroups[indexPath.section - 1][indexPath.row];
    return [TotalsRow rowForTotal:ti forTableView:tableView usingHHMM:UserPreferences.current.HHMMPref];
}

- (void) queryUpdated:(MFBWebServiceSvc_FlightQuery *) f
{
    self.fq = f;
    [self refresh];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isLoading)
        return;
    
    if (indexPath.section == 0)
    {
        FlightQueryForm * fqv = [[FlightQueryForm alloc] init];
        fqv.delegate = self;
        [fqv setQuery:self.fq];
        [self.navigationController pushViewController:fqv animated:YES];
    }
    else
    {
        MFBWebServiceSvc_TotalsItem * ti = self.rgTotalsGroups[indexPath.section - 1][indexPath.row];
        
        if (ti.Query != nil)
        {
            RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
            rf.fq = ti.Query;
            [rf refresh];
            [self.navigationController pushViewController:rf animated:YES];
        }
    }
}
@end
