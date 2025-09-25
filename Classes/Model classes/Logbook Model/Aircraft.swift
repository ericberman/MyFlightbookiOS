/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2025 MyFlightbook, LLC
 
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
//  Aircraft.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/13/23.
//

import Foundation

@objc public class Aircraft : MFBAsyncOperation, MFBSoapCallDelegate {
    private var dictHighWaterHobbs : [NSNumber : NSNumber] = [:]
    private var dictHighWaterTach : [NSNumber : NSNumber] = [:]
    private var dictHighWaterFlightMeter : [NSNumber : NSNumber] = [:]
    private var aircraftIDPreferred = -1
    
    @objc public var rgAircraftForUser : [MFBWebServiceSvc_Aircraft]? = nil
    @objc public var errorString = ""
    @objc public var rgMakeModels : [MFBWebServiceSvc_SimpleMakeModel]? = nil
    
    private static let _szKeyPreferredAircraftId = "PreferredAircraftID"
    private static let _szKeyCachedAircraft = "keyCacheAircraft"
    private static let _szKeyCachedAircraftRetrievalDate = "keyCacheAircraftDate"
    private static let _szKeyCachedAircraftAuthToken = "keyCacheAircraftAuthToken"
    
    private static let CONTEXT_DELETE_AIRCRAFT=1085683
    private static let CONTEXT_AIRCRAFTFORUSER=8503832

    @objc public static func aircraftInstanceTypeDisplay(_ instanceType : MFBWebServiceSvc_AircraftInstanceTypes) -> String {
        switch (instanceType) {
        case MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft:
            return String(localized: "Real Aircraft", comment: "Indicates an actual aircraft")
        case MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator:
            return String(localized: "Sim: Uncertified", comment: "Indicates an uncertified sim such as Microsoft Flight Simulator")
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD:
            return String(localized: "Aviation Training Device (ATD)", comment: "Indiates an ATD (FAA training device type)")
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator:
            return String(localized: "Sim: Log approaches", comment: "Indicates a training device where instrument approaches can count towards instrument currency")
        case MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator:
            return String(localized: "Sim: Log approaches, landings", comment: "Indicates a device where instrument approaches and landings count towards instrument currency and passenger carrying currency")
        default:
            return ""
        }
    }
    
    private static var _shared : Aircraft = Aircraft()
    @objc public static var sharedAircraft : Aircraft {
        get {
            return _shared
        }
    }
    
    @objc public override init() {
        super.init()
        rgAircraftForUser = cachedAircraft()
    }
    
    @objc public func clearAircraft() {
        rgAircraftForUser = nil
    }
    
    @objc public static let PrefixSim = "SIM"
    
    // MARK: State management
    @objc public var DefaultAircraftID : Int {
        get {
            aircraftIDPreferred = UserDefaults.standard.integer(forKey: Aircraft._szKeyPreferredAircraftId)
            checkAircraftID()
            return aircraftIDPreferred
        }
        set (idAircraft) {
            aircraftIDPreferred = idAircraft
            UserDefaults.standard.set(idAircraft, forKey: Aircraft._szKeyPreferredAircraftId)
            UserDefaults.standard.synchronize()
        }
    }
    
    private func checkAircraftID() {
        let ac = AircraftByID(aircraftIDPreferred)
        if (ac == nil) {
            if (rgAircraftForUser ?? []).isEmpty {
                DefaultAircraftID = -1
            } else {
                let rgAvailable = rgAircraftForUser!.filter { ac in
                    return !ac.hideFromSelection.boolValue
                }
                DefaultAircraftID = rgAvailable.isEmpty ? rgAircraftForUser![0].aircraftID.intValue : rgAvailable[0].aircraftID.intValue
            }
        }
    }
    
    // MARK: Caching
    
