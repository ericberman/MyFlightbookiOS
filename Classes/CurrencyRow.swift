/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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
//  CurrencyRow.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/22/23.
//

import Foundation

public class CurrencyRow : UITableViewCell {
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var lblValue : UILabel!
    @IBOutlet weak var lblDiscrepancy : UILabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func AdjustLayoutForValues() {
        /*
         if ([self.lblDiscrepancy.text length] == 0)
         {
             CGFloat h = (self.lblDiscrepancy.frame.origin.y + self.lblDiscrepancy.frame.size.height) - self.lblValue.frame.origin.y;
             CGRect r = self.lblValue.frame;
             r.size = CGSizeMake(r.size.width, h);
             self.lblValue.frame = r;
         }
         */
        if (!(lblDiscrepancy.text?.isEmpty ?? false)) {
            let h = lblDiscrepancy.frame.origin.y + lblDiscrepancy.frame.size.height - lblValue.frame.origin.y
            var r = lblValue.frame
            r.size = CGSize(width: r.size.width, height: h)
            lblValue.frame = r
        }
    }

    @objc(rowForCurrency: forTableView:) public static func rowForCurrency(ci : MFBWebServiceSvc_CurrencyStatusItem, tableView : UITableView) -> CurrencyRow {
        let CellIdentifier = "CurrencyRow"
        var _cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? CurrencyRow
        if (_cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed(CellIdentifier, owner: self)!
            if (topLevelObjects.count > 0) {
                if let first = topLevelObjects[0] as? CurrencyRow {
                    _cell = first
                }
                else if let second = topLevelObjects[1] as? CurrencyRow {
                    _cell = second
                }
            }
        }
        
        let cr = _cell!
        cr.selectionStyle = .none
        cr.lblDescription.text = ci.formattedTitle()
        cr.lblValue.text = ci.value
        cr.lblValue.textColor = MFBWebServiceSvc_CurrencyStatusItem.colorForState(state: ci.status)
        cr.lblDiscrepancy.text = ci.discrepancy
        cr.AdjustLayoutForValues()
        return cr
    }
}
