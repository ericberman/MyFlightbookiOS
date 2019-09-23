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
//  CollapsibleTable.m
//  MFBSample
//
//  Created by Eric Berman on 3/19/13.
//
//

#import "CollapsibleTable.h"
#import "ExpandHeaderCell.h"
#import "PropertyCell.h"
#import "NavigableCell.h"
#import "Airports.h"
#import "MFBTheme.h"

@import Photos;

@interface CollapsibleTable ()
@end

@implementation CollapsibleTable

BOOL fSelectActiveSelOnScrollCompletion = NO;
BOOL fSelectFirst = NO;

@synthesize expandedSections, ipActive, fIsValid, defSectionFooterHeight, defSectionHeaderHeight;

#pragma mark - View Creation/Destruction
- (void) setUpCollapsibleTable
{
    self.expandedSections = [[NSMutableIndexSet alloc] init];
    self.fIsValid = NO;
    self.defSectionHeaderHeight = self.defSectionFooterHeight = 1;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self setUpCollapsibleTable];
    }
    return self;
}

- (instancetype) init
{
    self = [super init];
    [self setUpCollapsibleTable];
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self setUpCollapsibleTable];
    return self;
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setUpCollapsibleTable];
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    // Fix an iOS 11 issue with going under the UITabBar?
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserverForName:NOTIFY_THEME_CHANGED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.tableView reloadData];
    }];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Misc ViewController
- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) reload {
    [self.tableView reloadData];
}

