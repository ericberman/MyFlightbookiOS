/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2014-2023 MyFlightbook, LLC
 
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
//  Training.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public class Training : UITableViewController {
    enum _trainingLinks : Int, CaseIterable {
        case instructors = 0
        case students
        case reqSignatures
        case endorsements
        case form8710
        case modelRollup
        case timeRollup
        case achievements
        case milestoneProgress
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: true)
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    func canViewTraining() -> Bool {
        return MFBNetworkManager.shared.isOnLine && MFBProfile.sharedProfile.isValid()
    }
    
    // MARK: Table view data source
    @objc public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _trainingLinks.allCases.count
    }
    
    @objc public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "TrainingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        
        var config = cell.defaultContentConfiguration()
        
        cell.accessoryType = .disclosureIndicator
        
        let cid = _trainingLinks(rawValue: indexPath.row)!  // we want to crash if this fails!
        switch cid {
        case .endorsements:
            config.text = String(localized: "Endorsements", comment: "Prompt to view/edit endorsements")
        case .achievements:
            config.text = String(localized: "Achievements", comment: "Prompt to view achievements")
        case .milestoneProgress:
            config.text = String(localized: "Ratings Progress", comment: "Prompt to view Ratings Progress")
        case .students:
            config.text = String(localized: "Students", comment: "Prompt for students")
        case .instructors:
            config.text = String(localized: "Instructors", comment: "Prompt for Instructors")
        case .reqSignatures:
            config.text = String(localized: "ReqSignatures", comment: "Prompt for Requesting Signatures")
        case .form8710:
            config.text = String(localized: "8710Form", comment: "Prompt for 8710 form")
        case .modelRollup:
            config.text = String(localized: "ModelRollup", comment: "Prompt for Model Rollup")
        case .timeRollup:
            config.text = String(localized: "TimeRollup", comment: "Prompt for Time Rollup")
        }
        
        if !canViewTraining() {
            config.textProperties.color = .tertiaryLabel
        }

        MFBTheme.addThemedImageToCellConfig(name: "training.png", config: &config)
        
        cell.contentConfiguration = config

        return cell
    }
    
    // MARK: Table view delegate
    func pushAuthURL(_ szDest : String) {
        if !canViewTraining() {
            showErrorAlertWithMessage(msg: String(localized: "TrainingNotAvailable", comment: "Error message for training if offline or not signed in"))
        } else {
            let szURL = MFBProfile.sharedProfile.authRedirForUser(params: "d=\(szDest)&naked=1")
            let vwWeb = HostedWebViewController(url: szURL)
            navigationController?.pushViewController(vwWeb, animated: true)
        }
    }
    
    // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cid = _trainingLinks(rawValue: indexPath.row)!
        switch (cid)
        {
        case .endorsements:
            pushAuthURL("endorse")
        case .achievements:
            pushAuthURL("badges")
        case .milestoneProgress:
            pushAuthURL("progress")
        case .instructors:
            pushAuthURL("instructorsFixed")
        case .reqSignatures:
            pushAuthURL("reqSigs")
        case .students:
            pushAuthURL("studentsFixed")
        case .form8710:
            pushAuthURL("8710")
        case .timeRollup:
            pushAuthURL("TimeRollup")
        case .modelRollup:
            pushAuthURL("ModelRollup")
        }
    }
}
