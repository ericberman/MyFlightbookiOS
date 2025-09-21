/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023-2025 MyFlightbook, LLC
 
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
//  ObjectExtensions.swift
//  MFBSample
//
//  Created by Eric Berman on 2/20/23.
//

import Foundation

// This file includes extensions for built-in Apple objects

// MARK: NSNumber extensions
@objc public enum NumericType : Int {
    case Integer
    case Decimal
    case Time
}

extension NSNumber {
    @objc public func formatAsInteger() -> NSString {
        let nf = NumberFormatter()
        nf.usesGroupingSeparator = true
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 0
        return nf.string(from: self)! as NSString
    }
    
    @objc public func formatAsTime(fHHMM: Bool, fGroup: Bool) -> NSString {
        if (fHHMM) {
            let val = self.doubleValue
            let totalMinutes = Int(round(val * 60.0))
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60
            return NSString.init(format: "%d:%02d", hours, minutes)
        }
        else {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 2
            nf.minimumFractionDigits = 1
            nf.usesGroupingSeparator = fGroup
            return nf.string(from: self)! as NSString
        }
    }
    
    @objc public func formatAs(Type : NumericType, inHHMM: Bool, useGrouping: Bool) -> NSString {
        switch (Type) {
        case .Integer:
            return self.formatAsInteger()
        case .Time:
            return self.formatAsTime(fHHMM: inHHMM, fGroup: useGrouping)
        case .Decimal:
            return self.formatAsTime(fHHMM: false, fGroup: useGrouping)
        }
    }
}

private var UIB_ISHHMM_KEY: UInt8 = 0
private var UIB_NUMBER_TYPE_KEY: UInt8 = 0


// MARK: UITextField Extensions for DecimalEdit
extension UITextField {
    @objc(updateKeyboardType: numType:) public func updateKeyboardType(nt : Int, fIsHHMM : Bool) -> Void {
        updateKeyboardType(numericType: NumericType(rawValue: nt)!, fIsHHMM: fIsHHMM)
    }
    
    @objc(updateKeyboardForNumericType: fIsHHMM:) public func updateKeyboardType(numericType : NumericType, fIsHHMM : Bool) -> Void {
        switch (numericType) {
        case .Integer:
            keyboardType = .numberPad
            break
        case .Decimal:
            keyboardType = .decimalPad
            break
        case .Time:
            keyboardType = fIsHHMM ? .numbersAndPunctuation : .decimalPad
            break
        default:
            break
        }
    }
    
