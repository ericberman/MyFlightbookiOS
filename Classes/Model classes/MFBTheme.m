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
//  MFBTheme.m
//  MyFlightbook
//
//  Created by Eric Berman on 12/7/18.
//

#import "MFBTheme.h"

@interface MFBTheme()
+ (ThemeType) themeType;
+ (void) setThemeType:(ThemeType) themeType;

@property (nonatomic, strong) UIColor * buttonBackColor;
@property (nonatomic, strong) UIColor * buttonSelectedColor;
@property (nonatomic, strong) UIColor * buttonHighlightedColor;
@property (nonatomic, strong) UIColor * buttonDisabledColor;
@property (nonatomic, strong) UIColor * buttonNormalColor;

@property (nonatomic, strong) UIColor * textViewBackColor;
@property (nonatomic, strong) UIColor * textViewForeColor;
@property (nonatomic, strong) UIColor * textFieldBackColor;
@property (nonatomic, strong) UIColor * textFieldForeColor;

@property (nonatomic, strong) UIColor * cellBackColor;
@property (nonatomic, strong, nullable) UIView * cellbackgroundView;

@property (nonatomic, strong) UIColor * navBarBackColor;

@property (nonatomic, strong) UIColor * tableBackColor;
@property (nonatomic, readwrite) UITableViewCellFocusStyle tableFocusStyle;
@property (nonatomic, readwrite) UITableViewCellSelectionStyle tableSelectStyle;

@property (nonatomic, strong) UIColor * tabbarBarTintColor;

@property (nonatomic, strong) UIColor * toolbarBackColor;
@property (nonatomic, strong) UIColor * searchBarBackColor;

@property (nonatomic, strong) UIColor * pickerBackColor;
@property (nonatomic, strong) UIColor * datePickerBackColor;
@property (nonatomic, readwrite) UIKeyboardAppearance keyboardType;

@property (nonatomic, strong) NSString * themeName;

@property (nonatomic, strong) UIColor * hintColor;

@property (nonatomic, readwrite) UIStatusBarStyle statusBarStyle;
@property (nonatomic, readwrite) UIBarStyle navBarStyle;
@property (nonatomic, readwrite) UIBarStyle toolBarStyle;

@property (nonatomic, strong) UIColor * tableHeaderFooterForeColor;
@property (nonatomic, strong) UIColor * tableHeaderFooterBackColor;

@end

@interface NightTheme : MFBTheme
@end

@interface DayTheme : MFBTheme
@end

@implementation MFBTheme

@synthesize themeName, cellValue1DetailTextColor, Type;
@synthesize buttonNormalColor, buttonSelectedColor, buttonHighlightedColor, buttonDisabledColor;
@synthesize textViewBackColor, textViewForeColor, textFieldBackColor, textFieldForeColor;
@synthesize labelBackColor, labelForeColor;
@synthesize cellBackColor, cellbackgroundView;
@synthesize navBarBackColor;
@synthesize tableBackColor, tableFocusStyle, tableSelectStyle;
@synthesize tabbarBarTintColor;
@synthesize toolbarBackColor;
@synthesize searchBarBackColor;
@synthesize pickerBackColor, datePickerBackColor, keyboardType;
@synthesize statusBarStyle, navBarStyle, toolBarStyle;

@synthesize tableHeaderFooterBackColor, tableHeaderFooterForeColor;

@synthesize expandHeaderBackColor, expandHeaderTextColor;
@synthesize dimmedColor, hintColor;

+ (UIColor *) MFBBrandColor {
    return [UIColor colorWithRed:0 green:0.73725 blue:.831372 alpha:1];
}

+ (NSString *) modeName:(ThemeMode) mode {
    switch (mode) {
        case ThemeModeOn:
            return NSLocalizedString(@"NightModeOn", @"Night Mode On");
        case ThemeModeOff:
            return NSLocalizedString(@"NightModeOff", @"Night Mode Off");
        case ThemeModeAuto:
            return NSLocalizedString(@"NightModeAuto", @"Night Mode Automatic");
        default:
            return @"";
    }
}

