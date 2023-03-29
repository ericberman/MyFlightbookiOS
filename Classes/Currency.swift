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
//  Currency.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/28/23.
//

import Foundation

public class Currency : PullRefreshTableViewControllerSW, MFBSoapCallDelegate {
    private var rgCurrency : [MFBWebServiceSvc_CurrencyStatusItem]? = nil
    private var errorString = ""
    
    private let sectCurrency = 1
    private let sectDisclaimer = 0
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = MFBAppDelegate.threadSafeAppDelegate
        app.registerNotifyDataChanged(self)
        app.registerNotifyResetAll(self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target:self, action:#selector(refresh))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.isToolbarHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if rgCurrency == nil || !fIsValid {
            refresh()
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        rgCurrency = nil
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
    }
    
    // MARK: - Get data
    @objc public override func refresh() {
        NSLog("LoadCurrencyForUser")
        errorString = ""
        let szAuthToken = MFBProfile.sharedProfile.AuthToken
        
        tableView.allowsSelection = true
        if szAuthToken.isEmpty {
            errorString = String(localized: "You must be signed in to view currency", comment: "Must be signed in to view currency")
            showError(errorString, withTitle: String(localized: "Error loading currency", comment: "Title Error message when loading currency"))
        } else if !MFBNetworkManager.shared.isOnLine {
            if let dtLastPack = PackAndGo.lastCurrencyPackDate {
                let df = DateFormatter()
                df.dateStyle = .short;
                rgCurrency = PackAndGo.cachedCurrency
                tableView.reloadData()
                fIsValid = true
                tableView.allowsSelection = false
                showError(String(format: String(localized: "PackAndGoUsingCached", comment: "Pack and go - Using Cached"), df.string(from: dtLastPack as Date)),
                          withTitle: String(localized: "PackAndGoOffline", comment: "Pack and go - Using Cached"))
            } else {
                errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
                showError(errorString, withTitle: String(localized: "Error loading currency", comment: "Title Error message when loading currency"))
            }
        }
        else
        {
            if (callInProgress) {
                return
            }
            
            startCall()

            let currencyForUserSVC = MFBWebServiceSvc_GetCurrencyForUser()
            currencyForUserSVC.szAuthToken = szAuthToken;
            
            let sc = MFBSoapCall()
            sc.delegate = self
            sc.makeCallAsync { b, sc in
                b.getCurrencyForUserAsync(usingParameters: currencyForUserSVC, delegate: sc)
            }
        }
    }
    
    func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_GetCurrencyForUserResponse {
            rgCurrency = resp.getCurrencyForUserResult.currencyStatusItem as? [MFBWebServiceSvc_CurrencyStatusItem]
            if (rgCurrency != nil) {
                PackAndGo.updateCurrency(rgCurrency!)
                fIsValid = true
            }
        }
    }
    
    func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        if !errorString.isEmpty {
            showError(errorString, withTitle: String(localized: "Error loading currency", comment: "Title Error message when loading currency"))
        }
        
        tableView.reloadData()
        
        if isLoading {
            stopLoading()
        }
        endCall()
    }
    
    // MARK: - Tableview data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sectDisclaimer {
            return 1
        } else if section == sectCurrency {
            return callInProgress ? 1 : rgCurrency?.count ?? 0
        }
        return 0
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == sectDisclaimer ? nil :
        ((rgCurrency ?? []).count == 0 ? String(localized: "No currency is available.", comment: "Unable to retrieve flying currency") : nil)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == sectDisclaimer {
            let szID = "Disclaimer"
            let cell = tableView.dequeueReusableCell(withIdentifier: szID) ?? UITableViewCell(style: .value1, reuseIdentifier: szID)
            
            var config = cell.defaultContentConfiguration()
            config.text = String(localized: "Currency Disclaimer", comment: "Currency Disclaimer")
            config.textProperties.font = UIFont.boldSystemFont(ofSize: config.textProperties.font.pointSize)
            cell.contentConfiguration = config

            cell.selectionStyle = .gray
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        if callInProgress {
            return waitCellWithText(String(localized: "Getting Currency...", comment: "Progress indicator for currency"))
        }
        
        // Otherwise, must be a currency item - rgCurrency MUST have a value
        let ci = rgCurrency![indexPath.row]
        
        return CurrencyRow.rowForCurrency(ci: ci, tableView: tableView)
    }
    

    // MARK: - Handling clicks
    func pushWebURL(_ szPath : String) {
        let vwWeb = HostedWebViewController(url: szPath)
        navigationController?.pushViewController(vwWeb, animated: true)
    }
    
    func pushAuthURL(_ target : String) {
        pushWebURL(MFBProfile.sharedProfile.authRedirForUser(params: "d=\(target)&naked=1"))
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == sectDisclaimer {
            pushWebURL(String(format: "https://%@/logbook/Public/CurrencyDisclaimer.aspx?naked=1", MFBHOSTNAME))
        }
        else if indexPath.section == sectCurrency {
            let ci = rgCurrency![indexPath.row] // rgCurrency shouldn't be empty if we're receiving a select event!
            
            switch ci.currencyGroup {
            case MFBWebServiceSvc_CurrencyGroups_Medical:
                pushAuthURL("MEDICAL")
            case MFBWebServiceSvc_CurrencyGroups_Deadline:
                pushAuthURL("DEADLINE")
            case MFBWebServiceSvc_CurrencyGroups_AircraftDeadline:
                pushAuthURL("AIRCRAFTEDIT&id=\(ci.associatedResourceID.intValue)")
            case MFBWebServiceSvc_CurrencyGroups_Certificates:
                pushAuthURL("CERTIFICATES")
            case MFBWebServiceSvc_CurrencyGroups_FlightReview:
                pushAuthURL("FLIGHTREVIEW")
            case MFBWebServiceSvc_CurrencyGroups_FlightExperience:
                if ci.query != nil {
                    navigationController?.pushViewController(SwiftConversionHackBridge.recentFlights(with: ci.query), animated: true)
                }
            case MFBWebServiceSvc_CurrencyGroups_CustomCurrency:
                if (ci.query != nil)  {
                    navigationController?.pushViewController(SwiftConversionHackBridge.recentFlights(with: ci.query!), animated: true)
                }
                else {
                    pushAuthURL("CUSTOMCURRENCY")
                }
            case MFBWebServiceSvc_CurrencyGroups_Aircraft:
                if let ac = Aircraft.sharedAircraft.AircraftByID(ci.associatedResourceID.intValue) {
                    navigationController?.pushViewController(SwiftConversionHackBridge.aircraftDetails(with: ac), animated: true)
                }
            case MFBWebServiceSvc_CurrencyGroups_none, MFBWebServiceSvc_CurrencyGroups_None:
                break
            default:
                break
            }
        }
    }
    
    // MARK: - Invalidatable
    public override func invalidateViewController() {
        rgCurrency = nil
        tableView.reloadData()
        fIsValid = false
    }
    

}
