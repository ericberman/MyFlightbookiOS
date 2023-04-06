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
//  NewAircraftViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/4/23.
//

import Foundation

@objc public class NewAircraftViewController : AircraftViewControllerBaseSw, UIPickerViewDelegate, UITextFieldDelegate, MFBSoapCallDelegate {
    private var szTailnumberLast = ""
    private var suggestedAircraft : [MFBWebServiceSvc_Aircraft] = []
    
    enum newAircraftSection : Int, CaseIterable {
        case sectMain = 0, sectTail, sectModel, sectImages
    }
    
    enum newAircraftRow : Int, CaseIterable {
        case rowInstanceTypeReal = 0 , rowInstanceTypeUncertified, rowInstanceTypeATD, rowInstanceTypeFTD, rowInstanceTypeFFS, rowIsAnonymous, rowTailnum,
             rowSuggestion, rowModel, rowImageHeader
    }
    
    // MARK: - Initialization
    public required init(with acIn : MFBWebServiceSvc_Aircraft, delegate d : AircraftViewControllerDelegate?) {
        super.init(with: acIn, delegate: d, style: .grouped)
        imagesSection = newAircraftSection.sectImages.rawValue
        assert(ac.isNew())
        DispatchQueue.global(qos: .default).async {
            let ar = NSMutableArray()
            if CommentedImage.initCommentedImagesFromMFBII(self.ac.aircraftImages.mfbImageInfo as! [MFBWebServiceSvc_MFBImageInfo], toArray: ar) {
                self.rgImages = ar as! [CommentedImage]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if !self.rgImages.isEmpty && !self.isExpanded(self.imagesSection) {
                        self.expandSection(self.imagesSection)
                    }
                }
            }
        }
        
