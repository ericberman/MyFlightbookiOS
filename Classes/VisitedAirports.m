/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2011-2023 MyFlightbook, LLC
 
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
//  VisitedAirports.m
//  MFBSample
//
//  Created by Eric Berman on 8/2/11.
//

#import "VisitedAirports.h"
#import "VisitedAirportRow.h"
#import "VADetails.h"
#import "PackAndGo.h"

@interface VisitedAirports()
@property (strong) NSMutableArray<MFBWebServiceSvc_VisitedAirport *> * rgVAFiltered;
@property (nonatomic, strong) NSMutableArray<MFBWebServiceSvc_VisitedAirport *> * rgVA;
@property (nonatomic, strong) NSString * errorString;
@property (nonatomic, strong) NSMutableArray * content;
@property (nonatomic, strong) NSArray * indices;
@property (nonatomic, strong) VADetails * vaDetails;
@end

@implementation VisitedAirports

static NSString * szKeyRowValues = @"rowValues";
static NSString * szKeyHeaderTitle = @"headerTitle";

@synthesize rgVAFiltered, rgVA, errorString, content, indices, vaDetails, searchBar;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    self.rgVA = nil;
    self.vaDetails = nil;
    self.content = nil;
    self.indices = nil;
    self.searchBar = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.errorString = @"";
    self.rgVA = nil;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateVisitedAirports)];

    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
    [app registerNotifyDataChanged:self];
    [app registerNotifyResetAll:self];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.searchBar.placeholder = NSLocalizedString(@"AirportsSearchPrompt", @"Search for airports");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.rgVA == nil || !self.fIsValid)
        [self updateVisitedAirports];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - GetData
- (void) setData:(NSArray<MFBWebServiceSvc_VisitedAirport *> *) arr {
    self.rgVA = [NSMutableArray arrayWithArray:arr];
    [self.rgVA sortUsingSelector:@selector(compareName:)];
    [self refreshFilteredAirports:self.searchBar.text = @""];
    self.rgVAFiltered = [NSMutableArray arrayWithArray:self.rgVA];
    [self setUpIndices];
}

