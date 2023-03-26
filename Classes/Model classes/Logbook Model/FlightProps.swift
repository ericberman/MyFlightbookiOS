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
// FlightProps.swift
// MyFlightbook
//
// Created by Eric Berman on 3/5/23.
//

import Foundation
import SQLite3

@objc public enum PropTypeID : Int {
    case nightTakeOff = 73
    case solo = 77
    case IPC = 41
    case BFR = 44
    case nameOfPIC = 183
    case nameOfSIC = 184
    case nameOfCFI = 92
    case nameOfStudent = 166
    case tachStart = 95
    case tachEnd = 96
    case approachName = 267
    case blockOut = 187
    case blockIn = 186
    case flightCost = 415
    case lessonStart = 668
    case lessonEnd = 669
    case groundInstructionGiven = 198
    case groundInstructionReceived = 158
    case fuelAtStart = 622
    case fuelAtEnd = 72
    case fuelConsumed = 71
    case fuelBurnRate = 381
    
    case NEW_PROP_ID = -1
}

@objc public enum KnownTemplateID : Int {
    case ID_NEW = -1
    case ID_MRU = -2
    case ID_SIM = -3
    case ID_ANON = -4
}

@objc public class FlightProps : NSObject, MFBSoapCallDelegate {
    // Public variable properties
    @objc public var rgPropTypes : [MFBWebServiceSvc_CustomPropertyType]
    @objc public var rgFlightProps = MFBWebServiceSvc_ArrayOfCustomFlightProperty()
    @objc public var errorString = ""
    
    // Private variable properties
    private static var hasLoadedThisSession = false
    
    // Private constants
    private static let _szKeyCachedPropTypes = "keyCachePropTypes";
    private static let _szKeyCachedTemplates = "keyCacheTemplates";
    private static let _szKeyPrefsLockedTypes = "keyPrefsLockedTypes";
    
    private static var _sharedPropTypes : [MFBWebServiceSvc_CustomPropertyType]? = nil
    public static var sharedPropTypes : [MFBWebServiceSvc_CustomPropertyType] {
        get {
            if (_sharedPropTypes == nil) {
                // NEVER hit the net; use cached if available otherwise use the database
                _sharedPropTypes = cachedProps()
                if (_sharedPropTypes!.isEmpty) {
                    _sharedPropTypes = propertiesFromDB()
                }
            }
            return _sharedPropTypes!
        }
    }
    
