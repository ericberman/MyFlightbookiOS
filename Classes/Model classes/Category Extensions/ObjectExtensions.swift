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

extension NSDate {
    @objc public static func nowInUTC() -> Date {
        return Date()
    }
}
