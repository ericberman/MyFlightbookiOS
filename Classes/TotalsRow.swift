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
//  TotalsRow.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/22/23.
//

import Foundation

public class TotalsRow : UITableViewCell {
    @IBOutlet weak var txtLabel : UILabel!
    @IBOutlet weak var txtValue : UILabel!
    @IBOutlet weak var txtSubDesc : UILabel!

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func AdjustLayoutForValues() {
        if (!(txtSubDesc.text?.isEmpty ?? false)) {
            let h = (txtSubDesc.frame.origin.y + txtSubDesc.frame.size.height) - txtLabel.frame.origin.y
            var r = self.txtLabel.frame
            r.size.height = h
            txtLabel.frame = r
            r = self.txtValue.frame
            r.size.height = h
            txtValue.frame = r
        }
    }
    
    @objc(rowForTotal: forTableView: usingHHMM:) public static func rowForTotal(ti : MFBWebServiceSvc_TotalsItem, tableView : UITableView, fHHMM : Bool) -> TotalsRow? {
        let CellIdentifier = "TotalsRow"
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if (cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed(CellIdentifier, owner: self)!
            if (topLevelObjects.count > 0) {
                if let first = topLevelObjects[0] as? TotalsRow {
                    cell = first
                }
                else if let second = topLevelObjects[1] as? TotalsRow {
                    cell = second
                }
            }
            cell?.selectionStyle = .none
        }
        
        if let tr = cell as? TotalsRow {
            tr.txtLabel.text = ti.description
            tr.txtSubDesc.text = ti.subDescription
            tr.txtValue.text = ti.formattedValue(fHHMM: fHHMM) as String
            tr.accessoryType = (ti.query == nil) ? .none : .disclosureIndicator
            tr.AdjustLayoutForValues()
            return tr
        }
        
        return cell as? TotalsRow // should never happen
    }
}
