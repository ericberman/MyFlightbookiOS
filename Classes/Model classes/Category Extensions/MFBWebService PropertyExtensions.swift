/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2009-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
//
//  MFBWebService PropertyExtensions.swift
//  MFBSample
//
//  Created by Eric Berman on 3/11/23.
//

import Foundation
import SQLite3

// MARK: MFBWebServiceSvc_ArrayOfCustomFlightProperty extensions
extension MFBWebServiceSvc_ArrayOfCustomFlightProperty {
    private static var _szKeyPropArray : String {
        get {
            return "keycfpPropArray"
        }
    }
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(self.customFlightProperty, forKey: MFBWebServiceSvc_ArrayOfCustomFlightProperty._szKeyPropArray)
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder : NSCoder) {
        self.init()
        do {
            let rgProps = try decoder.decodeTopLevelObject(of: [NSArray.self, MFBWebServiceSvc_CustomFlightProperty.self, MFBWebServiceSvc_CustomPropertyType.self],
                                                           forKey: MFBWebServiceSvc_ArrayOfCustomFlightProperty._szKeyPropArray) as? NSArray
            for cfp in rgProps! {
                customFlightProperty.add(cfp)
            }
        }
        catch { }
    }
    
    @objc public func setProperties(_ ar : [MFBWebServiceSvc_CustomFlightProperty]) {
        customFlightProperty.removeAllObjects()
        customFlightProperty.addObjects(from: ar)
    }
    
}

// MARK: MFBWebServiceSvc_CustomPropertyType extensions
extension MFBWebServiceSvc_CustomPropertyType {

    // Convenience method - we're computing isLocked, no longer storing it
    @objc public var isLocked : Bool {
        get {
            return FlightProps.isLockedProperty(propTypeID.intValue)
        }
        set(val) {
            FlightProps.setPropLock(val, forPropTypeID: propTypeID.intValue)
        }
    }

    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encodeCInt(Int32(type.rawValue), forKey: "cptType")
        encoder.encode(title, forKey: "cptTitle")
        encoder.encode(sortKey, forKey: "cptSortKey")
        encoder.encode(propTypeID, forKey: "cptPropTypeID")
        encoder.encode(formatString, forKey: "cptFormatString")
        encoder.encode(description, forKey: "cptDescription")
        encoder.encode(previousValues, forKey: "cptPrevValues")
        encoder.encode(flags, forKey: "cptFlags")
        encoder.encode(isFavorite.boolValue, forKey: "cptFavoriteBOOL")
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder : NSCoder) {
        self.init()

        type = MFBWebServiceSvc_CFPPropertyType(rawValue: UInt32(decoder.decodeCInt(forKey: "cptType")))
        title = decoder.decodeObject(of: NSString.self, forKey: "cptTitle")! as String
        sortKey = decoder.decodeObject(of: NSString.self, forKey: "cptSortKey")! as String
        propTypeID = decoder.decodeObject(of: NSNumber.self, forKey: "cptPropTypeID")! as NSNumber
        formatString = decoder.decodeObject(of: NSString.self, forKey: "cptFormatString")! as String
        description = decoder.decodeObject(of: NSString.self, forKey: "cptDescription")! as String
        previousValues = try! decoder.decodeTopLevelObject(of: [MFBWebServiceSvc_ArrayOfString.self, NSString.self, NSMutableArray.self],
                                                           forKey: "cptPrevValues")! as! MFBWebServiceSvc_ArrayOfString
        flags = decoder.decodeObject(of: NSNumber.self, forKey: "cptFlags")! as NSNumber
        isFavorite = USBoolean(bool: decoder.decodeBool(forKey: "cptFavoriteBOOL"))
    }
    
    @objc(initFromRow:) public convenience init(_ row : OpaquePointer) {
        self.init()
        propTypeID = NSNumber(integerLiteral: Int(sqlite3_column_int(row, 0)))
        title = String.stringFromCharsThatCouldBeNull(sqlite3_column_text(row, 1))
        sortKey = String.stringFromCharsThatCouldBeNull(sqlite3_column_text(row, 2))
        if sortKey.isEmpty {
            sortKey = title
        }
        formatString = String.stringFromCharsThatCouldBeNull(sqlite3_column_text(row, 3))
        type = MFBWebServiceSvc_CFPPropertyType(rawValue: UInt32(sqlite3_column_int(row, 4) + 1))
        flags = NSNumber(integerLiteral: Int(sqlite3_column_int(row, 5)))
        description = String.stringFromCharsThatCouldBeNull(sqlite3_column_text(row, 3))
        isFavorite = USBoolean(bool: false)
        previousValues = MFBWebServiceSvc_ArrayOfString()
    }
}