    public var isHHMM : Bool {
        get {
            let val = objc_getAssociatedObject(self, &UIB_ISHHMM_KEY) as? String ?? "N"
            return val == "Y"
        }
        set (val) {
            objc_setAssociatedObject(self, &UIB_ISHHMM_KEY, val ? "Y" : "N", objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            updateKeyboardType(numericType: numberType(), fIsHHMM: val)
            placeholder = NSNumber(floatLiteral: 0.0).formatAs(Type: numberType(), inHHMM: val, useGrouping: true) as String
        }
    }
        
    @objc(setNumberType: inHHMM:) public func setType(numericType: NumericType, fHHMM : Bool) -> Void {
        objc_setAssociatedObject(self, &UIB_NUMBER_TYPE_KEY, numericType, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        isHHMM = fHHMM
        updateKeyboardType(numericType: numericType, fIsHHMM: numericType == .Time && fHHMM)
        placeholder = NSNumber(floatLiteral: 0.0).formatAs(Type: numericType, inHHMM: fHHMM, useGrouping: true) as String
    }
    
    @objc public func NumberType() -> Int {
        return numberType().rawValue
    }
    
    @objc public func numberType() -> NumericType {
        return objc_getAssociatedObject(self, &UIB_NUMBER_TYPE_KEY) as? NumericType ?? .Decimal
    }
    
    @objc(valueForString: ofType: withHHMM:) public static func valueForString(sz : String?, numType : NumericType, fHHMM : Bool) -> NSNumber {
        if sz == nil || sz!.isEmpty {
            return NSNumber(floatLiteral: 0)
        }
        
        if (numType == .Time && fHHMM) {
            let rgPieces = sz!.components(separatedBy: ":")
            let cPieces = rgPieces.count
            var szH : String
            var szM : String
            
            if (cPieces == 0 || cPieces > 2) {
                return NSNumber(floatLiteral: 0.0)
            }
            szH = rgPieces[0]
            if (cPieces == 2) {
                szM = rgPieces[1]
                // pad or trim szM as appropriate
                switch (szM.count) {
                case 0:
                    szM = "00"
                    break
                case 1:
                    szM += "0"
                    break
                case 2:
                    break
                default:
                    szM = String(szM[..<szM.index(szM.startIndex, offsetBy: 2)])
                }
            } else {
                szM = "0"
            }
            
            if szH.isEmpty {
                szH = "0"
            }
            
            return NSNumber(floatLiteral: Double(szH)! + (Double(szM)! / 60.0))
        }
        else if numType == .Integer {
            return NSNumber(integerLiteral: Int(sz!)!)
        } else if numType == .Decimal || numType == .Time {
            // otherwise it is either explicitly a decimal, or it is a time but HHMM is false.
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            return nf.number(from: sz!)!
        }
        
        return NSNumber()
    }
    
    // Convenience method for integer numeric type from Objective-C
    @objc(valueForString: withType: withHHMM:) public static func valueForString(sz : String?, nt : Int, fHHMM : Bool) -> NSNumber {
        return valueForString(sz: sz, numType: NumericType(rawValue: nt)!, fHHMM: fHHMM)
    }
    
    @objc(stringFromNumber: forType: inHHMM: useGrouping:) public static func stringFromNumber(num : NSNumber, nt : Int, inHHMM: Bool, fGroup: Bool) -> NSString {
        return num.formatAs(Type: NumericType(rawValue: nt)!, inHHMM: inHHMM, useGrouping: fGroup)
    }
    
    @objc(stringFromNumber: forType: inHHMM:) public static func stringFromNumber(num: NSNumber, nt : Int, inHHMM: Bool) -> NSString {
        return num.formatAs(Type: NumericType(rawValue: nt)!, inHHMM: inHHMM, useGrouping: false)
    }
    
    @objc(value) public func getValue() -> NSNumber {
        return UITextField.valueForString(sz: text!, numType: numberType(), fHHMM: isHHMM)
    }
    
    @objc(setValue:) public func setValue(num : NSNumber) -> Void {
        text = num.formatAs(Type: numberType(), inHHMM: isHHMM, useGrouping: false) as String
    }
    
    @objc(setValue: withDefault:) public func setValueWithDefault(num : NSNumber, numDefault : NSNumber) {
        if num.doubleValue == numDefault.doubleValue {
            self.text = ""
        } else {
            setValue(num: num)
        }
    }
    
    @objc(isValidNumber:) public func isValidNumber(szProposed : String) -> Bool {
        let nt = numberType()
        if (nt == .Integer) {
            return szProposed.range(of: "^\\d*$", options: .regularExpression) != nil
        } else if (nt == .Decimal || (nt == .Time && !isHHMM)) {
            let nf = NumberFormatter()
            var szDec = nf.decimalSeparator
            if (szDec == ".") {
                szDec = "\\."
            }
            
            return szProposed.range(of: "^\\d*\(szDec!)?\\d*$", options: .regularExpression) != nil
        } else {
            // Must be hhmm
            return szProposed.range(of: "^\\d*:?\\d{0,2}$", options: .regularExpression) != nil
        }
    }
    
    @objc(crossFillFrom:) public func crossFillFrom(src : UITextField) {
        // animate the source button onto the target, change the value, then restore the source
        resignFirstResponder()
        
        let rSrc = src.frame;
        let rDst = frame;
        
        let tfTemp = UITextField(frame: rSrc)
        tfTemp.font = src.font;
        tfTemp.text = src.text;
        tfTemp.textAlignment = src.textAlignment;
        tfTemp.textColor = src.textColor;
        src.superview?.addSubview(tfTemp)
        
        src.translatesAutoresizingMaskIntoConstraints = false;
        UIView.animate(withDuration: 0.5,
                       animations: {
            tfTemp.frame = rDst
        },
                       completion: { finished in
            self.text = src.text
            UIView.animate(withDuration: 0.5, animations: {
                tfTemp.frame = rSrc
            },
                           completion: { finished in
                tfTemp.removeFromSuperview()
            })
        })
    }
}

// MARK: - TimeInterval extensions
extension TimeInterval {
    public func toHHMMSS() -> String {
        let h = Int(self / 3600.0)
        let m = Int(Double(Int(self) % 3600) / 60.0)
        let s = Int(self) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

// MARK: NSDate Extensions
extension NSDate {
    @objc(utcString:) public func utcString(useLocalTime: Bool) -> String {
        let df = DateFormatter()
        if (useLocalTime) {
            df.dateStyle = .short
            df.timeStyle = .short
            return "\(df.string(from: self as Date)) (\(TimeZone.current.abbreviation()!))"
        }
        else {
            df.dateFormat = "yyyy-MM-dd HH:mm"
            df.timeZone = TimeZone.init(secondsFromGMT: 0)
            return "\(df.string(from: self as Date)) (UTC)"
        }
    }
        
    public func dateString() -> String! {
        let df:DateFormatter! = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self as Date)
    }

    @objc(isUnknownDate:) static func isUnknownDate(dt : Date?) -> Bool {
        if dt == nil {
            return true
        }
        
        let dtOld = Date.distantPast
        
        // ASPX and Cocoa have different definitions for distantPast.  ASP.NET uses a year of 0001, so let's test for that.
        let cal = Calendar.current
        let comps = cal.dateComponents([.year , .month , .day], from: dt!)
        
        return (dt!.compare(dtOld) == .orderedSame || (comps.year ?? 0) < 100)
    }

    @objc(dateByAddingCalendarMonths:) public func dateByAddingCalendarMonths(cMonths:Int) -> Date! {
        var cal = Calendar(identifier: .gregorian)
        let utc = TimeZone(secondsFromGMT: 0)!
        cal.timeZone = utc
        var comps = cal.dateComponents(in: utc, from: self as Date)
        var compsDelta = DateComponents()
        compsDelta.timeZone = utc
        
        // go to the first day of this month
        comps.day = 1
        var dt = cal.date(from: comps)
        
        if cMonths >= 0
        {
            // Proper way to do this is to add an extra month and then back off a day.  E.g., 7/1/2019 + 12 months goes 13 months ahead to 8/1/2020 and then backs up to 7/31/2020
            // HOWEVER, NSCalendar's math is messed up - adding 13 months to 7/1/2019 yields 7/31/2020 instead of 8/1/2019.  Bizarre - must be using a fixed 365 day year or something.
            // Why?  Because, as I've said a million times before, FUCK APPLE!
            // So let's add years before months
            // we've already backed up to the 1st of the month, so we can instead just add one to the # of months to add.
            var compNew = DateComponents()
            var year = comps.year! + (cMonths + 1) / 12
            var month = comps.month! + (cMonths + 1) % 12
            while  month > 12 {
                year += 1   // why doesn't swift support ++?  Becuase FUCK APPLE!!!
                month -= 12
            }
            compNew.day = 1
            compNew.month = month
            compNew.year = year
            // and why doesn't swift support chaining expressions?  Because FUCK APPLE!!!
            compNew.hour = 0
            compNew.minute = 0
            compNew.second = 0
            compNew.timeZone = utc
            compNew.calendar = cal
            dt = cal.date(from: compNew)?.addingTimeInterval(-24*60*60)
            return dt!
        }
        else
        {
            compsDelta.month = cMonths
            return cal.date(byAdding: compsDelta, to: dt!)!
        }
    }

    @objc public func dateByTruncatingSeconds() -> Date! {
        let time = floor(self.timeIntervalSinceReferenceDate / 60.0) * 60.0
        return Date(timeIntervalSinceReferenceDate: time)
    }
    
    // Inside a soap call, dates get converted to XML using their UTC equivalent.
    // If we're dealing with a date in local form, we want to preserve that without regard
    // to time zone.  E.g., if it is 10pm on March 3 in Seattle, that's 5am March 4 UTC, but
    // we will want the date to pass as March 3.  So we must provide a UTC version of the date that will survive
    // this process with the correct day/month/year.
    // Due to daylight savings time issues, we do this by decomposing the local date into its constituent
    // month/day/year.  THEN set the timezone to create a new UTC date that looks like that date/time
    // we can then restore the timezone and return that date.  Note that we will do one timezone switch for each
    // date that is reconfigured, and will
    public func UTCDateFromLocalDate() -> Date {
        var cal = Calendar.current
        var comps = cal.dateComponents([.year , .month , .day], from: self as Date)
        
        let year = comps.year
        let month = comps.month
        let day = comps.day
        comps.day = day
        comps.month = month
        comps.year = year
        comps.hour = 12 // same date everywhere in the world - just be safe!
        comps.minute = 0
        comps.second = 0
       
        let tzDefault = cal.timeZone
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let dtReturn = cal.date(from: comps)
        cal.timeZone = tzDefault
        
        return dtReturn!
        }

    // Reverse of UTCDateFromLocalDate.
    // Given a UTC date, produces a local date that looks the same.  E.g., if it is
    // 8/25/2012 02:00 UTC, that is 8/24/2012 19:00 PDT.  We want this date to look
    // like 8/25, though.
    public func LocalDateFromUTCDate() -> Date {
        var cal = Calendar.current
        let tzDefault = cal.timeZone
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        var comps = cal.dateComponents([.year, .month, .day], from: self as Date)
        // get the day/month/year
        let year = comps.year
        let month = comps.month
        let day = comps.day
        cal.timeZone = tzDefault
        comps.day = day
        comps.month = month
        comps.year = year
        comps.hour = 12 // same date everywhere in the world - just be safe!
        comps.minute = 0
        comps.second = 0
       
        return cal.date(from: comps)!
    }
}

// MARK: Date extensions
extension Date {
    public static func getYYYYMMDDFormatter() -> DateFormatter{
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }
    
    public func utcString(useLocalTime: Bool) -> String {
        return (self as NSDate).utcString(useLocalTime: useLocalTime)
    }
}

// MARK: UIViewController
extension UIViewController {    
    @objc(showAlertWithTitle: message:) public func showAlertWithTitle(title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "Close", comment: "Close button on error message"), style: .cancel))
        self.present(alert, animated: true)
    }
    
