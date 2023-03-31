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
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  PackAndGo.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public class PackAndGo : NSObject, MFBSoapCallDelegate {
    @objc public var errorString = ""
    @objc public var authToken = ""
    
    private static let keyCurrency = "packedCurrencyKey"
    private static let keyTotals = "packedTotalsKey"
    private static let keyFlights = "packedFlightsKey"
    private static let keyAirports = "packedAirportsKey"
    private static let keyCurrencyDate = "packedCurrencyDate"
    private static let keyTotalsDate = "packedTotalsKeyDate"
    private static let keyFlightsDate = "packedFlightsKeyDate"
    private static let keyAirportsDate = "packedAirportsKeyDate"
    private static let keyPackedDate = "packedAllDate"
    
    private var fCurrencyReturned = false
    private var fTotalsReturned = false
    private var fFlightsReturned = false
    private var fAircraftReturned = false
    private var fPropsReturned = false
    private var fVisitedReturned = false
    
    private var packAll = false
    
    private var completionHandler : (() -> Void)? = nil
    private var progressHandler : ((String) -> Void)? = nil
    
    // MARK: Storing/retrieving
    static func dateForKey(_ key : String) -> Date? {
        return UserDefaults.standard.object(forKey: key) as? Date
    }
    
    static func setDate(_ dt : Date, forKey key : String) {
        UserDefaults.standard.set(dt, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    static func valuesForKey(_ key : String) -> [Any] {
        return try! NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self,
                                                               NSMutableArray.self,
                                                               NSString.self,
                                                               NSDate.self,
                                                               NSNumber.self,
                                                               LogbookEntry.self,
                                                               USBoolean.self,
                                                               MFBWebServiceSvc_LogbookEntry.self,
                                                               MFBWebServiceSvc_airport.self,
                                                               MFBWebServiceSvc_VideoRef.self,
                                                               MFBWebServiceSvc_MakeModel.self,
                                                               MFBWebServiceSvc_Aircraft.self,
                                                               MFBWebServiceSvc_ArrayOfVideoRef.self,
                                                               MFBWebServiceSvc_ArrayOfString.self,
                                                               MFBWebServiceSvc_ArrayOfInt.self,
                                                               MFBWebServiceSvc_ArrayOfAirport.self,
                                                               MFBWebServiceSvc_ArrayOfMakeModel.self,
                                                               MFBWebServiceSvc_ArrayOfLatLong.self,
                                                               MFBWebServiceSvc_ArrayOfLogbookEntry.self,
                                                               MFBWebServiceSvc_ArrayOfLatLong.self,
                                                               MFBWebServiceSvc_ArrayOfAircraft.self,
                                                               MFBWebServiceSvc_ArrayOfTotalsItem.self,
                                                               MFBWebServiceSvc_ArrayOfCannedQuery.self,
                                                               MFBWebServiceSvc_ArrayOfCategoryClass.self,
                                                               MFBWebServiceSvc_ArrayOfPropertyTemplate.self,
                                                               MFBWebServiceSvc_ArrayOfVisitedAirport.self,
                                                               MFBWebServiceSvc_ArrayOfMFBImageInfo.self,
                                                               MFBWebServiceSvc_ArrayOfCurrencyStatusItem.self,
                                                               MFBWebServiceSvc_ArrayOfCustomPropertyType.self,
                                                               MFBWebServiceSvc_ArrayOfCustomFlightProperty.self,
                                                               MFBWebServiceSvc_FlightQuery.self,
                                                               MFBWebServiceSvc_TotalsItem.self,
                                                               MFBWebServiceSvc_CurrencyStatusItem.self,
                                                               MFBWebServiceSvc_VisitedAirport.self,
                                                               MFBWebServiceSvc_Aircraft.self,
                                                               MFBWebServiceSvc_VideoRef.self,
                                                               MFBWebServiceSvc_LatLong.self,
                                                               MFBWebServiceSvc_CannedQuery.self,
                                                               MFBWebServiceSvc_CategoryClass.self,
                                                               MFBWebServiceSvc_PropertyTemplate.self,
                                                               MFBWebServiceSvc_MFBImageInfo.self,
                                                               MFBWebServiceSvc_CustomPropertyType.self,
                                                               MFBWebServiceSvc_CustomFlightProperty.self],
                                                   from: UserDefaults.standard.object(forKey: key) as! Data) as! [AnyObject]
    }
    
    static func setValues(_ arr : [AnyObject], forKey key : String) {
        try! UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: arr, requiringSecureCoding: true), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    @objc public static func clearPackedData() {
        let defs = UserDefaults.standard
        defs.set(nil, forKey: keyCurrency)
        defs.set(nil, forKey: keyTotals)
        defs.set(nil, forKey: keyFlights)
        defs.set(nil, forKey: keyAirports)
        defs.set(nil, forKey: keyCurrencyDate)
        defs.set(nil, forKey: keyTotalsDate)
        defs.set(nil, forKey: keyFlightsDate)
        defs.set(nil, forKey: keyAirportsDate)
        defs.set(nil, forKey: keyPackedDate)
        defs.synchronize()
    }
    
    @objc public static var lastPackDate : Date? {
        get {
            return dateForKey(keyPackedDate)
        }
        set(val) {
            UserDefaults.standard.set(val, forKey: keyPackedDate)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Pack
    @objc public func packAll(progressUpdate pu: @escaping (String) -> Void, completionHandler cu : @escaping () -> Void) {
        progressHandler = pu
        completionHandler = cu

        fVisitedReturned = false
        fPropsReturned = false
        fTotalsReturned = false
        fFlightsReturned = false
        fCurrencyReturned = false
        fAircraftReturned = false
        
        // initiate a sequential cascade
        packAll = true
        packAircraft()
    }
    
    func updateProgress(_ s : String) {
        DispatchQueue.main.async {
            self.progressHandler?(s)
        }
    }
    
    // MARK: Retrieving from WebServices
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_AircraftForUserResponse {
            Aircraft.sharedAircraft.cacheAircraft(resp.aircraftForUserResult.aircraft as! [MFBWebServiceSvc_Aircraft], forUser: authToken)
            fAircraftReturned = true
            if (packAll) {
                packProps()
            }
        } else if let resp = body as? MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse {
            FlightProps().cachePropsAndTemplates(resp)
            fPropsReturned = true
            if (packAll) {
                packCurrency()
            }
        } else if let resp = body as? MFBWebServiceSvc_GetCurrencyForUserResponse {
            PackAndGo.updateCurrency(resp.getCurrencyForUserResult.currencyStatusItem as! [MFBWebServiceSvc_CurrencyStatusItem])
            fCurrencyReturned = true
            if (packAll) {
                packTotals()
            }
        } else if let resp = body as? MFBWebServiceSvc_TotalsForUserWithQueryResponse {
            PackAndGo.updateTotals(resp.totalsForUserWithQueryResult.totalsItem as! [MFBWebServiceSvc_TotalsItem])
            fTotalsReturned = true
            if (packAll) {
                packFlights()
            }
        } else if let resp = body as? MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse {
            PackAndGo.updateFlights(resp.flightsWithQueryAndOffsetResult.logbookEntry as! [MFBWebServiceSvc_LogbookEntry])
            fFlightsReturned = true
            if (packAll) {
                packVisited()
            }
        } else if let resp = body as? MFBWebServiceSvc_VisitedAirportsResponse {
            PackAndGo.updateVisited(resp.visitedAirportsResult.visitedAirport as! [MFBWebServiceSvc_VisitedAirport])
            fVisitedReturned = true
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        
        if (fPropsReturned && fTotalsReturned && fVisitedReturned && fFlightsReturned && fAircraftReturned && fCurrencyReturned) {
            PackAndGo.lastPackDate = Date()
            packAll = false
            completionHandler?()
        }
    }
    
    func getSoapCall() -> MFBSoapCall {
        let sc = MFBSoapCall()
        sc.delegate = self
        sc.timeOut = 60.0 // 60 second timeout
        return sc
    }
    
    // MARK: Currency
    func packCurrency() {
        updateProgress(String(localized: "Getting Currency...", comment: "Progress indicator for currency"))
        let currencyForUserSVC = MFBWebServiceSvc_GetCurrencyForUser()
        currencyForUserSVC.szAuthToken = authToken
        
        let sc = getSoapCall()
        
        sc.makeCallAsync { b, sc in
            b.getCurrencyForUserAsync(usingParameters: currencyForUserSVC, delegate: sc)
        }
    }
    
    @objc public static func updateCurrency(_ currency : [MFBWebServiceSvc_CurrencyStatusItem]) {
        PackAndGo.setValues(currency, forKey: PackAndGo.keyCurrency)
        PackAndGo.setDate(Date(), forKey: PackAndGo.keyCurrencyDate)
    }
    
    @objc public static var cachedCurrency : [MFBWebServiceSvc_CurrencyStatusItem] {
        get {
            return PackAndGo.valuesForKey(keyCurrency) as? [MFBWebServiceSvc_CurrencyStatusItem] ?? []
        }
    }
    
    @objc public static var lastCurrencyPackDate : NSDate? {
        get {
            return dateForKey(keyCurrencyDate) as? NSDate
        }
    }
    
    // MARK: Totals
    func packTotals() {
        updateProgress(String(localized: "Getting Totals...", comment: "progress indicator"))
        let totalsForUserSvc = MFBWebServiceSvc_TotalsForUserWithQuery()
        totalsForUserSvc.szAuthToken = authToken
        totalsForUserSvc.fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        
        let sc = getSoapCall()
        
        sc.makeCallAsync { b, sc in
            b.totalsForUserWithQueryAsync(usingParameters: totalsForUserSvc, delegate: sc)
        }
    }
    
    @objc public static func updateTotals(_ totals : [MFBWebServiceSvc_TotalsItem]) {
        PackAndGo.setValues(totals, forKey: PackAndGo.keyTotals)
        PackAndGo.setDate(Date(), forKey: PackAndGo.keyTotalsDate)
    }
    
    @objc public static var cachedTotals : [MFBWebServiceSvc_TotalsItem] {
        get {
            return PackAndGo.valuesForKey(keyTotals) as? [MFBWebServiceSvc_TotalsItem] ?? []
        }
    }
    
    @objc public static var lastTotalsPackDate : NSDate? {
        get {
            return dateForKey(keyTotalsDate) as? NSDate
        }
    }
    
    // MARK: Flights
    func packFlights() {
        updateProgress(String(localized: "Getting Recent Flights...", comment: "Progress - getting recent flights"))
        let fbdSVC = MFBWebServiceSvc_FlightsWithQueryAndOffset()
        fbdSVC.szAuthUserToken = authToken
        fbdSVC.fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        fbdSVC.offset = 0
        fbdSVC.maxCount = -1
        
        let sc = getSoapCall()
        
        sc.makeCallAsync { b, sc in
            b.flightsWithQueryAndOffsetAsync(usingParameters: fbdSVC, delegate: sc)
        }
    }
    
    @objc public static func updateFlights(_ flights : [MFBWebServiceSvc_LogbookEntry]) {
        PackAndGo.setValues(flights, forKey: PackAndGo.keyFlights)
        PackAndGo.setDate(Date(), forKey: PackAndGo.keyFlightsDate)
    }
    
    @objc public static var cachedFlights : [MFBWebServiceSvc_LogbookEntry] {
        get {
            return PackAndGo.valuesForKey(keyFlights) as? [MFBWebServiceSvc_LogbookEntry] ?? []
        }
    }
    
    @objc public static var lastFlightsPackDate : NSDate? {
        get {
            return dateForKey(keyFlightsDate) as? NSDate
        }
    }
    
    // MARK: Aircraft
    func packAircraft() {
        updateProgress(String(localized: "Updating aircraft...", comment: "Progress: updating aircraft"))
        let acSvc = MFBWebServiceSvc_AircraftForUser()
        acSvc.szAuthUserToken = authToken
        
        let sc = getSoapCall()
        
        sc.makeCallAsync { b, sc in
            b.aircraftForUserAsync(usingParameters: acSvc, delegate: sc)
        }
    }
    
    // MARK: Props
    func packProps() {
        updateProgress(String(localized: "PackAndGoProgProps", comment: "Pack progress - properties"))
        let fpSvc = MFBWebServiceSvc_PropertiesAndTemplatesForUser()
        fpSvc.szAuthUserToken = authToken
        let sc = getSoapCall()

        sc.makeCallAsync { b, sc in
            b.propertiesAndTemplatesForUserAsync(usingParameters: fpSvc, delegate: sc)
        }
    }
    
    
    // MARK: Visited
    func packVisited() {
        updateProgress(String(localized: "Getting Visited Airports...", comment: "Progress indicator while getting visited airports"))
        let visitedAirportsSVC = MFBWebServiceSvc_VisitedAirports()
        visitedAirportsSVC.szAuthToken = authToken

        let sc = getSoapCall()
        
        sc.makeCallAsync { b, sc in
            b.visitedAirportsAsync(usingParameters: visitedAirportsSVC, delegate: sc)
        }
    }
    
    @objc public static func updateVisited(_ flights : [MFBWebServiceSvc_VisitedAirport]) {
        PackAndGo.setValues(flights, forKey: PackAndGo.keyAirports)
        PackAndGo.setDate(Date(), forKey: PackAndGo.keyAirportsDate)
    }
    
    @objc public static var cachedVisited : [MFBWebServiceSvc_VisitedAirport] {
        get {
            return PackAndGo.valuesForKey(keyAirports) as? [MFBWebServiceSvc_VisitedAirport] ?? []
        }
    }
    
    @objc public static var lastVisitedPackDate : NSDate? {
        get {
            return dateForKey(keyAirportsDate) as? NSDate
        }
    }
}
