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
//  RecentFlightCell.m
//  MFBSample
//
//  Created by Eric Berman on 1/14/12.
//

#import "RecentFlightCell.h"
#import "DecimalEdit.h"
#import "AutodetectOptions.h"
#import "FlightProps.h"

@implementation RecentFlightCell

@synthesize imgHasPics, imgSigState, lblComments, imgWidthConstraint, imgHeightConstraint, sigWidthConstraint, sigHeightConstraint;

+ (RecentFlightCell *) newRecentFlightCell:(recentRowType) rowType {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RecentFlightCell" owner:self options:nil];
    RecentFlightCell * cell;
    id firstObject = topLevelObjects[0];
    if ([firstObject isKindOfClass:[RecentFlightCell class]] )
        cell = firstObject;
    else
        cell = (RecentFlightCell *) topLevelObjects[1];
        
    if (rowType == textOnly || rowType == textAndImage)
        cell.sigWidthConstraint.constant = cell.sigHeightConstraint.constant = 0;
    if (rowType == textOnly || rowType == textAndSig)
        cell.imgWidthConstraint.constant = cell.imgHeightConstraint.constant = 0;
    
    [cell setNeedsLayout];
    [cell layoutSubviews];
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    return [super initWithStyle:style reuseIdentifier:reuseIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:label attributes:@{NSForegroundColorAttributeName : dimmedColor}];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@ ", [UITextField stringFromNumber:num forType:nt inHHMM:useHHMM]] attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor}]];
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
    
    NSTimeInterval elapsed = [dtEnd timeIntervalSinceDate:dtStart] / 3600.0;
    NSString * szInterval = (elapsed <= 0) ? @"" : [NSString stringWithFormat:@" (%@)",
                                                    [UITextField stringFromNumber:@(elapsed) forType:ntTime inHHMM:AutodetectOptions.HHMMPref]];
    
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:label attributes:@{NSForegroundColorAttributeName : dimmedColor}];
    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ - %@%@ ",
                                                                                   [dtStart utcString:AutodetectOptions.UseLocalTime],
                                                                                   [dtEnd utcString:AutodetectOptions.UseLocalTime], szInterval]
                                                                       attributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor}]];
    return attrString;
}