    @objc(showErrorAlertWithMessage:) public func showErrorAlertWithMessage(msg : String) {
        self.showAlertWithTitle(title: String(localized: "Error", comment: "Title for generic error message"), message: msg)
    }
    
    @objc(pushOrPopView:fromView:withDelegate:) public func pushOrPopView(target : UIViewController, sender :AnyObject, delegate : UIPopoverPresentationControllerDelegate) {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            target.modalPresentationStyle = .popover
            target.navigationController?.isNavigationBarHidden = false
            let ppc = target.popoverPresentationController!
            ppc.sourceView = self.view
            if let vw = sender as? UIView {
                ppc.sourceRect = vw.bounds
                ppc.sourceView = vw
            }
            else if let bbi = sender as? UIBarButtonItem {
                ppc.barButtonItem = bbi
            }
            ppc.permittedArrowDirections = .any
            ppc.delegate = delegate
            self.present(target, animated: true)
        }
        else {
            self.navigationController?.pushViewController(target, animated: true)
        }
    }
}

// MARK: NSAttributedString extensions

extension NSAttributedString {
    @objc(attributedStringFromMarkDown: size:) public static func attributedStringFromMarkDown(sz : NSString, size: CGFloat) -> NSAttributedString {
        let baseFont = UIFont.systemFont(ofSize: size)
        let boldFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: baseFont.pointSize)
        let italicFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: baseFont.pointSize)
        let textColor = UIColor.label
        var lastPos = Int(0)
        
        let attr = NSMutableAttributedString(string: "", attributes: [.font : baseFont, .foregroundColor  : textColor])

        let reg = try! NSRegularExpression(pattern: "(\\*[^*_\r\n]*\\*)|(_[^*_\r\n]*_)", options: .caseInsensitive)
        reg.enumerateMatches(in: sz as String, range: NSRange((sz as String).startIndex..., in:sz as String)) { match, flags, stop in
            let matchRange = match?.range
            if (matchRange != nil) {
                let r = matchRange!
                if (r.location > lastPos) {
                    let range = NSMakeRange(lastPos, r.location - lastPos)
                    attr.append(NSAttributedString(string: sz.substring(with: range), attributes: [.font : baseFont, .foregroundColor : textColor]))
                }
                if (r.length >= 2 && sz.length >= r.location + r.length) {
                    let matchText = sz.substring(with: r) as NSString
                    let matchType = matchText.substring(to: 1)
                    let matchContent = matchText.substring(with: NSMakeRange(1, matchText.length - 2))
                    if (matchType == "*") {
                        attr.append(NSAttributedString(string: matchContent, attributes:[.font : boldFont, .foregroundColor : textColor]))
                    }
                    else if (matchType == "_") {
                        attr.append(NSAttributedString(string: matchContent, attributes:[.font : italicFont, .foregroundColor : textColor]))
                    }
                    lastPos = r.location + r.length
                }
            }
        }
        
        if (lastPos < sz.length) {
            attr.append(NSAttributedString(string: sz.substring(with: NSMakeRange(lastPos, sz.length - lastPos)), attributes:[.font : baseFont, .foregroundColor : textColor]))
        }
        return attr
    }
}