// MARK: MFBWebServiceSvc_CustomFlightProperty extensions
private let _szKeyPropID = "keycfpPropID"
private let _szKeyFlightID = "keycfpFlightID"
private let _szKeyPropTypeID = "keycfpPropTypeID"
private let _szKeyIntVal = "keycfpIntVal"
private let _szKeyBoolVal = "keycfpBoolVal"
private let _szKeyDecVal = "keycfpDecVal"
private let _szKeyTextVal = "keycfpTextVal"
private let _szKeyDateVal = "keycfpDateVal"

extension MFBWebServiceSvc_CustomFlightProperty {
    @objc public static func getNewFlightProperty() -> MFBWebServiceSvc_CustomFlightProperty {
        let cfp = MFBWebServiceSvc_CustomFlightProperty()
        cfp.propTypeID = NSNumber(integerLiteral: -1)
        cfp.propID = NSNumber(integerLiteral: -1)
        cfp.flightID = NSNumber(integerLiteral: -1)
        cfp.intValue = NSNumber(integerLiteral: 0)
        cfp.decValue = NSNumber(floatLiteral: 0.0)
        cfp.boolValue = USBoolean(bool: false)
        cfp.dateValue = nil
        cfp.textValue = ""
        return cfp
    }
    
    @objc public func isDefaultForType(_ cpt : MFBWebServiceSvc_CustomPropertyType) -> Bool {
        switch (cpt.type) {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            return boolValue == nil || !boolValue.boolValue
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency, MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
            return decValue == nil || decValue.doubleValue == 0.0
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            return intValue == nil || intValue.intValue == 0
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            return textValue ==  nil || textValue.isEmpty
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime, MFBWebServiceSvc_CFPPropertyType_cfpDate:
            return dateValue == nil
        default:
            break
        }
        return false
    }
    
    @objc public func setDefaultForType(_ cpt : MFBWebServiceSvc_CustomPropertyType) {
        switch (cpt.type) {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            boolValue = USBoolean(bool: false)
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency, MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
            decValue = NSNumber(floatLiteral: 0.0)
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            intValue = NSNumber(integerLiteral: 0)
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            textValue = ""
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime, MFBWebServiceSvc_CFPPropertyType_cfpDate:
            dateValue = nil
        default:
            break
        }
    }
    
    @objc(formatForDisplay::::) public func formatForDisplay(_ labelColor : UIColor, valueColor : UIColor, labelFont : UIFont, valueFont : UIFont) -> NSAttributedString {
        let rgCpt = FlightProps.sharedPropTypes
        var s = AttributedString("", attributes: AttributeContainer([.font : labelFont, .foregroundColor : labelColor]))
        for cpt in rgCpt {
            if cpt.propTypeID.intValue == propTypeID.intValue {
                let sValue = AttributedString(FlightProps.stringValueForProperty(self, withType: cpt), attributes: AttributeContainer([.font : valueFont, .foregroundColor : valueColor]))
                s.append(AttributedString(cpt.formatString, attributes: AttributeContainer([.font: labelFont, .foregroundColor : labelColor])))
                
                // Replace {0} with the value.  Booleans don't have a "{0}" so just append the checkmark
                if let r = s.range(of: "{0}")  {
                    s.replaceSubrange(r, with: sValue)
                } else {
                    s.append(sValue)
                }
            }
        }
        return NSAttributedString(s)
    }

    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(propID, forKey: _szKeyPropID)
        encoder.encode(flightID, forKey: _szKeyFlightID)
        encoder.encode(propTypeID, forKey: _szKeyPropTypeID)
        encoder.encode(intValue, forKey: _szKeyIntVal)
        encoder.encode(boolValue.boolValue, forKey: _szKeyBoolVal)
        encoder.encode(decValue, forKey: _szKeyDecVal)
        encoder.encode(textValue, forKey: _szKeyTextVal)
        encoder.encode(dateValue, forKey: _szKeyDateVal)
    }
    
    @objc(initWithCoderMFB:) public convenience init(decoder : NSCoder) {
        self.init()
        propID = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyPropID)
        flightID = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyFlightID)
        propTypeID = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyPropTypeID)
        intValue = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyIntVal)
        boolValue = USBoolean(bool: decoder.decodeBool(forKey: _szKeyBoolVal))
        decValue = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyDecVal)
        textValue = decoder.decodeObject(of: NSString.self, forKey: _szKeyTextVal)! as String
        dateValue = decoder.decodeObject(of: NSDate.self, forKey: _szKeyDateVal) as Date?
    }
}

// MARK: MFBWebServiceSvc_PropertyTemplate
private let _szKeyTemplateID = "keyTemplID"
private let _szKeyTemplateName = "keyTemplName"
private let _szKeyTemplateDesc = "keyTemplDesc"
private let _szKeyTemplateGroup = "keyTemplGroup"
private let _szKeyTemplateDefault = "keyTemplDefault"
private let _szKeyTemplatePropTypes = "keyTemplTypes"

