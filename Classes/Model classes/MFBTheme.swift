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
//  MFBTheme.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/21/23.
//

import Foundation

@objc class MFBTheme : NSObject {
    @objc public static func isDarkMode() -> Bool {
        return UITraitCollection.current.userInterfaceStyle == .dark
    }
    
    static let _mfbColor = UIColor(red: 0, green: 0.73725, blue: 0.831372, alpha: 1)

    @objc public static func MFBBrandColor() -> UIColor {
        return _mfbColor
    }

    @objc(applyThemedImageNamed: toImageView:) public static func applyThemedImage(name: NSString?, imgView: UIImageView?) -> Void {
        if (name != nil) {
            imgView?.image = UIImage(named: name! as String)?.withRenderingMode(.alwaysTemplate)
            imgView?.tintColor = MFBTheme.MFBBrandColor()
        }
    }
    
    public static func addThemedImageToCellConfig(name: String, config: inout UIListContentConfiguration) {
        config.image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
        config.imageProperties.tintColor = MFBBrandColor()
    }
        
    @objc public static func setMFBTheme() -> Void {
        UITabBar.appearance().tintColor = _mfbColor
        UIToolbar.appearance().tintColor = _mfbColor
        UIButton.appearance().tintColor = _mfbColor
        UISegmentedControl.appearance().tintColor = _mfbColor
        UIButton.appearance().setTitleColor(_mfbColor, for: .normal)
        UIButton.appearance().setTitleColor(_mfbColor, for: .selected)
        UIButton.appearance().setTitleColor(_mfbColor, for: .highlighted)
        UISegmentedControl.appearance().selectedSegmentTintColor = _mfbColor

        // Bleah - fucking Apple introducing breaking changes.
        // With iOS 15, the top is black until you scroll.  Pathetically lame.
        // https://stackoverflow.com/questions/69111478/ios-15-navigation-bar-transparent
        let app = UINavigationBarAppearance()
        app.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = app
        UINavigationBar.appearance().scrollEdgeAppearance = app
        let tba = UIToolbarAppearance()
        tba.configureWithOpaqueBackground()
        UIToolbar.appearance().standardAppearance = tba
        UIToolbar.appearance().scrollEdgeAppearance = tba
        let tabapp = UITabBarAppearance()
        tabapp.configureWithOpaqueBackground()
        UITabBar.appearance().standardAppearance = tabapp
        UITabBar.appearance().scrollEdgeAppearance = tabapp
        
        UISwitch.appearance().onTintColor = _mfbColor
    }
}
