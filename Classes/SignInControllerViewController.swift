/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2013-2025 MyFlightbook, LLC
 
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
//  SignInControllerViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/9/23.
//

import Foundation

public class SignInControllerViewController : CollapsibleTableSw, UITextFieldDelegate {
    private var szUser = MFBProfile.sharedProfile.UserName
    private var szPass = MFBProfile.sharedProfile.Password
    private var sz2fa = ""
    private var vwAccessory : AccessoryBar!
    
    enum profSection : Int, CaseIterable {
        case sectWhySignIn = 0, sectCredentials, sectSignIn, sectCreateAccount, sectForgotPW, sectLinks, sectAbout, sectPackAndGo
    }
    
    enum profRow : Int, CaseIterable {
        case rowWhySignIn = 0, rowEmail, rowPass, rowSignInOut, rowForgotPW, rowCreateAcct, rowFAQ, rowContact, rowSupport, /* rowFollowTwitter, */ rowFollowFB, rowOptions, rowAbout, rowPackAndGo
    }
    
    private let rowLinksFirst = profRow.rowFAQ.rawValue
    private let rowLinksLast = profRow.rowFollowFB.rawValue
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        defSectionFooterHeight = 5.0
        defSectionHeaderHeight = 18.0
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        // reload user/pass, in case they've changed
        szUser = MFBProfile.sharedProfile.UserName
        szPass = MFBProfile.sharedProfile.Password
        tableView.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Signing In
    func showError(_ msg : String) {
        showErrorAlertWithMessage(msg: msg)
        tableView.reloadData()
    }
    