// MARK: UITableViewController extensions
extension UITableViewController {
    
    public func nextCell(ipCurrent : IndexPath) -> IndexPath {
        let cSections = numberOfSections(in: tableView)
        let cRowsInSection = self.tableView(tableView, numberOfRowsInSection: ipCurrent.section)
        
        // check for last cell
        if (ipCurrent.section >= cSections - 1 && ipCurrent.row >= cRowsInSection - 1) {
            return ipCurrent
        }
         
        if (ipCurrent.row < cRowsInSection - 1) {
            return IndexPath(row: ipCurrent.row + 1, section: ipCurrent.section)
        }
        else {
            var sect = ipCurrent.section + 1
            while (sect < cSections && self.tableView(tableView, numberOfRowsInSection: sect) == 0) {
                sect += 1
            }
            return (sect < cSections) ? IndexPath(row: 0, section: ipCurrent.section + 1) : ipCurrent
        }
    }
    
    @objc(nextCell:) public func nextCell(ipCurrent : NSIndexPath) -> NSIndexPath {
        return nextCell(ipCurrent: ipCurrent as IndexPath) as NSIndexPath
    }

    public func prevCell(ipCurrent : IndexPath) -> IndexPath {
        // check for 1st cell
        if (ipCurrent.section == 0 && ipCurrent.row == 0) {
            return ipCurrent
        }
         
        if (ipCurrent.row > 0) {
            return IndexPath(row: ipCurrent.row - 1, section: ipCurrent.section)
        }
        else {
            var sect = ipCurrent.section - 1
            while (sect >= 0 && self.tableView(tableView, numberOfRowsInSection: sect) == 0) {
                sect -= 1
            }
            
            return (sect < 0) ? ipCurrent : IndexPath(row: self.tableView(tableView, numberOfRowsInSection: sect) - 1, section: sect)
        }
    }
    
