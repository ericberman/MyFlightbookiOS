/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2013-2023 MyFlightbook, LLC
 
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
//  NewUserTableController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/9/23.
//

import Foundation

public class NewUserTableController : CollapsibleTableSw, UITextFieldDelegate {
    private var vwAccessory : AccessoryBar!
    private var nuo : NewUserObject = NewUserObject()
    
    enum sectNewUser : Int, CaseIterable {
        case sectCredentials = 0, sectName, sectQAExplanation, sectQA, sectLegal, sectCreate
    }
    
    enum rowNewUser : Int, CaseIterable {
        case rowEmail = 0, rowEmail2, rowPass, rowPass2, rowFirstName, rowLastName, rowQAExplanation1, rowQuestion, rowAnswer,
             rowPrivacy, rowTandC, rowAgree, rowCreate
    }
    
    // MARK: View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        navigationItem.title = String(localized: "Create Account", comment: "Title for create account screen")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    func rowFromIndexPath(_ ip : IndexPath) -> rowNewUser {
        switch sectNewUser(rawValue: ip.section) {
        case .sectCreate:
            return rowNewUser(rawValue: rowNewUser.rowAgree.rawValue + ip.row)!
        case .sectCredentials:
            return rowNewUser(rawValue: rowNewUser.rowEmail.rawValue + ip.row)!
        case .sectLegal:
            return rowNewUser(rawValue: rowNewUser.rowPrivacy.rawValue + ip.row)!
        case .sectName:
            return rowNewUser(rawValue: rowNewUser.rowFirstName.rawValue + ip.row)!
        case .sectQA:
            return rowNewUser(rawValue: rowNewUser.rowQuestion.rawValue + ip.row)!
        case .sectQAExplanation:
            return .rowQAExplanation1
        case .none:
            fatalError("Invalid section for new user: \(ip.section)")
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sectNewUser.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectNewUser(rawValue: section) {
        case .sectCreate:
            return rowNewUser.rowCreate.rawValue - rowNewUser.rowAgree.rawValue + 1
        case .sectCredentials:
            return rowNewUser.rowPass2.rawValue - rowNewUser.rowEmail.rawValue + 1
        case .sectLegal:
            return rowNewUser.rowTandC.rawValue - rowNewUser.rowPrivacy.rawValue + 1
        case .sectName:
            return rowNewUser.rowLastName.rawValue - rowNewUser.rowFirstName.rawValue + 1
        case .sectQA:
            return rowNewUser.rowAnswer.rawValue - rowNewUser.rowQuestion.rawValue + 1
        case .sectQAExplanation:
            return 1
        case .none:
            fatalError("Invalid section for new user: \(section)")
        }
    }
    
    var QARationaleString : String {
        get {
            return String(localized: "For password recovery, please provide a question and answer.", comment: "Question/Answer Rationale 1")
        }
    }
    