    private static var _sharedTemplate : [MFBWebServiceSvc_PropertyTemplate]? = nil
    @objc public static var sharedTemplates : [MFBWebServiceSvc_PropertyTemplate] {
        get {
            if (_sharedTemplate == nil) {
                let data = UserDefaults.standard.object(forKey: _szKeyCachedTemplates) as? NSData
                if (data != nil) {
                    _sharedTemplate = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, NSNumber.self, MFBWebServiceSvc_PropertyTemplate.self, MFBWebServiceSvc_ArrayOfPropertyTemplate.self],
                                                                         from: data! as Data) as? [MFBWebServiceSvc_PropertyTemplate]
                } else {
                    _sharedTemplate = []
                }
            }
            return _sharedTemplate!
        }
    }
    
    @objc public static func clearTemplates() {
        _sharedTemplate = []
    }
    
    @objc public static func replaceTemplates(_ ar : [MFBWebServiceSvc_PropertyTemplate]) {
        _sharedTemplate = ar
    }
    
    @objc public static func saveTemplates() {
        let defs = UserDefaults.standard
        try! defs.set(NSKeyedArchiver.archivedData(withRootObject: sharedTemplates, requiringSecureCoding: true), forKey: _szKeyCachedTemplates)
        defs.synchronize()
    }
    
    @objc(updateTemplates:forAircraft:) public static func updateTemplates(_ templates: NSMutableSet , forAircraft ac : MFBWebServiceSvc_Aircraft?) {
        let defaultTemplates = MFBWebServiceSvc_PropertyTemplate.defaultTemplates
        let ptSim = MFBWebServiceSvc_PropertyTemplate.simTemplate
        let ptAnon = MFBWebServiceSvc_PropertyTemplate.anonTemplate
        if (ptSim != nil) {
            templates.remove(ptSim!)
        }
        if (ptAnon != nil) {
            templates.remove(ptAnon!)
        }
        
        // If there is an aircraft specified and it has templates specified, use them .
        if (ac?.defaultTemplates?.int_.count ?? 0) > 0 {
            templates.addObjects(from: MFBWebServiceSvc_PropertyTemplate.templatesWithIDs(ac!.defaultTemplates!.int_ as! [NSNumber]))
        } else if !defaultTemplates.isEmpty {
            // check for default templates and use them exclusively
            templates.addObjects(from: defaultTemplates)
        }
        
        // Always add in sim/anon as needed
        if (ac?.isSim() ?? false) && ptAnon != nil {
            templates.add(ptSim!)
        }
        
        if ((ac?.isAnonymous() ?? false) && ptAnon != nil) {
            templates.add(ptAnon!)
        }
    }
    
    @objc public static func flushTemplates() {
        _sharedTemplate?.removeAll()
        saveTemplates()
    }
    
    @objc public func setPropTypeArray(_ ar : [MFBWebServiceSvc_CustomPropertyType]?) {
        objc_sync_enter(FlightProps.sharedPropTypes)
        rgPropTypes.removeAll()
        if (ar != nil) {
            rgPropTypes.append(contentsOf: ar!)
        }
        objc_sync_exit(FlightProps.sharedPropTypes)
    }
    
    @objc public var synchronizedProps : [MFBWebServiceSvc_CustomPropertyType] {
        get {
            objc_sync_enter(rgPropTypes)
            let ar = Array(rgPropTypes)
            objc_sync_exit(rgPropTypes)
            return ar
        }
    }
    
    @objc public override init() {
        rgPropTypes = FlightProps.sharedPropTypes
        super.init()
        setPropTypeArray(FlightProps.cachedProps())
    }
    
    private static func cachedProps() -> [MFBWebServiceSvc_CustomPropertyType] {
        if let rgArrayLastData = UserDefaults.standard.object(forKey: _szKeyCachedPropTypes) {
            return try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, MFBWebServiceSvc_CustomPropertyType.self], from: rgArrayLastData as! Data) as! [MFBWebServiceSvc_CustomPropertyType]
        } else {
            return []
        }
    }
    
    // Clears "has loaded this session" so that a refresh can be attempted
    @objc public func setCacheRetry() {
        FlightProps.hasLoadedThisSession = false
    }
    
    @objc public var cacheStatus : CacheStatus {
        get {
            return (rgPropTypes.isEmpty) ? .invalid : (FlightProps.hasLoadedThisSession ? .valid : .validButRefresh)
        }
    }
    
    private static func propertiesFromDB() -> [MFBWebServiceSvc_CustomPropertyType] {
        var rgcpt : [MFBWebServiceSvc_CustomPropertyType] = []
        
        var sqlCpt : OpaquePointer? = nil
        
        let szSql = "SELECT * FROM custompropertytypes ORDER BY title ASC"
        
        if (sqlite3_prepare(MFBSqlLite.current, szSql.cString(using: .ascii), -1, &sqlCpt, nil) != SQLITE_OK) {
            NSLog("Error: failed to prepare CPT query statement with message '%s'.", sqlite3_errmsg(MFBSqlLite.current))
        }
        
        while (sqlite3_step(sqlCpt) == SQLITE_ROW) {
            let cpt = MFBWebServiceSvc_CustomPropertyType(sqlCpt!)
            rgcpt.append(cpt)
        }
        
        sqlite3_finalize(sqlCpt)
        
        return rgcpt;
    }
    
    @objc public func cacheProps() {
        objc_sync_enter(rgPropTypes)
        let defs = UserDefaults.standard
        defs.set(try! NSKeyedArchiver.archivedData(withRootObject: rgPropTypes, requiringSecureCoding: true), forKey: FlightProps._szKeyCachedPropTypes)
        defs.synchronize()
        FlightProps.hasLoadedThisSession = true   // we've initialized - no need to refresh the cache again this session.
        objc_sync_exit(rgPropTypes)
        NSLog("Customproperty cache refreshed")
    }
    
    @objc public func loadCustomPropertyTypes() {
        NSLog("loadCustomPropertyTypes")
        errorString = ""
        
        let fNetworkAvail = MFBNetworkManager.shared.isOnLine

        
        // checking cache above will initialize self.rgPropTypes
        let cs = cacheStatus
        switch (cs)
        {
        case .valid:
            NSLog("loadCustomPropertyTypes - Using cached properties")
            return
        case .validButRefresh:
            if !fNetworkAvail {
                return
            }
            NSLog("loadCustomPropertyTypes - cache is valid, but going to refresh")
        case .invalid:
            // Use from DB by default - in case we are off-line, or there is some other failure
            if (rgPropTypes.isEmpty) {
                setPropTypeArray(FlightProps.propertiesFromDB())
                if (!rgPropTypes.isEmpty) { // should always be true.
                    cacheProps()
                }
                // Fall through - we will fetch them below
            }
        }
        
        // we now have a cached set array of property types OR network available; try a refresh, use this on failure.
        if fNetworkAvail {
            NSLog("Attempting to refresh cached property types")
            
            let cptSvc = MFBWebServiceSvc_PropertiesAndTemplatesForUser()
            cptSvc.szAuthUserToken =  MFBProfile.sharedProfile.AuthToken

            let sc = MFBSoapCall()
            sc.logCallData = false
            sc.timeOut = 10
            sc.delegate = self

            sc.makeCallAsync { b, sc in
                b.propertiesAndTemplatesForUserAsync(usingParameters: cptSvc, delegate: sc)
            }
        }
    }
    
    @objc public func deleteProperty(_ fp : MFBWebServiceSvc_CustomFlightProperty, forUser szAuthToken : String) {
        NSLog("deleteProperty")
        
        // new property - nothing to delete
        if (fp.propID?.intValue ?? 0) <= 0 || (fp.flightID?.intValue ?? 0) <= 0 {
            return
        }
        
        let fNetworkAvail = MFBNetworkManager.shared.isOnLine
        
        if !fNetworkAvail {
            errorString = String(localized: "No connection to the Internet is available", comment: "No connection to the Internet is available")
            return
        }
        

        let dpSvc = MFBWebServiceSvc_DeletePropertiesForFlight()
        dpSvc.idFlight = fp.flightID;
        dpSvc.szAuthUserToken = szAuthToken;
        dpSvc.rgPropIds = MFBWebServiceSvc_ArrayOfInt()
        dpSvc.rgPropIds.int_.add(fp.propID.intValue)

        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.timeOut = 10
        sc.delegate = self;
        sc.makeCallAsync { b, sc in
            b.deletePropertiesForFlightAsync(usingParameters: dpSvc, delegate: sc)
        }
    }
    
    @objc public func cachePropsAndTemplates(_ resp : MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse) {
        let bundle = resp.propertiesAndTemplatesForUserResult
        let rgCpt = bundle?.userProperties
        
        if (rgCpt?.customPropertyType?.count ?? 0) > 0 {
            setPropTypeArray(rgCpt!.customPropertyType! as? [MFBWebServiceSvc_CustomPropertyType])
            cacheProps()
        }
        else {
            setPropTypeArray(FlightProps.propertiesFromDB()) // update from the DB since refresh didn't work.
        }
        
        if (bundle?.userTemplates?.propertyTemplate != nil) {
            FlightProps._sharedTemplate = bundle!.userTemplates.propertyTemplate! as? [MFBWebServiceSvc_PropertyTemplate]
            FlightProps.saveTemplates()
        }
    }
    
    @objc public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse {
            cachePropsAndTemplates(resp)
        }
    }
    
    @objc public func propTypeFromID(_ id : NSNumber) -> MFBWebServiceSvc_CustomPropertyType? {
        objc_sync_enter(rgPropTypes)
        let ptid = id.intValue
        var result : MFBWebServiceSvc_CustomPropertyType? = nil
        for cpt in rgPropTypes {
            if cpt.propTypeID.intValue == ptid {
                result = cpt
                break
            }
        }
        objc_sync_exit(rgPropTypes)
        return result
    }
    
    public static func propTypeFromID(_ id : Int) -> MFBWebServiceSvc_CustomPropertyType? {
        return sharedPropTypes.first { cpt in
            cpt.propTypeID.intValue == id
        }
    }
    
    @objc public static func stringValueForProperty(_ fp : MFBWebServiceSvc_CustomFlightProperty, withType cpt : MFBWebServiceSvc_CustomPropertyType) -> String {
        var szValue = ""
        
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            szValue = (fp.boolValue.boolValue) ? " ✓" : ""
        case MFBWebServiceSvc_CFPPropertyType_cfpCurrency:
            let nfDecimal = NumberFormatter()
            nfDecimal.numberStyle = .currency
            szValue = nfDecimal.string(from: fp.decValue) ?? ""
        case MFBWebServiceSvc_CFPPropertyType_cfpDecimal:
            let nfDecimal = NumberFormatter()
            nfDecimal.numberStyle = .decimal
            nfDecimal.minimumFractionDigits = 1
            nfDecimal.maximumFractionDigits = 2
            szValue = nfDecimal.string(from: fp.decValue) ?? ""
        case MFBWebServiceSvc_CFPPropertyType_cfpInteger:
            szValue = (fp.intValue ?? 0).stringValue
        case MFBWebServiceSvc_CFPPropertyType_cfpString:
            szValue = fp.textValue ?? ""
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDate:
            szValue = fp.dateValue.formatted(date: .abbreviated, time: .omitted)
            break;
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime:
            szValue = (fp.dateValue as NSDate).utcString(useLocalTime: UserPreferences.current.UseLocalTime)
        default:
            break
        }
        
        return szValue
    }
    
    /*
      Returns a distillation of the provided list to only those items which are non-default AND not locked AND not in the specified templates
    */
    @objc public func distillList(_ rgFP : [MFBWebServiceSvc_CustomFlightProperty]?, includeLockedProps fIncludeLock : Bool, includeTemplates templates : NSSet?) -> NSMutableArray {
        var rgResult : [MFBWebServiceSvc_CustomFlightProperty] = []
        
        let templatedProps = (templates == nil) ? NSSet() : MFBWebServiceSvc_PropertyTemplate.propListForSets(templates!)
        
            for cfp in (rgFP ?? []) {
                if let cpt = propTypeFromID(cfp.propTypeID) {
                    if (fIncludeLock && cpt.isLocked) || templatedProps.contains(cpt.propTypeID!) || !cfp.isDefaultForType(cpt) {
                        rgResult.append(cfp)
                    }
                }
            }
        
        rgResult.sort { cfp1, cfp2 in
            let cpt1 = propTypeFromID(cfp1.propTypeID)
            let cpt2 = propTypeFromID(cfp2.propTypeID)
            let key1 = (cpt1?.sortKey ?? "").isEmpty ? cpt1?.title : cpt1!.sortKey
            let key2 = (cpt2?.sortKey ?? "").isEmpty ? cpt2?.title : cpt2!.sortKey
            return key1!.compare(key2!, options: .caseInsensitive) != .orderedDescending
        }
        
        return NSMutableArray(array: rgResult)
    }

    /*
     Provides a fully expanded list of properties, one item per property type, initialized with values from the supplied array
    */
    @objc public func crossProduct(_ rgFp : [MFBWebServiceSvc_CustomFlightProperty]) -> NSMutableArray {
        var rgResult : [MFBWebServiceSvc_CustomFlightProperty] = []
        
        objc_sync_enter(rgPropTypes)
        
        for cpt in rgPropTypes {
            var cfp : MFBWebServiceSvc_CustomFlightProperty? = nil;
            
            for fp in rgFp {
                if (fp.propTypeID!.intValue == cpt.propTypeID.intValue) {
                    cfp = fp
                    break
                }
            }
            
            if (cfp == nil) {
                cfp = MFBWebServiceSvc_CustomFlightProperty.getNewFlightProperty()
                cfp!.propTypeID = cpt.propTypeID
                cfp!.setDefaultForType(cpt)
            }
            
            rgResult.append(cfp!)
        }
        
        objc_sync_exit(rgPropTypes)
        
        return NSMutableArray(array: rgResult)
    }
    
    @objc public func defaultPropList() -> [MFBWebServiceSvc_CustomFlightProperty] {
        var rgResult : [MFBWebServiceSvc_CustomFlightProperty] = []
        objc_sync_enter(rgPropTypes)
        for cpt in self.rgPropTypes {
            if (cpt.isLocked) {
                let cfp = MFBWebServiceSvc_CustomFlightProperty.getNewFlightProperty()
                cfp.propTypeID = cpt.propTypeID
                cfp.setDefaultForType(cpt)
                rgResult.append(cfp)
            }
        }
        objc_sync_exit(rgPropTypes)
        return rgResult
    }
    
    @objc public static func getFlightPropsNoNet() -> FlightProps {
        let fp = FlightProps()
        if fp.cacheStatus == .invalid {
            fp.setPropTypeArray(FlightProps.propertiesFromDB())
        } else {
            fp.setPropTypeArray(FlightProps.cachedProps())
        }
        return fp
    }
    
    @objc public func propValueChanged(_ fp : MFBWebServiceSvc_CustomFlightProperty) {
        // see if the property was deleted (set to default value); if so, remove it.
        let cpt = propTypeFromID(fp.propTypeID)!
        if fp.isDefaultForType(cpt) {
            // Make a copy of this to delete (so that we don't have a collision in multi-threading
            let cfp = MFBWebServiceSvc_CustomFlightProperty.getNewFlightProperty()
            cfp.propTypeID = NSNumber(integerLiteral: fp.propTypeID.intValue)
            cfp.propID = NSNumber(integerLiteral: fp.propID.intValue)
            cfp.flightID = NSNumber(integerLiteral: fp.flightID.intValue)
            cfp.intValue = NSNumber(integerLiteral: 1)
            cfp.decValue = NSNumber(floatLiteral: 1.0)
            cfp.boolValue = USBoolean(bool: true)
            cfp.dateValue = Date()
            cfp.textValue = " "
            
            deleteProperty(cfp, forUser:MFBProfile.sharedProfile.AuthToken)
            
            // And now reset the actual object in the array
            fp.setDefaultForType(cpt)
            fp.propID = nil  // make it a "new" property again.
        }
    }
        
    // MARK: Locked Properties
    private static var lockedTypes : Set<Int>? = nil
    private static var sharedLockedTypes : Set<Int> {
        get {
            if (lockedTypes == nil) {
                // We're storing this now in a set, but it had been in a dictionary, so for backwards compatibility keep those semantics
                let d = UserDefaults.standard.object(forKey: _szKeyPrefsLockedTypes) as? [String : Int] ?? [:]
                lockedTypes = Set<Int>()
                for (_, value) in d {
                    lockedTypes!.insert(value)
                }
            }
            return lockedTypes!
        }
        set(newSet) {
            lockedTypes =  newSet

            // Because we used to store this in a dictionary, continue to do so.
            var d : [String : Int] = [:]
            for val in newSet {
                d[String(format: "%d", val)] = val
            }
            UserDefaults.standard.set(d, forKey: _szKeyPrefsLockedTypes)
            UserDefaults.standard.synchronize()
        }
    }
    
    // we moved setPropLock to be static, so this is a conveninence instance method.
    @objc public func setPropLock(_ fLock : Bool, forPropTypeID propTypeID : Int) {
        FlightProps.setPropLock(fLock, forPropTypeID: propTypeID)
    }
    
    @objc public static func setPropLock(_ fLock : Bool, forPropTypeID propTypeID : Int) {
        if (fLock) {
            FlightProps.sharedLockedTypes.insert(propTypeID)
        } else {
            FlightProps.sharedLockedTypes.remove(propTypeID)
        }
    }
    
    public static func isLockedProperty(_ idPropType : Int) -> Bool {
        return sharedLockedTypes.contains(idPropType)
    }
    
    @objc public static func clearAllLocked() {
        sharedLockedTypes.removeAll()
    }
}