    @objc(prevCell:) public func prevCell(ipCurrent : NSIndexPath) -> NSIndexPath {
        return prevCell(ipCurrent: ipCurrent as IndexPath) as NSIndexPath
    }
}

// MARK: UITableViewCell extensions
extension UITableViewCell {
    @objc public func makeTransparent() {
        backgroundColor = UIColor.clear
        backgroundView = UIView(frame: CGRect.zero)
        selectionStyle = .none
    }
}

// MARK: NSString extensions
extension NSString {
    @objc(stringFromCharsThatCouldBeNull:) public static func stringFromCharsThatCouldBeNull(pch : UnsafePointer<CChar>?) -> String {
        return pch == nil ? "" : String(cString: pch!)
    }
}

// MARK: NSHTTPCookiesStorage
// From http://stackoverflow.com/questions/26005641/are-cookies-in-uiwebview-accepted for cookie storage.
extension HTTPCookieStorage {
    private func KeyName() -> String {
        return "cookies"
    }
    
    @objc public func saveToUserDefaults() {
        let userDefaults = UserDefaults.standard
        if (cookies?.count ?? 0 > 0) {
            let cookieData = try! NSKeyedArchiver.archivedData(withRootObject: self.cookies!, requiringSecureCoding: true)
            userDefaults.set(cookieData, forKey: KeyName())
        } else {
            userDefaults.removeObject(forKey: KeyName())
        }
    }
    
