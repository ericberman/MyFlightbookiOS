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
//  WidgetSoapCall.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/17/23.
//

import Foundation

public class WidgetSoapCall : NSObject, MFBWebServiceSoapBindingResponseDelegate {
    public var errorString = ""
    
    internal let binding = MFBWebServiceSoapBinding()
    // request the correct language/locale
    private let szPreferredLocale = Locale.current.identifier
    private let szPreferredLanguage = Locale.preferredLanguages[0]
    public var fUseHHMM : Bool = false
    internal var szAuthToken : String?
    
    private let _szKeyCachedToken = "keyCacheAuthToken"
    private let _szKeyHHMM = "keyUseHHMM"
    
    var completionHandler : ((WidgetSoapCall) -> Void)?
    
    public func operation(_ operation: MFBWebServiceSoapBindingOperation!, completedWith response: MFBWebServiceSoapBindingResponse!) {
        if (!(response?.error?.localizedDescription ?? "").isEmpty) {
            errorString = response.error.localizedDescription
        } else {
            let arr = response.bodyParts as! [NSObject]
            for body in arr {
                if let sf = body as? SOAPFault {
                    if let r = try? NSRegularExpression(pattern: ".*-->") {
                        errorString = r.stringByReplacingMatches(in: sf.faultstring, range: NSRange(location: 0, length:  sf.faultstring.count), withTemplate: "")
                    }
                }
                else {
                    errorString = ""
                    dataReceived(data: body)
                }
            }
        }
        completionHandler?(self)
    }

    init(onComplete: ((WidgetSoapCall) -> Void)?) {
        super.init()
        if (binding.timeout < 30) {
            binding.timeout = 30 // at least 30 seconds for a timeout.
        }
        let rgElem = szPreferredLocale.components(separatedBy: "_")

        if (rgElem.count >= 2) {
            let szAcceptsHeader = "\(szPreferredLanguage)-\(rgElem[1])"
            binding.customHeaders.setValue(szAcceptsHeader, forKey: "Accept-Language")
        }
        
        let defs = UserDefaults(suiteName: "group.com.myflightbook.mfbapps");
        szAuthToken = defs?.string(forKey: _szKeyCachedToken)
        fUseHHMM = defs != nil && defs!.bool(forKey: _szKeyHHMM)

        binding.address = URL(string:"https://\(MFBHOSTNAME)/logbook/public/WebService.asmx")
        
        completionHandler = onComplete
    }
    
    func makeCall() {
        // done in subclass
    }
    
    func dataReceived(data : AnyObject) {
        // done in subclass
    }
}

public class CurrencyCall : WidgetSoapCall {
    public var currencyList = [] as [SimpleCurrencyItem]
    
    override func makeCall() {
        let currencyForUserSvc = MFBWebServiceSvc_GetCurrencyForUser()
        currencyForUserSvc.szAuthToken = szAuthToken
        binding.getCurrencyForUserAsync(usingParameters: currencyForUserSvc, delegate: self)
    }
    
    override func dataReceived(data: AnyObject) {
        currencyList = []
        let resp = data as? MFBWebServiceSvc_GetCurrencyForUserResponse
        if let rg = resp?.getCurrencyForUserResult?.currencyStatusItem as? NSMutableArray {
            for o in rg {
                if  let csi = o as? MFBWebServiceSvc_CurrencyStatusItem  {
                    if let sci = SimpleCurrencyItem() {
                        sci.value = csi.value
                        sci.discrepancy = csi.discrepancy
                        sci.state = csi.status
                        sci.attribute = csi.formattedTitle()
                        currencyList.append(sci)
                    }
                }
            }
        }
    }
}

public class TotalsCall : WidgetSoapCall {
    public var totalsList = [] as [SimpleTotalItem]
    
    override func makeCall() {
        let totalsForUser = MFBWebServiceSvc_TotalsForUserWithQuery()
        totalsForUser.szAuthToken = szAuthToken
        totalsForUser.fq = nil
        binding.totalsForUserWithQueryAsync(usingParameters: totalsForUser, delegate: self)
    }
    
    private func valueDisplay(ti : MFBWebServiceSvc_TotalsItem) -> String {
        switch (ti.numericType)
        {
            case MFBWebServiceSvc_NumType_Integer:
                return "\(ti.value.intValue)"
            case MFBWebServiceSvc_NumType_Currency:
                let nsf = NumberFormatter()
                nsf.numberStyle = NumberFormatter.Style.currency
                return nsf.string(from: ti.value)!
            case MFBWebServiceSvc_NumType_Decimal:
               let nsf = NumberFormatter()
               return nsf.string(from: ti.value)!
            case MFBWebServiceSvc_NumType_Time:
            return ti.value.format(asType: 2, inHHMM: fUseHHMM, useGrouping: true);
            default:
                return "\(ti.value.intValue)"
        }
    }
    
    override func dataReceived(data: AnyObject) {
        totalsList = []
        let resp = data as? MFBWebServiceSvc_TotalsForUserWithQueryResponse
        if let rg = resp?.totalsForUserWithQueryResult?.totalsItem as? NSMutableArray {
            for o in rg {
                if let ti = o as? MFBWebServiceSvc_TotalsItem {
                    if let sti = SimpleTotalItem() {
                        // Have to effectively re-implement "toSimpleItem" here because we can't easily pull in util (pulls in too many other things)
                        sti.title = ti.description
                        sti.subDesc = ti.subDescription
                        sti.valueDisplay = valueDisplay(ti: ti)
                        totalsList.append(sti)
                    }
                }
            }
        }
    }
}
