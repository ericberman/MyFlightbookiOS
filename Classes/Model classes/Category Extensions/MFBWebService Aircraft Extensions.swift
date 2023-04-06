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
//  MFBWebService Aircraft Extensions.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/12/23.
//

import Foundation


internal let _szEncodeKeyAircraftID = "AircraftID"
internal let _szEncodeKeyInstanceType = "InstanceType"
internal let _szEncodeKeyLast100 = "Last100"
internal let _szEncodeKeyLastAltimeter = "LastAltimeter"
internal let _szEncodeKeyLastAnnual = "LastAnnual"
internal let _szEncodeKeyLastELT = "LastELT"
internal let _szEncodeKeyLastNewEngine = "LastNewEngine"
internal let _szEncodeKeyLastOilChange = "LastOilChange"
internal let _szEncodeKeyLastStatic = "LastStatic"
internal let _szEncodeKeyLastTransponder = "LastTransponder"
internal let _szEncodeKeyLastVOR = "LastVOR"
internal let _szEncodeKeyRegistrationDue = "RegistrationDue"
internal let _szEncodeKeyModelCommonName = "ModelCommonName"
internal let _szEncodeKeyModelDescription = "ModelDescription"
internal let _szEncodeKeyModelID = "ModelID"
internal let _szEncodeKeyTailNumber = "TailNumber"
internal let _szEncodeKeyAircraftImages = "AircraftImages"
internal let _szEncodeKeyHideFromSelectionBOOL = "HideFromSelectionBOOL"
internal let _szEncodeKeyrevisionNumber = "revisionNumber"
internal let _szEncodeKeyRoleForPilot = "RoleForPilot"
internal let _szEncodeKeyCopyPICName = "CopyPICName"
internal let _szEncodeKeyDefaultImage = "DefaultImage"
internal let _szEncodeKeyDefaultTemplates = "DefaultTemplates"
internal let _szEncodeKeyPublicNotes = "PublicNotes"
internal let _szEncodeKeyPrivateNotes = "PrivateNotes"
internal let _szEncodeKeyIsGlass = "IsGlass"
internal let _szEncodeKeyICAO = "ICAO"

