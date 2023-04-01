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
//  VisitedAirports.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/31/23.
//

import Foundation

@objc public class VisitedAirports : PullRefreshTableViewControllerSW, MFBSoapCallDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var searchBar : UISearchBar!
    
    var rgVAFiltered : [MFBWebServiceSvc_VisitedAirport] = []
    var rgVA : [MFBWebServiceSvc_VisitedAirport]? = nil
    var errorString = ""
    var content : [[String : Any]] = []
    var indices : [String] = []
    
    let szKeyRowValues = "rowValues"
    let szKeyHeaderTitle = "headerTitle"

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        rgVA = nil
        rgVAFiltered.removeAll()
        content = []
        indices.removeAll()
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateVisitedAirports))
        
        let app = MFBAppDelegate.threadSafeAppDelegate
        app.registerNotifyDataChanged(self)
        app.registerNotifyResetAll(self)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.placeholder = String(localized: "AirportsSearchPrompt", comment: "Search for airports")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if rgVA == nil || !fIsValid {
            updateVisitedAirports()
        }
    }
    
    // MARK: - Data Management
    func setData(_ arr : [MFBWebServiceSvc_VisitedAirport]) {
        rgVA = Array(arr)
        rgVA!.sort(by: { va1, va2 in
            return va1.compareName(va2) != .orderedDescending
        })
        searchBar.text = ""
        refreshFilteredAirports(searchBar.text ?? "")
        rgVAFiltered = Array(rgVA ?? [])
        setupIndices()
    }
    
    func setupIndices() {
        // now chop this up into individual sections.
        // we create an dictionary of dictionary objects.
        // Each dictionary object contains the (a) the header title (1st letter of airpport code) +
        // (b) an array of all airports beginning with that code.
        // we will then convert that dictionary to an array and sort it.

        content.removeAll()
        var szKey = ""
        
        // Because f'ing swift arrays are structs, and every struct is passed by reference,
        // we can't modify things in place, which is horribly ineficient on multiple levels.
        // So we'll use NSMutable Array/Diction (abominations themselves), but at least we can
        // construct the mapping efficiently.  Uggh
        let rggroups = NSMutableArray()

        for va in rgVAFiltered {
            let szNewKey = va.airport.name.prefix(1).uppercased()
            var dictForKey = NSMutableDictionary()
            
            if szKey == szNewKey {
                dictForKey = rggroups[rggroups.count - 1] as! NSMutableDictionary
            } else {
                szKey = szNewKey
                // create the dictionary
                // and add the two items (header title and a mutable array)
                dictForKey = NSMutableDictionary()
                dictForKey[szKeyHeaderTitle] = szKey
                dictForKey[szKeyRowValues] = NSMutableArray()

                // and add this dctionary to contentDict
                rggroups.add(dictForKey)
            }
            
            // now get the array (perhaps just stored)
            let rg = dictForKey[szKeyRowValues] as! NSMutableArray
            rg.add(va)
        }
        
        content = rggroups as! [[String : Any]]
        
        // Add the "All items" item before all the others
        let dictAll : [String : Any] = [szKeyHeaderTitle : String(localized: "All", comment: "In visited airports, the table of contents on the right has A, B, ... Z for quick access to individual airports and 'All' for all airports"),
                                         szKeyRowValues : [] as [MFBWebServiceSvc_VisitedAirport]]
        content.insert(dictAll, at: 0)

        // and get the array of header titles.
        indices.removeAll()
        indices.append(contentsOf: content.map({ d in
            return d[szKeyHeaderTitle] as! String
        }))
    }
    
    @IBAction func updateVisitedAirports() {
        errorString = ""
        tableView.allowsSelection = true
        let authToken = MFBProfile.sharedProfile.AuthToken
        if authToken.isEmpty {
            errorString = String(localized: "You must sign in to view visited airports.", comment: "Can't see visited airports if not signed in.")
            showError(errorString, withTitle:String(localized: "Error loading visited airports", comment: "Title when an error occurs loading visited airports"))
        } else if !MFBNetworkManager.shared.isOnLine {
            if let dtLastPack = PackAndGo.lastVisitedPackDate {
                let df = DateFormatter()
                df.dateStyle = .short
                setData(PackAndGo.cachedVisited)

                tableView.allowsSelection = false
                tableView.reloadData()
                fIsValid = true
                showError(String(format: String(localized: "PackAndGoUsingCached", comment: "Pack and go - Using Cached"), df.string(from: dtLastPack as Date)), withTitle:String(localized: "PackAndGoOffline", comment: "Pack and go - Using Cached"))
            }
            else {
                self.errorString = String(localized: "No connection to the Internet is available", comment: "Error: Offline")
                showError(errorString, withTitle: String(localized: "Error loading visited airports", comment: "Title when an error occurs loading visited airports"))
            }
        } else {
            if self.callInProgress {
                return
            }
            
            startCall()
            let visitedAirportsSVC = MFBWebServiceSvc_VisitedAirports()
            visitedAirportsSVC.szAuthToken = authToken;

            let sc = MFBSoapCall(delegate: self)
            
            sc.makeCallAsync { b, sc in
                b.visitedAirportsAsync(usingParameters: visitedAirportsSVC, delegate: sc)
            }
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        errorString = sc.errorString
        if !errorString.isEmpty {
            showError(errorString, withTitle:String(localized: "Error loading visited airports", comment: "Title when an error occurs loading visited airports"))
        } else {
            tableView.reloadData()
        }
        if isLoading {
            stopLoading()
        }
        endCall()
    }
    
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_VisitedAirportsResponse {
            rgVA = Array(resp.visitedAirportsResult.visitedAirport as! [MFBWebServiceSvc_VisitedAirport])
            searchBar.text = ""
            
            // set the distance from current position, if it's known (else 0)
            let loc = MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc
            for va in rgVA! {
                va.airport.distanceFromPosition = (loc == nil) ?
                0 :
                NSNumber(floatLiteral: loc!.distance(from: CLLocation(latitude: va.airport.latLong.latitude.doubleValue, longitude: va.airport.latLong.longitude.doubleValue)) * MFBConstants.NM_IN_A_METER)
            }
            
            setData(rgVA!)
            PackAndGo.updateVisited(rgVA!)
            fIsValid = true
        }
    }
    
    public override func refresh() {
        searchBar.text = ""
        updateVisitedAirports()
    }
    
    // MARK: - UISearchBarDelegate/UISearchDisplayDelegate
    func refreshFilteredAirports(_ szFilter : String) {
        if szFilter.isEmpty {
            rgVAFiltered = Array(rgVA ?? [])
        } else {
            rgVAFiltered = (rgVA ?? []).filter({ va in
                let szSearch = "\(va.code ?? "") \(va.airport.name ?? "")"
                return szSearch.range(of: szFilter, options: .caseInsensitive) != nil
            })
        }
    }
    
    func updateResultsForText(_ searchText : String) {
        stopLoading()
        refreshFilteredAirports(searchText)
        setupIndices()
        tableView.reloadData()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateResultsForText(searchText)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateResultsForText(searchBar.text ?? "")
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
    // MARK: - Table data source delegate
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return callInProgress ? nil : content[section][szKeyHeaderTitle] as? String
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return callInProgress ? 1 : content.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 || callInProgress ? 1 : (content[section][szKeyRowValues] as! [MFBWebServiceSvc_VisitedAirport]).count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if callInProgress {
            return waitCellWithText(String(localized: "Getting Visited Airports...", comment: "Progress indicator while getting visited airports"))
        }
        
        let CellIdentifier = "VisitedAirportCell"
        let CellIdentifierAll = "VisitedAirportCellAll"
        
        if indexPath.section == 0 { // ALL airports item.
            let cellAll = tableView.dequeueReusableCell(withIdentifier: CellIdentifierAll) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifierAll)
            
            cellAll.selectionStyle = .blue
            cellAll.accessoryType = (rgVA ?? []).isEmpty ? .none : .disclosureIndicator
            
            var config = cellAll.defaultContentConfiguration()
            config.text = String(localized: "All Airports", comment: "The 'airport' that shows all visited airports")
            config.secondaryText = String(format: String(localized: "(%lu unique airports found)", comment: "# of unique visited airports that were found; '%d' gets replaced at runtime; leave it there!"), rgVAFiltered.count)
            cellAll.contentConfiguration = config
            return cellAll
        } else {
            // Configure the cell...
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
            cell.accessoryType = .disclosureIndicator
            
            var config = cell.defaultContentConfiguration()
            
            let df = DateFormatter()
            df.dateStyle = .short
            
            let va = (content[indexPath.section][szKeyRowValues] as! [MFBWebServiceSvc_VisitedAirport])[indexPath.row]
            
            config.attributedText = NSAttributedString.attributedStringFromMarkDown(sz: "*\(va.airport.code.uppercased())* - \(va.airport.name.capitalized)" as NSString, size: config.textProperties.font.pointSize)
            
            let dist = va.airport.distanceFromPosition.doubleValue
            
            let szDist = dist > 0 ? String.localizedStringWithFormat(String(localized: "(%.1fNM) ", comment: "Distance to an airport; the '%.1f' gets replaced by the numerical value at runtime; leave it there"), dist) : ""
            
            config.secondaryText = va.numberOfVisits.intValue == 1 ?
            String(format: String(localized: "%@%d visit on %@", comment: "For a visited airport, this puts the distance at the first %@, the number of visits at the %d, and the date of the visit at the latter %@; e.g., '(3.2NM) 2 visits on Jan 10 2010', so leave the %d and %@ intact"), szDist, va.numberOfVisits.intValue, df.string(from: va.earliestVisitDate)) :
            String(format: String(localized: "%@%d visits from %@ to %@", comment: "For a visited airport, this puts the distance at the first %@, the number of visits at the %d, and the earliest/latest dates at the other %@; e.g., '(3.2NM) 2 visits from Jan 10 2010 to Mar 31, 2011', so leave the %d/%@ intact"), szDist, va.numberOfVisits.intValue,
                   df.string(from: va.earliestVisitDate), df.string(from: va.latestVisitDate))
            cell.contentConfiguration = config
            return cell
        }
    }
    
    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indices
    }
    
    public override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return indices.firstIndex(of: title) ?? 0
    }
    
    // MARK: Table view delegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // don't respond to a selection if we're refreshing, or offline, or nothing to select
        if rgVAFiltered.isEmpty || isLoading || !MFBNetworkManager.shared.isOnLine {
            return
        }
        
        let vaDetails = VADetails(nibName: "VADetails", bundle: nil)
        
        vaDetails.rgVA = indexPath.section == 0 ? rgVAFiltered : [(content[indexPath.section][szKeyRowValues] as! [MFBWebServiceSvc_VisitedAirport])[indexPath.row]]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.pushViewController(vaDetails, animated: true)
    }
    
    // MARK: Invalidatable
    public override func invalidateViewController() {
        rgVA = nil
        content = []
        fIsValid = false
        tableView.reloadData()
    }
}
