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

+ (void) refreshTakeoffSpeed {
    [MFBLocation refreshTakeoffSpeed];
}

+ (void) setRecord:(BOOL) f {
    MFBAppDelegate.threadSafeAppDelegate.mfbloc.fRecordFlightData = f;
}

+ (void) setRecordHighRes:(BOOL) f {
    MFBAppDelegate.threadSafeAppDelegate.mfbloc.fRecordHighRes = f;
}

+ (CLLocation *) lastLoc {
    return MFBAppDelegate.threadSafeAppDelegate.mfbloc.lastSeenLoc;
}

+ (SharedWatch *) watchData {
    return MFBAppDelegate.threadSafeAppDelegate.watchData;
}

+ (void) updateWatchContext {
    [MFBAppDelegate.threadSafeAppDelegate updateWatchContext];
}

// Because fucking swift fucking renames every fucking variable because of their fucking anal retentiveness about capitalization,
// "Description" on the simple make/model conflicts with "description" that gets bridging assigned.
// I could use the NS_SWIFT_NAME macro to define an alternate name, but alas THAT has to be done in the auto-generated MFBWebServiceSvc.h
// file, which means that whenever I update that file I'd break if I forget to edit it, which I don't want to do
// So the hack here is to come back to objective-c where variables keep the fucking names I give them
+ (NSString *) getDescriptionForSimpleMakeModel:(MFBWebServiceSvc_SimpleMakeModel *) smm {
    return smm.Description;
}

+ (void) dequeueUnsubmittedFlight:(id) l {
    [MFBAppDelegate.threadSafeAppDelegate dequeueUnsubmittedFlight:(LogbookEntry *) l];
}

+ (NSString *) flightDataAsString {
    return MFBAppDelegate.threadSafeAppDelegate.mfbloc.flightDataAsString;
}

+ (void) queueFlightForLater:(id) l {
    [MFBAppDelegate.threadSafeAppDelegate queueFlightForLater:(LogbookEntry *) l];
}

@end
