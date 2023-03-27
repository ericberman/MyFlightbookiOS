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
//  EditCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public class EditCell : NavigableCell {
    @IBOutlet weak var lbl : UILabel!
    @IBOutlet weak var txt : UITextField!
    @IBOutlet weak var txtML : UITextView!
    @IBOutlet weak var lblDetail : UILabel!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc public func setLabelToFit(_ sz : String?) {
        var fnt = lbl.font!
        var ptSize = fnt.pointSize
        let rFrame = lbl.frame
        
        while ptSize > 0.0 {
            fnt = UIFont.systemFont(ofSize: ptSize)
            let size = NSString(string: sz ?? "").boundingRect(with: CGSizeMake(rFrame.size.width - 20 - 30, 10000),
                                                         options: .usesLineFragmentOrigin,
                                                         attributes: [.font : fnt],
                                                         context: nil).size
            if (size.height <= rFrame.size.height) {
                break;
            }
            ptSize -= 1.0
        }
        
        lbl.font = fnt
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = false
        lbl.lineBreakMode = .byWordWrapping
        lbl.text = sz
    }
    
    static func getEditCell(_ tableView : UITableView, withAccessory vwAccessory : AccessoryBar?, fromNib nibName : String, withID cellID : String) -> EditCell {
        var _cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? EditCell
        if (_cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed(nibName, owner: self)!
            if let firstObject = topLevelObjects[0] as? EditCell {
                _cell = firstObject
            } else {
                _cell = topLevelObjects[1] as? EditCell
            }
        }
        let cell = _cell!
        
        if cell.txt != nil {
            cell.txt.isSecureTextEntry = false
            cell.txt.inputAccessoryView = vwAccessory
            cell.txt.placeholder = ""
            cell.firstResponderControl = cell.txt
            cell.lastResponderControl = cell.txt
        }
        if cell.txtML != nil {
            cell.txtML.isSecureTextEntry = false
            cell.txtML.inputAccessoryView = vwAccessory
            cell.txtML.isEditable = true
            cell.firstResponderControl = cell.txtML
            cell.lastResponderControl = cell.txtML
        }
        
        cell.lblDetail?.text = ""
        return cell
    }
    
    @objc public static func getEditCell(_ tableView: UITableView, withAccessory vwAccessory : AccessoryBar?) -> EditCell {
        let CellTextIdentifier = "CellEdit"
        return EditCell.getEditCell(tableView, withAccessory:vwAccessory, fromNib:"EditCell", withID:CellTextIdentifier)
    }
    
    @objc public static func getEditCellDetail(_ tableView : UITableView, withAccessory vwAccessory : AccessoryBar?) -> EditCell {
        let CellTextIdentifier = "CellEditDetail"
        return EditCell.getEditCell(tableView, withAccessory:vwAccessory, fromNib:"EditCellDetail", withID:CellTextIdentifier)
    }

    @objc public static func getEditCellNoLabel(_ tableView : UITableView, withAccessory vwAccessory :AccessoryBar?) -> EditCell {
        let CellTextIdentifier = "CellEditNoLabel"
        return EditCell.getEditCell(tableView, withAccessory:vwAccessory, fromNib:"EditCellNoLabel", withID:CellTextIdentifier)
    }

    @objc public static func getEditCellMultiLine(_ tableView : UITableView, withAccessory vwAccessory : AccessoryBar?) -> EditCell {
        let CellTextIdentifier = "CellEditMultiLine"
        return EditCell.getEditCell(tableView, withAccessory:vwAccessory, fromNib:"EditCellML", withID:CellTextIdentifier)
    }

}
