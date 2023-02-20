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
//  DecimalEdit.m
//  MFBSample
//
//  Created by Eric Berman on 7/31/11.
//

#import "DecimalEdit.h"
#import <MyFlightbook-Swift.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "AutodetectOptions.h"
#import "MFBTheme.h"

@implementation UIButton(DecimalEdit)

- (void) setIsCheckbox
{
    [self setImage:[UIImage imageNamed:@"Checkbox-Sel"] forState:UIControlStateSelected];
    [self setImage:[UIImage imageNamed:@"Checkbox"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(toggleCheck:) forControlEvents:UIControlEventTouchUpInside];
    UIColor * backColor = UIColor.clearColor;
    UIColor * checkColor;
    if (@available(iOS 13.0, *)) {
        checkColor = UIColor.labelColor;
    } else {
        checkColor = UIColor.darkTextColor;
    }

    self.layer.backgroundColor = backColor.CGColor;
    self.layer.borderColor = backColor.CGColor;
    self.backgroundColor = backColor;
    
    if (checkColor != nil) {
        [self setTitleColor:checkColor forState:UIControlStateNormal];
        [self setTitleColor:checkColor forState:UIControlStateFocused];
        [self setTitleColor:checkColor forState:UIControlStateSelected];
        [self setTitleColor:checkColor forState:UIControlStateHighlighted];
    }
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
static NSNumberFormatter * _nfDecimal = nil;

#pragma mark Dynamic Property IsHHMM
- (void) updateKeyboardType:(int) numType :(BOOL) fIsHHMM {
    switch (numType) {
        case ntInteger:
            self.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case ntDecimal:
            self.keyboardType = UIKeyboardTypeDecimalPad;
            break;
        case ntTime:
            self.keyboardType = fIsHHMM ? UIKeyboardTypeNumbersAndPunctuation : UIKeyboardTypeDecimalPad;
            break;
    }
}

- (void) setIsHHMM:(BOOL)IsHHMM
{
    NSString * szVal = (IsHHMM ? @"Y" : @"N");
    objc_setAssociatedObject(self, &UIB_ISHHMM_KEY, szVal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.placeholder = [UITextField stringFromNumber:@0.0 forType:self.NumberType inHHMM:IsHHMM];
    [self updateKeyboardType:self.NumberType :self.IsHHMM];
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
    BOOL fIsHHMM = self.IsHHMM = (NumberType == ntTime && [AutodetectOptions HHMMPref]);
    [self updateKeyboardType:NumberType :fIsHHMM];
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

+ (NSString *) stringFromNumber:(NSNumber *) num forType:(int) nt inHHMM:(BOOL) fHHMM useGrouping:(BOOL) fGroup {
    return [num formatAsType:nt inHHMM:fHHMM useGrouping:fGroup];
}

+ (NSString *) stringFromNumber:(NSNumber *) num forType:(int) nt inHHMM:(BOOL) fHHMM {
    return [UITextField stringFromNumber:num forType:nt inHHMM:fHHMM useGrouping:NO];
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

- (void) crossFillFrom:(UITextField *) src {
    // animate the source button onto the target, change the value, then restore the source
    [self resignFirstResponder];
    
    CGRect rSrc = src.frame;
    CGRect rDst = self.frame;
    
    UITextField * tfTemp = [[UITextField alloc] initWithFrame:rSrc];
    tfTemp.font = src.font;
    tfTemp.text = src.text;
    tfTemp.textAlignment = src.textAlignment;
    tfTemp.textColor = src.textColor;
    [src.superview addSubview:tfTemp];
    
    src.translatesAutoresizingMaskIntoConstraints = NO;
    [UIView animateWithDuration:0.5f animations:^{
        tfTemp.frame = rDst;
    }
                     completion:^(BOOL finished) {
                         self.text = src.text;
                         [UIView animateWithDuration:0.5f animations:^{
                             tfTemp.frame = rSrc;
                         }
                                          completion:^(BOOL finished) {
                                              [tfTemp removeFromSuperview];
                                          }];
                     }];
}
@end
