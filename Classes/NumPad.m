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
//  NumPad.m
//  MFBSample
//
//  Created by Eric Berman on 3/3/13.
//
//

#import "NumPad.h"

@implementation NumPad

@synthesize idBtn6, idBtn7, idBtn8, idBtn9, idBtnDec, delegate, NumberType;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark Audio Feedback
- (void) playClickForCustomKeyTap {
    [[UIDevice currentDevice] playInputClick];
}

- (BOOL) enableInputClicksWhenVisible
{
    return YES;
}
#pragma mark KeyEvents
- (NSString *) decimalChar
{
    if (self.delegate.IsHHMM)
        return @":";
    else
    {
        NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
        return nf.decimalSeparator;
    }
}

- (void) ShowHideAppropriateKeys
{
    NSString * szDecimal = [self decimalChar];
    
    if (self.delegate.NumberType == ntTime && self.delegate.IsHHMM)
        self.idBtn6.hidden = self.idBtn7.hidden = self.idBtn8.hidden = self.idBtn9.hidden = [self.delegate.text hasSuffix:szDecimal];
    
    self.idBtnDec.hidden = (self.delegate.NumberType == ntInteger) || (([self.delegate.text rangeOfString:szDecimal]).location != NSNotFound);
    [self.idBtnDec setTitle:szDecimal forState:0];
}

- (IBAction) keyClicked: (UIButton *) sender
{
    // check for full hours in a decimaledit
    BOOL fIsFull = NO;
    NSMutableString * curText = [NSMutableString stringWithString:delegate.text];
    
    if (self.delegate.NumberType == ntTime && self.delegate.IsHHMM)
    {
        NSRange r = [curText rangeOfString:@":"];
        NSInteger cDigitsPostColon = [curText length] - r.location - 1;
        
        fIsFull = (cDigitsPostColon == 2);
    }
    
    NSInteger i = sender.tag;
    if (i >= 0 && !fIsFull)
		[curText appendString:[NSString stringWithFormat:@"%ld", (long)i]];
    self.delegate.text = curText;
    
    // see http://developer.apple.com/library/ios/#documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/InputViews/InputViews.html#//apple_ref/doc/uid/TP40009542-CH12-SW2
    // for how to do this
    [self playClickForCustomKeyTap];
    
    [self ShowHideAppropriateKeys];    
}

- (IBAction) backspaceClicked:(UIButton *)sender
{
    if (self.delegate == nil)
        return;
    
    NSInteger cch = [self.delegate.text length];
    if (cch > 0)
        self.delegate.text = [self.delegate.text substringToIndex:cch - 1];
    [self playClickForCustomKeyTap];
    [self ShowHideAppropriateKeys];
}

- (IBAction) decimalClicked:(UIButton *)sender
{
    NSString * szDecimal = [self decimalChar];
    NSRange r = [self.delegate.text rangeOfString:szDecimal];
    if (r.length <= 0)
        self.delegate.text = [NSString stringWithFormat:@"%@%@", self.delegate.text, szDecimal];
    [self playClickForCustomKeyTap];
    [self ShowHideAppropriateKeys];
}

// Specified string OK to insert?
- (BOOL) stringOK:(NSString *) sz
{
    if ([sz length] > 1)
        return NO;
    
    NSMutableCharacterSet * cs = [[NSMutableCharacterSet alloc] init];
    [cs addCharactersInString:@"012345"];
    if (!self.idBtn6.hidden)
        [cs addCharactersInString:@"6789"];
    if (!self.idBtnDec.hidden)
        [cs addCharactersInString:[self.idBtnDec titleForState:0]];

    return ([sz rangeOfCharacterFromSet:[cs invertedSet]].location == NSNotFound);
}
#pragma mark Delegate
- (void) setTextDelegate:(UITextField *)d
{
    self.delegate = d;
    [self ShowHideAppropriateKeys];
}

#pragma mark Lifecycle

#pragma mark - Object creation
+ (NumPad *) getNumPad
{
    NSArray * comp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    int majorVersion = [comp[0] intValue];

    NSString * szPopupNib = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"NumPad-iPad" : @"NumPad";
    NSArray * nibViews = [[NSBundle mainBundle] loadNibNamed:szPopupNib owner:self options:nil];
    for (id object in nibViews)
        if ([object isKindOfClass:[NumPad class]])
        {
            ((NumPad *) object).backgroundColor = (majorVersion < 7) ?
                [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0] :
                [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
            return (NumPad *) object;
        }
    
    return nil;
}

@end
