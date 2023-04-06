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
//  AircraftViewControllerBase.swift
//  MyFlightbook
//
//  Created by Eric Berman on 4/4/23.
//

import Foundation

@objc public class AircraftViewControllerBaseSw : CollapsibleTableSw {    
    public var delegate : AircraftViewControllerDelegate? = nil
    public var rgImages : [CommentedImage] = []
    public var vwAccessory : AccessoryBar!
    public var ac = MFBWebServiceSvc_Aircraft()
    public var imagesSection = -1   // invalid value
    public var progress : UIAlertController? = nil
    
    // MARK: - Initialization
    @objc public init(with acIn: MFBWebServiceSvc_Aircraft, delegate d : AircraftViewControllerDelegate?, style: UITableView.Style) {
        super.init(style: style)
        ac = acIn
        delegate = d
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public static func controllerFor(_ ac : MFBWebServiceSvc_Aircraft, delegate d : AircraftViewControllerDelegate?) -> UIViewController {
        return ac.isNew() ? NewAircraftViewController(with: ac, delegate: d) : AircraftViewController(with: ac, delegate: d)
    }
    
    // MARK: - ImageManagement
    public override func addImage(_ ci: CommentedImage) {
        rgImages.append(ci)
        tableView.reloadData()
        if imagesSection >= 0 && !isExpanded(imagesSection) {
            expandSection(imagesSection)
        }
    }
    
    public func imagesComplete(_ sc : MFBSoapCall, withCaller ao : MFBAsyncOperation) {
        fatalError("imagesComplet must be overridden in a subclass")
    }
    
    func aircraftRefreshComplete(_ sc : MFBSoapCall, withCaller a : Aircraft) {
        dismiss(animated: true) {
            if !sc.errorString.isEmpty {
                self.showErrorAlertWithMessage(msg: sc.errorString)
            } else {
                // Notify of a change so that the whole list gets refreshed
                self.delegate?.aircraftListChanged()
                // the add/update was successful, so we can pop the view.  Don't pop the view if the add/update failed.
                self.navigationController?.popViewController(animated: true)
            }
        }
        progress = nil;
    }
    
    public func commitAircraft() {
        if !MFBNetworkManager.shared.isOnLine {
            let sc = MFBSoapCall()
            sc.errorString = String(localized: "No access to the Internet", comment: "Error message if app cannot connect to the Internet")
            aircraftRefreshComplete(sc, withCaller: Aircraft.sharedAircraft)
            return
        }
        
        // Don't upload if we have videos and are not on wifi:
        if !CommentedImage.canSubmitImages(rgImages) {
            let sc = MFBSoapCall()
            sc.errorString = String(localized: "ErrorNeedWifiForVids", comment: "Can't upload with videos unless on wifi")
            aircraftRefreshComplete(sc, withCaller: Aircraft.sharedAircraft)
            return
        }
        
        let a = Aircraft()
        a.setDelegate(self) { sc, ao in
            assert(sc != nil)
            if sc!.errorString.isEmpty {
                let fIsNew = self.ac.isNew()
                let targetURL = fIsNew ? MFBConstants.MFBAIRCRAFTIMAGEUPLOADPAGENEW : MFBConstants.MFBAIRCRAFTIMAGEUPLOADPAGE;
                let key = fIsNew ? self.ac.tailNumber! : self.ac.aircraftID.stringValue
                CommentedImage.uploadImages(self.rgImages,
                                            progressUpdate: { sz in
                    self.progress?.title = sz
                },
                                            toPage: targetURL,
                                            authString: MFBProfile.sharedProfile.AuthToken,
                                            keyName: MFBConstants.MFB_KEYAIRCRAFTIMAGE,
                                            keyValue: key) {
                    self.imagesComplete(sc!, withCaller: ao)
                }
            } else {
                self.aircraftRefreshComplete(sc!, withCaller: ao as! Aircraft)
            }
        }
        a.rgAircraftForUser = nil
        let authtoken = MFBProfile.sharedProfile.AuthToken
        
        if ac.isNew() {
            a.addAircraft(ac, ForUser: authtoken)
        } else {
            a.updateAircraft(ac, ForUser: authtoken)
        }
    }
}
