/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2009-2018 MyFlightbook, LLC
 
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
//  NearbyAirports.m
//  MFBSample
//
//  Created by Eric Berman on 12/25/09.
//

#import "NearbyAirports.h"
#import "ImageComment.h"
#import <QuartzCore/QuartzCore.h>

@interface NearbyAirports ()
@property (atomic, readwrite) BOOL flightPathInProgress;
@property (atomic, readwrite) BOOL fHasAnnotations;
@property (strong) UIDocumentInteractionController * docController;
@end

@implementation NearbyAirports

@synthesize mapView, nearbyAirports, rgFlightPath, segMapSelector, toolbar, pathAirports, searchBar, routeText, delegateNearest, rgImages, flightPathInProgress, fHasAnnotations, bbAction, docController, associatedFlight, constraintSearchHeight;

CGFloat defaultSearchHeight;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (BOOL) showRoute
{
	return self.segMapSelector.selectedSegmentIndex == 1;
}

- (BOOL) showNearbyAirports
{
	return self.segMapSelector.selectedSegmentIndex == 0;
}

- (void) setUpRoute
{
	// auto-select route view if there is a route
	// (I.e., delegate presumes that the flight is being modified and thus is new)
	if ([self.routeText length] > 0 && self.pathAirports != nil && [self.pathAirports.rgAirports count] > 0)
    {
        self.searchBar.text = self.routeText;
		self.segMapSelector.selectedSegmentIndex = 1;
    }    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.nearbyAirports = [[Airports alloc] init];
	self.mapView.showsUserLocation = YES;
		
    [self setUpRoute];    
	// set the target AFTER adjusting the highlighted index above to avoid two calls to updateNearbyAirports
	if (self.segMapSelector)
		[self.segMapSelector addTarget:self action:@selector(updateNearbyAirports) forControlEvents:UIControlEventValueChanged];
    defaultSearchHeight = self.searchBar.frame.size.height;
    
    
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(appendAdHoc:)];
    lpgr.minimumPressDuration = 0.7; // in seconds
    lpgr.delegate = self;
    [self.mapView addGestureRecognizer:lpgr];
    
    self.fHasAnnotations = NO;
	fFirstRun = YES;
}

- (void) enableSendTelemetry
{
    [self.bbAction setEnabled:self.rgFlightPath.LatLong.count > 0];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self setUpRoute];
	[self updateNearbyAirports];
    self.navigationController.toolbarHidden = YES;
    self.mapView.mapType = [AutodetectOptions mapType];
    [self enableSendTelemetry];
    [self.bbAddCurloc setEnabled:self.delegateNearest != nil];
	[super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.delegateNearest != nil)
        [self.delegateNearest routeUpdated:self.searchBar.text];
	[super viewWillDisappear:animated];
}

- (void) addFlightPath
{
    if (self.rgFlightPath != nil && self.segMapSelector.selectedSegmentIndex == 1)
    {        
        MKCoordinateRegion mcr = [self.pathAirports defaultZoomRegionWithPath:self.rgFlightPath];
        FlightRoute * fr = [[FlightRoute alloc] init];
        fr.rgll = self.rgFlightPath;
        fr.lineColor = [UIColor redColor];
        fr.center = mcr.center;
        [self.mapView addOverlay:[fr getOverlay]];
    }
}

- (void) getPathForLogbookEntry
{
    if (!self.flightPathInProgress && self.associatedFlight != nil)
    {
        NSLog(@"GetPathForLogbookEntry in NearbyAirports");
        self.flightPathInProgress = YES;
        __block NearbyAirports * blockSelf = self;
        [self.associatedFlight setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
            if (blockSelf.flightPathInProgress)
            {
                blockSelf.flightPathInProgress = NO;
                blockSelf.rgFlightPath = ((LogbookEntry *) ao).rgPathLatLong;
                [blockSelf addFlightPath];
                [blockSelf enableSendTelemetry];
                NSLog(@"Path returned");
                blockSelf = nil;
            }}];
        [self.associatedFlight getFlightPath];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    
    Class c = NSClassFromString(((MKPolyline *) overlay).title);
    renderer.strokeColor = [c colorForPolyline];
    
    return renderer;
}

- (void) addImagesWorker
{
    @autoreleasepool {
        for (CommentedImage * ci in self.rgImages)
        {
            if (![ci hasThumbnailCache])
                [ci GetThumbnail];
            [self.mapView performSelectorOnMainThread:@selector(addAnnotation:) withObject:ci waitUntilDone:NO];
            [self.mapView setNeedsDisplay];
        }
    }
}

