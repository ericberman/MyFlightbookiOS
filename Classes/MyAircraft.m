/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2018 MyFlightbook, LLC
 
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
//  MyAircraft.m
//  MFBSample
//
//  Created by Eric Berman on 2/21/10.
//

#import "MyAircraft.h"
#import "CommentedImage.h"
#import "FixedImageCell.h"
#import "AircraftViewController.h"

@interface MyAircraft ()
@property (atomic, strong) NSMutableDictionary * dictImagesForAircraft;
@property (atomic, strong) NSMutableArray * rgFavoriteAircraft;
@property (atomic, strong) NSMutableArray * rgArchivedAircraft;
@end

enum aircraftSections {sectFavorites = 0, sectArchived};

@implementation MyAircraft
@synthesize dictImagesForAircraft, rgArchivedAircraft, rgFavoriteAircraft;

- (void) asyncLoadThumbnails
{
    @autoreleasepool {
        NSMutableDictionary * dictImages = self.dictImagesForAircraft;
        NSArray * rgAc = [Aircraft sharedAircraft].rgAircraftForUser;
        for (MFBWebServiceSvc_Aircraft * ac in rgAc)
        {
            CommentedImage * ci = [CommentedImage new];
            NSUInteger cImages = ac.AircraftImages.MFBImageInfo.count;
            if (cImages > 0)
            {
                // by default...
                ci.imgInfo = (MFBWebServiceSvc_MFBImageInfo *) (ac.AircraftImages.MFBImageInfo)[0];
                if (cImages > 1 && ac.DefaultImage != nil && ac.DefaultImage.length != 0)
                {
                    for (MFBWebServiceSvc_MFBImageInfo * mfbii in ac.AircraftImages.MFBImageInfo)
                    {
                        if ([mfbii.ThumbnailFile compare:ac.DefaultImage] == NSOrderedSame)
                        {
                            ci.imgInfo = mfbii;
                            break;
                        }
                    }
                }
            }
            else
                ci.imgInfo = nil;
            
            [ci GetThumbnail];
            
            if (dictImages == self.dictImagesForAircraft)
                dictImages[ac.AircraftID] = ci;
            else
                break;
            
            if (ci.imgInfo != nil)
                [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        
    }
}

- (void) initAircraftLists
{
    self.dictImagesForAircraft = [NSMutableDictionary new];
    self.rgFavoriteAircraft = [NSMutableArray new];
    self.rgArchivedAircraft = [NSMutableArray new];
    
    for (MFBWebServiceSvc_Aircraft * ac in [Aircraft sharedAircraft].rgAircraftForUser)
    {
        if (ac.HideFromSelection.boolValue)
            [self.rgArchivedAircraft addObject:ac];
        else
            [self.rgFavoriteAircraft addObject:ac];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem * btnNew = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newAircraft)];
	self.navigationItem.rightBarButtonItem = btnNew;
	
	UIBarButtonItem * btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.leftBarButtonItem = btnRefresh;
    [self initAircraftLists];
    
    [mfbApp() registerNotifyResetAll:self];
    
    self.tableView.rowHeight = 80;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
	[self.tableView reloadData];
    
    if (self.dictImagesForAircraft.count == 0)
        [NSThread detachNewThreadSelector:@selector(asyncLoadThumbnails) toTarget:self withObject:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
    [self.dictImagesForAircraft removeAllObjects];
}

#pragma mark Table view methods
- (BOOL) hasFavoriteAircraft
{
    return self.rgArchivedAircraft.count > 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.callInProgress)
        return 1;
    return self.hasFavoriteAircraft > 0 ? 2 : 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.callInProgress)
        return 1;
    if (self.hasFavoriteAircraft && section == sectArchived)
        return self.rgArchivedAircraft.count;
    else
        return self.rgFavoriteAircraft.count;
}

- (MFBWebServiceSvc_Aircraft *) aircraftAtIndexPath:(NSIndexPath *) indexPath
{
    if (self.hasFavoriteAircraft)
        return (MFBWebServiceSvc_Aircraft *) ((indexPath.section == sectFavorites) ? self.rgFavoriteAircraft[indexPath.row] : self.rgArchivedAircraft[indexPath.row]);
    else
        return (MFBWebServiceSvc_Aircraft *) ([Aircraft sharedAircraft].rgAircraftForUser)[indexPath.row];
}