        // Auto-expand image section if there are images
        collapseAll()
        if !rgImages.isEmpty {
            expandSection(imagesSection)
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        navigationItem.title = String(localized: "Add Aircraft", comment: "Submit - Add")
        
        // Set up for camera/images
        let bbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let bbGallery = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImages))
        let bbCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePictures))

        bbGallery.isEnabled = canUsePhotoLibrary()
        bbCamera.isEnabled = canUseCamera()
        
        bbGallery.style = .plain
        bbCamera.style = .plain;
        toolbarItems = [bbSpacer, bbGallery, bbCamera]
        
        // Submit button
        let bbSubmit = UIBarButtonItem(title: String(localized: "Add", comment: "Generic Add"),
                                       style: .plain,
                                       target: self,
                                       action: #selector(addAircraft))
        
        navigationItem.rightBarButtonItem = bbSubmit;

        // Old code did this in view did appear; we should start it earlier
        if (Aircraft.sharedAircraft.rgMakeModels ?? []).isEmpty {
            updateMakes()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.isTranslucent = false
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        progress = nil
        navigationController?.isToolbarHidden = true
        super.viewWillDisappear(animated)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        for ci in rgImages {
            ci.flushCachedImage()
        }
        progress = nil
    }
    
    // MARK: - Suggested Aircraft
    func removeSuggestedAircraft() {
        if !suggestedAircraft.isEmpty {
            var rgRows : [IndexPath] = []
            for i in 1...suggestedAircraft.count {
                rgRows.append(IndexPath(row: i, section: newAircraftSection.sectTail.rawValue))
            }
            suggestedAircraft = []
            tableView.deleteRows(at: rgRows, with: .none)
        }
    }
    
    func addSuggestedAircraft(_ rg : [MFBWebServiceSvc_Aircraft]) {
        if !rg.isEmpty {
            var rgRows : [IndexPath] = []
            for i in 1...rg.count {
                rgRows.append(IndexPath(row: i, section: newAircraftSection.sectTail.rawValue))
            }
            suggestedAircraft = rg
            tableView.insertRows(at: rgRows, with: .none)
        }
    }
    
    // MARK: - Table View Data Source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return newAircraftSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch newAircraftSection(rawValue: section) {
        case .sectMain:
            // 5 instance types + 0 if it's a sim, or a single row (the anonymous checkbox) if it's not
            return (newAircraftRow.rowInstanceTypeFFS.rawValue - newAircraftRow.rowInstanceTypeReal.rawValue + 1) + (ac.isSim() ? 0 : 1)
        case .sectModel:
            return 1
        case .sectImages:
            return rgImages.isEmpty ? 0 : 1 + (isExpanded(section) ? rgImages.count : 0)
        case .sectTail:
            // 0 if it's anonymous or a sim, otherwise 1 row plus any suggestions
            return ac.isAnonymous() || ac.isSim() ? 0 : 1 + suggestedAircraft.count
        default:
            fatalError("Unknown section in new aircraft: \(section)")
        }
    }
    
    func cellIDFrom(ip : IndexPath) -> newAircraftRow {
        switch newAircraftSection(rawValue: ip.section) {
        case .sectMain:
            return newAircraftRow(rawValue: newAircraftRow.rowInstanceTypeReal.rawValue + ip.row)!
        case .sectImages:
            // only the header is an enumerated row
            return newAircraftRow.rowImageHeader
        case .sectModel:
            return newAircraftRow.rowModel
        case .sectTail:
            // as with images, this is dynamic, so only return one possible value if row > 0
            return ip.row == 0 ? newAircraftRow.rowTailnum :  newAircraftRow.rowSuggestion
        default:
            fatalError("Unknown section in new aircraft: \(ip.section)")
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == newAircraftSection.sectImages.rawValue && indexPath.row > 0) ? 100 : UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch newAircraftSection(rawValue: section) {
        case .sectMain:
            return String(localized: "Aircraft Details", comment: "New Aircraft Section - Details")
        case .sectTail:
            return ac.isSim() || ac.isAnonymous() ? nil : String(localized: "TailLabel", comment: "Tail Label")
        case .sectModel:
            return String(localized: "Model of Aircraft", comment: "New Aircraft Section - Model")
        default:
            return nil
        }
    }
    
    func tableCell(_ tableView : UITableView, forInstanceType instanceType : MFBWebServiceSvc_AircraftInstanceTypes) -> UITableViewCell {
        let cellIdentifier = "cellIns«tanceType"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        var config = cell.defaultContentConfiguration()
        config.text = Aircraft.aircraftInstanceTypeDisplay(instanceType)
        cell.contentConfiguration = config
        cell.accessoryType = (instanceType == ac.instanceType) ? .checkmark : .none;
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = cellIDFrom(ip: indexPath)
        let section = newAircraftSection(rawValue: indexPath.section)
        let aircraft = Aircraft.sharedAircraft
        
        // handle the dynamic sections...
        if section == .sectTail && indexPath.row > 0 {
            let CellIdentifier = "cellSuggestion"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)

            let acSuggestion = suggestedAircraft[indexPath.row - 1];
            var config = cell.defaultContentConfiguration()
            config.text = acSuggestion.displayTailNumber
            config.secondaryText = Aircraft.sharedAircraft.descriptionOfModelId(acSuggestion.modelID.intValue)
            cell.backgroundColor = .systemGray5
            cell.contentConfiguration = config
            return cell
        } else if section == .sectImages && indexPath.row > 0 {
            let CellIdentifier = "cellImage"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            
            let imageIndex = indexPath.row - 1    // account for the header row
            assert(imageIndex >= 0 && imageIndex < rgImages.count)  // should never happen
            let ci = rgImages[imageIndex]
            cell.indentationLevel = 1
            cell.indentationWidth = 10.0
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            config.text = ci.imgInfo?.comment
            config.textProperties.adjustsFontSizeToFitWidth = true
            if (ci.hasThumbnailCache) {
                config.image = ci.GetThumbnail()
            } else {
                DispatchQueue.global(qos: .default).async {
                    ci.GetThumbnail()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            cell.contentConfiguration = config
            return cell
        }
        
        // If we are here, it must be a specific known row
        switch row {
        case .rowIsAnonymous:
            let cc = CheckboxCell.getButtonCell(tableView)
            cc.btn.setTitle(String(localized: "Anonymous Aircraft", comment: "Indicates an anonymous aircraft"), for: [])
            cc.btn.setIsCheckbox()
            cc.btn.addTarget(self, action: #selector(toggleAnonymous), for: .touchUpInside)
            cc.makeTransparent()
            cc.btn.isSelected = ac.isAnonymous()
            return cc
        case .rowModel:
            let CellIdentifier = "cellModel"
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: CellIdentifier)
            cell.accessoryType = .disclosureIndicator
            
            var config = cell.defaultContentConfiguration()
            config.secondaryText = ac.modelID.intValue > 0 ? "" : String(localized: "(Tap to select model)", comment: "Model Hint")
            config.text = ac.modelID.intValue >= 0 ? aircraft.descriptionOfModelId(ac.modelID.intValue) : ""
            config.textProperties.adjustsFontSizeToFitWidth = true
            cell.contentConfiguration = config
            
            return cell
        case .rowInstanceTypeReal:
            return tableCell(tableView, forInstanceType: MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft)
        case .rowInstanceTypeUncertified:
            return tableCell(tableView, forInstanceType: MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator)
        case .rowInstanceTypeATD:
            return tableCell(tableView, forInstanceType: MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD)
        case .rowInstanceTypeFTD:
            return tableCell(tableView, forInstanceType: MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator)
        case .rowInstanceTypeFFS:
            return tableCell(tableView, forInstanceType: MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator)
        case .rowTailnum:
            let ec = EditCell.getEditCellNoLabel(tableView, withAccessory: vwAccessory)
            ec.txt.text = ac.tailNumber
            ec.txt.placeholder = String(localized: "(Tail)", comment: "Tail Hint")
            ec.txt.delegate = self
            ec.txt.clearButtonMode = .never
            ec.txt.autocapitalizationType = .allCharacters
            ec.txt.autocorrectionType = .no
            ec.txt.adjustsFontSizeToFitWidth = true
            return ec
        case .rowImageHeader:
            let szHeader = String(localized: "Images", comment: "Title for image management screen (where you can add/delete/tap-to-edit images)")
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle: szHeader, forSection: indexPath.section, initialState: isExpanded(indexPath.section))
        case .rowSuggestion:
            // handled above
            break
        }
        
        fatalError("No cell returned in cellforindexpath in newaircraftviewcontroller")
    }
    
    // MARK: - Tableview delegate
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Can only edit images
        return indexPath.section == newAircraftSection.sectImages.rawValue && indexPath.row > 0
    }
    
    public override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return String(localized: "Delete", comment: "Title for 'delete' button in image list")
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ci = rgImages[indexPath.row - 1]
            ci.deleteImage(MFBProfile.sharedProfile.AuthToken)
            
            // then remove it from the array
            rgImages.remove(at: indexPath.row - 1)
            var ar = [indexPath]
            // if deleting the last image, we will delete the whole section, so delete the header row too
            if rgImages.isEmpty {
                ar.append(IndexPath(row: 0, section: indexPath.section))
            }
            tableView.deleteRows(at: ar, with: .fade)
            delegate?.aircraftListChanged()
        }
    }
    
    @objc func toggleAnonymous(_ sender : UIButton) {
        
        removeSuggestedAircraft()   // regardless
        
        let rgIp = [IndexPath(row: 0, section: newAircraftSection.sectTail.rawValue)]
        
        if ac.isAnonymous() {
            ac.tailNumber = szTailnumberLast
            tableView.insertRows(at: rgIp, with: .none)
        } else {
            szTailnumberLast = ac.tailNumber
            ac.tailNumber = String(format: "#%06d", ac.modelID.intValue)
            tableView.deleteRows(at: rgIp, with: .none)
        }
        tableView.reloadData()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = cellIDFrom(ip: indexPath)
        
        switch row {
        case .rowModel:
            tableView.endEditing(true)
            let mmView = MakeModel.init(nibName: "MakeModel", bundle: nil)
            mmView.ac = ac
            navigationController?.pushViewController(mmView, animated: true)
        case .rowIsAnonymous:
            break
        case .rowTailnum:
            // Do nothing if this is a sim or anonymous - should never happen
            assert(!ac.isSim() && !ac.isAnonymous());
        case .rowSuggestion:
            let selection = suggestedAircraft[indexPath.row - 1]
            ac.tailNumber = selection.tailNumber
            ac.modelID = selection.modelID
            removeSuggestedAircraft()
            tableView.reloadData()
        case .rowImageHeader:
            if indexPath.row == 0 {
                tableView.endEditing(true)
                toggleSection(indexPath.section)
            } else {
                tableView.endEditing(true)
                let ic = ImageComment(nibName: "ImageComment", bundle: nil)
                ic.ci = rgImages[indexPath.row - 1]
                navigationController?.pushViewController(ic, animated: true)
            }
        case .rowInstanceTypeReal:
            ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft
            tableView.reloadData()
        case .rowInstanceTypeUncertified:
            ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator
            tableView.reloadData()
        case .rowInstanceTypeATD:
            ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD
            tableView.reloadData()
        case .rowInstanceTypeFTD:
            ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator
            tableView.reloadData()
        case .rowInstanceTypeFFS:
            ac.instanceType = MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator
            tableView.reloadData()
        }
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tableView.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        ipActive = self.tableView.indexPath(for: owningCell(textField)!)
        let row = cellIDFrom(ip: ipActive!)
        if row == .rowTailnum {
            let szNew = textField.text?.replacingCharacters(in: Range(range, in: textField.text ?? "")!, with: string)
            let szOriginal = textField.text
            let illegalChars = NSCharacterSet(charactersIn: "0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            
            // disallow disallowed characters
            if let _ = szNew?.rangeOfCharacter(from: illegalChars) {
                return false
            }
            
            ac.tailNumber = szNew?.uppercased()
            
            if ac.tailNumber.replacingOccurrences(of: "-", with: "").count > 2 && szOriginal?.compare(ac.tailNumber, options: .caseInsensitive) != .orderedSame {
                removeSuggestedAircraft()
                let autocomplete = MFBWebServiceSvc_AircraftMatchingPrefix()
                autocomplete.szPrefix = ac.tailNumber
                autocomplete.szAuthToken = MFBProfile.sharedProfile.AuthToken
                
                let sc = MFBSoapCall(delegate: self)
                
                sc.makeCallAsync { b, sc in
                    b.aircraftMatchingPrefixAsync(usingParameters: autocomplete, delegate: sc)
                }
            }
        }
        return true
    }
    
    // MARK: - MFBSoapcall Delegate
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_AircraftMatchingPrefixResponse {
            let rg = resp.aircraftMatchingPrefixResult.aircraft
            if !suggestedAircraft.isEmpty {
                removeSuggestedAircraft()
            }
            addSuggestedAircraft(rg as! [MFBWebServiceSvc_Aircraft])
        }
    }
    
    // MARK: - AccessoryViewDelegate
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        return cellIDFrom(ip: ip) == .rowTailnum && ac.isNew()
    }
    
    // MARK: - Update makes and models
    @objc func updateMakes() {
        let a = Aircraft.sharedAircraft
        a.loadMakeModels()
    }
    
    // MARK: - Commit aircraft
    public override func imagesComplete(_ sc: MFBSoapCall, withCaller ao: MFBAsyncOperation) {
        // Invalidate totals, since this could affect currency (e.g., vor checks)
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
        let a = ao as! Aircraft
        
        let aircraft = Aircraft.sharedAircraft
        
        // And reload user aircraft to pick up the changes, if necessary
        if !(a.rgAircraftForUser ?? []).isEmpty {
            aircraft.rgAircraftForUser = a.rgAircraftForUser
            aircraft.cacheAircraft(a.rgAircraftForUser!, forUser: MFBProfile.sharedProfile.AuthToken)
            aircraftRefreshComplete(sc, withCaller: a)
        }
    }
    
    @IBAction func addAircraft() {
        tableView.endEditing(true)
        var szError = ""
        
        let fIsRealAirplane = !ac.isSim()
        
        if ac.modelID.intValue < 0 {
            szError = String(localized: "Please select a model for the aircraft", comment: "Error: please select a model")
        }
        if fIsRealAirplane && ac.tailNumber.count <= 2 {
            szError = String(localized: "Please specify a valid tailnumber.", comment: "Error: please select a valid tailnumber")
        }
        
        if fIsRealAirplane {
            if !ac.isAnonymous() {
                let cc = CountryCode.BestGuessPrefixForTail(ac.tailNumber)
                if cc != nil && ac.tailNumber.count <= cc!.Prefix.count {
                    szError = String(localized: "Tailnumber has nothing beyond the country code.", comment: "Error: Tailnumber has nothing beyond the country code")
                }
            }
        }
        else {
            ac.tailNumber = Aircraft.PrefixSim
        }
        
        
        if !szError.isEmpty {
            showErrorAlertWithMessage(msg: szError)
            return
        }
        
        progress = WPSAlertController.presentProgressAlertWithTitle(String(localized: "Uploading aircraft data...", comment: "Progress: uploading aircraft data"), onViewController:self)
        
        commitAircraft()
    }
}
