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
//  AircraftViewController.m
//  MFBSample
//
//  Created by Eric Berman on 3/12/19.
//
//

#import "AircraftViewController.h"
#import "RecentFlights.h"
#import "EditCell.h"
#import "ButtonCell.h"
#import "ExpandHeaderCell.h"
#import "DecimalEdit.h"
#import "Util.h"
#import "MakeModel.h"
#import "ImageComment.h"
#import "TextCell.h"
#import "CheckboxCell.h"
#import "CountryCode.h"
#import "HostedWebViewViewController.h"
#import "WPSAlertController.h"

@interface AircraftViewController ()
- (void) findFlights:(id)sender;

@property (nonatomic, strong) UIDatePicker * datePicker;

@end

@implementation AircraftViewController

enum aircraftSections {sectInfo, sectImages, sectFavorite, sectPrefs, sectNotes, sectMaintenance, sectLast};
enum aircraftRows {rowInfoStart, rowStaticDesc = rowInfoStart, rowInfoLast,
    rowFavorite,
    rowPrefsHeader, rowPrefsFirst = rowPrefsHeader, rowRoleNone, rowRolePIC, rowRoleSIC, rowRoleCFI, rowPrefsLast=rowRoleCFI,
    rowNotesHeader, rowNotesFirst = rowNotesHeader, rowNotesPublic, rowNotesPrivate, rowNotesLast = rowNotesPrivate,
    rowMaintHeader,
    rowMaintFirst = rowMaintHeader, rowVOR, rowXPnder, rowPitot, rowAltimeter, rowELT, rowAnnual, row100hr, rowOil, rowEngine, rowRegistration, rowMaintLast = rowRegistration,
    rowImageHeader};

@synthesize datePicker;
#pragma mark - ViewController
- (instancetype) initWithAircraft:(MFBWebServiceSvc_Aircraft *) aircraft {
    self = [super initWithAircraft:aircraft];
    if (self != nil) {
        self.imagesSection = sectImages;
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        self.datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        assert(aircraft != nil);
        assert(!aircraft.isNew);
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
        if ([self.ac hasMaintenance])
            [self expandSection:sectMaintenance];
        if (self.ac.RoleForPilot != MFBWebServiceSvc_PilotRole_None)
            [self expandSection:sectPrefs];
        if (self.ac.PrivateNotes.length > 0 || self.ac.PublicNotes.length > 0)
            [self expandSection:sectNotes];
        else
            [self collapseSection:sectNotes];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.rgImages == nil)
        self.rgImages = [[NSMutableArray alloc] init];

    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    self.navigationItem.title = self.ac.TailNumber;
    
    // Set up for camera/images
    
    UIBarButtonItem * bbSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(findFlights:)];
    UIBarButtonItem * bbSchedule = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSchedule:)];
    UIBarButtonItem * bbSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem * bbGallery = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImages:)];
	UIBarButtonItem * bbCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    bbGallery.enabled = self.canUsePhotoLibrary;
    bbCamera.enabled = self.canUseCamera;

    bbGallery.style = bbCamera.style = bbSearch.style = UIBarButtonItemStylePlain;
    self.toolbarItems = @[bbSearch, bbSchedule, bbSpacer, bbGallery, bbCamera];
    
    // Submit button
    UIBarButtonItem * bbSubmit = [[UIBarButtonItem alloc]
                                  initWithTitle:NSLocalizedString(@"Update", @"Update")
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(UpdateAircraft)];
    
    self.navigationItem.rightBarButtonItem = bbSubmit;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = NO;
    self.navigationController.toolbar.translucent = NO;
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.progress = nil;
    [self.navigationController setToolbarHidden:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	for (CommentedImage * ci in self.rgImages)
		[ci flushCachedImage];
    self.progress = nil;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectLast;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case sectInfo:
            return rowInfoLast - rowInfoStart;
        case sectFavorite:
            return 1;
        case sectImages:
            return ([self.rgImages count] == 0) ? 0 : 1 + (([self isExpanded:section]) ? [self.rgImages count] : 0);
        case sectPrefs:
            // hide this section if we are new
            return 1 + (([self isExpanded:section]) ? rowPrefsLast - rowPrefsHeader : 0);
            break;
        case sectNotes:
            return ([self isExpanded:section] ? rowNotesLast - rowNotesFirst + 1 : 1);
        case sectMaintenance:
            // Hide this section if we are new, a sim, or anonymous
            return (self.ac.isSim || self.ac.isAnonymous) ? 0 : 1 + (([self isExpanded:section]) ? rowMaintLast - rowMaintFirst : 0);
        default:
            return 0;
    }
}

- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) ip
{
    NSInteger row = ip.row;
    
    switch (ip.section)
    {
        case sectInfo:
            return rowInfoStart + ip.row;
        case sectImages:
            return rowImageHeader + row;
        case sectFavorite:
            return rowFavorite;
        case sectPrefs:
            return rowPrefsHeader + row;
        case sectNotes:
            return rowNotesFirst + row;
        case sectMaintenance:
            return rowMaintHeader + row;
        default:
            return 0;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == sectImages && indexPath.row > 0)
        return 100;
    if (indexPath.section == sectNotes && indexPath.row > 0)
        return 120;
    
    return UITableViewAutomaticDimension;
}

- (NSString *) utcShortDate:(NSDate *) dt {
    static NSDateFormatter * df;
    
    if (df == nil) {
        df = [NSDateFormatter new];
        df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        df.dateStyle = NSDateFormatterShortStyle;
    }
    return [df stringFromDate:dt];
}

- (void) setDate:(NSDate *) dt andExpiration:(NSDate *) dtExpiration forCell:(EditCell *) ec
{
    ec.txt.text = [NSDate isUnknownDate:dt] ? @"" : [self utcShortDate:dt];
    if ([NSDate isUnknownDate:dtExpiration])
        ec.lblDetail.text = @"";
    else
    {
        BOOL fIsExpired = [dtExpiration compare:[NSDate date]] == NSOrderedAscending;
        ec.lblDetail.text = [NSString stringWithFormat:(fIsExpired ? NSLocalizedString(@"CurrencyExpired", @"Currency Expired format string") : NSLocalizedString(@"CurrencyValid", @"Currency Valid format string")), [self utcShortDate:dtExpiration]];
        UIColor * detailColor;
        if (@available(iOS 13.0, *)) {
            detailColor = UIColor.secondaryLabelColor;
        } else {
            detailColor = UIColor.darkGrayColor;
        }
        ec.lblDetail.textColor = (fIsExpired) ? [UIColor redColor] : detailColor;
    }
}

- (void) updateNext100:(NSNumber *) last100 forCell:(EditCell *) ec
{
    if (last100 == nil || [last100 doubleValue] == 0)
        ec.lblDetail.text =  @"";
    else
        ec.lblDetail.text = [NSString stringWithFormat:NSLocalizedString(@"CurrencyValid", @"Currency Valid format string"), [NSString stringWithFormat:@"%.1f", [last100 doubleValue] + 100.0]];
}

- (EditCell *) dateCell:(NSDate *) dt withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView expirationDate:(NSDate *) dtExpiration
{
    EditCell * ec = [EditCell getEditCellDetail:tableView withAccessory:self.vwAccessory];
    ec.txt.inputView = self.datePicker;
    ec.txt.placeholder = NSLocalizedString(@"(Tap for Today)", @"Prompt for date that is currently un-set (tapping sets it to TODAY)");
    ec.txt.delegate = self;
    ec.lbl.text = szPrompt;
    ec.txt.clearButtonMode = UITextFieldViewModeNever;
    [self setDate:dt andExpiration:dtExpiration forCell:ec];
    return ec;
}

- (EditCell *) decimalCell:(NSNumber *) num withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView
{
    EditCell * ec = [EditCell getEditCellDetail:tableView withAccessory:self.vwAccessory];
    ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
    [ec.txt setValue:num withDefault:@0.0];
    ec.txt.NumberType = ntDecimal;
    ec.txt.delegate = self;
    ec.lbl.text = szPrompt;
    ec.txt.clearButtonMode = UITextFieldViewModeWhileEditing;
    return ec;
}

