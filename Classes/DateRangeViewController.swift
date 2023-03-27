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
//  DateRangeViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public protocol DateRangeChanged {
    func setStartDate(_ dtStart : Date?, andEndDate dtEnd : Date?)
}

@objc public class DateRangeViewController : UITableViewController, UITextFieldDelegate, AccessoryBarDelegate {
    
    @objc public var delegate : DateRangeChanged? = nil
    @objc public var dtStart : Date? = nil
    @objc public var dtEnd : Date? = nil
    @IBOutlet public weak var vwDatePicker : UIDatePicker!
    
    private var vwAccessory : AccessoryBar!
    private var activeIndexPath = IndexPath()

    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        vwAccessory = AccessoryBar.getAccessoryBar(self)!
        vwAccessory.btnDelete.isEnabled = false
        vwDatePicker.preferredDatePickerStyle = .wheels
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as? EditCell ?? EditCell.getEditCell(tableView, withAccessory: nil)
        
        // Configure the cell...
        if indexPath.row == 0 { // start date
            cell.lbl.text = String(localized: "Start Date", comment: "Indicates the starting date of a range")
            cell.txt.text = dtStart?.formatted() ?? ""
        } else {
            // End date
            cell.lbl.text = String(localized: "End Date", comment: "Indicates the ending date of a range")
            cell.txt.text = dtEnd?.formatted() ?? ""
        }
        
        cell.txt.inputAccessoryView = self.vwAccessory
        cell.txt.inputView = vwDatePicker
        cell.txt.clearButtonMode = .never
        cell.txt.delegate = self
        
        return cell;
    }
    
    // MARK: Table view delegate
    func handleClickForIndexPath(_ ip : IndexPath) {
        let ec = tableView.cellForRow(at: ip) as! EditCell
        vwDatePicker.date = ((ip.row == 0) ? dtStart : dtEnd) ?? Date()
        ec.txt.becomeFirstResponder()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeIndexPath = indexPath
        handleClickForIndexPath(indexPath)
    }

    // MARK: -
    // MARK: UITextFieldDelegate
    func owningCell(_ vw : UIView?) -> EditCell? {
        let pc : EditCell? = nil
        
        var v = vw
        while (v != nil) {
            v = v!.superview
            if let ec = v as? EditCell {
                return ec
            }
        }
        return pc
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeIndexPath = tableView.indexPath(for: owningCell(textField)!)!
        vwDatePicker.date = ((activeIndexPath.row == 0) ? dtStart : dtEnd) ?? Date()
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    // MARK: -
    // MARK: dateChanged events
    @IBAction public func dateChanged(_ sender : UIDatePicker) {
        let ec = tableView.cellForRow(at: activeIndexPath) as! EditCell
        ec.txt.text = sender.date.formatted()
        if activeIndexPath.row == 0 {
            dtStart = sender.date
        } else {
            dtEnd = sender.date
        }
        delegate?.setStartDate(dtStart, andEndDate: dtEnd)
    }

    // MARK: -
    // MARK: AccessoryBarDelegates
    func navigateToActiveCell() {
        tableView.selectRow(at: activeIndexPath, animated: true, scrollPosition: .middle)
        handleClickForIndexPath(activeIndexPath)
    }
    
    public func nextClicked() {
        activeIndexPath = nextCell(ipCurrent: activeIndexPath)
        navigateToActiveCell()
    }
    
    public func prevClicked() {
        activeIndexPath = prevCell(ipCurrent: activeIndexPath)
        navigateToActiveCell()
    }
    
    public func doneClicked() {
        let ec = tableView.cellForRow(at: activeIndexPath) as! EditCell
        ec.txt.resignFirstResponder()
    }
    
    public func deleteClicked() {
        // no-op
    }
}
