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
//  ApproachEditor.m
//  MFBSample
//
//  Created by Eric Berman on 1/17/17.
//
//

#import <MyFlightbook-Swift.h>
#import "ApproachEditor.h"

@interface ApproachEditor ()
@property (strong) NSArray<NSString *> * airportList;
@property (nonatomic, strong) AccessoryBar * vwAccessory;
@property (nonatomic, strong) UIPickerView * vwPickerApproach;
@property (nonatomic, strong) UIPickerView * vwPickerRunway;
@end

@implementation ApproachEditor

enum appchRows {rowCount, rowApproachType, rowRunway, rowAirport, rowAddToTotals, rowMax};

@synthesize airportList, approachDescription, delegate, vwAccessory, vwPickerApproach, vwPickerRunway;

- (instancetype) init
{
    if (self = [super init])
    {
        self.airportList = [NSMutableArray new];
        self.approachDescription = [ApproachDescription new];
        self.delegate = nil;
        self.vwAccessory = [AccessoryBar getAccessoryBar:self];
        self.vwPickerApproach = [UIPickerView new];
        self.vwPickerRunway = [UIPickerView new];
        self.vwPickerApproach.dataSource = self.vwPickerRunway.dataSource = self;
        self.vwPickerRunway.delegate = self.vwPickerApproach.delegate = self;
    }
    return self;
}

- (void) setAirports:(NSArray<NSString *> *) lst
{
    if (lst == nil)
        lst = [NSMutableArray new];
    self.airportList = lst;
    self.approachDescription.airportName = (lst != nil && lst.count > 0) ? self.airportList[lst.count - 1] : @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.tableView endEditing:YES];
    if (self.delegate != nil)
        [self.delegate addApproachDescription:self.approachDescription];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark TableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return rowMax;
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"ApproachHelper", @"Approach Helper - Title");
    return @"";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditCell * ec = [EditCell getEditCell:self.tableView withAccessory:self.vwAccessory];
    ec.txt.delegate = self;
    ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
    ec.txt.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
    
    switch (indexPath.row)
    {
        case rowCount:
            ec.txt.keyboardType = UIKeyboardTypeNumberPad;
            ec.txt.text = self.approachDescription.approachCount == 0 ? @"" : [NSString stringWithFormat:@"%ld", (long) self.approachDescription.approachCount];
            [ec.txt setNumberType:NumericTypeInteger inHHMM:NO];
            ec.txt.placeholder = NSLocalizedString(@"NumApproaches", @"Approach Helper - Quantity");
            ec.txt.returnKeyType = UIReturnKeyNext;
            break;
        case rowAddToTotals:
        {
            UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellAddToToals"];
            cell.textLabel.text = NSLocalizedString(@"ApproachAddToCount", @"Approach Helper - Add to approach count");
            cell.accessoryType = self.approachDescription.addToTotals ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case rowApproachType:
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.text = self.approachDescription.approachName;
            ec.txt.placeholder = ec.lbl.text = NSLocalizedString(@"ApproachType", @"Approach Helper - Approach Name");
            ec.txt.returnKeyType = UIReturnKeyNext;
            ec.txt.inputView = self.vwPickerApproach;
            break;
        case rowRunway:
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.text = self.approachDescription.runwayName;
            ec.txt.placeholder = NSLocalizedString(@"ApproachRunway", @"Approach Helper - Runway");
            ec.txt.returnKeyType = UIReturnKeyNext;
            ec.txt.inputView = self.vwPickerRunway;
            break;
        case rowAirport:
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.text = self.approachDescription.airportName;
            ec.txt.placeholder = NSLocalizedString(@"ApproachAirport", @"Approach Helper - Airport");
            ec.txt.returnKeyType = UIReturnKeyGo;
            ec.txt.delegate = self;
            break;
    }
    return ec;
}

- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) indexPath
{
    return indexPath.row;
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    
    switch (row)
    {
        case rowCount:
            self.approachDescription.approachCount = textField.value.intValue;
            break;
        case rowApproachType:
            self.approachDescription.approachName = textField.text;
            break;
        case rowRunway:
            self.approachDescription.runwayName = textField.text;
            break;
        case rowAirport:
            self.approachDescription.airportName = textField.text;
    }
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    [self enableNextPrev:self.vwAccessory];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    if (row == rowAirport)
    {
        self.approachDescription.airportName = textField.text;  // in case we hadn't picked it up before.
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self nextClicked];
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == rowAddToTotals)
    {
        self.approachDescription.addToTotals = !self.approachDescription.addToTotals;
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
// Returns an autocompletion based on the given prefix.
- (NSString *) proposeCompletion:(NSString *) szPrefix
{
    if (szPrefix.length > 0 && self.airportList != nil && self.airportList.count > 0)
    {
        NSString * szTest = szPrefix.lowercaseString;
        for (NSString * sz in self.airportList)
        {
            if ([sz.lowercaseString hasPrefix:szTest])
                return sz;
        }
    }
    
    return szPrefix;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // always allow deletion of a selection (allows for deletion of proposed selection)
    if (string.length == 0)
        return YES;

    if ([string rangeOfCharacterFromSet:[NSCharacterSet.alphanumericCharacterSet invertedSet]].location != NSNotFound)
        return NO;
    
    // check for autocomplete
    NSString * szUserTyped = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString * szUserTypedWithCompletion = [self proposeCompletion:szUserTyped];
    if ([szUserTyped compare:szUserTypedWithCompletion] != NSOrderedSame)
    {
        textField.text = szUserTypedWithCompletion;
        UITextPosition * startPos = [textField positionFromPosition:textField.beginningOfDocument offset:szUserTyped.length];
        UITextPosition * endPos = textField.endOfDocument;
        [textField setSelectedTextRange:[textField textRangeFromPosition:startPos toPosition:endPos]];
        return NO;
    }
    return YES; // any string can be edited
}

#pragma mark -
#pragma mark AccessoryViewDelegates
- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    return ip.row != rowAddToTotals;
}

#pragma mark - PickerView Data Source
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.vwPickerRunway)
        return 2;
    else if (pickerView == self.vwPickerApproach)
        return 2;
    return 0;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.vwPickerRunway)
        return (component == 0) ? [ApproachDescription RunwayNames].count : [ApproachDescription RunwayModifiers].count;
    else if (pickerView == self.vwPickerApproach)
        return (component == 0) ? [ApproachDescription ApproachNames].count : [ApproachDescription ApproachSuffixes].count;
    return 0;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.vwPickerRunway)
        return (component == 0)? [ApproachDescription RunwayNames][row] : [ApproachDescription RunwayModifiers][row];
    else if (pickerView == self.vwPickerApproach)
        return (component == 0) ? [ApproachDescription ApproachNames][row] : [ApproachDescription ApproachSuffixes][row];
    return @"";
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger cellID = [self cellIDFromIndexPath:self.ipActive];
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.ipActive];

    switch (cellID)
    {
        case rowRunway:
        {
            NSMutableString * sz = [[NSMutableString alloc] init];
            for (int i = 0; i < pickerView.numberOfComponents; i++)
            {
                NSInteger row = [pickerView selectedRowInComponent:i];
                [sz appendString:[self pickerView:pickerView titleForRow:row forComponent:i]];
            }
            ec.txt.text = self.approachDescription.runwayName = sz;
        }
            break;
        case rowApproachType:
        {
            NSMutableString * sz = [[NSMutableString alloc] init];
            for (int i = 0; i < pickerView.numberOfComponents; i++)
            {
                NSInteger row = [pickerView selectedRowInComponent:i];
                [sz appendString:[self pickerView:pickerView titleForRow:row forComponent:i]];
            }
            ec.txt.text = self.approachDescription.approachName = sz;
        }
            break;
        default:
            break;
    }
}

@end
