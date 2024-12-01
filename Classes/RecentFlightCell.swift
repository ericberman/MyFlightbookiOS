/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2024 MyFlightbook, LLC
 
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
//  RecentFlightCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/9/23.
//

import Foundation

public enum recentFlightRowType : Int {
     case textOnly = 0, textAndSig, textAndImage, textSigAndImage
}

public class RecentFlightCell : UITableViewCell {
    @IBOutlet weak var imgHasPics : UIImageView!
    @IBOutlet weak var imgSigState : UIImageView!
    @IBOutlet weak var lblComments : UILabel!
    @IBOutlet weak var imgWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var imgHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var sigWidthConstraint : NSLayoutConstraint!
    @IBOutlet weak var sigHeightConstraint : NSLayoutConstraint!
    
    
    public static func newRecentFlightCell(rowType: recentFlightRowType) -> RecentFlightCell {
        var cell : RecentFlightCell!
        let topLevelObjects = Bundle.main.loadNibNamed("RecentFlightCell", owner: nil)!
        let firstObject = topLevelObjects[0]
        if let rc = firstObject as? RecentFlightCell {
            cell = rc
        } else {
            cell = topLevelObjects[1] as? RecentFlightCell
        }
        
        if rowType == .textOnly || rowType == .textAndImage {
            cell.sigWidthConstraint.constant = 0
            cell.sigHeightConstraint.constant = 0
        }
        if rowType == .textOnly || rowType == .textAndSig {
            cell.imgWidthConstraint.constant = 0
            cell.imgHeightConstraint.constant = 0
        }
        
        cell.setNeedsLayout()
        cell.layoutSubviews()
        
        return cell
    }
    
    func attributedLabel(_ label : String, value num : NSNumber?, font : UIFont, inHHMM useHHMM : Bool, numType nt : NumericType) -> AttributedString {
        let textColor = UIColor.label
        let dimmedColor = UIColor.secondaryLabel
        
        if (num?.doubleValue ?? 0.0) != 0.0 {
            var attrString = AttributedString("\(label): ", attributes: AttributeContainer([.font : font, .foregroundColor : dimmedColor]))
            attrString.append(AttributedString("\(num!.formatAs(Type: nt, inHHMM: useHHMM, useGrouping: true)) ", attributes: AttributeContainer([.font : font, .foregroundColor : textColor])))
            return attrString
        } else {
            return AttributedString()
        }
    }
    
    func attributedUTCDateRange(_ label : String, start dtStart : Date?, end dtEnd : Date?, font : UIFont) -> AttributedString {
        let textColor = UIColor.label
        let dimmedColor = UIColor.secondaryLabel
        
        if NSDate.isUnknownDate(dt: dtStart) || NSDate.isUnknownDate(dt: dtEnd) {
            return AttributedString()
        } else {
            
            let elapsed = dtEnd!.timeIntervalSince(dtStart!) / 3600.0;
            let szInterval = (elapsed <= 0) ? "" : " (\(NSNumber(floatLiteral: elapsed).formatAs(Type: .Time, inHHMM: UserPreferences.current.HHMMPref, useGrouping : false)))"
            
            var attrString = AttributedString(label, attributes: AttributeContainer([.font : font, .foregroundColor : dimmedColor]))
            attrString.append(AttributedString(" \(dtStart!.utcString(useLocalTime: UserPreferences.current.UseLocalTime)) - \(dtEnd!.utcString(useLocalTime: UserPreferences.current.UseLocalTime))\(szInterval) ",
                                               attributes: AttributeContainer([.font : font, .foregroundColor : textColor])))
            return attrString;
        }
    }
    
    func layoutForTable(_ tableView : UITableView) {
        // Technique here from https://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-variable-row-heights for
        // Make sure the constraints have been set up for this cell, since it
        // may have just been created from scratch. Use the following lines,
        // assuming you are setting up constraints from within the cell's
        // updateConstraints method:
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
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
        bounds = CGRectMake(0.0, 0.0, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.bounds))
        
        // Do the layout pass on the cell, which will calculate the frames for
        // all the views based on the constraints. (Note that you must set the
        // preferredMaxLayoutWidth on multiline UILabels inside the
        // -[layoutSubviews] method of the UITableViewCell subclass, or do it
        // manually at this point before the below 2 lines!)
        
        // do it once to figure out the width for the comments...
        setNeedsLayout()
        layoutIfNeeded()
        
        // Now that we know the width of the comments label, set that width for height adjustment, but be a little narrow to ensure we get full height and account for padding!
        lblComments.preferredMaxLayoutWidth = lblComments.frame.size.width - 15
        
