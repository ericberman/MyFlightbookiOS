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
//  ApproachEditor.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/2/23.
//

import Foundation

@objc public protocol ApproachEditorDelegate {
    @objc func addApproachDescription(_ approachDescription : ApproachDescription)
}

@objc public class ApproachEditor : CollapsibleTableSw, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @objc public var approachDescription = ApproachDescription()
    @objc public var delegate : ApproachEditorDelegate? = nil
    
    
    
    @objc public var airports : [String] {
        get {
            return _rgAirports
        }
        set (val) {
            _rgAirports = val
            approachDescription.airportName = val.isEmpty ? "" : val[val.count - 1]
        }
    }
    
    private var _rgAirports : [String] = []
    private var vwAccessory : AccessoryBar!
    private var vwPickerApproach : UIPickerView!
    private var vwPickerRunway : UIPickerView!
    
    enum appchRow : Int, CaseIterable {
        case rowCount = 0, rowApproachType, rowRunway, rowAirport, rowAddToTotals
    }
    
    // MARK: - Initialization
    private func initLocals() {
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        
        vwPickerApproach = UIPickerView()
        vwPickerApproach.dataSource = self
        vwPickerApproach.delegate = self
        
        vwPickerRunway = UIPickerView()
        vwPickerRunway.dataSource = self
        vwPickerRunway.delegate = self
    }
    public override init(style: UITableView.Style) {
        super.init(style: style)
        initLocals()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initLocals()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initLocals()
    }
    
    // MARK: - View Lifecycle
    public override func viewWillDisappear(_ animated: Bool) {
        tableView.endEditing(true)
        delegate?.addApproachDescription(approachDescription)
        super.viewWillDisappear(animated)
    }

    // MARK: - Tableview data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return appchRow.allCases.count
        }
        fatalError("bad section \(section) in approach editor numberofrowsinsection")
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? String(localized: "ApproachHelper", comment: "Approach Helper - Title") : nil
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ec = EditCell.getEditCell(tableView, withAccessory: vwAccessory)
        ec.txt.delegate = self
        ec.txt.autocorrectionType = .no
        ec.txt.autocapitalizationType = .allCharacters
        ec.txt.autocorrectionType = .no
        
        switch cellIDFromIndexPath(indexPath) {
        case .rowCount:
            ec.txt.keyboardType = .numberPad
            ec.txt.text = approachDescription.approachCount == 0 ? "" : String(format: "%ld", approachDescription.approachCount)
            ec.txt.setType(numericType: .Integer, fHHMM: false)
            ec.txt.placeholder = String(localized: "NumApproaches", comment: "Approach Helper - Quantity")
            ec.txt.returnKeyType = .next
        case .rowAddToTotals:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "cellAddToTotals")
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "ApproachAddToCount", comment: "Approach Helper - Add to approach count")
            cell.contentConfiguration = config
            cell.accessoryType = approachDescription.addToTotals ? .checkmark : .none
            return cell
        case .rowApproachType:
            ec.txt.keyboardType = .default
            ec.txt.text = approachDescription.approachName
            ec.txt.placeholder = String(localized: "ApproachType", comment: "Approach Helper - Approach Name")
            ec.txt.returnKeyType = .next
            ec.txt.inputView = vwPickerApproach
        case .rowRunway:
            ec.txt.keyboardType = .default
            ec.txt.text = approachDescription.runwayName
            ec.txt.placeholder = String(localized: "ApproachRunway", comment: "Approach Helper - Runway")
            ec.txt.returnKeyType = .next
            ec.txt.inputView = vwPickerRunway
        case .rowAirport:
            ec.txt.keyboardType = .default
            ec.txt.text = approachDescription.airportName
            ec.txt.placeholder = String(localized: "ApproachAirport", comment: "Approach Helper - Airport")
            ec.txt.returnKeyType = .go
        }
        return ec
    }
    
    private func cellIDFromIndexPath(_ ip: IndexPath) -> appchRow {
        return appchRow(rawValue: ip.row)!
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if appchRow(rawValue: indexPath.row) == .rowAddToTotals {
            approachDescription.addToTotals = !approachDescription.addToTotals
            tableView.reloadData()
        }
    }
    
    // MARK: UITextFieldDelegate
    public func textFieldDidEndEditing(_ textField: UITextField) {
        switch cellIDFromIndexPath(tableView.indexPath(for: owningCell(textField)!)!) {
        case .rowCount:
            approachDescription.approachCount = textField.getValue().intValue
        case .rowApproachType:
            approachDescription.approachName = textField.text ?? ""
        case .rowRunway:
            approachDescription.runwayName = textField.text ?? ""
        case .rowAirport:
            approachDescription.airportName = textField.text ?? ""
        default:
            break
        }
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textField)!)!
        enableNextPrev(vwAccessory)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let row = cellIDFromIndexPath(tableView.indexPath(for: owningCell(textField)!)!)
        if row == .rowAirport {
            approachDescription.airportName = textField.text ?? "" // in case we hadn't picked it up before
            navigationController?.popViewController(animated: true)
        } else {
            nextClicked()
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    // Returns an autocompletion based on the given prefix.
    func proposeCompletion(_ szPrefix : String) -> String {
        if !szPrefix.isEmpty && !airports.isEmpty {
            let szTest = szPrefix.uppercased()
            if let szNew = airports.first(where: { sz in
                sz.uppercased().hasPrefix(szTest)
            }) {
                return szNew
            }
        }
        return szPrefix
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // always allow deletion of a selection (allows for deletion of proposed selection)
        if string.isEmpty {
            return true
        }
        
        // don't allow non-alphanumeric characters
        if let _ = string.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) {
            return false
        }
        
        // check for atocomplete
        let t = textField.text ?? ""
        let szUserTyped = t.replacingCharacters(in: Range(range, in: t)!, with: string)
        let szUserTypedWithCompletion = proposeCompletion(szUserTyped)
        if szUserTyped.compare(szUserTypedWithCompletion) != .orderedSame {
            textField.text = szUserTypedWithCompletion
            let startPos = textField.position(from: textField.beginningOfDocument, offset: szUserTyped.count)!
            let endPos = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: startPos, to: endPos)
            return false
        }
        
        return true // any string can be edited
    }
    
    // MARK: - AccessoryViewDelegates
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        return cellIDFromIndexPath(ip) != .rowAddToTotals
    }
    
    // MARK: - PickerView Data source
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerView == vwPickerRunway || pickerView == vwPickerApproach ? 2 : 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == vwPickerRunway {
            return component == 0 ? ApproachDescription.RunwayNames.count : ApproachDescription.RunwayModifiers.count
        } else if pickerView == vwPickerApproach {
            return component == 0 ? ApproachDescription.ApproachNames.count : ApproachDescription.ApproachSuffixes.count
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == vwPickerRunway {
            return component == 0 ? ApproachDescription.RunwayNames[row] : ApproachDescription.RunwayModifiers[row]
        } else if pickerView == vwPickerApproach {
            return component == 0 ? ApproachDescription.ApproachNames[row] : ApproachDescription.ApproachSuffixes[row]
        }
        return ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cellID = cellIDFromIndexPath(ipActive!)
        
        switch cellID {
        case .rowRunway:
            let ec = tableView.cellForRow(at: ipActive!) as! EditCell
            var sz = ""
            for i in 0..<pickerView.numberOfComponents {
                let row = pickerView.selectedRow(inComponent: i)
                sz += self.pickerView(pickerView, titleForRow: row, forComponent: i)!
            }
            ec.txt.text = sz
            approachDescription.runwayName = sz
        case .rowApproachType:
            let ec = tableView.cellForRow(at: ipActive!) as! EditCell
            var sz = ""
            for i in 0..<pickerView.numberOfComponents {
                let row = pickerView.selectedRow(inComponent: i)
                sz += self.pickerView(pickerView, titleForRow: row, forComponent: i)!
            }
            ec.txt.text = sz
            approachDescription.approachName = sz
        default:
            break
        }
    }
}
