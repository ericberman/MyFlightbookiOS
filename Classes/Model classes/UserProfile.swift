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
//  UserProfile.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/25/23.
//

import Foundation

@objc public class MFBProfile : NSObject, MFBSoapCallDelegate {
    @objc public var UserName = ""
    @objc public var Password = ""
    @objc public var AuthToken = ""
    @objc public var ErrorString = ""
    public var authStatus = MFBWebServiceSvc_AuthStatus_none

    private let _szPrefsPath = "MyFlightbookDataPrefs"
    private let _szKeyUser = "UserKey"
    private let _szKeyPass = "PassKey"
    private let _szKeyAuth = "AuthKey"
    private let _szKeyPrefEmail = "keyEmail"
    private let _szKeyPrefPass = "keyPass"

    private let _szKeyCachedToken = "keyCacheAuthToken"
    private let _szKeyCachedUser = "keyCacheAuthUser"
    private let _szKeyCachedTokenRetrievalDate = "keyCacheTokenDate"
    
    private static var _shared : MFBProfile = MFBProfile()
    
    private static let CONTEXT_CREATE_USER = 10238473
    private static let CONTEXT_GET_AUTHTOKEN = 8374736
    
    @objc public static var sharedProfile : MFBProfile {
        get {
            return _shared
        }
    }
        
    override private init() {
        let ud = UserDefaults.standard
        UserName = ud.string(forKey: _szKeyPrefEmail) ?? ""
        Password = ud.string(forKey: _szKeyPrefPass) ?? ""
        AuthToken = ud.string(forKey: _szKeyCachedToken) ?? ""
        super.init()
    }
    
    @objc public func SavePrefs() -> Void {
        let ud = UserDefaults.standard
        ud.set(UserName, forKey: _szKeyPrefEmail)
        ud.set(Password, forKey: _szKeyPrefPass)
    }
    
    private func cacheAuthCreds() {
        let ud = UserDefaults.standard
        ud.set(AuthToken, forKey: _szKeyCachedToken)
        ud.set(UserName, forKey: _szKeyCachedUser)
        ud.set(Date().timeIntervalSince1970, forKey: _szKeyCachedTokenRetrievalDate)
        
        // And save the ultimately used creds
        self.SavePrefs()
        ud.synchronize()
        
        // Save a copy where the affiliated apps can get it.
        UserDefaults(suiteName: "group.com.myflightbook.mfbapps")?.set(AuthToken, forKey: _szKeyCachedToken)
    }
    
