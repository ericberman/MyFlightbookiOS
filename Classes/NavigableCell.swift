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
//  NavigableCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public class NavigableCell : UITableViewCell {
    
    @IBOutlet weak var firstResponderControl : UIResponder!
    @IBOutlet weak var lastResponderControl : UIResponder!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Navigation within the cell
    func sortedTextFields() -> [UITextField] {
        var ar  : [UITextField] = []
        if let fr = firstResponderControl as? UITextField {
            for vw in fr.superview?.subviews ?? [] {
                if let tf = vw as? UITextField {
                    ar.append(tf)
                }
            }
        }
        
        ar.sort { tf1, tf2 in
            return tf1.tag <= tf2.tag
        }
        return ar
    }
    
    @objc public func navNext(_ txtCurrent : UITextField) -> Bool {
     let ar = sortedTextFields()
        if let index = ar.firstIndex(of: txtCurrent) {
            if index < ar.count - 1 {
                ar[index + 1].becomeFirstResponder()
                return true
            }
        }
        return false
    }
    
    @objc public func navPrev(_ txtCurrent : UITextField) -> Bool {
        let ar = sortedTextFields()
           if let index = ar.firstIndex(of: txtCurrent) {
               if index > 0 {
                   ar[index - 1].becomeFirstResponder()
                   return true
               }
           }
           return false
    }
}
