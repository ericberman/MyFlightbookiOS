/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2019 MyFlightbook, LLC
 
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
//  RecentFlightCell.m
//  MFBSample
//
//  Created by Eric Berman on 1/14/12.
//  Copyright (c) 2012-2018 MyFlightbook LLC. All rights reserved.
//

#import "RecentFlightCell.h"
#import "DecimalEdit.h"
#import "AutodetectOptions.h"
#import "Util.h"

@implementation RecentFlightCell

@synthesize imgHasPics, imgSigState, lblComments;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#define MARGIN 3.0

- (void) layoutSubviews
{
    [super layoutSubviews];
    CGRect f = self.contentView.frame;
    // x, y, width, height
    CGFloat dxWidth = f.size.height * 1.2;
    CGFloat dxHeight = f.size.height;
    
    BOOL fShowImages = [AutodetectOptions showFlightImages];
    
    self.imgHasPics.hidden = !fShowImages;
    
    if (!fShowImages)
        dxWidth = MARGIN;

    CGRect rImage = CGRectMake(MARGIN, 1.0, dxWidth - 2 * MARGIN, dxHeight - 1.0);
    self.imgHasPics.frame = rImage;
    self.imgHasPics.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat imageWidth =  fShowImages ? self.imgHasPics.frame.size.width : 0;
    
    CGFloat xLabels = rImage.origin.x + imageWidth + MARGIN;
    CGFloat dxSig =  (self.imgSigState.hidden ? 0 : self.imgSigState.frame.size.width);
    
    CGRect rComments = CGRectMake(xLabels, self.lblComments.frame.origin.y, f.size.width - xLabels -2 * MARGIN - dxSig, (dxHeight - MARGIN - self.lblComments.frame.origin.y));
    self.lblComments.frame = rComments;
    
    // remove margins/padding.
    [self.lblComments setTextContainerInset:UIEdgeInsetsZero];
    self.lblComments.textContainer.lineFragmentPadding = 0; // to remove left padding
}

- (NSAttributedString *) attributedLabel:(NSString *) label forValue:(NSNumber *) num withFont:(UIFont *) font inHHMM:(BOOL) useHHMM numType:(int) nt
{
    UIColor * textColor;;
    UIColor * dimmedColor;
    if (@available(iOS 13.0, *)) {
        textColor = UIColor.labelColor;
        dimmedColor = UIColor.secondaryLabelColor;
    } else {
        textColor = UIColor.blackColor;
        dimmedColor = UIColor.darkGrayColor;
    }

    if (num == nil || num.doubleValue == 0)
        return [[NSAttributedString alloc] init];
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:label attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor}];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@ ", [UITextField stringFromNumber:num forType:nt inHHMM:useHHMM]] attributes:@{NSForegroundColorAttributeName : dimmedColor}]];
    return attrString;
}

- (NSAttributedString *) attributedUTCDateRange:(NSString *) label start:(NSDate *) dtStart end:(NSDate *) dtEnd withFont:(UIFont *) font
{
    UIColor * textColor;;
    UIColor * dimmedColor;
    if (@available(iOS 13.0, *)) {
        textColor = UIColor.labelColor;
        dimmedColor = UIColor.secondaryLabelColor;
    } else {
        textColor = UIColor.blackColor;
        dimmedColor = UIColor.darkGrayColor;
    }

    if ([NSDate isUnknownDate:dtStart] || [NSDate isUnknownDate:dtEnd])
        return [[NSAttributedString alloc] init];
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:label attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor}];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ - %@ ", dtStart.utcString, dtEnd.utcString] attributes:@{NSForegroundColorAttributeName : dimmedColor}]];
    return attrString;
}

