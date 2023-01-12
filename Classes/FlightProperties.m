/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2023 MyFlightbook, LLC
 
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
//  FlightProperties.m
//  MFBSample
//
//  Created by Eric Berman on 7/8/10.
//

#import "FlightProperties.h"
#import "PropertyCell.h"
#import "DecimalEdit.h"
#import "Util.h"

@interface FlightProperties ()
@property (strong) NSArray<MFBWebServiceSvc_CustomPropertyType *> * rgFilteredProps;
@property (nonatomic, strong) NSMutableArray * content;
@property (nonatomic, strong) NSArray * indices;

@property (strong, readwrite) FlightProps * flightProps;
@property (strong, readwrite) AccessoryBar * vwAccessory;
@property (strong, readwrite) UITextField * activeTextField;

@property (strong, readwrite) NSMutableDictionary * dictPropCells;

@property (strong, readwrite) NSMutableArray<MFBWebServiceSvc_CustomFlightProperty *> * rgAllProps;

- (void) refreshFilteredProps:(NSString *) szFilter;
@end

@implementation FlightProperties

@synthesize le, flightProps, content, activeTextField, indices, rgAllProps, rgFilteredProps, vwAccessory, datePicker, dictPropCells, activeTemplates;
@synthesize delegate;

static NSString * szKeyRowValues = @"rowValues";
static NSString * szKeyHeaderTitle = @"headerTitle";

#pragma mark -
#pragma mark View lifecycle
- (void) setUpIndices
{
    // now chop the property types up for indexing.
    // we create an dictionary of dictionary objects.  
    // Each dictionary object contains the (a) the header title (1st letter of airpport code) + 
    // (b) an array of all airports beginning with that code.
    // we will then convert that dictionary to an array and sort it.
    // At the start of the list, we have our favorites; we put these at the top.
    
    self.content = [[NSMutableArray alloc] init];
    NSString * szKey = @"";
    
    for (MFBWebServiceSvc_CustomPropertyType * cpt in self.flightProps.syncrhonizedProps)
    {
        NSString * szNewKey;
        NSMutableDictionary * dictForKey;
        
        // favorites go into the "favorites" bucket
        szNewKey = (cpt.IsFavorite.boolValue) ? NSLocalizedString(@"Used", @"Bucket for quick access to previously used properties; KEEP THIS SHORT - e.g., 'previously used' is too long to fit in the right margin!") : [cpt.Title substringToIndex:1];
            
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
            // and add this dictionary to contentDict
            [self.content addObject:dictForKey];
        }
        
        // now get the array (perhaps just stored)
        NSMutableArray * rgPropsForKey = (NSMutableArray *) dictForKey[szKeyRowValues];
        [rgPropsForKey addObject:cpt];   
        dictForKey[szKey] = rgPropsForKey;
    }
        
    // and get the array of header titles.
    self.indices = [self.content valueForKey:szKeyHeaderTitle];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	if (self.le != nil)
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)]];
	
	self.navigationItem.title = NSLocalizedString(@"Flight Properties", @"Title for flight properties list page");

	self.flightProps = [[FlightProps alloc] init];
    self.rgAllProps = [self.flightProps crossProduct:self.le.entryData.CustomProperties.CustomFlightProperty];
    self.dictPropCells = [[NSMutableDictionary alloc] init];
    
    [self setUpIndices];
    [self refreshFilteredProps:@""];
    
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
    self.searchBar.placeholder = NSLocalizedString(@"PropertySearchPrompt", @"Search Prompt Properties");
    [super viewWillAppear:animated];
}

- (void) commitChanges
{
    [self.le.entryData.CustomProperties setProperties:[self.flightProps distillList:self.rgAllProps includeLockedProps:YES includeTemplates:self.activeTemplates]];
}

- (void) refresh
{
    [self commitChanges];
    [self.flightProps setCacheRetry];
    [self.flightProps loadCustomPropertyTypes];
    self.rgAllProps = [self.flightProps crossProduct:self.le.entryData.CustomProperties.CustomFlightProperty];
    self.searchBar.text = @"";
    [self refreshFilteredProps:@""];
    [self setUpIndices];
    [self stopLoading];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.tableView endEditing:YES];
    [self commitChanges];
    [self.dictPropCells removeAllObjects];    // stop hoarding the cells
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source
- (BOOL) searchActive
{
    return self.searchBar.text.length > 0;
}