#pragma mark - Expand/collapse support
- (void) collapseSection:(NSInteger) section forTable:(UITableView *) tv
{
    if (![self isExpanded:section])
        return;

    NSInteger oldRowCount = [self tableView:tv numberOfRowsInSection:section];
    [self.expandedSections removeIndex:section];
    ExpandHeaderCell * cell = (ExpandHeaderCell *) [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [cell setExpanded:NO];
    
    NSMutableArray * rg = [[NSMutableArray alloc] initWithCapacity:oldRowCount];
    for (NSInteger i = oldRowCount - 1; i >= 1; i--)
        [rg addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    [tv deleteRowsAtIndexPaths:rg withRowAnimation:UITableViewRowAnimationTop];
}

- (void) expandSection:(NSInteger) section forTable:(UITableView *) tv
{
    if ([self isExpanded:section])
        return;

    [self.expandedSections addIndex:section];
    ExpandHeaderCell * cell = (ExpandHeaderCell *) [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    [cell setExpanded:YES];
    
    NSInteger newRowCount = [self tableView:tv numberOfRowsInSection:section];
    NSMutableArray * rg = [[NSMutableArray alloc] initWithCapacity:newRowCount];
    for (int i = 1; i < newRowCount; i++)
        [rg addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    [tv insertRowsAtIndexPaths:rg withRowAnimation:UITableViewRowAnimationTop];
}

- (void) toggleSection:(NSInteger) section forTable:(UITableView *) tableView
{
    if ([self.expandedSections containsIndex:section])
        [self collapseSection:section forTable:tableView];
    else
        [self expandSection:section forTable:tableView];
}

- (void) collapseSection:(NSInteger) section
{
    [self collapseSection:section forTable:self.tableView];
}

- (void) expandSection:(NSInteger) section
{
    [self expandSection:section forTable:self.tableView];
}

- (void) toggleSection:(NSInteger) section
{
    [self toggleSection:section forTable:self.tableView];
}

- (BOOL) isExpanded:(NSInteger) section
{
    return [self.expandedSections containsIndex:section];
}

- (void) collapseAll
{
    [self.expandedSections removeAllIndexes];
}

- (void) expandAll:(UITableView *) tableView
{
    NSInteger cSections = [tableView numberOfSections];
    for (NSInteger i = 0; i < cSections; i++)
        [self.expandedSections addIndex:i];
}

#pragma mark - Basic Accessorybar Delegate Support
- (UITableViewCell *) owningCellGeneric:(UIView *)vw
{
    UITableViewCell * tc = nil;
    while (vw != nil)
    {
        vw = vw.superview;
        if ([vw isKindOfClass:[UITableViewCell class]])
            return (UITableViewCell *) vw;
    }
    return tc;
}

- (EditCell *) owningCell:(UIView *) vw
{
    EditCell * ec = nil;
    
    while (vw != nil)
    {
        vw = vw.superview;
        if ([vw isKindOfClass:[EditCell class]])
            return (EditCell *) vw;
    }
    
    return ec;
}

- (BOOL) isNavigableRow:(NSIndexPath *) ip
{
    // this should be overriden.
    return false;
}

- (NSIndexPath *) nextNavCell:(NSIndexPath *) ip
{
    NSIndexPath * ipNext = [self nextCell:ip];
    while (ipNext.row != ip.row || ipNext.section != ip.section)
    {
        if ([self isNavigableRow:ipNext])
            return ipNext;
        ip = ipNext;
        ipNext = [self nextCell:ip];
    }
    return nil;
}

- (NSIndexPath *) prevNavCell:(NSIndexPath *) ip
{
    NSIndexPath * ipPrev = [self prevCell:ip];
    while (ipPrev.row != ip.row || ipPrev.section != ip.section)
    {
        if ([self isNavigableRow:ipPrev])
            return ipPrev;
        ip = ipPrev;
        ipPrev = [self prevCell:ip];
    }
    return nil;
}

- (BOOL) canNext
{
    return [self nextNavCell:self.ipActive] != nil;
}

- (BOOL) canPrev
{
    return [self prevNavCell:self.ipActive] != nil;
}

- (void) enableNextPrev:(AccessoryBar *) vwAccessory
{
    vwAccessory.btnNext.enabled = [self canNext];
    vwAccessory.btnPrev.enabled = [self canPrev];
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (fSelectActiveSelOnScrollCompletion)
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.ipActive];
        if (cell != nil)
        {
            if ([cell isKindOfClass:[NavigableCell class]])
            {
                NavigableCell * nc = (NavigableCell *) cell;
                UIResponder * resp = (fSelectFirst) ? nc.firstResponderControl : nc.lastResponderControl;
                if (resp.canBecomeFirstResponder)
                    [resp becomeFirstResponder];
            }
        }
    }
    fSelectActiveSelOnScrollCompletion = NO;
}

- (void) navigateToActiveCell
{
    fSelectActiveSelOnScrollCompletion = YES;
    [self.tableView scrollToRowAtIndexPath:self.ipActive atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    // Scrolling MIGHT NOT happen if the cell is visible.
    // So test to see if the tableview already has it.  If so, we can call scrollViewDidEndScrollingAnimation ourselves
    if ([self.tableView cellForRowAtIndexPath:self.ipActive] != nil)
        [self scrollViewDidEndScrollingAnimation:self.tableView];
}

- (void) nextClicked
{
    NSIndexPath * ipNext = [self nextNavCell:self.ipActive];
    if (ipNext != nil)
    {
        NSLog(@"Navigating from %ld,%ld to %ld,%ld", (long) self.ipActive.section, (long) self.ipActive.row, (long) ipNext.section, (long)ipNext.row);
        self.ipActive = ipNext;
        fSelectFirst = YES;
        [self navigateToActiveCell];
    }
}

- (void) prevClicked
{
    NSIndexPath * ipPrev = [self prevNavCell:self.ipActive];
    if (ipPrev != nil)
    {
        NSLog(@"Navigating from %ld,%ld to %ld,%ld", (long) self.ipActive.section, (long) self.ipActive.row, (long) ipPrev.section, (long) ipPrev.row);
        self.ipActive = ipPrev;
        fSelectFirst = NO;
        [self navigateToActiveCell];
    }
}

- (void) doneClicked
{
    [self.tableView endEditing:YES];
}

- (void) deleteClicked
{
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];
    ec.txt.text = ec.txtML.text = @"";
}

#pragma mark - Camera support
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverController {
}

- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverController
{
	return true;
}
#endif

- (BOOL) canUseCamera
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) canUsePhotoLibrary
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void) addImages:(BOOL)usingCamera fromButton:(id)btn
{
	UIImagePickerController * imgView = [[UIImagePickerController alloc] init];
    
	imgView.delegate = self;
    
    BOOL fIsCameraAvailable = self.canUseCamera;
    BOOL fIsGalleryAvailable = self.canUsePhotoLibrary;
    if ((usingCamera && !fIsCameraAvailable) || (!usingCamera && !fIsGalleryAvailable))
        return;
    
    imgView.sourceType = (usingCamera && fIsCameraAvailable) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    imgView.mediaTypes =  [UIImagePickerController availableMediaTypesForSourceType:imgView.sourceType];
    
    imgView.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController * ppc = imgView.popoverPresentationController;
    ppc.barButtonItem = btn;
    ppc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    ppc.delegate = self;
    [self presentViewController:imgView animated:YES completion:^{}];
}

