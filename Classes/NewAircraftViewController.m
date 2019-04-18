/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2013-2019 MyFlightbook, LLC
 
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
//  NewAircraftViewController.m
//  MFBSample
//
//  Created by Eric Berman on 3/12/19.
//
//

#import "NewAircraftViewController.h"
#import "ExpandHeaderCell.h"
#import "Util.h"
#import "DecimalEdit.h"
#import "MakeModel.h"
#import "ImageComment.h"
#import "CheckboxCell.h"
#import "CountryCode.h"
#import "WPSAlertController.h"
#import "MFBTheme.h"

@interface NewAircraftViewController ()
@property (nonatomic, strong) NSString * szTailnumberLast;
@property (nonatomic, strong) NSArray<MFBWebServiceSvc_Aircraft *>* suggestedAircraft;
@property (nonatomic, strong) UIPickerView * picker;
@end

@implementation NewAircraftViewController

enum aircraftSections {sectMain, sectSuggestions, sectModel, sectImages, sectLast};
enum aircraftRows {rowMainFirst, rowInstanceType = rowMainFirst, rowIsAnonymous, rowTailnum, rowMainLast,
    rowModel,
    rowSuggestion, rowImageHeader};

@synthesize picker, szTailnumberLast, suggestedAircraft;
#pragma mark - ViewController
- (instancetype) initWithAircraft:(MFBWebServiceSvc_Aircraft *) aircraft {
    self = [super initWithAircraft:aircraft];
    if (self != nil) {
        self.imagesSection = sectImages;
        if (aircraft == nil)
        self.ac = [MFBWebServiceSvc_Aircraft getNewAircraft];
        assert(self.ac.isNew);
        self.ac = aircraft;
        if (self.rgImages == nil)
            self.rgImages = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([CommentedImage initCommentedImagesFromMFBII:self.ac.AircraftImages.MFBImageInfo toArray:self.rgImages]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    if (self.rgImages.count > 0 && ![self isExpanded:sectImages])
                        [self expandSection:sectImages];
                });
            }
        });
        
        // Auto-expand image section if there are images
        [self.expandedSections removeAllIndexes];
        if ([self.rgImages count] > 0)
            [self expandSection:sectImages];
        
        self.picker = [[UIPickerView alloc] init];
        self.picker.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.ac == nil)
        self.ac = [MFBWebServiceSvc_Aircraft getNewAircraft];
    
    if (self.rgImages == nil)
        self.rgImages = [[NSMutableArray alloc] init];
    
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    self.navigationItem.title = NSLocalizedString(@"Add Aircraft", @"Submit - Add");
    self.szTailnumberLast = @"";
    
    // Set up for camera/images
    
    UIBarButtonItem * bbSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * bbGallery = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImages:)];
    UIBarButtonItem * bbCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    bbGallery.enabled = self.canUsePhotoLibrary;
    bbCamera.enabled = self.canUseCamera;
    
    bbGallery.style = bbCamera.style = UIBarButtonItemStylePlain;
    self.toolbarItems = @[bbSpacer, bbGallery, bbCamera];
    
    // Submit button
    UIBarButtonItem * bbSubmit = [[UIBarButtonItem alloc]
                                  initWithTitle:NSLocalizedString(@"Add", @"Generic Add")
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(addAircraft)];
    
    self.navigationItem.rightBarButtonItem = bbSubmit;
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.toolbarHidden = NO;
    [self.navigationController setToolbarHidden:NO];
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    self.progress = nil;
    [self.navigationController setToolbarHidden:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    for (CommentedImage * ci in self.rgImages)
        [ci flushCachedImage];
    self.progress = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([Aircraft sharedAircraft].rgMakeModels == nil)
        [self updateMakes];
}

