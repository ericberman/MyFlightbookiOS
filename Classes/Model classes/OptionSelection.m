/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  OptionSelection.m
//  MyFlightbook
//
//  Created by Eric Berman on 4/18/18.
//

#import <Foundation/Foundation.h>
#import "OptionSelection.h"

@interface OptionSelection()
@property (nonatomic, strong) NSString * optionKey;
@end

@implementation OptionSelection

@synthesize title, optionKey, rgOptions;

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"";
        self.optionKey = @"";
        self.rgOptions = @[];
    }
    return self;
}

- (instancetype) initWithTitle:(NSString *) title forOptionKey:(NSString *) optionKey options:(NSArray<NSString *> *) titles {
    if (self = [super init]) {
        self.title = title;
        self.optionKey = optionKey;
        self.rgOptions = titles;
    }
    return self;
}

- (NSInteger) selectedIndex; {
    return [NSUserDefaults.standardUserDefaults integerForKey:self.optionKey];
}

- (void) setOptionToIndex:(NSInteger) index {
    [NSUserDefaults.standardUserDefaults setInteger:index forKey:self.optionKey];
}

@end
