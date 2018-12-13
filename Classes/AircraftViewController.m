/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2013-2018 MyFlightbook, LLC
 
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
//  Created by Eric Berman on 3/19/13.
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
#import "MFBTheme.h"

@interface AircraftViewController ()
- (void) findFlights:(id)sender;
- (void) updateMakes;

@property (nonatomic, strong) AccessoryBar * vwAccessory;
@property (readwrite, strong) NSMutableArray * rgImages;
@property (readwrite, strong) MFBWebServiceSvc_Aircraft * ac;
@property (nonatomic, strong) NSString * szTailnumberLast;
@property (nonatomic, strong) UIAlertController * progress;

@end

@implementation AircraftViewController

enum aircraftSections {sectInfo, sectEditModelPrompt, sectAnonymous, sectTailNumber, sectImages, sectFavorite, sectPrefs, sectNotes, sectMaintenance, sectLast};
enum aircraftRows {rowInfoStart, rowInstanceType = rowInfoStart, rowModel, rowInfoLast = rowModel,
    rowEditModelPrompt,
    rowIsAnonymous, rowTailnum,
    rowFavorite,
    rowPrefsHeader, rowPrefsFirst = rowPrefsHeader, rowRoleNone, rowRolePIC, rowRoleSIC, rowRoleCFI, rowPrefsLast=rowRoleCFI,
    rowNotesHeader, rowNotesFirst = rowNotesHeader, rowNotesPublic, rowNotesPrivate, rowNotesLast = rowNotesPrivate,
    rowStaticDesc, rowMaintHeader,
    rowMaintFirst = rowMaintHeader, rowVOR, rowXPnder, rowPitot, rowAltimeter, rowELT, rowAnnual, row100hr, rowOil, rowEngine, rowRegistration, rowMaintLast = rowRegistration,
    rowImageHeader};