- (void) refreshCompleted:(MFBSoapCall *) sc
{
	if ([[Aircraft sharedAircraft].errorString length] > 0)
        [self showErrorAlertWithMessage:[Aircraft sharedAircraft].errorString];
    
    [self endCall];
    if (isLoading)
        [self stopLoading];
    

    [self initAircraftLists];
    [NSThread detachNewThreadSelector:@selector(asyncLoadThumbnails) toTarget:self withObject:nil];
    
	[self.tableView reloadData];    
}

- (void) refresh
{   
    if (![mfbApp() isOnLine])
    {
        if (isLoading)
            [self stopLoading];
        return;
    }
    
    if (self.callInProgress)
        return;
    
    [self startCall];

    Aircraft * ac = [Aircraft sharedAircraft];
    [ac setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self refreshCompleted:sc];
    }];
	[ac loadAircraftForUser:YES]; // refresh = force a load, potentially updating cache.
}

- (void) invalidateViewController
{
    [[Aircraft sharedAircraft] clearAircraft];
    [self initAircraftLists];
    if ([NSThread isMainThread])
        [self.tableView reloadData];
    else
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark TableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AircraftCellID";
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Retrieving aircraft list...", @"status message while retrieving user aircraft")];
    
    FixedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FixedImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    MFBWebServiceSvc_Aircraft * ac = [self aircraftAtIndexPath:indexPath];
		
	cell.textLabel.text = ac.displayTailNumber;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", 
								 [ac.ModelCommonName stringByReplacingOccurrencesOfString:@"  " withString:@" "], 
								 [ac.ModelDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    cell.imageView.layer.opacity = cell.detailTextLabel.layer.opacity = cell.textLabel.layer.opacity = (ac.HideFromSelection.boolValue) ? 0.7 : 1.0;

    cell.imageView.image = [UIImage imageNamed:@"noimage"];
    CommentedImage * ci = self.dictImagesForAircraft[ac.AircraftID];

    if (ci != nil && [ci hasThumbnailCache])
        cell.imageView.image = [ci GetThumbnail];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[Aircraft sharedAircraft].rgAircraftForUser count] == 0)
        return NSLocalizedString(@"No aircraft found.  You can add one above.", @"No aircraft found");
    
    if (self.callInProgress)
        return @"";

    if (self.hasFavoriteAircraft)
    {
        switch (section) {
            case sectFavorites:
                return NSLocalizedString(@"Frequently Used Aircraft", @"Frequently Used Aircraft Header");
            case sectArchived:
                return NSLocalizedString(@"Archived Aircraft", @"Archived Aircraft Header");
            default:
                break;
        }
    }
    return @"";
}

+ (void) viewAircraft:(MFBWebServiceSvc_Aircraft *) ac onNavigationController:(UINavigationController *) nav withDelegate:(id<AircraftViewControllerDelegate>)delegate
{
	MFBAppDelegate * app = mfbApp();
    
    if (![app.userProfile isValid])
    {
        [nav showErrorAlertWithMessage:NSLocalizedString(@"You must be signed in to create an aircraft", @"Must be signed in to create an aircraft")];
        return;
    }

	AircraftViewController * acView;
    acView = [[AircraftViewController alloc] initWithNibName:@"AircraftViewController" bundle:nil];
    [acView setAircraft:ac];
    acView.delegate = delegate;

	[nav pushViewController:acView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.callInProgress || isLoading)
        return;
	[MyAircraft viewAircraft:[self aircraftAtIndexPath:indexPath] onNavigationController:self.navigationController withDelegate:self];
}

- (void) newAircraft
{
	[MyAircraft viewAircraft:[MFBWebServiceSvc_Aircraft getNewAircraft] onNavigationController:self.navigationController withDelegate:self];
}

+ (void) pushNewAircraftOnViewController:(UINavigationController *) nav
{
	[MyAircraft viewAircraft:[MFBWebServiceSvc_Aircraft getNewAircraft] onNavigationController:nav withDelegate:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [mfbApp() isOnLine];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![mfbApp() isOnLine])
            return;
        
        if (self.callInProgress)
            return;
        
        [self startCall];
        
        Aircraft * ac = [Aircraft sharedAircraft];
        [ac setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
            [self refreshCompleted:sc];
        }];
        
        [ac deleteAircraft:[self aircraftAtIndexPath:indexPath].AircraftID forUser:mfbApp().userProfile.AuthToken];
    }
}


#pragma mark - AircraftViewDelegate
- (void) aircraftListChanged
{
    [self initAircraftLists];
}
@end

