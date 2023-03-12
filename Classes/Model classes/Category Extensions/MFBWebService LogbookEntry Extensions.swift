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
//  MFBWebService LogbookEntry Extensions.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/12/23.
//

import Foundation

// keys for preferences.
private let _szkeyHasSavedState = "pref_leSavedState"
private let _szkeySavedLE = "pref_savedLE2"
private let _szkeyFlightID = "pref_leFlightID"
private let _szKeyPendingID = "pref_lePendingID"
private let _szkeyAircraftID = "pref_leAircraftID"
private let _szkeyApproaches = "pref_leApproaches"
private let _szkeyCFI = "pref_leCFI"
private let _szkeyComment = "pref_leComment"
private let _szkeyCrossCountry = "pref_leCrossCountry"
private let _szkeyDate = "pref_leDate"
private let _szkeyDual = "pref_leDual"
private let _szkeyEngineEnd = "pref_leengineEnd"
private let _szkeyEngineStart = "pref_leengineStart"
private let _szkeyFlightEnd = "pref_leflightEnd"
private let _szkeyFlightStart = "pref_leflightStart"
private let _szkeyFullStopLandings = "pref_lefullStopLandings"
private let _szkeyHobbsEnd = "pref_lehobbsEnd"
private let _szkeyHobbsStart = "pref_lehobbsStart"
private let _szkeyIMC = "pref_leactualIMC"
private let _szkeyLandings = "pref_letotalLandings"
private let _szkeyNight = "pref_leNight"
private let _szkeyNightLandings = "pref_lenightLandings"
private let _szkeyPIC = "pref_lePIC"
private let _szkeyRoute = "pref_leRoute"
private let _szkeySIC = "pref_leSIC"
private let _szkeySimulatedIFR = "pref_lesimIFR"
private let _szkeyGroundSim = "pref_leGroundSim"
private let _szkeyTotalFlight = "pref_letotalFlight"
private let _szkeyUser = "pref_leUser"
private let _szkeyHolding = "pref_lefHolding"
private let _szkeyIsPublic = "pref_leisPublic"
private let _szKeyFlightData = "pref_leFlightData"
private let _szKeyCatClassOverride = "pref_leCatClassOverride"
private let _szKeyCustomProperties = "pref_leCustProperties"

// MARK: MFBWebServiceSvc_LogbookEntry has enough extensions to justify its own file
// Also, don't want to share with Widgets - too many other dependencies.
extension MFBWebServiceSvc_LogbookEntry : AutoDetectDelegate {
    @objc public static func idNewFlight() -> NSNumber {
        return NSNumber(integerLiteral: -1)
    }
    
    @objc public static func idPendingFlight() -> NSNumber {
        return NSNumber(integerLiteral: -2)
    }
    
    @objc public static func idQueuedFlight() -> NSNumber {
        return NSNumber(integerLiteral: -3)
    }
    
    @objc(toSimpleItem:) public func toSimpleItem(fHHMM : Bool) -> SimpleLogbookEntry {
        let sle = SimpleLogbookEntry()
        sle.comment = comment
        sle.route = route
        sle.date = date
        sle.totalTimeDisplay = totalFlightTime.formatAs(Type: .Time, inHHMM: fHHMM, useGrouping: true) as String
        sle.tailNumDisplay = tailNumDisplay
        return sle
    }
    
    @objc(toSimpleItems:inHHMM:) public static func toSimpleItems(items : [MFBWebServiceSvc_LogbookEntry], fHHMM : Bool) ->[SimpleLogbookEntry] {
        var arr = [SimpleLogbookEntry]()
        for le in items {
            arr.append(le.toSimpleItem(fHHMM: fHHMM))
        }
        return arr
    }
    
    @objc public func isKnownFlightStart() -> Bool  {
        return !NSDate.isUnknownDate(dt: flightStart);
    }
    
    @objc public func isKnownEngineStart() -> Bool  {
        return !NSDate.isUnknownDate(dt: engineStart);
    }
    
    @objc public func isKnownFlightEnd() -> Bool  {
        return !NSDate.isUnknownDate(dt: flightEnd);
    }
    
    @objc public func isKnownEngineEnd() -> Bool  {
        return !NSDate.isUnknownDate(dt: engineEnd);
    }
    
    @objc public func isKnownFlightTime() -> Bool {
        return isKnownFlightStart() && isKnownFlightEnd()
    }
    
