/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  PropertyCell.m
//  MFBSample
//
//  Created by Eric Berman on 3/3/13.
//
//

#import "PropertyCell.h"
#import "FlightProps.h"
#import "Util.h"
#import "DecimalEdit.h"
#import <QuartzCore/QuartzCore.h>

@interface PropertyCell()
@property (strong) NSNumber * autofillValue;
@end

@implementation PropertyCell

@synthesize txt, lbl, lblDescription, lblDescriptionBackground, btnShowDescription, cfp, cpt, imgLocked, flightPropDelegate, autofillValue;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction) dateChanged:(UIDatePicker *)sender
{
    if ([sender isKindOfClass:[UIDatePicker class]])
    {
        self.cfp.DateValue = sender.date;
        
        if (sender.datePickerMode == UIDatePickerModeDateAndTime)
            self.txt.text = [sender.date utcString];
        else
            self.txt.text = [sender.date dateString];
    }
}

- (void) setNoText
{
    self.txt.hidden = YES;
    self.txt.enabled = NO;
    
    CGRect r = self.lbl.frame;
    r.origin.y = (self.frame.size.height - self.lbl.frame.size.height) / 2.0;
    self.lbl.frame = r;
}

- (void) autoFill:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan && self.autofillValue != nil)
        self.txt.value = self.autofillValue;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) setAutoFillValue:(NSNumber *) num
{
    self.autofillValue = num;
    // Disable the existing long-press recognizer
    NSArray * currentGestures = [NSArray arrayWithArray:self.txt.gestureRecognizers];
    for (UIGestureRecognizer *recognizer in currentGestures)
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [self.txt removeGestureRecognizer:recognizer];
    
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(autoFill:)];
    lpgr.minimumPressDuration = 0.7; // in seconds
    lpgr.delegate = self;
    [self.txt addGestureRecognizer:lpgr];
}

- (void) updateLockStatus
{
    self.imgLocked.hidden = !self.cpt.isLocked;
}

- (void) toggleLock:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan && self.cpt != nil)
    {
        self.cpt.isLocked = !self.cpt.isLocked;
        if (self.flightPropDelegate != nil)
            [self.flightPropDelegate setPropLock:self.cpt.isLocked forPropTypeID:self.cpt.PropTypeID.intValue];
        [self updateLockStatus];
    }
}

+ (PropertyCell *) getPropertyCell:(UITableView *) tableView withCPT:(MFBWebServiceSvc_CustomPropertyType *) cpt andFlightProperty:(MFBWebServiceSvc_CustomFlightProperty *) cfp
{
    static NSString *CellTextIdentifier = @"PropertyCell";
    PropertyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTextIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"PropertyCell" owner:self options:nil];
        id firstObject = topLevelObjects[0];
        if ([firstObject isKindOfClass:[PropertyCell class]] )
            cell = firstObject;
        else
            cell = topLevelObjects[1];
        
        [cell addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:cell action:@selector(toggleLock:)]];
    }
    cell.firstResponderControl = cell.lastResponderControl = cell.txt;
    cell.cpt = cpt;
    cell.cfp = cfp;

    return cell;
}

- (void) styleLabelAsDefault:(BOOL)fIsDefault
{
    self.lbl.textColor = (fIsDefault) ? [UIColor darkGrayColor] : [UIColor blackColor];
    self.lbl.font = (fIsDefault) ? [UIFont systemFontOfSize:12.0] : [UIFont boldSystemFontOfSize:12.0];
}

