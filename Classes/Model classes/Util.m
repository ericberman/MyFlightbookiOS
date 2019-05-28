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
//  Util.m
//  MFBSample
//
//  Created by Eric Berman on 3/6/13.
//
//

#import "Util.h"
#import "MFBAppDelegate.h"
#import "DecimalEdit.h"
#import "TotalsCategories.h"
#import <QuartzCore/QuartzCore.h>
#import "MFBTheme.h"

@implementation UIViewController(MFBAdditions)
- (void) showAlertWithTitle:(NSString *) title message:(NSString *) msg {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"Close button on error message") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) showErrorAlertWithMessage:(NSString *) msg {
    [self showAlertWithTitle:NSLocalizedString(@"Error", @"Title for generic error message") message:msg];
}

- (void) pushOrPopView:(UIViewController *) target fromView:(id) sender withDelegate:(id<UIPopoverPresentationControllerDelegate>) delegate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        target.modalPresentationStyle = UIModalPresentationPopover;
        target.navigationController.navigationBarHidden = NO;
        UIPopoverPresentationController * ppc = target.popoverPresentationController;
        ppc.sourceView = self.view;
        if ([sender isKindOfClass:[UIView class]]) {
            ppc.sourceRect = ((UIView *) sender).bounds;
            ppc.sourceView = sender;
        }
        else if ([sender isKindOfClass:[UIBarButtonItem class]])
            ppc.barButtonItem = sender;
        ppc.permittedArrowDirections = UIPopoverArrowDirectionAny;
        ppc.delegate = delegate;
        [self presentViewController:target animated:YES completion:^{}];
    } else
        [self.navigationController pushViewController:target animated:YES];
}
@end

@implementation NSAttributedString(MFBAdditions)
+ (NSAttributedString *) attributedStringFromMarkDown:(NSString *) sz {
    NSError * error = nil;
    NSRegularExpression * reg = [[NSRegularExpression alloc] initWithPattern:@"(\\*[^*_\r\n]*\\*)|(_[^*_\r\n]*_)" options:NSRegularExpressionCaseInsensitive error:&error];
    UIFont * baseFont = [UIFont systemFontOfSize:12];
    UIFont * boldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:baseFont.pointSize];
    UIFont * italicFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic] size:baseFont.pointSize];

    __block NSUInteger lastPos = 0;
    UIColor * textColor = MFBTheme.currentTheme.labelForeColor;
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : textColor}];
    [reg enumerateMatchesInString:sz options:0 range:NSMakeRange(0, sz.length) usingBlock:^(NSTextCheckingResult * _Nullable match, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange matchRange = match.range;
        if (matchRange.location > lastPos)
            [attr appendAttributedString:[[NSAttributedString alloc] initWithString:[sz substringWithRange:NSMakeRange(lastPos, matchRange.location - lastPos)] attributes:@{NSForegroundColorAttributeName : textColor}]];
        
        if (matchRange.length >= 2 && sz.length >= matchRange.location + matchRange.length) {  // should always be!!!
            NSString * matchText = [sz substringWithRange:matchRange];
            NSString * matchType = [matchText substringToIndex:1];
            NSString * matchContent = [matchText substringWithRange:NSMakeRange(1, matchText.length - 2)];
            if ([matchType compare:@"*"] == NSOrderedSame)
                [attr appendAttributedString:[[NSAttributedString alloc] initWithString:matchContent
                                                                                   attributes:@{NSFontAttributeName : boldFont, NSForegroundColorAttributeName : textColor}]];
            else if ([matchType compare:@"_"] == NSOrderedSame)
                [attr appendAttributedString:[[NSAttributedString alloc] initWithString:matchContent
                                                                             attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : textColor}]];
            lastPos = matchRange.location + matchRange.length;
        }
    }];
    
    if (lastPos < sz.length)
        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:[sz substringWithRange:NSMakeRange(lastPos, sz.length - lastPos)] attributes:@{NSForegroundColorAttributeName : textColor}]];

     return attr;
}
@end

@implementation NSDate(MFBAdditions)

#pragma mark Date handling
+ (NSDate *) nowInUTC
{
	return [NSDate date];
}

