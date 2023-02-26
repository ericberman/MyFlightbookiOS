/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2011-2023 MyFlightbook, LLC
 
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
//  VADetails.m
//  MFBSample
//
//  Created by Eric Berman on 8/2/11.
//

#import "VADetails.h"
#import "RecentFlights.h"
#import <MyFlightbook-Swift.h>

@implementation VADetails

@synthesize rgVA;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
	((MKMapView *) self.view).showsUserLocation = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.rgVA != nil && [self.rgVA count] == 1)
    {
        MFBWebServiceSvc_VisitedAirport * va = (MFBWebServiceSvc_VisitedAirport *) (self.rgVA)[0];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(findFlights:)];
        self.navigationItem.title = va.Airport.Code;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = @"";
    }
    

    [self showAirports];
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark ShowAirport or airports
- (void) showAirports
{
    LatLongBox * llb = [[LatLongBox alloc] init];

    // remove all previous annotations
    if ([((MKMapView *) self.view).annotations count] > 0)
        [((MKMapView *) self.view) removeAnnotations:((MKMapView *) self.view).annotations];
    
    for (MFBWebServiceSvc_VisitedAirport * va in self.rgVA)
    {
        CLLocationCoordinate2D coord;
        coord.latitude = [va.Airport.Latitude doubleValue];
        coord.longitude = [va.Airport.Longitude doubleValue];
        [llb addPoint:coord];
    }
    [((MKMapView *) self.view) addAnnotations:self.rgVA];
    
    if ([self.rgVA count] == 1) // one airport
    {
        MFBWebServiceSvc_VisitedAirport * va = (MFBWebServiceSvc_VisitedAirport *) (self.rgVA)[0];
        MKCoordinateRegion mcr;
        mcr.span.latitudeDelta = mcr.span.longitudeDelta = 0.008; // approximately 1NM delta
        mcr.center.latitude = [va.Airport.Latitude doubleValue];
        mcr.center.longitude = [va.Airport.Longitude doubleValue];
        [((MKMapView *) self.view) setRegion:mcr animated:YES];
    }
    else
        [((MKMapView *) self.view) setRegion:[llb getRegion] animated:YES];
}

#pragma mark MKMapViewDelegate Functions
// MKMapViewDelegate functions
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
	NSString * identifier = @"VisitedAirportLoc";
	
	BOOL fIsCurrentLoc = [annotation isKindOfClass:[MKUserLocation class]];
	
    if (fIsCurrentLoc)
	{
		// Need to return nil to get updates to work.
		return nil;
	}	
	else
	{
		identifier = @"pinLoc";
		
		MKAnnotationView * curLocView = (MKAnnotationView *) [mv dequeueReusableAnnotationViewWithIdentifier:identifier];
		if (curLocView == nil)
			curLocView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		curLocView.image = [UIImage imageNamed:@"airport.png"];
		curLocView.canShowCallout = YES;
        curLocView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
		
		return curLocView;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // The annotation is a visited-airport object
    [self findFlightsForAirport:(MFBWebServiceSvc_VisitedAirport *)view.annotation];
}

#pragma mark View matching flights
- (void) findFlights:(id)sender
{
    if (self.rgVA == nil || [self.rgVA count] != 1 || self.navigationController == nil)
        return;
    [self findFlightsForAirport:(self.rgVA)[0]];
}

- (void) findFlightsForAirport:(MFBWebServiceSvc_VisitedAirport *) va
{
    MFBWebServiceSvc_FlightQuery * fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    
    [fq.AirportList.string addObjectsFromArray:[Airports CodesFromString:va.AllCodes]];
    
    RecentFlights * rf = [[RecentFlights alloc] initWithNibName:@"RecentFlights" bundle:nil];
    rf.fq = fq;
    [rf refresh];
    [self.navigationController pushViewController:rf animated:YES];
}

@end
