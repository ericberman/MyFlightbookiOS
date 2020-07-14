/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019-2020 MyFlightbook, LLC
 
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
//  SelectTemplates.m
//  MyFlightbook
//
//  Created by Eric Berman on 6/11/19.
//

#import "SelectTemplates.h"
#import "FlightProps.h"
#import "MFBAppDelegate.h"

@interface SelectTemplates ()
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> * templateGroups;
@end

@implementation SelectTemplates

@synthesize templateSet, templateGroups, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.templateGroups = [MFBWebServiceSvc_PropertyTemplate groupTemplates:FlightProps.sharedTemplates];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
}

#pragma retrieving templates
- (NSDictionary<NSString *, id> *) groupDictionaryForSection:(NSInteger) section {
    return self.templateGroups[section];
}

- (NSArray<MFBWebServiceSvc_PropertyTemplate *> *) propsForSection:(NSInteger) section {
    return (NSArray<MFBWebServiceSvc_PropertyTemplate *> *) ([self groupDictionaryForSection:section][KEY_PROPSFORGROUP]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.templateGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self propsForSection:section].count;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return (NSString *) [self groupDictionaryForSection:section][KEY_GROUPNAME];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellTempl";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

    MFBWebServiceSvc_PropertyTemplate * pt = [self propsForSection:indexPath.section][indexPath.row];

    cell.textLabel.text = pt.Name;
    cell.detailTextLabel.text = pt.Description;
    cell.accessoryType = [self.templateSet containsObject:pt] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MFBWebServiceSvc_PropertyTemplate * pt = [self propsForSection:indexPath.section][indexPath.row];
    if ([self.templateSet containsObject:pt])
        [self.templateSet removeObject:pt];
    else
        [self.templateSet addObject:pt];
    [self.tableView reloadData];
    [self.delegate templatesUpdated:self.templateSet];
}

#pragma - mark Refresh
- (void) refresh {
    MFBWebServiceSvc_PropertiesAndTemplatesForUser * cptSvc = [MFBWebServiceSvc_PropertiesAndTemplatesForUser new];
    MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
    
    if (!app.isOnLine)
    {
        [self endCall];
        return;
    }

    cptSvc.szAuthUserToken = app.userProfile.AuthToken;
    
    MFBSoapCall * sc = [MFBSoapCall new];
    sc.logCallData = NO;
    sc.timeOut = 10;
    sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b PropertiesAndTemplatesForUserAsyncUsingParameters:cptSvc delegate:sc];
    }];
}

- (void) BodyReturned:(id)body
{
    if ([body isKindOfClass:[MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse class]]) {
        MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse * resp = (MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse *) body;
        
        // sanity check, but should never happen.
        if (resp.PropertiesAndTemplatesForUserResult.UserProperties.CustomPropertyType == nil || resp.PropertiesAndTemplatesForUserResult.UserProperties.CustomPropertyType.count == 0)
            return;
        
        [FlightProps.sharedTemplates removeAllObjects];
        [FlightProps.sharedTemplates addObjectsFromArray:resp.PropertiesAndTemplatesForUserResult.UserTemplates.PropertyTemplate];
        [FlightProps saveTemplates];
        [self.templateSet removeAllObjects];
        for (MFBWebServiceSvc_PropertyTemplate * pt in FlightProps.sharedTemplates)
            if (pt.IsDefault.boolValue)
                [self.templateSet addObject:pt];
        self.templateGroups = [MFBWebServiceSvc_PropertyTemplate groupTemplates:FlightProps.sharedTemplates];
        self.fIsValid = YES;

        // update the cache of proptypes too, since we got 'em...
        FlightProps * fp = [[FlightProps alloc] init];
        [fp setPropTypeArray:resp.PropertiesAndTemplatesForUserResult.UserProperties.CustomPropertyType];
        [fp cacheProps];
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc {
    if ([sc.errorString length] > 0)
        [self showError:sc.errorString withTitle:NSLocalizedString(@"Error loading totals", @"Title for error message")];
    else {
        [self.tableView reloadData];
        if (self.delegate != nil)
            [self.delegate templatesUpdated:self.templateSet];
    }
    
    if (isLoading)
        [self stopLoading];
    [self endCall];
}@end