- (void) updateVisitedAirports
{
    self.errorString = @"";
	
    self.tableView.allowsSelection = YES;
    NSString * authToken = MFBProfile.sharedProfile.AuthToken;
	if ([authToken length] == 0)
    {
		self.errorString = NSLocalizedString(@"You must sign in to view visited airports.", @"Can't see visited airports if not signed in.");
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading visited airports", @"Title when an error occurs loading visited airports")];
    }
    else if (![MFBAppDelegate.threadSafeAppDelegate isOnLine])
    {
        NSDate * dtLastPack = PackAndGo.lastVisitedPackDate;
        if (dtLastPack != nil) {
            NSDateFormatter * df = NSDateFormatter.new;
            df.dateStyle = NSDateFormatterShortStyle;
            [self setData:PackAndGo.cachedVisited];
            self.tableView.allowsSelection = NO;
            [self.tableView reloadData];
            self.fIsValid = YES;
            [self showError:[NSString stringWithFormat:NSLocalizedString(@"PackAndGoUsingCached", @"Pack and go - Using Cached"), [df stringFromDate:dtLastPack]] withTitle:NSLocalizedString(@"PackAndGoOffline", @"Pack and go - Using Cached")];
        }
        else {
            self.errorString = NSLocalizedString(@"No connection to the Internet is available", @"Error: Offline");
            [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading visited airports", @"Title when an error occurs loading visited airports")];
        }
    }
    else
    {
        if (self.callInProgress)
            return;
        
        [self startCall];
        MFBWebServiceSvc_VisitedAirports * visitedAirportsSVC = [MFBWebServiceSvc_VisitedAirports new];

        visitedAirportsSVC.szAuthToken = authToken;

        MFBSoapCall * sc = [[MFBSoapCall alloc] init];
        sc.delegate = self;

        [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
            [b VisitedAirportsAsyncUsingParameters:visitedAirportsSVC delegate:sc];
        }];
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc
{
    self.errorString = sc.errorString;
	if ([self.errorString length] > 0)
        [self showError:self.errorString withTitle:NSLocalizedString(@"Error loading visited airports", @"Title when an error occurs loading visited airports")];
    else
        [self.tableView reloadData];
    
    if (isLoading)
        [self stopLoading];
    [self endCall];
}

- (void) refresh
{
    self.searchBar.text = @"";
    [self updateVisitedAirports];
}

- (void) invalidateViewController
{
    self.rgVA = nil;
    self.content = nil;
    self.fIsValid = NO;
    [self.tableView reloadData];
}

- (void) setUpIndices
{
    // now chop this up into individual sections.
    // we create an dictionary of dictionary objects.
    // Each dictionary object contains the (a) the header title (1st letter of airpport code) +
    // (b) an array of all airports beginning with that code.
    // we will then convert that dictionary to an array and sort it.
    
    self.content = [[NSMutableArray alloc] init];
    NSString * szKey = @"";
    
    for (MFBWebServiceSvc_VisitedAirport * va in self.rgVAFiltered)
    {
        NSString * szNewKey = [va.Airport.Name substringToIndex:1];
        NSMutableDictionary * dictForKey;
        
        if ([szKey compare:szNewKey] == NSOrderedSame)
            dictForKey = (NSMutableDictionary *)(self.content)[[self.content count] - 1];
        else
        {
            szKey = szNewKey;
            // create the dictionary
            dictForKey = [[NSMutableDictionary alloc] init];
            // add the two items (header title and a mutable array)
            [dictForKey setValue:szKey forKey:szKeyHeaderTitle];
            dictForKey[szKeyRowValues] = [[NSMutableArray alloc] init];
            // and add this dctionary to contentDict
            [self.content addObject:dictForKey];
        }
        
        // now get the array (perhaps just stored)
        NSMutableArray * rgAirportsForKey = (NSMutableArray *) dictForKey[szKeyRowValues];
        [rgAirportsForKey addObject:va];
        dictForKey[szKey] = rgAirportsForKey;
    }
    
    // Add the "All items" item before all the others
    NSDictionary * dictAll = [[NSMutableDictionary alloc] init];
    [dictAll setValue:NSLocalizedString(@"All", @"In visited airports, the table of contents on the right has A, B, ... Z for quick access to individual airports and 'All' for all airports") forKey:szKeyHeaderTitle];
    [dictAll setValue:[[NSMutableArray alloc] init] forKey:szKeyRowValues];
    [self.content insertObject:dictAll atIndex:0];
    
    // and get the array of header titles.
    self.indices = [self.content valueForKey:szKeyHeaderTitle];
}

- (void) BodyReturned:(id)body
{
	if ([body isKindOfClass:[MFBWebServiceSvc_VisitedAirportsResponse class]])
	{
		MFBWebServiceSvc_VisitedAirportsResponse * resp = (MFBWebServiceSvc_VisitedAirportsResponse *) body;
        MFBWebServiceSvc_ArrayOfVisitedAirport * rg = resp.VisitedAirportsResult;
        MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
        		
        self.rgVA = rg.VisitedAirport;
        self.searchBar.text = @"";
		for (MFBWebServiceSvc_VisitedAirport * va in rg.VisitedAirport)
		{
            if (app.mfbloc.lastSeenLoc != nil)
            {
                CLLocation * locVA = [[CLLocation alloc] initWithLatitude:[va.Airport.Latitude doubleValue] longitude:[va.Airport.Longitude doubleValue]];

                if ([app.mfbloc.lastSeenLoc respondsToSelector:@selector(distanceFromLocation:)])
                    va.Airport.DistanceFromPosition = @([app.mfbloc.lastSeenLoc distanceFromLocation:locVA] * MFBConstants.NM_IN_A_METER);
                else
                    va.Airport.DistanceFromPosition = @0.0;
            }
        }
        
        [self setData:self.rgVA];
        
        [PackAndGo updateVisited:self.rgVA];
        
        self.fIsValid = YES;
	}
}

#pragma mark - UISearchBarDelegate
- (void) refreshFilteredAirports:(NSString *) szFilter
{
    if (szFilter == nil || [szFilter length] == 0)
        self.rgVAFiltered = [NSMutableArray arrayWithArray:self.rgVA];
    else
        self.rgVAFiltered = [NSMutableArray arrayWithArray:[self.rgVA filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL(MFBWebServiceSvc_VisitedAirport * va, NSDictionary *bindings)
              {
                  NSString * szSearch = [NSString stringWithFormat:@"%@ %@", va.Code, va.Airport.Name];
                  return [szSearch rangeOfString:szFilter options:NSCaseInsensitiveSearch].location != NSNotFound;
              }]]];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)updateResultsForText:(NSString *) searchText
{
    [self stopLoading];
    [self refreshFilteredAirports:searchText];
    [self setUpIndices];
    [self.tableView reloadData];
}


- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateResultsForText:searchText];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)sb
{
    [self updateResultsForText:sb.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (self.content)[section][szKeyHeaderTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.callInProgress)
        return 1;
    else
        return [self.content count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
    {
        if (self.callInProgress)
            return 1;
        else
            return [((NSMutableArray *) (self.content)[section][szKeyRowValues]) count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VisitedAirportCell";
    static NSString *CellIdentifierAll = @"VisitedAirportCellAll";
    static NSDateFormatter * df = nil;
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Getting Visited Airports...", @"Progress indicator while getting visited airports")];
    
    if (indexPath.section == 0) // ALL airports item.
    {
        UITableViewCell *cellAll = [tableView dequeueReusableCellWithIdentifier:CellIdentifierAll];
        if (cellAll == nil)
        {
            cellAll = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierAll];
            cellAll.selectionStyle = UITableViewCellSelectionStyleBlue;
            cellAll.accessoryType = ([rgVA count] > 0) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
        cellAll.textLabel.text = NSLocalizedString(@"All Airports", @"The 'airport' that shows all visited airports");
        cellAll.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"(%lu unique airports found)", @"# of unique visited airports that were found; '%d' gets replaced at runtime; leave it there!"), (unsigned long)self.rgVAFiltered.count];
        return cellAll;
    }
    else
    {    
        // Configure the cell...
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (df == nil)
        {
            df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterShortStyle];
        }
        
        MFBWebServiceSvc_VisitedAirport * va;
        va = (MFBWebServiceSvc_VisitedAirport *) (self.content)[indexPath.section][szKeyRowValues][indexPath.row];

        cell.textLabel.attributedText = [NSAttributedString attributedStringFromMarkDown:[NSString stringWithFormat:@"*%@* - %@", va.Airport.Code, va.Airport.Name.capitalizedString] size:cell.textLabel.font.pointSize];
        double dist = [va.Airport.DistanceFromPosition doubleValue];
        NSString * szDist = (dist > 0) ? [NSString localizedStringWithFormat:NSLocalizedString(@"(%.1fNM) ", @"Distance to an airport; the '%.1f' gets replaced by the numerical value at runtime; leave it there"), dist] : @"";
        if ([va.NumberOfVisits intValue] == 1)
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@%d visit on %@", @"For a visited airport, this puts the distance at the first %@, the number of visits at the %d, and the date of the visit at the latter %@; e.g., '(3.2NM) 2 visits on Jan 10 2010', so leave the %d and %@ intact"), szDist, [va.NumberOfVisits intValue],
                                  [df stringFromDate:va.EarliestVisitDate]];
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@%d visits from %@ to %@", @"For a visited airport, this puts the distance at the first %@, the number of visits at the %d, and the earliest/latest dates at the other %@; e.g., '(3.2NM) 2 visits from Jan 10 2010 to Mar 31, 2011', so leave the %d/%@ intact"), szDist, [va.NumberOfVisits intValue],
                         [df stringFromDate:va.EarliestVisitDate], [df stringFromDate:va.LatestVisitDate]];

        return cell;
    }   
    return nil;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.content valueForKey:szKeyHeaderTitle];
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.indices indexOfObject:title];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.rgVAFiltered.count == 0)
        return;
    
    // don't respond to selection if we're refreshing.
    if (isLoading)
        return;
    
    if (!MFBAppDelegate.threadSafeAppDelegate.isOnLine)
        return;
    
    if (self.vaDetails == nil)
        self.vaDetails = [[VADetails alloc] initWithNibName:@"VADetails" bundle:nil];
    
    if (indexPath.section == 0)
        self.vaDetails.rgVA = self.rgVAFiltered;
    else
        self.vaDetails.rgVA = @[(MFBWebServiceSvc_VisitedAirport *) (self.content)[indexPath.section][szKeyRowValues][indexPath.row]];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController pushViewController:vaDetails animated:YES];
}

@end
