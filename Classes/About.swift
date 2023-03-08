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
//  About.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/8/23.
//

import Foundation

@objc public class about : UIViewController {
    @IBOutlet @objc var lblAbout : UILabel?
    @IBOutlet @objc var lblDetails : UILabel?
    @IBOutlet @objc var lblDetailedText : UITextView?

    public override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        lblAbout?.text = String(format: "%@%@", lblAbout?.text ?? "", " - DEBUG VERSION")
        #endif
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        lblDetails?.text = String(format: "%@, %@",
                                  MFBHOSTNAME,
                                  bundleVersion ?? "")
        lblDetailedText?.text = String(localized: "AboutMyFlightbook", comment: "About MyFlightbook")
    }
}
