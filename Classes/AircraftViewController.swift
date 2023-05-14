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
//  AircraftViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/4/23.
//

import Foundation

@objc public class AircraftViewController : AircraftViewControllerBaseSw, UITextFieldDelegate, UITextViewDelegate {
    var datePicker = UIDatePicker()

    enum aircraftSection : Int, CaseIterable {
        case sectInfo = 0, sectFavorite, sectPrefs, sectNotes, sectMaintenance, sectImages
    }
    enum aircraftRow : Int, CaseIterable {
        case rowStaticDesc = 0, rowFavorite, rowPrefsHeader, rowRoleNone, rowRolePIC, rowRoleSIC, rowRoleCFI,
        rowNotesHeader, rowNotesPublic, rowNotesPrivate,
        rowMaintHeader, rowAnnual, rowXPnder, rowPitot, rowAltimeter, rowELT, rowVOR, row100hr, rowOil, rowEngine, rowRegistration, rowMaintNotes,
        rowImageHeader
    }
    
    let rowPrefFirst = aircraftRow.rowPrefsHeader.rawValue
    let rowPrefLast = aircraftRow.rowRoleCFI.rawValue
    let rowMaintFirst = aircraftRow.rowMaintHeader.rawValue
    let rowMaintLast = aircraftRow.rowMaintNotes.rawValue
    let rowNotesFirst = aircraftRow.rowNotesHeader.rawValue
    let rowNotesLast = aircraftRow.rowNotesPrivate.rawValue