#pragma mark - Suggested Aircraft
- (void) removeSuggestedAircraft {
    if (self.suggestedAircraft.count == 0)
        return;
    NSMutableArray * rgRows = [NSMutableArray new];
    for (NSInteger i = 0; i < self.suggestedAircraft.count; i++)
        [rgRows addObject:[NSIndexPath indexPathForRow:i inSection:sectSuggestions]];
    self.suggestedAircraft = [NSArray new];
    [self.tableView deleteRowsAtIndexPaths:rgRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) addSuggestedAircraft:(NSArray<MFBWebServiceSvc_Aircraft *> *) array {
    if (array == nil || array.count == 0)
        return;
    NSMutableArray * rgRows = [NSMutableArray new];
    for (NSInteger i = 0; i < array.count; i++)
        [rgRows addObject:[NSIndexPath indexPathForRow:i inSection:sectSuggestions]];
    self.suggestedAircraft = array;
    [self.tableView insertRowsAtIndexPaths:rgRows withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectLast;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section)
    {
        case sectMain: {
            NSInteger result = (rowMainLast - rowMainFirst) - (self.ac.isSim ? 2 : (self.ac.isAnonymous ? 1 : 0));
            return result;}
        case sectModel:
            return 1;
        case sectImages:
            return ([self.rgImages count] == 0) ? 0 : 1 + (([self isExpanded:section]) ? [self.rgImages count] : 0);
        case sectSuggestions:
            return self.suggestedAircraft.count;
        default:
            return 0;
    }
}

- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) ip {
    switch (ip.section) {
        case sectMain:
            return ip.row;
        case sectImages:
            return rowImageHeader + ip.row;
        case sectModel:
            return rowModel;
        case sectSuggestions:
            return rowSuggestion;
        default:
            return 0;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == sectImages && indexPath.row > 0) ? 100 : UITableViewAutomaticDimension;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    Aircraft * aircraft = [Aircraft sharedAircraft];
    
    // Handle the dynamic sections...
    if (indexPath.section == sectSuggestions) {
        static NSString * CellIdentifier = @"cellSuggestion";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        MFBWebServiceSvc_Aircraft * acSuggestion = self.suggestedAircraft[indexPath.row];
        cell.textLabel.text = acSuggestion.displayTailNumber;
        NSString * modelDisplay = [Aircraft.sharedAircraft descriptionOfModelId:acSuggestion.ModelID.intValue];
        cell.detailTextLabel.text = modelDisplay;
        return cell;
    } else if (indexPath.section == sectImages) {
        if (indexPath.row > 0) {
            static NSString *CellIdentifier = @"cellImage";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            NSInteger imageIndex = (row - rowImageHeader) - 1;
            if (imageIndex >= 0 && imageIndex < [self.rgImages count])
            {
                CommentedImage * ci = (CommentedImage *) (self.rgImages)[imageIndex];
                cell.indentationLevel = 1;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.text = ci.imgInfo.Comment;
                if (ci.hasThumbnailCache)
                    cell.imageView.image = [ci GetThumbnail];
                else
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [ci GetThumbnail];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    });
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.indentationWidth = 10.0;
            }
            return cell;
        }
    }
    
    // else it msut be a specific known row.
    switch (row) {
        case rowIsAnonymous: {
            CheckboxCell * cc = [CheckboxCell getButtonCell:tableView];
            [cc.btn setTitle:NSLocalizedString(@"Anonymous Aircraft", @"Indicates an anonymous aircraft") forState:0];
            [cc.btn setIsCheckbox];
            [cc.btn addTarget:self action:@selector(toggleAnonymous:) forControlEvents:UIControlEventTouchUpInside];
            [cc makeTransparent];
            cc.btn.selected = self.ac.isAnonymous;
            return cc;
        }
        case rowModel: {
            static NSString *CellIdentifier = @"cellModel";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.detailTextLabel.text = (self.ac.ModelID.intValue > 0) ? @"" : NSLocalizedString(@"(Tap to select model)", @"Model Hint");
            cell.textLabel.text = (self.ac.ModelID.intValue >= 0) ? [aircraft descriptionOfModelId:[self.ac.ModelID intValue]] : @"";
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case rowInstanceType:
        case rowTailnum: {
            EditCell * ec = [EditCell getEditCellNoLabel:tableView withAccessory:self.vwAccessory];
            if (row == rowTailnum) {
                ec.txt.text = self.ac.TailNumber;
                ec.txt.inputView = nil;
            }
            else {
                ec.txt.text = (NSString *) (aircraft.rgAircraftInstanceTypes)[[self.ac.InstanceTypeID intValue] - 1];
                ec.txt.inputView = self.picker;
            }
            
            ec.txt.attributedPlaceholder = [MFBTheme.currentTheme formatAsPlaceholder:(row == rowTailnum) ? NSLocalizedString(@"(Tail)", @"Tail Hint") : NSLocalizedString(@"(Model)", @"Model Hint")];
            ec.txt.delegate = self;
            ec.txt.clearButtonMode = UITextFieldViewModeNever;
            ec.txt.adjustsFontSizeToFitWidth = YES;
            return ec;
        }
        case rowImageHeader: {
            NSString * szHeader = NSLocalizedString(@"Images", @"Title for image management screen (where you can add/delete/tap-to-edit images)");
            ExpandHeaderCell * ec = [ExpandHeaderCell getHeaderCell:tableView withTitle:szHeader forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            return ec;
        }
        default: {
            @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in AircraftViewController with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
        }
    }
}

#pragma mark - Table view delegate
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == sectImages && indexPath.row > 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"Delete", @"Title for 'delete' button in image list");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CommentedImage * ci = (CommentedImage *) (self.rgImages)[indexPath.row - 1];
        [ci deleteImage:(mfbApp()).userProfile.AuthToken];
        
        // then remove it from the array
        [self.rgImages removeObjectAtIndex:indexPath.row - 1];
        NSMutableArray * ar = [[NSMutableArray alloc] initWithObjects:indexPath, nil];
        // If deleting the last image we will delete the whole section, so delete the header row too
        if ([self.rgImages count] == 0)
            [ar addObject:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
        [tableView deleteRowsAtIndexPaths:ar withRowAnimation:UITableViewRowAnimationFade];
        [self.delegate aircraftListChanged];
    }
}