- (MFBWebServiceSvc_CustomFlightProperty *) FlightPropertyForType:(MFBWebServiceSvc_CustomPropertyType *) cpt
{
	for (MFBWebServiceSvc_CustomFlightProperty * cfp in self.rgAllProps)
		if ([cfp.PropTypeID intValue] == [cpt.PropTypeID intValue])
			return cfp;
	return nil;    
}

- (MFBWebServiceSvc_CustomPropertyType *) cptForIndexPath:(NSIndexPath *) indexPath forTable:(UITableView *) tableView
{
    return (self.searchActive) ? (self.rgFilteredProps)[indexPath.row] : (self.content)[indexPath.section][szKeyRowValues][indexPath.row];
}

- (MFBWebServiceSvc_CustomFlightProperty *) FlightPropertyForIndexPath:(NSIndexPath *) indexPath forTable:(UITableView *) tableView
{
    return [self FlightPropertyForType:[self cptForIndexPath:indexPath forTable:tableView]];
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (self.searchActive) ? nil : self.content[section][szKeyHeaderTitle];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.searchActive) ? 1 : self.content.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.searchActive) ? self.rgFilteredProps.count : ((NSMutableArray *) (self.content)[section][szKeyRowValues]).count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MFBWebServiceSvc_CustomPropertyType * cpt = [self cptForIndexPath:indexPath forTable:tableView];
    MFBWebServiceSvc_CustomFlightProperty * cfp = [self FlightPropertyForType:cpt];
    
    // hack for iOS 7 - we need to hold ALL of the cells around so that if you scroll away while editing it doesn't
    // crash while you edit another cell.
    PropertyCell *cell = (PropertyCell *) (self.dictPropCells)[cpt.PropTypeID];
    if (cell == nil)
    {
        cell = [PropertyCell getPropertyCell:tableView withCPT:cpt andFlightProperty:cfp];
        (self.dictPropCells)[cpt.PropTypeID] = cell;
    }
    
    // Configure the cell...
    cell.txt.delegate = self;
    cell.flightPropDelegate = self.flightProps;
    [cell configureCell:self.vwAccessory andDatePicker:self.datePicker defValue:[self.le.entryData xfillValueForPropType:cpt]];
    
    return cell;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * ar = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    if (!self.searchActive)
        [ar addObjectsFromArray:[self.content valueForKey:szKeyHeaderTitle]];
    return ar;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([title compare:UITableViewIndexSearch] == NSOrderedSame) {
        [self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
    }
    return self.searchActive ? 0 : [self.indices indexOfObject:title];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	MFBWebServiceSvc_CustomFlightProperty * cfp = [self FlightPropertyForIndexPath:indexPath forTable:tableView];

	return (cfp != nil);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		MFBWebServiceSvc_CustomFlightProperty * cfp = [self FlightPropertyForIndexPath:indexPath forTable:tableView];
		if (cfp != nil)
		{
            [self.flightProps deleteProperty:cfp forUser:mfbApp().userProfile.AuthToken];
            MFBWebServiceSvc_CustomPropertyType * cpt = [self cptForIndexPath:indexPath forTable:tableView];
            [cfp setDefaultForType:cpt];
            [self commitChanges];
            self.rgAllProps = [self.flightProps crossProduct:self.le.entryData.CustomProperties.CustomFlightProperty];
            [self.dictPropCells removeAllObjects];
            self.editing = NO;
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO]; // Because iOS sucks, you can't call reload data synchronously - it crashes.  So reload after we return
		}
        // [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

