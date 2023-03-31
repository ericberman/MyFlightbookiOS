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

    var returnedBody : AnyObject? = nil
    
    // MARK: MFBSoapDelegate
    @objc func getSoapCall() -> MFBSoapCall {
        let sc = MFBSoapCall()
        sc.delegate = self
        sc.timeOut = 20.0   // 20 second timeout
        return sc
    }
    
    private func resultFromBody() -> AnyObject? {
        if let resp = returnedBody as? MFBWebServiceSvc_GetCurrencyForUserResponse {
            let rgCs = resp.getCurrencyForUserResult.currencyStatusItem as? [MFBWebServiceSvc_CurrencyStatusItem] ?? []
            return MFBWebServiceSvc_CurrencyStatusItem.toSimpleItems(items: rgCs) as AnyObject
        } else if let resp = returnedBody as? MFBWebServiceSvc_TotalsForUserResponse {
            let rgti = resp.totalsForUserResult.totalsItem as? [MFBWebServiceSvc_TotalsItem] ?? []
            return MFBWebServiceSvc_TotalsItem.toSimpleItems(items: rgti, fHHMM: UserPreferences.current.HHMMPref) as AnyObject
        } else if let resp = returnedBody as? MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse {
            let rgle = resp.flightsWithQueryAndOffsetResult.logbookEntry as? [MFBWebServiceSvc_LogbookEntry] ?? []
            return MFBWebServiceSvc_LogbookEntry.toSimpleItems(items: rgle, fHHMM: UserPreferences.current.HHMMPref) as AnyObject
        }
        
        return nil
    }
    
    public func currency(forUserSynchronous szAuthToken : String?) -> [SimpleCurrencyItem]? {
        if (szAuthToken ?? "").isEmpty {
            return nil
        }
        
        let curSvc = MFBWebServiceSvc_GetCurrencyForUser()
        curSvc.szAuthToken = szAuthToken
        
        getSoapCall().makeCallSynchronous(calltoMake: { b in
            return b.getCurrencyForUser(usingParameters: curSvc)
        }, asSecure: true)
        
        return resultFromBody() as? [SimpleCurrencyItem]
    }
    
    public func totals(forUserSynchronous szAuthToken : String?) -> [SimpleTotalItem]? {
        if (szAuthToken ?? "").isEmpty {
            return nil
        }
        
        let totSvc = MFBWebServiceSvc_TotalsForUser()
        totSvc.szAuthToken = szAuthToken
        
        getSoapCall().makeCallSynchronous(calltoMake: { b in
            return b.totalsForUser(usingParameters: totSvc)
        }, asSecure: true)
        
        return resultFromBody() as? [SimpleTotalItem]
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
        
        getSoapCall().makeCallSynchronous(calltoMake: { b in
            return b.flightsWithQueryAndOffset(usingParameters: recSvc)
        }, asSecure: true)
        
        return resultFromBody() as? [SimpleLogbookEntry]
    }
    
    @objc public func BodyReturned(body: AnyObject) {
        returnedBody = body
    }
    
    @objc public func ResultCompleted(sc: MFBSoapCall) {
        
    }
}