    // MARK: - Initialization
    public required init(with acIn: MFBWebServiceSvc_Aircraft, delegate d : AircraftViewControllerDelegate?) {
        super.init(with: acIn, delegate: d, style: .plain)
        imagesSection = aircraftSection.sectImages.rawValue
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datePicker.timeZone = TimeZone(secondsFromGMT: 0)
        delegate = d
        
        assert(!acIn.isNew())
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        vwAccessory = AccessoryBar.getAccessoryBar(self)
        navigationItem.title = ac.tailNumber
        
        // set up for camera/images
        let bbSearch = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(findFlights))
        let bbSchedule = UIBarButtonItem(image: UIImage(named: "schedule"), style: .plain, target: self, action: #selector(viewSchedule))
        let bbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let bbGallery = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImages))
        let bbCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePictures))
        
        bbGallery.isEnabled = canUsePhotoLibrary()
        bbCamera.isEnabled = canUseCamera()
        
        bbGallery.style = .plain
        bbCamera.style = .plain
        bbSearch.style = .plain
        
        toolbarItems = [bbSearch, bbSchedule, bbSpacer, bbGallery, bbCamera]
        
        // Submit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Update", comment: "Update"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(updateAircraft))
        
        // Load any images (in the background) and auto-expand things as necessary
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
        
        // Auto expand any sections as necessary
        collapseAll()
        if !rgImages.isEmpty {
            expandSection(imagesSection)
        }
        if ac.hasMaintenance() {
            expandSection(aircraftSection.sectMaintenance.rawValue)
        }
        if ac.roleForPilot != MFBWebServiceSvc_PilotRole_None {
            expandSection(aircraftSection.sectPrefs.rawValue)
        }
        if !ac.publicNotes.isEmpty || !ac.privateNotes.isEmpty {
            expandSection(aircraftSection.sectNotes.rawValue)
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
        for ci in rgImages {
            ci.flushCachedImage()
        }
        progress = nil
    }
    
    // MARK: - Table view data source
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return aircraftSection.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch aircraftSection(rawValue: section) {
        case .sectInfo:
            return 1
        case .sectFavorite:
            return 1
        case .sectImages:
            return rgImages.isEmpty ? 0 : 1 + (isExpanded(section) ? rgImages.count : 0)
        case .sectPrefs:
            return 1 + (isExpanded(section) ? rowPrefLast - rowPrefFirst : 0)
        case .sectNotes:
            return 1 + (isExpanded(section) ? rowNotesLast - rowNotesFirst : 0)
        case .sectMaintenance:
            // Hide this section if we are new, a sim, or anonymous
            return ac.isSim() || ac.isAnonymous() ? 0 : 1 + (isExpanded(section) ? rowMaintLast - rowMaintFirst : 0)
        case .none:
            fatalError("Invalid section \(section) in AircraftViewController number of rows in section")
        }
    }
    
    func cellIDFromIndexPath(_ ip : IndexPath) -> aircraftRow {
        let row = ip.row
        switch aircraftSection(rawValue: ip.section) {
        case .sectInfo:
            return aircraftRow.rowStaticDesc
        case .sectFavorite:
            return .rowFavorite
        case .sectImages:
            // ALL images are row imageheader since we can't enumerate all possible images
            return .rowImageHeader
        case .sectPrefs:
            return aircraftRow(rawValue: rowPrefFirst + row)!
        case .sectNotes:
            return aircraftRow(rawValue: rowNotesFirst + row)!
        case .sectMaintenance:
            return aircraftRow(rawValue: rowMaintFirst + row)!
        default:
            fatalError("index path \(ip.section)-\(ip.row) in cellIDFromIndexPath for aircraftviewcontroller does not correspond to an enumerated row.")
        }
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let s = aircraftSection(rawValue: indexPath.section)
        return s == .sectImages && indexPath.row > 0 ? 100.0 : (s == .sectNotes && indexPath.row > 0 ? 120.0 : UITableView.automaticDimension)
    }
    
    func utcShortDate(_ dt : Date) -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateStyle = .short
        return df.string(from: dt)
    }
    
    func setDate(_ dt : Date, expiration dtExpiration : Date?, cell ec : EditCell) {
        ec.txt.text = NSDate.isUnknownDate(dt: dt) ? "" : utcShortDate(dt)
        
        if (NSDate.isUnknownDate(dt: dtExpiration)) {
            ec.lblDetail.text = ""
        } else  {
            let fIsExpired = dtExpiration!.compare(Date()) == .orderedAscending;
            ec.lblDetail.text = String(format: fIsExpired ? String(localized: "CurrencyExpired", comment: "Currency Expired format string") : String(localized: "CurrencyValid", comment: "Currency Valid format string"),
                                       utcShortDate(dtExpiration!))
            ec.lblDetail.textColor = fIsExpired ? .systemRed : .secondaryLabel
        }
    }
    
    func updateNext100(_ last100 : NSNumber?, cell ec : EditCell) {
        ec.lblDetail.text = (last100?.doubleValue ?? 0.0) == 0.0 ? "" : String(format: String(localized: "CurrencyValid", comment: "Currency Valid format string"),
                                                                               String(format: "%.1f", last100!.doubleValue + 100.0))
    }
    
    func dateCell(_ dt : Date, prompt szPrompt: String, tableView : UITableView, expiration dtExpiration : Date?) -> EditCell {
        let ec = EditCell.getEditCellDetail(tableView, withAccessory: vwAccessory)
        ec.txt.inputView = datePicker
        ec.txt.placeholder = String(localized: "(Tap for Today)", comment: "Prompt for date that is currently un-set (tapping sets it to TODAY)")
        ec.txt.delegate = self
        ec.lbl.text = szPrompt
        ec.txt.clearButtonMode = .never
        setDate(dt, expiration: dtExpiration, cell: ec)
        return ec
    }
    
    func decimalCell(_ num : NSNumber, prompt szPrompt : String, tableView : UITableView) -> EditCell {
        let ec = EditCell.getEditCellDetail(tableView, withAccessory: vwAccessory)
        ec.txt.autocorrectionType = .no
        ec.txt.setValueWithDefault(num: num, numDefault: 0.0)
        ec.txt.setType(numericType: .Decimal, fHHMM: UserPreferences.current.HHMMPref)
        ec.txt.delegate = self
        ec.lbl.text = szPrompt
        ec.txt.clearButtonMode = .whileEditing
        return ec
    }
    
    func textCell(_ szText : String, prompt szPrompt : String, placeholder szPlaceholder : String, tableView : UITableView) -> EditCell {
        let ec = EditCell.getEditCell(tableView, withAccessory: vwAccessory)
        ec.lbl.text = szPrompt
        ec.txt.text = szText
        ec.txt.placeholder = szPlaceholder
        ec.txt.delegate = self
        ec.txt.clearButtonMode = .whileEditing
        ec.txt.adjustsFontSizeToFitWidth = true
        ec.txt.minimumFontSize = 6.0
        return ec
    }
    
    func multilineTextCell(_ szText : String, prompt szPrompt : String, tableView : UITableView) -> EditCell {
        let ec = EditCell.getEditCellMultiLine(tableView, withAccessory: vwAccessory)
        ec.lbl.text = szPrompt
        ec.txtML.text = szText
        ec.txtML.delegate = self
        return ec
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = cellIDFromIndexPath(indexPath)
        
        switch row {
        case .rowStaticDesc:
            let cellID = "CellStatic"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
            
            let szInstanceTypeDesc = ac.isSim() ? Aircraft.aircraftInstanceTypeDisplay(ac.instanceType) : ""
            cell.selectionStyle = .none
            var config = cell.defaultContentConfiguration()
            config.text = ac.tailNumber
            config.textProperties.adjustsFontSizeToFitWidth = true
            config.secondaryText = "\(ac.modelFullDescription) \(szInstanceTypeDesc)"
            cell.contentConfiguration = config
            return cell
        case .rowMaintHeader, .rowPrefsHeader, .rowNotesHeader:
            var szHeader = ""
            switch (row) {
            case .rowMaintHeader:
                szHeader = String(localized: "Maintenance and Inspections", comment: "Maintenance header")
            case .rowPrefsHeader:
                szHeader = String(localized: "AircraftPrefsHeader", comment: "Aircraft Preferences Header")
            case .rowNotesHeader:
                szHeader = String(localized: "NotesHeader", comment: "Notes Header")
            default:
                break
            }
            return ExpandHeaderCell.getHeaderCell(tableView, withTitle: szHeader, forSection: indexPath.section, initialState: isExpanded(indexPath.section))
        case .rowNotesPrivate:
            return multilineTextCell(ac.privateNotes, prompt: String(localized: "PrivateNotes", comment: "Private Notes"), tableView: tableView)
        case .rowNotesPublic:
            return multilineTextCell(ac.publicNotes, prompt:String(localized: "PublicNotes", comment: "Public Notes"), tableView:tableView)
        case .rowVOR:
            return dateCell(ac.lastVOR, prompt:String(localized: "VOR", comment: "VOR Check"), tableView: tableView, expiration:ac.nextVOR())
        case .rowXPnder:
            return dateCell(ac.lastTransponder, prompt:String(localized: "Transponder", comment: "Transponder"), tableView:tableView, expiration:ac.nextTransponder())
        case .rowPitot:
            return dateCell(ac.lastStatic, prompt: String(localized: "Pitot/Static", comment: "Pitot/Static"), tableView: tableView, expiration: ac.nextPitotStatic())
        case .rowAltimeter:
            return dateCell(ac.lastAltimeter, prompt: String(localized: "Altimeter", comment: "Altimeter"), tableView: tableView, expiration: ac.nextAltimeter())
        case .rowELT:
            return dateCell(ac.lastELT, prompt: String(localized: "ELT", comment: "ELT"), tableView: tableView, expiration: ac.nextELT())
        case .rowAnnual:
            return dateCell(ac.lastAnnual, prompt: String(localized: "Annual", comment: "Annual"), tableView: tableView, expiration: ac.nextAnnual())
        case .rowRegistration:
            // determine whether to show the expiration date
            let dtExpiraton = !NSDate.isUnknownDate(dt: ac.registrationDue) && Date().compare(ac.registrationDue!) == .orderedDescending ? ac.registrationDue : nil
            return dateCell(ac.registrationDue, prompt: String(localized: "RegistrationRenewal", comment: "Date that renewal is required"), tableView: tableView, expiration: dtExpiraton)
        case .row100hr:
            return decimalCell(ac.last100, prompt: String(localized: "100 hour", comment: "100 hour"), tableView: tableView)
        case .rowOil:
            return decimalCell(ac.lastOilChange, prompt: String(localized: "Oil Change", comment: "Oil Change"), tableView: tableView)
        case .rowEngine:
            return decimalCell(ac.lastNewEngine, prompt: String(localized: "New Engine", comment: "New Engine"), tableView: tableView)
        case .rowMaintNotes:
            let tc = textCell("", prompt: String(localized: "MaintenanceNotes", comment: "Maintenance Notes"), placeholder: String(localized: "MaintenanceNotesPrompt", comment: "Maintenance Notes Prompt"), tableView: tableView)
            tc.txt.autocorrectionType = .no
            return tc
        case .rowFavorite:
            let cc = CheckboxCell.getButtonCell(tableView)
            cc.btn.setTitle(String(localized: "ShowAircraft", comment: "Aircraft - Show Aircraft"), for:[])
            cc.btn.setIsCheckbox()
            cc.btn.addTarget(self, action:#selector(toggleVisible), for:.touchUpInside)
            cc.makeTransparent()
            cc.btn.isSelected = !ac.hideFromSelection.boolValue
            return cc
        case .rowRoleNone, .rowRolePIC, .rowRoleSIC, .rowRoleCFI:
            let cellID = "CellStatic"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
            var prompt = ""
            switch (row) {
            case .rowRoleNone:
                cell.accessoryType = ac.roleForPilot == MFBWebServiceSvc_PilotRole_None ? .checkmark : .none
                prompt = String(localized: "RoleNone", comment: "Aircraft Role = None")
            case .rowRolePIC:
                cell.accessoryType = ac.roleForPilot == MFBWebServiceSvc_PilotRole_PIC ? .checkmark : .none
                prompt = String(localized: "RolePIC", comment: "Aircraft Role = PIC")
            case .rowRoleSIC:
                cell.accessoryType = ac.roleForPilot == MFBWebServiceSvc_PilotRole_SIC ? .checkmark : .none
                prompt = String(localized: "RoleSIC", comment: "Aircraft Role = SIC")
            case .rowRoleCFI:
                cell.accessoryType = ac.roleForPilot == MFBWebServiceSvc_PilotRole_CFI ? .checkmark : .none
                prompt = String(localized: "RoleCFI", comment: "Aircraft Role = CFI")
            default:
                break
            }
            var config = cell.defaultContentConfiguration()
            config.text = prompt
            config.textProperties.adjustsFontSizeToFitWidth = true
            cell.contentConfiguration = config
            return cell
        case .rowImageHeader:
            if indexPath.row == 0 { // header row
                return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "Images", comment: "Title for image management screen (where you can add/delete/tap-to-edit images)"), forSection: indexPath.section, initialState: isExpanded(indexPath.section))
            } else {
                let imageIndex = indexPath.row - 1
                assert(imageIndex >= 0 && imageIndex < rgImages.count)
                let ci = rgImages[imageIndex]
                
                let cellID = "cellImage"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
                cell.indentationLevel = 1
                cell.indentationWidth = 10.0
                cell.accessoryType = .disclosureIndicator

                var config = cell.defaultContentConfiguration()
                config.text = ci.imgInfo?.comment ?? ""
                config.textProperties.adjustsFontSizeToFitWidth = true
                config.textProperties.numberOfLines = 3
                if ci.hasThumbnailCache {
                    config.image = ci.GetThumbnail()
                } else {
                    DispatchQueue.global().async {
                        ci.GetThumbnail()
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                cell.contentConfiguration = config
                
                return cell
            }
        }
    }
    
    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // We've disallowed editing of online images for shared aircraft - delete 'em from the website
        // But you should be able to delete a local image you've added and not yet saved
        return indexPath.section == aircraftSection.sectImages.rawValue &&
        indexPath.row > 0 &&
        !(rgImages[indexPath.row - 1].imgInfo?.livesOnServer ?? true)
    }
    
    public override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return String(localized: "Delete", comment: "Title for 'delete' button in image list")
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ci = rgImages[indexPath.row - 1]
            
            assert(!(ci.imgInfo?.livesOnServer ?? true))
            rgImages.remove(at: indexPath.row - 1)
            var ar = [indexPath]
            // if deleting the last image we will delete the whole section, so delete the header row too
            if rgImages.isEmpty {
                ar.append(IndexPath(row: 0, section: indexPath.section))
            }
            tableView.deleteRows(at: ar, with: .fade)
            delegate?.aircraftListChanged()
        }
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return (section == aircraftSection.sectInfo.rawValue) ? String(localized: "WrongModelPrompt", comment: "Prompt to edit model on MyFlightbook.com") : nil
    }
    
    public override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == aircraftSection.sectInfo.rawValue {
            if let header = view as? UITableViewHeaderFooterView {
                var config = header.defaultContentConfiguration()
                config.text = String(localized: "WrongModelPrompt", comment: "Prompt to edit model on MyFlightbook.com")
                config.textProperties.alignment = .center
                config.textProperties.lineBreakMode = .byWordWrapping
                config.textProperties.numberOfLines = 2
                config.textProperties.font = UIFont.preferredFont(forTextStyle: .caption2)
                header.contentConfiguration = config
            }
        }
    }
    
    @objc func toggleVisible(_ sender : UIButton) {
        tableView.endEditing(true)
        ac.hideFromSelection.boolValue = !self.ac.hideFromSelection.boolValue
        tableView.reloadData()
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = cellIDFromIndexPath(indexPath)
        switch row {
        case .rowVOR, .rowXPnder, .rowPitot, .rowAltimeter, .rowELT, .rowAnnual, .row100hr, .rowOil, .rowEngine, .rowRegistration:
            (tableView.cellForRow(at: indexPath) as! EditCell).txt.becomeFirstResponder()
        case .rowMaintNotes:
            (tableView.cellForRow(at: indexPath) as! EditCell).txt.becomeFirstResponder()
        case .rowMaintHeader, .rowPrefsHeader, .rowNotesHeader:
            self.tableView.endEditing(true)
            toggleSection(indexPath.section)
        case .rowImageHeader:
            self.tableView.endEditing(true)
            if (indexPath.row == 0) {
                toggleSection(indexPath.section)
            } else {
                let ic = ImageComment.init(nibName: "ImageComment", bundle: nil)
                ic.ci = rgImages[indexPath.row  - 1]
                navigationController?.pushViewController(ic, animated: true)
            }
        case .rowRoleNone:
            self.tableView.endEditing(true)
            ac.roleForPilot = MFBWebServiceSvc_PilotRole_None
            self.tableView.reloadData()
        case .rowRolePIC:
            self.tableView.endEditing(true)
            ac.roleForPilot = MFBWebServiceSvc_PilotRole_PIC
            self.tableView.reloadData()
        case .rowRoleSIC:
            self.tableView.endEditing(true)
            ac.roleForPilot = MFBWebServiceSvc_PilotRole_SIC
            self.tableView.reloadData()
        case .rowRoleCFI:
            self.tableView.endEditing(true)
            ac.roleForPilot = MFBWebServiceSvc_PilotRole_CFI
            self.tableView.reloadData()
        default:
            break
        }
    }
    
    // MARK: - DatePicker
    @IBAction @objc func dateChanged(_ sender : UIDatePicker) {
        let row = cellIDFromIndexPath(ipActive!)
        let ec = self.tableView.cellForRow(at: ipActive!) as! EditCell
        switch row {
        case .rowAltimeter:
            ac.lastAltimeter = sender.date
            setDate(ac.lastAltimeter, expiration: ac.nextAltimeter(), cell: ec)
        case .rowAnnual:
            ac.lastAnnual = sender.date
            setDate(ac.lastAnnual, expiration: ac.nextAnnual(), cell: ec)
        case .rowELT:
            ac.lastELT = sender.date
            setDate(ac.lastELT, expiration: ac.nextELT(), cell: ec)
        case .rowPitot:
            ac.lastStatic = sender.date
            setDate(ac.lastStatic, expiration: ac.nextPitotStatic(), cell: ec)
        case .rowVOR:
            ac.lastVOR = sender.date
            setDate(ac.lastVOR, expiration: ac.nextVOR(), cell: ec)
        case .rowXPnder:
            ac.lastTransponder = sender.date
            setDate(ac.lastTransponder, expiration: ac.nextTransponder(), cell: ec)
        case .rowRegistration:
            ac.registrationDue = sender.date
            setDate(ac.registrationDue, expiration: nil, cell: ec)
        default:
            break
        }
    }
    
    // MARK: - UITextViewDelegate
    public func textViewDidEndEditing(_ textView: UITextView) {
        let ec = owningCell(textView)!
        let row = cellIDFromIndexPath(tableView.indexPath(for: ec)!)
        switch row {
        case .rowNotesPublic:
            ac.publicNotes = textView.text
        case .rowNotesPrivate:
            ac.privateNotes = textView.text
        default:
            break
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textView)!)
        enableNextPrev(vwAccessory)
        return true
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let ec = owningCell(textField)!
        let row = cellIDFromIndexPath(tableView.indexPath(for: ec)!)
        switch row {
        case .row100hr:
            ac.last100 = textField.getValue()
            updateNext100(textField.getValue(), cell: ec)
        case .rowEngine:
            ac.lastNewEngine = textField.getValue()
        case .rowOil:
            ac.lastOilChange = textField.getValue()
        case .rowMaintNotes:
            ac.maintenanceNote = textField.text
        default:
            break
        }
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func dateClick(_ dt : Date, onInit initializer : (Date, EditCell) -> Void) -> Bool {
        let ec = tableView.cellForRow(at: ipActive!) as! EditCell
        // see if this is a "Tap for today" click - if so, set it to today and resign
        if (ec.txt.text ?? "").isEmpty || NSDate.isUnknownDate(dt: dt) {
            datePicker.date = Date()
            initializer(datePicker.date, ec)
            tableView.endEditing(true)
            return false
        }
        datePicker.date = dt
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textField)!)
        let row = cellIDFromIndexPath(ipActive!)
        enableNextPrev(vwAccessory)
        vwAccessory.btnDelete.isEnabled = true
        
        // If this was a picker-tied edit cell, set up the picker correctly
        switch row {
        case .rowAltimeter:
            return dateClick(ac.lastAltimeter) { d, ec in
                ac.lastAltimeter = d
                setDate(d, expiration: ac.nextAltimeter(), cell: ec)
            }
        case .rowAnnual:
            return dateClick(ac.lastAnnual) { d, ec in
                ac.lastAnnual = d
                setDate(d, expiration: ac.nextAnnual(), cell: ec)
            }
        case .rowELT:
            return dateClick(ac.lastELT) { d, ec in
                ac.lastELT = d
                setDate(d, expiration: ac.nextELT(), cell: ec)
            }
        case .rowPitot:
            return dateClick(ac.lastStatic) { d, ec in
                ac.lastStatic = d
                setDate(d, expiration: ac.nextPitotStatic(), cell: ec)
            }
        case .rowVOR:
            return dateClick(ac.lastVOR) { d, ec in
                ac.lastVOR = d
                setDate(d, expiration: ac.nextVOR(), cell: ec)
            }
        case .rowXPnder:
            return dateClick(ac.lastTransponder) { d, ec in
                ac.lastTransponder = d
                setDate(d, expiration: ac.nextTransponder(), cell: ec)
            }
        case .rowRegistration:
            return dateClick(ac.registrationDue) { d, ec in
                ac.registrationDue = d
                setDate(d, expiration: d, cell: ec)
            }
        default:
            break
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tableView.endEditing(true)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        ipActive = tableView.indexPath(for: owningCell(textField)!)
        let row = cellIDFromIndexPath(ipActive!)
        switch row {
        case .rowOil, .rowEngine, .row100hr:
            return textField.isValidNumber(szProposed: ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string))
        default:
            break
        }
        return true
    }
    
    // MARK: - AccessoryViewDelegate
    public override func deleteClicked() {
        super.deleteClicked()
        switch (cellIDFromIndexPath(ipActive!)){
        case .rowAnnual, .rowAltimeter, .rowXPnder, .rowELT, .rowVOR, .rowPitot, .rowRegistration:
            tableView.endEditing(true)
            datePicker.date = Date.distantPast
            dateChanged(datePicker)
        default:
            break
        }
    }
    
    public override func isNavigableRow(_ ip: IndexPath) -> Bool {
        switch cellIDFromIndexPath(ip) {
        case .rowAnnual:
            return !NSDate.isUnknownDate(dt: ac.lastAnnual)
        case .rowAltimeter:
            return !NSDate.isUnknownDate(dt: ac.lastAltimeter)
        case .rowXPnder:
            return !NSDate.isUnknownDate(dt: ac.lastTransponder)
        case .rowELT:
            return !NSDate.isUnknownDate(dt: ac.lastELT)
        case .rowVOR:
            return !NSDate.isUnknownDate(dt: ac.lastVOR)
        case .rowPitot:
            return !NSDate.isUnknownDate(dt: ac.lastStatic)
        case .rowRegistration:
            return !NSDate.isUnknownDate(dt: ac.registrationDue)
        case .rowNotesPrivate, .rowNotesPublic, .rowOil, .rowEngine, .row100hr:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Find Flights
    @objc func findFlights(_ sender : Any) {
        if !MFBNetworkManager.shared.isOnLine {
            return
        }
        
        let fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        fq.aircraftList.add(ac)
        
        navigationController?.pushViewController(RecentFlights.viewForFlightsMatching(query: fq), animated: true)
    }
    
    // MARK: - View Schedule
    @objc func viewSchedule(_ sender : Any) {
        let szURL = MFBProfile.sharedProfile.authRedirForUser(params: String(format:"d=aircraftschedule&naked=1&ac=%d", ac.aircraftID.intValue))
        navigationController?.pushViewController(HostedWebViewController(url: szURL), animated: true)
    }
    
    // MARK: - Commit Aircraft
    public override func imagesComplete(_ sc: MFBSoapCall, withCaller ao: MFBAsyncOperation) {
        // Invalidate totals, since this could affect currency (e.g., vor checks)
        MFBAppDelegate.threadSafeAppDelegate.invalidateCachedTotals()
        
        let aircraft = Aircraft.sharedAircraft

        // And reload user aircraft to pick up the changes, if necessary
        aircraft.setDelegate(self) { sc, ao in
            self.aircraftRefreshComplete(sc!, withCaller: ao as! Aircraft)
        }
        aircraft.loadAircraftForUser(true)  // force a refresh attempt
    }
    
    @IBAction @objc func updateAircraft() {
        tableView.endEditing(true)
        progress = WPSAlertController.presentProgressAlertWithTitle(String(localized: "Updating aircraft...", comment: "Progress: updating aircraft"), onViewController:self)
        commitAircraft()
    }
}
