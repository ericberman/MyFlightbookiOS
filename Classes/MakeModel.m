/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2011-2018 MyFlightbook, LLC
 
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
//  MakeModel.m
//  MFBSample
//
//  Created by Eric Berman on 8/2/11.
//

#import "MakeModel.h"
#import "ExpandHeaderCell.h"

// Local object: ManufacturerCollection includes all of the models for a given manufacturer
@interface ManufacturerCollection : NSObject {}
@property (nonatomic, strong) NSString * szManufacturer;
@property (nonatomic, strong) NSMutableArray * rgModels;
@end

@implementation ManufacturerCollection

@synthesize szManufacturer, rgModels;

- (instancetype) init
{
    if (self = [super init])
    {
        self.szManufacturer = nil;
        self.rgModels = nil;
    }
    return self;
}

- (instancetype) initWithName:(NSString *) szMan
{
    if (self = [super init])
    {
        self.szManufacturer = szMan;
        self.rgModels = [NSMutableArray new];
    }
    return self;
}

@end

@interface MakeModel () <UISearchDisplayDelegate>
@property (strong) NSArray * rgFilteredMakes;
@property (nonatomic, strong) NSMutableArray * content;
@property (nonatomic, strong) NSMutableArray * indices;
@property (nonatomic, strong) NSMutableDictionary * dictIndexMap;
@property (nonatomic, readwrite) BOOL fDisableRefresh;
@end

@implementation  MakeModel

@synthesize indices, content, ac, rgFilteredMakes, dictIndexMap, searchBar;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return (self = [super initWithStyle:style]);
}


#pragma mark - Data
/*  
    The data structure is this:
    self.content is an array of ManufacturerCollection objects
    Each ManufacturerCollection has the name of the manufacturer and an array of its models (SimpleMakeModel)
*/
- (void) refreshData
{
    // now chop the property types up for indexing.
    // we will then convert that dictionary to an array and sort it.
    
    self.content = [[NSMutableArray alloc] init];
    NSString * szKey = @"";
    NSCharacterSet * alphaSet = [NSCharacterSet alphanumericCharacterSet];
    
    if (self.rgFilteredMakes == nil)
        self.rgFilteredMakes = [NSArray arrayWithArray:[Aircraft sharedAircraft].rgMakeModels];
    NSArray * arMakes = self.rgFilteredMakes;
    
    // Create the array of ManufacturerCollection objects from the models in the above array
    NSMutableDictionary * dictMC = [NSMutableDictionary new];
    for (MFBWebServiceSvc_SimpleMakeModel * mm in arMakes)
    {
        NSString * szMan = [mm manufacturerName];
        ManufacturerCollection * mc = dictMC[szMan];
        if (mc == nil)
        {
            mc = [[ManufacturerCollection alloc] initWithName:szMan];
            dictMC[szMan] = mc;
        }
        [mc.rgModels addObject:mm];
    }
    
    // Now create an array of these models
    [dictMC enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { [self.content addObject:obj];}];
    
    // Sort by manufacturer name
    [self.content sortUsingComparator:^NSComparisonResult(ManufacturerCollection * mc1, ManufacturerCollection * mc2) {
        return [mc1.szManufacturer caseInsensitiveCompare:mc2.szManufacturer];
    }];
    
    // And build up the appropriate indices
    self.indices = [NSMutableArray new];
    [self.indices addObject:UITableViewIndexSearch];
    self.dictIndexMap = [NSMutableDictionary new];
    
    for (NSInteger i = 0; i < [self.content count]; i++)
    {
        ManufacturerCollection * mc = (ManufacturerCollection *) self.content[i];
        NSString * szNewKey = [[mc.szManufacturer substringToIndex:1] uppercaseString];

        if ([[szNewKey stringByTrimmingCharactersInSet:alphaSet] isEqualToString:szNewKey])
            szNewKey = @" ";
        
        if ([szKey compare:szNewKey] == NSOrderedSame)
            continue;
        
        szKey = szNewKey;
        [self.indices addObject:szNewKey];
        (self.dictIndexMap)[szNewKey] = @(i);
    }
}

