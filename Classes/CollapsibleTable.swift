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
//  CollapsibleTable.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation
import Photos

/// Swift version of the CollapsibleTable class
/// MUST coexist with CollapsibleTable during swift transition because it relies on Swift protocols/classes
/// Since objc-classes can't inherit from a swift class, we can't migrate child classes unless/until
/// this is migrated without including collapsibletable.h in the bridging header, but if we do that, we get
/// circular references.
/// So this will duplicate the objc class, and swift classes can inherit from this.
/// We will do the same for pullrefreshtableviewcontroller

public class CollapsibleTableSw : UITableViewController, UIImagePickerControllerDelegate, AccessoryBarDelegate, Invalidatable, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    public var expandedSections : Set<Int> = []
    public var ipActive : IndexPath? = nil
    public var fIsValid = false
    public var defSectionHeaderHeight : CGFloat = 1
    public var defSectionFooterHeight : CGFloat = 1
    
    private var fSelectActiveSelOnScrollCompletion = false
    private var fSelectFirst = false
    
    // MARK: Lifecycle
    // No need to do viewdidload/etc since all initialization is done above
    
    // MARK: Misc ViewController
    public override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    public func reload() {
        tableView.reloadData()
    }
    
    // MARK: Expand/collapse support
    public func collapseSection(_ section : Int, table tv : UITableView) {
        if !isExpanded(section) {
            return
        }
        
        let oldRowCount = tableView(tv, numberOfRowsInSection: section)
        expandedSections.remove(section)
        
        // cellforrow can return nil if the cell isn't visible yet, which might be true in viewDidLoad
        let cell = tv.cellForRow(at: IndexPath(row: 0, section: section)) as? ExpandHeaderCell
        cell?.setExpanded(false)
        
        var rg : [IndexPath] = []
        for i in 1..<oldRowCount {
            rg.append(IndexPath(row: i, section: section))
        }
        tv.deleteRows(at: rg.reversed(), with: .top)
    }
    
    public func expandSection(_ section : Int, table tv : UITableView) {
        if isExpanded(section) {
            return
        }

        expandedSections.insert(section)

        // cellforrow can return nil if the cell isn't visible yet, which might be true in viewDidLoad
        let cell = tv.cellForRow(at: IndexPath(row: 0, section: section)) as? ExpandHeaderCell
        cell?.setExpanded(true)
        
        let newRowCount = tableView(tv, numberOfRowsInSection: section)
        var rg : [IndexPath] = []
        for i in 1..<newRowCount {
            rg.append(IndexPath(row: i, section: section))
        }
        tv.insertRows(at: rg, with: .top)
    }
    
    @objc public func toggleSection(_ section : Int, forTable tableView : UITableView) {
        if expandedSections.contains(section) {
            collapseSection(section, table: tableView)
        } else {
            expandSection(section, table: tableView)
        }
    }
    
    public func collapseSection(_ section : Int) {
        collapseSection(section, table: tableView)
    }
    
    public func expandSection(_ section : Int) {
        expandSection(section, table: tableView)
    }
    
    public func toggleSection(_ section : Int) {
        toggleSection(section, forTable: tableView)
    }
    
    public func isExpanded(_ section : Int) -> Bool {
        return expandedSections.contains(section)
    }
    
    public func collapseAll() {
        expandedSections.removeAll()
    }
    
    public func expandAll(_ tableView : UITableView) {
        let cSections = tableView.numberOfSections
        for i in 0..<cSections {
            expandedSections.insert(i)
        }
    }
    
    // MARK: Basic Accessorybar Delegate Support
    public func owningCellGeneric(_ vw : UIView) -> UITableViewCell? {
        var v : UIView? = vw
        while v != nil {
            v = v!.superview
            if let cell = v as? UITableViewCell {
                return cell
            }
        }
        return nil
    }
    
    public func owningCell(_ vw : UIView) -> EditCell? {
        var v : UIView? = vw
        while v != nil {
            v = v!.superview
            if let cell = v as? EditCell {
                return cell
            }
        }
        return nil
    }
    
    public func isNavigableRow(_ ip : IndexPath) -> Bool {
        // this should be overridden
        return false
    }
    
    func nextNavCell(_ ipIn : IndexPath?) -> IndexPath? {
            if ipIn == nil {
            return nil
        }
        var ip = ipIn!
        
        var ipNext = nextCell(ipCurrent: ip)
        while ipNext.row != ip.row || ipNext.section != ip.section {
            if isNavigableRow(ipNext) {
                return ipNext
            }
            ip = ipNext
            ipNext = nextCell(ipCurrent: ip)
        }
        return nil
    }
    
    func prevNavCell(_ ipIn : IndexPath?) -> IndexPath? {
        if ipIn == nil {
            return nil
        }
        var ip = ipIn!
        
        var ipPrev = prevCell(ipCurrent: ip)
        while ipPrev.row != ip.row || ipPrev.section != ip.section {
            if isNavigableRow(ipPrev) {
                return ipPrev
            }
            ip = ipPrev
            ipPrev = prevCell(ipCurrent: ip)
        }
        return nil
    }
    
    func canNext() -> Bool {
        return nextNavCell(ipActive) != nil
    }
    
    func canPrev() -> Bool {
        return prevNavCell(ipActive) != nil
    }
    
    public func enableNextPrev(_ vwAccesory : AccessoryBar) {
        vwAccesory.btnNext.isEnabled = canNext()
        vwAccesory.btnPrev.isEnabled = canPrev()
    }
    
    public override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if fSelectActiveSelOnScrollCompletion && ipActive != nil {
            if let cell = tableView.cellForRow(at: ipActive!) {
                if let nc = cell as? NavigableCell {
                    let resp = fSelectFirst ? nc.firstResponderControl : nc.lastResponderControl
                    if resp?.canBecomeFirstResponder ?? false {
                        resp?.becomeFirstResponder()
                    }
                }
            }
        }
        fSelectActiveSelOnScrollCompletion = false
    }
    
    public func navigateToActiveCell() {
        if ipActive == nil {
            return
        }
        fSelectActiveSelOnScrollCompletion = true
        tableView.scrollToRow(at: ipActive!, at: .middle, animated: true)
        // Scrolling MIGHT NOT happen if the cell is visible.
        // So test to see if the tableview already has it.  If so, we can call scrollViewDidEndScrollingAnimation ourselves
        if tableView.cellForRow(at: ipActive!) != nil {
            scrollViewDidEndScrollingAnimation(tableView)
        }
    }
    
    public func nextClicked() {
        if let ipNext = nextNavCell(ipActive) {
            NSLog("Navigating from %d,%d to %d,%d", ipActive!.section,  ipActive!.row,  ipNext.section, ipNext.row)
            ipActive = ipNext
            fSelectFirst = true
            navigateToActiveCell()
        }
    }
    
    public func prevClicked() {
        if let ipPrev = prevNavCell(ipActive) {
            NSLog("Navigating from %d,%d to %d,%d", ipActive!.section,  ipActive!.row,  ipPrev.section, ipPrev.row)
            ipActive = ipPrev
            fSelectFirst = false
            navigateToActiveCell()
        }
    }
    
    public func doneClicked() {
        tableView.endEditing(true)
    }
    
    public func deleteClicked() {
        if ipActive != nil, let ec = tableView.cellForRow(at: ipActive!) as? EditCell {
            ec.txt?.text = ""
            ec.txtML?.text = ""
        }
    }
    
    // Issue #284 - trap any physical keyboard tab events.
    public override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if press.key?.keyCode == .keyboardTab {
                if (press.key?.modifierFlags == .shift) {
                    if canPrev() {
                        prevClicked()
                    }
                }
                else {
                    if canNext() {
                        nextClicked()
                    }
                }
                return
            }
        }
        super.pressesBegan(presses, with: event)
    }
    
    // MARK: Camera support
    public func canUseCamera() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    // TODO: Migrate to PHPicker from UIImagePicker?
    public func canUsePhotoLibrary() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    func addImages(_ usingCamera : Bool, fromButton btn: UIBarButtonItem?) {
        let imgView = UIImagePickerController()
        imgView.delegate = self
        
        let fIsCameraAvailable = canUseCamera()
        let fIsGalleryAvailable = canUsePhotoLibrary()
        if usingCamera && !fIsCameraAvailable || !usingCamera && !fIsGalleryAvailable {
            return
        }
        
        imgView.sourceType = usingCamera && fIsCameraAvailable ? .camera : .photoLibrary
        imgView.mediaTypes = UIImagePickerController.availableMediaTypes(for: imgView.sourceType) ?? []
        
        imgView.modalPresentationStyle = .popover
        let ppc = imgView.popoverPresentationController
        ppc?.barButtonItem = btn
        ppc?.delegate = self
        present(imgView, animated: true)
    }
    
    @IBAction public func pickImages(_ sender : Any) {
        // Request permission so that we can get geotag
        // Technically not required, so we'll call addImages regardless.
        let status = PHPhotoLibrary.authorizationStatus()
        switch (status) {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.addImages(false, fromButton: sender as? UIBarButtonItem)
                    }
                }
            }
            case .denied, .restricted, .limited:
                break
        case .authorized:
            addImages(false, fromButton: sender as? UIBarButtonItem)
        default:
            break
        }
    }
    
    @IBAction public func takePictures(_ sender : Any) {
        addImages(true, fromButton: sender as? UIBarButtonItem)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func stopPickingPictures() {
        dismiss(animated: true)
        tableView.reloadData()
    }
    
    public func addImage(_ ci : CommentedImage) {
        fatalError("addImage called directly on CollapsibleTable - Should be subclassed")
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let szType = info[.mediaType] as? String
                
        let fImage = szType == UTType.image.identifier
        let fVideo = szType == UTType.movie.identifier
        let fCamera = picker.sourceType == .camera
        if (fImage || fVideo) {
            var loc : CLLocation? = nil
            if !fCamera {
                // Get the location of the library image
                if let thisPhoto = info[.phAsset] as? PHAsset {
                    loc = thisPhoto.location
                }
            }
            
            let ci = CommentedImage()
            if (fImage) {
                if !fCamera && loc != nil {
                    ci.imgInfo?.location = MFBWebServiceSvc_LatLong(coord: loc!.coordinate)
                }
                
                if let img = info[.originalImage] as? UIImage {
                    ci.SetImage(img, fromCamera: fCamera, withMetaData: info)
                }
            } else if (fVideo) {
                ci.SetVideo(info[.mediaURL] as! URL, fromCamera: fCamera)
            }
            
            addImage(ci)
            stopPickingPictures()
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        stopPickingPictures()
    }
    
    // MARK: UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            tableView.reloadData()
        }
    }
    
    // MARK: Background image
    public func setBackground(_ szImageName : String) {
        tableView.backgroundView = UIImageView(image: UIImage(named: szImageName))
        tableView.backgroundView?.contentMode = .topLeft
    }
    
    // MARK: iOS7 hacks
    // Reduce the space between sections.
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sz = self.tableView(tableView, titleForFooterInSection:section) ?? ""
        
        if tableView == tableView && !sz.isEmpty {
            let h = (sz as NSString).boundingRect(with: CGSizeMake(self.tableView.frame.size.width - 20, 10000),
                                                  options:.usesLineFragmentOrigin,
                                                  attributes: [.font : UIFont.systemFont(ofSize: 22.0)],
                                                  context: nil).size.height
            return ceil(h)
        }
        return defSectionFooterHeight
    }
    
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sz = self.tableView(tableView, titleForHeaderInSection:section) ?? ""
        
        if tableView == tableView && !sz.isEmpty {
            let h = (sz as NSString).boundingRect(with: CGSizeMake(self.tableView.frame.size.width - 20, 10000),
                                                  options:.usesLineFragmentOrigin,
                                                  attributes: [.font : UIFont.systemFont(ofSize: 22.0)],
                                                  context: nil).size.height
            return ceil(h)
        }
        return defSectionHeaderHeight
    }
    
    // MARK: Invalidate (for sign-out)
    public func invalidateViewController() {
        fatalError("invalidatedViewController called directly on CollapsibleTable - Should be subclassed")
    }
}
 
