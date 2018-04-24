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
//  Currency.m
//  MFBSample
//
//  Created by Eric Berman on 12/23/09.
//

#import "Currency.h"
#import "HostedWebViewViewController.h"
#import "AircraftViewController.h"
#import "RecentFlights.h"

@interface Currency()
@property (readwrite, strong) NSMutableArray<MFBWebServiceSvc_CurrencyStatusItem *> * rgCurrency;
@property (readwrite, strong) NSString * errorString;
@end

@implementation Currency

@synthesize rgCurrency;
@synthesize errorString;

#define sectCurrency 1
#define sectDisclaimer 0

#pragma mark View Management
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

	self.rgCurrency = [NSMutableArray new];
	self.errorString = [NSString new];

    MFBAppDelegate * app = mfbApp();
    [app registerNotifyDataChanged:self];
    [app registerNotifyResetAll:self];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void) invalidateViewController
{
    self.rgCurrency = nil;
    [self.tableView reloadData];
    self.fIsValid = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	
	if (self.rgCurrency == nil || !self.fIsValid)
		[self refresh];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	self.rgCurrency = nil;
	[((MFBAppDelegate *) [[UIApplication sharedApplication] delegate]) invalidateCachedTotals];
}

#pragma mark Get Data
- (void) refresh
{
	NSLog(@"LoadCurrencyForUser");
	self.errorString = @"";
    NSString * szAuthToken = mfbApp().userProfile.AuthToken;
	
	if ([szAuthToken length] == 0)
    {
		self.errorString = NSLocalizedString(@"You must be signed in to view currency", @"Must be signed in to view currency");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading currency", @"Title Error message when loading currency")];
    }
    else if (![mfbApp() isOnLine])
    {
        self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading currency", @"Title Error message when loading currency")];
    }
    else
    {
        if (self.callInProgress)
            return;
        
        [self startCall];

        MFBWebServiceSvc_GetCurrencyForUser * currencyForUserSVC = [MFBWebServiceSvc_GetCurrencyForUser new];
        
        currencyForUserSVC.szAuthToken = szAuthToken;
        
        MFBSoapCall * sc = [[MFBSoapCall alloc] init];
        sc.delegate = self;
        [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
            [b GetCurrencyForUserAsyncUsingParameters:currencyForUserSVC delegate:sc];
        }];
    }	
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_GetCurrencyForUserResponse class]])
	{
		MFBWebServiceSvc_GetCurrencyForUserResponse * resp = (MFBWebServiceSvc_GetCurrencyForUserResponse *) body;
		MFBWebServiceSvc_ArrayOfCurrencyStatusItem * rgCs = resp.GetCurrencyForUserResult;
		
        self.rgCurrency = rgCs.CurrencyStatusItem;
        self.fIsValid = YES;
	}
}

- (void) ResultCompleted:(MFBSoapCall *) sc
{
    self.errorString = sc.errorString;
	if ([self.errorString length] > 0)
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading currency", @"Title Error message when loading currency")];

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
    if (section == sectDisclaimer)
        return 1;
    if (section == sectCurrency)
    {
        if (self.callInProgress)
            return 1;
        else
            return [self.rgCurrency count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == sectDisclaimer)
        return @"";
    else {
        if ([self.rgCurrency count] == 0)
            return NSLocalizedString(@"No currency is available.", @"Unable to retrieve flying currency");
        else
            return @"";
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == sectDisclaimer)
    {
        static NSString * szId = @"Disclaimer";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:szId];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:szId];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = NSLocalizedString(@"Currency Disclaimer", @"Currency Disclaimer");
        cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;        
    }
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Getting Currency...", @"Progress indicator for currency")];
    
	MFBWebServiceSvc_CurrencyStatusItem * ci = (self.rgCurrency)[indexPath.row];
    
	// NOTE: we're not reusin cells because the addition of a new flight might cause currency to change, which
	// can cause the layout of the cell to change.  We want to use new cells every time.
	// The efficiency angle here is that we are caching the results, and only reloading if the cache is invalidated.
    static NSString *CellIdentifier = @"CurrencyCell";
    CurrencyRow * cell = (CurrencyRow *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CurrencyRow" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ( [firstObject isKindOfClass:[UITableViewCell class]] )
            cell = firstObject;     
        else cell = topLevelObjects[1];
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
    // Set up the cell...

    cell.lblDescription.text = ci.formattedTitle;
	
	// Color the value red/blue/green depending on severity:
    cell.lblValue.text = ci.Value;
	switch (ci.Status) {
		case MFBWebServiceSvc_CurrencyState_OK:
			cell.lblValue.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
			break;
		case MFBWebServiceSvc_CurrencyState_GettingClose:
			cell.lblValue.textColor = [UIColor blueColor];
			break;
		case MFBWebServiceSvc_CurrencyState_NotCurrent:
			cell.lblValue.textColor = [UIColor redColor];
			break;
        case MFBWebServiceSvc_CurrencyState_NoDate:
        case MFBWebServiceSvc_CurrencyState_none:
		default:
            cell.lblValue.textColor = [UIColor blackColor];
			break;
	}
	
    cell.lblDiscrepancy.text = ci.Discrepancy; 	// add any relevant discrepancy string
    
    [cell AdjustLayoutForValues];
	
    return cell;
}

