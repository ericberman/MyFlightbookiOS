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
//  SynchronousCalls.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/22/23.
//

import Foundation

@objc public class SynchronousCalls : NSObject, MFBSoapCallDelegate {

    let group = DispatchGroup()
    
    private let onResultKey = "onResultKey"
    private var _onBodyReturned : ((AnyObject) -> Void)!
    
    // MARK: MFBSoapDelegate
    @objc func getSoapCall(onBodyReturned : @escaping (AnyObject) -> Void) -> MFBSoapCall {
        assert(!Thread.isMainThread, "SynchronousCall made on main thread!!!")
        let sc = MFBSoapCall(delegate: self)
        sc.timeOut = 20.0   // 20 second timeout
        _onBodyReturned = onBodyReturned
        group.enter()
        return sc
    }
    
    @objc public func BodyReturned(body: AnyObject) {
        _onBodyReturned(body)
    }
    
    @objc public func ResultCompleted(sc: MFBSoapCall) {
        group.leave()
    }
    
    public func currency(forUserSynchronous szAuthToken : String?) -> [SimpleCurrencyItem]? {
        if (szAuthToken ?? "").isEmpty {
            return nil
        }
        
        let curSvc = MFBWebServiceSvc_GetCurrencyForUser()
        curSvc.szAuthToken = szAuthToken
        
        var result : [MFBWebServiceSvc_CurrencyStatusItem] = []
        
        getSoapCall { body in
            if let resp = body as? MFBWebServiceSvc_GetCurrencyForUserResponse {
                result = resp.getCurrencyForUserResult.currencyStatusItem as? [MFBWebServiceSvc_CurrencyStatusItem] ?? []
            }
        }.makeCallAsync { b, sc in
            b.getCurrencyForUserAsync(usingParameters: curSvc, delegate: sc)
        }
        
        group.wait()
        return MFBWebServiceSvc_CurrencyStatusItem.toSimpleItems(items: result)
    }
    
    public func totals(forUserSynchronous szAuthToken : String?) -> [SimpleTotalItem]? {
        if (szAuthToken ?? "").isEmpty {
            return nil
        }
        
        let totSvc = MFBWebServiceSvc_TotalsForUserWithQuery()
        totSvc.szAuthToken = szAuthToken
        totSvc.fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        
        var result : [MFBWebServiceSvc_TotalsItem] = []
        
        getSoapCall { body in
            if let resp = body as? MFBWebServiceSvc_TotalsForUserWithQueryResponse {
                result = resp.totalsForUserWithQueryResult.totalsItem as? [MFBWebServiceSvc_TotalsItem] ?? []
            }
        }.makeCallAsync { b, sc in
            b.totalsForUserWithQueryAsync(usingParameters: totSvc, delegate: sc)
        }
        
        group.wait()
        return MFBWebServiceSvc_TotalsItem.toSimpleItems(items: result, fHHMM: UserPreferences.current.HHMMPref)
    }
    
    public func recents(forUserSynchronous szAuthToken : String?) -> [SimpleLogbookEntry]? {
        if (szAuthToken ?? "").isEmpty {
            return nil
        }
        
        let recSvc = MFBWebServiceSvc_FlightsWithQueryAndOffset()
        recSvc.szAuthUserToken = szAuthToken
        recSvc.fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        recSvc.offset = NSNumber(integerLiteral: 0)
        recSvc.maxCount = NSNumber(integerLiteral: 10)
        
        var result : [MFBWebServiceSvc_LogbookEntry] = []
        
        getSoapCall { body in
            if let resp = body as? MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse {
                result = resp.flightsWithQueryAndOffsetResult.logbookEntry as? [MFBWebServiceSvc_LogbookEntry] ?? []
            }
        }.makeCallAsync { b, sc in
            b.flightsWithQueryAndOffsetAsync(usingParameters: recSvc, delegate: sc)
        }
        
        group.wait()
        return MFBWebServiceSvc_LogbookEntry.toSimpleItems(items: result, fHHMM: UserPreferences.current.HHMMPref)
    }
}