- (void) toggleAnonymous:(UIButton *) sender {
    NSIndexPath * ip = [NSIndexPath indexPathForRow:rowTailnum - rowMainFirst inSection:sectMain];
    NSArray * rgIP = @[ip];
    if (self.ac.isAnonymous) {
        self.ac.TailNumber = self.szTailnumberLast;
        [self.tableView insertRowsAtIndexPaths:rgIP withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        self.szTailnumberLast = self.ac.TailNumber;
        self.ac.TailNumber = [NSString stringWithFormat:@"#%05d", [self.ac.ModelID intValue]];
        [self.tableView deleteRowsAtIndexPaths:rgIP withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row) {
        case rowModel: {
            [self.tableView endEditing:YES];
            MakeModel * mmView = [[MakeModel alloc] initWithNibName:@"MakeModel" bundle:nil];
            mmView.ac = self.ac;
            
            [self.navigationController pushViewController:mmView animated:YES];
        }
            break;
        case rowIsAnonymous:
            break;
        case rowTailnum:
            // Do nothing if this is a sim or anonymous - should never happen
            assert(!self.ac.isSim && !self.ac.isAnonymous);
            break;
        case rowSuggestion: {
            MFBWebServiceSvc_Aircraft * selection = self.suggestedAircraft[indexPath.row];
            self.ac.TailNumber = selection.TailNumber;
            self.ac.ModelID = selection.ModelID;
            [self removeSuggestedAircraft];
            [self.tableView reloadData];
            break;
        }
        case rowImageHeader:
            [self.tableView endEditing:YES];
            [self toggleSection:indexPath.section];
            break;
        default:
            [self.tableView endEditing:YES];
            if (row > rowImageHeader) {
                ImageComment * ic = [[ImageComment alloc] initWithNibName:@"ImageComment" bundle:nil];
                ic.ci = (CommentedImage *) (self.rgImages)[indexPath.row - 1];
                [self.navigationController pushViewController:ic animated:YES];
            }
            break;
    }
}

#pragma mark - Data Source - picker
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return Aircraft.sharedAircraft.rgAircraftInstanceTypes.count;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return (NSString *) ([Aircraft sharedAircraft].rgAircraftInstanceTypes)[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    
    BOOL fIsSim = [self.ac isSim];
    
    self.ac.InstanceTypeID = @(row + 1);
    ec.txt.text = (NSString *) ([Aircraft sharedAircraft].rgAircraftInstanceTypes)[[self.ac.InstanceTypeID intValue] - 1];
    
    // if it changed to/from being a sim, reload the table.
    if ([self.ac isSim] ^ fIsSim)
        [self.tableView reloadData];
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [self.tableView endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    NSString * szNew = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (row == rowTailnum) {
        NSString * szOriginal = textField.text;
        NSCharacterSet * illegalChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        
        if ([szNew rangeOfCharacterFromSet:illegalChars].location != NSNotFound)
            return NO;
        
        self.ac.TailNumber = [szNew uppercaseString];
        
        if ([self.ac.TailNumber stringByReplacingOccurrencesOfString:@"-" withString:@""].length > 2 && [szOriginal compare:self.ac.TailNumber options:NSCaseInsensitiveSearch] != NSOrderedSame) {
            [self removeSuggestedAircraft];
            MFBWebServiceSvc_AircraftMatchingPrefix * autocomplete = [MFBWebServiceSvc_AircraftMatchingPrefix new];
            autocomplete.szPrefix = self.ac.TailNumber;
            autocomplete.szAuthToken = mfbApp().userProfile.AuthToken;
            
            MFBSoapCall * sc = [[MFBSoapCall alloc] init];
            sc.logCallData = NO;
            sc.delegate = self;
            
            [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
                [b AircraftMatchingPrefixAsyncUsingParameters:autocomplete delegate:sc];
            }];
        }
    }
    return YES;
}

#pragma mark - MFBSoapCallDelegate
- (void) BodyReturned:(id) body {
    if ([body isKindOfClass:[MFBWebServiceSvc_AircraftMatchingPrefixResponse class]]) {
        MFBWebServiceSvc_AircraftMatchingPrefixResponse * response = (MFBWebServiceSvc_AircraftMatchingPrefixResponse *) body;
        NSArray<MFBWebServiceSvc_Aircraft *> * rg = response.AircraftMatchingPrefixResult.Aircraft;
        
        if (self.suggestedAircraft.count > 0)
            [self removeSuggestedAircraft];
        [self addSuggestedAircraft:rg];
    }
}

#pragma mark - AccessoryViewDelegates
- (BOOL) isNavigableRow:(NSIndexPath *)ip {
    switch ([self cellIDFromIndexPath:ip]) {
        case rowTailnum:
        case rowInstanceType:
            return [self.ac isNew];
        default:
            return NO;
    }
}

#pragma mark Update Makes and models
- (void) updateMakesCompleted:(MFBSoapCall *) sc fromCaller:(Aircraft *) a {
    if (![self.ac isNew])
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];  // in case the static description needs to be updated.
}

- (void) updateMakes {
    Aircraft * a = [Aircraft sharedAircraft];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self updateMakesCompleted:sc fromCaller:(Aircraft *) ao];
    }];
    [a loadMakeModels];
}