- (NSString *) utcString
{
    BOOL fSuppressUTC = [AutodetectOptions UseLocalTime];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    if (fSuppressUTC)
    {
        NSTimeZone * tzCurrent = [NSTimeZone localTimeZone];
        [df setDateStyle:NSDateFormatterShortStyle];
        [df setTimeStyle:NSDateFormatterShortStyle];
        return [NSString stringWithFormat:@"%@ (%@)", [df stringFromDate:self], [tzCurrent abbreviation]];
    }
    else
    {
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        return [NSString stringWithFormat:@"%@ (UTC)", [df stringFromDate:self]];
    }
}

- (NSString *) dateString
{
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    return [df stringFromDate:self];
}

+ (BOOL) isUnknownDate:(NSDate *) dt
{
    if (dt == nil)
        return YES;

	NSDate * dtOld = [NSDate distantPast];
    
	// ASPX and Cocoa have different definitions for distantPast.  ASP.NET uses a year of 0001, so let's test for that.
	NSCalendar * cal = [NSCalendar currentCalendar];
	NSDateComponents * comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:dt];
	
	return ([dt compare:dtOld] == NSOrderedSame || [comps year] == 1);
}

- (NSDate *) dateByAddingCalendarMonths:(int) cMonths
{
    NSCalendar * cal = [NSCalendar currentCalendar];
	NSDateComponents * comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSDateComponents * compsDelta = [[NSDateComponents alloc] init];

    // go to the first day of this month
    [comps setDay:1];
    NSDate * dt = [cal dateFromComponents:comps];
    
    if (cMonths >= 0)
    {
        // going forward - we want the last day of the month so we go to the first day of 1 month beyond what we want,
        // then back up a day
        [compsDelta setMonth:cMonths + 1];
        dt = [cal dateByAddingComponents:compsDelta toDate:dt options:0];
        [compsDelta setMonth:0];
        [compsDelta setDay:-1];
        return [cal dateByAddingComponents:compsDelta toDate:dt options:0];
    }
    else
    {
        [compsDelta setMonth:cMonths];
        return [cal dateByAddingComponents:compsDelta toDate:dt options:0];
    }
}

- (NSDate *) dateByTruncatingSeconds {
    NSTimeInterval time = floor([self timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    return [NSDate dateWithTimeIntervalSinceReferenceDate:time];
}
@end

@implementation UITableViewController(MFBAdditions)
- (NSIndexPath *) nextCell:(NSIndexPath *) ipCurrent
{
    NSInteger cSections = [self numberOfSectionsInTableView:self.tableView];
    NSInteger cRowsInSection = [self tableView:self.tableView numberOfRowsInSection:ipCurrent.section];
    
    // check for last cell
    if (ipCurrent.section >= cSections - 1 && ipCurrent.row >= cRowsInSection - 1)
        return ipCurrent;
    
    if (ipCurrent.row < cRowsInSection - 1)
        return [NSIndexPath indexPathForRow:ipCurrent.row + 1 inSection:ipCurrent.section];
    else
    {
        NSInteger sect = ipCurrent.section;
        while (++sect < cSections && [self tableView:self.tableView numberOfRowsInSection:sect] == 0);
        return (sect < cSections) ? [NSIndexPath indexPathForRow:0 inSection:ipCurrent.section + 1] : ipCurrent;
    }
}

- (NSIndexPath *) prevCell:(NSIndexPath *) ipCurrent
{
    // check for 1st cell
    if (ipCurrent.section == 0 && ipCurrent.row == 0)
        return ipCurrent;
    
    if (ipCurrent.row > 0)
        return [NSIndexPath indexPathForRow:ipCurrent.row - 1 inSection:ipCurrent.section];
    else
    {
        NSInteger sect = ipCurrent.section;
        while (--sect >= 0 && [self tableView:self.tableView numberOfRowsInSection:sect] == 0);
        return (sect < 0) ? ipCurrent: [NSIndexPath indexPathForRow:[self tableView:self.tableView numberOfRowsInSection:sect] - 1 inSection:sect];
    }
    
}

// Thanks to http://stackoverflow.com/questions/13795141/print-all-rows-of-a-table-view-when-its-too-large-to-fit-on-screen
// for advice on how to render the tableview into a PDF stream.
// I'll keep this as an "if needed", but it looks pretty crappy when actually printed.
// Far better to print from the webview.
- (NSData *) pdfData
{
    CGRect priorBounds = self.tableView.bounds;
    CGSize fittedSize = [self.tableView sizeThatFits:CGSizeMake(priorBounds.size.width, HUGE_VALF)];
    self.tableView.bounds = CGRectMake(0, 0, fittedSize.width, fittedSize.height);
    
    // Standard US Letter dimensions 8.5" x 11"
    CGRect pdfPageBounds = CGRectMake(0, 0, 612, 792);
    
    NSMutableData *pdfData = [[NSMutableData alloc] init];
    UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil); {
        for (CGFloat pageOriginY = 0; pageOriginY < fittedSize.height; pageOriginY += pdfPageBounds.size.height) {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil);
            CGContextSaveGState(UIGraphicsGetCurrentContext()); {
                CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -pageOriginY);
                [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
            } CGContextRestoreGState(UIGraphicsGetCurrentContext());
        }
    } UIGraphicsEndPDFContext();
    self.tableView.bounds = priorBounds;
    return pdfData;
}
@end

