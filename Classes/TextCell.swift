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
//  TextCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/30/23.
//

import Foundation

@objc public class TextCell : UITableViewCell {
    @IBOutlet weak var txt : UILabel!
    
    // MARK: - Initialization
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Instantiation
    @objc public static func getTextCell(_ tableView : UITableView) -> TextCell {
        let CellTextIdentifier = "CellTextID"
        var _cell = tableView.dequeueReusableCell(withIdentifier: CellTextIdentifier) as? TextCell
        if _cell == nil {
            let topLevelObjects = Bundle.main.loadNibNamed("TextCell", owner: self)!
            if let firstObject = topLevelObjects[0] as? TextCell {
                _cell = firstObject
            } else {
                _cell = topLevelObjects[1] as? TextCell
            }
        }

        let cell = _cell!
        cell.selectionStyle = .none;
        return cell
    }
    
    @objc public static func getTextCellTransparent(_ tableView : UITableView) -> TextCell {
        let tc = TextCell.getTextCell(tableView)
        tc.makeTransparent()
        return tc
    }
    
    // MARK: - Utility
    @objc public override func makeTransparent() {
        txt.backgroundColor = .clear
        super.makeTransparent()
    }
}
