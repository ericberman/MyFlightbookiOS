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
//  Totals.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/28/23.
//

import Foundation

@objc public class Totals : PullRefreshTableViewControllerSW, MFBSoapCallDelegate, QueryDelegate {
    @objc public var fq : MFBWebServiceSvc_FlightQuery = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
    
    private var rgTotalsGroups : [[MFBWebServiceSvc_TotalsItem]]? = nil
    private var errorString = ""
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        fIsValid = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target:self, action:#selector(refresh))
        
        let app = MFBAppDelegate.threadSafeAppDelegate;
        app.registerNotifyDataChanged(self)
        app.registerNotifyResetAll(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.toolbar.isTranslucent = false
        navigationController?.isToolbarHidden = true
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rgTotalsGroups == nil || !fIsValid {
            refresh()
            tableView.reloadData()
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        rgTotalsGroups = nil
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
    }
    
    // MARK: - Invalidatible
    public override func invalidateViewController() {
        rgTotalsGroups = nil
        fIsValid = false
        tableView.reloadData()
    }
    
    // MARK: - Data
    public override func refresh() {
        NSLog("LoadTotalsForUser")
        errorString = ""
        
        tableView.allowsSelection = true
        
        let authToken = MFBProfile.sharedProfile.AuthToken
        if authToken.isEmpty {
            errorString = String(localized: "You must be signed in to view totals.")
            showError(errorString, withTitle:String(localized: "Error loading totals", comment: "Title for error message"))
        } else if !MFBNetworkManager.shared.isOnLine {
            if let dtLastPack = PackAndGo.lastTotalsPackDate {
                let df = DateFormatter()
                df.dateStyle = .short
                rgTotalsGroups = MFBWebServiceSvc_TotalsItem.group(items: PackAndGo.cachedTotals)
                tableView.reloadData()
                fIsValid = true
                tableView.allowsSelection = false
                showError(String(format: String(localized: "PackAndGoUsingCached", comment: "Pack and go - Using Cached"), df.string(from: dtLastPack as Date)),
                                 withTitle: String(localized: "PackAndGoOffline", comment: "Pack and go - Using Cached"))
            }
            else {
                self.errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
                showError(errorString, withTitle: String(localized: "Error loading totals", comment: "Title for error message"))
            }
        }
        else
        {
            if callInProgress {
                return
            }
            
            self.startCall()

            let totalsForUserSvc = MFBWebServiceSvc_TotalsForUserWithQuery()
            
            totalsForUserSvc.szAuthToken = authToken
            totalsForUserSvc.fq = fq;
            
            let sc = MFBSoapCall()
            sc.delegate = self;
            sc.logCallData = false
            
            sc.makeCallAsync { b, sc in
                b.totalsForUserWithQueryAsync(usingParameters: totalsForUserSvc, delegate: sc)
            }
        }
    }
    
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_TotalsForUserWithQueryResponse {
            if fq.isUnrestricted() {
                PackAndGo.updateTotals(resp.totalsForUserWithQueryResult.totalsItem as! [MFBWebServiceSvc_TotalsItem])
            }
            rgTotalsGroups = MFBWebServiceSvc_TotalsItem.group(items: resp.totalsForUserWithQueryResult.totalsItem as! [MFBWebServiceSvc_TotalsItem])
            fIsValid = true
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        if errorString.isEmpty {
            tableView.reloadData()
        } else {
            showError(errorString, withTitle: String(localized: "Error loading totals", comment: "Title for error message"))
        }
        
        if isLoading {
            stopLoading()
        }
        endCall()
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (callInProgress ? 1 : (rgTotalsGroups ?? []).count == 0 ? 1 : rgTotalsGroups!.count)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return MFBNetworkManager.shared.isOnLine ? 1 : 0
        } else {
            return callInProgress ? 1 : ((rgTotalsGroups ?? []).count == 0 ? 0 : rgTotalsGroups![section - 1].count)
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section == 0) ? CGFloat.leastNonzeroMagnitude : super.tableView(tableView, heightForHeaderInSection: section)
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? nil : (section == 1 && (rgTotalsGroups ?? []).count == 0 ? String(localized: "No totals are available.", comment: "No totals retrieved") : rgTotalsGroups![section - 1][0].groupName)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifierSelector = "CellSelector"
        if (indexPath.section == 0) // Filter
        {
            let cellSelector = tableView.dequeueReusableCell(withIdentifier: CellIdentifierSelector) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifierSelector)
            cellSelector.accessoryType = .disclosureIndicator

            var config = cellSelector.defaultContentConfiguration()
            config.text = String(localized: "FlightSearch", comment: "Choose Flights")
            config.secondaryText = fq.isUnrestricted() ? String(localized: "All Flights", comment: "All flights are selected") :
            String(localized: "Not all flights", comment: "Not all flights are selected")
            config.image = UIImage(named: "search.png")
            cellSelector.contentConfiguration = config
            return cellSelector;
        }
        
        if callInProgress {
            return waitCellWithText(String(localized: "Getting Totals...", comment: "progress indicator"))
        }

        let ti = self.rgTotalsGroups![indexPath.section - 1][indexPath.row]
        return TotalsRow.rowForTotal(ti: ti, tableView: tableView, fHHMM:UserPreferences.current.HHMMPref)
    }
    
    // MARK: - QueryDelegate
    public func queryUpdated(_ fq: MFBWebServiceSvc_FlightQuery) {
        self.fq = fq
        refresh()
    }
    
    // MARK: - Tableview clicks
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLoading {
            return
        }
        
        if indexPath.section == 0 {
            let fqf = FlightQueryForm.queryController(fq, delegate: self)
            navigationController?.pushViewController(fqf, animated: true)
        }
        else {
            let ti = rgTotalsGroups![indexPath.section - 1][indexPath.row]
            if let q = ti.query {
                navigationController?.pushViewController(RecentFlights.viewForFlightsMatching(query: q), animated: true)
            }
        }
    }
}
