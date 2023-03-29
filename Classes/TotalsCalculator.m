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
//  TotalsCalculator.m
//  MFBSample
//
//  Created by Eric Berman on 2/12/17.
//
//

#import <MyFlightbook-Swift.h>
#import "TotalsCalculator.h"

@interface TotalsCalculator ()

@property (nonatomic, strong) EditCell * cellSegmentStart;
@property (nonatomic, strong) EditCell * cellSegmentEnd;
@property (nonatomic, strong) NSMutableArray<NSNumber *> * values;
@property (nonatomic, strong) AccessoryBar * vwAccessory;
@property (nonatomic, strong) NSString * errorString;

@end

@implementation TotalsCalculator

@synthesize cellSegmentStart, cellSegmentEnd, values, delegate, vwAccessory, errorString;

enum timecalcRows {sectTimeGroupStart, rowEquation = sectTimeGroupStart, rowSegmentStart, rowSegmentEnd, sectTimeGroupEnd,
    sectActionsStart = sectTimeGroupEnd, rowCopy = sectActionsStart, rowAdd, rowUpdate, sectActionsEnd};

EditCell * cellToActivateAfterReload = nil;

- (instancetype) init
{
    if (self = [super init]) {
        self.values = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    // Do any additional setup after loading the view.
    cellToActivateAfterReload = self.cellSegmentStart = [self getEditCell:NSLocalizedString(@"tcAddTimeStartPrompt", @"Total Time Calculator - Segment Start")];
    self.cellSegmentEnd =  [self getEditCell:NSLocalizedString(@"tcAddTimeEndPrompt", @"Total Time Calculator - Segment End")];
    self.errorString = @"";
    [self clearTime];
}

- (EditCell *) getEditCell:(NSString *) label {
    EditCell * ec = [EditCell getEditCell:self.tableView withAccessory:nil];
    ec.txt.delegate = self;
    ec.txt.inputAccessoryView = self.vwAccessory;
    ec.txt.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
    [ec.txt setNumberType:NumericTypeTime inHHMM:YES];
    ec.txt.IsHHMM = YES;
    ec.txt.text = @"";
    [ec setLabelToFit:label];
    return ec;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
- (void) copySum {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [UITextField stringFromNumber:[NSNumber numberWithDouble:self.computedTotal] forType:NumericTypeTime inHHMM:UserPreferences.current.HHMMPref];
}

- (void) addSum {
    cellToActivateAfterReload = self.cellSegmentStart;
    [self addSpecifiedTime];
    [self.tableView reloadData];
}

- (void) updateSum {
    [self addSpecifiedTime];
    if (self.delegate != nil)
        [self.delegate updateTotal:[NSNumber numberWithDouble:self.computedTotal]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setInitialTotal: (NSNumber *) d {
    if (d.doubleValue > 0)
        [self.values addObject:d];
}

#pragma mark - segment math
- (void) clearTime {
    self.cellSegmentStart.txt.text = @"";
    self.cellSegmentEnd.txt.text = @"";
    [self.tableView reloadData];
}

- (double) computedTotal {
    double d = 0.0;
    for (NSNumber * n in self.values) {
        d += n.doubleValue;
    }
    return d;
}

- (double) getSpecifiedTimeRange {
    double d1 = self.cellSegmentStart.txt.value.doubleValue;
    double d2 = self.cellSegmentEnd.txt.value.doubleValue;
    
    if (d1 >= 0 && d2 >= 0 && d1 <= 24 && d2 <= 24) {
        while (d2 < d1)
            d2 += 24.0;
        
        self.errorString = @"";
        [self clearTime];
        return d2 - d1;
    } else {
        self.errorString = NSLocalizedString(@"tcErrBadTime", @"Total Time Calculator - Error - bad times");
        cellToActivateAfterReload = nil;
        [self.tableView reloadData];
        
    }
    
    return 0.0;
}

- (void) addSpecifiedTime {
    double d = self.getSpecifiedTimeRange;
    if (d > 0) {
        [self.values addObject:[NSNumber numberWithDouble:d]];
    }
}

- (NSString *) equationString {
    if (self.values.count == 0)
        return @"";
    
    BOOL fHHMM = UserPreferences.current.HHMMPref;
    NSMutableString * s = [NSMutableString new];
    for (NSNumber * n in self.values) {
        NSString * szVal = [UITextField stringFromNumber:n forType:NumericTypeTime inHHMM:fHHMM];
        if (s.length > 0)
            [s appendFormat:@" + %@", szVal];
        else
            [s appendString: szVal];
    }
    if (self.values.count > 0)
        [s appendFormat:@" = %@", [UITextField stringFromNumber:[NSNumber numberWithDouble:self.computedTotal] forType:NumericTypeTime inHHMM:fHHMM]];
    
    return s;
}

#pragma mark - UITableViewDelegate

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? NSLocalizedString(@"tcAddTimeRangePrompt", @"Total Time Calculator - Prompt") : @"";
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return section == 0 ? self.errorString : @"";
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return sectTimeGroupEnd - sectTimeGroupStart;
    else
        return sectActionsEnd - sectActionsStart;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) ip {
    if (ip.section == 0)
        return rowEquation + ip.row;
    else
        return sectActionsStart + ip.row;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell == cellToActivateAfterReload) {
        [cellToActivateAfterReload.txt becomeFirstResponder];
        cellToActivateAfterReload = nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self cellIDFromIndexPath:indexPath]) {
        default:    // should never happen.
        case rowEquation: {
            static NSString *CellIdentifier = @"cellModel";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.detailTextLabel.text = nil;
            cell.textLabel.text = self.equationString;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
            break;
        case rowSegmentStart:
            return self.cellSegmentStart;
        case rowSegmentEnd:
            return self.cellSegmentEnd;
        case rowCopy: {
            ButtonCell * bc = [ButtonCell getButtonCell:tableView];
            [bc.btn setTitle:NSLocalizedString(@"tcCopyResult", @"Total Time Calculator - Copy") forState:0];
            [bc.btn addTarget:self action:@selector(copySum) forControlEvents:UIControlEventTouchUpInside];
            return bc;
        }
            break;
        case rowAdd: {
            ButtonCell * bc = [ButtonCell getButtonCell:tableView];
            [bc.btn setTitle:NSLocalizedString(@"tcAddSegment", @"Total Time Calculator - Add") forState:0];
            [bc.btn addTarget:self action:@selector(addSum) forControlEvents:UIControlEventTouchUpInside];
            return bc;
        }
            
            break;
        case rowUpdate: {
            ButtonCell * bc = [ButtonCell getButtonCell:tableView];
            [bc.btn setTitle:NSLocalizedString(@"tcAddSegmentAndUpdate", @"Total Time Calculator - Add and update") forState:0];
            [bc.btn addTarget:self action:@selector(updateSum) forControlEvents:UIControlEventTouchUpInside];
            return bc;
        }
            
            break;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    [self enableNextPrev:self.vwAccessory];

    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField {
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSInteger row = [self cellIDFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    if (row == rowSegmentStart)
        [self nextClicked];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [textField isValidNumber:[textField.text stringByReplacingCharactersInRange:range withString:string]];
}

#pragma mark -
#pragma mark AccessoryViewDelegates
- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    NSInteger row = [self cellIDFromIndexPath:ip];
    return row == rowSegmentStart || row == rowSegmentEnd;
}
@end