- (void) refreshAirportsOnMap:(MKCoordinateRegion) mcr
{		
	Airports * ap;
	if ([self showNearbyAirports])
	{
		// remove all previous annotations
		if ([self.mapView.annotations count] > 0)
			[self.mapView removeAnnotations:self.mapView.annotations];
        if ([self.mapView.overlays count] > 0)
            [self.mapView removeOverlays:self.mapView.overlays];
        self.fHasAnnotations = NO;

		ap = self.nearbyAirports;
		MFBAppDelegate * app = mfbApp();
			
		if (app.mfbloc.lastSeenLoc != nil)
			[ap loadAirportsNearPosition:mcr limit:-1];

		if ([ap.rgAirports count] > 0)
			[self.mapView addAnnotations:ap.rgAirports];
	}
	else if ([self showRoute])
	{
		// nothing to do if we have the path annotations - we'll re-use them.
		if (!self.fHasAnnotations)
		{
			ap = self.pathAirports;

			MKCoordinateRegion mcr2 = [ap defaultZoomRegionWithPath:self.rgFlightPath];

			if ([ap.rgAirports count] > 0)
			{
				[self.mapView addAnnotations:ap.rgAirports];
				
				if (self.segMapSelector.selectedSegmentIndex == 1 && ap.rgAirports.count > 1)
				{
                    AirportRoute * ar = [[AirportRoute alloc] init];
                    ar.airports = ap;
                    ar.lineColor = [UIColor blueColor];
                    ar.center = mcr2.center;

                    // if displaying route, we already have the individual airports.
                    // Now, we just want to add one more pseudo-annotation which is the Routeannotation.
                    [self.mapView addOverlay:[ar getOverlay]];
				}
			}
            
            [self addFlightPath];
        }
	}
    
    // add any images as well, but do this on a background thread
    if ([self.rgImages count] > 0)
        [NSThread detachNewThreadSelector:@selector(addImagesWorker) toTarget:self withObject:nil];

    self.fHasAnnotations = YES;
    [self.mapView setNeedsDisplay];
}

- (void) resizeForFrame
{
    self.constraintSearchHeight.constant = self.showNearbyAirports ? 0 : defaultSearchHeight;
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    
}

- (IBAction) updateNearbyAirports
{
	[self resizeForFrame];

	MFBAppDelegate * app = mfbApp();
	
	// center the map
	if ([self showNearbyAirports])
	{
		if (app.mfbloc.lastSeenLoc != nil)
			[self.mapView setRegion:[Airports defaultRegionForPosition:app.mfbloc.lastSeenLoc] animated:!fFirstRun];
        [self refreshAirportsOnMap:self.mapView.region];
	}
	else if ([self showRoute]) // show the path, zooming appropriately for it.
	{
		if (self.pathAirports != nil)
		{
            // set the region AFTER refreshing any anotations
            [self refreshAirportsOnMap:self.mapView.region];
			MKCoordinateRegion mcr = [self.pathAirports defaultZoomRegionWithPath:self.rgFlightPath];
			if (mcr.span.latitudeDelta > 0 && mcr.span.longitudeDelta > 0)
				[self.mapView setRegion:mcr animated:!fFirstRun];
		}
	}
	
	fFirstRun = NO;
}

- (IBAction) appendCurloc:(id)sender
{
    if (mfbApp().mfbloc.lastSeenLoc == nil || self.delegateNearest == nil)
        return;
    
    NSString * szLatLong = [[[MFBWebServiceSvc_LatLong alloc] initWithCoord:mfbApp().mfbloc.lastSeenLoc.coordinate] toAdhocString];
    [self.delegateNearest airportClicked:[MFBWebServiceSvc_airport getAdHoc:szLatLong]];
    if (self.navigationController != nil)
        [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void) appendAdHoc:(UILongPressGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [sender locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MFBWebServiceSvc_LatLong * ll = [[MFBWebServiceSvc_LatLong alloc] initWithCoord:touchMapCoordinate];
    NSString * szAdHoc = ll.toAdhocString;
    self.routeText = [[self.routeText stringByAppendingFormat:@" %@", szAdHoc] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self setUpRoute];
    
    if (self.delegateNearest != nil)
        [self.delegateNearest routeUpdated:self.routeText];
}


- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self resizeForFrame];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark GPX
- (void) sendTelemetryCompletion
{
    if (self.associatedFlight == nil || self.associatedFlight.gpxPath == nil || self.associatedFlight.gpxPath.length == 0)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Title for generic error message")
                                                       message:NSLocalizedString(@"errNoTelemetry", @"No telemetry to share") delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"Close", @"Close button on error message") otherButtonTitles:nil];
        
        [av show];
        return;
    }
		
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[mfbApp().mfbloc writeToFile:self.associatedFlight.gpxPath]]];
    self.docController.delegate = nil;
    bool fResult = [self.docController presentOptionsMenuFromBarButtonItem:self.bbAction animated:YES];
    if (!fResult)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Title for generic error message")
                                                       message:NSLocalizedString(@"errCantShareTelemetry", @"Unable to share telemetry") delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"Close", @"Close button on error message") otherButtonTitles:nil];
        
        [av show];
    }
}