    @objc public func cacheAircraft(_ rgAircraft : [MFBWebServiceSvc_Aircraft], forUser szAuthToken : String) {
        NSLog("Caching %d aircraft", rgAircraft.count)
        let defs = UserDefaults.standard
        do {
            defs.set(try NSKeyedArchiver.archivedData(withRootObject: rgAircraft, requiringSecureCoding: true), forKey: Aircraft._szKeyCachedAircraft)
            defs.set(szAuthToken, forKey: Aircraft._szKeyCachedAircraftAuthToken)
            defs.set(Date().timeIntervalSince1970, forKey: Aircraft._szKeyCachedAircraftRetrievalDate)
            defs.synchronize()
        } catch {
            // TODO: Show an error, but should never happen
        }
    }
    
    @objc public func invalidateCachedAircraft() {
        UserDefaults.standard.set(0, forKey: Aircraft._szKeyCachedAircraftRetrievalDate)
    }
    
    @objc public func cachedAircraft() -> [MFBWebServiceSvc_Aircraft]? {
        let rgArrayLastData = UserDefaults.standard.object(forKey: Aircraft._szKeyCachedAircraft)
        if (rgArrayLastData != nil) {
            do {
                return try NSKeyedUnarchiver.unarchivedObject(ofClasses:
                                                                [NSArray.self, MFBWebServiceSvc_Aircraft.self, NSNumber.self, NSMutableArray.self, MFBWebServiceSvc_ArrayOfInt.self],
                                                              from: rgArrayLastData as! Data) as? [MFBWebServiceSvc_Aircraft]
            }
            catch {
                // TODO: Show an error or rethrow?
            }
        }
        return nil
    }
    
    @objc public func refreshIfNeeded() {
        self.setDelegate(self) { sc, ao in
            if (sc?.errorString ?? "").isEmpty {
                Aircraft.sharedAircraft.checkAircraftID()
            } else {
                // display this after a pause
                DispatchQueue.main.async {
                    UIViewController.topViewControllerForScenes(UIApplication.shared.connectedScenes)?.showErrorAlertWithMessage(msg: sc!.errorString)
                }
            }
        }
        loadAircraftForUser(false)
    }
    
    // MARK: Soap Calls
    @objc public func cacheStatus(_ szAuthToken : String) -> CacheStatus {
        // see whether we have valid cached aircraft
        let rgAircraftCached = cachedAircraft()
        
        if (rgAircraftCached == nil) {
            return .invalid
        }
        let timestampAircraftCache = UserDefaults.standard.double(forKey: Aircraft._szKeyCachedAircraftRetrievalDate)
        let szCachedToken = UserDefaults.standard.string(forKey: Aircraft._szKeyCachedAircraftAuthToken)
        
        let timeSinceLastRefresh = Date().timeIntervalSince1970 - timestampAircraftCache
        
        // (a) we have a cached aircraft list,
        // (b) it was retrieved for this token, and
        // (c) less than the cache lifetime has passed.
        if (rgAircraftCached != nil && self.rgAircraftForUser != nil &&
            szCachedToken != nil && szCachedToken!.compare(szAuthToken) == .orderedSame &&
            timeSinceLastRefresh < Double(MFBConstants.CACHE_LIFETIME)) {
            return (timeSinceLastRefresh < Double(MFBConstants.CACHE_REFRESH) || !MFBNetworkManager.shared.isOnLine) ? .valid : .validButRefresh
        }

        return .invalid
    }
    
    @objc public func loadAircraftForUser(_ forceRefresh : Bool) {
        NSLog("loadAircraftForUser");
        errorString = ""
        let szAuthToken = MFBProfile.sharedProfile.AuthToken

        switch cacheStatus(szAuthToken) {
        case .valid:
            NSLog("Cached aircraft are valid; using cached aircraft")
            if (!forceRefresh) {
                operationCompleted(nil)
                return
            }
        case .validButRefresh:
            NSLog("Cached aircraft list is valid, but a refresh attempt will be made.")
        case .invalid:
            NSLog("loadAircraftForUser - cache not valid");
        }
        
        let aircraftForUserSvc = MFBWebServiceSvc_AircraftForUser()
        aircraftForUserSvc.szAuthUserToken = szAuthToken;
        
        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.timeOut = 10;
        sc.delegate = self
        sc.contextFlag = Aircraft.CONTEXT_AIRCRAFTFORUSER
        
        sc.makeCallAsync { b, sc in
            b.aircraftForUserAsync(usingParameters: aircraftForUserSvc, delegate: sc)
        }
    }
    
