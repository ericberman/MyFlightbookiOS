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
//  ButtonCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/29/23.
//

import Foundation

@objc public class ButtonCell : UITableViewCell {
    @IBOutlet weak var btn : UIButton!
 
    func setTransparent() {
        backgroundColor = .clear
        backgroundView = UIView(frame: CGRectZero)
        selectionStyle = .none
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setTransparent()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setTransparent()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc public class func getButtonCell(_ tableView : UITableView) -> ButtonCell {
        let CellTextIdentifier = "cellButton"
        var _cell = tableView.dequeueReusableCell(withIdentifier: CellTextIdentifier) as? ButtonCell
        if (_cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed("ButtonCell", owner:self)!
            if let firstObject = topLevelObjects[0] as? ButtonCell {
                _cell = firstObject
            } else {
                _cell = topLevelObjects[1] as? ButtonCell
            }
        }
        return _cell!
    }
}