#pragma mark Commit aircraft

- (void) imagesComplete:(NSArray *) ar {
    MFBSoapCall * sc = (MFBSoapCall *)ar[0];
    Aircraft * a = (Aircraft *) ar[1];
    
    // Invalidate totals, since this could affect currency (e.g., vor checks)
    [mfbApp() invalidateCachedTotals];
    
    Aircraft * aircraft = [Aircraft sharedAircraft];
    // And reload user aircraft to pick up the changes, if necessary
    if (a.rgAircraftForUser != nil && [a.rgAircraftForUser count] > 0) {
        aircraft.rgAircraftForUser = a.rgAircraftForUser;
        [aircraft cacheAircraft:a.rgAircraftForUser forUser:mfbApp().userProfile.AuthToken];
        [self aircraftRefreshComplete:sc withCaller:a];
    }
}

- (IBAction) addAircraft {
    [self.tableView endEditing:YES]; // capture any changes.
    NSString * szError = @"";
    
    BOOL fIsRealAirplane = ![self.ac isSim];
    
    if ([self.ac.ModelID intValue] <= 0)
        szError = NSLocalizedString(@"Please select a model for the aircraft", @"Error: please select a model");
    if (fIsRealAirplane && self.ac.TailNumber.length <= 2)
        szError = NSLocalizedString(@"Please specify a valid tailnumber.", @"Error: please select a valid tailnumber");
    
    if (fIsRealAirplane) {
        if (![self.ac isAnonymous]) {
            CountryCode * cc = [CountryCode BestGuessPrefixForTail:self.ac.TailNumber];
            if (cc != nil && self.ac.TailNumber.length <= cc.Prefix.length)
                szError = NSLocalizedString(@"Tailnumber has nothing beyond the country code.", @"Error: Tailnumber has nothing beyond the country code");
        }
    }
    else
        self.ac.TailNumber = Aircraft.PrefixSIM;
    
    
    if ([szError length] > 0) {
        [self showErrorAlertWithMessage:szError];
        return;
    }
    
    self.progress = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Uploading aircraft data...", @"Progress: uploading aircraft data") onViewController:self];
    
    [self commitAircraft];
}
@end
