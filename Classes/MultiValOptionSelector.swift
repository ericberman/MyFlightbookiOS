/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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
//  MultiValOptionSelector.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

import Foundation

@objc public class MultiValOptionSelector : UITableViewController {
    @objc public var optionGroups : [OptionSelection] = []
    
    public init() {
        super.init(style: UITableView.Style.grouped)
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        UserPreferences .invalidate()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return optionGroups.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionGroups[section].rgOptions.count
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return optionGroups[section].title
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "CellCheckmark"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .default, reuseIdentifier: cellID)
        
        let os = optionGroups[indexPath.section]
        cell.textLabel?.text = os.rgOptions[indexPath.row]
        cell.accessoryType = (indexPath.row == os.selectedIndex()) ? .checkmark : .none
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let os = optionGroups[indexPath.section]
        os.setOptionToIndex(index: indexPath.row)
        tableView.reloadData()
    }
}