// MARK: MFBWebServiceSvc_Aircraft extensions
extension MFBWebServiceSvc_Aircraft {
    @objc public func instanceTypeIDFromInstanceType(_ instanceType : MFBWebServiceSvc_AircraftInstanceTypes) -> NSNumber {
        return NSNumber(integerLiteral: instanceType == MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft || instanceType == MFBWebServiceSvc_AircraftInstanceTypes_none ? 1 : Int((instanceType.rawValue - MFBWebServiceSvc_AircraftInstanceTypes_Mintype.rawValue)) + 1)
    }
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(aircraftID, forKey: _szEncodeKeyAircraftID)
        encoder.encode(Int32(instanceType.rawValue), forKey:_szEncodeKeyInstanceType)
        encoder.encode(last100, forKey: _szEncodeKeyLast100)
        encoder.encode(lastAltimeter, forKey: _szEncodeKeyLastAltimeter)
        encoder.encode(lastAnnual, forKey: _szEncodeKeyLastAnnual)
        encoder.encode(lastELT, forKey: _szEncodeKeyLastELT)
        encoder.encode(lastNewEngine, forKey: _szEncodeKeyLastNewEngine)
        encoder.encode(lastOilChange, forKey: _szEncodeKeyLastOilChange)
        encoder.encode(lastStatic, forKey: _szEncodeKeyLastStatic)
        encoder.encode(lastTransponder, forKey: _szEncodeKeyLastTransponder)
        encoder.encode(lastVOR, forKey: _szEncodeKeyLastVOR)
        encoder.encode(registrationDue, forKey: _szEncodeKeyRegistrationDue)
        encoder.encode(modelCommonName, forKey: _szEncodeKeyModelCommonName)
        encoder.encode(modelDescription, forKey: _szEncodeKeyModelDescription)
        encoder.encode(modelID, forKey: _szEncodeKeyModelID)
        encoder.encode(tailNumber, forKey: _szEncodeKeyTailNumber)
        encoder.encode(aircraftImages, forKey: _szEncodeKeyAircraftImages)
        encoder.encode(hideFromSelection.boolValue, forKey:_szEncodeKeyHideFromSelectionBOOL)
        encoder.encode(revision.intValue, forKey:_szEncodeKeyrevisionNumber)
        encoder.encode(Int32(roleForPilot.rawValue), forKey:_szEncodeKeyRoleForPilot)
        encoder.encode(copyPICNameWithCrossfill.boolValue, forKey:_szEncodeKeyCopyPICName)
        encoder.encode(defaultImage, forKey: _szEncodeKeyDefaultImage)
        encoder.encode(defaultTemplates, forKey: _szEncodeKeyDefaultTemplates)
        encoder.encode(publicNotes, forKey: _szEncodeKeyPublicNotes)
        encoder.encode(privateNotes, forKey: _szEncodeKeyPrivateNotes)
        encoder.encode(isGlass.boolValue, forKey:_szEncodeKeyIsGlass)
        encoder.encode(icao, forKey: _szEncodeKeyICAO)
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder : NSCoder) {
        self.init()
        
        aircraftID = decoder.decodeObject(of: NSNumber.self, forKey: _szEncodeKeyAircraftID)
        instanceType = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: UInt32(decoder.decodeInt32(forKey:_szEncodeKeyInstanceType)))
        instanceTypeID = instanceTypeIDFromInstanceType(instanceType)
        last100 = decoder.decodeObject(of: NSNumber.self, forKey:_szEncodeKeyLast100)
        lastAltimeter = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastAltimeter) as? Date
        lastAnnual = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastAnnual) as? Date
        lastELT = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastELT) as? Date
        lastNewEngine = decoder.decodeObject(of: NSNumber.self, forKey:_szEncodeKeyLastNewEngine)
        lastOilChange = decoder.decodeObject(of: NSNumber.self, forKey:_szEncodeKeyLastOilChange)
        lastStatic = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastStatic) as? Date
        lastTransponder = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastTransponder) as? Date
        lastVOR = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyLastVOR) as? Date
        registrationDue = decoder.decodeObject(of: NSDate.self, forKey:_szEncodeKeyRegistrationDue) as? Date
        modelCommonName = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyModelCommonName) as? String
        modelDescription = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyModelDescription) as? String
        modelID = decoder.decodeObject(of: NSNumber.self, forKey:_szEncodeKeyModelID)
        tailNumber = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyTailNumber) as? String
        aircraftImages = decoder.decodeObject(of: MFBWebServiceSvc_ArrayOfMFBImageInfo.self, forKey:_szEncodeKeyAircraftImages)
        hideFromSelection = USBoolean(bool: decoder.decodeBool(forKey: _szEncodeKeyHideFromSelectionBOOL))
        roleForPilot = MFBWebServiceSvc_PilotRole(UInt32(decoder.decodeInt32(forKey: _szEncodeKeyRoleForPilot)))
        copyPICNameWithCrossfill = USBoolean(bool: decoder.decodeBool(forKey: _szEncodeKeyCopyPICName))
        if (roleForPilot == MFBWebServiceSvc_PilotRole_none) {
            roleForPilot = MFBWebServiceSvc_PilotRole_None
        }
        defaultImage = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyDefaultImage) as? String
        defaultTemplates = try! decoder.decodeTopLevelObject(of: [NSMutableArray.self, NSNumber.self, MFBWebServiceSvc_ArrayOfInt.self], forKey: _szEncodeKeyDefaultTemplates) as? MFBWebServiceSvc_ArrayOfInt
        publicNotes = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyPublicNotes) as? String
        privateNotes = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyPrivateNotes) as? String
        isGlass = USBoolean(bool: decoder.decodeBool(forKey: _szEncodeKeyIsGlass))
        icao = decoder.decodeObject(of: NSString.self, forKey:_szEncodeKeyICAO) as? String
        revision = NSNumber(integerLiteral: Int(decoder.decodeInt32(forKey: _szEncodeKeyrevisionNumber)))
    }
    
    @objc public override var description: String {
        get {
            return "\(tailNumber!) - \(modelCommonName!), ID=\(aircraftID!)"
        }
    }
    
    @objc public var modelFullDescription : String {
        get {
            return "\(modelCommonName.replacingOccurrences(of: "  ", with: " ")) (\(modelDescription.trimmingCharacters(in: .whitespaces)))"
        }
    }
    
    @objc public var displayTailNumber : String {
        if isAnonymous() {
            if !(modelCommonName ?? "").isEmpty {
                return "(\(modelDescription!))"
            }
        }
        return tailNumber
    }
    
    @objc public func hasMaintenance() -> Bool {
        return (last100.intValue > 0 || lastOilChange.intValue > 0 || lastNewEngine.intValue > 0 ||
                !NSDate.isUnknownDate(dt: lastVOR) ||
                !NSDate.isUnknownDate(dt: lastAltimeter) ||
                !NSDate.isUnknownDate(dt: lastAnnual) ||
                !NSDate.isUnknownDate(dt: lastELT) ||
                !NSDate.isUnknownDate(dt: lastStatic) ||
                !NSDate.isUnknownDate(dt: lastTransponder))
    }
    
    @objc public func nextVOR() -> Date {
        return NSDate.isUnknownDate(dt: lastVOR) ? lastVOR : lastVOR!.addingTimeInterval(TimeInterval(24 * 3600 * 30))
    }

    @objc public func nextAnnual() -> Date {
        return NSDate.isUnknownDate(dt: lastAnnual) ? lastAnnual : (lastAnnual as NSDate).dateByAddingCalendarMonths(cMonths: 12)
    }

    @objc public func nextELT() -> Date {
        return NSDate.isUnknownDate(dt: lastELT) ? lastELT : (lastELT as NSDate).dateByAddingCalendarMonths(cMonths: 12)
    }

    @objc public func nextAltimeter() -> Date {
        return NSDate.isUnknownDate(dt: lastAltimeter) ? lastAltimeter : (lastAltimeter as NSDate).dateByAddingCalendarMonths(cMonths: 24)
    }

    @objc public func nextPitotStatic() -> Date {
        return NSDate.isUnknownDate(dt: lastStatic) ? lastStatic : (lastStatic as NSDate).dateByAddingCalendarMonths(cMonths: 24)
    }

    @objc public func nextTransponder() -> Date {
        return NSDate.isUnknownDate(dt: lastTransponder) ? lastTransponder : (lastTransponder as NSDate).dateByAddingCalendarMonths(cMonths: 24)
    }
    
    @objc public static func getNewAircraft() -> MFBWebServiceSvc_Aircraft {
        let ac = MFBWebServiceSvc_Aircraft()
        ac.tailNumber = CountryCode.BestGuessForCurrentLocale().Prefix
        ac.aircraftID = NSNumber(integerLiteral: -1)
        ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft
        ac.instanceTypeID = ac.instanceTypeIDFromInstanceType(ac.instanceType)
        ac.last100 = NSNumber(integerLiteral: 0);
        ac.lastAltimeter = Date.distantPast
        ac.lastAnnual = Date.distantPast
        ac.lastELT = Date.distantPast
        ac.lastNewEngine = NSNumber(integerLiteral: 0);
        ac.lastOilChange = NSNumber(integerLiteral: 0);
        ac.lastStatic = Date.distantPast
        ac.lastTransponder = Date.distantPast
        ac.lastVOR = Date.distantPast
        ac.modelCommonName = ""
        ac.modelDescription = "";
        ac.modelID = NSNumber(integerLiteral: -1)
        ac.hideFromSelection = USBoolean(bool: false)
        ac.roleForPilot = MFBWebServiceSvc_PilotRole_None;
        ac.defaultImage = ""
        ac.defaultTemplates = MFBWebServiceSvc_ArrayOfInt()
        ac.privateNotes = ""
        ac.publicNotes = ""
        ac.aircraftImages = MFBWebServiceSvc_ArrayOfMFBImageInfo()
        return ac;
    }

    @objc public func isNew() -> Bool  {
        return aircraftID == nil || aircraftID.intValue < 0
    }

    @objc public func isSim() -> Bool {
        switch (instanceType) {
            case MFBWebServiceSvc_AircraftInstanceTypes_none, MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft, MFBWebServiceSvc_AircraftInstanceTypes_Mintype:
                return false
            default:
                return true
        }
    }
    
    @objc public func isAnonymous() -> Bool {
        return tailNumber.hasPrefix(MFBWebServiceSvc_Aircraft.PrefixAnonymous)
    }
    
    @objc public static var PrefixAnonymous : String {
        get {
            return "#"
        }
    }
}

