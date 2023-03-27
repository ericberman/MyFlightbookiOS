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
//  AccessoryBar.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/26/23.
//

import Foundation

@objc public protocol AccessoryBarDelegate {
    func nextClicked()
    func prevClicked()
    func deleteClicked()
    func doneClicked()
}

@objc public class AccessoryBar : UIToolbar, AccessoryBarDelegate {
    @IBOutlet weak var btnNext : UIBarButtonItem!
    @IBOutlet weak var btnPrev : UIBarButtonItem!
    @IBOutlet weak var btnDelete : UIBarButtonItem!
    @IBOutlet weak var btnDone : UIBarButtonItem!
    
    private var abDelegate : AccessoryBarDelegate? = nil
    
    // MARK: AccessoryBarDelegate methods
    @IBAction public func nextClicked() {
        abDelegate?.nextClicked()
    }
    
    @IBAction public func prevClicked() {
        abDelegate?.prevClicked()
    }
    
    @IBAction public func deleteClicked() {
        abDelegate?.deleteClicked()
    }
    
    @IBAction public func doneClicked() {
        abDelegate?.doneClicked()
    }
    
    @objc public static func getAccessoryBar(_ d : AccessoryBarDelegate) -> AccessoryBar? {
        let ar = Bundle.main.loadNibNamed("AccessoryBar", owner: self)
        for obj in ar ?? [] {
            if let ab = obj as? AccessoryBar {
                ab.abDelegate = d
                return ab
            }
        }
        return nil
    }
}