- (void) setFlight:(MFBWebServiceSvc_LogbookEntry *)le withImage:(id)ci withError:(NSString *) szErr
{
    UIColor * textColor;;
    UIColor * dimmedColor;
    if (@available(iOS 13.0, *)) {
        textColor = UIColor.labelColor;
        dimmedColor = UIColor.secondaryLabelColor;
    } else {
        textColor = UIColor.blackColor;
        dimmedColor = UIColor.darkGrayColor;
    }
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : textColor}];
    UIFont * baseFont = [UIFont systemFontOfSize:12];
    BOOL fUseHHMM = [AutodetectOptions HHMMPref];
    UIFont * boldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:baseFont.pointSize];
    UIFont * largeBoldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:baseFont.pointSize * 1.3];
    UIFont * italicFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic | UIFontDescriptorTraitBold] size:baseFont.pointSize];
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    
    szErr = [szErr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (szErr.length != 0)
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", szErr] attributes:@{NSForegroundColorAttributeName : [UIColor redColor]}]];

    if (le.Date != nil) // should never happen!
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[df stringFromDate:le.Date]  attributes:@{NSFontAttributeName : largeBoldFont, NSForegroundColorAttributeName : textColor}]];

    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", le.TailNumDisplay] attributes:@{NSFontAttributeName : largeBoldFont, NSForegroundColorAttributeName : textColor}]];
    
    MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] AircraftByID:le.AircraftID.intValue];
    if (ac != nil && ac.ModelDescription.length > 0)
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", ac.ModelDescription] attributes:@{ NSForegroundColorAttributeName : textColor}]];
    
    NSString * trimmedRoute = [le.Route stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedRoute.length == 0) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", NSLocalizedString(@"(No Route)", @"No Route")] attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : dimmedColor }]];
    } else
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", le.Route]
                                                                           attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : dimmedColor}]];
    NSString * trimmedComments = [le.Comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedComments.length == 0) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"(No Comment)", @"No Comment")
                                                                           attributes:@{NSForegroundColorAttributeName : dimmedColor }]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : textColor}]];
    }
    else
        [attrString appendAttributedString:[NSAttributedString attributedStringFromMarkDown:trimmedComments size:12.0]];
    
    flightTimeDetail detail = AutodetectOptions.showFlightTimes;
    if (detail != flightTimeNone) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName : textColor}]];
        
        // Add various values
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldLandings", @"Entry Field: Landings") forValue:le.Landings withFont:boldFont inHHMM:fUseHHMM numType:ntInteger]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldApproaches", @"Entry Field: Approaches") forValue:le.Approaches withFont:boldFont inHHMM:fUseHHMM numType:ntInteger]];
        
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldNight", @"Entry Field: Night") forValue:le.Nighttime withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldSimIMC", @"Entry Field: Simulated IMC") forValue:le.SimulatedIFR withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldIMC", @"Entry Field: Actual IMC") forValue:le.IMC withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldXC", @"Entry Field: XC") forValue:le.CrossCountry withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldDual", @"Entry Field: Dual") forValue:le.Dual withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldGround", @"Entry Field: Ground Sim") forValue:le.GroundSim withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldCFI", @"Entry Field: CFI") forValue:le.CFI withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldSIC", @"Entry Field: SIC") forValue:le.SIC withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldPIC", @"Entry Field: PIC") forValue:le.PIC withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldTotal", @"Entry Field: Total") forValue:le.TotalFlightTime withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];
        
        if (detail == flightTimeDetailed) {
            [attrString appendAttributedString:[self attributedUTCDateRange:NSLocalizedString(@"Engine Time", @"Auto-fill based on engine time") start:le.EngineStart end:le.EngineEnd withFont:boldFont]];
            [attrString appendAttributedString:[self attributedUTCDateRange:NSLocalizedString(@"Flight Time", @"Auto-fill based on time in the air") start:le.FlightStart end:le.FlightEnd withFont:boldFont]];
        }
    }
    
    self.lblComments.attributedText = attrString;
    
    if ([AutodetectOptions showFlightImages]) {
        self.imgHasPics.image = le.FlightImages.MFBImageInfo.count > 0 ? nil : [UIImage imageNamed:@"noimage"];
        
        if (ci != nil && [ci hasThumbnailCache])
            self.imgHasPics.image = [ci GetThumbnail];
    }
    
    self.imgSigState.hidden = (le.CFISignatureState == MFBWebServiceSvc_SignatureState_None);
    if (le.CFISignatureState == MFBWebServiceSvc_SignatureState_Valid)
        self.imgSigState.image = [UIImage imageNamed:@"sigok"];
    else if (le.CFISignatureState == MFBWebServiceSvc_SignatureState_Invalid)
        self.imgSigState.image = [UIImage imageNamed:@"siginvalid"];
    else
        self.imgSigState.image = nil;
}
@end