// Grouping of models by manufacturer.
public struct ModelGroup {
    public var manufacturerName : String
    public var models : [MFBWebServiceSvc_SimpleMakeModel] = []
    
    public static func groupModels(_ rg : [MFBWebServiceSvc_SimpleMakeModel]) -> [ModelGroup] {
        var result : [ModelGroup] = []
        var szKey = ""
        
        // sort by manufacturer name, if not already sorted.
        let rgSorted = rg.sorted { smm1, smm2 in
            switch smm1.manufacturerName.compare(smm2.manufacturerName, options: .caseInsensitive) {
            case .orderedDescending:
                return false
            case .orderedAscending:
                return true
            case .orderedSame:
                return smm1.unamibiguousDescription.compare(smm2.unamibiguousDescription, options: .caseInsensitive) != .orderedDescending
            }
        }
        
        for smm in rgSorted {
            let szNewKey = smm.manufacturerName
            
            if (szKey.compare(szNewKey, options: .caseInsensitive) != .orderedSame) {
                result.append(ModelGroup(manufacturerName: szNewKey))
                szKey = szNewKey
            }
            
            result[result.count - 1].models.append(smm)
        }
        
        return result
    }
    
    public static func indicesFromGroups(_ rg : [ModelGroup]) -> [String] {
        var rgResult = [UITableView.indexSearch]
        var szKey = ""

        for mg in rg {
            let szNewKey = String(mg.manufacturerName.prefix(1)).uppercased()
            if szKey.compare(szNewKey, options: .caseInsensitive) != .orderedSame {
                rgResult.append(szNewKey)
                szKey = szNewKey
            }
        }

        return rgResult
    }
}

