/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2024 MyFlightbook, LLC
 
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
//  MyAircraft.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/1/23.
//

import Foundation

public class MyAircraft : PullRefreshTableViewControllerSW, AircraftViewControllerDelegate {
    var _dictImagesForAircraft : [NSNumber : CommentedImage] = [:]
    let dictLock = NSLock()
    var rgFavoriteAircraft : [MFBWebServiceSvc_Aircraft] = []
    var rgArchivedAircraft : [MFBWebServiceSvc_Aircraft] = []
    var fNeedsRefresh = false
    
    let hasRefreshedSinceSwiftConversionKey = "keyHasRefreshed"
    
    enum aircraftSections : Int, CaseIterable {
        case sectFavorites = 0
        case sectArchived = 1
    }
        
    // MARK: - Thread safe dictionary utilities
    // Non of these functions make any calls that can result in another one being called, so there should be no thread contention/deadlock.
    func imageForAircraft(_ num : NSNumber) -> CommentedImage? {
        dictLock.lock()
        let result = _dictImagesForAircraft[num]
        dictLock.unlock()
        return result
    }
    
    func cacheImage(_ ci : CommentedImage, for aircraftID : NSNumber) {
        dictLock.lock()
        _dictImagesForAircraft[aircraftID] = ci
        dictLock.unlock()
    }
    
    func clearImageCache() {
        dictLock.lock()
        _dictImagesForAircraft.removeAll()
        dictLock.unlock()
    }
    