- (EditCell *) textCell:(NSString *) szText WithPrompt:(NSString *) szPrompt andPlacholder:(NSString *) szPlaceholder forTableView:(UITableView *) tableView
{
    EditCell * ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
    ec.lbl.text = szPrompt;
    ec.txt.text = szText;
    ec.txt.placeholder = szPlaceholder;
    ec.txt.delegate = self;
    ec.txt.clearButtonMode = UITextFieldViewModeWhileEditing;
    return ec;
}

- (EditCell *) multilineTextCell:(NSString *) szText WithPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView
{
    EditCell * ec = [EditCell getEditCellMultiLine:tableView withAccessory:self.vwAccessory];
    ec.lbl.text = szPrompt;
    ec.txtML.text = szText;
    ec.txtML.delegate = self;
    return ec;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
	Aircraft * aircraft = [Aircraft sharedAircraft];

    switch (row)
    {
        case rowStaticDesc:
        {
            static NSString *CellIdentifier = @"CellStatic";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            NSString * szInstanceTypeDesc = @"";
            if ([self.ac isSim])
                szInstanceTypeDesc = [NSString stringWithFormat:@" (%@)", (aircraft.rgAircraftInstanceTypes)[[self.ac.InstanceTypeID intValue] - 1]];
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@", self.ac.TailNumber, szInstanceTypeDesc];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.detailTextLabel.text = self.ac.modelFullDescription;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case rowMaintHeader:
        case rowImageHeader:
        case rowPrefsHeader:
        case rowNotesHeader:
        {
            NSString * szHeader;
            switch (row)
            {
                case rowMaintHeader:
                    szHeader = NSLocalizedString(@"Maintenance and Inspections", @"Maintenance header");
                    break;
                case rowImageHeader:
                    szHeader = NSLocalizedString(@"Images", @"Title for image management screen (where you can add/delete/tap-to-edit images)");
                    break;
                case rowPrefsHeader:
                    szHeader = NSLocalizedString(@"AircraftPrefsHeader", @"Aircraft Preferences Header");
                    break;
                case rowNotesHeader:
                    szHeader = NSLocalizedString(@"NotesHeader", @"Notes Header");
                    break;
                default:
                    szHeader = @"";
            }
            ExpandHeaderCell * ec = [ExpandHeaderCell getHeaderCell:tableView withTitle:szHeader forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            return ec;
        }
        case rowNotesPrivate:
            return [self multilineTextCell:self.ac.PrivateNotes WithPrompt:NSLocalizedString(@"PrivateNotes", @"Private Notes") forTableView:tableView];
        case rowNotesPublic:
            return [self multilineTextCell:self.ac.PublicNotes WithPrompt:NSLocalizedString(@"PublicNotes", @"Public Notes") forTableView:tableView];
        case rowVOR:
            return [self dateCell:self.ac.LastVOR withPrompt:NSLocalizedString(@"VOR", @"VOR Check") forTableView:tableView expirationDate:[self.ac nextVOR]];
        case rowXPnder:
            return [self dateCell:self.ac.LastTransponder withPrompt:NSLocalizedString(@"Transponder", @"Transponder") forTableView:tableView expirationDate:[self.ac nextTransponder]];
        case rowPitot:
            return [self dateCell:self.ac.LastStatic withPrompt:NSLocalizedString(@"Pitot/Static", @"Pitot/Static") forTableView:tableView expirationDate:[self.ac nextPitotStatic]];
        case rowAltimeter:
            return [self dateCell:self.ac.LastAltimeter withPrompt:NSLocalizedString(@"Altimeter", @"Altimeter") forTableView:tableView expirationDate:[self.ac nextAltimeter]];
        case rowELT:
            return [self dateCell:self.ac.LastELT withPrompt:NSLocalizedString(@"ELT", @"ELT") forTableView:tableView expirationDate:[self.ac nextELT]];
        case rowAnnual:
            return [self dateCell:self.ac.LastAnnual withPrompt:NSLocalizedString(@"Annual", @"Annual") forTableView:tableView expirationDate:[self.ac nextAnnual]];
        case rowRegistration:
        {
            // determine whether to show the expiration date
            NSDate * dtExpiration = (![NSDate isUnknownDate:self.ac.RegistrationDue] && [[NSDate date] compare:self.ac.RegistrationDue] == NSOrderedDescending) ? self.ac.RegistrationDue : nil;
            return [self dateCell:self.ac.RegistrationDue withPrompt:NSLocalizedString(@"RegistrationRenewal", @"Date that renewal is required") forTableView:tableView expirationDate:dtExpiration];
        }
        case row100hr:
            return [self decimalCell:self.ac.Last100 withPrompt:NSLocalizedString(@"100 hour", @"100 hour") forTableView:tableView];
        case rowOil:
            return [self decimalCell:self.ac.LastOilChange withPrompt:NSLocalizedString(@"Oil Change", @"Oil Change") forTableView:tableView];
        case rowEngine:
            return [self decimalCell:self.ac.LastNewEngine withPrompt:NSLocalizedString(@"New Engine", @"New Engine") forTableView:tableView];
        case rowFavorite:
        {
            CheckboxCell * cc = [CheckboxCell getButtonCell:tableView];

            [cc.btn setTitle:NSLocalizedString(@"ShowAircraft", @"Aircraft - Show Aircraft") forState:0];
            [cc.btn setIsCheckbox];
            [cc.btn addTarget:self action:@selector(toggleVisible:) forControlEvents:UIControlEventTouchUpInside];
            [cc makeTransparent];
            cc.btn.selected = !self.ac.HideFromSelection.boolValue;
            return cc;
        }
        case rowRoleNone:
        {
            static NSString *CellIdentifier = @"cellRole";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"RoleNone", @"Aircraft Role = None");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = (self.ac.RoleForPilot == MFBWebServiceSvc_PilotRole_None) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case rowRolePIC:
        {
            static NSString *CellIdentifier = @"cellRole";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"RolePIC", @"Aircraft Role = PIC");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = (self.ac.RoleForPilot == MFBWebServiceSvc_PilotRole_PIC) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case rowRoleSIC:
        {
            static NSString *CellIdentifier = @"cellRole";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"RoleSIC", @"Aircraft Role = SIC");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = (self.ac.RoleForPilot == MFBWebServiceSvc_PilotRole_SIC) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case rowRoleCFI:
        {
            static NSString *CellIdentifier = @"cellRole";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.text = NSLocalizedString(@"RoleCFI", @"Aircraft Role = CFI");
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = (self.ac.RoleForPilot == MFBWebServiceSvc_PilotRole_CFI) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        default:
        {
            if (row > rowImageHeader)
            {
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
                    cell.textLabel.numberOfLines = 3;
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
            @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in AircraftViewController with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
        }
    }
}

#pragma mark - Table view delegate

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == sectImages && indexPath.row > 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete", @"Title for 'delete' button in image list");
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return (section == sectInfo) ? NSLocalizedString(@"WrongModelPrompt", @"Prompt to edit model on MyFlightbook.com") : nil;
}

- (void) tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section {
    if (section == 0) {
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        
        header.textLabel.textAlignment = NSTextAlignmentCenter;
        header.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        header.textLabel.numberOfLines = 2;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
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

- (void) toggleVisible:(UIButton *) sender
{
    [self.tableView endEditing:YES];
    self.ac.HideFromSelection.boolValue = !self.ac.HideFromSelection.boolValue;
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self cellIDFromIndexPath:indexPath];
    switch (row)
    {
        case rowVOR:
        case rowXPnder:
        case rowPitot:
        case rowAltimeter:
        case rowELT:
        case rowAnnual:
        case row100hr:
        case rowOil:
        case rowEngine:
        case rowRegistration:
            [((EditCell *) [tableView cellForRowAtIndexPath:indexPath]).txt becomeFirstResponder];
            break;
        case rowMaintHeader:
        case rowImageHeader:
        case rowPrefsHeader:
        case rowNotesHeader:
            [self.tableView endEditing:YES];
            [self toggleSection:indexPath.section];
            break;
        case rowRoleNone:
            [self.tableView endEditing:YES];
            self.ac.RoleForPilot = MFBWebServiceSvc_PilotRole_None;
            [self.tableView reloadData];
            break;
        case rowRolePIC:
            [self.tableView endEditing:YES];
            self.ac.RoleForPilot = MFBWebServiceSvc_PilotRole_PIC;
            [self.tableView reloadData];
            break;
        case rowRoleSIC:
            [self.tableView endEditing:YES];
            self.ac.RoleForPilot = MFBWebServiceSvc_PilotRole_SIC;
            [self.tableView reloadData];
            break;
        case rowRoleCFI:
            [self.tableView endEditing:YES];
            self.ac.RoleForPilot = MFBWebServiceSvc_PilotRole_CFI;
            [self.tableView reloadData];
            break;
        default:
            [self.tableView endEditing:YES];
            if (row > rowImageHeader)
            {
                ImageComment * ic = [[ImageComment alloc] initWithNibName:@"ImageComment" bundle:nil];
                ic.ci = (CommentedImage *) (self.rgImages)[indexPath.row - 1];
                [self.navigationController pushViewController:ic animated:YES];
            }
            break;
    }
}

#pragma mark - DatePicker
- (IBAction)dateChanged:(UIDatePicker *)sender
{
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    switch (row)
    {
        case rowAltimeter:
            self.ac.LastAltimeter = sender.date;
            [self setDate:self.ac.LastAltimeter andExpiration:[self.ac nextAltimeter] forCell:ec];
            break;
        case rowAnnual:
            self.ac.LastAnnual = sender.date;
            [self setDate:self.ac.LastAnnual andExpiration:[self.ac nextAnnual] forCell:ec];
            break;
        case rowELT:
            self.ac.LastELT = sender.date;
            [self setDate:self.ac.LastELT andExpiration:[self.ac nextELT] forCell:ec];
            break;
        case rowPitot:
            self.ac.LastStatic = sender.date;
            [self setDate:self.ac.LastStatic andExpiration:[self.ac nextPitotStatic] forCell:ec];
            break;
        case rowVOR:
            self.ac.LastVOR = sender.date;
            [self setDate:self.ac.LastVOR andExpiration:[self.ac nextVOR] forCell:ec];
            break;
        case rowXPnder:
            self.ac.LastTransponder = sender.date;
            [self setDate:self.ac.LastTransponder andExpiration:[self.ac nextTransponder] forCell:ec];
            break;
        case rowRegistration:
            self.ac.RegistrationDue = sender.date;
            [self setDate:self.ac.RegistrationDue andExpiration:nil forCell:ec];
            break;
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView
{
    EditCell * ec = [self owningCell:textView];
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:ec]];
    switch (row)
    {
        case rowNotesPublic:
            self.ac.PublicNotes = textView.text;
            break;
        case rowNotesPrivate:
            self.ac.PrivateNotes = textView.text;
            break;
        default:
            break;
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textView]];
    [self enableNextPrev:self.vwAccessory];
    return YES;
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    EditCell * ec = [self owningCell:textField];
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:ec]];
    switch (row)
    {
        case row100hr:
            self.ac.Last100 = textField.value;
            [self updateNext100:textField.value forCell:ec];
            break;
        case rowEngine:
            self.ac.LastNewEngine = textField.value;
            break;
        case rowOil:
            self.ac.LastOilChange = textField.value;
            break;
        default:
            break;
    }
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL) dateClick:(NSDate *) dt onInit:(void (^)(NSDate*, EditCell *)) initializer
{
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    // see if this is a "Tap for today" click - if so, set to today and resign.
    if ([ec.txt.text length] == 0 || [NSDate isUnknownDate:dt])
    {
        self.datePicker.date = dt = [NSDate date];
        initializer(dt, ec);
        [self.tableView endEditing:YES];
        return NO;
    }
    
    self.datePicker.date = dt;
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    [self enableNextPrev:self.vwAccessory];
    self.vwAccessory.btnDelete.enabled = YES;
    
    // If this was a picker-tied edit cell, set up the picker correctly.
    switch (row)
    {
        case rowAltimeter:
            return [self dateClick:self.ac.LastAltimeter onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastAltimeter = d;
                [self setDate:d andExpiration:self.ac.nextAltimeter forCell:ec];
            }];
        case rowAnnual:
            return [self dateClick:self.ac.LastAnnual onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastAnnual = d;
                [self setDate:d andExpiration:self.ac.nextAnnual forCell:ec];
            }];
        case rowELT:
            return [self dateClick:self.ac.LastELT onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastELT = d;
                [self setDate:d andExpiration:self.ac.nextELT forCell:ec];
            }];
        case rowPitot:
            return [self dateClick:self.ac.LastStatic onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastStatic = d;
                [self setDate:d andExpiration:self.ac.nextPitotStatic forCell:ec];
            }];
        case rowVOR:
            return [self dateClick:self.ac.LastVOR onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastVOR = d;
                [self setDate:d andExpiration:self.ac.nextVOR forCell:ec];
            }];
        case rowXPnder:
            return [self dateClick:self.ac.LastTransponder onInit:^(NSDate * d, EditCell * ec) {
                self.ac.LastTransponder = d;
                [self setDate:d andExpiration:self.ac.nextTransponder forCell:ec];
            }];
        case rowRegistration:
            return [self dateClick:self.ac.RegistrationDue onInit:^(NSDate * d, EditCell * ec) {
                self.ac.RegistrationDue = d;
                [self setDate:d andExpiration:d forCell:ec];
            }];
        case row100hr:
        case rowOil:
        case rowEngine:
            break;
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.tableView endEditing:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    switch (row)
    {
        case rowOil:
        case rowEngine:
        case row100hr:
            return [textField isValidNumber:[textField.text stringByReplacingCharactersInRange:range withString:string]];
        default:
            break;
    }
    return YES;
}

