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
//  FixedImageCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/1/23.
//

import Foundation

@objc public class FixedImageCell : UITableViewCell {
    @IBOutlet public weak var imgView : UIImageView!
    @IBOutlet public weak var lblMain : UILabel!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc public static func getFixedImageCell(_ tableView : UITableView) -> FixedImageCell {
        let cellTextIdentifier = "fixedImageCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellTextIdentifier) as? FixedImageCell
        if (cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed("FixedImageCell", owner: self)!
            if let firstObject = topLevelObjects[0] as? FixedImageCell {
                cell = firstObject
            } else {
                cell = topLevelObjects[1] as? FixedImageCell
            }
        }
        return cell!
    }
}
