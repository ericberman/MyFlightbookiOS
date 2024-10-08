/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2011-2023 MyFlightbook, LLC
 
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
//  MakeModel.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/28/23.
//

import Foundation

@objc public class MakeModel : PullRefreshTableViewControllerSW, UISearchBarDelegate {
    @IBOutlet weak var searchBar : UISearchBar!

    @objc public var ac : MFBWebServiceSvc_Aircraft? = nil
    var rgFilteredMakes : [MFBWebServiceSvc_SimpleMakeModel] = []
    var content : [ModelGroup] = []
    var indices : [String] = []
    var fDisableRefresh = false
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // MARK: - Data
    /*
        The data structure is this:
        self.content is an array of ManufacturerCollection objects
        Each ManufacturerCollection has the name of the manufacturer and an array of its models (SimpleMakeModel)
    */
    public func groupData() {
        if (rgFilteredMakes.isEmpty) {
            rgFilteredMakes.append(contentsOf: Aircraft.sharedAircraft.rgMakeModels ?? [])
        }

        content = ModelGroup.groupModels(rgFilteredMakes)
        indices = ModelGroup.indicesFromGroups(content)
    }
    
    // MARK: - Update makes and models
    func updateMakesCompleted(_ sc : MFBSoapCall, fromCaller a : Aircraft) {
        endCall()
        if isLoading {
            stopLoading()
        }
        
        rgFilteredMakes.removeAll()
        rgFilteredMakes.append(contentsOf: Aircraft.sharedAircraft.rgMakeModels ?? [])
        groupData()
        tableView.reloadData() // in case the static description needs to be updated
    }
    
    @objc public override func refresh() {
        if fDisableRefresh || !MFBNetworkManager.shared.isOnLine {
            if isLoading {
                stopLoading()
            }
            return
        }
        
        if callInProgress {
            return
        }
        
        startCall()
        
        let a = Aircraft.sharedAircraft
        a.setDelegate(self) { sc, ao in
            self.updateMakesCompleted(sc!, fromCaller: ao as! Aircraft)
        }
        a.loadMakeModels()
    }
    
    @objc public func makesLoaded(_ notification : NSNotification) {
        rgFilteredMakes.removeAll()
        rgFilteredMakes.append(contentsOf: Aircraft.sharedAircraft.rgMakeModels ?? [])
        groupData()
        tableView.reloadData()
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        groupData()
        NotificationCenter.default.addObserver(self, selector: #selector(makesLoaded), name: Notification.Name("makesLoaded"), object: nil)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 38
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        searchBar.placeholder = String(localized: "ModelSearchPrompt", comment: "Search Prompt Models")
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    public override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if (section == 0) {
            let header = view as! UITableViewHeaderFooterView
            
            var config = header.defaultContentConfiguration()
            config.text = String(localized: "Add Model Prompt", comment: "Prompt to create a new model on MyFlightbook.com")
            config.textProperties.adjustsFontSizeToFitWidth = true
            config.textProperties.alignment = .center
            header.contentConfiguration = config
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (isExpanded(section) ? content[section].models.count : 0)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifierModel = "Cell"
        
        // Get the manufacturer collection for this indexpath
        let mg = content[indexPath.section]
        
        // See if this is a header cell
        if (indexPath.row == 0) {
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle: mg.manufacturerName, forSection: indexPath.section, initialState: isExpanded(indexPath.section))
        }

        // Otherwise, it's a model cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifierModel) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifierModel)

        let mm = mg.models[indexPath.row - 1]
        
        var config = cell.defaultContentConfiguration()
        config.text = mm.manufacturerName
        if mm.manufacturerName != mm.unamibiguousDescription {
            config.secondaryText = mm.subDesc
        }
        cell.contentConfiguration = config
        
        return cell
    }
    
    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indices
    }
    
    public override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title == UITableView.indexSearch {
            tableView.scrollRectToVisible(searchBar.frame, animated: false)
            return -1
        }
        return content.firstIndex { mg in
            mg.manufacturerName.hasPrefix(title)
        } ?? 0
    }
    
    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            toggleSection(indexPath.section, forTable: tableView)
            return
        }
        
        let mc = content[indexPath.section]
        let mm = mc.models[indexPath.row - 1]
        ac?.modelID = mm.modelID
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    func updateFilteredMakes(_ szFilter : String?) {
        let rgMakes = Aircraft.sharedAircraft.rgMakeModels ?? []
        let filter = szFilter ?? ""
        if (filter).isEmpty {
            rgFilteredMakes.removeAll()
            rgFilteredMakes.append(contentsOf: rgMakes)
        } else {
            let nonAlphaNumeric = CharacterSet.alphanumerics.inverted
            let searchStrings = filter.components(separatedBy: nonAlphaNumeric)
            rgFilteredMakes = rgMakes.filter({ smm in
                for sz in searchStrings {
                    if !sz.isEmpty && smm.unamibiguousDescription.range(of: sz, options: .caseInsensitive) == nil {
                        return false
                    }
                }
                return true
            })
        }
        groupData()
    }
    
    // MARK: - UISearchDisplayDelegate
    func updateResultsForText(_ searchText : String?) {
        fDisableRefresh = true
        updateFilteredMakes(searchText)
        if content.count > 5 {
            collapseAll()
        }
        else {
            expandAll(self.tableView)
        }
        tableView.reloadData()
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateResultsForText(searchText)
    }
    
    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateResultsForText(searchBar.text)
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        collapseAll()
        updateFilteredMakes(nil)
        tableView.reloadData()
        fDisableRefresh = false
    }
    
}
