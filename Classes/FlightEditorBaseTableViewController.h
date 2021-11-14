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
//  FlightEditorBaseTableViewController.h
//  MyFlightbook
//
//  Created by Eric Berman on 6/23/19.
//

#import "CollapsibleTable.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlightEditorBaseTableViewController : CollapsibleTable<UIGestureRecognizerDelegate, UIContentContainer, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField * idDate;
@property (nonatomic, strong) IBOutlet UITextField * idRoute;
@property (nonatomic, strong) IBOutlet UITextView * idComments;
@property (nonatomic, strong) IBOutlet UITextField * idTotalTime;
@property (nonatomic, strong) IBOutlet UITextField * idPopAircraft;
@property (nonatomic, strong) IBOutlet UITextField * idApproaches;
@property (nonatomic, strong) IBOutlet UIButton * idHold;
@property (nonatomic, strong) IBOutlet UITextField * idLandings;
@property (nonatomic, strong) IBOutlet UITextField * idDayLandings;
@property (nonatomic, strong) IBOutlet UITextField * idNightLandings;
@property (nonatomic, strong) IBOutlet UITextField * idNight;
@property (nonatomic, strong) IBOutlet UITextField * idIMC;
@property (nonatomic, strong) IBOutlet UITextField * idSimIMC;
@property (nonatomic, strong) IBOutlet UITextField * idGrndSim;
@property (nonatomic, strong) IBOutlet UITextField * idXC;
@property (nonatomic, strong) IBOutlet UITextField * idDual;
@property (nonatomic, strong) IBOutlet UITextField * idCFI;
@property (nonatomic, strong) IBOutlet UITextField * idSIC;
@property (nonatomic, strong) IBOutlet UITextField * idPIC;
@property (nonatomic, strong) IBOutlet UIButton * idPublic;

@property (nonatomic, strong) IBOutlet UILabel * idLblStatus;
@property (nonatomic, strong) IBOutlet UILabel * idLblSpeed;
@property (nonatomic, strong) IBOutlet UILabel * idLblAltitude;
@property (nonatomic, strong) IBOutlet UILabel * idLblQuality;
@property (nonatomic, strong) IBOutlet UIImageView * idimgRecording;
@property (nonatomic, strong) IBOutlet UILabel * idlblElapsedTime;
@property (nonatomic, strong) IBOutlet UIButton * idbtnPausePlay;
@property (nonatomic, strong) IBOutlet UIButton * idbtnAppendNearest;
@property (nonatomic, strong) IBOutlet UILabel * lblLat;
@property (nonatomic, strong) IBOutlet UILabel * lblLon;
@property (nonatomic, strong) IBOutlet UILabel * lblSunrise;
@property (nonatomic, strong) IBOutlet UILabel * lblSunset;

@property (nonatomic, strong) AccessoryBar * vwAccessory;

/* cells */
@property (nonatomic, strong) IBOutlet UITableViewCell * cellDateAndTail;
@property (nonatomic, strong) IBOutlet EditCell * cellComments;
@property (nonatomic, strong) IBOutlet EditCell * cellRoute;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellLandings;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellGPS;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellTimeBlock;
@property (nonatomic, strong) IBOutlet UITableViewCell * cellSharing;

@property (nonatomic, strong) IBOutlet UIDatePicker * datePicker;
@property (nonatomic, strong) IBOutlet UIPickerView * pickerView;
@property (nonatomic, strong) UITextField * _Nullable activeTextField;

// Gesture functionality
- (void) enableLongPressForField:(UITextField *) txt withSelector:(SEL) s;

// UI Management functionality
- (EditCell *) decimalCell:(UITableView *) tableView withPrompt:(NSString *)szPrompt andValue:(NSNumber *)val selector:(SEL)sel andInflation:(BOOL) fIsInflated;
- (EditCell *) dateCell:(NSDate *) dt withPrompt:(NSString *) szPrompt forTableView:(UITableView *) tableView inflated:(BOOL) fInflated;

// Accessory functionality
- (BOOL) hasAccessories;
- (void) viewAccessories;

// Misc. display functionalty
- (NSString *) elapsedTimeDisplay:(NSTimeInterval) dt;
- (void) setLabelInflated:(BOOL) fInflate forEditCell:(EditCell *)ec;

@end

NS_ASSUME_NONNULL_END