#pragma mark Update Makes and models
- (void) updateMakesCompleted:(MFBSoapCall *) sc fromCaller:(Aircraft *) a
{
    [self endCall];
    if (isLoading)
        [self stopLoading];
    
    self.rgFilteredMakes = [NSArray arrayWithArray:[Aircraft sharedAircraft].rgMakeModels];
    [self refreshData];
    [self.tableView reloadData]; // in case the static description needs to be updated.
}

- (void) refresh
{
    if (self.fDisableRefresh || ![mfbApp() isOnLine])
    {
        if (isLoading)
            [self stopLoading];
        return;
    }
    
    if (self.callInProgress)
        return;
    
    [self startCall];
    
    Aircraft * a = [Aircraft sharedAircraft];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self updateMakesCompleted:sc fromCaller:(Aircraft *) ao];
    }];
    [a loadMakeModels];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.content count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ManufacturerCollection * mc = (ManufacturerCollection *) self.content[section];
    return 1 + ([self isExpanded:section] ? [mc.rgModels count] : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierModel = @"Cell";
    
    // Get the manufacturer collection for this indexpath
    ManufacturerCollection * mc = (ManufacturerCollection *) self.content[indexPath.section];
    
    // See if this is a header cell or not.
    if (indexPath.row == 0)
        return [ExpandHeaderCell getHeaderCell:tableView withTitle:mc.szManufacturer forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];

    // Otherwise, it's a model cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierModel];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierModel];
    }
    
    MFBWebServiceSvc_SimpleMakeModel * mm = (MFBWebServiceSvc_SimpleMakeModel *) mc.rgModels[indexPath.row - 1];
    
    cell.textLabel.text = [mm manufacturerName];
    if ([cell.textLabel.text compare:mm.Description] != NSOrderedSame)
        cell.detailTextLabel.text = [mm subDesc];
    
    return cell;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indices;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title compare:UITableViewIndexSearch] == NSOrderedSame) {
        [self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
        return -1;
    }
    NSNumber * num = (self.dictIndexMap)[title];
    return (num == nil) ? 0 : num.integerValue;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self toggleSection:indexPath.section forTable:tableView];
        return;
    }

    ManufacturerCollection * mc = (ManufacturerCollection *) self.content[indexPath.section];
    MFBWebServiceSvc_SimpleMakeModel * mm = (MFBWebServiceSvc_SimpleMakeModel *) mc.rgModels[indexPath.row - 1];
    self.ac.ModelID = mm.ModelID;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate
- (void) updateFilteredMakes:(NSString *) szFilter
{
    NSArray * rgMakes = [Aircraft sharedAircraft].rgMakeModels;
    if (szFilter == nil || [szFilter length] == 0)
        self.rgFilteredMakes = [NSArray arrayWithArray:rgMakes];
    else {
        NSCharacterSet * nonAlphaNumeric = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        NSArray<NSString *> * searchStrings = [szFilter componentsSeparatedByCharactersInSet:nonAlphaNumeric];
        self.rgFilteredMakes = [rgMakes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL(id evaluatedObject, NSDictionary *bindings)
               {
                   MFBWebServiceSvc_SimpleMakeModel * m = (MFBWebServiceSvc_SimpleMakeModel *) evaluatedObject;
                   for (NSString * sz in searchStrings)
                       if (sz.length > 0 && [m.Description rangeOfString:sz options:NSCaseInsensitiveSearch].location == NSNotFound)
                           return NO;
                   
                   return YES;
               }]];
    }
    [self refreshData];
}

#pragma mark -
#pragma UISearchDisplayDelegate
- (void)updateResultsForText:(NSString *) searchText
{
    self.fDisableRefresh = YES;
    [self updateFilteredMakes:searchText];
    if (self.content.count > 5)
        [self collapseAll];
    else
        [self expandAll:self.tableView];
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
    [self collapseAll];
    [self updateFilteredMakes:@""];
    [self.tableView reloadData];
    self.fDisableRefresh = NO;
}
@end
