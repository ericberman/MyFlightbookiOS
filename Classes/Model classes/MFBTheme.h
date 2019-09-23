/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018 MyFlightbook, LLC
 
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
//  MFBTheme.h
//  MyFlightbook
//
//  Created by Eric Berman on 12/7/18.
//

#import "OptionSelection.h"

typedef enum : NSInteger {
    themeDay = 0, themeNight
} ThemeType;

typedef enum : NSInteger {
    ThemeModeOff,
    ThemeModeOn,
    ThemeModeAuto
} ThemeMode;

#define keyThemePref    @"currentThemePref"
#define keyThemeType    @"currentThemeType"

#define NOTIFY_THEME_CHANGED @"notify_theme_changed"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MFBTheme : NSObject

+ (void) restoreTheme;
+ (ThemeMode) themeMode;
+ (void) setTheme:(ThemeType) themeType;
+ (NSString *) modeName:(ThemeMode) mode;
+ (MFBTheme *) currentTheme;
+ (UIColor *) MFBBrandColor;

- (NSAttributedString *) formatAsPlaceholder:(NSString *) placeholder;
- (void) setSearchBar:(UISearchBar *) searchBar Placholeder:(NSString *) placeholder;
- (void) applyThemedImageNamed:(NSString *) imageName toImageView:(UIImageView *) imgView;
- (void) applyThemeToCell:(UITableViewCell *) cell;
- (void) applyThemeToTableHeader:(UIView *) header;

@property (nonatomic, readwrite) ThemeType Type;
@property (nonatomic, strong) UIColor * labelForeColor;
@property (nonatomic, strong) UIColor * labelBackColor;
@property (nonatomic, strong) UIColor * tableBackColor;
@property (nonatomic, strong) UIColor * dimmedColor;
@property (nonatomic, strong) UIColor * expandHeaderBackColor;
@property (nonatomic, strong) UIColor * expandHeaderTextColor;
@property (nonatomic, strong) UIColor * cellValue1DetailTextColor;

@end

@interface ThemeOptionSelection : OptionSelection
@end

@interface UITableViewCell (MFBTheming)
- (instancetype) initWithMFBThemedStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end

@interface UITableView (MFBTheming)
- (UITableViewCell *) dequeueThemedReusableCellWithIdentifier:(NSString *)identifier;
@end

@interface UIColor (MFBTheming)
- (NSString *) asRGB;
@end

NS_ASSUME_NONNULL_END