    @objc public func deleteAircraft(_ idAircraft : NSNumber, forUser szAuthToken : String) {
        NSLog("deleteAircraft")
        errorString = ""
        
        let deleteAircraft = MFBWebServiceSvc_DeleteAircraftForUser()
        deleteAircraft.szAuthUserToken = szAuthToken;
        deleteAircraft.idAircraft = idAircraft;
        
        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.delegate = self
        sc.contextFlag = Aircraft.CONTEXT_DELETE_AIRCRAFT
        
        sc.makeCallAsync { b, sc in
            b.deleteAircraftForUserAsync(usingParameters: deleteAircraft, delegate: sc)
        }
    }
    
    @objc public func addAircraft(_ ac : MFBWebServiceSvc_Aircraft, ForUser szAuthToken : String) {
        NSLog("addAircraft")
        errorString = ""
        
        let addAircraft = MFBWebServiceSvc_AddAircraftForUser()
        
        addAircraft.idInstanceType = ac.instanceTypeIDFromInstanceType(ac.instanceType)
        addAircraft.idModel = ac.modelID
        addAircraft.szTail = ac.tailNumber
        addAircraft.szAuthUserToken = szAuthToken
        
        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.delegate = self
        
        sc.makeCallAsync { b, sc in
            b.addAircraftForUserAsync(usingParameters: addAircraft, delegate: sc)
        }
    }
    
    @objc public func updateAircraft(_ ac : MFBWebServiceSvc_Aircraft, ForUser szAuthToken : String) {
        NSLog("updateAircraft")
        errorString = ""

        let updAircraft = MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes()
        updAircraft.ac = ac
        updAircraft.szAuthUserToken = szAuthToken
        
        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.delegate = self
        
        sc.makeCallAsync { b, sc in
            b.updateMaintenanceForAircraftWithFlagsAndNotesAsync(usingParameters: updAircraft, delegate: sc)
        }
    }
    
    @objc public func loadMakeModels() {
        NSLog("loadMakeModels")
        errorString = ""
            
        let makesAndModels = MFBWebServiceSvc_MakesAndModels()

        let sc = MFBSoapCall()
        sc.logCallData = false
        sc.delegate = self
        
        sc.makeCallAsync { b, sc in
            b.makesAndModelsAsync(usingParameters: makesAndModels, delegate: sc)
        }
    }
    
    @objc public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        
        if (sc.contextFlag == Aircraft.CONTEXT_AIRCRAFTFORUSER) {
            if errorString.isEmpty { // success! {
                cacheAircraft(rgAircraftForUser ?? [], forUser: MFBProfile.sharedProfile.AuthToken)
            } else {
                // see if this was a refresh attempt.  If so, and if we have a set of aircraft to fall back upon, then we can fall
                // back on the cache and treat it as a non-error
                if (cacheStatus(MFBProfile.sharedProfile.AuthToken) != .invalid && rgAircraftForUser != nil) {
                    self.errorString = ""
                }
            }
        } else if (sc.contextFlag == Aircraft.CONTEXT_DELETE_AIRCRAFT) {
            if errorString.isEmpty {
                cacheAircraft(rgAircraftForUser!, forUser: MFBProfile.sharedProfile.AuthToken)
            }
        }
        
