/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2025 MyFlightbook, LLC
 
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
//  PropertyCell.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public class PropertyCell : NavigableCell, UITextFieldDelegate, CAAnimationDelegate {
    
    @IBOutlet weak var lbl : UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var lblDescriptionBackground : UIView!
    @IBOutlet weak var txt : UITextField!
    @IBOutlet weak var imgLocked : UIImageView!
    @IBOutlet weak var btnShowDescription : UIButton!
    
    @objc public var cfp : MFBWebServiceSvc_CustomFlightProperty = MFBWebServiceSvc_CustomFlightProperty()
    @objc public var cpt : MFBWebServiceSvc_CustomPropertyType = MFBWebServiceSvc_CustomPropertyType()
    @objc public var flightPropDelegate : FlightProps?
    
    private var autofillValue : NSNumber? = nil
    
    @IBAction public func dateChanged(_ sender : UIDatePicker) {
        cfp.dateValue = sender.date
        txt.text = sender.datePickerMode == .dateAndTime ?
        (sender.date as NSDate).utcString(useLocalTime: UserPreferences.current.UseLocalTime) :
        (sender.date as NSDate).dateString()
    }
    
    func setNoText() {
        txt.isHidden = true
        txt.isEnabled = false
        
        var r = lbl.frame
        r.origin.y = (frame.size.height - lbl.frame.size.height) / 2
        lbl.frame = r
    }
    
    // MARK: Autofill/long press
    @objc func autoFill(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began && autofillValue != nil {
            txt.becomeFirstResponder()
            txt.setValue(num: autofillValue!)
        }
    }
    
    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func setXFill(_ num : NSNumber) {
        autofillValue = num
        
        // Disable the existing long-press recognizer
        txt.gestureRecognizers?.removeAll(where: { g in
            return g as? UILongPressGestureRecognizer != nil
        })
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(autoFill))
        lpgr.minimumPressDuration = 0.7 // in seconds
        lpgr.cancelsTouchesInView = true
        lpgr.delegate = self
        txt.addGestureRecognizer(lpgr)
    }
    
    // MARK: Lock/unlock
    func updateLockStatus() {
        imgLocked.image = cpt.isLocked ? UIImage(named: "Favorite.png") : nil
    }
    
    @objc func toggleLock(_ sender : UILongPressGestureRecognizer) {
        if sender.state == .began {
            cpt.isLocked = !cpt.isLocked
            flightPropDelegate?.setPropLock(cpt.isLocked, forPropTypeID: cpt.propTypeID.intValue)
            updateLockStatus()
        }
    }
    
    // MARK: Loading cells
    @objc public static func getPropertyCell(_ tableView: UITableView, withCPT cpt : MFBWebServiceSvc_CustomPropertyType, andFlightProperty cfp : MFBWebServiceSvc_CustomFlightProperty) -> PropertyCell {
        let cellTextIdentifier = "PropertyCell";
        var _cell = tableView.dequeueReusableCell(withIdentifier: cellTextIdentifier) as? PropertyCell
        if _cell == nil {
            let topLevelObjects = Bundle.main.loadNibNamed("PropertyCell", owner:self) ?? []
            if let fo = topLevelObjects[0] as? PropertyCell {
                _cell = fo
            } else {
                _cell = topLevelObjects[1] as? PropertyCell
            }
        }
        let cell = _cell!
            
        cell.imgLocked.addGestureRecognizer(UILongPressGestureRecognizer(target: cell, action: #selector(toggleLock)))
        cell.lbl.addGestureRecognizer(UILongPressGestureRecognizer(target: cell, action: #selector(toggleLock)))

        cell.firstResponderControl = cell.txt
        cell.lastResponderControl = cell.txt
        cell.cpt = cpt
        cell.cfp = cfp

        return cell
    }
    
    func styleLabelAsDefault(_ fIsDefault : Bool) {
        lbl.textColor = fIsDefault ? .secondaryLabel : .label
        lbl.font = fIsDefault ? UIFont.systemFont(ofSize: 12.0) : UIFont.boldSystemFont(ofSize: 12.0)
    }
    
    @objc public func prepForEditing() -> Bool {
        var fResult = true
        
        if cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDate || cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime {
            let dp = txt.inputView as! UIDatePicker
            let fDateOnly = cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDate
            dp.datePickerMode = fDateOnly ? .date : .dateAndTime
            dp.timeZone = fDateOnly || UserPreferences.current.UseLocalTime ? TimeZone.current : TimeZone(secondsFromGMT: 0)
            dp.locale = fDateOnly || UserPreferences.current.UseLocalTime ? Locale.current : Locale(identifier: "en-GB")
            
            dp.removeTarget(nil, action: #selector(dateChanged), for: .valueChanged)
            if (txt.text ?? "").isEmpty {
                // initialilze it to now
                superview?.endEditing(true)
                
                // Since we don't display seconds, truncate them; this prevents odd looking math like
                // an interval from 12:13:59 to 12:15:01, which is a 1:02 but would display as 12:13-12:15 (which looks like 2 minutes)
                // By truncating the time, we go straight to 12:13:00 and 12:15:00, which will even yield 2 minutes.
                let time = floor(NSDate.timeIntervalSinceReferenceDate / 60.0) * 60.0
                let date = NSDate(timeIntervalSinceReferenceDate: time) as Date
                cfp.dateValue = date
                dp.date = date
                txt.text = (cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime) ? (cfp.dateValue as NSDate).utcString(useLocalTime: UserPreferences.current.UseLocalTime) : (cfp.dateValue as NSDate).dateString()
                fResult = false
            } else {
                dp.date = cfp.dateValue
            }
            dp.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        }
        
        return fResult
    }
    
    @objc public func handleClick() -> Bool {
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            superview?.endEditing(true)
            if cfp.boolValue ==  nil {
                cfp.boolValue = USBoolean(bool: false)
            }
            cfp.boolValue.boolValue = !cfp.boolValue.boolValue
            return true
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime,
            MFBWebServiceSvc_CFPPropertyType_cfpDate,
            MFBWebServiceSvc_CFPPropertyType_cfpString,
            MFBWebServiceSvc_CFPPropertyType_cfpDecimal,
            MFBWebServiceSvc_CFPPropertyType_cfpCurrency,
            MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            txt.becomeFirstResponder()
        default:
            break
        }
        return false
    }
    
    @objc public func handleTextUpdate(_ textField : UITextField) {
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            break
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            cfp.textValue = textField.text
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime, MFBWebServiceSvc_CFPPropertyType_cfpDate:
            if (textField.text ?? "").isEmpty {
                cfp.dateValue = nil
            }
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal, MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
            cfp.decValue = textField.getValue()
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            cfp.intValue = textField.getValue()
        default:
            break
        }
        
        styleLabelAsDefault(cfp.isDefaultForType(cpt))
    }
    
    private func capitalizationForType() -> UITextAutocapitalizationType {
        return ((cpt.flags.uint32Value & 0x04000000) == 0) ? (((cpt.flags.uint32Value & 0x10000000) == 0 ? .sentences : .words)) : .allCharacters;
    }
    
    @objc public func configureCell(_ vwAcc : UIView, andDatePicker dp : UIDatePicker, defValue defVal : NSNumber) {
        lbl.text = cpt.title
        if cfp.isDefaultForType(cpt) {
            txt.text = ""
            styleLabelAsDefault(true)
            accessoryType = .none
        } else {
            txt.text = FlightProps.stringValueForProperty(cfp, withType:cpt, forEditing: true)
            styleLabelAsDefault(false)
            accessoryType = (cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpBoolean && cfp.boolValue.boolValue) ? .checkmark : .none
        }
        
        lblDescription.text = cpt.description;
        lblDescriptionBackground.layer.cornerRadius = 5;
        lblDescriptionBackground.layer.masksToBounds = true
        btnShowDescription.isHidden = cpt.description.isEmpty
        
        txt.isEnabled = true
        txt.isHidden = false
        txt.inputAccessoryView = vwAcc;
        updateLockStatus()
        
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            setNoText()
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            txt.placeholder = ""
            txt.keyboardType = .default
            // turn off autocorrect if we have previous values from which to choose.  This prevents spacebar from accepting the propoosed text.
            txt.autocapitalizationType = capitalizationForType()
            txt.autocorrectionType = (cpt.previousValues.string.count > 0 || txt.autocapitalizationType == .allCharacters) ? .no : .default
        case MFBWebServiceSvc_CFPPropertyType_cfpDate, MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            txt.placeholder = (cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDate) ?
            String(localized: "Tap for Today", comment:"Prompt on button to specify a date that is not yet specified") :
            String(localized: "Tap for Now", comment: "Prompt on button to specify a date/time that is not yet specified")
            dp.timeZone = UserPreferences.current.UseLocalTime ? NSTimeZone.system as TimeZone  : NSTimeZone(forSecondsFromGMT:0) as TimeZone
            dp.locale = UserPreferences.current.UseLocalTime ? NSLocale.current : Locale(identifier: "en-GB")
            txt.inputView = dp;
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
            txt.keyboardType = .decimalPad
            txt.setType(numericType: .Decimal, fHHMM:UserPreferences.current.HHMMPref)
            txt.autocorrectionType = .no
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
            // assume it's a time unless the PlainDecimal flags (0x00200000) is set, in which case force decimal
            txt.setType(numericType: (cpt.flags.uint32Value & 0x00200000) == 0 ? .Time : .Decimal, fHHMM:UserPreferences.current.HHMMPref)
            txt.autocorrectionType = .no
            txt.setValueWithDefault(num: cfp.decValue, numDefault: 0.0) // Fix bug #37. re-assign it; this will respect the number type.
            if (defVal != 0.0 && (txt.numberType() == .Time || cpt.propTypeID.intValue == PropTypeID.tachStart.rawValue)) {
                setXFill(defVal)
            }
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            txt.setType(numericType: .Integer, fHHMM: UserPreferences.current.HHMMPref)
            txt.keyboardType = .numberPad
            if (defVal != 0.0) {
                setXFill(defVal)
            }
        default:
            break
        }
    }
    
    @IBAction public func showDescription(_ sender : Any) {
        if !lblDescriptionBackground.isHidden {
            return
        }
        
        lblDescriptionBackground.alpha = 1.0
        UIView.animate(withDuration: 1.0) {
            self.lblDescriptionBackground.isHidden = false
            let transition = CATransition()
            transition.delegate = self
            transition.duration = 0.7
            transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
            transition.type = CATransitionType(rawValue: "pageUnCurl")
            self.lblDescriptionBackground.layer.add(transition, forKey: "pageUnCurl")
        }
        
        UIView.animate(withDuration: 1.0, delay: 3.0, options: .curveLinear, animations: {
            self.lblDescriptionBackground.alpha = 0.0
        }) { b in
            self.lblDescriptionBackground.isHidden = true
            self.lblDescriptionBackground.alpha = 1.0
        }
    }
    
    // Returns an autocompletion based on the given prefix.
    func proposeCompletion(_ szPrefix : String) -> String {
        if !szPrefix.isEmpty && cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpString && cpt.previousValues.string.count > 0 {
            let szText = szPrefix.lowercased()
            let strings = cpt.previousValues.string as! [String]
            for sz in strings {
                if sz.lowercased().hasPrefix(szText) {
                    return sz
                }
            }
        }
        return szPrefix
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            if string.isEmpty {
                return true
            }
            
            let sz = textField.text! as NSString
            
            // check for autocomplete
            let szUserTyped = sz.replacingCharacters(in: range, with: string)
            let szUserTypedWithCompletion = proposeCompletion(szUserTyped)
            if szUserTyped.compare(szUserTypedWithCompletion) != .orderedSame {
                let savedAutoCap = textField.autocapitalizationType
                textField.autocapitalizationType = .none
                textField.reloadInputViews()
                textField.text = szUserTypedWithCompletion;
                textField.autocapitalizationType = savedAutoCap
                let startPos = textField.position(from: textField.beginningOfDocument, offset: szUserTyped.count)
                let endPos = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: startPos!, to: endPos)
                return false
            }
            else {
                textField.autocapitalizationType = capitalizationForType()
                textField.reloadInputViews()
            }
            return true // any string can be edited
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean, MFBWebServiceSvc_CFPPropertyType_cfpDate, MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            return false
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency, MFBWebServiceSvc_CFPPropertyType_cfpDecimal, MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            // OK, at this point we have a number - either integer, decimal, or HH:MM.  Allow it if the result makes sense.
            let t = textField.text ?? ""
            return textField.isValidNumber(szProposed: t.replacingCharacters(in: Range(range, in: t)!, with: string))
        case MFBWebServiceSvc_CFPPropertyType_none:
            // should never happen
            return true
        default:
            // should never happen
            return true
        }
    }
}