@synthesize progress, datePicker, picker, rgImages, ac, vwAccessory, delegate, szTailnumberLast;
#pragma mark - ViewController
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void) setAircraft:(MFBWebServiceSvc_Aircraft *)aircraft
{
    self.ac = aircraft;
    if (self.rgImages == nil)
        self.rgImages = [[NSMutableArray alloc] init];
    [CommentedImage initCommentedImagesFromMFBII:self.ac.AircraftImages.MFBImageInfo toArray:self.rgImages];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];

	if (self.ac == nil)
        self.ac = [MFBWebServiceSvc_Aircraft getNewAircraft];
    
    if (self.rgImages == nil)
        self.rgImages = [[NSMutableArray alloc] init];

    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    self.navigationItem.title = [self.ac isNew] ? NSLocalizedString(@"Add Aircraft", @"Submit - Add") : self.ac.TailNumber;
    
    self.szTailnumberLast = @"";

    // Set up for camera/images
    
    UIBarButtonItem * bbSearch = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(findFlights:)];
    UIBarButtonItem * bbSchedule = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"schedule"] style:UIBarButtonItemStylePlain target:self action:@selector(viewSchedule:)];
    UIBarButtonItem * bbSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem * bbGallery = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImages:)];
	UIBarButtonItem * bbCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    bbGallery.enabled = self.canUsePhotoLibrary;
    bbCamera.enabled = self.canUseCamera;

    bbGallery.style = bbCamera.style = bbSearch.style = UIBarButtonItemStylePlain;
    self.toolbarItems = [self.ac isNew] ?
        @[bbSpacer, bbGallery, bbCamera] :
        @[bbSearch, bbSchedule, bbSpacer, bbGallery, bbCamera];
    
    // Submit button
    UIBarButtonItem * bbSubmit = [[UIBarButtonItem alloc]
                                               initWithTitle:[self.ac isNew] ? NSLocalizedString(@"Add", @"Generic Add") : NSLocalizedString(@"Update", @"Update")
                                               style:UIBarButtonItemStylePlain
                                               target:self
                                               action:[self.ac isNew] ? @selector(addAircraft) : @selector(UpdateAircraft)];
    
    self.navigationItem.rightBarButtonItem = bbSubmit;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = NO;
    [self.navigationController setToolbarHidden:NO];
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
    if ([Aircraft sharedAircraft].rgMakeModels == nil)
        [self updateMakes];
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
            return self.ac.isNew ? rowInfoLast - rowInfoStart + 1 : 1;
        case sectEditModelPrompt:
            return 1;
        case sectFavorite:
            return self.ac.isNew ? 0 : 1;
        case sectAnonymous:
            // Only show this section if we are a real, new aircraft
            return (!self.ac.isSim && self.ac.isNew) ? 1 : 0;
        case sectTailNumber:
            // Only show this section if we are a real, new, non-anonymouse aircraft
            return (!self.ac.isSim && self.ac.isNew && !self.ac.isAnonymous) ? 1 : 0;
        case sectImages:
            return ([self.rgImages count] == 0) ? 0 : 1 + (([self isExpanded:section]) ? [self.rgImages count] : 0);
        case sectPrefs:
            // hide this section if we are new
            return (self.ac.isNew) ? 0 : 1 + (([self isExpanded:section]) ? rowPrefsLast - rowPrefsHeader : 0);
            break;
        case sectNotes:
            return self.ac.isNew ? 0 : ([self isExpanded:section] ? rowNotesLast - rowNotesFirst + 1 : 1);
        case sectMaintenance:
            // Hide this section if we are new, a sim, or anonymous
            return (self.ac.isNew || self.ac.isSim || self.ac.isAnonymous) ? 0 : 1 + (([self isExpanded:section]) ? rowMaintLast - rowMaintFirst : 0);
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
            return (self.ac.isNew) ? rowInfoStart + row : rowStaticDesc;
        case sectImages:
            return rowImageHeader + row;
        case sectAnonymous:
            return rowIsAnonymous;
        case sectTailNumber:
            return rowTailnum;
        case sectFavorite:
            return rowFavorite;
        case sectPrefs:
            return rowPrefsHeader + row;
        case sectNotes:
            return rowNotesFirst + row;
        case sectMaintenance:
            return rowMaintHeader + row;
        case sectEditModelPrompt:
            return rowEditModelPrompt;
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