#pragma mark -
#pragma mark Table view delegate
- (void) handleClick:(UITableView *) tableView ForIndexPath:(NSIndexPath *) indexPath
{
    // See http://stackoverflow.com/questions/1896399/becomefirstresponder-on-uitextview-not-working;
    // Need to use [self.tableView cellForRow...] to get the existing cell, rather than [self tableview:self.tableView...];
    PropertyCell * pc = (PropertyCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (pc == nil)
        NSLog(@"Nil PropertyCell clicked.  WTF?");
    if ([pc handleClick])
    {
        [self.flightProps propValueChanged:pc.cfp];
        [tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.ipActive = indexPath;
    [self handleClick:tableView ForIndexPath:indexPath];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

#pragma mark - UISearchBarDelegate
- (void) refreshFilteredProps:(NSString *) szFilter
{
    if (szFilter == nil || [szFilter stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].length == 0)
        self.rgFilteredProps = [NSArray arrayWithArray:self.flightProps.rgPropTypes];
    else {
        NSArray<NSString *> * rgWords = [szFilter componentsSeparatedByString:@" "];
        self.rgFilteredProps = [self.flightProps.rgPropTypes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^ BOOL(id evaluatedObject, NSDictionary *bindings)
           {
               MFBWebServiceSvc_CustomPropertyType * cpt = (MFBWebServiceSvc_CustomPropertyType *) evaluatedObject;
               for (NSString * sz in rgWords)
                   if (sz.length > 0 && [cpt.Title rangeOfString:sz options:NSCaseInsensitiveSearch].location == NSNotFound)
                       return NO;
               return YES;
           }]];
     }
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)updateResultsForText:(NSString *) searchText
{
    [self stopLoading];
    [self refreshFilteredProps:searchText];
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

#pragma mark -
#pragma mark UITextFieldDelegate
- (PropertyCell *) owningPropertyCell:(UIView *) vw
{
    PropertyCell * pc = nil;
    
    while (vw != nil)
    {
        vw = vw.superview;
        
        if ([vw isKindOfClass:[PropertyCell class]])
             return (PropertyCell *) vw;
    }
    
    return pc;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    PropertyCell * pc = [self owningPropertyCell:textField];

    if (pc.cfp == nil)
        return; // should never happen?

    [pc handleTextUpdate:textField];
    
    if (self.delegate != nil)
        [delegate propertyUpdated:pc.cpt];
    
    [self.flightProps propValueChanged:pc.cfp];
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    PropertyCell * pc = [self owningPropertyCell:textField];
    
    if (pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDate || pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime)
        pc.cfp.DateValue = nil;
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{    
    PropertyCell * pc = [self owningPropertyCell:textField];
    
    // if pc.cfp is nil, see if we can find the property in the current flight's properties
    if (pc.cfp == nil)
        pc.cfp = [self FlightPropertyForType:pc.cpt];
    
    // If that didn't work, create a provisional property if necessary to hold the value and add it
    if (pc.cfp == nil)
    {
        pc.cfp = [MFBWebServiceSvc_CustomFlightProperty getNewFlightProperty];
        pc.cfp.PropTypeID = pc.cpt.PropTypeID;
        [pc.cfp setDefaultForType:pc.cpt];
        [self.le.entryData.CustomProperties.CustomFlightProperty addObject:pc.cfp];
    }
    
    BOOL fShouldEdit = [pc prepForEditing];
    
    if (!fShouldEdit && pc.cfp.PropTypeID.intValue == PropTypeID_BlockOut)
        [self.delegate dateOfFlightShouldReset:pc.cfp.DateValue];
    
    self.ipActive = [self.tableView indexPathForCell:pc];
    
    [self enableNextPrev:self.vwAccessory];
    
    if (fShouldEdit)
        self.activeTextField = textField;
    
    return fShouldEdit;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.activeTextField = nil;
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    PropertyCell * pc = [self owningPropertyCell:textField];
    
    switch (pc.cpt.Type) {
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            // Defer to the property cell so that autocompletion to previous values can work.
            return [pc textField:textField shouldChangeCharactersInRange:range replacementString:string];
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            return NO;
        default:
            // OK, at this point we have a number - either integer, decimal, or HH:MM.  Allow it if the result makes sense.
            return [textField isValidNumber:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    }
}

#pragma mark -
#pragma mark AccessoryViewDelegates
- (void) deleteClicked
{
    PropertyCell * pc = [self owningPropertyCell:self.activeTextField];
    self.activeTextField.text = @"";
    if (pc != nil && pc.cpt != nil &&
        (pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime || pc.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDate))
        pc.cfp.DateValue = nil;
}

- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    MFBWebServiceSvc_CustomPropertyType * cpt = [self cptForIndexPath:ip forTable:self.tableView];
    switch (cpt.Type)
    {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            return NO;
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
        {
            MFBWebServiceSvc_CustomFlightProperty * cfp = [self FlightPropertyForType:cpt];
            return ![NSDate isUnknownDate:cfp.DateValue];
        }
        default:
            return YES;
    }
}
@end

