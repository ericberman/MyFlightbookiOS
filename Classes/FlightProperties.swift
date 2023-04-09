/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2023 MyFlightbook, LLC
 
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
//  FlightProperties.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/2/23.
//

import Foundation

@objc public protocol EditPropertyDelegate {
    func propertyUpdated(_ cpt : MFBWebServiceSvc_CustomPropertyType)
    func dateOfFlightShouldReset(_ dt : Date)
}

@objc public class FlightProperties : PullRefreshTableViewControllerSW, UITextFieldDelegate, UISearchBarDelegate {
    @IBOutlet var datePicker : UIDatePicker!
    @IBOutlet var searchBar : UISearchBar!

    @objc public var delegate : EditPropertyDelegate? = nil
    @objc public var activeTemplates : Set<MFBWebServiceSvc_PropertyTemplate> = []
    @objc public var le : LogbookEntry? = nil
    
    private var rgFilteredProps : [MFBWebServiceSvc_CustomPropertyType] = []
    private var rgAllProps : [MFBWebServiceSvc_CustomFlightProperty] = []
    private var dictPropCells : [NSNumber : PropertyCell] = [:]
    private var content : [PropGroup] = []
    private var indices : [String] = []
    private var flightProps : FlightProps!
    private var vwAccessory : AccessoryBar!
    private var activeTextField : UITextField? = nil

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        flightProps = FlightProps()
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        if le != nil {
            navigationItem.rightBarButtonItems = [editButtonItem, UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))]
            rgAllProps = flightProps.crossProduct(le!.entryData.customProperties.customFlightProperty as! [MFBWebServiceSvc_CustomFlightProperty]) as! [MFBWebServiceSvc_CustomFlightProperty]
        }
        
        setUpIndices()
        refreshFilteredProps("")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        searchBar.placeholder = String(localized: "PropertySearchPrompt", comment: "Search Prompt Properties")
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        tableView.endEditing(true)
        commitChanges()
        dictPropCells.removeAll()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - data management
    
    func setUpIndices() {
        content = PropGroup.groupProps(flightProps.synchronizedProps)
        indices = PropGroup.indicesFromGroups(content)
    }
    
    func commitChanges() {
        le?.entryData.customProperties.setProperties(flightProps.distillList(rgAllProps, includeLockedProps: true, includeTemplates: activeTemplates as NSSet))
    }
    
    @objc public override func refresh() {
        commitChanges()
        flightProps.setCacheRetry()
        flightProps.loadCustomPropertyTypes()
        rgAllProps = (flightProps.crossProduct(le?.entryData.customProperties.customFlightProperty  as! [MFBWebServiceSvc_CustomFlightProperty])) as! [MFBWebServiceSvc_CustomFlightProperty]
        searchBar.text = ""
        refreshFilteredProps("")
        setUpIndices()
        stopLoading()
        tableView.reloadData()
    }
    
    // MARK: Table view utilities to convert indexpaths to properties
    func flightPropertyForType(_ cpt : MFBWebServiceSvc_CustomPropertyType) -> MFBWebServiceSvc_CustomFlightProperty? {
        return rgAllProps.first { cfp in
            cfp.propTypeID.intValue == cpt.propTypeID.intValue
        }
    }
    
    func cptForIndexPath(_ ip : IndexPath) -> MFBWebServiceSvc_CustomPropertyType {
        return searchActive ? rgFilteredProps[ip.row] : content[ip.section].props[ip.row]
    }
    
    func flightPropertyForIndexPath(_ ip : IndexPath) -> MFBWebServiceSvc_CustomFlightProperty {
        return flightPropertyForType(cptForIndexPath(ip))!  // better not be nil!
    }
    

    // MARK: - UITableView data source
    var searchActive : Bool {
        get {
            return !(searchBar.text ?? "").isEmpty
        }
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchActive ? nil : content[section].key
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return searchActive ? 1 : content.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActive ? rgFilteredProps.count : content[section].props.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cpt = cptForIndexPath(indexPath)
        let cfp = flightPropertyForType(cpt)!
        
        // hack for iOS 7+ - we need to hold ALL of the cells around so that if you scroll away while editing it doesn't
        // crash while you edit another cell.
        var _cell = dictPropCells[cpt.propTypeID]
        if _cell == nil {
            _cell = PropertyCell.getPropertyCell(tableView, withCPT: cpt, andFlightProperty: cfp)
            dictPropCells[cpt.propTypeID] = _cell
        }
        
        let cell = _cell!
        // Configure the cell...
        cell.txt.delegate = self
        cell.flightPropDelegate = flightProps
        cell.configureCell(vwAccessory, andDatePicker: datePicker, defValue: le?.entryData.xfillValueForPropType(cpt) ?? NSNumber(floatLiteral: 0.0))
        
        return cell;
    }
    
    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indices
    }
    
    public override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if title.compare(UITableView.indexSearch) == .orderedSame {
            tableView.scrollRectToVisible(searchBar.frame, animated: false)
        }
        return searchActive ? 0 : indices.firstIndex(of: title)! - 1
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let cfp = flightPropertyForIndexPath(indexPath)
            flightProps.deleteProperty(cfp, forUser: MFBProfile.sharedProfile.AuthToken)
            let cpt = cptForIndexPath(indexPath)
            cfp.setDefaultForType(cpt)
            commitChanges()
            rgAllProps = flightProps.crossProduct(le!.entryData.customProperties.customFlightProperty as! [MFBWebServiceSvc_CustomFlightProperty]) as! [MFBWebServiceSvc_CustomFlightProperty]
            dictPropCells.removeAll()
            isEditing = false
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableView Delegate
    func handleClick(_ tableView : UITableView, ip: IndexPath) {
        // See http://stackoverflow.com/questions/1896399/becomefirstresponder-on-uitextview-not-working;
        // Need to use [self.tableView cellForRow...] to get the existing cell, rather than [self tableview:self.tableView...];
        let pc = self.tableView(tableView, cellForRowAt: ip) as! PropertyCell
        if pc.handleClick() {
            flightProps.propValueChanged(pc.cfp)
            tableView.reloadData()
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ipActive = indexPath
        handleClick(tableView, ip: indexPath)
    }
    
    // MARK: - UISearchBarDelegate
    func refreshFilteredProps(_ szFilter : String) {
        if szFilter.trimmingCharacters(in: .whitespaces).isEmpty {
            rgFilteredProps = flightProps.rgPropTypes
        } else {
            let rgWords = szFilter.components(separatedBy: " ")
            rgFilteredProps = flightProps.rgPropTypes.filter({ cpt in
                for sz in rgWords {
                    if !sz.isEmpty && cpt.title.range(of: sz, options: .caseInsensitive) == nil {
                        return false
                    }
                }
                return true
            })
        }
    }
    
    // MARK: UISearchDisplayDelegate
    func updateResultsForText(_ searchText : String) {
        stopLoading()
        refreshFilteredProps(searchText)
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
    
    // MARK: - UITextFieldDelegate
    func owningPropertyCell(_ vw : UIView) -> PropertyCell {
        var v : UIView? = vw
        while v != nil {
            v = v!.superview
            if let c = v as? PropertyCell {
                return c
            }
        }
        fatalError("No propertycell found in hierarchy!")
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let pc = owningPropertyCell(textField)
        
        pc.handleTextUpdate(textField)
        
        delegate?.propertyUpdated(pc.cpt)
        
        self.flightProps.propValueChanged(pc.cfp)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let pc = owningPropertyCell(textField)
        if pc.cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDate || pc.cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime {
            pc.cfp.dateValue = nil
        }
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let pc = owningPropertyCell(textField)
        
        // There was a bunch of objective-C code pre-conversion that tested for cfp=nil
        // and tried to initialize it; in this case, cfp is never nil - do we still need
        // to worry about a default-value CFP with no proptypeID set?
        assert(pc.cfp.propTypeID.intValue > 0, "Invalid proptypeID for property")
        
        let fShouldEdit = pc.prepForEditing()
        
        if !fShouldEdit && pc.cfp.propTypeID.intValue == PropTypeID.blockOut.rawValue {
            delegate?.dateOfFlightShouldReset(pc.cfp.dateValue!)
        }
        
        ipActive = self.tableView.indexPath(for: pc)
        enableNextPrev(vwAccessory)
        return fShouldEdit
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        activeTextField = nil
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let pc = owningPropertyCell(textField)
        return pc.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    // MARK: - AccessoryViewDelegates
    public override func deleteClicked() {
        assert(activeTextField != nil, "Delete clicked with no active text field!")
        let pc = owningPropertyCell(activeTextField!)
        activeTextField?.text = ""
        if pc.cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDateTime || pc.cpt.type == MFBWebServiceSvc_CFPPropertyType_cfpDate {
            pc.cfp.dateValue = nil
        }
    }
    
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        let cpt = cptForIndexPath(ip)
        switch cpt.type {
        case MFBWebServiceSvc_CFPPropertyType_cfpBoolean:
            return false
        case MFBWebServiceSvc_CFPPropertyType_cfpDateTime, MFBWebServiceSvc_CFPPropertyType_cfpDate:
            return !NSDate.isUnknownDate(dt: flightPropertyForType(cpt)?.dateValue)
        default:
            return true
        }
    }
}