    @objc public func clearCache() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: _szKeyCachedUser)
        ud.removeObject(forKey: _szKeyCachedToken)
        
        UserDefaults(suiteName: "group.com.myflightbook.mfbapps")?.removeObject(forKey: _szKeyCachedToken)
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
    }
    
    @objc public func clearOldUserContent() {
        let ac = Aircraft.sharedAircraft
        ac.invalidateCachedAircraft()
        ac.DefaultAircraftID = -1
        MFBAppDelegate.threadSafeAppDelegate.invalidateAll()
    }
    
    @objc public func cacheStatus() -> CacheStatus {
        let ud = UserDefaults.standard
        // initialize from the cache, if necessary...
        if (AuthToken.isEmpty) {
            AuthToken = ud.string(forKey: _szKeyCachedToken) ?? ""
        }
        
        // invalid cache if we have no username/password, no valid authtoken already, or this is for a different user
        let szUserCached = ud.string(forKey: _szKeyCachedUser)
        if (UserName.isEmpty ||
            Password.isEmpty ||
            !self.isValid() ||
            szUserCached != UserName) {
            return .invalid
        }
         
        let timestampAuthCache = ud.double(forKey: _szKeyCachedTokenRetrievalDate) as TimeInterval
        let timeSinceLastAuth = Date().timeIntervalSince1970 - timestampAuthCache
        
        // credentials are valid if
        // (a) we have a cached auth token,
        // (b) it is still valid.
        if (!AuthToken.isEmpty && timeSinceLastAuth < Double(MFBConstants.CACHE_LIFETIME)) {
            return (timeSinceLastAuth < Double(MFBConstants.CACHE_REFRESH) || !MFBNetworkManager.shared.isOnLine) ? .valid : .validButRefresh
        }
        
        return .invalid;

    }
    
    @discardableResult @objc public func RefreshAuthToken() -> Bool {
        let cacheStat = cacheStatus()
        
        if (cacheStat == .valid) {    // nothing to do
            return true
        }
            
        // Cache is either invalid or valid but want to refresh.  Either way, we'll try a refresh, but only if we can do so
        if (UserName.isEmpty || Password.isEmpty || AuthToken.isEmpty || !MFBNetworkManager.shared.isOnLine) {
            return false
        }
        
        NSLog("RefreshAuthToken - cache isn't valid but we have information required to refresh, so refreshing")

        let refreshSvc = MFBWebServiceSvc_RefreshAuthToken()
        refreshSvc.szAppToken = _szKeyAppToken
        refreshSvc.szUser = UserName
        refreshSvc.szPass = Password
        refreshSvc.szPreviousToken = AuthToken
        
        let sc = MFBSoapCall()
        sc.delegate = self
        sc.timeOut = 10.0   // 10 second timeout
        
        // Make async call - result will be cached asynchronously, so we can simply return.
        sc.makeCallAsyncSecure { b, sc in
            b.refreshAuthTokenAsync(usingParameters: refreshSvc, delegate: sc)
        }
        
        return true
    }
    
    public func GetAuthToken(sz2FACode : String, onCompletion : ((MFBSoapCall)->Void)?) -> Bool {
        NSLog("GetAuthToken")
        ErrorString = ""
        
        if (UserName.isEmpty) {
            ErrorString = String(localized: "Please provide an email address.", comment: "Create Account validation - no email")
            return false
        }
        if (Password.isEmpty) {
            ErrorString = String(localized: "Please provide a password.", comment: "Validation - Missing Password")
            return false
        }
        
        let ud = UserDefaults.standard
        let szUserCached = ud.string(forKey: _szKeyCachedUser)
        
        // clear the cache if requesting for a different user
        if (szUserCached != nil && szUserCached != UserName) {
            NSLog("Cached credentials being cleared because of new username")
            clearCache()
        }
        let authTokSvc = MFBWebServiceSvc_AuthTokenForUserNew()
        authTokSvc.szAppToken = _szKeyAppToken
        authTokSvc.szUser = UserName
        authTokSvc.szPass = Password
        authTokSvc.sz2FactorAuth = sz2FACode
        
        let sc = MFBSoapCall()
        sc.delegate = self
        sc.timeOut = 10.0
        
        sc.contextFlag = MFBProfile.CONTEXT_GET_AUTHTOKEN
        sc.additionalContext["at"] = authTokSvc
        sc.additionalContext["cachedUser"] = szUserCached
        sc.onCompletion = onCompletion
        
        sc.makeCallAsync { b, sc in
            b.authTokenForUserNewAsync(usingParameters: authTokSvc, delegate: sc)
        }

        return true
    }
    
    public func createUser(cu : MFBWebServiceSvc_CreateUser, onCompletion : ((MFBSoapCall)->Void)?) -> Bool {
        NSLog("CreateUser");
        if (cu.szEmail.isEmpty) {
            ErrorString = String(localized: "Please provide an email address.", comment: "Create Account validation - no email")
            return false
        }
        if (cu.szPass.isEmpty) {
            ErrorString = String(localized: "Please provide a password.", comment: "Validation - Missing Password")
            return false
        }
        if (cu.szPass.count < 6) {
            ErrorString = String(localized: "Password must be at least 6 characters long.", comment: "Create Account validation - password too short")
            return false
        }
        if (cu.szQuestion.isEmpty) {
            ErrorString = String(localized: "Please provide a password question.", comment: "Create Account validation - no password question")
            return false
        }
        if (cu.szAnswer.isEmpty) {
            ErrorString = String(localized: "Please provide an answer to the password question.", comment: "Create Account validation - no secret answer")
            return false;
        }
        
        let sc = MFBSoapCall(delegate: self)
        sc.timeOut = 10.0
        sc.contextFlag = MFBProfile.CONTEXT_CREATE_USER
        
        cu.szAppToken = _szKeyAppToken
        sc.onCompletion = onCompletion
        sc.additionalContext["cu"] = cu
        
        sc.makeCallAsync { b, sc in
            b.createUserAsync(usingParameters: cu, delegate: sc)
        }
        return true
    }
    
    @objc(BodyReturned:) public func BodyReturned(body: AnyObject) {
        if let tokresp = body as? MFBWebServiceSvc_AuthTokenForUserNewResponse {
            authStatus = tokresp.authTokenForUserNewResult.result
            if (authStatus == MFBWebServiceSvc_AuthStatus_Success) {
                AuthToken = tokresp.authTokenForUserNewResult.authToken
                if (!AuthToken.isEmpty) {
                    ErrorString = ""
                }
            }
        } else if let curesp = body as? MFBWebServiceSvc_CreateUserResponse {
            AuthToken = curesp.createUserResult.szAuthToken
        } else if let raresp = body as? MFBWebServiceSvc_RefreshAuthTokenResponse {
            let szAuth = raresp.refreshAuthTokenResult ?? ""
            if (!szAuth.isEmpty) {
                AuthToken = szAuth
                cacheAuthCreds()
            }
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        ErrorString = sc.errorString
        
        if sc.contextFlag == MFBProfile.CONTEXT_CREATE_USER && ErrorString.isEmpty && !AuthToken.isEmpty {
            NSLog("Account successfully created")
            // Now, sign in
            if let cu = sc.additionalContext["cu"] as? MFBWebServiceSvc_CreateUser {
                UserName = cu.szEmail
                Password = cu.szPass
            }
            cacheAuthCreds()
            clearOldUserContent()
        } else if sc.contextFlag == MFBProfile.CONTEXT_GET_AUTHTOKEN  && ErrorString.isEmpty && !AuthToken.isEmpty && authStatus == MFBWebServiceSvc_AuthStatus_Success {
                NSLog("Authtoken successfully retrieved - updating cache");
                cacheAuthCreds()
            if let szUserCached = sc.additionalContext["cachedUser"] as? String {
                if szUserCached != UserName { // signed in as someone new
                    clearOldUserContent()
                }
            }
            else if AuthToken.isEmpty && ErrorString.isEmpty {  // if we didn't get any actual error, but didn't get an auth string, that's also an error
                ErrorString = String(localized: "Unable to authenticate.  Please check your email address and password and ensure that you have Internet access", comment: "Error - authentication failure")
                sc.errorString = ErrorString    // in case we added an error
            }
        }

        sc.onCompletion?(sc)
    }
    
    @objc public func isValid() -> Bool {
        return !AuthToken.isEmpty
    }
    
    @objc(authRedirForUser:) public func authRedirForUser(params : String) -> String {
        var components = URLComponents()
        components.scheme = "https"
        components.host = MFBHOSTNAME
        components.path = "/logbook/mvc/auth/authredir"
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "u", value: UserName))
        queryItems.append(URLQueryItem(name: "p", value: Password))
        components.queryItems = queryItems
        return "\(components.string!)&\(params)"
    }
}

public class NewUserObject : MFBWebServiceSvc_CreateUser {
    public var szEmail2 = ""
    public var szPass2 = ""
    public var szLastError = ""
    
    private func initSuperVars() {
        // below are all initialized to nil in super.init, so set them to empty strings now
        szAppToken = ""
        szEmail = ""
        szPass = ""
        szFirst = ""
        szLast = ""
        szQuestion = ""
        szAnswer = ""
    }
    
    @objc public override init() {
        super.init()
        initSuperVars()
    }
    
    @objc public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSuperVars()
    }
    
    public func isValid() -> Bool {
        szLastError = ""
        
        if (szPass.isEmpty || szPass != szPass2) {
            szLastError = String(localized: "Please enter your password twice.", comment:"Create Account validation - passwords don't match")
        } else if (szEmail2.isEmpty || szEmail2 != szEmail) {
            szLastError = String(localized: "Please enter your email address twice.", comment: "Create Account validation - emails don't match")
        }
        return szLastError.isEmpty
    }
}