    var hasCachedImages : Bool {
        get {
            dictLock.lock()
            let result = !_dictImagesForAircraft.isEmpty
            dictLock.unlock()
            return result
        }
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newAircraft))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        initAircraftLists()

        MFBAppDelegate.threadSafeAppDelegate.registerNotifyResetAll(self)
        
        if !UserDefaults.standard.bool(forKey: hasRefreshedSinceSwiftConversionKey) {
            fNeedsRefresh = true
            UserDefaults.standard.set(true, forKey: hasRefreshedSinceSwiftConversionKey)
        }
        
        tableView.rowHeight = 86
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = true
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        if !hasCachedImages {
            loadThumbnails()
        }
        
        if fNeedsRefresh && !MFBProfile.sharedProfile.AuthToken.isEmpty {
            refresh()
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        clearImageCache()
    }
    
    // MARK: - Tableview data source delegate
    var hasFavoriteAircraft : Bool {
        get {
            return !rgArchivedAircraft.isEmpty
        }
    }
    
    func aircraftAt(indexPath ip : IndexPath) -> MFBWebServiceSvc_Aircraft {
        // forced unwrapping below had better work - why would we have an indexpath that hasn't already been produced from the existance of an aircraft in a non-nil array?
        if hasFavoriteAircraft {
            return aircraftSections(rawValue: ip.section) == .sectFavorites ? rgFavoriteAircraft[ip.row] : rgArchivedAircraft[ip.row]
        } else {
            return Aircraft.sharedAircraft.rgAircraftForUser![ip.row]
        }
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return callInProgress ? 1 : (hasFavoriteAircraft ? aircraftSections.allCases.count : 1)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callInProgress ? 1 : (hasFavoriteAircraft && aircraftSections(rawValue: section) == .sectArchived ? rgArchivedAircraft.count : rgFavoriteAircraft.count)
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AircraftCellID"
        
        if self.callInProgress {
            return waitCellWithText(String(localized: "Retrieving aircraft list...", comment: "status message while retrieving user aircraft"))
        }
        
        let cell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? FixedImageCell ?? FixedImageCell.getFixedImageCell(tableView))
        
        cell.accessoryType = .disclosureIndicator;
        
        let ac = aircraftAt(indexPath: indexPath)

        let textSizeLabel = cell.lblMain.font.pointSize
        let textSizeDetail = textSizeLabel * 0.8
        
        let baseFont = UIFont.systemFont(ofSize: textSizeDetail)
        let boldFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitBold)!, size: textSizeLabel)
        let italicFont = UIFont(descriptor: baseFont.fontDescriptor.withSymbolicTraits(.traitItalic)!, size: textSizeDetail)
        let colorMain = UIColor.label
        let colorNotes = UIColor.secondaryLabel
        

        let szTail = NSMutableAttributedString(string: ac.isAnonymous() ? "" : ac.displayTailNumber, attributes: [.font : boldFont, .foregroundColor : colorMain])
        szTail.append(NSAttributedString(string: " " + "\(ac.modelFullDescription) \(ac.isSim() ? "\(Aircraft.aircraftInstanceTypeDisplay(ac.instanceType)) " : "")".trimmingCharacters(in: .whitespaces),
                                         attributes: [.font : italicFont, .foregroundColor : colorMain]))
        szTail.append(NSAttributedString(string: " " + "\(ac.privateNotes ?? "") \(ac.publicNotes ?? "")".trimmingCharacters(in: .whitespaces), attributes: [.font : baseFont, .foregroundColor : colorNotes]))

        cell.lblMain.attributedText = szTail
        

        let ci = imageForAircraft(ac.aircraftID)
        let opacity = ac.hideFromSelection.boolValue ? 0.5 : 1.0
        cell.lblMain.alpha = opacity
        cell.imgView.alpha = opacity
        cell.imgView.image = ((ci?.hasThumbnailCache ?? false) ? ci!.GetThumbnail() : nil) ?? UIImage(named: "noimage")
        
        return cell;
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if Aircraft.sharedAircraft.rgAircraftForUser?.isEmpty ?? true {
            return String(localized: "No aircraft found.  You can add one above.", comment: "No aircraft found")
        }
        
        if callInProgress {
            return ""
        }
        
        if self.hasFavoriteAircraft {
            switch aircraftSections(rawValue: section) {
            case .sectFavorites:
                return String(localized: "Frequently Used Aircraft", comment: "Frequently Used Aircraft Header")
            case .sectArchived:
                return String(localized: "Archived Aircraft", comment: "Archived Aircraft Header")
            case .none:
                return nil
            }
        }
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !callInProgress && !isLoading {
            MyAircraft.viewAircraft(aircraftAt(indexPath: indexPath), on: navigationController, delegate: self)
        }
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return MFBNetworkManager.shared.isOnLine && MFBProfile.sharedProfile.isValid()
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && MFBNetworkManager.shared.isOnLine && !callInProgress {
            startCall()
            let a = Aircraft.sharedAircraft
            a.setDelegate(self) { sc, ao in
                self.refreshCompleted(sc)
            }
            a.deleteAircraft(aircraftAt(indexPath: indexPath).aircraftID, forUser: MFBProfile.sharedProfile.AuthToken)
        }
    }
        
    // MARK: - Viewing aircraft details
    static func viewAircraft(_ ac : MFBWebServiceSvc_Aircraft, on nc : UINavigationController?, delegate d : AircraftViewControllerDelegate?) {
        if !MFBProfile.sharedProfile.isValid() {
            nc?.showErrorAlertWithMessage(msg: String(localized: "You must be signed in to create an aircraft", comment: "Must be signed in to create an aircraft"))
            return
        }
        
        nc?.pushViewController(AircraftViewControllerBaseSw.controllerFor(ac, delegate: d), animated: true)
    }
    
    @objc func newAircraft() {
        if !MFBProfile.sharedProfile.isValid() {
            navigationController?.showErrorAlertWithMessage(msg: String(localized: "You must be signed in to create an aircraft", comment: "Must be signed in to create an aircraft"))
            return
        }

        if MFBNetworkManager.shared.isOnLine && MFBProfile.sharedProfile.isValid() {
            MyAircraft.viewAircraft(MFBWebServiceSvc_Aircraft.getNewAircraft(), on: navigationController, delegate: self)
        }
    }
    
    @objc public static func pushNewAircraftOnViewController(_ nav : UINavigationController) {
        if MFBNetworkManager.shared.isOnLine && MFBProfile.sharedProfile.isValid() {
            MyAircraft.viewAircraft(MFBWebServiceSvc_Aircraft.getNewAircraft(), on: nav, delegate: nil)
        }
    }

    // MARK: - Refreshing
    func refreshCompleted(_ sc : MFBSoapCall?) {
        if !Aircraft.sharedAircraft.errorString.isEmpty {
            showErrorAlertWithMessage(msg: Aircraft.sharedAircraft.errorString)
        }
        
        endCall()
        if isLoading {
            stopLoading()
        }
        
        initAircraftLists()
        loadThumbnails()
        tableView.reloadData()
    }
    
    public override func refresh() {
        if !MFBNetworkManager.shared.isOnLine {
            if isLoading {
                stopLoading()
            }
            return
        }
        
        fNeedsRefresh = false
        if callInProgress {
            return
        }
        
        startCall()
        let ac = Aircraft.sharedAircraft
        ac.setDelegate(self) { sc, ao in
            self.refreshCompleted(sc)
        }
        ac.loadAircraftForUser(true)    // refresh = force a load, potentially updating cache
    }
    
    // MARK: - Invalidatable
    public override func invalidateViewController() {
        Aircraft.sharedAircraft.clearAircraft()
        initAircraftLists()
        fNeedsRefresh = true
        if Thread.isMainThread {
            tableView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: AircraftViewDelegate
    @objc public func aircraftListChanged() {
        initAircraftLists()
    }
    
    // MARK: - Thumbnails
    func loadThumbnails() {
        let a = Aircraft.sharedAircraft
        let rgAc = a.rgAircraftForUser ?? []
        
        if rgAc.isEmpty {
            return  // don't bother with the dispatching below or caching results
        }
        
        DispatchQueue.global(qos: .background).async {
            for ac in rgAc {
                let rgmfb = ac.aircraftImages.mfbImageInfo as! [MFBWebServiceSvc_MFBImageInfo]
                if rgmfb.isEmpty {
                    continue
                }
                let ci = CommentedImage()
                // get the default image, if present, otherwise take the first image
                ci.imgInfo = (ac.defaultImage ?? "").isEmpty ? rgmfb[0] : rgmfb.first(where: { mfbii in
                    mfbii.thumbnailFile.compare(ac.defaultImage, options: .caseInsensitive) == .orderedSame
                }) ?? rgmfb[0]
                
                // get the thumbnail on a background queue
                ci.GetThumbnail()
                self.cacheImage(ci, for: ac.aircraftID)
                
                if (ci.imgInfo != nil) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            // Cache the images, but only once we've loaded all of them.
            a.cacheAircraft(rgAc, forUser: MFBProfile.sharedProfile.AuthToken)
        }
    }
    
    func initAircraftLists() {
        clearImageCache()
        rgArchivedAircraft.removeAll()
        rgFavoriteAircraft.removeAll()
        
        let rgAc = (Aircraft.sharedAircraft.rgAircraftForUser) ?? []
        for ac in rgAc {
            if ac.hideFromSelection.boolValue {
                rgArchivedAircraft.append(ac)
            } else {
                rgFavoriteAircraft.append(ac)
            }
        }
    }
}
