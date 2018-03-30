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
//  imageSelector.m
//  MFBSample
//
//  Created by Eric Berman on 1/10/10.
//

#import "imageSelector.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MFBAppDelegate.h"

@implementation imageSelector

@synthesize rgImages;
@synthesize popoverControl;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.rowHeight = 100.0;
	self.title = NSLocalizedString(@"Images", @"Title for image management screen (where you can add/delete/tap-to-edit images)");
			
	UIBarButtonItem * bbSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem * bbGallery = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pickImages:)];
	UIBarButtonItem * bbCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
	
	bbGallery.style = bbCamera.style = UIBarButtonItemStylePlain;

	// this code here will run always, but if iPad, it will be overrideen below.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.toolbarItems = @[bbSpacer, bbGallery, bbCamera];
	[self.navigationController setToolbarHidden:NO];
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[self.navigationController setToolbarHidden:YES];
		UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,183,44.01)];
		[toolbar setItems:@[bbSpacer, bbGallery, bbCamera, self.editButtonItem]];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
	}
#endif
}

// UIPopoverControllerDelegate functions
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{	
	self.popoverControl = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
	return true;
}
#endif

- (void) addImages:(BOOL)usingCamera fromButton:(id)btn
{
	UIImagePickerController * imgView = [[UIImagePickerController alloc] init];
	imgView.delegate = self;
		
	if (usingCamera && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		imgView.sourceType = UIImagePickerControllerSourceTypeCamera;
	else
		imgView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if (self.popoverControl == nil)
		{
		self.popoverControl = [[NSClassFromString(@"UIPopoverController") alloc] initWithContentViewController:imgView];
		((UIPopoverController *) self.popoverControl).delegate = self;
		[self.popoverControl presentPopoverFromBarButtonItem:btn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		}
	}
	else
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

// Navigation delegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == self)
		[self.tableView reloadData];
}

- (void) stopPickingPictures
{
	[self dismissViewControllerAnimated:YES completion:^{}];
	[self.tableView reloadData];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	NSString * szType = info[UIImagePickerControllerMediaType];
	if (CFStringCompare((CFStringRef) szType, kUTTypeImage, 0) == kCFCompareEqualTo)
	{
		CommentedImage * ci = [[CommentedImage alloc] init];
		UIImage * img = info[UIImagePickerControllerOriginalImage];
		[ci SetImage:img fromCamera:(picker.sourceType == UIImagePickerControllerSourceTypeCamera) withMetaData:info];
		[self.rgImages addObject:ci];
		[self stopPickingPictures];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self stopPickingPictures];
}

- (void)viewDidAppear:(BOOL)animated {
	[self.tableView reloadData];
    [super viewDidAppear:animated];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	for (CommentedImage * ci in self.rgImages)
		[ci flushCachedImage];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rgImages count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.indentationLevel = 1;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    // Set up the cell...
	CommentedImage * ci	= (CommentedImage *) (self.rgImages)[indexPath.row];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:12.0];
	cell.textLabel.numberOfLines = 2;
	
	cell.imageView.image = [ci GetThumbnail];
	cell.textLabel.text = ci.imgInfo.Comment;
	cell.indentationWidth = 10.0;
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NSLocalizedString(@"Delete", @"Title for 'delete' button in image list");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		MFBAppDelegate * app = mfbApp();
		CommentedImage * ci = (CommentedImage *) (self.rgImages)[indexPath.row];
		[ci deleteImage:app.userProfile.AuthToken];
		
		// then remove it from the array
		[self.rgImages removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		// [tableView reloadData];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ImageComment * icView = [[ImageComment alloc] init];
	icView.ci = (CommentedImage *) (self.rgImages)[indexPath.row];
	[self.navigationController pushViewController:icView animated:YES];
}

@end

