/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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

// MARK: NSNumber extensions
@objc public enum NumericType : Int {
    case Integer
    case Decimal
    case Time
}

extension NSNumber {
    @objc public func formatAsInteger() -> NSString {
        return NSString.init(format: "%d", intValue)
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

extension MFBWebServiceSvc_TotalsItem {
    @objc public func formattedValue(fHHMM : Bool) -> NSString {
        let nt = numericType as MFBWebServiceSvc_NumType
        switch (nt) {
            case MFBWebServiceSvc_NumType_Integer:
                return value.formatAsInteger()
            case MFBWebServiceSvc_NumType_Currency:
                let nsf = NumberFormatter()
                nsf.numberStyle = .currency
                return nsf.string(from: value)! as NSString
            case MFBWebServiceSvc_NumType_Decimal:
                return self.value.formatAs(Type: .Decimal, inHHMM: fHHMM, useGrouping: true)
            case MFBWebServiceSvc_NumType_Time:
                return self.value.formatAs(Type: .Time, inHHMM: fHHMM, useGrouping: true)
            default:
                return value.formatAsInteger()
            }
    }
    
    @objc public static func Group(items : Array<MFBWebServiceSvc_TotalsItem>) -> NSMutableArray {
        let d = NSMutableDictionary()
        for ti in items {
            let key = Int(ti.group.rawValue)
            if (d[key] == nil) {
                d[key] = NSMutableArray()
            }
            if let arr = d[key] as? NSMutableArray {
                arr.add(ti)
            }
        }
        
        let result = NSMutableArray()
        for group in MFBWebServiceSvc_TotalsGroup_none.rawValue ... MFBWebServiceSvc_TotalsGroup_Total.rawValue {
            let key = Int(group)
            if let arr = d[key] {
                result.add(arr)
            }
        }
        return result
    }
}

extension MFBWebServiceSvc_CurrencyStatusItem {
    @objc public func formattedTitle() -> String {
        if (attribute.range(of:"<a href", options: .caseInsensitive) != nil) {
            let csHtmlTag = CharacterSet(charactersIn: "<>")
            let a = attribute.components(separatedBy: csHtmlTag)
            return "\(a[2])\(a[4])"
        }
        return attribute
    }
}