static NSArray * rgThemes = nil;
static MFBTheme * currentTheme = nil;

- (void) applyTheme {
    currentTheme = self;
    
    [UIButton.appearance setTitleColor:self.buttonNormalColor forState:UIControlStateNormal];
    [UIButton.appearance setTitleColor:self.buttonSelectedColor forState:UIControlStateSelected];
    [UIButton.appearance setTitleColor:self.buttonHighlightedColor forState:UIControlStateHighlighted];
    [UIButton.appearance setTitleColor:self.buttonDisabledColor forState:UIControlStateDisabled];

    UITextView.appearance.backgroundColor = self.textViewBackColor;
    UITextView.appearance.textColor = self.textViewForeColor;
    
    UITextField.appearance.textColor = self.textFieldForeColor;
    UITextField.appearance.backgroundColor = self.textFieldBackColor;
    
    UITableViewCell.appearance.backgroundColor = self.cellBackColor;
    UITableViewCell.appearance.selectedBackgroundView = self.cellbackgroundView;
    
    UITableViewCell.appearance.focusStyle = self.tableFocusStyle;
    UITableViewCell.appearance.selectionStyle = self.tableSelectStyle;
    
    UITableView.appearance.backgroundColor = self.tableBackColor;
    
    UINavigationBar.appearance.backgroundColor = self.navBarBackColor;
    
    UITabBar.appearance.barTintColor = self.tabbarBarTintColor;

    UIToolbar.appearance.backgroundColor = self.toolbarBackColor;
    UIToolbar.appearance.barStyle = self.toolBarStyle;
    UIToolbar.appearance.barTintColor = self.tabbarBarTintColor;
    
    
    UINavigationBar.appearance.barStyle = self.navBarStyle;
    UIApplication.sharedApplication.statusBarStyle = self.statusBarStyle;

    UIPickerView.appearance.backgroundColor = self.pickerBackColor;
    UIDatePicker.appearance.backgroundColor = self.datePickerBackColor;
    UITextField.appearance.keyboardAppearance = self.keyboardType;
    
    UISearchBar.appearance.searchBarStyle = UISearchBarStyleProminent;
    UISearchBar.appearance.barStyle = self.toolBarStyle;

    [UIView appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]].backgroundColor = self.tableHeaderFooterBackColor;
    [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]].backgroundColor = self.tableHeaderFooterBackColor;
    [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewHeaderFooterView class]]].textColor = self.tableHeaderFooterForeColor;
    UILabel.appearance.textColor = self.labelForeColor;
    
    UITableView.appearance.separatorStyle = UITableViewCellSeparatorStyleNone;

    // Branded colors - regardless of theme
    UITabBar.appearance.tintColor = UIToolbar.appearance.tintColor = UIButton.appearance.tintColor = UISegmentedControl.appearance.tintColor = [MFBTheme MFBBrandColor];
    UISwitch.appearance.onTintColor = MFBTheme.MFBBrandColor;

}

#pragma mark - external formatting
- (NSAttributedString *) formatAsPlaceholder:(NSString *) placeholder {
    return [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName : self.hintColor}];
}

