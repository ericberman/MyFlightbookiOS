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
//  OptionSelection.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

import Foundation

@objc public class OptionSelection : NSObject {
    @objc public let title : String
    @objc public let optionKey : String
    @objc public let rgOptions : [String]
        
    @objc(initWithTitle:forOptionKey:options:) init(szTitle : String, key : String, options : [String]) {
        title = szTitle
        optionKey = key
        rgOptions = options
        super.init()
    }
    
    @objc public func selectedIndex() -> Int {
        return UserDefaults.standard.integer(forKey: optionKey)
    }
    
    @objc(setOptionToIndex:) public func setOptionToIndex(index : Int) {
        UserDefaults.standard.setValue(index, forKey: optionKey)
    }
}
