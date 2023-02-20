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
//  DecimalEdit.h
//  MFBSample
//
//  Created by Eric Berman on 7/31/11.
//

#import <Foundation/Foundation.h>

// Convenience alias to reduce code churn for Swift
#define ntInteger NumericTypeInteger
#define ntDecimal NumericTypeDecimal
#define ntTime NumericTypeTime

@interface UIButton(DecimalEdit) 
- (IBAction) toggleCheck:(id) sender;
- (void) setCheckboxValue:(BOOL) value;
- (void) setIsCheckbox;
@end

@interface UITextField(DecimalEdit)
@property (nonatomic, readwrite) BOOL IsHHMM;
@property (nonatomic, assign) NSNumber * value;
@property (nonatomic, assign) int NumberType;

+ (NSString *) stringFromNumber:(NSNumber *) num forType:(int) nt inHHMM:(BOOL) fHHMM useGrouping:(BOOL) fGroup;
+ (NSString *) stringFromNumber:(NSNumber *) num forType:(int) nt inHHMM:(BOOL) fHHMM;
+ (NSNumber *) valueForString:(NSString *) sz withType:(int) numType withHHMM:(BOOL) fIsHHMM;
- (BOOL) isValidNumber:(NSString *) szProposed;
- (void) setValue:(NSNumber *) num withDefault:(NSNumber *) numDefault;
- (void) crossFillFrom:(UITextField *) txtSrc;
@end