    @objc public func loadFromUserDefaults() {
        if let cookieData = UserDefaults.standard.object(forKey: KeyName()) as? Data {
            let cookies = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: cookieData)
            
            if let rgcookies = cookies as? [HTTPCookie] {
                for cookie in rgcookies {
                    self.setCookie(cookie)
                }
            }
        }
    }
}

// MARK: String extensions - because string.index is a fucking nightmare.  Why can't you just use integer *character* (yes, I know they're varying length) positions?
// this is stolen from https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift#:~:text=Using%20an%20Int%20index%20extension%3F
extension String {
  subscript(_ i: Int) -> String {
    let idx1 = index(startIndex, offsetBy: i)
    let idx2 = index(idx1, offsetBy: 1)
    return String(self[idx1..<idx2])
  }

  subscript (r: Range<Int>) -> String {
    let start = index(startIndex, offsetBy: r.lowerBound)
    let end = index(startIndex, offsetBy: r.upperBound)
    return String(self[start ..< end])
  }

  subscript (r: CountableClosedRange<Int>) -> String {
    let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
    let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
    return String(self[startIndex...endIndex])
  }
    
    public static func stringFromCharsThatCouldBeNull(_ pch : UnsafePointer<UInt8>?) -> String {
        return pch == nil ? "" : String(cString: pch!)
    }
}

// MARK: Double extensions
extension Double {
    public func asLatString() -> String {
        return String(format:"%.3f°%@", abs(self), self > 0 ? "N" : "S")
    }
    
    public func asLonString() -> String {
        return String(format:"%.3f°%@", abs(self), self > 0 ? "E" : "W")
    }
    
    public func degreesToRadians() -> Double {
        return self * (Double.pi / 180.0)
    }
}

