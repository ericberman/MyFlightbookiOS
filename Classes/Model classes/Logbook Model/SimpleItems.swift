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
//  SimpleItems.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/22/23.
//

import Foundation

// Note that we MUST decorate the classes with "@objc(name-of-class)" so that these are correctly received from a namespace perspective by the watchkit extension.
// Otherwise archive/dearchive doesn't work because the class names (with namespaces) don't line up.
// Alternatively, we could also put these into a framework
// See https://stackoverflow.com/questions/29472935/cannot-decode-object-of-class for more information.

@objc(SimpleCurrencyItem) public class SimpleCurrencyItem : NSObject, NSCoding, NSSecureCoding {
    public var attribute = ""
    public var value = ""
    public var discrepancy = ""
    public var state : MFBWebServiceSvc_CurrencyState = MFBWebServiceSvc_CurrencyState_none
    
    private let keyCurAttribute = "curAttribute"
    private let keyCurValue = "curValue"
    private let keyCurDiscrepancy = "curDiscrepancy"
    private let keyCurState = "curState"
    
    public override init() {
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        attribute = coder.decodeObject(forKey: keyCurAttribute) as? String ?? ""
        value = coder.decodeObject(forKey: keyCurValue) as? String ?? ""
        discrepancy = coder.decodeObject(forKey: keyCurDiscrepancy) as? String ?? ""
        if let raw = coder.decodeObject(forKey: keyCurState) as? Int {
            state = MFBWebServiceSvc_CurrencyState(rawValue: UInt32(raw))
        }
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(attribute, forKey: keyCurAttribute)
        coder.encode(value, forKey: keyCurValue)
        coder.encode(discrepancy, forKey: keyCurDiscrepancy)
        coder.encode(state.rawValue, forKey:keyCurState)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
}

@objc(SimpleTotalItem) public class SimpleTotalItem : NSObject, NSCoding, NSSecureCoding {
    public var title = ""
    public var valueDisplay = ""
    public var subDesc = ""
    
    private let keyTotalTitle = "totTitle"
    private let keyTotalValue = "totValue"
    private let keyTotalSubDesc = "totSubDesc"
    
    public override init() {
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        title = coder.decodeObject(forKey: keyTotalTitle) as? String ?? ""
        valueDisplay = coder.decodeObject(forKey: keyTotalValue) as? String ?? ""
        subDesc = coder.decodeObject(forKey: keyTotalSubDesc) as? String ?? ""
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(title, forKey: keyTotalTitle)
        coder.encode(valueDisplay, forKey: keyTotalValue)
        coder.encode(subDesc, forKey: keyTotalSubDesc)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
}

@objc(SimpleLogbookEntry) public class SimpleLogbookEntry : NSObject, NSCoding, NSSecureCoding {
    public var comment = ""
    public var route = ""
    public var date = Date()
    public var totalTimeDisplay = ""
    public var tailNumDisplay = ""
    
    private let keyLEComment = "LEComment"
    private let keyLERoute = "LERoute"
    private let keyLEDate = "LEDate"
    private let keyLETotal = "LETotal"
    private let keyLETailDisplay = "LETail"
    
    public override init() {
        super.init()
    }
    
    public required convenience init?(coder: NSCoder) {
        self.init()
        comment = coder.decodeObject(forKey: keyLEComment) as? String ?? ""
        route = coder.decodeObject(forKey: keyLERoute) as? String ?? ""
        date = coder.decodeObject(forKey: keyLEDate) as? Date ?? Date()
        totalTimeDisplay = coder.decodeObject(forKey: keyLETotal) as? String ?? ""
        tailNumDisplay = coder.decodeObject(forKey: keyLETailDisplay) as? String ?? ""
    }

    public func encode(with coder: NSCoder) {
        coder.encode(comment, forKey: keyLEComment)
        coder.encode(route, forKey: keyLERoute)
        coder.encode(date, forKey: keyLEDate)
        coder.encode(totalTimeDisplay, forKey: keyLETotal)
        coder.encode(tailNumDisplay, forKey: keyLETailDisplay)
    }
    
    public static var supportsSecureCoding: Bool {
        return true
    }
}
