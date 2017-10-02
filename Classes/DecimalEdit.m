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
//  DecimalEdit.m
//  MFBSample
//
//  Created by Eric Berman on 7/31/11.
//  Copyright 2011-2017 MyFlightbook LLC. All rights reserved.
//

#import "DecimalEdit.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "AutodetectOptions.h"

@implementation UIButton(DecimalEdit)

- (void) setIsCheckbox
{
    [self setImage:[UIImage imageNamed:@"Checkbox-Sel"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"Checkbox"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(toggleCheck:) forControlEvents:UIControlEventTouchUpInside];
    self.backgroundColor = [UIColor clearColor];
    self.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.layer.borderColor = [[UIColor clearColor] CGColor];
}

- (IBAction) toggleCheck:(id) sender
{
    self.selected = !self.selected;
}

- (void) setCheckboxValue:(BOOL) value
{
    self.selected = value;
}

@end

@implementation UITextField(DecimalEdit)

@dynamic IsHHMM;
@dynamic value;
@dynamic NumberType;

static char UIB_NUMBER_TYPE_KEY;
static char UIB_ISHHMM_KEY;
static NSNumberFormatter * _nf = nil;
static NSNumberFormatter * _nfDecimal = nil;

#pragma mark Dynamic Property IsHHMM
- (void) setIsHHMM:(BOOL)IsHHMM
{
    NSString * szVal = (IsHHMM ? @"Y" : @"N");
    objc_setAssociatedObject(self, &UIB_ISHHMM_KEY, szVal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholder = [UITextField stringFromNumber:@0.0 forType:self.NumberType inHHMM:IsHHMM];
}

- (BOOL) IsHHMM
{
    NSString * sz = (NSString *) objc_getAssociatedObject(self, &UIB_ISHHMM_KEY);
    return (sz != nil && [sz compare:@"Y"] == NSOrderedSame);
}

#pragma mark NumberType
- (void) setNumberType:(int)NumberType
{
    NSNumber * nt = @(NumberType);
    objc_setAssociatedObject(self, &UIB_NUMBER_TYPE_KEY, nt, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.IsHHMM = (NumberType == ntTime && [AutodetectOptions HHMMPref]);
}

- (int) NumberType
{
    NSNumber * num = (NSNumber *) objc_getAssociatedObject(self, &UIB_NUMBER_TYPE_KEY);
    return (num == nil) ? ntInteger : [num intValue];
}

#pragma mark - String/Value conversion
+ (NSNumber *) valueForString:(NSString *) sz withType:(int) numType withHHMM:(BOOL) fIsHHMM
{
    if ([sz length] == 0)
        return @0.0;
    
    if (numType == ntTime && fIsHHMM)
    {
        NSArray * rgPieces = [sz componentsSeparatedByString:@":"];
        NSInteger cPieces = [rgPieces count];
        NSString * szH;
        NSString * szM;
        
        switch (cPieces)
        {
            case 1:
            case 2:
                szH = (NSString *) rgPieces[0];
                if (cPieces == 2)
                {
                    szM = (NSString *) rgPieces[1];
                    // pad or trim szM as appropriate
                    switch ([szM length])
                    {
                        case 0:
                            szM = @"00";
                            break;
                        case 1:
                            szM = [szM stringByAppendingString:@"0"];
                            break;
                        case 2:
                            break;
                        default:
                            szM = [szM substringToIndex:2];
                            break;
                    }
                }
                else
                    szM = @"0";
                
                if ([szH length] == 0)
                    szH = @"0";
                
                return @([szH doubleValue] + ([szM doubleValue] / 60.0));
            default:
                return @0.0;
        }
    }
    else if (numType == ntInteger)
        return @([sz intValue]);
    else
    {
        if (_nfDecimal == nil)
        {
            _nfDecimal = [[NSNumberFormatter alloc] init];
            [_nfDecimal setNumberStyle:NSNumberFormatterDecimalStyle];
        }
        // otherwise it is either explicitly a decimal, or it is a time but HHMM is false.
        return [_nfDecimal numberFromString:sz];
    }
}

+ (NSString *) stringFromNumber:(NSNumber *) num forType:(int) nt inHHMM:(BOOL) fHHMM
{
    if (nt == ntTime && fHHMM)
    {
        double val = [num doubleValue];
        val = round(val * 60.0) / 60.0; // fix any rounding by getting precise minute
        int hours = (int) trunc(val);
        int minutes = (int) round((val - hours) * 60);
        return [NSString stringWithFormat:@"%d:%02d", hours, minutes];
    }
    else if (nt == ntInteger)
        return [num stringValue];
    else
    {
        if (_nf == nil)
        {
            _nf = [[NSNumberFormatter alloc] init];
            _nf.numberStyle = NSNumberFormatterDecimalStyle;
            _nf.maximumFractionDigits = 2;
            _nf.minimumFractionDigits = 1;
            _nf.usesGroupingSeparator = NO; // necessary for round-trip.
        }
        
        return [_nf stringFromNumber:num];
    }
}

#pragma mark DynamicProperty numericValue
- (NSNumber *) value
{
    return [UITextField valueForString:self.text withType:self.NumberType withHHMM:self.IsHHMM];
}

- (void) setValue:(NSNumber *) num
{
    self.text = [UITextField stringFromNumber:num forType:self.NumberType inHHMM:self.IsHHMM];
}

- (void) setValue:(NSNumber *) num withDefault:(NSNumber *) numDefault
{
    if ([num doubleValue] == [numDefault doubleValue])
        self.text = @"";
    else
        [self setValue:num];
}

#pragma mark utility
- (BOOL) isValidNumber:(NSString *) szProposed
{
    NSRange rangeWhole, rangeResult;
    rangeWhole.location = 0;
    rangeWhole.length = szProposed.length;
    
    NSRegularExpression * re;
    if (self.NumberType == ntInteger)
        re = [NSRegularExpression regularExpressionWithPattern:@"^\\d*$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    else if (self.NumberType == ntDecimal || (self.NumberType == ntTime && !self.IsHHMM))
    {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSString * szDecimal = [formatter decimalSeparator];
        if ([szDecimal compare:@"."] == NSOrderedSame)
            szDecimal = @"\\.";
        re = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"^\\d*%@?\\d*$", szDecimal] options:NSRegularExpressionAnchorsMatchLines error:nil];
    }
    else
        re = [NSRegularExpression regularExpressionWithPattern:@"^\\d*:?\\d{0,2}$" options:NSRegularExpressionAnchorsMatchLines error:nil];
    
    rangeResult = [re rangeOfFirstMatchInString:szProposed options:NSMatchingAnchored range:rangeWhole];
    return rangeResult.length == szProposed.length && rangeResult.location == 0;
}

@end