    @objc public func isKnownEngineTime() -> Bool {
        return isKnownEngineStart() && isKnownEngineEnd()
    }
    
    @objc public func isNewFlight() -> Bool {
        return flightID?.intValue == -1
    }
    
    @objc public func isAwaitingUpload() -> Bool {
        return flightID?.intValue ?? 0 < -1
    }
    
    @objc public func isNewOrAwaitingUpload() -> Bool {
        return flightID?.intValue ?? 0 < 0
    }
    
    @objc public func isQueued() -> Bool {
        return flightID?.intValue == MFBWebServiceSvc_LogbookEntry.idQueuedFlight().intValue
    }
    
    @objc public func isSigned() -> Bool {
        return cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid || cfiSignatureState == MFBWebServiceSvc_SignatureState_Invalid;
    }
    
    public var propArray : [MFBWebServiceSvc_CustomFlightProperty] {
        get {
            return (customProperties.customFlightProperty as? [MFBWebServiceSvc_CustomFlightProperty]) ?? []
        }
    }
    
    @objc public func isEmpty() -> Bool {
        return hobbsStart.doubleValue == 0.0 && isInInitialState()
    }
    
    // isInitialState means a basically empty flight, but it COULD have a pre-initialized hobbs starting time.
    @objc public func isInInitialState() -> Bool {
        if (comment?.isEmpty ?? true &&
            route?.isEmpty ?? true &&
            approaches?.intValue == 0 &&
            cfi?.doubleValue == 0.0 &&
            crossCountry?.doubleValue == 0.0 &&
            dual?.doubleValue == 0.0 &&
            fullStopLandings?.intValue == 0 &&
            hobbsEnd?.doubleValue == 0.0 &&
            imc?.doubleValue == 0.0 &&
            landings?.intValue == 0 &&
            nightLandings?.intValue == 0 &&
            nighttime?.doubleValue == 0.0 &&
            pic?.doubleValue == 0.0 &&
            sic?.doubleValue == 0.0 &&
            simulatedIFR?.doubleValue == 0.0 &&
            totalFlightTime?.doubleValue == 0.0 &&
            customProperties?.customFlightProperty?.count == 0) {
            return true;
        }
        
        // see if any properties are empty
        if ((customProperties?.customFlightProperty?.count ?? 0) > 0) {
            return FlightProps().distillList(customProperties.customFlightProperty as? [MFBWebServiceSvc_CustomFlightProperty], includeLockedProps: false, includeTemplates: NSSet()).count == 0
        }
        
        return false
    }
    
    // MARK: Initialization and serialization
    @objc public static func getNewLogbookEntry() -> MFBWebServiceSvc_LogbookEntry {
        let le = MFBWebServiceSvc_LogbookEntry()
        le.flightID = NSNumber(integerLiteral: -1)
        le.aircraftID = NSNumber(integerLiteral: -1)
        
        le.customProperties = MFBWebServiceSvc_ArrayOfCustomFlightProperty()
        
        le.date = Date()
        le.comment = ""
        le.route = ""
        
        le.nighttime = NSNumber(integerLiteral: 0)
        le.imc = NSNumber(integerLiteral: 0)
        le.simulatedIFR = NSNumber(integerLiteral: 0)
        le.groundSim = NSNumber(integerLiteral: 0)
        le.crossCountry = NSNumber(integerLiteral: 0)
        le.dual = NSNumber(integerLiteral: 0)
        le.cfi =  NSNumber(integerLiteral: 0)
        le.sic = NSNumber(integerLiteral: 0)
        le.pic = NSNumber(integerLiteral: 0)
        le.totalFlightTime = NSNumber(integerLiteral: 0)
        
        le.landings = NSNumber(integerLiteral: 0)
        le.nightLandings = NSNumber(integerLiteral: 0)
        le.fullStopLandings = NSNumber(integerLiteral: 0)
        
        le.approaches = NSNumber(integerLiteral: 0)
        le.fHoldingProcedures = USBoolean(bool: false)
        
        le.hobbsEnd = NSNumber(integerLiteral: 0)
        le.hobbsStart = NSNumber(integerLiteral: 0)
        
        le.fIsPublic = USBoolean(bool: false)
        
        le.catClassOverride = NSNumber(integerLiteral: 0)
        
        le.user = ""
        le.flightData = ""
        
        return le;
    }
    
