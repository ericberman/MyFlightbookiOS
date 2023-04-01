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
//  ProgressCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/1/23.
//

import Foundation

@objc public class ProgressCell : UITableViewCell {
    @IBOutlet weak var progressLabel : UILabel!
    @IBOutlet weak var progressDetailLabel : UILabel!
    @IBOutlet weak var progressBar : UIProgressView!
    
    @objc public static func getProgressCell(_ tableView : UITableView) -> ProgressCell {
        let cellTextIdentifier = "progressCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellTextIdentifier) as? ProgressCell
        if (cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed("ProgressCell", owner: self)!
            if let firstObject = topLevelObjects[0] as? ProgressCell {
                cell = firstObject
            } else {
                cell = topLevelObjects[1] as? ProgressCell
            }
        }
        return cell!
    }
}
