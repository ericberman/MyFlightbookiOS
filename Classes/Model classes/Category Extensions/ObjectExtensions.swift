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
        
    @objc public func dateString() -> String! {
        let df:DateFormatter! = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: self as Date)
    }

    @objc(isUnknownDate:) static func isUnknownDate(dt : Date!) -> Bool {
        if dt == nil {
            return true
        }
        
        let dtOld = Date.distantPast
        
        // ASPX and Cocoa have different definitions for distantPast.  ASP.NET uses a year of 0001, so let's test for that.
        let cal = Calendar.current
        let comps = cal.dateComponents([.year , .month , .day], from: dt)
        
        return (dt.compare(dtOld) == .orderedSame || comps.year == 1)
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
}