    // HACK: Because of swizzling (see main.m), subclassing encoding/decoding goes to the wrong encoder/decoder.  So just break it out
    // here into a function that can be called by the class or the subclass with NO "super" call.
    @objc internal func encodeBaseObject(_ encoder : NSCoder) {
        encoder.encode(flightID, forKey: _szkeyFlightID)
        encoder.encode(aircraftID, forKey: _szkeyAircraftID)
        
        encoder.encode(customProperties, forKey: _szKeyCustomProperties)
        
        encoder.encode(date, forKey: _szkeyDate)
        encoder.encode(comment, forKey: _szkeyComment)
        encoder.encode(route, forKey: _szkeyRoute)
        
        encoder.encode(nighttime, forKey: _szkeyNight)
        encoder.encode(imc, forKey: _szkeyIMC)
        encoder.encode(simulatedIFR, forKey: _szkeySimulatedIFR)
        encoder.encode(groundSim, forKey: _szkeyGroundSim)
        encoder.encode(crossCountry, forKey: _szkeyCrossCountry)
        encoder.encode(dual, forKey: _szkeyDual)
        encoder.encode(cfi, forKey: _szkeyCFI)
        encoder.encode(sic, forKey: _szkeySIC)
        encoder.encode(pic, forKey: _szkeyPIC)
        encoder.encode(totalFlightTime, forKey: _szkeyTotalFlight)
        
        encoder.encode(landings, forKey: _szkeyLandings)
        encoder.encode(nightLandings, forKey: _szkeyNightLandings)
        encoder.encode(fullStopLandings, forKey: _szkeyFullStopLandings)
        
        encoder.encode(approaches, forKey: _szkeyApproaches)
        encoder.encode(fHoldingProcedures.boolValue, forKey:_szkeyHolding)
        
        encoder.encode(hobbsStart, forKey: _szkeyHobbsStart)
        encoder.encode(hobbsEnd, forKey: _szkeyHobbsEnd)
        encoder.encode(engineStart, forKey: _szkeyEngineStart)
        encoder.encode(engineEnd, forKey: _szkeyEngineEnd)
        encoder.encode(flightStart, forKey: _szkeyFlightStart)
        encoder.encode(flightEnd, forKey: _szkeyFlightEnd)
        
        encoder.encode(fIsPublic.boolValue, forKey:_szkeyIsPublic)
        
        encoder.encode(catClassOverride, forKey: _szKeyCatClassOverride)
        
        encoder.encode(user, forKey: _szkeyUser)
        encoder.encode(flightData, forKey: _szKeyFlightData)
    }
    