- (void) layoutForTable:(UITableView *) tableView {

    // Technique here from https://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights for
    // Make sure the constraints have been set up for this cell, since it
    // may have just been created from scratch. Use the following lines,
    // assuming you are setting up constraints from within the cell's
    // updateConstraints method:
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];

    // Set the width of the cell to match the width of the table view. This
    // is important so that we'll get the correct cell height for different
    // table view widths if the cell's height depends on its width (due to
    // multi-line UILabels word wrapping, etc). We don't need to do this
    // above in -[tableView:cellForRowAtIndexPath] because it happens
    // automatically when the cell is used in the table view. Also note,
    // the final width of the cell may not be the width of the table view in
    // some cases, for example when a section index is displayed along
    // the right side of the table view. You must account for the reduced
    // cell width.
    self.bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.bounds));

    // Do the layout pass on the cell, which will calculate the frames for
    // all the views based on the constraints. (Note that you must set the
    // preferredMaxLayoutWidth on multiline UILabels inside the
    // -[layoutSubviews] method of the UITableViewCell subclass, or do it
    // manually at this point before the below 2 lines!)
    
    // do it once to figure out the width for the comments...
    [self setNeedsLayout];
    [self layoutIfNeeded];

    // Now that we know the width of the comments label, set that width for height adjustment, but be a little narrow to ensure we get full height and account for padding!
    self.lblComments.preferredMaxLayoutWidth = self.lblComments.frame.size.width - 15;
    
    // Now do it again since the preferredMaxLayoutWidth is now known
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void) setFlight:(MFBWebServiceSvc_LogbookEntry *)le withImage:(id)ci errorString:(NSString *) szErr forTable:(UITableView *) tableView
{
    UIColor * textColor;
    UIColor * dimmedColor;
    UIColor * redColor;
    if (@available(iOS 13.0, *)) {
        textColor = UIColor.labelColor;
        dimmedColor = UIColor.secondaryLabelColor;
        redColor = UIColor.systemRedColor;
    } else {
        textColor = UIColor.blackColor;
        dimmedColor = UIColor.darkGrayColor;
        redColor = UIColor.redColor;
    }
    
    UIFont * baseFont = [UIFont systemFontOfSize:12];
    BOOL fUseHHMM = [AutodetectOptions HHMMPref];
    UIFont * boldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:baseFont.pointSize];
    UIFont * largeBoldFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:baseFont.pointSize * 1.3];
    UIFont * italicFont = [UIFont fontWithDescriptor:[[baseFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic | UIFontDescriptorTraitBold] size:baseFont.pointSize];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : baseFont, NSForegroundColorAttributeName : textColor}];

    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
        
    szErr = [szErr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (szErr.length != 0)
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", szErr] attributes:@{NSForegroundColorAttributeName : redColor}]];

    if (le.Date != nil) // should never happen!
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[df stringFromDate:le.Date]  attributes:@{NSFontAttributeName : largeBoldFont, NSForegroundColorAttributeName : textColor}]];

    [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", le.TailNumDisplay] attributes:@{NSFontAttributeName : largeBoldFont, NSForegroundColorAttributeName : textColor}]];
    
    MFBWebServiceSvc_Aircraft * ac = [[Aircraft sharedAircraft] AircraftByID:le.AircraftID.intValue];
    if (ac != nil && ac.ModelDescription.length > 0)
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%@)", ac.ModelDescription] attributes:@{ NSForegroundColorAttributeName : dimmedColor}]];
    
    NSString * trimmedRoute = [le.Route stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedRoute.length == 0) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", NSLocalizedString(@"(No Route)", @"No Route")] attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : dimmedColor }]];
    } else
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ", le.Route]
                                                                           attributes:@{NSFontAttributeName : italicFont, NSForegroundColorAttributeName : textColor}]];
    
    NSString * trimmedComments = [le.Comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedComments.length == 0) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"(No Comment)", @"No Comment")
                                                                           attributes:@{NSForegroundColorAttributeName : dimmedColor, NSFontAttributeName : baseFont }]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : textColor, NSFontAttributeName : baseFont }]];
    }
    else {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName : textColor, NSFontAttributeName : baseFont }]];
        [attrString appendAttributedString:[NSAttributedString attributedStringFromMarkDown:trimmedComments size:12.0]];
    }
    
    flightTimeDetail detail = AutodetectOptions.showFlightTimes;
    if (detail != flightTimeNone) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSForegroundColorAttributeName : textColor}]];
        
        // Add various values
        [attrString appendAttributedString:[self attributedLabel:NSLocalizedString(@"fieldTotal", @"Entry Field: Total") forValue:le.TotalFlightTime withFont:boldFont inHHMM:fUseHHMM numType:ntTime]];

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
        
        if (detail == flightTimeDetailed) {
            MFBWebServiceSvc_CustomFlightProperty * blockOut = [le getExistingProperty:@(PropTypeID_BlockOut)];
            MFBWebServiceSvc_CustomFlightProperty * blockIn = [le getExistingProperty:@(PropTypeID_BlockIn)];
            
            if (blockIn != nil && blockOut != nil)
                [attrString appendAttributedString:[self attributedUTCDateRange:NSLocalizedString(@"Block Time", @"Auto-fill total based on block time") start:blockOut.DateValue end:blockIn.DateValue withFont:baseFont]];
            
            [attrString appendAttributedString:[self attributedUTCDateRange:NSLocalizedString(@"Engine Time", @"Auto-fill based on engine time") start:le.EngineStart end:le.EngineEnd withFont:baseFont]];
            [attrString appendAttributedString:[self attributedUTCDateRange:NSLocalizedString(@"Flight Time", @"Auto-fill based on time in the air") start:le.FlightStart end:le.FlightEnd withFont:baseFont]];
            NSAttributedString * spacer = [[NSAttributedString alloc] initWithString:@" "];
            
            for (MFBWebServiceSvc_CustomFlightProperty * fp in le.CustomProperties.CustomFlightProperty) {
                if (fp.PropTypeID.intValue == PropTypeID_BlockIn || fp.PropTypeID.intValue == PropTypeID_BlockOut)
                    continue;
                [attrString appendAttributedString:[fp formatForDisplay:dimmedColor :textColor :baseFont :boldFont]];
                [attrString appendAttributedString:spacer];
            }
        }
    }
    
    self.lblComments.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblComments.numberOfLines = 0;
    self.lblComments.attributedText = attrString;

    if (AutodetectOptions.showFlightImages) {
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
    
    [self layoutForTable:tableView];
}
@end
