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
//  TotalsCalculator.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/2/23.
//

import Foundation

@objc public protocol TotalsCalculatorDelegate {
    @objc func updateTotal(_ value : NSNumber)
}

@objc public class TotalsCalculator : CollapsibleTableSw, UITextFieldDelegate {
    
    @objc public var delegate : TotalsCalculatorDelegate? = nil
    
    private var cellSegmentStart : EditCell!
    private var cellSegmentEnd : EditCell!
    private var cellToActivateAfterReload : EditCell? = nil
    private var vwAccessory : AccessoryBar!
    private var values : [Double] = []
    public var errorString = ""
    
    @objc public var initialTotal : NSNumber {
        get {
            return NSNumber(floatLiteral: values.isEmpty ? 0 : values[0])
        }
        set (val) {
            values.append(val.doubleValue)
        }
    }
    
    enum timeCalcRows : Int, CaseIterable {
        case rowInstructions = 0, rowEquation, rowSegmentStart, rowSegmentEnd, rowCopy, rowAdd, rowUpdate
    }
    
    // MARK: - Initialization/lifecycle
    private func getEditCell(_ label : String) -> EditCell {
        let ec = EditCell.getEditCell(tableView, withAccessory: nil)
        ec.txt.delegate = self
        ec.txt.inputAccessoryView = vwAccessory
        ec.txt.autocapitalizationType = .allCharacters
        ec.txt.autocorrectionType = .no
        ec.txt.setType(numericType: .Time, fHHMM: true)
        ec.txt.text = ""
        ec.setLabelToFit(label)
        return ec
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        cellSegmentStart = getEditCell(String(localized: "tcAddTimeStartPrompt", comment: "Total Time Calculator - Segment Start"))
        cellSegmentEnd = getEditCell(String(localized: "tcAddTimeEndPrompt", comment: "Total Time Calculator - Segment End"))
        cellToActivateAfterReload = cellSegmentStart
        clearTime()
    }
    
    // MARK: - Actions
    @objc func copySum() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = UITextField.stringFromNumber(num: NSNumber(floatLiteral: computedTotal), nt: NumericType.Time.rawValue, inHHMM: UserPreferences.current.HHMMPref) as String
    }
    
    @objc func addSum() {
        cellToActivateAfterReload = cellSegmentStart
        addSpecifiedTime()
        tableView.reloadData()
    }
    
    @objc func updateSum() {
        addSpecifiedTime()
        delegate?.updateTotal(NSNumber(floatLiteral: computedTotal))
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - segment math
    func clearTime() {
        cellSegmentStart.txt.text = ""
        cellSegmentEnd.txt.text = ""
        tableView.reloadData()
    }
    
    var computedTotal : Double {
        get {
            var d = 0.0
            for n in values {
                d += n
            }
            return d
        }
    }
    
    func getSpecifiedTimeRange() -> Double {
        let d1 = cellSegmentStart.txt.getValue().doubleValue
        var d2 = cellSegmentEnd.txt.getValue().doubleValue
        
        if (d1 >= 0 && d2 >= 0 && d1 <= 24 && d2 <= 24) {
            while (d2 < d1) {
                d2 += 24.0
            }
            errorString = ""
            clearTime()
            return d2 - d1
        } else {
            errorString = String(localized: "tcErrBadTime", comment: "Total Time Calculator - Error - bad times")
            cellToActivateAfterReload = nil
            tableView.reloadData()
        }
        return 0.0
    }
    
    func addSpecifiedTime() {
        let d = getSpecifiedTimeRange()
        if (d > 0) {
            values.append(d)
        }
    }
    
    func equationString() -> String {
        if values.isEmpty {
            return ""
        }
        
        let fHHMM = UserPreferences.current.HHMMPref
        var s = ""
        for d in values {
            let val = NSNumber(floatLiteral: d).formatAsTime(fHHMM: fHHMM, fGroup: false) as String
            s = s.isEmpty ? val : "\(s) + \(val)"
        }
        s.append(" = \(NSNumber(floatLiteral: computedTotal).formatAsTime(fHHMM: fHHMM, fGroup: false))")
        return s
    }
    
    // MARK: UITableView data delegate
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return errorString
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeCalcRows.allCases.count
    }
    
    func cellIDFromIndexPath(_ ip : IndexPath) -> timeCalcRows {
        return timeCalcRows(rawValue: ip.row)!
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell == cellToActivateAfterReload {
            cellToActivateAfterReload?.txt.becomeFirstResponder()
            cellToActivateAfterReload = nil
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellIDFromIndexPath(indexPath) {
        case .rowInstructions:
            let tc = TextCell.getTextCell(tableView)
            tc.txt.text = String(localized: "tcAddTimeRangePrompt", comment: "Total Time Calculator - Prompt")
            return tc
        case .rowEquation:
            let CellIdentifier = "cellModel"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
            var config = cell.defaultContentConfiguration()
            config.secondaryText = nil
            config.text = equationString()
            config.textProperties.adjustsFontSizeToFitWidth = true
            cell.contentConfiguration = config
            cell.accessoryType = .none
            return cell
        case .rowSegmentStart:
            return self.cellSegmentStart
        case .rowSegmentEnd:
            return self.cellSegmentEnd
        case .rowCopy:
            let bc = ButtonCell.getButtonCell(tableView)
            bc.btn.setTitle(String(localized: "tcCopyResult", comment: "Total Time Calculator - Copy"), for:.normal)
            bc.btn.addTarget(self, action: #selector(copySum), for: .touchUpInside)
            return bc
        case .rowAdd:
            let bc = ButtonCell.getButtonCell(tableView)
            bc.btn.setTitle(String(localized: "tcAddSegment", comment: "Total Time Calculator - Add"), for:.normal)
            bc.btn.addTarget(self, action: #selector(addSum), for: .touchUpInside)
            return bc
        case .rowUpdate:
            let bc = ButtonCell.getButtonCell(tableView)
            bc.btn.setTitle(String(localized: "tcAddSegmentAndUpdate", comment: "Total Time Calculator - Add and update"), for:.normal)
            bc.btn.addTarget(self, action: #selector(updateSum), for: .touchUpInside)
            return bc
        }
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldDidEndEditing(_ textField: UITextField) {
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textField)!)
        enableNextPrev(vwAccessory)
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if cellIDFromIndexPath(tableView.indexPath(for: owningCell(textField)!)!) == .rowSegmentStart {
            nextClicked()
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.isValidNumber(szProposed: (textField.text as? NSString ?? "").replacingCharacters(in: range, with: string))
    }
    
    // MARK: - AccessoryViewDelegate
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        let row = cellIDFromIndexPath(ip)
        return row == timeCalcRows.rowSegmentEnd || row == timeCalcRows.rowSegmentStart
    }
}
