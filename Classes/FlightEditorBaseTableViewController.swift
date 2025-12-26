/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2025 MyFlightbook, LLC
 
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
//  FlightEditorBaseTableViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/6/23.
//

import Foundation
import ExternalAccessory

public class FlightEditorBaseTableViewController : CollapsibleTableSw, UIGestureRecognizerDelegate, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet public var idDate : UITextField!
    @IBOutlet public var idRoute : UITextField!
    @IBOutlet public var idComments : UITextView!
    @IBOutlet public var idTotalTime : UITextField!
    @IBOutlet public var idPopAircraft : UITextField!
    @IBOutlet public var idApproaches : UITextField!
    @IBOutlet public var idHold : UIButton!
    @IBOutlet public var idLandings : UITextField!
    @IBOutlet public var idDayLandings : UITextField!
    @IBOutlet public var idNightLandings : UITextField!
    @IBOutlet public var idNight : UITextField!
    @IBOutlet public var idIMC : UITextField!
    @IBOutlet public var idSimIMC : UITextField!
    @IBOutlet public var idGrndSim : UITextField!
    @IBOutlet public var idXC : UITextField!
    @IBOutlet public var idDual : UITextField!
    @IBOutlet public var idCFI : UITextField!
    @IBOutlet public var idSIC : UITextField!
    @IBOutlet public var idPIC : UITextField!
    @IBOutlet public var idPublic : UIButton!

    @IBOutlet public var idLblStatus : UILabel!
    @IBOutlet public var idLblSpeed : UILabel!
    @IBOutlet public var idLblAltitude : UILabel!
    @IBOutlet public var idLblQuality : UILabel!
    @IBOutlet public var idimgRecording : UIImageView!
    @IBOutlet public var idlblElapsedTime : UILabel!
    @IBOutlet public var idbtnPausePlay : UIButton!
    @IBOutlet public var idbtnAppendNearest : UIButton!
    @IBOutlet public var lblLat : UILabel!
    @IBOutlet public var lblLon : UILabel!
    @IBOutlet public var lblSunrise : UILabel!
    @IBOutlet public var lblSunset : UILabel!
    @IBOutlet public var btnViewRoute : UIButton!

    /* cells */
    @IBOutlet public var cellDateAndTail : UITableViewCell!
    @IBOutlet public var cellComments : EditCell!
    @IBOutlet public var cellRoute : EditCell!
    @IBOutlet public var cellLandings : UITableViewCell!
    @IBOutlet public var cellGPS : UITableViewCell!
    @IBOutlet public var cellTimeBlock : UITableViewCell!
    @IBOutlet public var cellSharing : UITableViewCell!

    @IBOutlet public var datePicker : UIDatePicker!
    @IBOutlet public var dateTimePicker : UIDatePicker!
    @IBOutlet public var pickerView : UIPickerView!
    
    public var vwAccessory : AccessoryBar!
    public var activeTextField : UITextField? = nil
    public var externalAccessories : [EAAccessory] = []
    
    // MARK: - UI/UITableViewCell Helpers
    func setNumericField(_ txt : UITextField, type nt : NumericType) {
        txt.setType(numericType: nt, fHHMM: UserPreferences.current.HHMMPref)
        txt.autocorrectionType = .no
        txt.inputAccessoryView = vwAccessory
        txt.delegate = self
    }
    
    public func decimalCell(_ tableView : UITableView, prompt szPrompt : String, value val : NSNumber, selector: Selector) -> EditCell {
        let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
        setNumericField(ec.txt, type:NumericType.Decimal)
        ec.txt.addTarget(self, action: selector, for: .editingChanged)
        ec.txt.setValueWithDefault(num: val, numDefault: 0.0)
        ec.lbl.text = szPrompt
        return ec
    }
    
    public func dateCell(_ dt : NSDate?, prompt szPrompt : String, tableView : UITableView) -> EditCell {
        let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
        ec.txt.inputView = dateTimePicker
        ec.txt.placeholder = String(localized: "(Tap for Now)", comment: "Prompt UTC Date/Time that is currently un-set (tapping sets it to NOW in UTC)")
        ec.txt.delegate = self
        ec.lbl.text = szPrompt
        ec.txt.clearButtonMode = .never
        ec.txt.text = NSDate.isUnknownDate(dt: dt as? Date) ? "" : dt!.utcString(useLocalTime: UserPreferences.current.UseLocalTime)

        return ec
    }
    
    // MARK: - Gesture support
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func enableLongPressForField(_ txt : UITextField, selector s : Selector) {
        // Disable the existing long-press recognizer
        let currentGestures = txt.gestureRecognizers ?? []
        for recognizer in currentGestures {
            if let r = recognizer as? UILongPressGestureRecognizer {
                txt.removeGestureRecognizer(r)
            }
        }
        let lpgr = UILongPressGestureRecognizer(target: self, action: s)
        lpgr.minimumPressDuration = 0.7 // in seconds
        lpgr.delegate = self
        txt.addGestureRecognizer(lpgr)
    }
    
    func enableLabelClick(for txt : UITextField) {
        if txt.tag <= 0 {
            return
        }
        for vw in txt.superview?.subviews ?? [] {
            if let l = vw as? UILabel {
                if l.tag == txt.tag {
                    l.addGestureRecognizer(UITapGestureRecognizer(target: txt, action: #selector(becomeFirstResponder)))
                }
            }
        }
    }
    
    @objc func crossFillTotal(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            (sender.view as! UITextField).crossFillFrom(src: idTotalTime)
        }
    }
    
    @objc func crossFillLanding(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            (sender.view as! UITextField).crossFillFrom(src: idLandings)
        }
    }
    
    // MARK: - External Devices
    @objc func deviceDidConnect(_ notification : NSNotification) {
        if let accessory = notification.userInfo?[EAAccessoryKey] as? EAAccessory {
            externalAccessories.append(accessory)
        }
        tableView.reloadData()
    }
    
    @objc func deviceDidDisconnect(_ notification : NSNotification) {
        externalAccessories = EAAccessoryManager.shared().connectedAccessories
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    public var hasAccessories : Bool {
        get {
            return !externalAccessories.isEmpty
        }
    }
    
    public func viewAccessories() {
        if hasAccessories {
            let gpsView = GPSDeviceViewTableViewController()
            gpsView.eaaccessory = externalAccessories[0]
            tableView.endEditing(true)
            navigationController?.pushViewController(gpsView, animated: true)
        }
    }
    
    // MARK: - UIPopoverPresentationController functions
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        tableView.reloadData()
    }
    
    // MARK: - CollapsibleTable
    public override func nextClicked() {
        // activeTextField had better be non-null for this to ever happen
        if activeTextField != nil {
            let cell = owningCellGeneric(activeTextField!)
            if let nc = cell as? NavigableCell {
                if nc.navNext(activeTextField!) {
                    return
                }
            }
        }
        super.nextClicked()
    }
    
    public override func prevClicked() {
        let cell = owningCellGeneric(activeTextField!)
        if let nc = cell as? NavigableCell {
            if nc.navPrev(activeTextField!) {
                return
            }
        }
        super.prevClicked()
    }
    
    public override func doneClicked() {
        activeTextField = nil
        super.doneClicked()
    }
    
    // MARK: UITextViewDelegate
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTextField = nil
        return true
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textView)!)
        enableNextPrev(vwAccessory)
        return true
    }
    
    // MARK: View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Set the accessory view and the inputview for our various text boxes.
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        
        // Set numeric fields
        setNumericField(idLandings, type : .Integer)
        setNumericField(idDayLandings, type : .Integer)
        setNumericField(idNightLandings, type : .Integer)
        setNumericField(idApproaches, type : .Integer)
        
        setNumericField(idXC, type : .Time)
        setNumericField(idSIC, type : .Time)
        setNumericField(idSimIMC, type : .Time)
        setNumericField(idCFI, type : .Time)
        setNumericField(idDual, type : .Time)
        setNumericField(idGrndSim, type : .Time)
        setNumericField(idIMC, type : .Time)
        setNumericField(idNight, type : .Time)
        setNumericField(idPIC, type : .Time)
        setNumericField(idTotalTime, type : .Time)
        
        enableLabelClick(for: idLandings)
        enableLabelClick(for: idNightLandings)
        enableLabelClick(for: idDayLandings)
        enableLabelClick(for: idApproaches)
        
        enableLabelClick(for: idNight)
        enableLabelClick(for: idSimIMC)
        enableLabelClick(for: idIMC)
        enableLabelClick(for: idXC)
        enableLabelClick(for: idDual)
        enableLabelClick(for: idGrndSim)
        enableLabelClick(for: idCFI)
        enableLabelClick(for: idSIC)
        enableLabelClick(for: idPIC)
        enableLabelClick(for: idTotalTime)
        
        enableLongPressForField(idNight, selector: #selector(crossFillTotal))
        enableLongPressForField(idSimIMC, selector: #selector(crossFillTotal))
        enableLongPressForField(idIMC, selector: #selector(crossFillTotal))
        enableLongPressForField(idXC, selector: #selector(crossFillTotal))
        enableLongPressForField(idDual, selector: #selector(crossFillTotal))
        enableLongPressForField(idGrndSim, selector: #selector(crossFillTotal))
        enableLongPressForField(idCFI, selector: #selector(crossFillTotal))
        enableLongPressForField(idSIC, selector: #selector(crossFillTotal))
        enableLongPressForField(idPIC, selector: #selector(crossFillTotal))
        enableLongPressForField(idDayLandings, selector: #selector(crossFillLanding))
        enableLongPressForField(idNightLandings, selector: #selector(crossFillLanding))
        
        // Make the checkboxes checkboxes
        idHold.setIsCheckbox()
        idHold.contentHorizontalAlignment = .left
        idPublic.setIsCheckbox()
        idPublic.contentHorizontalAlignment = .left
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EAAccessoryManager.shared().registerForLocalNotifications()
        externalAccessories = EAAccessoryManager.shared().connectedAccessories
        let notctr = NotificationCenter.default
        notctr.addObserver(self, selector: #selector(deviceDidConnect), name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        notctr.addObserver(self, selector: #selector(deviceDidDisconnect), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EAAccessoryManager.shared().unregisterForLocalNotifications()
        let notctr = NotificationCenter.default
        notctr.removeObserver(self, name: NSNotification.Name.EAAccessoryDidConnect, object: nil)
        notctr.removeObserver(self, name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
    }
}
