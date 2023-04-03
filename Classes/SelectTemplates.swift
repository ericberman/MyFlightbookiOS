//
//  SelectTemplates.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/2/23.
//

import Foundation

@objc public protocol SelectTemplatesDelegate {
    @objc func templatesUpdated(_ templateSet : Set<MFBWebServiceSvc_PropertyTemplate>)
}

@objc public class SelectTemplates : PullRefreshTableViewControllerSW, MFBSoapCallDelegate {
    @objc public var delegate : SelectTemplatesDelegate? = nil
    @objc public var templateSet : Set<MFBWebServiceSvc_PropertyTemplate> = []
    
    var templateGroups : [TemplateGroup] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        templateGroups = MFBWebServiceSvc_PropertyTemplate.groupTemplates(FlightProps.sharedTemplates)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return templateGroups.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templateGroups[section].templates.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return templateGroups[section].groupName
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellIdentifier = "cellTemp1"
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: CellIdentifier)
        let pt = templateGroups[indexPath.section].templates[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = pt.name
        // Have to use "pt.description!" because FUCK APPLE decides to change the casing on a properties, causing
        // "Description" to collide with the debug "description" computed var.  Adding the forced unwrapping should
        // work, but I have no way to know if that will change in the future.  Why, oh, way, do you enforce
        // casing changes??? Really, what f'ing problem are you solving???
        config.secondaryText = pt.description!
        cell.contentConfiguration = config
        cell.accessoryType = templateSet.contains(pt) ? .checkmark : .none
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pt = templateGroups[indexPath.section].templates[indexPath.row]
        if templateSet.contains(pt) {
            templateSet.remove(pt)
        } else {
            templateSet.insert(pt)
        }
        tableView.reloadData()
        delegate?.templatesUpdated(templateSet)
    }
    
    // MARK: - Refresh
    public override func refresh() {
        if !MFBNetworkManager.shared.isOnLine {
            endCall()
            return
        }
        
        let cptSvc = MFBWebServiceSvc_PropertiesAndTemplatesForUser()
        cptSvc.szAuthUserToken = MFBProfile.sharedProfile.AuthToken
        let sc = MFBSoapCall(delegate: self)
        sc.timeOut = 10
        
        sc.makeCallAsync { b, sc in
            b.propertiesAndTemplatesForUserAsync(usingParameters: cptSvc, delegate: sc)
        }
    }
    
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse {
            // sanity check but should never happen
            if resp.propertiesAndTemplatesForUserResult.userProperties.customPropertyType.count == 0 {
                return
            }
            
            FlightProps.replaceTemplates(resp.propertiesAndTemplatesForUserResult.userTemplates.propertyTemplate as! [MFBWebServiceSvc_PropertyTemplate])
            FlightProps.saveTemplates()
            templateSet.removeAll()
            
            for pt  in FlightProps.sharedTemplates {
                if pt.isDefault.boolValue {
                    templateSet.insert(pt)
                }
            }
            templateGroups = MFBWebServiceSvc_PropertyTemplate.groupTemplates(FlightProps.sharedTemplates)
            fIsValid = true
            
            // update the cache of proptypes too, since we got 'em...
            let fp = FlightProps()
            fp.setPropTypeArray(resp.propertiesAndTemplatesForUserResult.userProperties.customPropertyType as? [MFBWebServiceSvc_CustomPropertyType])
            fp.cacheProps()
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        if !sc.errorString.isEmpty {
            showError(sc.errorString, withTitle: String(localized: "Error loading totals", comment: "Title for error message"))
        } else {
            tableView.reloadData()
            delegate?.templatesUpdated(templateSet)
        }
        
        if isLoading {
            stopLoading()
        }
        endCall()
    }
 }