- (void) setSearchBar:(UISearchBar *) searchBar Placholeder:(NSString *) placeholder {
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    searchTextField.placeholder = nil;
    if ([searchTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        searchTextField.attributedPlaceholder = [self formatAsPlaceholder:placeholder];
    }
}

- (void) applyThemedImageNamed:(NSString *) imageName toImageView:(UIImageView *) imgView {
    imgView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imgView.tintColor = MFBTheme.MFBBrandColor;
}

- (void) applyThemeToCell:(UITableViewCell *) cell {
    cell.detailTextLabel.textColor = self.cellValue1DetailTextColor;
    cell.textLabel.textColor = self.labelForeColor;
}

- (void) applyThemeToTableHeader:(UIView *) header {
    if ([header isMemberOfClass:[UITableViewHeaderFooterView class]])
        ((UITableViewHeaderFooterView *) header).textLabel.textColor = self.tableHeaderFooterForeColor;
}

#pragma - mark applying/retrieving themes
+ (NSArray<MFBTheme *> *) availableThemes {
    if (rgThemes == nil) {
        rgThemes = @[[[DayTheme alloc] init],
                     [[NightTheme alloc] init]];
    }
    return rgThemes;
}

+ (MFBTheme *) currentTheme {
    if (currentTheme == nil)
        return currentTheme = MFBTheme.availableThemes[0];
    return currentTheme;
}

- (void) applyToAllViews {
    UIView * window = [UIApplication sharedApplication].keyWindow;
    for (UIView * view in window.subviews) {
        [view removeFromSuperview];
        [window addSubview:view];
    }
}

+ (void) setTheme:(ThemeType) themeType {
    for (MFBTheme * theme in [MFBTheme availableThemes]) {
        if (theme.Type == themeType) {
            [theme applyTheme];
            [theme applyToAllViews];    // force the reload
            
            // Tables are problematic because reload above doesn't fix cells, so send a notification to these.
            // This also addresses "Automatic" mode, where we don't know who to tell to reload their tables.
            [[NSNotificationCenter defaultCenter] postNotification:[[NSNotification alloc] initWithName:NOTIFY_THEME_CHANGED object:nil userInfo:nil]];
            MFBTheme.themeType = themeType;
            break;
        }
    }
}

+ (void) restoreTheme {
    [MFBTheme setTheme:MFBTheme.themeType];
}

+ (void) setThemeType:(ThemeType) themeType {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setInteger:themeType forKey:keyThemeType];
    [defs synchronize];
}

+ (ThemeType) themeType {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    return [defs integerForKey:keyThemeType];
}

+ (void) setThemeMode:(ThemeMode) themeMode {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    [defs setInteger:themeMode forKey:keyThemePref];
    [defs synchronize];
}

+ (ThemeMode) themeMode {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    return [defs integerForKey:keyThemePref];
}
@end

@implementation NightTheme
- (instancetype) init {
    if (self = [super init]) {
        self.themeName = @"Night";
        self.Type = themeNight;
        
        self.buttonSelectedColor = self.buttonHighlightedColor = self.buttonNormalColor =  [MFBTheme MFBBrandColor];        
        self.buttonDisabledColor = [UIColor grayColor];
        self.textViewForeColor = self.textFieldForeColor = self.labelForeColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];;
        
        self.buttonBackColor = self.textViewBackColor = self.textFieldBackColor = self.labelBackColor = self.cellBackColor =
        self.navBarBackColor = self.searchBarBackColor = self.tabbarBarTintColor = self.toolbarBackColor =
        self.pickerBackColor = self.datePickerBackColor = [UIColor colorWithRed:.1 green:.1 blue:.1 alpha:1];
        
        self.tableBackColor = [UIColor blackColor];
        
        self.keyboardType = UIKeyboardAppearanceDark;
        
        self.cellValue1DetailTextColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.0];
        
        self.tableFocusStyle = UITableViewCellFocusStyleDefault;
        self.tableSelectStyle = UITableViewCellSelectionStyleNone;
        self.cellbackgroundView = nil;
        
        self.statusBarStyle = UIStatusBarStyleLightContent;
        self.navBarStyle = UIBarStyleBlack;
        self.toolBarStyle = UIBarStyleBlack;
        
        self.tableHeaderFooterBackColor = self.expandHeaderBackColor = [UIColor colorWithRed:80/255.0 green:80/255.0 blue:80/255.0 alpha:1.0];
        self.tableHeaderFooterForeColor = self.expandHeaderTextColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        
        self.dimmedColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1.0];
        self.hintColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    }
    return self;
}
@end