extension MFBWebServiceSvc_PropertyTemplate {
    @objc public static let KEY_GROUPNAME  = "GroupName"
    @objc public static let KEY_PROPSFORGROUP = "PropsForGroup"
    @objc public static let GROUP_ID_AUTOMATIC=0
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(id_, forKey: _szKeyTemplateID)
        encoder.encode(name, forKey: _szKeyTemplateName)
        encoder.encode(description, forKey: _szKeyTemplateDesc)
        encoder.encode(groupAsInt, forKey: _szKeyTemplateGroup)
        encoder.encode(isDefault, forKey: _szKeyTemplateDefault)
        encoder.encode(propertyTypes, forKey: _szKeyTemplatePropTypes)
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder : NSCoder) {
        self.init()
        id_ = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyTemplateID)
        name = decoder.decodeObject(of: NSString.self, forKey: _szKeyTemplateName)! as String
        description = decoder.decodeObject(of: NSString.self, forKey: _szKeyTemplateDesc)! as String
        groupAsInt = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyTemplateGroup)! as NSNumber
        isDefault = decoder.decodeObject(of: USBoolean.self, forKey: _szKeyTemplateDefault)
        propertyTypes = try! decoder.decodeTopLevelObject(of: [NSMutableArray.self, MFBWebServiceSvc_ArrayOfInt.self, NSNumber.self],
                                                          forKey: _szKeyTemplatePropTypes)! as! MFBWebServiceSvc_ArrayOfInt
    }
    
    public static func templateWithID(_ idProp : Int) -> MFBWebServiceSvc_PropertyTemplate? {
        for pt in FlightProps.sharedTemplates {
            if (pt.id_.intValue == idProp) {
                return pt
            }
        }
        return nil
    }
    
    public static var simTemplate : MFBWebServiceSvc_PropertyTemplate? {
        get {
            return templateWithID(KnownTemplateID.ID_SIM.rawValue)
        }
    }
    
    public static var anonTemplate : MFBWebServiceSvc_PropertyTemplate? {
        get {
            return templateWithID(KnownTemplateID.ID_ANON.rawValue)
        }
    }
    
    @objc public static var defaultTemplates : [MFBWebServiceSvc_PropertyTemplate] {
        get {
            return FlightProps.sharedTemplates.filter { pt in
                return pt.isDefault.boolValue
            }
        }
    }
    
    @objc public static func templatesWithIDs(_ rgIDs : [NSNumber]) -> [MFBWebServiceSvc_PropertyTemplate] {
        return FlightProps.sharedTemplates.filter { pt in
            for n in rgIDs {
                if n.intValue == pt.id_.intValue {
                    return true
                }
            }
            return false
        }
    }
        
    @objc public static func propListForSets(_ rgTemplates : NSSet) -> NSSet {
        let rg = rgTemplates as! Set<MFBWebServiceSvc_PropertyTemplate>
        var set = Set<NSNumber>()
        for pt in rg {
            let ptprops = Set(pt.propertyTypes.int_ as! [NSNumber])
            
            set = set.union(ptprops)
        }
        return set as NSSet
    }
    
    @objc public override func isEqual(_ object: Any?) -> Bool {
        guard let pt = object as? MFBWebServiceSvc_PropertyTemplate else {
            return false
        }
        
        return id_.intValue == pt.id_.intValue
    }
    
    @objc public override var hash: Int {
        return id_.hash
    }

    @objc public static func groupTemplates(_ rgTemplates : [MFBWebServiceSvc_PropertyTemplate]) -> [NSDictionary] {
        var result : [NSMutableDictionary] = []
        
        // sort the arry by group, then by name
        let sorted = rgTemplates.sorted { pt1, pt2 in
            if (pt1.groupAsInt.intValue == pt2.groupAsInt.intValue) {
                return (pt1.groupAsInt.intValue == GROUP_ID_AUTOMATIC) ? pt2.id_.compare(pt1.id_) != .orderedDescending : pt1.name .compare(pt2.name, options: .caseInsensitive) != .orderedDescending
            } else if pt1.groupAsInt.intValue == GROUP_ID_AUTOMATIC {
                return true
            } else if pt2.groupAsInt.intValue == GROUP_ID_AUTOMATIC {
                return false
            } else {
                return pt1.groupDisplayName.compare(pt2.groupDisplayName, options: .caseInsensitive) != .orderedDescending
            }
        }
        
        var currentGroupName = ""
        var currentItems : NSMutableArray? = nil
        
        for pt in sorted {
            if pt.groupDisplayName.compare(currentGroupName, options: .caseInsensitive) != .orderedSame {
                currentGroupName = pt.groupDisplayName
                currentItems = NSMutableArray()
                let dict = NSMutableDictionary()
                dict[KEY_GROUPNAME] = currentGroupName
                dict[KEY_PROPSFORGROUP] = currentItems
                result.append(dict)
            }
            currentItems!.add(pt)
        }
        
        return result
    }
}
