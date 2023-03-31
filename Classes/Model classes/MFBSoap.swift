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
//  MFBSoap.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

import Foundation

@objc public protocol MFBSoapCallDelegate {
    @objc(BodyReturned:) func BodyReturned(body : AnyObject) -> Void
    @objc(HeaderReturned:) optional func HeaderReturned(header : AnyObject) -> Void
    @objc(ResultCompleted:) optional func ResultCompleted(sc : MFBSoapCall) -> Void
}

@objc public class MFBSoapCall : NSObject, MFBWebServiceSoapBindingResponseDelegate {
    @objc var delegate : MFBSoapCallDelegate?
    @objc var logCallData : Bool
    @objc var errorString : String
    @objc var timeOut : TimeInterval
    @objc var contextFlag : Int

    @objc public override init() {
        logCallData = false
        errorString = ""
        delegate = nil
        timeOut = 0
        contextFlag = 0
        super.init()
    }
    
    public convenience init(delegate d : MFBSoapCallDelegate) {
        self.init()
        delegate = d
    }
    
    // MARK: Hack retain/release for async calls
    // the wsdl2objc code treats the delegate as ASSIGN not RETAIN (to avoid cycles?) so we are not retained while the async operaiton completes.
    // We hack retain ourselves by adding to a static array for the duration of the call
    static var _rgHackRetain : [NSObject] = []
    
    public static func hackARCRetain(sc : MFBSoapCall) {
        _rgHackRetain.append(sc)
    }
    
    public static func hackARCRelease(sc : MFBSoapCall) {
        _rgHackRetain.removeAll { o in
            o == sc
        }
    }
    
    // MARK: Actual functionality
    func setUpBinding(fSecure : Bool) -> MFBWebServiceSoapBinding? {
        var secure = fSecure
        if (!MFBNetworkManager.shared.isOnLine) {
            self.errorString = String(localized: "No access to the Internet", comment: "Error message if app cannot connect to the Internet")
            return nil;
        }
        
        let binding = MFBWebServiceSoapBinding()
        if (timeOut != 0) {
            binding.timeout = self.timeOut
        }
        binding.timeout = (binding.timeout < 30) ? 30 : binding.timeout // at least 30 seconds for a timeout
        let szPreferredLocale = Locale.current.identifier
        let szPreferredLanguage = Locale.preferredLanguages[0]
        let rgElem = szPreferredLocale.components(separatedBy: "_")
        if (rgElem.count >= 2) {
            let szAcceptsHeader = "\(szPreferredLanguage)-\(rgElem[1])"
            binding.customHeaders.setValue(szAcceptsHeader, forKey: "Accept-Language")
        }
        secure = true
        
        #if DEBUG
        binding.logXMLInOut = logCallData
        #endif
        if (MFBHOSTNAME.hasPrefix("192.") || MFBHOSTNAME.hasPrefix("10.") || MFBHOSTNAME.hasPrefix("BERMAN")) {
            secure = false
        }
            
        let testAddress = URL(string: "http\(secure ? "s" : "")://\(MFBHOSTNAME)/logbook/public/WebService.asmx")
        binding.address = testAddress
        return binding
    }
    
    func parseResponse(response : MFBWebServiceSoapBindingResponse?) -> Bool {
        var retVal = true
        
        if (response?.error?.localizedDescription.isEmpty ?? false) {
            retVal = false
            errorString = response?.error.localizedDescription ?? ""
            NSLog("MFBSoapCall.m - MakeCall - Error: %@", self.errorString);
        }
        
        let responseHeaders = response?.headers
        let responseBodyParts = response?.bodyParts
        
        for header in responseHeaders ?? [] {
            delegate?.HeaderReturned?(header: header as! MFBSoapCallDelegate)
        }
        
        for id in responseBodyParts ?? [] {
            if let part = id as? SOAPFault {
                // strip off the preamble, if present, which is: "Server was unable to process request. ---->"
                if let r = try? NSRegularExpression(pattern: ".*-->") {
                    errorString = r.stringByReplacingMatches(in: part.faultstring, range: NSRange(location: 0, length:  part.faultstring.count), withTemplate: "")
                } else {
                    errorString = part.faultstring
                }
            }
            else {
                self.delegate?.BodyReturned(body: id as AnyObject)
            }
        }
        return retVal
    }
    
