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
//  SwiftHackBridge.m
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

#import <Foundation/Foundation.h>
#import "MFBAppDelegate.h"

// Hack class for now to provide minimal pollution of the bridging header while we slowly migrate stuff to swift
// TODO: REMOVE THIS OVER TIME 
@implementation SwiftHackBridge
+ (BOOL)isOnline {
    return MFBAppDelegate.threadSafeAppDelegate.isOnLine;
}
+ (void) invalidateCachedTotals {
    [MFBAppDelegate.threadSafeAppDelegate invalidateCachedTotals];
}

+ (void) clearOldUserContent {
    Aircraft * ac = [Aircraft sharedAircraft];
    [ac invalidateCachedAircraft];
    ac.DefaultAircraftID = -1;
    [MFBAppDelegate.threadSafeAppDelegate invalidateAll];
}

@end