- (BOOL) prepForEditing
{
    BOOL fResult = YES;
    
    if (self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDate || self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime)
    {
        UIDatePicker * dp = (UIDatePicker *) self.txt.inputView;
        BOOL fDateOnly = (self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDate);
        dp.datePickerMode = fDateOnly ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
        dp.timeZone =  (fDateOnly || [AutodetectOptions UseLocalTime]) ? [NSTimeZone systemTimeZone] : [NSTimeZone timeZoneForSecondsFromGMT:0];
        dp.locale = (fDateOnly ||[AutodetectOptions UseLocalTime]) ? [NSLocale currentLocale] : [NSLocale localeWithLocaleIdentifier:@"en-GB"];


        [dp removeTarget:nil action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        if ([self.txt.text length] == 0)   // initialize it to now
        {
            [((UITableView *)self.superview) endEditing:YES];
            
            // Since we don't display seconds, truncate them; this prevents odd looking math like
            // an interval from 12:13:59 to 12:15:01, which is a 1:02 but would display as 12:13-12:15 (which looks like 2 minutes)
            // By truncating the time, we go straight to 12:13:00 and 12:15:00, which will even yield 2 minutes.
            NSTimeInterval time = floor([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
            self.cfp.DateValue = dp.date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
            self.txt.text = (self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime) ? [self.cfp.DateValue utcString] : [self.cfp.DateValue dateString];
            fResult = NO;
        }
        else
            dp.date = self.cfp.DateValue;
        [dp addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return fResult;
}

- (BOOL) handleClick
{
    switch (self.cpt.Type)
    {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            [((UITableView *)self.superview) endEditing:YES];
            if (self.cfp.BoolValue == nil)
                self.cfp.BoolValue = [[USBoolean alloc] initWithBool:YES];
            self.cfp.BoolValue.boolValue = !self.cfp.BoolValue.boolValue;
            return true;
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            [self.txt becomeFirstResponder];
            break;
        default:
            break;
    }
    return NO;
}

- (BOOL) handleTextUpdate:(UITextField *) textField
{
    switch (self.cpt.Type)
    {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            self.cfp.TextValue = textField.text;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            if ([textField.text length] == 0)
                self.cfp.DateValue = nil;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
            self.cfp.DecValue = textField.value;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            self.cfp.IntValue = textField.value;
            break;
        default:
            break;
    }
    
    // change the font rather than reloading the table to avoid mucking with focus
    [self styleLabelAsDefault:[self.cfp isDefaultForType:self.cpt]];

    return YES;
}

- (void) configureCell:(UIView *) vwAcc andDatePicker:(UIDatePicker *) dp defValue:(NSNumber *)defVal
{
    self.lbl.text = cpt.Title;
	if (self.cfp == nil || [self.cfp isDefaultForType:self.cpt])
	{
        self.txt.text = @"";
        [self styleLabelAsDefault:YES];
        self.accessoryType = UITableViewCellAccessoryNone;
	}
	else
	{
		self.txt.text = [FlightProps stringValueForProperty:self.cfp withType:self.cpt];
        [self styleLabelAsDefault:NO];
        self.accessoryType = (self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpBoolean && self.cfp.BoolValue.boolValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
    
    self.lblDescription.text = self.cpt.Description;
    self.lblDescriptionBackground.layer.cornerRadius = 5;
    self.lblDescriptionBackground.layer.masksToBounds = YES;
    self.btnShowDescription.hidden = self.cpt.Description.length == 0;

    self.txt.enabled = YES;
    self.txt.hidden = NO;
    self.txt.inputAccessoryView = vwAcc;
    [self updateLockStatus];

    switch (self.cpt.Type) {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            [self setNoText];
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            self.txt.placeholder = @"";
            self.txt.keyboardType = UIKeyboardTypeDefault;
            // turn off autocorrect if we have previous values from which to choose.  This prevents spacebar from accepting the propoosed text.
            [self.txt setAutocorrectionType: (self.cpt.PreviousValues.string.count > 0) ? UITextAutocorrectionTypeNo : UITextAutocorrectionTypeDefault];
            self.txt.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            self.txt.placeholder = (self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDate) ?
            NSLocalizedString(@"Tap for Today", @"Prompt on button to specify a date that is not yet specified") :
            NSLocalizedString(@"Tap for Now", @"Prompt on button to specify a date/time that is not yet specified");
            self.txt.inputView = dp;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
            self.txt.keyboardType = UIKeyboardTypeDecimalPad;
            self.txt.NumberType = ntDecimal;
            self.txt.autocorrectionType = UITextAutocorrectionTypeNo;
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
            // assume it's a time unless the PlanDecimal flags (0x00200000) is set, in which case force decimal
            self.txt.NumberType = ((self.cpt.Flags.unsignedIntegerValue & 0x00200000) == 0) ? ntTime : ntDecimal;
            self.txt.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.txt.autocorrectionType = UITextAutocorrectionTypeNo;
            if (defVal != nil)
                [self setAutoFillValue:defVal];
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            self.txt.NumberType = ntInteger;
            self.txt.keyboardType = UIKeyboardTypeNumberPad;
            break;
        default:
            break;
    }
}

- (IBAction) showDescription:(id)sender
{
    if (self.lblDescriptionBackground.hidden == NO)
        return;
    
    self.lblDescriptionBackground.alpha = 1.0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.lblDescriptionBackground.hidden = NO;
                         CATransition *transition = [CATransition animation];
                         [transition setDelegate:self];
                         [transition setDuration:0.7];
                         [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
                         [transition setType:@"pageUnCurl"];
                         [self.lblDescriptionBackground.layer addAnimation:transition forKey:@"pageUnCurl"];
                     }];
    
        [UIView animateWithDuration:1.0 delay:3.0 options: UIViewAnimationOptionCurveLinear animations:^{
        self.lblDescriptionBackground.alpha = 0.0;
    } completion: ^(BOOL b) { self.lblDescriptionBackground.hidden = YES; self.lblDescriptionBackground.alpha = 1.0; }];
}

// Returns an autocompletion based on the given prefix.
- (NSString *) proposeCompletion:(NSString *) szPrefix
{
    if (szPrefix.length > 0 && self.cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpString && self.cpt.PreviousValues.string.count > 0)
    {
        NSString * szTest = szPrefix.lowercaseString;
        for (NSString * sz in self.cpt.PreviousValues.string)
        {
            if ([sz.lowercaseString hasPrefix:szTest])
                return sz;
        }
    }
    
    return szPrefix;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    {
        // always allow deletion of a selection (allows for deletion of proposed selection)
        if (string.length == 0)
            return YES;
        
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
}
@end