// MARK: UIButton (implementation of checkbox functionality)
extension UIButton {
    @objc public func setIsCheckbox() -> Void {
        setImage(UIImage(named: "Checkbox-Sel"), for: .selected)
        setImage(UIImage(named: "Checkbox"), for: .normal)
        addTarget(self, action: #selector(UIButton.toggleCheck), for: .touchUpInside)
        let backColor = UIColor.clear
        let checkColor = UIColor.label
        layer.backgroundColor = backColor.cgColor
        layer.borderColor = backColor.cgColor
        backgroundColor = backColor
        
        setTitleColor(checkColor, for: .normal)
        setTitleColor(checkColor, for: .focused)
        setTitleColor(checkColor, for: .selected)
        setTitleColor(checkColor, for: .highlighted)
    }
    
    @objc(toggleCheck:) @IBAction public func toggleCheck(sender: AnyObject) -> Void {
        isSelected = !isSelected
    }
    
    @objc(setCheckboxValue:) public func setCheckboxValue(value : Bool) -> Void {
        isSelected = value
    }
}

// MARK: UIColor extension because F***ing apple doesn't provide this already?!?  In 2024?  WTF?
// Code here from https://ditto.live/blog/swift-hex-color-extension
extension UIColor {
    // Initializes a new UIColor instance from a hex string
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        let scanner = Scanner(string: hexString)

        var rgbValue: UInt64 = 0
        guard scanner.scanHexInt64(&rgbValue) else {
            return nil
        }

        var red, green, blue, alpha: UInt64
        switch hexString.count {
        case 6:
            red = (rgbValue >> 16)
            green = (rgbValue >> 8 & 0xFF)
            blue = (rgbValue & 0xFF)
            alpha = 255
        case 8:
            red = (rgbValue >> 16)
            green = (rgbValue >> 8 & 0xFF)
            blue = (rgbValue & 0xFF)
            alpha = rgbValue >> 24
        default:
            return nil
        }

        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }
    
    // Returns a hex string representation of the UIColor instance
    func toHexString(includeAlpha: Bool = false) -> String? {
        // Get the red, green, and blue components of the UIColor as floats between 0 and 1
        guard let components = self.cgColor.components else {
            // If the UIColor's color space doesn't support RGB components, return nil
            return nil
        }
        
        // Convert the red, green, and blue components to integers between 0 and 255
        let red = Int(components[0] * 255.0)
        let green = Int(components[1] * 255.0)
        let blue = Int(components[2] * 255.0)
        
        // Create a hex string with the RGB values and, optionally, the alpha value
        let hexString: String
        if includeAlpha, let alpha = components.last {
            let alphaValue = Int(alpha * 255.0)
            hexString = String(format: "#%02X%02X%02X%02X", red, green, blue, alphaValue)
        } else {
            hexString = String(format: "#%02X%02X%02X", red, green, blue)
        }
        
        // Return the hex string
        return hexString
    }
}
// MARK: - Extension for UIViewController
// Because Apple with iOS 26 completely broke toolbars, we need this Claude-generated extension to preserve basic functionality.  FUCK APPLE for not caring about backwards compatibility.
extension UIViewController {
    
    private static var customToolbarKey: UInt8 = 0
    private static var tabControllerToolbarKey: UInt8 = 1
    
