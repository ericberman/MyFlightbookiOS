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
//  ExpandHeaderCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/27/23.
//

import Foundation

@objc public class ExpandHeaderCell : UITableViewCell {
    @IBOutlet @objc public weak var HeaderLabel : UILabel!
    @IBOutlet @objc public weak var ExpandCollapseLabel : UIImageView!
    @IBOutlet @objc public weak var DisclosureButton : UIButton!
    @objc public var isExpanded = false
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        DisclosureButton.isHidden = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc public func setExpanded(_ fExpanded : Bool) {
        if (isExpanded == fExpanded) {
            return
        }
        
        isExpanded = fExpanded
        
        UIView.animate(withDuration: 0.35) {
            self.ExpandCollapseLabel.transform = CGAffineTransformRotate(self.ExpandCollapseLabel.transform, fExpanded ? Double.pi / 2.0 : -Double.pi / 2.0)
        }
    }
    
    @objc public static func getHeaderCell(_ tableView : UITableView, withTitle szTitle : String, forSection section : Int, initialState initExpanded : Bool) -> ExpandHeaderCell {
        let cellIdentifier = "expandcellHeader"
        var _cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? ExpandHeaderCell
        if _cell == nil {
            let topLevelObjects = Bundle.main.loadNibNamed("ExpandHeaderCell", owner: self)!
            if let firstObject = topLevelObjects[0] as? ExpandHeaderCell {
                _cell = firstObject
            } else {
                _cell = topLevelObjects[1] as? ExpandHeaderCell
            }
        }
        
        let cell = _cell!
        cell.selectionStyle = .none
        MFBTheme.applyThemedImage(name: "Collapsed.png", imgView: cell.ExpandCollapseLabel)
        cell.HeaderLabel.text = szTitle
        cell.setExpanded(initExpanded)
        cell.DisclosureButton.isHidden = true
        return cell
    }
}
