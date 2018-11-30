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
//  Totals.m
//  MFBSample
//
//  Created by Eric Berman on 12/22/09.
//

#import "Totals.h"
#import "MFBAppDelegate.h"
#import "DecimalEdit.h"
#import "util.h"
#import "RecentFlights.h"

@implementation Totals

@synthesize rgTotals;
@synthesize errorString;
@synthesize fq;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark View Management
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.rgTotals = [NSMutableArray new];
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
    self.rgTotals = nil;
    self.fIsValid = NO;
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	if (self.rgTotals == nil || !self.fIsValid)
	{
		[self refresh];
        [self.tableView reloadData];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	self.rgTotals = nil;
	[mfbApp() invalidateCachedTotals];
}

#pragma mark DateRangeDelegate
- (void) refresh
{    	
	NSLog(@"LoadTotalsForUser");
	self.errorString = @"";
	
    NSString * authToken = mfbApp().userProfile.AuthToken;
	if ([authToken length] == 0)
    {
		self.errorString = NSLocalizedString(@"You must be signed in to view totals.",nil);
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
    }
    else if (![mfbApp() isOnLine])
    {
        self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
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
        self.rgTotals = resp.TotalsForUserWithQueryResult.TotalsItem;
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
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
    {
        if (self.callInProgress)
            return 1;
        return [self.rgTotals count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"";
    else if (section == 1 && [self.rgTotals count] == 0)
        return NSLocalizedString(@"No totals are available.", @"No totals retrieved");
    else
        return @"";
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
        return cellSelector;
    }
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Getting Totals...", @"progress indicator")];

    MFBWebServiceSvc_TotalsItem * ti = (MFBWebServiceSvc_TotalsItem *) (self.rgTotals)[indexPath.row];
    return [TotalsRow rowForTotal:ti forTableView:tableView usngHHMM:[AutodetectOptions HHMMPref]];
}

/*
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Date Range";
    else
        return @"Totals";
}
 */

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
        MFBWebServiceSvc_TotalsItem * ti = (MFBWebServiceSvc_TotalsItem *) (self.rgTotals)[indexPath.row];
        
        if (ti.Query != nil)
        {
            RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
            rf.fq = ti.Query;
            [rf refresh];
            [self.navigationController pushViewController:rf animated:YES];
        }
    }
    

    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



@end
