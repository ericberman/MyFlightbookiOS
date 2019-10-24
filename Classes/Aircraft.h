/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2019 MyFlightbook, LLC
 
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
//  Aircraft.h
//  MFBSample
//
//  Created by Eric Berman on 12/20/09.
//  Copyright 2009-2017, MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBSoapCall.h"
#import "MFBWebServiceSvc.h"
#import "MFBAsyncOperation.h"


@interface Aircraft : MFBAsyncOperation <MFBSoapCallDelegate> {
}

#define MINTAILNUM	3
#define TAILNUMDIGITS 7

@property (readwrite, strong) NSArray<MFBWebServiceSvc_Aircraft *> * rgAircraftForUser;
@property (readwrite, strong) NSString * errorString;
@property (nonatomic, strong) NSArray<MFBWebServiceSvc_SimpleMakeModel *> * rgMakeModels;
@property (nonatomic, readwrite) int DefaultAircraftID;

+ (Aircraft *) sharedAircraft;
+ (NSString *) PrefixSIM;
+ (NSString *) PrefixAnonymous;
+ (NSString *) aircraftInstanceTypeDisplay:(MFBWebServiceSvc_AircraftInstanceTypes) instanceType;

- (void) setHighWaterTach:(NSNumber *) tach forAircraft:(NSNumber *) aircraftID;
- (NSNumber *) getHighWaterTachForAircraft:(NSNumber *) aircraftID;
- (void) setHighWaterHobbs:(NSNumber *) hobbs forAircraft:(NSNumber *) aircraftID;
- (NSNumber *) getHighWaterHobbsForAircraft:(NSNumber *) aircraftID;

- (void) clearAircraft;
- (void) cacheAircraft:(NSArray *) rgAircraft forUser:(NSString *) szAuthToken;
- (void) invalidateCachedAircraft;
- (NSArray *) cachedAircraft;
- (int) cacheStatus:(NSString *) szAuthToken;
- (void) loadAircraftForUser:(BOOL) forceRefresh;
- (void) refreshIfNeeded;
- (void) deleteAircraft:(NSNumber *) idAircraft forUser:(NSString *) szAuthToken;
- (void) loadMakeModels;
- (NSArray *) modelsInUse;
- (void) addAircraft:(MFBWebServiceSvc_Aircraft *) ac ForUser:(NSString *) szAuthToken;
- (void) updateAircraft:(MFBWebServiceSvc_Aircraft *) ac ForUser:(NSString *) szAuthToken;
- (MFBWebServiceSvc_Aircraft *) preferredAircraft;
- (NSInteger) indexOfAircraftID:(int) idAircraft;
- (MFBWebServiceSvc_Aircraft *) AircraftByID:(int) idAircraft;
- (MFBWebServiceSvc_Aircraft *) AircraftByTail:(NSString *) szTail;
- (NSInteger) indexOfModelID:(NSInteger) idModel;
- (NSString *) descriptionOfModelId:(NSInteger) idModel;
- (BOOL) validateAircraftForUser:(MFBWebServiceSvc_Aircraft *) ac;
- (NSArray *) AircraftForSelection:(NSNumber *) acIDToInclude;
@end

@interface MFBWebServiceSvc_SimpleMakeModel (MFBExtensions)
- (NSString *) manufacturerName;
- (NSString *) subDesc;
@end

// Add methods to the MFBWebServiceSvc_Aircraft object (from WSDL) to make it comform to the NSCoding protocol
@interface MFBWebServiceSvc_Aircraft (NSCodingSupport)
- (NSNumber *) instanceTypeIDFromInstanceType:(MFBWebServiceSvc_AircraftInstanceTypes) instanceType;
- (void)encodeWithCoderMFB:(NSCoder *)encoder;
- (instancetype)initWithCoderMFB:(NSCoder *)decoder;
- (NSString *) modelFullDescription;
+ (MFBWebServiceSvc_Aircraft *) getNewAircraft;
- (BOOL) isNew;
- (BOOL) isSim;
- (BOOL) isAnonymous;
- (BOOL) hasMaintenance;
- (NSString *) displayTailNumber;
- (NSDate *) nextVOR;
- (NSDate *) nextAnnual;
- (NSDate *) nextELT;
- (NSDate *) nextAltimeter;
- (NSDate *) nextPitotStatic;
- (NSDate *) nextTransponder;
@end