        // Now do it again since the preferredMaxLayoutWidth is now known
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    public func setFlight(_ le : MFBWebServiceSvc_LogbookEntry, image ci : CommentedImage?, errorString : String?, tableView : UITableView, isColored : Bool) {
        if isColored {
            self.overrideUserInterfaceStyle = .light
        }
        let textColor = UIColor.label
        let dimmedColor = UIColor.secondaryLabel
        let redColor = UIColor.systemRed
        
        let baseFont = UIFont.preferredFont(forTextStyle: .caption1)
        let fUseHHMM = UserPreferences.current.HHMMPref
        let boldFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: baseFont.pointSize)
        let largeBoldFont = UIFont.preferredFont(forTextStyle: .headline)
        let italicFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits([.traitItalic, .traitBold])!, size: baseFont.pointSize)
        
        var attrString = AttributedString("", attributes: AttributeContainer([.font : baseFont, .foregroundColor : textColor]))
        
        let df = DateFormatter()
        df.dateStyle = .short
        
        let szErr = (errorString ?? "").trimmingCharacters(in: .whitespaces)
        if !szErr.isEmpty {
            attrString.append(AttributedString("\(szErr)\n", attributes: AttributeContainer([.foregroundColor : redColor])))
        }
        
        attrString.append(AttributedString(df.string(from: le.date), attributes: AttributeContainer([.font : largeBoldFont, .foregroundColor : textColor])))

        // Issue #326, #330 - show flight number early
        let flightnum = le.getExistingProperty(.flightNum)
        attrString.append(AttributedString(" \(flightnum?.textValue ?? "")", attributes: AttributeContainer([.font : largeBoldFont, .foregroundColor : textColor])))

        let ac = Aircraft.sharedAircraft.AircraftByID(le.aircraftID.intValue)
        let modelDesc = "(\(ac?.modelDescription ?? ""))"
        // Issue #330 - clean up redundancies - only show the tail number if it is distinct from the model description
        // Issue #339 - le.tailNumDisplay can be null when offline.
        let tailDisplay = le.tailNumDisplay ?? ac?.displayTailNumber ?? ""
        if (modelDesc.compare(tailDisplay) != .orderedSame) {
            attrString.append(AttributedString(" \(tailDisplay)", attributes: AttributeContainer([.font : largeBoldFont, .foregroundColor : textColor])))
        }

        if !(ac?.modelDescription ?? "").isEmpty {
            attrString.append(AttributedString(" \(modelDesc)", attributes: AttributeContainer([.font : baseFont, .foregroundColor : dimmedColor])))
        }
        
        let trimmedRoute = le.route.trimmingCharacters(in: .whitespaces)
        if trimmedRoute.isEmpty {
            attrString.append(AttributedString(" \(String(localized: "(No Route)", comment: "No Route"))", attributes: AttributeContainer([.font : italicFont, .foregroundColor : dimmedColor])))
        } else {
            attrString.append(AttributedString(" \(trimmedRoute)", attributes: AttributeContainer([.font : italicFont, .foregroundColor : textColor])))
        }
        
        let trimmedComments = le.comment?.trimmingCharacters(in: .whitespaces) ?? ""
        if trimmedComments.isEmpty {
            attrString.append(AttributedString(" \(String(localized: "(No Comment)", comment: "No Comment"))", attributes: AttributeContainer([.font : baseFont, .foregroundColor : dimmedColor])))
            attrString.append(AttributedString("", attributes: AttributeContainer([.font : baseFont, .foregroundColor : textColor])))
        } else {
            attrString.append(AttributedString(" ", attributes: AttributeContainer([.font : baseFont, .foregroundColor : textColor])))
            attrString.append(AttributedString(NSAttributedString.attributedStringFromMarkDown(sz: trimmedComments as NSString, size: baseFont.pointSize)))
        }
        
        let detail = UserPreferences.current.showFlightTimes
        if detail != .none {
            attrString.append(AttributedString("\n", attributes: AttributeContainer([.foregroundColor : textColor])))
            
            // Add various values
            attrString.append(attributedLabel(String(localized: "fieldTotal", comment: "Entry Field: Total"), value: le.totalFlightTime, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            
            attrString.append(attributedLabel(String(localized: "fieldLandings", comment: "Entry Field: Landings"), value: le.landings, font: boldFont, inHHMM: false, numType : .Integer))
            attrString.append(attributedLabel(String(localized: "fieldApproaches", comment: "Entry Field: Approaches"), value: le.approaches, font: boldFont, inHHMM: false, numType : .Integer))
            
            attrString.append(attributedLabel(String(localized: "fieldNight", comment: "Entry Field: Night"), value: le.nighttime, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldSimIMC", comment: "Entry Field: Simulated IMC"), value: le.simulatedIFR, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldIMC", comment: "Entry Field: Actual IMC"), value: le.imc, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldXC", comment: "Entry Field: XC"), value: le.crossCountry, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldDual", comment: "Entry Field: Dual"), value: le.dual, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldGround", comment: "Entry Field: Ground Sim"), value: le.groundSim, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldCFI", comment: "Entry Field: CFI"), value: le.cfi, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldSIC", comment: "Entry Field: SIC"), value: le.sic, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            attrString.append(attributedLabel(String(localized: "fieldPIC", comment: "Entry Field: PIC"), value: le.pic, font: boldFont, inHHMM: fUseHHMM, numType : .Time))
            
            if detail == .detailed {
                if (le.hobbsStart.doubleValue > 0 && le.hobbsEnd.doubleValue > le.hobbsStart.doubleValue) {
                    attrString.append(AttributedString("\(String(localized: "Hobbs", comment: "Elapsed Hobbs Label")): ", attributes: AttributeContainer([.font : baseFont, .foregroundColor : dimmedColor])))

                    let elapsed = NSNumber(value: le.hobbsEnd.doubleValue - le.hobbsStart.doubleValue)
                    let elapsedString = "\(le.hobbsStart!.formatAs(Type: .Decimal, inHHMM: false, useGrouping: true)) - \(le.hobbsEnd!.formatAs(Type: .Decimal, inHHMM: false, useGrouping: true)) (\(elapsed.formatAs(Type: .Decimal, inHHMM: false, useGrouping: true))) "
                    attrString.append(AttributedString(elapsedString, attributes: AttributeContainer([.font : boldFont, .foregroundColor : textColor])))
                } else {
                    attrString.append(attributedLabel(String(localized: "Hobbs Start", comment: "Hobbs Start Label"), value: le.hobbsStart, font: boldFont, inHHMM: false, numType: .Decimal))
                    attrString.append(attributedLabel(String(localized: "Hobbs End", comment: "Hobbs End Label"), value: le.hobbsEnd, font: boldFont, inHHMM: false, numType: .Decimal))
                }
                
                let blockOut = le.getExistingProperty(.blockOut)
                let blockIn = le.getExistingProperty(.blockIn)
                
                if blockIn?.dateValue != nil && blockOut?.dateValue != nil {
                    attrString.append(attributedUTCDateRange(String(localized: "Block Time", comment: "Auto-fill total based on block time"), start: blockOut!.dateValue, end: blockIn!.dateValue, font: baseFont))
                }
                
                attrString.append(attributedUTCDateRange(String(localized: "Engine Time", comment: "Auto-fill based on engine time"), start: le.engineStart, end: le.engineEnd, font: baseFont))
                attrString.append(attributedUTCDateRange(String(localized: "Flight Time", comment: "Auto-fill based on time in the air"), start: le.flightStart, end: le.flightEnd, font: baseFont))
                
                let spacer = AttributedString(" ")
                
                for cfp in le.customProperties.customFlightProperty {
                    let fp = cfp as! MFBWebServiceSvc_CustomFlightProperty
                    if fp.propTypeID.intValue == PropTypeID.blockIn.rawValue || fp.propTypeID.intValue == PropTypeID.blockOut.rawValue || fp.propTypeID.intValue == PropTypeID.flightNum.rawValue {
                        continue
                    }
                    attrString.append(fp.formatForDisplay(dimmedColor, valueColor: textColor, labelFont: baseFont, valueFont: boldFont))
                    attrString.append(spacer)
                }
            }
        }
        
        lblComments.lineBreakMode = .byWordWrapping
        lblComments.numberOfLines = 0
        lblComments.attributedText = NSAttributedString(attrString)

        if UserPreferences.current.showFlightImages {
            imgHasPics.image = le.flightImages.mfbImageInfo.count > 0 ? nil : UIImage(named: "noimage")
            
            if ci != nil && ci!.hasThumbnailCache {
                imgHasPics.image = ci!.GetThumbnail()
            }
        }
        
        imgSigState.isHidden = le.cfiSignatureState == MFBWebServiceSvc_SignatureState_None
        if le.cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid {
            imgSigState.image = UIImage(named: "sigok")
        } else if le.cfiSignatureState == MFBWebServiceSvc_SignatureState_Invalid {
            imgSigState.image = UIImage(named: "siginvalid")
        } else {
            imgSigState.image = nil
        }
        
        layoutForTable(tableView)
    }
}
