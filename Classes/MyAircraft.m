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
//  MyAircraft.m
//  MFBSample
//
//  Created by Eric Berman on 2/21/10.
//

#import "MyAircraft.h"
#import "CommentedImage.h"
#import "FixedImageCell.h"
#import "AircraftViewController.h"
#import "NewAircraftViewController.h"

@interface MyAircraft ()
@property (atomic, strong) NSMutableDictionary * dictImagesForAircraft;
@property (atomic, strong) NSMutableArray * rgFavoriteAircraft;
@property (atomic, strong) NSMutableArray * rgArchivedAircraft;
@end

enum aircraftSections {sectFavorites = 0, sectArchived};

@implementation MyAircraft
@synthesize dictImagesForAircraft, rgArchivedAircraft, rgFavoriteAircraft;

BOOL fNeedsRefresh = NO;

- (void) asyncLoadThumbnails
{
    @autoreleasepool {
        NSMutableDictionary * dictImages = self.dictImagesForAircraft;
        Aircraft * a = [Aircraft sharedAircraft];
        NSArray * rgAc = a.rgAircraftForUser;
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
            else {
                ci.imgInfo = nil;
                continue;
            }
            
            [ci GetThumbnail];
            
            if (dictImages == self.dictImagesForAircraft)
                dictImages[ac.AircraftID] = ci;
            else
                break;
            
            if (ci.imgInfo != nil)
                [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
        }
        
        // Cache the images
        [a cacheAircraft:rgAc forUser:MFBProfile.sharedProfile.AuthToken];
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
    
    [MFBAppDelegate.threadSafeAppDelegate registerNotifyResetAll:self];
    
    self.tableView.rowHeight = 80;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = YES;
    [super viewWillAppear:animated];
	[self.tableView reloadData];
    
    if (self.dictImagesForAircraft.count == 0)
        [NSThread detachNewThreadSelector:@selector(asyncLoadThumbnails) toTarget:self withObject:nil];
    
    if (fNeedsRefresh && MFBProfile.sharedProfile.AuthToken.length > 0)
        [self refresh];
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
    if (![MFBAppDelegate.threadSafeAppDelegate isOnLine])
    {
        if (isLoading)
            [self stopLoading];
        return;
    }
    
    fNeedsRefresh = NO;
    if (self.callInProgress)
        return;
    
    [self startCall];

    Aircraft * ac = [Aircraft sharedAircraft];
    [ac setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self refreshCompleted:sc];
    }];
	[ac loadAircraftForUser:YES]; // refresh = force a load, potentially updating cache.
}

- (void) reloadTableview {
    [self.tableView reloadData];
}

- (void) invalidateViewController {
    [[Aircraft sharedAircraft] clearAircraft];
    [self initAircraftLists];
    fNeedsRefresh = YES;
    if ([NSThread isMainThread])
        [self.tableView reloadData];
    else
        [self performSelectorOnMainThread:@selector(reloadTableview) withObject:nil waitUntilDone:NO];
}

#pragma mark TableView Delegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AircraftCellID";
    
    if (self.callInProgress)
        return [self waitCellWithText:NSLocalizedString(@"Retrieving aircraft list...", @"status message while retrieving user aircraft")];
    
    FixedImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FixedImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
    
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    MFBWebServiceSvc_Aircraft * ac = [self aircraftAtIndexPath:indexPath];
    CGFloat textSizeLabel = cell.textLabel.font.pointSize;
    CGFloat textSizeDetail = textSizeLabel * 0.8;
    
    UIFont * baseFont = [UIFont systemFontOfSize:textSizeDetail];
    UIFont * boldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:textSizeLabel];
    UIFont * italicFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:textSizeDetail];
    UIColor * colorMain;
    UIColor * colorNotes;
    if (@available(iOS 13.0, *)) {
        colorMain = UIColor.labelColor;
        colorNotes = UIColor.secondaryLabelColor;
    } else {
        colorMain = UIColor.darkTextColor;
        colorNotes = UIColor.darkGrayColor;
    }

    
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableAttributedString * szTail = [[NSMutableAttributedString alloc] initWithString:ac.displayTailNumber attributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName : colorMain}];
    [szTail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ %@", ac.modelFullDescription, ac.isSim ? [NSString stringWithFormat:@"%@ ", [Aircraft aircraftInstanceTypeDisplay:ac.InstanceType]] : @""]
                                                                               attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : colorMain}]];
    [szTail appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", ac.PrivateNotes == nil ? @"" : ac.PrivateNotes, ac.PublicNotes == nil ? @"" : ac.PublicNotes] attributes:@{NSFontAttributeName : baseFont, NSForegroundColorAttributeName : colorNotes}]];
    cell.textLabel.attributedText = szTail;
    
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
    if (!MFBProfile.sharedProfile.isValid)
    {
        [nav showErrorAlertWithMessage:NSLocalizedString(@"You must be signed in to create an aircraft", @"Must be signed in to create an aircraft")];
        return;
    }

    AircraftViewControllerBase * acView = [(ac.isNew ? [NewAircraftViewController alloc] : [AircraftViewController alloc]) initWithAircraft:ac];
    acView.delegate = delegate;
	[nav pushViewController:acView animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.callInProgress || isLoading)
        return;
	[MyAircraft viewAircraft:[self aircraftAtIndexPath:indexPath] onNavigationController:self.navigationController withDelegate:self];
}

- (void) newAircraft {
    if (MFBAppDelegate.threadSafeAppDelegate.isOnLine)
        [MyAircraft viewAircraft:[MFBWebServiceSvc_Aircraft getNewAircraft] onNavigationController:self.navigationController withDelegate:self];
}

+ (void) pushNewAircraftOnViewController:(UINavigationController *) nav
{
	[MyAircraft viewAircraft:[MFBWebServiceSvc_Aircraft getNewAircraft] onNavigationController:nav withDelegate:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MFBAppDelegate.threadSafeAppDelegate isOnLine];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![MFBAppDelegate.threadSafeAppDelegate isOnLine])
            return;
        
        if (self.callInProgress)
            return;
        
        [self startCall];
        
        Aircraft * ac = [Aircraft sharedAircraft];
        [ac setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
            [self refreshCompleted:sc];
        }];
        
        [ac deleteAircraft:[self aircraftAtIndexPath:indexPath].AircraftID forUser:MFBProfile.sharedProfile.AuthToken];
    }
}


#pragma mark - AircraftViewDelegate
- (void) aircraftListChanged
{
    [self initAircraftLists];
}
@end

