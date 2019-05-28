/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2013-2019 MyFlightbook, LLC
 
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
//  Util.h
//  MFBSample
//
//  Created by Eric Berman on 3/6/13.
//
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"
#import "SharedWatch.h"

@interface UIViewController(MFBAdditions)
- (void) showAlertWithTitle:(NSString *) title message:(NSString *) msg;
- (void) showErrorAlertWithMessage:(NSString *) msg;
- (void) pushOrPopView:(UIViewController *) target fromView:(id) sender withDelegate:(id<UIPopoverPresentationControllerDelegate>) delegate;
@end

@interface NSAttributedString(MFBAdditions)
+ (NSAttributedString *) attributedStringFromMarkDown:(NSString *) sz;
@end

@interface UITableViewController(MFBAdditions)
- (NSIndexPath *) nextCell:(NSIndexPath *) ipCurrent;
- (NSIndexPath *) prevCell:(NSIndexPath *) ipCurrent;
- (NSData *) pdfData;
@end

@interface NSDate(MFBAdditions)
+ (NSDate *) nowInUTC;
- (NSString *) utcString;
- (NSString *) dateString;
// This we keep as a class function specifically so that dt=nil can return true.
+ (BOOL) isUnknownDate:(NSDate *) dt;
- (NSDate *) dateByAddingCalendarMonths:(int) cMonths;
- (NSDate *) dateByTruncatingSeconds;
@end

@interface UITableViewCell(MFBAdditions)
- (void) makeTransparent;
@end

@interface NSString (MFBAdditions)
- (NSString *) stringByURLEncodingString;
+ (NSString *) stringFromCharsThatCouldBeNull:(char *) pch;
@end

@interface MFBWebServiceSvc_CategoryClass (MFBAdditions)
- (instancetype) initWithID:(MFBWebServiceSvc_CatClassID) ccID;
- (NSString *) localizedDescription;
- (BOOL)isEqual:(id)anObject;
@end

@interface MFBWebServiceSvc_TotalsItem (MFBAdditions)
- (SimpleTotalItem *) toSimpleItem;
+ (NSMutableArray *) toSimpleItems:(NSArray *) ar;
@end

@interface MFBWebServiceSvc_CurrencyStatusItem (MFBAdditions)
- (SimpleCurrencyItem *) toSimpleItem;
+ (NSMutableArray *) toSimpleItems:(NSArray *) ar;
@end

@interface MFBWebServiceSvc_LogbookEntry (MFBAdditions)
- (SimpleLogbookEntry *) toSimpleItem;
+ (NSMutableArray *) toSimpleItems:(NSArray *) ar;
@end

@interface NSHTTPCookieStorage (Persistence)
- (void)saveToUserDefaults;
- (void)loadFromUserDefaults;
@end
