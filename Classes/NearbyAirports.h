/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  NearbyAirports.h
//  MFBSample
//
//  Created by Eric Berman on 12/25/09.
//

#import <UIKit/UIKit.h>
#import <MyFlightbook-Swift.h>
#import "MFBWebServiceSvc.h"
#import "MFBAppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CommentedImage.h"
#import "LogbookEntry.h"

@protocol NearbyAirportsDelegate

- (void) airportClicked:(MFBWebServiceSvc_airport *) ap;
- (void) routeUpdated:(NSString *) newRoute;

@end


@interface NearbyAirports : UIViewController <UISearchBarDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate> {
	BOOL fFirstRun;
}

@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, strong) IBOutlet UISegmentedControl * segMapSelector;
@property (nonatomic, strong) IBOutlet UISearchBar * searchBar;
@property (nonatomic, strong) IBOutlet UIToolbar * toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * bbAction;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * bbAddCurloc;

@property (nonatomic, strong) Airports * nearbyAirports;
@property (nonatomic, strong) Airports * pathAirports;
@property (nonatomic, strong) NSString * routeText;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfLatLong * rgFlightPath;
@property (nonatomic, strong) NSMutableArray * rgImages;
@property (nonatomic, strong) NSObject <NearbyAirportsDelegate> * delegateNearest;
@property (nonatomic, strong) LogbookEntry * associatedFlight;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * constraintSearchHeight;

- (IBAction) updateNearbyAirports;
- (IBAction) appendCurloc:(id)sender;
- (IBAction) switchView;
- (IBAction) sendTelemetry:(id)sender;
- (void) getPathForLogbookEntry;
@end