    var QARationaleHeight : CGFloat {
        get {
            let h = (QARationaleString as NSString).boundingRect(with: CGSizeMake(tableView.frame.size.width - 20, 10000),
                                                                             options:.usesLineFragmentOrigin,
                                                                             attributes: [.font : UIFont.systemFont(ofSize: 12.0)],
                                                                             context:nil).size.height
            return ceil(h) + 2
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowFromIndexPath(indexPath) == .rowQAExplanation1 ? QARationaleHeight : UITableView.automaticDimension
    }
    
    func getCell(_ tv : UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell"
        return tv.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowFromIndexPath(indexPath)
        
        switch row {
        case .rowAgree:
            let cell = TextCell.getTextCellTransparent(tableView)
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "By creating an account, you are agreeing to the terms and conditions.", comment: "Terms and Conditions agreement")
            cell.contentConfiguration = config
            return cell
        case .rowQuestion:
            let ec = EditCell.getEditCell(tableView, withAccessory: vwAccessory)
            ec.txt.placeholder = String(localized: "Question Placeholder", comment: "Question Placeholder")
            ec.setLabelToFit(String(localized: "Secret Question", comment: "Secret Question Prompt"))
            ec.txt.text = nuo.szQuestion
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            ec.txt.adjustsFontSizeToFitWidth = true
            ec.accessoryType = .detailButton
            return ec
        case .rowAnswer:
            let ec = EditCell.getEditCell(tableView, withAccessory: vwAccessory)
            ec.txt.placeholder = String(localized: "Answer Placeholder", comment: "Answer Placeholder")
            ec.setLabelToFit(String(localized: "Secret Answer", comment: "Secret Answer Prompt"))
            ec.txt.text = nuo.szAnswer
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            ec.txt.adjustsFontSizeToFitWidth = true
            return ec
        case .rowEmail:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.setLabelToFit(String(localized: "E-mail", comment: "E-mail Prompt"))
            ec.txt.placeholder = String(localized: "E-Mail Placeholder", comment: "E-Mail Placeholder")
            ec.txt.text = self.nuo.szEmail
            ec.txt.keyboardType = .emailAddress
            ec.txt.autocorrectionType = .no
            ec.txt.delegate = self
            return ec
        case .rowEmail2:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.setLabelToFit(String(localized: "Confirm E-mail", comment: "Confirm E-mail"))
            ec.txt.placeholder = String(localized: "E-Mail Placeholder", comment: "E-Mail Placeholder")
            ec.txt.text = self.nuo.szEmail2
            ec.txt.keyboardType = .emailAddress
            ec.txt.autocorrectionType = .no
            ec.txt.delegate = self
            return ec
        case .rowPass:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.setLabelToFit(String(localized: "Password", comment: "Password prompt"))
            ec.txt.placeholder = String(localized: "Password Placeholder", comment: "Password Placeholder")
            ec.txt.text = self.nuo.szPass
            ec.txt.isSecureTextEntry = true
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            return ec
        case .rowPass2:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.txt.placeholder = String(localized: "Password Placeholder", comment: "Password Placeholder")
            ec.setLabelToFit(String(localized: "Confirm Password", comment: "Confirm Password prompt"))
            ec.txt.text = self.nuo.szPass2
            ec.txt.isSecureTextEntry = true
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            return ec
        case .rowFirstName:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.lbl.text = String(localized: "First Name", comment: "First Name prompt")
            ec.txt.placeholder = String(localized: "(Optional)", comment: "Optional")
            ec.txt.text = self.nuo.szFirst
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            return ec
        case .rowLastName:
            let ec = EditCell.getEditCell(tableView, withAccessory:self.vwAccessory)
            ec.lbl.text = String(localized: "Last Name", comment: "Last Name prompt")
            ec.txt.text = self.nuo.szLast
            ec.txt.placeholder = String(localized: "(Optional)", comment: "Optional")
            ec.txt.keyboardType = .default
            ec.txt.delegate = self
            return ec
        case .rowCreate:
            let bc = ButtonCell.getButtonCell(tableView)
            bc.btn.setTitle(String(localized: "Create Account", comment: "Create Account button"), for: [])
            bc.btn.addTarget(self, action:#selector(createUser), for:[.touchUpInside])
            return bc
        case .rowPrivacy:
            let cell = getCell(tableView)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "View Privacy Policy", comment: "View Privacy Policy prompt")
            cell.contentConfiguration = config
            return cell
        case .rowTandC:
            let cell = getCell(tableView)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "View Terms and Conditions", comment: "View Terms and Conditions prompt")
            cell.contentConfiguration = config
            return cell
        case .rowQAExplanation1:
            let tc = TextCell.getTextCellTransparent(tableView)
            tc.txt.text = String(localized: "For password recovery, please provide a question and answer.", comment: "Question/Answer Rationale 1")
            tc.txt.numberOfLines = 20
            tc.txt.font = UIFont.systemFont(ofSize: 12.0)
            tc.txt.adjustsFontSizeToFitWidth = false
            return tc
        }
    }
    
    
    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = rowFromIndexPath(indexPath)
        switch row {
        case .rowPrivacy:
            tableView.endEditing(true)
            viewPrivacy()
        case .rowTandC:
            tableView.endEditing(true)
            viewTandC()
        case .rowEmail, .rowEmail2, .rowPass, .rowPass2,.rowFirstName, .rowLastName, .rowQuestion, .rowAnswer:
            (tableView.cellForRow(at: indexPath) as! EditCell).txt.becomeFirstResponder()
        default:
            tableView.endEditing(true)
        }
    }
    
    public override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if rowFromIndexPath(indexPath) == .rowQuestion {
            let sqp = SecurityQuestionPicker()
            sqp.nuo = self.nuo
            navigationController?.pushViewController(sqp, animated: true)
        }
    }
    
    // MARK: - Create User
    @objc func createUser() {
        // Pick up any pending changes
        view.endEditing(true)
        
        if (!nuo.isValid()) {
            showErrorAlertWithMessage(msg: nuo.szLastError)
            return
        }
        
        if MFBProfile.sharedProfile.createUser(cu: nuo, onCompletion: { sc in
            self.dismiss(animated: true) {
                if sc.errorString.isEmpty {
                    // cache the relevant credentials, load any aircraft, and go to the default page for the user!
                    MFBProfile.sharedProfile.SavePrefs()
                    Aircraft.sharedAircraft.refreshIfNeeded()
                    
                    // Refresh properties on a background thread.
                    let fp = FlightProps()
                    fp.setCacheRetry()
                    fp.loadCustomPropertyTypes()
                    
                    let alert = UIAlertController(title: String(localized: "Welcome to MyFlightbook!", comment: "New user welcome message title"),
                                                  message:String(localized: "\r\nBefore you can enter flights, you must set up at least one aircraft that you fly.", comment: "New user 'Next steps' message"), preferredStyle:.alert)
                    
                    alert.addAction(UIAlertAction(title: String(localized: "Close", comment: "Close button on error message"), style:.cancel) { uaa in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                } else {
                    self.showErrorAlertWithMessage(msg: MFBProfile.sharedProfile.ErrorString)
                }
            }
        }) {
            // successfully started create user, show progress.
            WPSAlertController.presentProgressAlertWithTitle(String(localized: "Creating Account...", comment: "Progress indicator"), onViewController:self)
        } else {
            showErrorAlertWithMessage(msg: MFBProfile.sharedProfile.ErrorString)
        }
    }
    
    @objc func viewPrivacy() {
        let vwWeb = HostedWebViewController(url: "https://\(MFBHOSTNAME)/logbook/mvc/pub/privacy?naked=1")
        navigationController?.pushViewController(vwWeb, animated: true)
    }

    @objc func viewTandC() {
        let vwWeb = HostedWebViewController(url: "https://\(MFBHOSTNAME)/logbook/mvc/pub/TandC?naked=1")
        navigationController?.pushViewController(vwWeb, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let c = owningCell(textField)!
        let ip = tableView.indexPath(for: c)
        if (ip == nil) {
            return
        }
        let row = rowFromIndexPath(ip!)
        let sz = textField.text ?? ""
        switch row {
        case .rowEmail:
            self.nuo.szEmail = sz
        case .rowEmail2:
            self.nuo.szEmail2 = sz
        case .rowPass:
            self.nuo.szPass = sz
        case .rowPass2:
            self.nuo.szPass2 = sz
        case .rowFirstName:
            self.nuo.szFirst = sz
        case .rowLastName:
            self.nuo.szLast = sz
        case .rowQuestion:
            self.nuo.szQuestion = sz
        case .rowAnswer:
            self.nuo.szAnswer = sz
        default:
            break;
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
        tableView.endEditing(true)
        return true
    }
    
    // MARK: - AccessoryViewDelegates
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        switch rowFromIndexPath(ip) {
        case .rowEmail, .rowEmail2, .rowPass, .rowPass2, .rowFirstName, .rowLastName, .rowQuestion, .rowAnswer:
            return true
        default:
            return false
        }
    }
}
