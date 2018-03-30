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
//  OptionKeys.h
//  MyFlightbook
//
//  Created by Eric Berman on 3/30/18.
//

#ifndef OptionKeys_h
#define OptionKeys_h

// Define the keys used in NSUserDefaults.
#define szPrefAutoHobbs @"prefKeyAutoHobbs"
#define szPrefAutoTotal @"prefKeyAutoTotal"
#define szPrefKeyHHMM @"keyUseHHMM"
#define szPrefKeyRoundNearestTenth  @"keyRoundNearestTenth"
#define keyPrefSuppressUTC @"keySuppressUTC"
#define _szKeyPrefTakeOffSpeed @"keyPrefTakeOffSpeed"
#define keyIncludeHeliports @"keyIncludeHeliports"
#define keyMapMode @"keyMappingMode"
#define keyShowImages @"keyShowImages"
#define keyShowFlightTimes @"keyShowFlightTimes"
#define keyNightFlightPref @"keyNightFlightPref"
#define keyNightLandingPref @"keyNightLandingPref"

#endif /* OptionKeys_h */
