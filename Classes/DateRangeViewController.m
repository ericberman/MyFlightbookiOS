/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2013-2020 MyFlightbook, LLC
 
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
//  DateRangeViewController.m
//  MFBSample
//
//  Created by Eric Berman on 3/11/13.
//
//

#import "DateRangeViewController.h"
#import "EditCell.h"
#import "Util.h"

@interface DateRangeViewController ()
@property (strong, readwrite) AccessoryBar * vwAccessory;
@property (nonatomic, strong) NSIndexPath * activeIndexPath;

@end

@implementation DateRangeViewController

@synthesize vwAccessory, vwDatePicker, dtEnd, dtStart, delegate, activeIndexPath;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    self.vwAccessory.btnDelete.enabled = NO;
    if (@available(iOS 13.4, *)) {
        self.vwDatePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [EditCell getEditCell:self.tableView withAccessory:nil];
    
    // Configure the cell...
    if (indexPath.row == 0) // start date
    {
        cell.lbl.text = NSLocalizedString(@"Start Date", @"Indicates the starting date of a range");
        cell.txt.text = [self.dtStart dateString];
    }
    else
    {
        // End date
        cell.lbl.text = NSLocalizedString(@"End Date", @"Indicates the ending date of a range");
        cell.txt.text = [self.dtEnd dateString];
    }
    
    cell.txt.inputAccessoryView = self.vwAccessory;
    cell.txt.inputView = self.vwDatePicker;
    cell.txt.clearButtonMode = UITextFieldViewModeNever;
    cell.txt.delegate = self;
    
    return cell;
}

#pragma mark - Table view delegate
- (void) handleClickForIndexPath:(NSIndexPath *) ip
{
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:ip];
    self.vwDatePicker.date = (ip.row == 0) ? self.dtStart : self.dtEnd;
    [ec.txt becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.activeIndexPath = indexPath;
    [self handleClickForIndexPath:indexPath];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (EditCell *) owningCell:(UIView *) vw
{
    EditCell * pc = nil;
    
    while (vw != nil)
    {
        vw = vw.superview;
        if ([vw isKindOfClass:[EditCell class]])
            return (EditCell *) vw;
    }
    
    return pc;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return NO;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeIndexPath = [self.tableView indexPathForCell:[self owningCell:textField]];
    self.vwDatePicker.date = (self.activeIndexPath.row == 0) ? self.dtStart : self.dtEnd;
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

#pragma mark -
#pragma mark dateChanged events

- (void) dateChanged:(UIDatePicker *) sender
{
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.activeIndexPath];
    ec.txt.text = [sender.date dateString];
    if (self.activeIndexPath.row == 0)
        self.dtStart = sender.date;
    else
        self.dtEnd = sender.date;
    [self.delegate setStartDate:self.dtStart andEndDate:self.dtEnd];
}

#pragma mark -
#pragma mark AccessoryViewDelegates
- (void) navigateToActiveCell
{
    [self.tableView selectRowAtIndexPath:self.activeIndexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    [self handleClickForIndexPath:self.activeIndexPath];
}

- (void) nextClicked
{
    self.activeIndexPath = [self nextCell:self.activeIndexPath];
    [self navigateToActiveCell];
}
- (void) prevClicked
{
    self.activeIndexPath = [self prevCell:self.activeIndexPath];
    [self navigateToActiveCell];
}

- (void) doneClicked
{
    EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:self.activeIndexPath];
    [ec.txt resignFirstResponder];
}

- (void) deleteClicked
{
    
}
@end