- (void) sendTelemetry:(id)sender
{
    if (self.associatedFlight != nil && self.associatedFlight.gpxPath != nil && self.associatedFlight.gpxPath.length > 0)
        [self sendTelemetryCompletion];
    else
    {
        if (!self.flightPathInProgress && self.associatedFlight != nil)
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            self.flightPathInProgress = YES;
            __block NearbyAirports * blockSelf = self;
            [self.associatedFlight setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                blockSelf.flightPathInProgress = NO;
                [blockSelf sendTelemetryCompletion];
                blockSelf = nil;
            }];
            [self.associatedFlight getGPXDataForFlight];
        }
    }
}

#pragma mark MKMapViewDelegate functions

#define imageDimension  50.0
#define imageCornerRadius    20.0

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
	NSString * identifier;
	
	if ([annotation isKindOfClass:[MKUserLocation class]])
	{
		// Need to return nil to get updates to work.
		return nil;
	}
	else if ([annotation isKindOfClass:[CommentedImage class]])
	{
		identifier = @"pixloc";
		
        MKAnnotationView * curLocView = (MKAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (curLocView == nil)
			curLocView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];

        CommentedImage * ci = (CommentedImage *) annotation;
        
        if (ci.hasThumbnailCache)
        {
            UIImageView * imgView = [[UIImageView alloc] initWithImage:[ci GetThumbnail]];
            curLocView.frame = CGRectMake(curLocView.frame.origin.x, curLocView.frame.origin.y, imageDimension, imageDimension);
            imgView.frame = CGRectMake(0.0, 0.0, imageDimension, imageDimension);
            imgView.contentMode = curLocView.contentMode = UIViewContentModeScaleAspectFill;
            [curLocView addSubview:imgView];
            CALayer * layer = imgView.layer;
            layer.cornerRadius = imageCornerRadius;
            layer.masksToBounds = YES;
            layer.borderColor = [UIColor lightGrayColor].CGColor;
            layer.borderWidth = 2.0;
            curLocView.centerOffset = CGPointMake(0.0, 0.0);
        }
        else
        {
            curLocView.image = [UIImage imageNamed:@"cameramarker.png"];
            curLocView.contentMode = UIViewContentModeCenter;
        }
		curLocView.canShowCallout = YES;

		// add a little + button on the right to display the image
        curLocView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		return curLocView;
	}
	else
	{
		identifier = @"pinLoc";
		
		MKAnnotationView * curLocView = (MKAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (curLocView == nil)
			curLocView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        if ([annotation isKindOfClass:[MFBWebServiceSvc_airport class]] && ![((MFBWebServiceSvc_airport *) annotation) isPort])
            curLocView.image = [UIImage imageNamed:@"tower.png"];
        else
            curLocView.image = [UIImage imageNamed:@"airport.png"];
		curLocView.canShowCallout = YES;
		
		// add a little + button on the right if the airport is for an in-progress flight (i.e., that we
		// may want to click on "add" to add the nearest airport)
		if (self.delegateNearest != nil && !((MFBWebServiceSvc_airport *) annotation).isAdhoc)
			curLocView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
		
		return curLocView;
	}
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self refreshAirportsOnMap:self.mapView.region];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([view.annotation isKindOfClass:[MFBWebServiceSvc_airport class]])
	{
		// notify the parent that an airport was clicked
		if (self.delegateNearest != nil && [self.delegateNearest conformsToProtocol:@protocol(NearbyAirportsDelegate)])
			[self.delegateNearest airportClicked:(MFBWebServiceSvc_airport *) view.annotation];
		
		// and then pop ourselves off of the stack
		if (self.navigationController != nil)
			[self.navigationController popViewControllerAnimated:YES];
	}
    else if ([view.annotation isKindOfClass:[CommentedImage class]])
    {
        ImageComment * icView = [[ImageComment alloc] init];
        icView.ci = (CommentedImage *) view.annotation;
        [self.navigationController pushViewController:icView animated:YES];
    }
}

- (IBAction) switchView
{
	[self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.fHasAnnotations = NO;
	[self refreshAirportsOnMap:self.mapView.region];
}

#pragma mark Search Bar Delegate 
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	Airports * ap = [[Airports alloc] init];
	self.routeText = self.searchBar.text;
	[ap loadAirportsFromRoute:self.searchBar.text];
	
	self.pathAirports = ap;

	if ([self.searchBar.text length] > 0 && [self.pathAirports.rgAirports count] > 0)
		self.segMapSelector.selectedSegmentIndex = 1;

	[self.searchBar resignFirstResponder];
	
	[self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
	self.fHasAnnotations = NO;
	[self updateNearbyAirports];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
}

@end