@implementation UITableViewCell(MFBAdditions)
- (void) makeTransparent
{
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    self.selectionStyle = UITableViewCellSelectionStyleNone;    
}
@end

@implementation NSString (MFBAdditions)
- (NSString *) stringByURLEncodingString
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"!*'() ;:@%=+$,/?%#[]&^"] invertedSet]];
}

+ (NSString *) stringFromCharsThatCouldBeNull:(char *) pch
{
    return (pch == NULL) ? @"" : @(pch);
}
@end

@implementation MFBWebServiceSvc_CategoryClass (MFBAdditions)
- (instancetype) initWithID:(MFBWebServiceSvc_CatClassID) ccID
{
    if (self = [super init])
    {
        self.IdCatClass = ccID;
    }
    return self;
}

- (NSString *) localizedDescription
{
    switch (self.IdCatClass) {
        default:
        case MFBWebServiceSvc_CatClassID_none:
            return NSLocalizedString(@"ccAny", @"Any category-class");
        case MFBWebServiceSvc_CatClassID_ASEL:
            return NSLocalizedString(@"ccASEL", @"ASEL");
        case MFBWebServiceSvc_CatClassID_AMEL:
            return NSLocalizedString(@"ccAMEL", @"AMEL");
        case MFBWebServiceSvc_CatClassID_ASES:
            return NSLocalizedString(@"ccASES", @"ASES");
        case MFBWebServiceSvc_CatClassID_AMES:
            return NSLocalizedString(@"ccAMES", @"AMES");
        case MFBWebServiceSvc_CatClassID_Glider:
            return NSLocalizedString(@"ccGlider", @"Glider");
        case MFBWebServiceSvc_CatClassID_Helicopter:
            return NSLocalizedString(@"ccHelicopter", @"Helicopter");
        case MFBWebServiceSvc_CatClassID_Gyroplane:
            return NSLocalizedString(@"ccGyroplane", @"Gyroplane");
        case MFBWebServiceSvc_CatClassID_PoweredLift:
            return NSLocalizedString(@"ccPoweredLift", @"Powered Lift");
        case MFBWebServiceSvc_CatClassID_Airship:
            return NSLocalizedString(@"ccAirship", @"Airship");
        case MFBWebServiceSvc_CatClassID_HotAirBalloon:
            return NSLocalizedString(@"ccHotAirBalloon", @"Hot Air Balloon");
        case MFBWebServiceSvc_CatClassID_GasBalloon:
            return NSLocalizedString(@"ccGasBalloon", @"Gas Balloon");
        case MFBWebServiceSvc_CatClassID_PoweredParachuteLand:
            return NSLocalizedString(@"ccPoweredParachuteLand", @"Powered Parachute Land");
        case MFBWebServiceSvc_CatClassID_PoweredParachuteSea:
            return NSLocalizedString(@"ccPoweredParachuteSea", @"Powered Parachute Sea");
        case MFBWebServiceSvc_CatClassID_WeightShiftControlLand:
            return NSLocalizedString(@"ccWeightShiftControlLand", @"WeightShiftControlLand");
        case MFBWebServiceSvc_CatClassID_WeightShiftControlSea:
            return NSLocalizedString(@"ccWeightShiftControlSea", @"WeightShiftControlSea");
        case MFBWebServiceSvc_CatClassID_UnmannedAerialSystem:
            return NSLocalizedString(@"ccUAS", @"UAS");
        case MFBWebServiceSvc_CatClassID_PoweredParaglider:
            return NSLocalizedString(@"ccPoweredParaglider", @"Powered Paraglider");
    }
    return self.description;
}