    @objc public func decodeBaseObject(_ decoder : NSCoder) {
        flightID = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyFlightID)
        aircraftID = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyAircraftID)
        
        customProperties = (decoder.decodeObject(of: [NSArray.self, MFBWebServiceSvc_ArrayOfCustomFlightProperty.self, MFBWebServiceSvc_ArrayOfCustomFlightProperty.self, MFBWebServiceSvc_CustomPropertyType.self],
                                                 forKey: _szKeyCustomProperties) as? MFBWebServiceSvc_ArrayOfCustomFlightProperty) ?? MFBWebServiceSvc_ArrayOfCustomFlightProperty()
        
        date = decoder.decodeObject(of: NSDate.self, forKey: _szkeyDate) as Date?
        comment = (decoder.decodeObject(of: NSString.self, forKey: _szkeyComment) ?? "") as String
        route = (decoder.decodeObject(of: NSString.self, forKey: _szkeyRoute) ?? "") as String
        
        nighttime = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyNight)
        imc = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyIMC)
        simulatedIFR = decoder.decodeObject(of: NSNumber.self, forKey: _szkeySimulatedIFR)
        groundSim = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyGroundSim) ?? NSNumber(integerLiteral: 0)
        crossCountry = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyCrossCountry)
        dual = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyDual)
        cfi = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyCFI)
        sic = decoder.decodeObject(of: NSNumber.self, forKey: _szkeySIC)
        pic = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyPIC)
        totalFlightTime = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyTotalFlight)
        
        landings = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyLandings)
        nightLandings = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyNightLandings)
        fullStopLandings = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyFullStopLandings)
        
        approaches = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyApproaches)
        fHoldingProcedures = USBoolean(bool: decoder.decodeBool(forKey: _szkeyHolding))
        
        hobbsStart = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyHobbsStart)
        hobbsEnd = decoder.decodeObject(of: NSNumber.self, forKey: _szkeyHobbsEnd)
        engineStart = decoder.decodeObject(of: NSDate.self, forKey: _szkeyEngineStart) as Date?
        engineEnd = decoder.decodeObject(of: NSDate.self, forKey: _szkeyEngineEnd) as Date?
        flightStart = decoder.decodeObject(of: NSDate.self, forKey: _szkeyFlightStart) as Date?
        flightEnd = decoder.decodeObject(of: NSDate.self, forKey: _szkeyFlightEnd) as Date?
        
        fIsPublic = USBoolean(bool: decoder.decodeBool(forKey: _szkeyIsPublic))
        
        catClassOverride = decoder.decodeObject(of: NSNumber.self, forKey: _szKeyCatClassOverride) ?? NSNumber(integerLiteral: 0)
        
        user = (decoder.decodeObject(of: NSString.self, forKey: _szkeyUser) ?? "") as String
        flightData = (decoder.decodeObject(of: NSString.self, forKey: _szKeyFlightData) ?? "") as String
    }
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encodeBaseObject(encoder)
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder : NSCoder) {
        self.init()
        decodeBaseObject(decoder)
    }
    
    // MARK: Clone/Reverse
    @objc public func clone() -> MFBWebServiceSvc_LogbookEntry {
        do {
            // A bit of a hack for a deep copy: encode it then decode it.
            let thisArchived = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            let leNew = try NSKeyedUnarchiver.unarchivedObject(ofClass: MFBWebServiceSvc_LogbookEntry.self, from: thisArchived)!
            leNew.flightID = MFBWebServiceSvc_LogbookEntry.idNewFlight()
            
            // Because of the hack above to do a deep copy, a pendingflight in became a pending flight out for leNew, which meant that it had a pendingID that was an empty string, not nil
            // Trouble is, when we send this up the wire to commit as a pending flight, that empty string overwrites the GUID that gets assigned by the server,
            // and the save-as-pending operation fails.
            // To solve that, We need to nix the pending ID to force this into being a proper pending flight, if this is a pending flight
            if let pf = leNew as? MFBWebServiceSvc_PendingFlight {
                pf.pendingID = nil
            }
            
            if (leNew.customProperties != nil) {
                var defaultProps : [MFBWebServiceSvc_CustomFlightProperty] = []
                for c in leNew.customProperties.customFlightProperty {
                    let cfp = c as! MFBWebServiceSvc_CustomFlightProperty
                    cfp.flightID = MFBWebServiceSvc_LogbookEntry.idNewFlight()
                    cfp.propID = NSNumber(integerLiteral: PropTypeID.NEW_PROP_ID.rawValue)
                    if (cfp.isDefaultForType(FlightProps.propTypeFromID(cfp.propTypeID.intValue)!)) {
                        defaultProps.append(cfp)
                    }
                }
                // Fix a bug: we didn't distill the list, so this actually has a lot of default-value properties from the active template or pinned/starred props
                // No harm, no foul, though - they'll get distilled at some point, possibly even up on the server
                // Remove default properties
                for cfp in defaultProps {
                    leNew.customProperties.customFlightProperty.remove(cfp)
                }
            }
            
            leNew.date = Date()
            leNew.engineStart = Date.distantPast
            leNew.engineEnd = Date.distantPast
            leNew.flightStart = Date.distantPast
            leNew.flightEnd = Date.distantPast
            leNew.hobbsEnd = NSNumber(integerLiteral: 0)
            leNew.hobbsStart = NSNumber(integerLiteral: 0)
            leNew.flightData = ""
            leNew.flightImages = MFBWebServiceSvc_ArrayOfMFBImageInfo()
            return leNew
        } catch {
            return MFBWebServiceSvc_LogbookEntry.getNewLogbookEntry()
        }
    }
    
    @objc public func cloneAndReverse() -> MFBWebServiceSvc_LogbookEntry {
        let leNew = clone()
        var ar = Airports.CodesFromString(leNew.route)
        ar.reverse()
        leNew.route = ar.joined(separator: " ")
        return leNew
    }
    
    // MARK: Managing properties
    enum PropertyError: Error {
        case runtimeError(String)
    }
    
    @objc public func getExistingProperty(_ idPropType : NSNumber) -> MFBWebServiceSvc_CustomFlightProperty? {
        let propVal = idPropType.intValue
        for c in customProperties.customFlightProperty {
            let cfp = c as! MFBWebServiceSvc_CustomFlightProperty
            if (cfp.propTypeID.intValue == propVal) {
                return cfp
            }
        }
        return nil
    }
    
    ///Like RemoveProperty but deletes from the server if necessary (i.e., if it has a PropID > 0)
    @objc public func removeProperty(_ idPropType : NSNumber, withServerAuth szAuthToken : NSString?, deleteSvc fp : FlightProps?) throws {
        let idProp = idPropType.intValue
        let r = customProperties.customFlightProperty.filter { c in
            let cfp = c as! MFBWebServiceSvc_CustomFlightProperty
            return cfp.propTypeID.intValue == idProp
        }
        
        if (r.count > 1) {
            throw PropertyError.runtimeError("Multiple properties found with the same ID")
        }
        
        if (r.count == 1) {
            if let fpDelete = r[0] as? MFBWebServiceSvc_CustomFlightProperty {
                if fpDelete.propID.intValue > 0 {
                    if (szAuthToken == nil || szAuthToken!.length == 0 || fp == nil) {
                        throw PropertyError.runtimeError("Removing a property with a positive ID but no authtoken or flight props service provided; delete the property instead")
                    }
                    fp!.deleteProperty(fpDelete, forUser: szAuthToken! as String)   // kick off thread to delete on the server
                }
            }
        }
        customProperties.customFlightProperty.removeObjects(in: r)
    }
    
    @objc public func removeProperty(_ idPropType : NSNumber) {
        do {
            try removeProperty(idPropType, withServerAuth: nil, deleteSvc: nil)
        }
        catch {
            // something bad has happened - we should show an error.
        }
    }
    
    private func getNewProperty(_ idPropType : NSNumber) -> MFBWebServiceSvc_CustomFlightProperty {
        let fp = MFBWebServiceSvc_CustomFlightProperty.getNewFlightProperty()
        fp.flightID = flightID
        fp.propTypeID = idPropType
        return fp
    }
    
    @objc @discardableResult public func addProperty(_ idPropType : NSNumber, withInteger intVal : NSNumber?) -> MFBWebServiceSvc_CustomFlightProperty? {
        if (intVal?.intValue ?? 0) == 0 {
            return nil
        }
        let fp = getNewProperty(idPropType)
        fp.intValue = intVal!
        customProperties.customFlightProperty.add(fp)
        return fp
    }
    
    @objc @discardableResult public func addProperty(_ idPropType : NSNumber, withDecimal decVal : NSNumber?) -> MFBWebServiceSvc_CustomFlightProperty? {
        if (decVal?.doubleValue ?? 0.0) == 0.0 {
            return nil
        }
        let fp = getNewProperty(idPropType)
        fp.decValue = decVal!
        customProperties.customFlightProperty.add(fp)
        return fp
    }
    
    @objc @discardableResult public func addProperty(_ idPropType : NSNumber, withString sz : String?) -> MFBWebServiceSvc_CustomFlightProperty? {
        if (sz ?? "").isEmpty {
            return nil
        }
        let fp = getNewProperty(idPropType)
        fp.textValue = sz!
        customProperties.customFlightProperty.add(fp)
        return fp
    }
    
    
    @objc @discardableResult public func addProperty(_ idPropType : NSNumber, withBool fBool : Bool) -> MFBWebServiceSvc_CustomFlightProperty? {
        if !fBool {
            return nil
        }
        let fp = getNewProperty(idPropType)
        fp.boolValue = USBoolean(bool: fBool)
        customProperties.customFlightProperty.add(fp)
        return fp
    }
    
    @objc @discardableResult public func addProperty(_ idPropType : NSNumber, withDate dt : Date?) -> MFBWebServiceSvc_CustomFlightProperty? {
        if NSDate.isUnknownDate(dt: dt) {
            return nil
        }
        let fp = getNewProperty(idPropType)
        fp.dateValue = dt
        customProperties.customFlightProperty.add(fp)
        return fp
    }
    
    @objc @discardableResult public func setPropertyValue(_ idPropType : NSNumber, withDecimal decVal : NSNumber) -> MFBWebServiceSvc_CustomFlightProperty {
        let cfp = getExistingProperty(idPropType)
        if cfp == nil {
            return addProperty(idPropType, withDecimal: decVal)!
        } else {
            cfp?.decValue = decVal
            return cfp!
        }
    }
    
    @objc @discardableResult public func setPropertyValue(_ idPropType : NSNumber, withDate dt : Date?) -> MFBWebServiceSvc_CustomFlightProperty {
        let cfp = getExistingProperty(idPropType)
        if cfp == nil {
            return addProperty(idPropType, withDate: dt)!
        } else {
            cfp?.dateValue = dt
            return cfp!
        }
    }
    
    // MARK: Parsing (for JSON/LogTen)
    // TODO: Make these internal when we convert fromJSONDictionary
    @objc public func parseNum(_ s: Any?, numType nt : NumericType) -> NSNumber {
        let result = NSNumber(integerLiteral: 0)
        if s == nil {
            return result
        }
        if let num = s as? NSNumber {
            return num
        }
        if var sz = s as? String {
            if sz.isEmpty {
                return result
            }
            
            // Logten spec allows for "+" in addition to ":"
            sz = sz.replacingOccurrences(of: "+", with: ":")

            let fIsHHMM = sz.contains(":")
            return UITextField.valueForString(sz: sz, nt: nt.rawValue, fHHMM: fIsHHMM)
        }
        return result
    }
    
    @objc public func parseDate(_ szDt: Any?, withFormatter df : DateFormatter) -> Date? {
        if let dtIn = szDt as? Date {
            return dtIn
        }
        
        if let numIn = szDt as? NSNumber {
            return Date(timeIntervalSince1970: TimeInterval(numIn.intValue))
        }
        
        if let sz = szDt as? String {
            return df.date(from: sz)
        }
        
        return nil
    }
    
    /*
     TODO: Can't complete this until we migrate aircraft
    @objc public func fromJSONDictionary(_ dict : [String : String], dateFormatter dfDate : DateFormatter, dateTimeFormatter dfDateTime : DateFormatter) -> String {
        var szResult = ""
        
        do {
            comment = dict["flight_remarks"] ?? ""
            let szFrom = dict["flight_from"] ?? ""
            let szTo = dict["flight_to"] ?? ""
            let szRoute = dict["flight_route"] ?? ""
            
            route = "\(szFrom) \(szRoute) \(szTo)".trimmingCharacters(in: .whitespaces)
            
            hobbsStart = parseNum(dict["flight_hobbsStart"], numType: .Decimal)
            hobbsEnd = parseNum(dict["flight_hobbsStop"], numType: .Decimal)
            
            date = parseDate(dict["flight_flightDate"], withFormatter:dfDate)
            flightStart = parseDate(dict["flight_takeoffTime"], withFormatter:dfDateTime)
            flightEnd = parseDate(dict["flight_landingTime"], withFormatter:dfDateTime)
            
            crossCountry = parseNum(dict["flight_crossCountry"], numType: .Time)
            nighttime = parseNum(dict["flight_night"], numType: .Time)
            simulatedIFR = parseNum(dict["flight_simulatedInstrument"], numType: .Time)
            imc = parseNum(dict["flight_actualInstrument"], numType: .Time)
            groundSim = parseNum(dict["flight_simulator"], numType: .Time)
            dual = parseNum(dict["flight_dualReceived"], numType: .Time)
            cfi = parseNum(dict["flight_dualGiven"], numType: .Time)
            sic = parseNum(dict["flight_sic"], numType: .Time)
            pic = parseNum(dict["flight_pic"], numType: .Time)
            totalFlightTime = parseNum(dict["flight_totalTime"], numType: .Time)
            
            nightLandings = parseNum(dict["flight_nightLandings"], numType: .Integer)
            fullStopLandings = parseNum(dict["flight_dayLandings"], numType: .Integer)
            landings = parseNum(dict["flight_totalLandings"], numType: .Integer)
            
            let flight_holds = parseNum(dict["flight_holds"], numType: .Integer)
            fHoldingProcedures = USBoolean(bool: flight_holds.intValue > 0)
            fIsPublic = USBoolean(bool: false)
            approaches = parseNum(dict["flight_totalApproaches"], numType: .Integer)
            
            // Now add a few properties that match to known property types
            addProperty(NSNumber(integerLiteral: PropTypeID.IPC.rawValue), withBool:dict["flight_instrumentProficiencyCheck"] != nil)
            addProperty(NSNumber(integerLiteral: PropTypeID.BFR.rawValue), withBool:dict["flight_review"] != nil)
            addProperty(NSNumber(integerLiteral: PropTypeID.nightTakeOff.rawValue), withInteger:parseNum(dict["flight_nightTakeoffs"], numType: .Integer))
            addProperty(NSNumber(integerLiteral: PropTypeID.solo.rawValue), withDecimal:parseNum(dict["flight_solo"], numType: .Time))
            addProperty(NSNumber(integerLiteral: PropTypeID.nameOfPIC.rawValue), withString:dict["flight_selectedCrewPIC"])
            addProperty(NSNumber(integerLiteral: PropTypeID.nameOfSIC.rawValue), withString:dict["flight_selectedCrewSIC"])
            addProperty(NSNumber(integerLiteral: PropTypeID.nameOfCFI.rawValue), withString:dict["flight_selectedCrewInstructor"])
            addProperty(NSNumber(integerLiteral: PropTypeID.nameOfStudent.rawValue), withString:dict["flight_selectedCrewStudent"])

            aircraftID = NSNumber(integerLiteral: -1)
            MFBWebServiceSvc_Aircraft * ac;
            if (dict[@"flight_selectedAircraftID"] == nil || (ac = [[Aircraft sharedAircraft] AircraftByTail:dict[@"flight_selectedAircraftID"]]) == nil)
                szResult = NSLocalizedString(@"No Aircraft", @"Title for No Aircraft error");
            else
                self.AircraftID = ac.AircraftID;
        }
        catch {
            szResult = error.localizedDescription
        }
        
        return szResult
    }
     */
    
    // MARK: Autodetect Delegate
    @objc public func autofillClosest() {
        route = Airports.appendNearestAirport(route)
    }
    
    @objc @discardableResult public func takeoffDetected() -> NSString {
        if !isKnownFlightTime() {
            flightStart = SwiftHackBridge.lastLoc().timestamp
        }
        autofillClosest()
        return ""
    }
    
    @objc @discardableResult public func nightTakeoffDetected() -> NSString {
        if customProperties == nil {
            customProperties = MFBWebServiceSvc_ArrayOfCustomFlightProperty()
        }
        
        // See if the flight has a night-time take-off property attached.  If not, add it.
        var fpTakeoff : MFBWebServiceSvc_CustomFlightProperty? = nil;
        for c in self.customProperties.customFlightProperty {
            if let cfp = c as? MFBWebServiceSvc_CustomFlightProperty {
                if (cfp.propTypeID.intValue == PropTypeID.nightTakeOff.rawValue) {
                    fpTakeoff = cfp
                    break;
                }
            }
        }
        if (fpTakeoff == nil) {
            addProperty(NSNumber(integerLiteral: PropTypeID.nightTakeOff.rawValue), withInteger: NSNumber(integerLiteral: 1))
        } else {
            fpTakeoff!.intValue = NSNumber(integerLiteral: fpTakeoff!.intValue.intValue + 1)
        }
        return ""
    }
    
    @objc @discardableResult public func landingDetected() -> NSString {
        if self.isKnownEngineEnd() {
            return ""
        }
        if !NSDate.isUnknownDate(dt: flightStart) {
            flightEnd = SwiftHackBridge.lastLoc().timestamp
            landings = NSNumber(integerLiteral: landings.intValue + 1)
            autofillClosest()
        }
        return ""
    }
    
    @objc @discardableResult public func fsLandingDetected(_ fIsNight : Bool) -> NSString {
        if isKnownEngineEnd() {
            return ""
        }
        
        if fIsNight {
            nightLandings = NSNumber(integerLiteral: nightLandings.intValue + 1)
        } else {
            fullStopLandings = NSNumber(integerLiteral: fullStopLandings.intValue + 1)
        }
        return ""
    }
    
    @objc public func addNightTime(_ t : Double) {
        nighttime = NSNumber(floatLiteral: nighttime.doubleValue + t)
    }
    
    @objc public func flightCouldBeInProgress() -> Bool {
        // Could be in progress if (EITHER engine or flight start is known) AND EngineEnd is unknown.
        return ((isKnownFlightStart() || isKnownEngineStart()) && !isKnownEngineEnd())
    }
    
    @objc public func newLocation(_ newLocation : CLLocation) {
        // don't care
    }
    
    // MARK: Misc useful functions
    @objc public func addApproachDescription(_ description : String) {
        if customProperties == nil {
            customProperties = MFBWebServiceSvc_ArrayOfCustomFlightProperty()
        }
        
        // See if the flight has an approach description attached.  If not, add it.
        var fpDescription : MFBWebServiceSvc_CustomFlightProperty?  = nil
        for c in customProperties.customFlightProperty {
            if let cfp = c as? MFBWebServiceSvc_CustomFlightProperty {
                if cfp.propTypeID.intValue == PropTypeID.approachName.rawValue {
                    fpDescription = cfp
                    break
                }
            }
        }
        
        if fpDescription == nil {
            addProperty(NSNumber(integerLiteral: PropTypeID.approachName.rawValue), withString: description)
        } else {
            fpDescription?.textValue = "\(fpDescription!.textValue.trimmingCharacters(in: .whitespaces)) \(description)"
        }
    }
    
    /*
     TODO: Can't complete this until we have Aircraft migrated
     - (NSNumber *) xfillValueForPropType:(MFBWebServiceSvc_CustomPropertyType *) cpt {
         if (cpt.PropTypeID.integerValue == PropTypeIDTachStart)
             return [Aircraft.sharedAircraft getHighWaterTachForAircraft:self.AircraftID];
         
         // if it's a decimal but not a basic decimal
         if (cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpDecimal && (cpt.Flags.intValue & 0x00200000) == 0)
             return self.TotalFlightTime;
         
         if (cpt.Type == MFBWebServiceSvc_CFPPropertyType_cfpInteger) {
             if ((cpt.Flags.intValue & 0x08000000) == 0x08000000)
                 return self.Landings;
             if ((cpt.Flags.intValue & 0x00001000) == 0x00001000)
                 return self.Approaches;
         }
         
         return nil;
     }
     */
    
    @objc public func sendFlight() {
        if (sendFlightLink ?? "").isEmpty {
            return
        }
        
        let szEncodedSubject = String(localized: "flightActionSendSubject", comment: "Flight Action - Send Subject").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let szEncodeBody = String(format: String(localized: "flightActionSendBody", comment:"Flight Action - Send Body"), sendFlightLink!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let szURL = "mailto:?subject=\(szEncodedSubject!)&body=\(szEncodeBody!)"
        UIApplication.shared.open(URL(string: szURL)!)
    }
    
    @objc public func shareFlight(_ sender : UIBarButtonItem, fromViewController source : UIViewController) {
        if (socialMediaLink ?? "").isEmpty {
            return
        }
        
        let szComment = "\(comment ?? "") \(route ?? "")".trimmingCharacters(in: .whitespaces)
        let url = URL(string: socialMediaLink!)!
        let avc = UIActivityViewController(activityItems: [szComment, url], applicationActivities: nil)
        
        let bbi = sender
        let bbiView = bbi.value(forKey: "view") as! UIView
        avc.popoverPresentationController?.sourceView = bbiView
        avc.popoverPresentationController?.sourceRect = bbiView.frame
        
        avc.excludedActivityTypes = [.airDrop, .print, .assignToContact, .saveToCameraRoll,.addToReadingList, .postToFlickr, .postToVimeo]
        source.present(avc, animated: true)
    }
}

// MARK: MFBWebServiceSvc_PendingFlight extensions
extension MFBWebServiceSvc_PendingFlight {
    @objc public override func encodeWithCoderMFB(_ encoder: NSCoder) {
        encodeBaseObject(encoder)
        encoder.encode(pendingID, forKey: _szKeyPendingID)
    }
    
    @objc(initWithCoderMFB:) public convenience init(_ decoder: NSCoder) {
        self.init()
        decodeBaseObject(decoder)
        pendingID = (decoder.decodeObject(of: NSString.self, forKey: _szKeyPendingID) ?? "") as String
    }
    
    @objc public override func clone() -> MFBWebServiceSvc_LogbookEntry {
        pendingID = nil
        return super.clone()
    }
    
    @objc public override func cloneAndReverse() -> MFBWebServiceSvc_LogbookEntry {
        return super.cloneAndReverse()
    }
}