    // Associated object to store the custom toolbar per tab bar controller
    private var sharedCustomToolbar: UIToolbar? {
        get {
            guard let tabController = tabBarController else { return nil }
            return objc_getAssociatedObject(tabController, &Self.tabControllerToolbarKey) as? UIToolbar
        }
        set {
            guard let tabController = tabBarController else { return }
            objc_setAssociatedObject(tabController, &Self.tabControllerToolbarKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Associated object to store the custom toolbar
    private var customToolbar: UIToolbar? {
        get {
            return sharedCustomToolbar
        }
        set {
            sharedCustomToolbar = newValue
        }
    }
    
    /// Call this in viewDidLoad to set up toolbar compatibility
    func setupToolbarCompatibility() {
        // Remove this method - toolbar creation is now handled automatically
        // when setCompatibleToolbarItems is called
    }
    
    /// Call this in viewWillAppear instead of setting toolbarItems directly
    func setCompatibleToolbarItems(_ items: [UIBarButtonItem], animated: Bool = false) {
        if #available(iOS 26.0, *) {
            // For iOS 26, completely disable the system toolbar
            navigationController?.isToolbarHidden = true
            
            // If this is a table view controller, we need to adjust content insets
            if let tableVC = self as? UITableViewController {
                tableVC.tableView.contentInsetAdjustmentBehavior = .never
                // Manually set bottom inset to account for tab bar + our toolbar
                let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
                let toolbarHeight = UIToolbar().intrinsicContentSize.height
                tableVC.tableView.contentInset.bottom = tabBarHeight + toolbarHeight
                tableVC.tableView.verticalScrollIndicatorInsets.bottom = tabBarHeight + toolbarHeight
            }
            
            // Always ensure custom toolbar exists when we need to set items
            if customToolbar == nil {
                setupCustomToolbar()
            }
            
            // Show and configure the toolbar
            customToolbar?.setItems(items, animated: animated)
            customToolbar?.isHidden = false
        } else {
            navigationController?.isToolbarHidden = false
            if animated {
                setToolbarItems(items, animated: true)
            } else {
                toolbarItems = items
            }
        }
    }
    
    /// Call this to hide/show the toolbar
    func setCompatibleToolbarHidden(_ hidden: Bool, animated: Bool = false) {
        if #available(iOS 26.0, *) {
            if animated {
                UIView.animate(withDuration: 0.3) {
                    self.customToolbar?.alpha = hidden ? 0 : 1
                }
            } else {
                customToolbar?.isHidden = hidden
            }
            
            // If hiding and this is a table view controller, reset content insets
            if hidden, let tableVC = self as? UITableViewController {
                let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
                tableVC.tableView.contentInset.bottom = tabBarHeight
                tableVC.tableView.verticalScrollIndicatorInsets.bottom = tabBarHeight
            }
        } else {
            navigationController?.setToolbarHidden(hidden, animated: animated)
        }
    }
    
    // MARK: - Private Implementation
    
    private func setupCustomToolbar() {
        // Don't create if already exists
        guard customToolbar == nil else { return }
        
        // Ensure we have a view hierarchy
        guard view.superview != nil || isViewLoaded else {
            print("View not ready, deferring toolbar setup")
            return
        }
        
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure appearance to match system toolbar
        if #available(iOS 15.0, *) {
            let appearance = UIToolbarAppearance()
            appearance.configureWithOpaqueBackground()
            toolbar.standardAppearance = appearance
            toolbar.compactAppearance = appearance
            toolbar.scrollEdgeAppearance = appearance
        } else {
            toolbar.isTranslucent = false
            toolbar.barTintColor = UIColor.systemBackground
        }
        
        // Always add to the tab bar controller's view for consistency
        guard let targetView = tabBarController?.view ?? navigationController?.view ?? view else {
            print("No target view available for toolbar")
            return
        }
        
        print("Adding toolbar to tab bar controller view: \(targetView.frame)")
        targetView.addSubview(toolbar)
        print("Toolbar superview after adding: \(String(describing: toolbar.superview))")
        
        // Get dynamic toolbar height
        let toolbarHeight = toolbar.intrinsicContentSize.height
        
        // Position relative to the target view, using safe area to avoid constraint conflicts
        let bottomConstraint: NSLayoutConstraint
        if let tabBar = tabBarController?.tabBar {
            print("Tab bar frame: \(tabBar.frame)")
            // Calculate offset from safe area to position above tab bar
            let tabBarHeight = tabBar.frame.height
            bottomConstraint = toolbar.bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor, constant: -tabBarHeight)
            print("Using calculated offset: -\(tabBarHeight)")
        } else {
            // Fallback to safe area
            bottomConstraint = toolbar.bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor)
            print("Using safe area bottom")
        }
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: targetView.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: targetView.trailingAnchor),
            bottomConstraint,
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight)
        ])
        
        customToolbar = toolbar
        
        // Force layout immediately
        targetView.layoutIfNeeded()
        
        // Debug output
        print("Custom toolbar created with frame: \(toolbar.frame)")
        DispatchQueue.main.async {
            print("Custom toolbar final frame: \(toolbar.frame)")
            print("Toolbar items count: \(toolbar.items?.count ?? 0)")
        }
    }
}
