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
//  SwiftHackBridge.h
//  MFBSample
//
//  Created by Eric Berman on 2/24/23.
//

#ifndef SwiftHackBridge_h
#define SwiftHackBridge_h

@interface SwiftHackBridge : NSObject {
}

+ (BOOL) isOnline;
+ (void) invalidateCachedTotals;
+ (void) clearOldUserContent;
+ (void) refreshTakeoffSpeed;
+ (void) setRecord:(BOOL) f;
+ (void) setRecordHighRes:(BOOL) f;
@end

#endif /* SwiftHackBridge_h */