    func get2FA() {
        let alert = UIAlertController(title: String(localized: "2FATitle", comment: "2fa Title"),
                                      message:String(localized: "2FAPrompt", comment: "2fa Prompt"),
                                      preferredStyle:.alert)
        alert.addTextField() { (textField) in
            textField.placeholder = String(localized: "2FAWatermark", comment: "2fa Watermark")
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style:.cancel) { uaa in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style:.default) { uaa in
            self.sz2fa = alert.textFields?[0].text ?? ""
            self.navigationController?.popViewController(animated: true)
            self.updateProfile()
        })
        present(alert, animated: true)
    }
    
    @objc func updateProfile() {
        tableView.endEditing(true)
        
        MFBProfile.sharedProfile.UserName = szUser
        MFBProfile.sharedProfile.Password = szPass
        MFBProfile.sharedProfile.AuthToken = ""
        
        MFBProfile.sharedProfile.clearCache()
        
        if MFBProfile.sharedProfile.GetAuthToken(sz2FACode: sz2fa, onCompletion: { sc in
            // if successful, refresh flight properties.
            let result = MFBProfile.sharedProfile.authStatus
            if result == MFBWebServiceSvc_AuthStatus_Success {
                let fp = FlightProps()
                fp.setCacheRetry()
                fp.loadCustomPropertyTypes()
            }
            
            self.dismiss(animated: true) {
                if (result == MFBWebServiceSvc_AuthStatus_Success) {
                    let app = MFBAppDelegate.threadSafeAppDelegate
                    self.sz2fa = ""
                    
                    app.ensureWarningShownForUser()
                    MFBProfile.sharedProfile.SavePrefs()
                    self.tableView.reloadData()
                    
                    Aircraft.sharedAircraft.refreshIfNeeded()
                    app.getActiveSceneDelegate()?.DefaultPage()
                } else if (result == MFBWebServiceSvc_AuthStatus_TwoFactorCodeRequired) {
                    self.get2FA()
                } else {
                    self.showError(MFBProfile.sharedProfile.ErrorString)
                }
            }
        }) {
            // successfully started the sign-in, so show progress...
            WPSAlertController.presentProgressAlertWithTitle(String(localized: "Signing in...", comment: "Progress: Signing In"), onViewController:self)
        } else {
            showError(MFBProfile.sharedProfile.ErrorString)
        }
    }
    
    @objc func signOut(_ sender : AnyObject) {
        let sp = MFBProfile.sharedProfile
        sp.UserName = ""
        sp.Password = ""
        sp.AuthToken = ""
        szPass = ""
        szUser = ""
        sp.clearCache()
        sp.clearOldUserContent()
        sp.SavePrefs()
        FlightProps.clearTemplates()
        FlightProps.saveTemplates()
        FlightProps.clearAllLocked()
        PackAndGo.clearPackedData()
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    func cellIDFromIndexPath(_ ip : IndexPath) -> profRow {
        switch profSection(rawValue: ip.section) {
        case .sectWhySignIn:
            return profRow.rowWhySignIn
        case .sectCredentials:
            return profRow(rawValue: profRow.rowEmail.rawValue + ip.row)!
        case .sectSignIn:
            return profRow.rowSignInOut
        case .sectForgotPW:
            return profRow.rowForgotPW
        case .sectCreateAccount:
            return profRow.rowCreateAcct
        case .sectLinks:
            return profRow(rawValue: rowLinksFirst + ip.row)!
        case .sectAbout:
            return profRow(rawValue: profRow.rowOptions.rawValue + ip.row)!
        case .sectPackAndGo:
            return profRow.rowPackAndGo
        case .none:
            fatalError("invalid index path in sign-in controller row = \(ip.row), section=\(ip.section)")
        }
    }
    
    func getCell(_ text : String = "", detail text2 : String = "", img : UIImage? = nil) -> UITableViewCell {
        let CellIdentifier = "CellNormal"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
        var config = cell.defaultContentConfiguration()
        config.text = text
        config.secondaryText = text2
        config.image = img
        config.textProperties.font = UIFont.systemFont(ofSize: config.textProperties.font.pointSize)
        config.textProperties.adjustsFontSizeToFitWidth = true
        cell.contentConfiguration = config
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sect = profSection(rawValue: section)!
        if sect == .sectCredentials {
            return MFBProfile.sharedProfile.isValid() ? String(format:String(localized: "You are signed in.", comment: "Prompt if you are signed in."), MFBProfile.sharedProfile.UserName) :
            String(localized: "You are not signed in.  Please sign in or create an account.", comment: "Prompt if you are not signed in.")
        } else if sect == .sectPackAndGo && MFBProfile.sharedProfile.isValid() {
            return String(localized: "PackAndGoDesc", comment: "Pack and go description")
        }
        
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sect = profSection(rawValue: section)!
        if sect == .sectPackAndGo && MFBProfile.sharedProfile.isValid() {
            let dtPacked = PackAndGo.lastPackDate
            if dtPacked == nil {
                return String(localized: "PackAndGoStatusNone", comment: "Pack and go not packed")
            } else {
                let df = DateFormatter()
                df.dateStyle = .short
                df.timeStyle = .long
                return String(format:String(localized: "PackAndGoStatusOK", comment: "Pack and go status OK"), df.string(from: dtPacked!))
            }
        }
        return nil
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return profSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch profSection(rawValue: section) {
        case .sectWhySignIn:
            return MFBProfile.sharedProfile.isValid() ? 0 : 1 // just the explanation text
        case .sectCredentials:
            return MFBProfile.sharedProfile.isValid() ? 0 : 2 // email + password
        case .sectSignIn:
            return 1
        case .sectForgotPW:
            return 1 // just the "Forgot password" cell
        case .sectPackAndGo:
            return MFBProfile.sharedProfile.isValid() ? 1 : 0
        case .sectCreateAccount:
            return MFBProfile.sharedProfile.isValid() ? 0 : 1 // just the "Create account" cell, but only if not signed in
        case .sectLinks:
            return rowLinksLast - rowLinksFirst + 1
        case .sectAbout:
            return 2 // About cell + options
        case .none:
            fatalError("Invalid section \(section) in sign-in controller")
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = cellIDFromIndexPath(indexPath)
        
        switch row {
        case .rowWhySignIn:
            let tc = TextCell.getTextCellTransparent(tableView)
            tc.txt.text = String(localized: "Sign-in Header", comment: "Prompt for signing in")
            return tc
        case .rowAbout:
            return getCell(String(localized: "About MyFlightbook", comment: "About MyFlightbook prompt"))
        case .rowForgotPW:
            return getCell(String(localized: "Reset Password", comment: "Reset Password Prompt"))
        case .rowSignInOut:
            let cell = ButtonCell.getButtonCell(tableView)
            if MFBProfile.sharedProfile.isValid() {
                cell.btn.setTitle(String(localized: "Sign-out", comment: "Sign-out"), for:[])
                cell.btn.addTarget(self, action: #selector(signOut), for: .touchUpInside)
            } else {
                cell.btn.setTitle(String(localized: "Sign-in", comment: "Sign-in"), for:[])
                cell.btn.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
            }
            return cell
        case .rowEmail, .rowPass:
            let ec = EditCell.getEditCell(tableView, withAccessory:vwAccessory)
            ec.txt.delegate = self
            ec.txt.keyboardType = (row == .rowEmail) ? .emailAddress : .default
            ec.txt.isSecureTextEntry = (row == .rowPass)
            ec.txt.autocorrectionType = .no
            ec.txt.text = (row == .rowEmail) ? self.szUser : self.szPass
            ec.lbl.text = (row == .rowEmail) ? String(localized: "E-mail", comment: "E-mail prompt") : String(localized: "Password", comment: "PasswordPrmopt")
            ec.txt.placeholder = (row == .rowEmail) ? String(localized: "E-Mail Placeholder", comment: "E-Mail Placeholder") : String(localized: "Password Placeholder", comment: "Password Placeholder")
            ec.txt.returnKeyType = (row == .rowEmail) ? .next : .go
            return ec
        case .rowCreateAcct:
            return getCell(String(localized: "Create a free Account", comment: "Create an account prompt"))
        case .rowFAQ:
            return getCell(String(localized: "FAQ", comment: "FAQ prompt"), img: UIImage(named: "MFBLogo"))
        case .rowFollowFB:
            return getCell(String(localized: "Follow on Facebook", comment: "Prompt to follow on Facebook"), img: UIImage(named: "f_logo"))
            /*
        case .rowFollowTwitter:
            return getCell(String(localized: "Follow on Twitter", comment: "Prompt to follow on Twitter"), img: UIImage(named: "twitter"))
             */
        case .rowSupport:
            let cell = getCell(String(localized: "SupportPrompt", comment: "Support"), img: UIImage(named: "MFBLogo"))
            var config = cell.contentConfiguration as! UIListContentConfiguration
            config.textProperties.color = MFBProfile.sharedProfile.isValid() ? UIColor.label : UIColor.systemGray
            cell.contentConfiguration = config
            return cell
        case .rowContact:
            return getCell(String(localized: "Contact Us", comment: "Contact Us prompt"), img: UIImage(named: "MFBLogo"))
        case .rowOptions:
            return getCell(String(localized: "Options", comment: "Options button for autodetect, etc."))
        case .rowPackAndGo:
            let cell = getCell(String(localized: "PackAndGo", comment: "Pack and Go"))
            cell.accessoryType = .none
            return cell
        }
    }
    
    // MARK: - Table view delegate
    func pushURL(_ szURL : String) {
        navigationController?.pushViewController(HostedWebViewController(url: szURL), animated: true)
    }
    
    func contactUs() {
        let szSubj = "Comment from \(UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone") user"
        pushURL(MFBProfile.sharedProfile.authRedirForUser(params: "d=CONTACT&subj=\(szSubj.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)&noCap=1&naked=1"))
    }
    
    func followFacebook() {
        UIApplication.shared.open(URL(string: "https://www.facebook.com/pages/MyFlightbook/145794653106")!)
    }
    
    func followTwitter() {
        UIApplication.shared.open(URL(string: "https://www.twitter.com/myflightbook")!)
    }
    
    func showAbout() {
        navigationController?.pushViewController(about(nibName: "about", bundle: nil), animated: true)
    }
    
    func createUser() {
        navigationController?.pushViewController(NewUserTableController(nibName: "NewUserTableController", bundle: nil), animated: true)
    }
    
    func packAndGo() {
        tableView.endEditing(true)

        let uac = WPSAlertController.presentProgressAlertWithTitle(String(localized: "PackAndGoInProgress", comment: "Pack and go - downloaded"), onViewController:self)
        
        let p = PackAndGo()
        p.authToken = MFBProfile.sharedProfile.AuthToken
        
        p.packAll { sz in
            uac.title = sz
        } completionHandler: {
            self.dismiss(animated: true) {
                if !p.errorString.isEmpty {
                    self.showError(p.errorString)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ipActive = indexPath
        let row = cellIDFromIndexPath(indexPath)
        
        switch row {
        case .rowForgotPW:
            tableView.endEditing(true)
            UIApplication.shared.open(URL(string: "http://\(MFBHOSTNAME)/logbook/mvc/auth/resetpass")!)
        case .rowContact:
            tableView.endEditing(true)
            contactUs()
        case .rowFollowFB:
            tableView.endEditing(true)
            followFacebook()
                /*
        case .rowFollowTwitter:
            tableView.endEditing(true)
            followTwitter()
                 */
        case .rowAbout:
            tableView.endEditing(true)
            showAbout()
        case .rowFAQ:
            tableView.endEditing(true)
            pushURL(MFBProfile.sharedProfile.authRedirForUser(params: "d=faq&naked=1"))
        case .rowSupport:
            tableView.endEditing(true)
            
            if MFBProfile.sharedProfile.isValid() {
                UIApplication.shared.open(URL(string: MFBProfile.sharedProfile.authRedirForUser(params: "d=donate"))!)
            }
        case .rowCreateAcct:
            tableView.endEditing(true)
            createUser()
        case .rowEmail, .rowPass:
            (tableView.cellForRow(at: indexPath) as? EditCell)?.txt.becomeFirstResponder()
        case .rowOptions:
            navigationController?.pushViewController(AutodetectOptions(nibName: "AutodetectOptions", bundle: nil), animated: true)
        case .rowPackAndGo:
            packAndGo()
        default:
            tableView.endEditing(true)
        }
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let row = cellIDFromIndexPath(tableView.indexPath(for: owningCell(textField)!)!)
        
        if row == .rowEmail {
            szUser = textField.text ?? ""
        } else if row == .rowPass {
            szPass = textField.text ?? ""
        }
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textField)!)
        enableNextPrev(vwAccessory)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let row = cellIDFromIndexPath(tableView.indexPath(for: owningCell(textField)!)!)
        if row == .rowPass {
            textField.resignFirstResponder()
            updateProfile()
        } else {
            nextClicked()
        }
        return true
    }
    
    // MARK: - AccessoryViewDelegates
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        switch cellIDFromIndexPath(ip) {
        case .rowEmail, .rowPass:
            return true
        default:
            return false
        }
    }
}