- (void) setDate:(NSDate *) dt andExpiration:(NSDate *) dtExpiration forCell:(EditCell *) ec
{
    ec.txt.text = [NSDate isUnknownDate:dt] ? @"" : [dt dateString];
    if ([NSDate isUnknownDate:dtExpiration])
        ec.lblDetail.text = @"";
    else
    {
        BOOL fIsExpired = [dtExpiration compare:[NSDate date]] == NSOrderedAscending;
        ec.lblDetail.text = [NSString stringWithFormat:(fIsExpired ? NSLocalizedString(@"CurrencyExpired", @"Currency Expired format string") : NSLocalizedString(@"CurrencyValid", @"Currency Valid format string")), [dtExpiration dateString]];
        ec.lblDetail.textColor = (fIsExpired) ? [UIColor redColor] : MFBTheme.currentTheme.cellValue1DetailTextColor;
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
    ec.txt.attributedPlaceholder = [MFBTheme.currentTheme formatAsPlaceholder:NSLocalizedString(@"(Tap for Today)", @"Prompt for date that is currently un-set (tapping sets it to TODAY)")];
    ec.txt.delegate = self;
    ec.lbl.text = szPrompt;
    ec.txt.clearButtonMode = UITextFieldViewModeNever;
    [self setDate:dt andExpiration:dtExpiration forCell:ec];
    return ec;
}

- (EditCell *) decimalCell:(NSNumber *) num withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView
{
    EditCell * ec = [EditCell getEditCellDetail:tableView withAccessory:self.vwAccessory];
    ec.txt.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
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
    ec.txt.attributedPlaceholder = [MFBTheme.currentTheme formatAsPlaceholder:szPlaceholder];
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
            cell.detailTextLabel.text = [aircraft descriptionOfModelId:[self.ac.ModelID intValue]];;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        case rowIsAnonymous:
        {
            CheckboxCell * cc = [CheckboxCell getButtonCell:tableView];
            [cc.btn setTitle:NSLocalizedString(@"Anonymous Aircraft", @"Indicates an anonymous aircraft") forState:0];
            [cc.btn setIsCheckbox];
            [cc.btn addTarget:self action:@selector(toggleAnonymous:) forControlEvents:UIControlEventTouchUpInside];
            [cc makeTransparent];
            cc.btn.selected = self.ac.isAnonymous;
            return cc;
        }
        case rowInstanceType:
        case rowTailnum:
        {
            EditCell * ec = [EditCell getEditCellNoLabel:tableView withAccessory:self.vwAccessory];
            ec.txt.inputView = self.picker;
            if (row == rowTailnum)
                ec.txt.text = self.ac.TailNumber;
            else
                ec.txt.text = (NSString *) (aircraft.rgAircraftInstanceTypes)[[self.ac.InstanceTypeID intValue] - 1];
            
            ec.txt.attributedPlaceholder = [MFBTheme.currentTheme formatAsPlaceholder:(row == rowTailnum) ? NSLocalizedString(@"(Tail)", @"Tail Hint") : NSLocalizedString(@"(Model)", @"Model Hint")];
            ec.txt.delegate = self;
            ec.txt.clearButtonMode = UITextFieldViewModeNever;
            ec.txt.adjustsFontSizeToFitWidth = YES;
            return ec;
        }
        case rowModel:
        {
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
        case rowEditModelPrompt:
        {
            static NSString * cidEditInfo = @"cellEditModel";
            TextCell * tc = (TextCell *) [tableView dequeueReusableCellWithIdentifier:cidEditInfo];
            if (tc == nil)
                tc = [TextCell getTextCellTransparent:tableView];
            tc.txt.text = (self.ac.isNew) ?
                NSLocalizedString(@"Add Model Prompt", @"Prompt to create a new model on MyFlightbook.com") :
                NSLocalizedString(@"WrongModelPrompt", @"Prompt to edit model on MyFlightbook.com");
            return tc;
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
            cell.accessoryType = (ac.RoleForPilot == MFBWebServiceSvc_PilotRole_None) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
            cell.accessoryType = (ac.RoleForPilot == MFBWebServiceSvc_PilotRole_PIC) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
            cell.accessoryType = (ac.RoleForPilot == MFBWebServiceSvc_PilotRole_SIC) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
            cell.accessoryType = (ac.RoleForPilot == MFBWebServiceSvc_PilotRole_CFI) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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
                    cell.imageView.image = [ci GetThumbnail];
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

- (void) toggleAnonymous:(UIButton *) sender
{
    NSIndexPath * ip = [NSIndexPath indexPathForRow:0 inSection:sectTailNumber];
    NSArray * rgIP = @[ip];
    if (self.ac.isAnonymous)
    {
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
        case rowModel:
        {
            [self.tableView endEditing:YES];
            MakeModel * mmView = [[MakeModel alloc] initWithNibName:@"MakeModel" bundle:nil];
            mmView.ac = self.ac;
            
            [self.navigationController pushViewController:mmView animated:YES];
        }
            break;
        case rowIsAnonymous:
            break;
        case rowTailnum:
            // Do nothing if this is a sim or anonymous
            if ([self.ac isSim] || [self.ac isAnonymous])
                break;
            // Otherwise, fall through.
        case rowInstanceType:
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

#pragma mark - Data Source - picker
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    switch (row)
    {
        case rowTailnum:
            return TAILNUMDIGITS;
        case rowInstanceType:
        default:
            return 1;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    static CGFloat widthMargins = 20.0;
    CGFloat defaultWidth = pickerView.frame.size.width - 2 * widthMargins;
    
    return defaultWidth / [self numberOfComponentsInPickerView:pickerView];
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
 
	switch (row)
	{
		case rowInstanceType:
            return [[Aircraft sharedAircraft].rgAircraftInstanceTypes count];
		case rowTailnum:
			if (component == 0)
				return [CountryCode AllCountryCodes].count;
			else if (component < MINTAILNUM)
				return 36;  // = 26 letters + 10 digits
			else
				return 37;  // = 26 letters + 10 digits + blank
	}
	return 0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger cellID = [self cellIDFromIndexPath:self.ipActive];
    
	switch (cellID)
	{
		case rowInstanceType:
            return (NSString *) ([Aircraft sharedAircraft].rgAircraftInstanceTypes)[row];
		case rowTailnum:
		{
			if (component == 0)
				return [CountryCode AllCountryCodes][row].Prefix;
			else
			{
				int iOffset = 0;
				if (component >= MINTAILNUM)
				{
					iOffset = 1;
					if (row == 0)
						return @"";
				}
				return [NSString stringWithFormat:@"%c", (row < 10 + iOffset) ? '0' + (int) (row - iOffset) : 'A' +  (int) (row - (10 + iOffset))];
			}
        }
        default:
            return @"";
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger cellID = [self cellIDFromIndexPath:self.ipActive];
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    
    switch (cellID)
    {
        case rowInstanceType:
        {
            BOOL fIsSim = [self.ac isSim];
            
            self.ac.InstanceTypeID = @(row + 1);
            ec.txt.text = (NSString *) ([Aircraft sharedAircraft].rgAircraftInstanceTypes)[[self.ac.InstanceTypeID intValue] - 1];
            
            // if it changed to/from being a sim, reload the table.
            if ([self.ac isSim] ^ fIsSim)
                [self.tableView reloadData];
        }
            break;
        case rowTailnum:
        {
			NSMutableString * sz = [[NSMutableString alloc] init];
			for (int i = 0; i < pickerView.numberOfComponents; i++)
			{
				NSInteger row = [pickerView selectedRowInComponent:i];
				[sz appendString:[self pickerView:pickerView titleForRow:row forComponent:i]];
			}
			ec.txt.text = self.ac.TailNumber = sz;
        }
            break;
    }
}

#pragma mark - DatePicker
- (IBAction)dateChanged:(UIDatePicker *)sender
{
    NSInteger row = [self cellIDFromIndexPath:self.ipActive];
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    ec.txt.text = [sender.date dateString];
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
        ec.txt.text = [self.datePicker.date dateString];
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
    self.vwAccessory.btnDelete.enabled = (row != rowInstanceType);
    
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
        case rowTailnum:
        {
            if ([self.ac isSim])
                return NO;
            
            [self.picker reloadAllComponents];
			if ([self.ac.TailNumber length] == 0)
			{
				for (int i = 0; i < [self.picker numberOfComponents]; i++)
					[self.picker selectRow:0 inComponent:0 animated:YES];
			}
			
            NSArray<CountryCode *> * rgCodes = [CountryCode AllCountryCodes];
            CountryCode * ccBest = [CountryCode BestGuessPrefixForTail:self.ac.TailNumber];
            NSInteger iPref = (ccBest == nil) ? 0 : [rgCodes indexOfObject:ccBest];
			NSString * szPref = rgCodes[iPref].Prefix;
			if (iPref >= 0)
                [self.picker selectRow:iPref inComponent:0 animated:YES];
			
			NSRange r;
			
			r.location = [szPref length];
			r.length = 1;
			
			int iComponent = 1;
			int iOffset;
			
			while (r.location < [self.ac.TailNumber length])
			{
				unichar rgch[5];
				
				[self.ac.TailNumber getCharacters:rgch range:r];
				
				iOffset = (iComponent < MINTAILNUM) ? 0 : 1;
				
				if (rgch[0] >= '0' && rgch[0] <= '9')
					[self.picker selectRow:(rgch[0] - '0' + iOffset) inComponent:iComponent animated:YES];
				else if (rgch[0] >= 'A' && rgch[0] <= 'Z')
					[self.picker selectRow:(rgch[0] - 'A' + iOffset + 10) inComponent:iComponent animated:YES];
				
				r.location++;
				iComponent++;
			}
			
			while (iComponent < [self.picker numberOfComponents])
				[self.picker selectRow:0 inComponent:iComponent++ animated:YES];
		}
            break;
        case rowInstanceType:
            [self.picker reloadAllComponents];
            [self.picker selectRow:[self.ac.InstanceTypeID intValue] - 1 inComponent:0 animated:YES];
            break;
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
    NSString * szNew = [textField.text stringByReplacingCharactersInRange:range withString:string];
    switch (row)
    {
        case rowTailnum:
            self.ac.TailNumber = szNew;
            break;
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
        case rowTailnum:
        case rowInstanceType:
            return [self.ac isNew];
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

#pragma mark Update Makes and models
- (void) updateMakesCompleted:(MFBSoapCall *) sc fromCaller:(Aircraft *) a
{
    if (![self.ac isNew])
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];  // in case the static description needs to be updated.
}

- (void) updateMakes
{
    Aircraft * a = [Aircraft sharedAircraft];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self updateMakesCompleted:sc fromCaller:(Aircraft *) ao];
    }];
    [a loadMakeModels];
}

#pragma mark - Add Image
- (void) addImage:(CommentedImage *)ci
{
    [self.rgImages addObject:ci];
    [self.tableView reloadData];
    [super addImage:ci];
    if (![self isExpanded:sectImages])
        [self expandSection:sectImages];
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
- (void) aircraftRefreshComplete:(MFBSoapCall *) sc withCaller:(Aircraft *) a
{
    // dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:^{
        // display any error that happened at any point
        if ([sc.errorString length] > 0)
            [self showErrorAlertWithMessage:sc.errorString];
        else
        {
            // Notify of a change so that the whole list gets refreshed
            [self.delegate aircraftListChanged];
            // the add/update was successful, so we can pop the view.  Don't pop the view if the add/update failed.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    self.progress = nil;
}

- (void) imagesComplete:(NSArray *) ar
{
    MFBSoapCall * sc = (MFBSoapCall *)ar[0];
    Aircraft * a = (Aircraft *) ar[1];

    // add/update was successful - though we may get an error from reloading aircraft below.
    BOOL fNew = [self.ac.AircraftID intValue] < 0;
    [self showAlertWithTitle:NSLocalizedString(@"Success", @"Title for success message box") message:(fNew ? NSLocalizedString(@"Aircraft added successfully", @"Aircraft added successfully") : NSLocalizedString(@"Aircraft updated successfully", @"Aircraft updated successfully"))];
    
    // Invalidate totals, since this could affect currency (e.g., vor checks)
    [mfbApp() invalidateCachedTotals];
    
    Aircraft * aircraft = [Aircraft sharedAircraft];
    // And reload user aircraft to pick up the changes, if necessary
    if (fNew && a.rgAircraftForUser != nil && [a.rgAircraftForUser count] > 0)
    {
        aircraft.rgAircraftForUser = a.rgAircraftForUser;
        [aircraft cacheAircraft:a.rgAircraftForUser forUser:mfbApp().userProfile.AuthToken];
        [self aircraftRefreshComplete:sc withCaller:a];
    }
    else
    {
        [aircraft setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
            [self aircraftRefreshComplete:sc withCaller:(Aircraft *) ao];
        }];
        [aircraft loadAircraftForUser:YES]; // force a refresh attempt.
    }
}

- (void) submitImagesWorker:(NSArray *) ar
{
    @autoreleasepool {
        BOOL fIsNew = self.ac.AircraftID.intValue < 0;
        NSString * targetURL = fIsNew ? MFBAIRCRAFTIMAGEUPLOADPAGENEW : MFBAIRCRAFTIMAGEUPLOADPAGE;
        NSString * key = fIsNew ? ac.TailNumber : ac.AircraftID.stringValue;
        [CommentedImage uploadImages:self.rgImages progressUpdate:^(NSString * sz) { self.progress.title = sz; }
                              toPage:targetURL authString:[MFBAppDelegate threadSafeAppDelegate].userProfile.AuthToken keyName:MFB_KEYAIRCRAFTIMAGE keyValue:key];
        [self performSelectorOnMainThread:@selector(imagesComplete:) withObject:ar waitUntilDone:NO];
    }
}

- (void) aircraftWorkerComplete:(MFBSoapCall *)sc withCaller:(Aircraft *) a
{
	if ([sc.errorString length] == 0)
        [NSThread detachNewThreadSelector:@selector(submitImagesWorker:) toTarget:self withObject:@[sc, a]];
    else
        [self aircraftRefreshComplete:sc withCaller:a];
}

- (void) aircraftWorker
{
	BOOL fNew = [self.ac.AircraftID intValue] < 0;
    
    // Don't upload if we have videos and are not on wifi:
    if (![CommentedImage canSubmitImages:self.rgImages])
    {
        MFBSoapCall * sc = [MFBSoapCall alloc];
        sc.errorString = NSLocalizedString(@"ErrorNeedWifiForVids", @"Can't upload with videos unless on wifi");
        [self aircraftRefreshComplete:sc withCaller:[Aircraft sharedAircraft]];
        return;
    }
	
    Aircraft * a = [[Aircraft alloc] init];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self aircraftWorkerComplete:sc withCaller:(Aircraft *) ao];
    }];
    a.rgAircraftForUser = nil;
    NSString * szAuthToken = mfbApp().userProfile.AuthToken;
    
	if (fNew)
		[a addAircraft:self.ac ForUser:szAuthToken];
	else
		[a updateAircraft:self.ac ForUser:szAuthToken];
}

- (IBAction) addAircraft
{
    [self.tableView endEditing:YES]; // capture any changes.
	NSString * szError = @"";
	
    BOOL fIsRealAirplane = ![self.ac isSim];
    
	if ([ac.ModelID intValue] <= 0)
		szError = NSLocalizedString(@"Please select a model for the aircraft", @"Error: please select a model");
	if (fIsRealAirplane && [ac.TailNumber length] <= 2)
		szError = NSLocalizedString(@"Please specify a valid tailnumber.", @"Error: please select a valid tailnumber");
    
    if (fIsRealAirplane)
    {
        if (![self.ac isAnonymous])
        {
            CountryCode * cc = [CountryCode BestGuessPrefixForTail:ac.TailNumber];
            if (cc != nil)
            {
                if ([ac.TailNumber length] <= cc.Prefix.length)
                    szError = NSLocalizedString(@"Tailnumber has nothing beyond the country code.", @"Error: Tailnumber has nothing beyond the country code");
            }
        }
    }
    else
        ac.TailNumber = [Aircraft PrefixSIM];
    
	
	if ([szError length] > 0)
	{
        [self showErrorAlertWithMessage:szError];
		return;
	}
	
    self.progress = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Uploading aircraft data...", @"Progress: uploading aircraft data") onViewController:self];
    
    [self aircraftWorker];
}

- (IBAction) UpdateAircraft
{
    [self.tableView endEditing:YES]; // capture any changes.
    self.progress = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Updating aircraft...", @"Progress: updating aircraft") onViewController:self];
	[self aircraftWorker];
}
@end
