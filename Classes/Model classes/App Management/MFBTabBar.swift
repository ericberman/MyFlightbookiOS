/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2025 MyFlightbook, LLC
 
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
//  MFBTabBar.swift
//  MFBSample
//
//  Created by Eric Berman on 9/21/25.
//

public class MFBTabBarController: UITabBarController {

    @IBOutlet var leMain : UITableViewController!
    @IBOutlet var tabNewFlight : UINavigationController!
    @IBOutlet var tabRecents : UINavigationController!
    @IBOutlet var tabProfile : UINavigationController!
    @IBOutlet var tabTotals : UINavigationController!
    @IBOutlet var tabCurrency : UINavigationController!
    @IBOutlet var tbiRecent : UITabBarItem!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any tab bar setup that used to live in AppDelegate
    }
}