- (void) pushWebURL:(NSString *) szPath {
    NSString * szProtocol = @"https";
#ifdef DEBUG
    if ([MFBHOSTNAME hasPrefix:@"192."] || [MFBHOSTNAME hasPrefix:@"10."])
        szProtocol = @"http";
#endif
    HostedWebViewViewController * vwWeb = [[HostedWebViewViewController alloc] initWithURL:[NSString stringWithFormat:@"%@://%@%@", szProtocol, MFBHOSTNAME, szPath]];
    [self.navigationController pushViewController:vwWeb animated:YES];
}

- (void) pushAuthURL:(NSString *) target {

    NSString * szURL = [NSString stringWithFormat:@"/logbook/public/authredir.aspx?u=%@&p=%@&d=%@&naked=1",
                        [mfbApp().userProfile.UserName stringByURLEncodingString],
                        [mfbApp().userProfile.Password stringByURLEncodingString],
                        target];
    [self pushWebURL:szURL];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == sectDisclaimer)
        [self pushWebURL:@"/logbook/Public/CurrencyDisclaimer.aspx?naked=1"];
    else if (indexPath.section == sectCurrency) {
        MFBWebServiceSvc_CurrencyStatusItem * ci = (self.rgCurrency)[indexPath.row];
        
        switch (ci.CurrencyGroup) {
            case MFBWebServiceSvc_CurrencyGroups_Medical:
                [self pushAuthURL:@"MEDICAL"];
                break;
            case MFBWebServiceSvc_CurrencyGroups_Deadline:
                [self pushAuthURL:@"DEADLINE"];
                break;
            case MFBWebServiceSvc_CurrencyGroups_Certificates:
                [self pushAuthURL:@"CERTIFICATES"];
                break;
            case MFBWebServiceSvc_CurrencyGroups_FlightReview:
                [self pushAuthURL:@"FLIGHTREVIEW"];
                break;
            case MFBWebServiceSvc_CurrencyGroups_CustomCurrency:
                if (ci.Query != nil)  {
                    RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
                    rf.fq = ci.Query;
                    [rf refresh];
                    [self.navigationController pushViewController:rf animated:YES];
                }
                else
                    [self pushAuthURL:@"CUSTOMCURRENCY"];
                break;
            case MFBWebServiceSvc_CurrencyGroups_Aircraft: {
                MFBWebServiceSvc_Aircraft * ac = [Aircraft.sharedAircraft AircraftByID:ci.AssociatedResourceID.intValue];
                if (ac != nil) {
                    AircraftViewController * acView;
                    acView = [[AircraftViewController alloc] initWithNibName:@"AircraftViewController" bundle:nil];
                    [acView setAircraft:ac];
                    
                    [self.navigationController pushViewController:acView animated:YES];
                }
            }
                break;
            case MFBWebServiceSvc_CurrencyGroups_none:
            case MFBWebServiceSvc_CurrencyGroups_None:
            case MFBWebServiceSvc_CurrencyGroups_FlightExperience:
                break;
        }
    }
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}
@end

