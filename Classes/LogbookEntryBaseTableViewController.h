/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019-2022 MyFlightbook, LLC
 
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
//  LogbookEntryBaseTableViewController.h
//  MyFlightbook
//
//  Created by Eric Berman on 7/4/19.
//

#import "FlightEditorBaseTableViewController.h"
#import "LogbookEntry.h"
#import "SelectTemplates.h"
#import "FlightProps.h"
#import "ApproachEditor.h"
#import "TotalsCalculator.h"
#import "NearbyAirports.h"

NS_ASSUME_NONNULL_BEGIN

// FlightEditorBaseTableViewController, but now knows about a logbook entry and its associated properties and templates.
// Also handles launching of various IBActions like adding aircraft, approaches, launching the totals calculator etc..
// Main pieces not in here are UITableView delegate and data source.
@class LogbookEntryBaseTableViewController;

@protocol LEEditDelegate
- (void) flightUpdated:(LogbookEntryBaseTableViewController *) sender;
@end

@interface LogbookEntryBaseTableViewController : FlightEditorBaseTableViewController<SelectTemplatesDelegate, ApproachEditorDelegate, TotalsCalculatorDelegate, NearbyAirportsDelegate>
@property (strong) LogbookEntry * le;
@property (strong) FlightProps * flightProps;
@property (readwrite, strong) NSMutableSet<MFBWebServiceSvc_PropertyTemplate *> * activeTemplates;
@property (nonatomic, strong) IBOutlet id<LEEditDelegate> delegate;

// Binding data to/from the UI
- (void) initLEFromForm;
- (void) initFormFromLE;
- (void) resetDateOfFlight;
- (void) setCurrentAircraft: (MFBWebServiceSvc_Aircraft *) ac;

// Template functionality
- (void) updateTemplatesForAircraft:(MFBWebServiceSvc_Aircraft *) ac;
- (void) pickTemplates:(id) sender;

// Properties
- (void) refreshProperties;

// Approach Editor
- (IBAction) addApproach:(id) sender;

// Options
- (IBAction) configAutoDetect;

// New Aircraft
- (IBAction) newAircraft;

// Long-press
- (void) setHighWaterHobbs:(UILongPressGestureRecognizer *) sender;
- (void) setHighWaterTach:(UILongPressGestureRecognizer *) sender;

// Nearby airports IBActions.
- (IBAction) viewClosest;
- (IBAction) autofillClosest;

// Saving a flight
- (void) submitFlight:(id) sender;

// Saving state
- (void) saveState;
- (void) restoreFlightInProgress;

// Reset flight
- (void) resetFlight;
- (void) resetFlightWithConfirmation;

// actions on a flight
- (void) sendFlight:(id) sender;
- (void) signFlight:(id)sender;
@end

NS_ASSUME_NONNULL_END