- (IBAction) pickImages:(id) sender
{
	[self addImages:NO fromButton:sender];
}

- (IBAction) takePicture:(id) sender
{
	[self addImages:YES fromButton:sender];
}

#pragma mark - UIImagePickerControllerDelegate
- (void) stopPickingPictures
{
	[self dismissViewControllerAnimated:YES completion:^{}];
	[self.tableView reloadData];
}

- (void) addImage:(CommentedImage *)ci
{
    // Subclass this to add an image!!
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString * szType = info[UIImagePickerControllerMediaType];

    BOOL fImage = (CFStringCompare((CFStringRef) szType, kUTTypeImage, 0) == kCFCompareEqualTo);
    BOOL fVideo = (CFStringCompare((CFStringRef) szType, kUTTypeMovie, 0) == kCFCompareEqualTo);
    BOOL fCamera = (picker.sourceType == UIImagePickerControllerSourceTypeCamera);
    if (fImage || fVideo)
    {
        CLLocation * loc = nil;
        if (!fCamera) {
            NSURL *url = info[UIImagePickerControllerReferenceURL];
            PHFetchResult *res = [PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:url] options:nil];
            if (res.count > 0) {
                PHAsset *thisPhoto = [res objectAtIndex: 0];
                loc = [thisPhoto location];
            }
        }
        
        CommentedImage * ci = [[CommentedImage alloc] init];
        if (fImage)
        {
            if (!fCamera && loc != nil)
                ci.imgInfo.Location = [[MFBWebServiceSvc_LatLong alloc] initWithCoord:loc.coordinate];

            UIImage * img = info[UIImagePickerControllerOriginalImage];
            [ci SetImage:img fromCamera:fCamera withMetaData:info];
        }
        else if (fVideo)
        {
            [ci SetVideo:info[UIImagePickerControllerMediaURL] fromCamera:fCamera];
        }

        [self addImage:ci];
        [self stopPickingPictures];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self stopPickingPictures];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == self)
		[self.tableView reloadData];
}

#pragma mark - Background Image
- (void) setBackground:(NSString *) szImageName
{
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:szImageName]];
    self.tableView.backgroundView.contentMode = UIViewContentModeTopLeft;
}

#pragma mark - iOS7 hacks
// Reduce the space between sections.
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = self.defSectionFooterHeight;    // default
    NSString * sz = [self tableView:tableView titleForFooterInSection:section];
    if (tableView == self.tableView && [sz length] > 0)
    {
        CGFloat h = [sz boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 20, 10000)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22.0]}
                                                        context:nil].size.height;
        return ceil(h);
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = self.defSectionHeaderHeight;
    NSString * sz = [self tableView:tableView titleForHeaderInSection:section];
    if (tableView == self.tableView && [sz length] > 0)
    {
        CGFloat h = [sz boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 20, 10000)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:22.0]}
                                     context:nil].size.height;
        return ceil(h);
    }
    
    return height;
}

#pragma mark - Theming support
- (void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [MFBTheme.currentTheme applyThemeToTableHeader:view];
}

#pragma mark - invalidate (for sign-out)
- (void) invalidateViewController
{
    // Should be subclassed
}
@end