        self.operationCompleted(sc)
    }
    
    @objc public func BodyReturned(body : AnyObject) {
        if let resp = body as? MFBWebServiceSvc_AircraftForUserResponse {
            rgAircraftForUser = resp.aircraftForUserResult.aircraft as? [MFBWebServiceSvc_Aircraft]
            checkAircraftID()
        } else if let resp = body as? MFBWebServiceSvc_MakesAndModelsResponse {
            rgMakeModels = resp.makesAndModelsResult.simpleMakeModel as? [MFBWebServiceSvc_SimpleMakeModel]
            NotificationCenter.default.post(name: Notification.Name("makesLoaded"), object: self)
        }
        else if let resp = body as? MFBWebServiceSvc_AddAircraftForUserResponse {
            if ((resp.addAircraftForUserResult?.aircraft ?? []).count > 0) {
                rgAircraftForUser = resp.addAircraftForUserResult.aircraft as? [MFBWebServiceSvc_Aircraft]
            }
            checkAircraftID()
        } else if let resp = body as? MFBWebServiceSvc_DeleteAircraftForUserResponse {
            if ((resp.deleteAircraftForUserResult?.aircraft ?? []).count > 0) {
                rgAircraftForUser = resp.deleteAircraftForUserResult.aircraft as? [MFBWebServiceSvc_Aircraft]
            }
            self.checkAircraftID()
        }
    }
    
    // MARK: Misc. Utility
    @objc public var preferredAircraft : MFBWebServiceSvc_Aircraft? {
        get {
            if rgAircraftForUser == nil || rgAircraftForUser!.isEmpty {
                return nil
            }
            
            let ac = AircraftByID(aircraftIDPreferred)
            if aircraftIDPreferred < 0 || ac == nil {
                checkAircraftID()
            }
            
            return ac ?? AircraftByID(aircraftIDPreferred)
        }
    }
    
    @objc public func indexOfAircraftID(_ idAircraft : Int) -> Int {
        let result = -1
        
        if (rgAircraftForUser == nil) {
            return result
        }
        
        if (idAircraft > 0) {
            for i in 0..<rgAircraftForUser!.count {
                if rgAircraftForUser![i].aircraftID.intValue == idAircraft {
                    return i
                }
            }
        }
        return result
    }
    
    @objc public func AircraftByID(_ idAircraft : Int) -> MFBWebServiceSvc_Aircraft? {
        return rgAircraftForUser?.first { ac in
            ac.aircraftID.intValue == idAircraft
        }
    }

    @objc public func AircraftByTail(_ szTail : String) -> MFBWebServiceSvc_Aircraft? {
        return rgAircraftForUser?.first { ac in
            ac.tailNumber.compare(szTail, options: .caseInsensitive) == .orderedSame
        }
    }
    
    @objc public func indexOfModelID(_ idModel : Int) -> Int {
        for i in 0..<(rgMakeModels?.count ?? 0) {
            if rgMakeModels![i].modelID.intValue == idModel {
                return i
            }
        }
        
        return -1
    }
 
    @objc public func descriptionOfModelId(_ idModel : Int) -> String {
        for smm in (rgMakeModels ?? [])  {
            if smm.modelID.intValue == idModel {
                // Because fucking swift fucking renames every fucking objective-c variable because of their fucking anal retentiveness about capitalization,
                // "Description" on the simple make/model conflicts with "description" that gets bridging assigned.
                // I could use the NS_SWIFT_NAME macro to define an alternate name, but alas THAT has to be done in the auto-generated MFBWebServiceSvc.h
                // file, which means that whenever I update that file I'd break if I forget to edit it, which I don't want to do
                // But alas, it seems that using description! seems to do the trick of getting the correct property.
                return smm.description!
            }
        }
        return ""
    }
    
    @objc public func validateAircraftForUser(_ ac : MFBWebServiceSvc_Aircraft) -> Bool {
        let idAircraft = ac.aircraftID.intValue
        return rgAircraftForUser?.first { ac in
            ac.aircraftID.intValue == idAircraft
        } != nil
    }
    
    // Return all of the user aircraft that are not hidden from selection
    // BUT ensure that acToInclude is included
    @objc public func AircraftForSelection(_ acIDToInclude : NSNumber?) -> [MFBWebServiceSvc_Aircraft] {
        let idAircraft = acIDToInclude?.intValue ?? -1
        return (rgAircraftForUser ?? []).filter { ac in
            !ac.hideFromSelection.boolValue || ac.aircraftID.intValue == idAircraft
        }
    }
    
    @objc public func modelsInUse() -> [MFBWebServiceSvc_SimpleMakeModel] {
        var dictMM : [Int : MFBWebServiceSvc_SimpleMakeModel] = [:]
        var dictMakesUsed : [Int : MFBWebServiceSvc_SimpleMakeModel] = [:]
        
        // build a dictionary of all makes/models, keyed by id
        for smm in (rgMakeModels ?? []) {
            dictMM[smm.modelID.intValue] = smm
        }
        
        // now build a dictionary of all makes/models, keyed by id, from the aircraft in the user's list
        for acUser in (self.rgAircraftForUser ?? []) {
            if let obj = dictMM[acUser.modelID.intValue] { // test for nil in case there is an aircraft in the list that has a model that is not in the list of models.
                dictMakesUsed[acUser.modelID.intValue] = obj;
            }
        }
        
        // now return an array from that
        return dictMakesUsed.values.sorted { smm1, smm2 in
            // Because fucking swift fucking renames every fucking objective-c variable because of their fucking anal retentiveness about capitalization,
            // "Description" on the simple make/model conflicts with "description" that gets bridging assigned.
            // I could use the NS_SWIFT_NAME macro to define an alternate name, but alas THAT has to be done in the auto-generated MFBWebServiceSvc.h
            // file, which means that whenever I update that file I'd break if I forget to edit it, which I don't want to do
            // But alas, it seems that using description! seems to do the trick of getting the correct property.
            smm1.description!.compare(smm2.description!) != .orderedDescending
        }
    }
    
    // MARK: Tach/hobbs high-water
    @objc public func setHighWaterTach(_ tach : NSNumber?, forAircraft aircraftID : NSNumber) {
        if ((tach?.doubleValue) ?? 0.0) == 0.0 {
            return
        }
        
        if getHighWaterTachForAircraft(aircraftID).doubleValue < tach!.doubleValue {
            dictHighWaterTach[aircraftID] = tach!
        }
    }
    
    @objc public func getHighWaterTachForAircraft(_ aircraftID : NSNumber) -> NSNumber {
        return dictHighWaterTach[aircraftID] ?? NSNumber(floatLiteral: 0.0)
    }
    
    @objc public func setHighWaterHobbs(_ hobbs : NSNumber?, forAircraft aircraftID : NSNumber) {
        if ((hobbs?.doubleValue) ?? 0.0) == 0.0 {
            return
        }
        
        if getHighWaterHobbsForAircraft(aircraftID).doubleValue < hobbs!.doubleValue {
            dictHighWaterHobbs[aircraftID] = hobbs!
        }
    }
    
    @objc public func getHighWaterHobbsForAircraft(_ aircraftID : NSNumber) -> NSNumber {
        return dictHighWaterHobbs[aircraftID] ?? NSNumber(floatLiteral: 0.0)
    }
    
    @objc public func getHighWaterFlightMeter(_ aircraftID: NSNumber) -> NSNumber {
        return dictHighWaterFlightMeter[aircraftID] ?? NSNumber(floatLiteral: 0.0)
    }
    
    @objc public func setHighWaterFlightMeter(_ meter : NSNumber?, forAircraft aircraftID : NSNumber) {
        if ((meter?.doubleValue) ?? 0.0) == 0.0 {
            return
        }
        
        if getHighWaterFlightMeter(aircraftID).doubleValue < meter!.doubleValue {
            dictHighWaterFlightMeter[aircraftID] = meter!
        }
    }
    
    public func clearHighWater() {
        dictHighWaterTach.removeAll()
        dictHighWaterHobbs.removeAll()
        dictHighWaterFlightMeter.removeAll()
    }
}

@objc public protocol AircraftViewControllerDelegate {
    @objc func aircraftListChanged()
}

