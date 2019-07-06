/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019 MyFlightbook, LLC
 
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
//  LogbookEntryBaseViewControllerTableViewController.h
//  MyFlightbook
//
//  Created by Eric Berman on 7/4/19.
//

#import "FlightEditorBaseTableViewController.h"
#import "LogbookEntry.h"
#import "SelectTemplates.h"
#import "FlightProps.h"

NS_ASSUME_NONNULL_BEGIN

@class LogbookEntryBaseViewControllerTableViewController;

@protocol LEEditDelegate
- (void) flightUpdated:(LogbookEntryBaseViewControllerTableViewController *) sender;
@end

// FlightEditorBaseTableViewController, but now knows about a logbook entry and its associated properties and templates.  Still no actual layout...
@interface LogbookEntryBaseViewControllerTableViewController : FlightEditorBaseTableViewController<SelectTemplatesDelegate>
@property (strong) LogbookEntry * le;
@property (strong) FlightProps * flightProps;
@property (readwrite, strong) NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> * activeTemplates;
@property (nonatomic, strong) IBOutlet id<LEEditDelegate> delegate;


// Template functionality
- (void) updateTemplatesForAircraft:(MFBWebServiceSvc_Aircraft *) ac;
- (void) pickTemplates:(id) sender;

// actions on a flight
- (void) sendFlight:(id) sender;
- (void) signFlight:(id)sender;
@end

NS_ASSUME_NONNULL_END