// MARK: MFBWebServiceSvc_SimpleMakeModel extensions
extension MFBWebServiceSvc_SimpleMakeModel {
    // These are kind of a hack on the syntax of the simple make/model Description, which is "Manufacturer (model and other info)"
    private func getDescriptionPiece(_ index : Int) -> String {
        // Because fucking swift fucking renames every fucking variable because of their fucking anal retentiveness about capitalization,
        // "Description" on the simple make/model conflicts with "description" that gets bridging assigned.
        // I could use the NS_SWIFT_NAME macro to define an alternate name, but alas THAT has to be done in the auto-generated MFBWebServiceSvc.h
        // file, which means that whenever I update that file I'd break if I forget to edit it, which I don't want to do
        // But it seems that using "description!" instead of "description" does the right thing...I don't know if I can count on that.
        let d = self.description!
        let regex = try! NSRegularExpression(pattern: #"([^(]+) (\(.*\) -.*)"#)
        if let m = regex.firstMatch(in: d, range: NSRange(location: 0, length: d.count)) {
            if (m.numberOfRanges == 3) {    // should always be true!!!
                return d[Range(m.range(at: index))!]
            }
        }
        return d
    }
        
    @objc public var subDesc : String {
        get {
            return getDescriptionPiece(2)
        }
    }
    
    @objc public var manufacturerName : String {
        get {
            return getDescriptionPiece(1)
        }
    }
    
    // See comment above - this avoids the conflicting upper/lowercase names on "description"
    public var unamibiguousDescription : String {
        get {
            return description!
        }
    }
}