#pragma mark - AccessoryViewDelegates
- (void) deleteClicked
{
    [super deleteClicked];
    switch ([self cellIDFromIndexPath:self.ipActive])
    {
        case rowAnnual:
        case rowAltimeter:
        case rowXPnder:
        case rowELT:
        case rowVOR:
        case rowPitot:
        case rowRegistration:
            [self.tableView endEditing:YES];
            self.datePicker.date = [NSDate distantPast];
            [self dateChanged:self.datePicker];
            break;
        default:
            break;
    }
}

- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    switch ([self cellIDFromIndexPath:ip])
    {
        case rowAnnual:
            return ![NSDate isUnknownDate:self.ac.LastAnnual];
        case rowAltimeter:
            return ![NSDate isUnknownDate:self.ac.LastAltimeter];
        case rowXPnder:
            return ![NSDate isUnknownDate:self.ac.LastTransponder];
        case rowELT:
            return ![NSDate isUnknownDate:self.ac.LastELT];
        case rowVOR:
            return ![NSDate isUnknownDate:self.ac.LastVOR];
        case rowPitot:
            return ![NSDate isUnknownDate:self.ac.LastStatic];
        case rowRegistration:
            return ![NSDate isUnknownDate:self.ac.RegistrationDue];
        case rowNotesPrivate:
        case rowNotesPublic:
        case rowOil:
        case rowEngine:
        case row100hr:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - Find Flights
- (void) findFlights:(id)sender
{
    if (self.ac == nil || self.navigationController == nil)
        return;
    
    MFBWebServiceSvc_FlightQuery * fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    
    [fq.AircraftList addAircraft:self.ac];
    
    RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
    rf.fq = fq;
    [rf refresh];
    [self.navigationController pushViewController:rf animated:YES];
}

#pragma mark - View Schedule
- (void) viewSchedule:(id) sender
{
    NSString * szURL = [mfbApp().userProfile authRedirForUser:[NSString stringWithFormat:@"d=aircraftschedule&naked=1&ac=%d", self.ac.AircraftID.intValue]];
    
    HostedWebViewViewController * vwWeb = [[HostedWebViewViewController alloc] initWithURL:szURL];
    [self.navigationController pushViewController:vwWeb animated:YES];
}

#pragma mark Commit aircraft
- (void) imagesComplete:(NSArray *) ar
{
    // Invalidate totals, since this could affect currency (e.g., vor checks)
    [mfbApp() invalidateCachedTotals];
    
    Aircraft * aircraft = [Aircraft sharedAircraft];
    // And reload user aircraft to pick up the changes, if necessary
    [aircraft setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self aircraftRefreshComplete:sc withCaller:(Aircraft *) ao];
    }];
    [aircraft loadAircraftForUser:YES]; // force a refresh attempt.
}

- (IBAction) UpdateAircraft
{
    [self.tableView endEditing:YES]; // capture any changes.
    self.progress = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Updating aircraft...", @"Progress: updating aircraft") onViewController:self];
    [self commitAircraft];
}
@end