- (BOOL)isEqual:(id)anObject
{
    return (anObject != nil) && [anObject isKindOfClass:[MFBWebServiceSvc_CategoryClass class]] && self.IdCatClass == ((MFBWebServiceSvc_CategoryClass *) anObject).IdCatClass;
}
@end

@implementation MFBWebServiceSvc_TotalsItem (MFBAdditions)
- (SimpleTotalItem *) toSimpleItem {
    SimpleTotalItem * sti = [SimpleTotalItem new];
    sti.title = self.Description;
    sti.subDesc = self.SubDescription;
    sti.valueDisplay = [self formattedValue:[AutodetectOptions HHMMPref]];
    return sti;
}

+ (NSMutableArray *) toSimpleItems:(NSArray *) ar
{
    NSMutableArray * rgNew = [NSMutableArray new];
    for (MFBWebServiceSvc_TotalsItem * csi in ar)
        [rgNew addObject:[csi toSimpleItem]];
    return rgNew;
}
@end

@implementation MFBWebServiceSvc_CurrencyStatusItem (MFBAdditions)
- (SimpleCurrencyItem *) toSimpleItem {
    SimpleCurrencyItem * sci = [SimpleCurrencyItem new];
    sci.attribute = self.Attribute;
    sci.value = self.Value;
    sci.discrepancy = self.Discrepancy;
    sci.state = self.Status;
    return sci;
}

+ (NSMutableArray *) toSimpleItems:(NSArray *) ar
{
    NSMutableArray * rgNew = [NSMutableArray new];
    for (MFBWebServiceSvc_CurrencyStatusItem * csi in ar)
        [rgNew addObject:csi.toSimpleItem];
    return rgNew;
}
@end

@implementation MFBWebServiceSvc_LogbookEntry (MFBAdditions)
- (SimpleLogbookEntry *) toSimpleItem {
    SimpleLogbookEntry * sle = [SimpleLogbookEntry new];
    sle.Comment = self.Comment;
    sle.Route = self.Route;
    sle.Date = self.Date;
    sle.TotalTimeDisplay = [UITextField stringFromNumber:self.TotalFlightTime forType:ntTime inHHMM:[AutodetectOptions HHMMPref]];
    sle.TailNumDisplay = self.TailNumDisplay;
    return sle;
}

+ (NSMutableArray *) toSimpleItems:(NSArray *) ar  {
    NSMutableArray * rgNew = [NSMutableArray new];
    for (MFBWebServiceSvc_LogbookEntry * le in ar)
        [rgNew addObject:le.toSimpleItem];
    return rgNew;
}
@end


// From http://stackoverflow.com/questions/26005641/are-cookies-in-uiwebview-accepted for cookie storage.
#define kCookiesKey @"cookies"

@implementation NSHTTPCookieStorage (Persistence)

- (void)saveToUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.cookies != nil && self.cookies.count > 0) {
        NSData *cookieData = [NSKeyedArchiver archivedDataWithRootObject:self.cookies];
        [userDefaults setObject:cookieData forKey:kCookiesKey];
    } else {
        [userDefaults removeObjectForKey:kCookiesKey];
    }
    [userDefaults synchronize];
}

- (void)loadFromUserDefaults
{
    NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:kCookiesKey];
    if (cookieData != nil) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookieData];
        for (NSHTTPCookie *cookie in cookies) {
            [self setCookie:cookie];
        }
    }
}

@end