@implementation DayTheme
- (instancetype) init {
    if (self = [super init]) {
        self.cellValue1DetailTextColor = [UIColor colorWithRed:.35 green:.35 blue:.35 alpha:1.0];
        self.expandHeaderBackColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        self.expandHeaderTextColor = [UIColor blackColor];
        self.themeName = @"Day";
        self.dimmedColor = [UIColor grayColor];
        self.hintColor = [UIColor darkGrayColor];
        
        self.buttonSelectedColor = self.buttonHighlightedColor = self.buttonNormalColor = [MFBTheme MFBBrandColor];
        self.buttonDisabledColor = [UIColor grayColor];
        self.textViewForeColor = self.textFieldForeColor = self.labelForeColor = [UIColor blackColor];
        
        self.buttonBackColor = self.textViewBackColor = self.textFieldBackColor = self.labelBackColor = self.cellBackColor = [UIColor whiteColor];
        
        self.toolbarBackColor = self.navBarBackColor = self.searchBarBackColor = [UIColor lightGrayColor];
        
        self.tableBackColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        
        self.pickerBackColor = self.datePickerBackColor = [UIColor lightGrayColor];
        
        self.keyboardType = UIKeyboardAppearanceLight;
        
        self.tableFocusStyle = UITableViewCellFocusStyleDefault;
        self.tableSelectStyle = UITableViewCellSelectionStyleNone;
        self.cellbackgroundView = nil;
        
        self.tabbarBarTintColor = [UIColor whiteColor];
        
        self.statusBarStyle = UIStatusBarStyleDefault;
        self.navBarStyle = UIBarStyleDefault;
        self.toolBarStyle = UIBarStyleDefault;
        
        self.expandHeaderBackColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
        self.expandHeaderTextColor = [UIColor blackColor];
        
        self.tableHeaderFooterForeColor = [UIColor darkGrayColor];
        self.tableHeaderFooterBackColor = [UIColor colorWithRed:.9 green:.9 blue:.9 alpha:1.0];
        
        self.dimmedColor = [UIColor lightGrayColor];
        self.hintColor = [UIColor colorWithRed:.7 green:.7 blue:.7 alpha:1.0];

        self.Type = themeDay;
    }
    return self;
}
@end

@implementation ThemeOptionSelection
- (void) setOptionToIndex:(NSInteger)index {
    ThemeMode mode = (ThemeMode) index;
    if (mode != MFBTheme.themeMode) {
        [MFBTheme setThemeMode:(ThemeMode) mode];
        switch (mode) {
            case ThemeModeOff:
                [MFBTheme setTheme:themeDay];
                break;
            case ThemeModeOn:
                [MFBTheme setTheme:themeNight];
                break;
            case ThemeModeAuto:
                // don't do anything - next sample we receive will change it.
                break;
        }
    }
}
@end

@implementation UITableViewCell (MFBTheming)
- (instancetype) initWithMFBThemedStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    // below looks like infinite recursion but isn't because this method has been swizzled with
    // initWithStyle:reuseIdentifier:.  See https://nshipster.com/method-swizzling/.
    id result = [self initWithMFBThemedStyle:style reuseIdentifier:reuseIdentifier];
    
    if (result != nil)
        [MFBTheme.currentTheme applyThemeToCell:self];
    
    return result;
}
@end

@implementation UITableView (MFBTheming)
- (UITableViewCell *) dequeueThemedReusableCellWithIdentifier:(NSString *)identifier {
    UITableViewCell * cell = [self dequeueThemedReusableCellWithIdentifier:identifier];
    [MFBTheme.currentTheme applyThemeToCell:cell];

    return cell;
}
@end

@implementation UIColor (MFBTheming)
- (NSString *) asRGB {
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [NSString stringWithFormat:@"r:%f g:%f b:%f a:%f", r, g, b, a];
}
@end
