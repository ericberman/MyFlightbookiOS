/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019-2023 MyFlightbook, LLC
 
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
//  ConjunctionCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/29/23.
//

import Foundation

@objc class ConjunctionCell : UITableViewCell {
    @IBOutlet weak var segConjunction : UISegmentedControl!
    
    @objc public var conjunction : MFBWebServiceSvc_GroupConjunction {
        get {
            return MFBWebServiceSvc_GroupConjunction(MFBWebServiceSvc_GroupConjunction_Any.rawValue + UInt32(segConjunction.selectedSegmentIndex))
        }
        set (val) {
            segConjunction.selectedSegmentIndex = Int(val.rawValue - MFBWebServiceSvc_GroupConjunction_Any.rawValue)
        }
    }
    
    @objc public static func getConjunctionCell(_ tableView : UITableView, withConjunction conj : MFBWebServiceSvc_GroupConjunction) -> ConjunctionCell {
        let CellTextIdentifier = "ConjunctionCell"
        var _cell = tableView.dequeueReusableCell(withIdentifier: CellTextIdentifier) as? ConjunctionCell
        if (_cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed("ConjunctionCell", owner:self)!
            if let firstObject = topLevelObjects[0] as? ConjunctionCell {
                _cell = firstObject
            } else {
                _cell = topLevelObjects[1] as? ConjunctionCell
            }
        }
        let cell = _cell!
        cell.conjunction = conj
        return cell
    }
}
