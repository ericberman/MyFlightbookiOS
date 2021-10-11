/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018-2021 MyFlightbook, LLC
 
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
//  MFBTheme.m
//  MyFlightbook
//
//  Created by Eric Berman on 12/7/18.
//

#import "MFBTheme.h"

@implementation MFBTheme
+ (BOOL) isDarkMode {
    if (@available(iOS 13.0, *)) {
        return UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    } else {
        return false;
    }
}

+ (UIColor *) MFBBrandColor {
    return [UIColor colorWithRed:0 green:0.73725 blue:.831372 alpha:1];
}

+ (void) applyThemedImageNamed:(NSString *) imageName toImageView:(UIImageView *) imgView {
    imgView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imgView.tintColor = MFBTheme.MFBBrandColor;
}

+ (void) setMFBTheme {
    UIColor * mfbColor = MFBTheme.MFBBrandColor;
    UITabBar.appearance.tintColor = UIToolbar.appearance.tintColor = UIButton.appearance.tintColor = UISegmentedControl.appearance.tintColor = mfbColor;
    [UIButton.appearance setTitleColor:mfbColor forState:UIControlStateNormal];
    [UIButton.appearance setTitleColor:mfbColor forState:UIControlStateSelected];
    [UIButton.appearance setTitleColor:mfbColor forState:UIControlStateHighlighted];

    if (@available(iOS 13.0, *)) {
        UISegmentedControl.appearance.selectedSegmentTintColor = mfbColor;
    } else {
        // Fallback on earlier versions
    }
    
    // Bleah - fucking Apple introducing breaking changes.
    // With iOS 15, the top is black until you scroll.  Pathetically lame.
    // https://stackoverflow.com/questions/69111478/ios-15-navigation-bar-transparent
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance * app = UINavigationBarAppearance.new;
        [app configureWithOpaqueBackground];
        UINavigationBar.appearance.standardAppearance = app;
        UINavigationBar.appearance.scrollEdgeAppearance = app;
        UIToolbarAppearance * tba = UIToolbarAppearance.new;
        [tba configureWithOpaqueBackground];
        UIToolbar.appearance.standardAppearance = tba;
        UIToolbar.appearance.scrollEdgeAppearance = tba;
        UITabBarAppearance * tabapp = UITabBarAppearance.new;
        [tabapp configureWithOpaqueBackground];
        UITabBar.appearance.standardAppearance = tabapp;
        UITabBar.appearance.scrollEdgeAppearance = tabapp;
    }
    
    UISwitch.appearance.onTintColor = mfbColor;
}
@end