    @discardableResult func makeCallAsync(callToMake:@escaping (MFBWebServiceSoapBinding, MFBSoapCall)->Void, asSecure fSecure: Bool) -> Bool {
        var retVal:Bool = true

        let binding = setUpBinding(fSecure: fSecure)
        if binding != nil
        {
             // need to make sure that we're still around to be the delegate when the call completes
            MFBSoapCall.hackARCRetain(sc: self)

            // We do this on a background thread because even though the call is async, it can hit a semaphore.
            DispatchQueue.global(qos:.background).async() {
                callToMake(binding!, self)
            }
        }
        else
            {retVal = false}

        return retVal
    }
    
    @discardableResult @objc(makeCallAsync:) public func makeCallAsync(callToMake : @escaping (MFBWebServiceSoapBinding, MFBSoapCall) -> Void) -> Bool {
        return makeCallAsync(callToMake: callToMake, asSecure: false)
    }
    
    @discardableResult @objc(makeCallAsyncSecure:) public func makeCallAsyncSecure(calltoMake : @escaping (MFBWebServiceSoapBinding, MFBSoapCall) -> Void) -> Bool {
        return makeCallAsync(callToMake: calltoMake, asSecure: true)
    }
    
    // Call only on background threads.
    @discardableResult @objc(makeCallSynchronous: asSecure:) public func makeCallSynchronous(calltoMake : (MFBWebServiceSoapBinding) -> MFBWebServiceSoapBindingResponse, asSecure : Bool) -> Bool {
        var retVal = true
        assert(!Thread.isMainThread, "NEVER call makeCallSynchronous on the main thread!")
        let binding = setUpBinding(fSecure: setUpBinding(fSecure: asSecure) != nil)
        if (binding != nil) {
            let response = calltoMake(binding!)
            retVal = parseResponse(response: response)
        }
        else {
            retVal = false
        }
        return retVal
    }
    
    public func operation(_ operation: MFBWebServiceSoapBindingOperation!, completedWith response: MFBWebServiceSoapBindingResponse!) {
        // always call this on the main thread
        DispatchQueue.main.async {
            let _ = self.parseResponse(response: response)
            self.delegate?.ResultCompleted?(sc: self)
            MFBSoapCall.hackARCRelease(sc: self)
        }
    }

    // Inside a soap call, dates get converted to XML using their UTC equivalent.
    // If we're dealing with a date in local form, we want to preserve that without regard
    // to time zone.  E.g., if it is 10pm on March 3 in Seattle, that's 5am March 4 UTC, but
    // we will want the date to pass as March 3.  So we must provide a UTC version of the date that will survive
    // this process with the correct day/month/year.
    // Due to daylight savings time issues, we do this by decomposing the local date into its constituent
    // month/day/year.  THEN set the timezone to create a new UTC date that looks like that date/time
    // we can then restore the timezone and return that date.  Note that we will do one timezone switch for each
    // date that is reconfigured, and will
    @objc(UTCDateFromLocalDate:) public static func UTCDateFromLocalDate(dt : Date) -> Date {
        return (dt as NSDate).UTCDateFromLocalDate()
    }

    // Reverse of UTCDateFromLocalDate.
    // Given a UTC date, produces a local date that looks the same.  E.g., if it is
    // 8/25/2012 02:00 UTC, that is 8/24/2012 19:00 PDT.  We want this date to look
    // like 8/25, though.
    @objc(LocalDateFromUTCDate:) public static func LocalDateFromUTCDate(dt : Date) -> Date {
        return (dt as NSDate).LocalDateFromUTCDate()
    }
}
