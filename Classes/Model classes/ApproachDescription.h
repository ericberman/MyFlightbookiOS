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
//  ApproachDescription.h
//  MFBSample
//
//  Created by Eric Berman on 1/17/17.
//
//

#ifndef ApproachDescription_h
#define ApproachDescription_h

@interface ApproachDescription : NSObject

@property (readwrite) NSInteger approachCount;
@property (readwrite) BOOL addToTotals;
@property (nonatomic, strong) NSString * approachName;
@property (nonatomic, strong) NSString * runwayName;
@property (nonatomic, strong) NSString * airportName;

+ (NSArray<NSString *> *) ApproachNames;
+ (NSArray<NSString *> *) ApproachSuffixes;
+ (NSArray<NSString *> *) RunwayNames;
+ (NSArray<NSString *> *) RunwayModifiers;
@end

#endif /* ApproachDescription_h */
