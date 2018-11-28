#import <Foundation/Foundation.h>
#import "USAdditions.h"
#import <libxml/tree.h>
#import "USGlobals.h"
#import <objc/runtime.h>
@class MFBWebServiceSvc_AircraftForUser;
@class MFBWebServiceSvc_AircraftForUserResponse;
@class MFBWebServiceSvc_ArrayOfAircraft;
@class MFBWebServiceSvc_Aircraft;
@class MFBWebServiceSvc_ArrayOfMFBImageInfo;
@class MFBWebServiceSvc_MFBImageInfo;
@class MFBWebServiceSvc_LatLong;
@class MFBWebServiceSvc_AddAircraftForUser;
@class MFBWebServiceSvc_AddAircraftForUserResponse;
@class MFBWebServiceSvc_UpdateMaintenanceForAircraft;
@class MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse;
@class MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes;
@class MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse;
@class MFBWebServiceSvc_DeleteAircraftForUser;
@class MFBWebServiceSvc_DeleteAircraftForUserResponse;
@class MFBWebServiceSvc_MakesAndModels;
@class MFBWebServiceSvc_MakesAndModelsResponse;
@class MFBWebServiceSvc_ArrayOfSimpleMakeModel;
@class MFBWebServiceSvc_SimpleMakeModel;
@class MFBWebServiceSvc_GetCurrencyForUser;
@class MFBWebServiceSvc_GetCurrencyForUserResponse;
@class MFBWebServiceSvc_ArrayOfCurrencyStatusItem;
@class MFBWebServiceSvc_CurrencyStatusItem;
@class MFBWebServiceSvc_FlightQuery;
@class MFBWebServiceSvc_ArrayOfCategoryClass;
@class MFBWebServiceSvc_ArrayOfCustomPropertyType;
@class MFBWebServiceSvc_ArrayOfString;
@class MFBWebServiceSvc_ArrayOfMakeModel;
@class MFBWebServiceSvc_CategoryClass;
@class MFBWebServiceSvc_CustomPropertyType;
@class MFBWebServiceSvc_MakeModel;
@class MFBWebServiceSvc_TotalsForUser;
@class MFBWebServiceSvc_TotalsForUserResponse;
@class MFBWebServiceSvc_ArrayOfTotalsItem;
@class MFBWebServiceSvc_TotalsItem;
@class MFBWebServiceSvc_TotalsForUserWithQuery;
@class MFBWebServiceSvc_TotalsForUserWithQueryResponse;
@class MFBWebServiceSvc_VisitedAirports;
@class MFBWebServiceSvc_VisitedAirportsResponse;
@class MFBWebServiceSvc_ArrayOfVisitedAirport;
@class MFBWebServiceSvc_VisitedAirport;
@class MFBWebServiceSvc_airport;
@class MFBWebServiceSvc_FlightsWithQueryAndOffset;
@class MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse;
@class MFBWebServiceSvc_ArrayOfLogbookEntry;
@class MFBWebServiceSvc_LogbookEntry;
@class MFBWebServiceSvc_ArrayOfCustomFlightProperty;
@class MFBWebServiceSvc_ArrayOfVideoRef;
@class MFBWebServiceSvc_CustomFlightProperty;
@class MFBWebServiceSvc_VideoRef;
@class MFBWebServiceSvc_FlightsWithQuery;
@class MFBWebServiceSvc_FlightsWithQueryResponse;
@class MFBWebServiceSvc_DeleteLogbookEntry;
@class MFBWebServiceSvc_DeleteLogbookEntryResponse;
@class MFBWebServiceSvc_CommitFlightWithOptions;
@class MFBWebServiceSvc_PostingOptions;
@class MFBWebServiceSvc_CommitFlightWithOptionsResponse;
@class MFBWebServiceSvc_FlightPathForFlight;
@class MFBWebServiceSvc_FlightPathForFlightResponse;
@class MFBWebServiceSvc_ArrayOfLatLong;
@class MFBWebServiceSvc_FlightPathForFlightGPX;
@class MFBWebServiceSvc_FlightPathForFlightGPXResponse;
@class MFBWebServiceSvc_AvailablePropertyTypes;
@class MFBWebServiceSvc_AvailablePropertyTypesResponse;
@class MFBWebServiceSvc_AvailablePropertyTypesForUser;
@class MFBWebServiceSvc_AvailablePropertyTypesForUserResponse;
@class MFBWebServiceSvc_PropertiesForFlight;
@class MFBWebServiceSvc_PropertiesForFlightResponse;
@class MFBWebServiceSvc_DeletePropertiesForFlight;
@class MFBWebServiceSvc_ArrayOfInt;
@class MFBWebServiceSvc_DeletePropertiesForFlightResponse;
@class MFBWebServiceSvc_DeletePropertyForFlight;
@class MFBWebServiceSvc_DeletePropertyForFlightResponse;
@class MFBWebServiceSvc_DeleteImage;
@class MFBWebServiceSvc_DeleteImageResponse;
@class MFBWebServiceSvc_UpdateImageAnnotation;
@class MFBWebServiceSvc_UpdateImageAnnotationResponse;
@class MFBWebServiceSvc_AuthTokenForUser;
@class MFBWebServiceSvc_AuthTokenForUserResponse;
@class MFBWebServiceSvc_CreateUser;
@class MFBWebServiceSvc_CreateUserResponse;
@class MFBWebServiceSvc_UserEntity;
@class MFBWebServiceSvc_GetNamedQueriesForUser;
@class MFBWebServiceSvc_GetNamedQueriesForUserResponse;
@class MFBWebServiceSvc_ArrayOfCannedQuery;
@class MFBWebServiceSvc_CannedQuery;
@class MFBWebServiceSvc_AddNamedQueryForUser;
@class MFBWebServiceSvc_AddNamedQueryForUserResponse;
@class MFBWebServiceSvc_DeleteNamedQueryForUser;
@class MFBWebServiceSvc_DeleteNamedQueryForUserResponse;
@class MFBWebServiceSvc_SuggestModels;
@class MFBWebServiceSvc_SuggestModelsResponse;
@class MFBWebServiceSvc_PreviouslyUsedTextProperties;
@class MFBWebServiceSvc_PreviouslyUsedTextPropertiesResponse;
@class MFBWebServiceSvc_AirportsInBoundingBox;
@class MFBWebServiceSvc_AirportsInBoundingBoxResponse;
@class MFBWebServiceSvc_ArrayOfAirport;
@interface MFBWebServiceSvc_AircraftForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AircraftForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_AircraftInstanceTypes_none = 0,
	MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft,
	MFBWebServiceSvc_AircraftInstanceTypes_Mintype,
	MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator,
	MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator,
	MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator,
	MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD,
	MFBWebServiceSvc_AircraftInstanceTypes_MaxType,
} MFBWebServiceSvc_AircraftInstanceTypes;
MFBWebServiceSvc_AircraftInstanceTypes MFBWebServiceSvc_AircraftInstanceTypes_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AircraftInstanceTypes_stringFromEnum(MFBWebServiceSvc_AircraftInstanceTypes enumValue);
typedef enum {
	MFBWebServiceSvc_ImageFileType_none = 0,
	MFBWebServiceSvc_ImageFileType_JPEG,
	MFBWebServiceSvc_ImageFileType_PDF,
	MFBWebServiceSvc_ImageFileType_S3PDF,
	MFBWebServiceSvc_ImageFileType_S3VideoMP4,
	MFBWebServiceSvc_ImageFileType_Unknown,
} MFBWebServiceSvc_ImageFileType;
MFBWebServiceSvc_ImageFileType MFBWebServiceSvc_ImageFileType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_ImageFileType_stringFromEnum(MFBWebServiceSvc_ImageFileType enumValue);
@interface MFBWebServiceSvc_LatLong : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * Latitude;
	NSNumber * Longitude;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_LatLong *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * Latitude;
@property (nonatomic, retain) NSNumber * Longitude;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MFBImageInfo : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * Width;
	NSNumber * Height;
	NSNumber * WidthThumbnail;
	NSNumber * HeightThumbnail;
	MFBWebServiceSvc_ImageFileType ImageType;
	NSString * Comment;
	NSString * VirtualPath;
	NSString * ThumbnailFile;
	MFBWebServiceSvc_LatLong * Location;
	NSString * URLFullImage;
	NSString * URLThumbnail;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_MFBImageInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * Width;
@property (nonatomic, retain) NSNumber * Height;
@property (nonatomic, retain) NSNumber * WidthThumbnail;
@property (nonatomic, retain) NSNumber * HeightThumbnail;
@property (nonatomic, assign) MFBWebServiceSvc_ImageFileType ImageType;
@property (nonatomic, retain) NSString * Comment;
@property (nonatomic, retain) NSString * VirtualPath;
@property (nonatomic, retain) NSString * ThumbnailFile;
@property (nonatomic, retain) MFBWebServiceSvc_LatLong * Location;
@property (nonatomic, retain) NSString * URLFullImage;
@property (nonatomic, retain) NSString * URLThumbnail;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfMFBImageInfo : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *MFBImageInfo;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfMFBImageInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addMFBImageInfo:(MFBWebServiceSvc_MFBImageInfo *)toAdd;
@property (nonatomic, readonly) NSMutableArray * MFBImageInfo;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_PilotRole_none = 0,
	MFBWebServiceSvc_PilotRole_None,
	MFBWebServiceSvc_PilotRole_PIC,
	MFBWebServiceSvc_PilotRole_SIC,
	MFBWebServiceSvc_PilotRole_CFI,
} MFBWebServiceSvc_PilotRole;
MFBWebServiceSvc_PilotRole MFBWebServiceSvc_PilotRole_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_PilotRole_stringFromEnum(MFBWebServiceSvc_PilotRole enumValue);
typedef enum {
	MFBWebServiceSvc_AvionicsTechnologyType_none = 0,
	MFBWebServiceSvc_AvionicsTechnologyType_None,
	MFBWebServiceSvc_AvionicsTechnologyType_Glass,
	MFBWebServiceSvc_AvionicsTechnologyType_TAA,
} MFBWebServiceSvc_AvionicsTechnologyType;
MFBWebServiceSvc_AvionicsTechnologyType MFBWebServiceSvc_AvionicsTechnologyType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AvionicsTechnologyType_stringFromEnum(MFBWebServiceSvc_AvionicsTechnologyType enumValue);
@interface MFBWebServiceSvc_Aircraft : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * InstanceTypeID;
	MFBWebServiceSvc_AircraftInstanceTypes InstanceType;
	NSString * InstanceTypeDescription;
	NSDate * LastVOR;
	NSDate * LastAltimeter;
	NSDate * LastTransponder;
	NSDate * LastELT;
	NSDate * LastStatic;
	NSNumber * Last100;
	NSNumber * LastOilChange;
	NSNumber * LastNewEngine;
	NSDate * LastAnnual;
	USBoolean * IsGlass;
	MFBWebServiceSvc_ArrayOfMFBImageInfo * AircraftImages;
	NSNumber * AircraftID;
	NSString * ModelCommonName;
	NSString * TailNumber;
	NSNumber * ModelID;
	NSString * ModelDescription;
	NSString * ErrorString;
	USBoolean * HideFromSelection;
	NSNumber * Version;
	NSString * DefaultImage;
	MFBWebServiceSvc_PilotRole RoleForPilot;
	NSDate * RegistrationDue;
	NSString * PublicNotes;
	NSString * PrivateNotes;
	NSString * ICAO;
	NSDate * GlassUpgradeDate;
	MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnologyUpgrade;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_Aircraft *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * InstanceTypeID;
@property (nonatomic, assign) MFBWebServiceSvc_AircraftInstanceTypes InstanceType;
@property (nonatomic, retain) NSString * InstanceTypeDescription;
@property (nonatomic, retain) NSDate * LastVOR;
@property (nonatomic, retain) NSDate * LastAltimeter;
@property (nonatomic, retain) NSDate * LastTransponder;
@property (nonatomic, retain) NSDate * LastELT;
@property (nonatomic, retain) NSDate * LastStatic;
@property (nonatomic, retain) NSNumber * Last100;
@property (nonatomic, retain) NSNumber * LastOilChange;
@property (nonatomic, retain) NSNumber * LastNewEngine;
@property (nonatomic, retain) NSDate * LastAnnual;
@property (nonatomic, retain) USBoolean * IsGlass;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfMFBImageInfo * AircraftImages;
@property (nonatomic, retain) NSNumber * AircraftID;
@property (nonatomic, retain) NSString * ModelCommonName;
@property (nonatomic, retain) NSString * TailNumber;
@property (nonatomic, retain) NSNumber * ModelID;
@property (nonatomic, retain) NSString * ModelDescription;
@property (nonatomic, retain) NSString * ErrorString;
@property (nonatomic, retain) USBoolean * HideFromSelection;
@property (nonatomic, retain) NSNumber * Version;
@property (nonatomic, retain) NSString * DefaultImage;
@property (nonatomic, assign) MFBWebServiceSvc_PilotRole RoleForPilot;
@property (nonatomic, retain) NSDate * RegistrationDue;
@property (nonatomic, retain) NSString * PublicNotes;
@property (nonatomic, retain) NSString * PrivateNotes;
@property (nonatomic, retain) NSString * ICAO;
@property (nonatomic, retain) NSDate * GlassUpgradeDate;
@property (nonatomic, assign) MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnologyUpgrade;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfAircraft : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *Aircraft;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfAircraft *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addAircraft:(MFBWebServiceSvc_Aircraft *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Aircraft;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AircraftForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfAircraft * AircraftForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AircraftForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfAircraft * AircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddAircraftForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSString * szTail;
	NSNumber * idModel;
	NSNumber * idInstanceType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AddAircraftForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSString * szTail;
@property (nonatomic, retain) NSNumber * idModel;
@property (nonatomic, retain) NSNumber * idInstanceType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddAircraftForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfAircraft * AddAircraftForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AddAircraftForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfAircraft * AddAircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraft : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_Aircraft * ac;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateMaintenanceForAircraft *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_Aircraft * ac;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_Aircraft * ac;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_Aircraft * ac;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteAircraftForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idAircraft;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteAircraftForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idAircraft;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteAircraftForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfAircraft * DeleteAircraftForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteAircraftForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfAircraft * DeleteAircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MakesAndModels : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_MakesAndModels *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_SimpleMakeModel : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * ModelID;
	NSString * Description;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_SimpleMakeModel *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * ModelID;
@property (nonatomic, retain) NSString * Description;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfSimpleMakeModel : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *SimpleMakeModel;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfSimpleMakeModel *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addSimpleMakeModel:(MFBWebServiceSvc_SimpleMakeModel *)toAdd;
@property (nonatomic, readonly) NSMutableArray * SimpleMakeModel;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MakesAndModelsResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfSimpleMakeModel * MakesAndModelsResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_MakesAndModelsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfSimpleMakeModel * MakesAndModelsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetCurrencyForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_GetCurrencyForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_CurrencyState_none = 0,
	MFBWebServiceSvc_CurrencyState_NotCurrent,
	MFBWebServiceSvc_CurrencyState_GettingClose,
	MFBWebServiceSvc_CurrencyState_OK,
	MFBWebServiceSvc_CurrencyState_NoDate,
} MFBWebServiceSvc_CurrencyState;
MFBWebServiceSvc_CurrencyState MFBWebServiceSvc_CurrencyState_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_CurrencyState_stringFromEnum(MFBWebServiceSvc_CurrencyState enumValue);
typedef enum {
	MFBWebServiceSvc_CurrencyGroups_none = 0,
	MFBWebServiceSvc_CurrencyGroups_None,
	MFBWebServiceSvc_CurrencyGroups_FlightExperience,
	MFBWebServiceSvc_CurrencyGroups_FlightReview,
	MFBWebServiceSvc_CurrencyGroups_Aircraft,
	MFBWebServiceSvc_CurrencyGroups_AircraftDeadline,
	MFBWebServiceSvc_CurrencyGroups_Certificates,
	MFBWebServiceSvc_CurrencyGroups_Medical,
	MFBWebServiceSvc_CurrencyGroups_Deadline,
	MFBWebServiceSvc_CurrencyGroups_CustomCurrency,
} MFBWebServiceSvc_CurrencyGroups;
MFBWebServiceSvc_CurrencyGroups MFBWebServiceSvc_CurrencyGroups_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_CurrencyGroups_stringFromEnum(MFBWebServiceSvc_CurrencyGroups enumValue);
typedef enum {
	MFBWebServiceSvc_DateRanges_none = 0,
	MFBWebServiceSvc_DateRanges_AllTime,
	MFBWebServiceSvc_DateRanges_YTD,
	MFBWebServiceSvc_DateRanges_Tailing6Months,
	MFBWebServiceSvc_DateRanges_Trailing12Months,
	MFBWebServiceSvc_DateRanges_ThisMonth,
	MFBWebServiceSvc_DateRanges_PrevMonth,
	MFBWebServiceSvc_DateRanges_PrevYear,
	MFBWebServiceSvc_DateRanges_Trailing30,
	MFBWebServiceSvc_DateRanges_Trailing90,
	MFBWebServiceSvc_DateRanges_Custom,
} MFBWebServiceSvc_DateRanges;
MFBWebServiceSvc_DateRanges MFBWebServiceSvc_DateRanges_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_DateRanges_stringFromEnum(MFBWebServiceSvc_DateRanges enumValue);
typedef enum {
	MFBWebServiceSvc_FlightDistance_none = 0,
	MFBWebServiceSvc_FlightDistance_AllFlights,
	MFBWebServiceSvc_FlightDistance_LocalOnly,
	MFBWebServiceSvc_FlightDistance_NonLocalOnly,
} MFBWebServiceSvc_FlightDistance;
MFBWebServiceSvc_FlightDistance MFBWebServiceSvc_FlightDistance_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_FlightDistance_stringFromEnum(MFBWebServiceSvc_FlightDistance enumValue);
typedef enum {
	MFBWebServiceSvc_CatClassID_none = 0,
	MFBWebServiceSvc_CatClassID_ASEL,
	MFBWebServiceSvc_CatClassID_AMEL,
	MFBWebServiceSvc_CatClassID_ASES,
	MFBWebServiceSvc_CatClassID_AMES,
	MFBWebServiceSvc_CatClassID_Glider,
	MFBWebServiceSvc_CatClassID_Helicopter,
	MFBWebServiceSvc_CatClassID_Gyroplane,
	MFBWebServiceSvc_CatClassID_PoweredLift,
	MFBWebServiceSvc_CatClassID_Airship,
	MFBWebServiceSvc_CatClassID_HotAirBalloon,
	MFBWebServiceSvc_CatClassID_GasBalloon,
	MFBWebServiceSvc_CatClassID_PoweredParachuteLand,
	MFBWebServiceSvc_CatClassID_PoweredParachuteSea,
	MFBWebServiceSvc_CatClassID_WeightShiftControlLand,
	MFBWebServiceSvc_CatClassID_WeightShiftControlSea,
	MFBWebServiceSvc_CatClassID_UnmannedAerialSystem,
	MFBWebServiceSvc_CatClassID_PoweredParaglider,
} MFBWebServiceSvc_CatClassID;
MFBWebServiceSvc_CatClassID MFBWebServiceSvc_CatClassID_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_CatClassID_stringFromEnum(MFBWebServiceSvc_CatClassID enumValue);
@interface MFBWebServiceSvc_CategoryClass : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * CatClass;
	NSString * Category_;
	NSString * Class_;
	NSNumber * AltCatClass;
	MFBWebServiceSvc_CatClassID IdCatClass;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CategoryClass *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * CatClass;
@property (nonatomic, retain) NSString * Category_;
@property (nonatomic, retain) NSString * Class_;
@property (nonatomic, retain) NSNumber * AltCatClass;
@property (nonatomic, assign) MFBWebServiceSvc_CatClassID IdCatClass;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCategoryClass : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *CategoryClass;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfCategoryClass *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addCategoryClass:(MFBWebServiceSvc_CategoryClass *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CategoryClass;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_CFPPropertyType_none = 0,
	MFBWebServiceSvc_CFPPropertyType_cfpInteger,
	MFBWebServiceSvc_CFPPropertyType_cfpDecimal,
	MFBWebServiceSvc_CFPPropertyType_cfpBoolean,
	MFBWebServiceSvc_CFPPropertyType_cfpDate,
	MFBWebServiceSvc_CFPPropertyType_cfpDateTime,
	MFBWebServiceSvc_CFPPropertyType_cfpString,
	MFBWebServiceSvc_CFPPropertyType_cfpCurrency,
} MFBWebServiceSvc_CFPPropertyType;
MFBWebServiceSvc_CFPPropertyType MFBWebServiceSvc_CFPPropertyType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_CFPPropertyType_stringFromEnum(MFBWebServiceSvc_CFPPropertyType enumValue);
@interface MFBWebServiceSvc_ArrayOfString : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *string;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfString *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addString:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * string;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CustomPropertyType : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * PropTypeID;
	NSString * Title;
	NSString * SortKey;
	USBoolean * IsFavorite;
	NSString * FormatString;
	MFBWebServiceSvc_CFPPropertyType Type;
	NSString * Description;
	NSNumber * Flags;
	MFBWebServiceSvc_ArrayOfString * PreviousValues;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CustomPropertyType *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * PropTypeID;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * SortKey;
@property (nonatomic, retain) USBoolean * IsFavorite;
@property (nonatomic, retain) NSString * FormatString;
@property (nonatomic, assign) MFBWebServiceSvc_CFPPropertyType Type;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSNumber * Flags;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfString * PreviousValues;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCustomPropertyType : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *CustomPropertyType;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfCustomPropertyType *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addCustomPropertyType:(MFBWebServiceSvc_CustomPropertyType *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CustomPropertyType;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_AllowedAircraftTypes_none = 0,
	MFBWebServiceSvc_AllowedAircraftTypes_Any,
	MFBWebServiceSvc_AllowedAircraftTypes_SimulatorOnly,
	MFBWebServiceSvc_AllowedAircraftTypes_SimOrAnonymous,
} MFBWebServiceSvc_AllowedAircraftTypes;
MFBWebServiceSvc_AllowedAircraftTypes MFBWebServiceSvc_AllowedAircraftTypes_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AllowedAircraftTypes_stringFromEnum(MFBWebServiceSvc_AllowedAircraftTypes enumValue);
typedef enum {
	MFBWebServiceSvc_HighPerfType_none = 0,
	MFBWebServiceSvc_HighPerfType_NotHighPerf,
	MFBWebServiceSvc_HighPerfType_HighPerf,
	MFBWebServiceSvc_HighPerfType_Is200HP,
} MFBWebServiceSvc_HighPerfType;
MFBWebServiceSvc_HighPerfType MFBWebServiceSvc_HighPerfType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_HighPerfType_stringFromEnum(MFBWebServiceSvc_HighPerfType enumValue);
typedef enum {
	MFBWebServiceSvc_TurbineLevel_none = 0,
	MFBWebServiceSvc_TurbineLevel_Piston,
	MFBWebServiceSvc_TurbineLevel_TurboProp,
	MFBWebServiceSvc_TurbineLevel_Jet,
	MFBWebServiceSvc_TurbineLevel_UnspecifiedTurbine,
	MFBWebServiceSvc_TurbineLevel_Electric,
} MFBWebServiceSvc_TurbineLevel;
MFBWebServiceSvc_TurbineLevel MFBWebServiceSvc_TurbineLevel_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_TurbineLevel_stringFromEnum(MFBWebServiceSvc_TurbineLevel enumValue);
@interface MFBWebServiceSvc_MakeModel : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_AllowedAircraftTypes AllowedTypes;
	NSString * CategoryClassDisplay;
	NSString * ManufacturerDisplay;
	MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnology;
	NSString * ArmyMDS;
	NSString * ErrorString;
	NSNumber * MakeModelID;
	NSString * Model;
	NSString * ModelName;
	NSString * TypeName;
	NSString * FamilyName;
	MFBWebServiceSvc_CatClassID CategoryClassID;
	NSNumber * ManufacturerID;
	USBoolean * IsComplex;
	USBoolean * IsHighPerf;
	USBoolean * Is200HP;
	MFBWebServiceSvc_HighPerfType PerformanceType;
	USBoolean * IsTailWheel;
	USBoolean * IsConstantProp;
	USBoolean * HasFlaps;
	USBoolean * IsRetract;
	MFBWebServiceSvc_TurbineLevel EngineType;
	USBoolean * IsCertifiedSinglePilot;
	USBoolean * IsMotorGlider;
	USBoolean * IsMultiEngineHelicopter;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_MakeModel *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, assign) MFBWebServiceSvc_AllowedAircraftTypes AllowedTypes;
@property (nonatomic, retain) NSString * CategoryClassDisplay;
@property (nonatomic, retain) NSString * ManufacturerDisplay;
@property (nonatomic, assign) MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnology;
@property (nonatomic, retain) NSString * ArmyMDS;
@property (nonatomic, retain) NSString * ErrorString;
@property (nonatomic, retain) NSNumber * MakeModelID;
@property (nonatomic, retain) NSString * Model;
@property (nonatomic, retain) NSString * ModelName;
@property (nonatomic, retain) NSString * TypeName;
@property (nonatomic, retain) NSString * FamilyName;
@property (nonatomic, assign) MFBWebServiceSvc_CatClassID CategoryClassID;
@property (nonatomic, retain) NSNumber * ManufacturerID;
@property (nonatomic, retain) USBoolean * IsComplex;
@property (nonatomic, retain) USBoolean * IsHighPerf;
@property (nonatomic, retain) USBoolean * Is200HP;
@property (nonatomic, assign) MFBWebServiceSvc_HighPerfType PerformanceType;
@property (nonatomic, retain) USBoolean * IsTailWheel;
@property (nonatomic, retain) USBoolean * IsConstantProp;
@property (nonatomic, retain) USBoolean * HasFlaps;
@property (nonatomic, retain) USBoolean * IsRetract;
@property (nonatomic, assign) MFBWebServiceSvc_TurbineLevel EngineType;
@property (nonatomic, retain) USBoolean * IsCertifiedSinglePilot;
@property (nonatomic, retain) USBoolean * IsMotorGlider;
@property (nonatomic, retain) USBoolean * IsMultiEngineHelicopter;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfMakeModel : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *MakeModel;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfMakeModel *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addMakeModel:(MFBWebServiceSvc_MakeModel *)toAdd;
@property (nonatomic, readonly) NSMutableArray * MakeModel;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_EngineTypeRestriction_none = 0,
	MFBWebServiceSvc_EngineTypeRestriction_AllEngines,
	MFBWebServiceSvc_EngineTypeRestriction_Piston,
	MFBWebServiceSvc_EngineTypeRestriction_Jet,
	MFBWebServiceSvc_EngineTypeRestriction_Turboprop,
	MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine,
	MFBWebServiceSvc_EngineTypeRestriction_Electric,
} MFBWebServiceSvc_EngineTypeRestriction;
MFBWebServiceSvc_EngineTypeRestriction MFBWebServiceSvc_EngineTypeRestriction_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_EngineTypeRestriction_stringFromEnum(MFBWebServiceSvc_EngineTypeRestriction enumValue);
typedef enum {
	MFBWebServiceSvc_AircraftInstanceRestriction_none = 0,
	MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft,
	MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly,
	MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly,
} MFBWebServiceSvc_AircraftInstanceRestriction;
MFBWebServiceSvc_AircraftInstanceRestriction MFBWebServiceSvc_AircraftInstanceRestriction_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AircraftInstanceRestriction_stringFromEnum(MFBWebServiceSvc_AircraftInstanceRestriction enumValue);
@interface MFBWebServiceSvc_FlightQuery : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_DateRanges DateRange;
	MFBWebServiceSvc_FlightDistance Distance;
	MFBWebServiceSvc_ArrayOfCategoryClass * CatClasses;
	MFBWebServiceSvc_ArrayOfCustomPropertyType * PropertyTypes;
	NSString * UserName;
	USBoolean * IsPublic;
	USBoolean * HasNightLandings;
	USBoolean * HasFullStopLandings;
	USBoolean * HasLandings;
	USBoolean * HasApproaches;
	USBoolean * HasHolds;
	USBoolean * HasXC;
	USBoolean * HasSimIMCTime;
	USBoolean * HasGroundSim;
	USBoolean * HasIMC;
	USBoolean * HasAnyInstrument;
	USBoolean * HasNight;
	USBoolean * HasDual;
	USBoolean * HasCFI;
	USBoolean * HasSIC;
	USBoolean * HasPIC;
	USBoolean * HasTotalTime;
	USBoolean * IsSigned;
	NSDate * DateMin;
	NSDate * DateMax;
	NSString * GeneralText;
	MFBWebServiceSvc_ArrayOfAircraft * AircraftList;
	MFBWebServiceSvc_ArrayOfString * AirportList;
	MFBWebServiceSvc_ArrayOfMakeModel * MakeList;
	NSString * ModelName;
	MFBWebServiceSvc_ArrayOfString * TypeNames;
	USBoolean * IsComplex;
	USBoolean * HasFlaps;
	USBoolean * IsHighPerformance;
	USBoolean * IsConstantSpeedProp;
	USBoolean * IsRetract;
	USBoolean * IsTechnicallyAdvanced;
	USBoolean * IsGlass;
	USBoolean * IsTailwheel;
	MFBWebServiceSvc_EngineTypeRestriction EngineType;
	USBoolean * IsMultiEngineHeli;
	USBoolean * IsTurbine;
	USBoolean * HasTelemetry;
	USBoolean * HasImages;
	USBoolean * IsMotorglider;
	MFBWebServiceSvc_AircraftInstanceRestriction AircraftInstanceTypes;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightQuery *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, assign) MFBWebServiceSvc_DateRanges DateRange;
@property (nonatomic, assign) MFBWebServiceSvc_FlightDistance Distance;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCategoryClass * CatClasses;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCustomPropertyType * PropertyTypes;
@property (nonatomic, retain) NSString * UserName;
@property (nonatomic, retain) USBoolean * IsPublic;
@property (nonatomic, retain) USBoolean * HasNightLandings;
@property (nonatomic, retain) USBoolean * HasFullStopLandings;
@property (nonatomic, retain) USBoolean * HasLandings;
@property (nonatomic, retain) USBoolean * HasApproaches;
@property (nonatomic, retain) USBoolean * HasHolds;
@property (nonatomic, retain) USBoolean * HasXC;
@property (nonatomic, retain) USBoolean * HasSimIMCTime;
@property (nonatomic, retain) USBoolean * HasGroundSim;
@property (nonatomic, retain) USBoolean * HasIMC;
@property (nonatomic, retain) USBoolean * HasAnyInstrument;
@property (nonatomic, retain) USBoolean * HasNight;
@property (nonatomic, retain) USBoolean * HasDual;
@property (nonatomic, retain) USBoolean * HasCFI;
@property (nonatomic, retain) USBoolean * HasSIC;
@property (nonatomic, retain) USBoolean * HasPIC;
@property (nonatomic, retain) USBoolean * HasTotalTime;
@property (nonatomic, retain) USBoolean * IsSigned;
@property (nonatomic, retain) NSDate * DateMin;
@property (nonatomic, retain) NSDate * DateMax;
@property (nonatomic, retain) NSString * GeneralText;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfAircraft * AircraftList;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfString * AirportList;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfMakeModel * MakeList;
@property (nonatomic, retain) NSString * ModelName;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfString * TypeNames;
@property (nonatomic, retain) USBoolean * IsComplex;
@property (nonatomic, retain) USBoolean * HasFlaps;
@property (nonatomic, retain) USBoolean * IsHighPerformance;
@property (nonatomic, retain) USBoolean * IsConstantSpeedProp;
@property (nonatomic, retain) USBoolean * IsRetract;
@property (nonatomic, retain) USBoolean * IsTechnicallyAdvanced;
@property (nonatomic, retain) USBoolean * IsGlass;
@property (nonatomic, retain) USBoolean * IsTailwheel;
@property (nonatomic, assign) MFBWebServiceSvc_EngineTypeRestriction EngineType;
@property (nonatomic, retain) USBoolean * IsMultiEngineHeli;
@property (nonatomic, retain) USBoolean * IsTurbine;
@property (nonatomic, retain) USBoolean * HasTelemetry;
@property (nonatomic, retain) USBoolean * HasImages;
@property (nonatomic, retain) USBoolean * IsMotorglider;
@property (nonatomic, assign) MFBWebServiceSvc_AircraftInstanceRestriction AircraftInstanceTypes;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CurrencyStatusItem : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * Attribute;
	NSString * Value;
	MFBWebServiceSvc_CurrencyState Status;
	NSString * Discrepancy;
	NSNumber * AssociatedResourceID;
	MFBWebServiceSvc_CurrencyGroups CurrencyGroup;
	MFBWebServiceSvc_FlightQuery * Query;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CurrencyStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * Attribute;
@property (nonatomic, retain) NSString * Value;
@property (nonatomic, assign) MFBWebServiceSvc_CurrencyState Status;
@property (nonatomic, retain) NSString * Discrepancy;
@property (nonatomic, retain) NSNumber * AssociatedResourceID;
@property (nonatomic, assign) MFBWebServiceSvc_CurrencyGroups CurrencyGroup;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * Query;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCurrencyStatusItem : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *CurrencyStatusItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfCurrencyStatusItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addCurrencyStatusItem:(MFBWebServiceSvc_CurrencyStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CurrencyStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetCurrencyForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCurrencyStatusItem * GetCurrencyForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_GetCurrencyForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCurrencyStatusItem * GetCurrencyForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	NSDate * dtMin;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
@property (nonatomic, retain) NSDate * dtMin;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_NumType_none = 0,
	MFBWebServiceSvc_NumType_Integer,
	MFBWebServiceSvc_NumType_Decimal,
	MFBWebServiceSvc_NumType_Time,
	MFBWebServiceSvc_NumType_Currency,
} MFBWebServiceSvc_NumType;
MFBWebServiceSvc_NumType MFBWebServiceSvc_NumType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_NumType_stringFromEnum(MFBWebServiceSvc_NumType enumValue);
@interface MFBWebServiceSvc_TotalsItem : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * Value;
	NSString * Description;
	NSString * SubDescription;
	MFBWebServiceSvc_NumType NumericType;
	USBoolean * IsInt;
	USBoolean * IsTime;
	USBoolean * IsCurrency;
	MFBWebServiceSvc_FlightQuery * Query;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * Value;
@property (nonatomic, retain) NSString * Description;
@property (nonatomic, retain) NSString * SubDescription;
@property (nonatomic, assign) MFBWebServiceSvc_NumType NumericType;
@property (nonatomic, retain) USBoolean * IsInt;
@property (nonatomic, retain) USBoolean * IsTime;
@property (nonatomic, retain) USBoolean * IsCurrency;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * Query;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfTotalsItem : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *TotalsItem;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfTotalsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addTotalsItem:(MFBWebServiceSvc_TotalsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TotalsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserWithQuery : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	MFBWebServiceSvc_FlightQuery * fq;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsForUserWithQuery *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * fq;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserWithQueryResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserWithQueryResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsForUserWithQueryResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserWithQueryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirports : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_VisitedAirports *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_airport : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * DistanceFromPosition;
	NSString * UserName;
	NSString * FacilityTypeCode;
	NSString * FacilityType;
	NSString * Code;
	NSString * Name;
	MFBWebServiceSvc_LatLong * LatLong;
	NSString * Latitude;
	NSString * Longitude;
	NSString * ErrorText;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_airport *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * DistanceFromPosition;
@property (nonatomic, retain) NSString * UserName;
@property (nonatomic, retain) NSString * FacilityTypeCode;
@property (nonatomic, retain) NSString * FacilityType;
@property (nonatomic, retain) NSString * Code;
@property (nonatomic, retain) NSString * Name;
@property (nonatomic, retain) MFBWebServiceSvc_LatLong * LatLong;
@property (nonatomic, retain) NSString * Latitude;
@property (nonatomic, retain) NSString * Longitude;
@property (nonatomic, retain) NSString * ErrorText;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirport : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * Code;
	NSString * Aliases;
	MFBWebServiceSvc_airport * Airport;
	NSDate * EarliestVisitDate;
	NSDate * LatestVisitDate;
	NSNumber * NumberOfVisits;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_VisitedAirport *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * Code;
@property (nonatomic, retain) NSString * Aliases;
@property (nonatomic, retain) MFBWebServiceSvc_airport * Airport;
@property (nonatomic, retain) NSDate * EarliestVisitDate;
@property (nonatomic, retain) NSDate * LatestVisitDate;
@property (nonatomic, retain) NSNumber * NumberOfVisits;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfVisitedAirport : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *VisitedAirport;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfVisitedAirport *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addVisitedAirport:(MFBWebServiceSvc_VisitedAirport *)toAdd;
@property (nonatomic, readonly) NSMutableArray * VisitedAirport;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirportsResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfVisitedAirport * VisitedAirportsResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_VisitedAirportsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfVisitedAirport * VisitedAirportsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryAndOffset : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_FlightQuery * fq;
	NSNumber * offset;
	NSNumber * maxCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightsWithQueryAndOffset *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * maxCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CustomFlightProperty : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * PropID;
	NSNumber * FlightID;
	NSNumber * PropTypeID;
	NSNumber * IntValue;
	USBoolean * BoolValue;
	NSNumber * DecValue;
	NSDate * DateValue;
	NSString * TextValue;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CustomFlightProperty *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * PropID;
@property (nonatomic, retain) NSNumber * FlightID;
@property (nonatomic, retain) NSNumber * PropTypeID;
@property (nonatomic, retain) NSNumber * IntValue;
@property (nonatomic, retain) USBoolean * BoolValue;
@property (nonatomic, retain) NSNumber * DecValue;
@property (nonatomic, retain) NSDate * DateValue;
@property (nonatomic, retain) NSString * TextValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCustomFlightProperty : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *CustomFlightProperty;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfCustomFlightProperty *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addCustomFlightProperty:(MFBWebServiceSvc_CustomFlightProperty *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CustomFlightProperty;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_VideoSource_none = 0,
	MFBWebServiceSvc_VideoSource_Unknown,
	MFBWebServiceSvc_VideoSource_YouTube,
	MFBWebServiceSvc_VideoSource_Vimeo,
} MFBWebServiceSvc_VideoSource;
MFBWebServiceSvc_VideoSource MFBWebServiceSvc_VideoSource_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_VideoSource_stringFromEnum(MFBWebServiceSvc_VideoSource enumValue);
@interface MFBWebServiceSvc_VideoRef : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * ID_;
	NSNumber * FlightID;
	NSString * VideoReference;
	MFBWebServiceSvc_VideoSource Source;
	NSString * Comment;
	NSString * ErrorString;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_VideoRef *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * ID_;
@property (nonatomic, retain) NSNumber * FlightID;
@property (nonatomic, retain) NSString * VideoReference;
@property (nonatomic, assign) MFBWebServiceSvc_VideoSource Source;
@property (nonatomic, retain) NSString * Comment;
@property (nonatomic, retain) NSString * ErrorString;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfVideoRef : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *VideoRef;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfVideoRef *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addVideoRef:(MFBWebServiceSvc_VideoRef *)toAdd;
@property (nonatomic, readonly) NSMutableArray * VideoRef;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_SignatureState_none = 0,
	MFBWebServiceSvc_SignatureState_None,
	MFBWebServiceSvc_SignatureState_Valid,
	MFBWebServiceSvc_SignatureState_Invalid,
} MFBWebServiceSvc_SignatureState;
MFBWebServiceSvc_SignatureState MFBWebServiceSvc_SignatureState_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_SignatureState_stringFromEnum(MFBWebServiceSvc_SignatureState enumValue);
@interface MFBWebServiceSvc_LogbookEntry : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * User;
	NSNumber * AircraftID;
	NSNumber * CatClassOverride;
	NSNumber * NightLandings;
	NSNumber * FullStopLandings;
	NSNumber * Approaches;
	NSNumber * PrecisionApproaches;
	NSNumber * NonPrecisionApproaches;
	NSNumber * Landings;
	NSNumber * CrossCountry;
	NSNumber * Nighttime;
	NSNumber * IMC;
	NSNumber * SimulatedIFR;
	NSNumber * GroundSim;
	NSNumber * Dual;
	NSNumber * CFI;
	NSNumber * PIC;
	NSNumber * SIC;
	NSNumber * TotalFlightTime;
	USBoolean * fHoldingProcedures;
	NSString * Route;
	NSString * Comment;
	USBoolean * fIsPublic;
	NSDate * Date;
	NSString * ErrorString;
	NSNumber * FlightID;
	NSDate * FlightStart;
	NSDate * FlightEnd;
	NSDate * EngineStart;
	NSDate * EngineEnd;
	NSNumber * HobbsStart;
	NSNumber * HobbsEnd;
	NSString * ModelDisplay;
	NSString * TailNumDisplay;
	NSString * CatClassDisplay;
	NSString * FlightData;
	MFBWebServiceSvc_ArrayOfCustomFlightProperty * CustomProperties;
	MFBWebServiceSvc_ArrayOfMFBImageInfo * FlightImages;
	MFBWebServiceSvc_ArrayOfVideoRef * Videos;
	NSString * CFIComments;
	NSDate * CFISignatureDate;
	NSString * CFICertificate;
	NSDate * CFIExpiration;
	NSString * CFIEmail;
	NSString * CFIName;
	MFBWebServiceSvc_SignatureState CFISignatureState;
	NSData * DigitizedSignature;
	USBoolean * HasDigitizedSig;
	NSString * SendFlightLink;
	NSString * SocialMediaLink;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_LogbookEntry *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * User;
@property (nonatomic, retain) NSNumber * AircraftID;
@property (nonatomic, retain) NSNumber * CatClassOverride;
@property (nonatomic, retain) NSNumber * NightLandings;
@property (nonatomic, retain) NSNumber * FullStopLandings;
@property (nonatomic, retain) NSNumber * Approaches;
@property (nonatomic, retain) NSNumber * PrecisionApproaches;
@property (nonatomic, retain) NSNumber * NonPrecisionApproaches;
@property (nonatomic, retain) NSNumber * Landings;
@property (nonatomic, retain) NSNumber * CrossCountry;
@property (nonatomic, retain) NSNumber * Nighttime;
@property (nonatomic, retain) NSNumber * IMC;
@property (nonatomic, retain) NSNumber * SimulatedIFR;
@property (nonatomic, retain) NSNumber * GroundSim;
@property (nonatomic, retain) NSNumber * Dual;
@property (nonatomic, retain) NSNumber * CFI;
@property (nonatomic, retain) NSNumber * PIC;
@property (nonatomic, retain) NSNumber * SIC;
@property (nonatomic, retain) NSNumber * TotalFlightTime;
@property (nonatomic, retain) USBoolean * fHoldingProcedures;
@property (nonatomic, retain) NSString * Route;
@property (nonatomic, retain) NSString * Comment;
@property (nonatomic, retain) USBoolean * fIsPublic;
@property (nonatomic, retain) NSDate * Date;
@property (nonatomic, retain) NSString * ErrorString;
@property (nonatomic, retain) NSNumber * FlightID;
@property (nonatomic, retain) NSDate * FlightStart;
@property (nonatomic, retain) NSDate * FlightEnd;
@property (nonatomic, retain) NSDate * EngineStart;
@property (nonatomic, retain) NSDate * EngineEnd;
@property (nonatomic, retain) NSNumber * HobbsStart;
@property (nonatomic, retain) NSNumber * HobbsEnd;
@property (nonatomic, retain) NSString * ModelDisplay;
@property (nonatomic, retain) NSString * TailNumDisplay;
@property (nonatomic, retain) NSString * CatClassDisplay;
@property (nonatomic, retain) NSString * FlightData;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCustomFlightProperty * CustomProperties;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfMFBImageInfo * FlightImages;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfVideoRef * Videos;
@property (nonatomic, retain) NSString * CFIComments;
@property (nonatomic, retain) NSDate * CFISignatureDate;
@property (nonatomic, retain) NSString * CFICertificate;
@property (nonatomic, retain) NSDate * CFIExpiration;
@property (nonatomic, retain) NSString * CFIEmail;
@property (nonatomic, retain) NSString * CFIName;
@property (nonatomic, assign) MFBWebServiceSvc_SignatureState CFISignatureState;
@property (nonatomic, retain) NSData * DigitizedSignature;
@property (nonatomic, retain) USBoolean * HasDigitizedSig;
@property (nonatomic, retain) NSString * SendFlightLink;
@property (nonatomic, retain) NSString * SocialMediaLink;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfLogbookEntry : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *LogbookEntry;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfLogbookEntry *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addLogbookEntry:(MFBWebServiceSvc_LogbookEntry *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LogbookEntry;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryAndOffsetResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryAndOffsetResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQuery : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_FlightQuery * fq;
	NSNumber * maxCount;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightsWithQuery *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, retain) NSNumber * maxCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightsWithQueryResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteLogbookEntry : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteLogbookEntry *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteLogbookEntryResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	USBoolean * DeleteLogbookEntryResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteLogbookEntryResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) USBoolean * DeleteLogbookEntryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PostingOptions : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PostingOptions *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitFlightWithOptions : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_LogbookEntry * le;
	MFBWebServiceSvc_PostingOptions * po;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CommitFlightWithOptions *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_LogbookEntry * le;
@property (nonatomic, retain) MFBWebServiceSvc_PostingOptions * po;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitFlightWithOptionsResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_LogbookEntry * CommitFlightWithOptionsResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CommitFlightWithOptionsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_LogbookEntry * CommitFlightWithOptionsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlight : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightPathForFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfLatLong : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *LatLong;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfLatLong *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addLatLong:(MFBWebServiceSvc_LatLong *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LatLong;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfLatLong * FlightPathForFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightPathForFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfLatLong * FlightPathForFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightGPX : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightPathForFlightGPX *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightGPXResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * FlightPathForFlightGPXResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_FlightPathForFlightGPXResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * FlightPathForFlightGPXResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypes : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AvailablePropertyTypes *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AvailablePropertyTypesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AvailablePropertyTypesForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AvailablePropertyTypesForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesForFlight : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PropertiesForFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesForFlightResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCustomFlightProperty * PropertiesForFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PropertiesForFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCustomFlightProperty * PropertiesForFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfInt : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *int_;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfInt *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addInt_:(NSNumber *)toAdd;
@property (nonatomic, readonly) NSMutableArray * int_;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertiesForFlight : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
	MFBWebServiceSvc_ArrayOfInt * rgPropIds;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePropertiesForFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfInt * rgPropIds;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertiesForFlightResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePropertiesForFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertyForFlight : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSNumber * idFlight;
	NSNumber * propId;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePropertyForFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) NSNumber * idFlight;
@property (nonatomic, retain) NSNumber * propId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertyForFlightResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePropertyForFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteImage : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteImage *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteImageResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteImageResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateImageAnnotation : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateImageAnnotation *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthUserToken;
@property (nonatomic, retain) MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateImageAnnotationResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdateImageAnnotationResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAppToken;
	NSString * szUser;
	NSString * szPass;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AuthTokenForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAppToken;
@property (nonatomic, retain) NSString * szUser;
@property (nonatomic, retain) NSString * szPass;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * AuthTokenForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AuthTokenForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * AuthTokenForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreateUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAppToken;
	NSString * szEmail;
	NSString * szPass;
	NSString * szFirst;
	NSString * szLast;
	NSString * szQuestion;
	NSString * szAnswer;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CreateUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAppToken;
@property (nonatomic, retain) NSString * szEmail;
@property (nonatomic, retain) NSString * szPass;
@property (nonatomic, retain) NSString * szFirst;
@property (nonatomic, retain) NSString * szLast;
@property (nonatomic, retain) NSString * szQuestion;
@property (nonatomic, retain) NSString * szAnswer;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_MembershipCreateStatus_none = 0,
	MFBWebServiceSvc_MembershipCreateStatus_Success,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidUserName,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidPassword,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidQuestion,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidAnswer,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidEmail,
	MFBWebServiceSvc_MembershipCreateStatus_DuplicateUserName,
	MFBWebServiceSvc_MembershipCreateStatus_DuplicateEmail,
	MFBWebServiceSvc_MembershipCreateStatus_UserRejected,
	MFBWebServiceSvc_MembershipCreateStatus_InvalidProviderUserKey,
	MFBWebServiceSvc_MembershipCreateStatus_DuplicateProviderUserKey,
	MFBWebServiceSvc_MembershipCreateStatus_ProviderError,
} MFBWebServiceSvc_MembershipCreateStatus;
MFBWebServiceSvc_MembershipCreateStatus MFBWebServiceSvc_MembershipCreateStatus_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_MembershipCreateStatus_stringFromEnum(MFBWebServiceSvc_MembershipCreateStatus enumValue);
@interface MFBWebServiceSvc_UserEntity : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	NSString * szUsername;
	MFBWebServiceSvc_MembershipCreateStatus mcs;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UserEntity *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
@property (nonatomic, retain) NSString * szUsername;
@property (nonatomic, assign) MFBWebServiceSvc_MembershipCreateStatus mcs;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreateUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_UserEntity * CreateUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CreateUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_UserEntity * CreateUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetNamedQueriesForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_GetNamedQueriesForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CannedQuery : MFBWebServiceSvc_FlightQuery {
/* elements */
	NSString * QueryName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CannedQuery *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, retain) NSString * QueryName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCannedQuery : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *CannedQuery;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfCannedQuery *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addCannedQuery:(MFBWebServiceSvc_CannedQuery *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CannedQuery;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetNamedQueriesForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCannedQuery * GetNamedQueriesForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_GetNamedQueriesForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCannedQuery * GetNamedQueriesForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddNamedQueryForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	MFBWebServiceSvc_FlightQuery * fq;
	NSString * szName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AddNamedQueryForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
@property (nonatomic, retain) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, retain) NSString * szName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddNamedQueryForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCannedQuery * AddNamedQueryForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AddNamedQueryForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCannedQuery * AddNamedQueryForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteNamedQueryForUser : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	MFBWebServiceSvc_CannedQuery * cq;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteNamedQueryForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * szAuthToken;
@property (nonatomic, retain) MFBWebServiceSvc_CannedQuery * cq;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteNamedQueryForUserResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCannedQuery * DeleteNamedQueryForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeleteNamedQueryForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfCannedQuery * DeleteNamedQueryForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_SuggestModels : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * prefixText;
	NSNumber * count;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_SuggestModels *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * prefixText;
@property (nonatomic, retain) NSNumber * count;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_SuggestModelsResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfString * SuggestModelsResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_SuggestModelsResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfString * SuggestModelsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PreviouslyUsedTextProperties : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * prefixText;
	NSNumber * count;
	NSString * contextKey;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PreviouslyUsedTextProperties *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSString * prefixText;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * contextKey;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PreviouslyUsedTextPropertiesResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfString * PreviouslyUsedTextPropertiesResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PreviouslyUsedTextPropertiesResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfString * PreviouslyUsedTextPropertiesResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AirportsInBoundingBox : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * latSouth;
	NSNumber * lonWest;
	NSNumber * latNorth;
	NSNumber * lonEast;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AirportsInBoundingBox *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) NSNumber * latSouth;
@property (nonatomic, retain) NSNumber * lonWest;
@property (nonatomic, retain) NSNumber * latNorth;
@property (nonatomic, retain) NSNumber * lonEast;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfAirport : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *airport;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfAirport *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
- (void)addAirport:(MFBWebServiceSvc_airport *)toAdd;
@property (nonatomic, readonly) NSMutableArray * airport;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AirportsInBoundingBoxResponse : NSObject <NSCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfAirport * AirportsInBoundingBoxResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AirportsInBoundingBoxResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (retain) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, retain) MFBWebServiceSvc_ArrayOfAirport * AirportsInBoundingBoxResult;
/* attributes */
- (NSDictionary *)attributes;
@end
/* Cookies handling provided by http://en.wikibooks.org/wiki/Programming:WebObjects/Web_Services/Web_Service_Provider */
#import <libxml/parser.h>
#import "xsd.h"
#import "MFBWebServiceSvc.h"
@class MFBWebServiceSoapBinding;
@class MFBWebServiceSoap12Binding;
@interface MFBWebServiceSvc : NSObject {
	
}
+ (MFBWebServiceSoapBinding *)MFBWebServiceSoapBinding;
+ (MFBWebServiceSoap12Binding *)MFBWebServiceSoap12Binding;
@end
@class MFBWebServiceSoapBindingResponse;
@class MFBWebServiceSoapBindingOperation;
@protocol MFBWebServiceSoapBindingResponseDelegate <NSObject>
- (void) operation:(MFBWebServiceSoapBindingOperation *)operation completedWithResponse:(MFBWebServiceSoapBindingResponse *)response;
@end
#define kServerAnchorCertificates   @"kServerAnchorCertificates"
#define kServerAnchorsOnly          @"kServerAnchorsOnly"
#define kClientIdentity             @"kClientIdentity"
#define kClientCertificates         @"kClientCertificates"
#define kClientUsername             @"kClientUsername"
#define kClientPassword             @"kClientPassword"
#define kNSURLCredentialPersistence @"kNSURLCredentialPersistence"
#define kValidateResult             @"kValidateResult"
@interface MFBWebServiceSoapBinding : NSObject <MFBWebServiceSoapBindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval timeout;
	NSMutableArray *cookies;
	NSMutableDictionary *customHeaders;
	BOOL logXMLInOut;
	BOOL ignoreEmptyResponse;
	BOOL synchronousOperationComplete;
	id<SSLCredentialsManaging> sslManager;
	SOAPSigner *soapSigner;
}
@property (nonatomic, copy) NSURL *address;
@property (nonatomic) BOOL logXMLInOut;
@property (nonatomic) BOOL ignoreEmptyResponse;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSMutableDictionary *customHeaders;
@property (nonatomic, retain) id<SSLCredentialsManaging> sslManager;
@property (nonatomic, retain) SOAPSigner *soapSigner;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(MFBWebServiceSoapBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (MFBWebServiceSoapBindingResponse *)AircraftForUserUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters ;
- (void)AircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AddAircraftForUserUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters ;
- (void)AddAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)UpdateMaintenanceForAircraftUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters ;
- (void)UpdateMaintenanceForAircraftAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)UpdateMaintenanceForAircraftWithFlagsAndNotesUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters ;
- (void)UpdateMaintenanceForAircraftWithFlagsAndNotesAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeleteAircraftForUserUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters ;
- (void)DeleteAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)MakesAndModelsUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters ;
- (void)MakesAndModelsAsyncUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)GetCurrencyForUserUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters ;
- (void)GetCurrencyForUserAsyncUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)TotalsForUserUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters ;
- (void)TotalsForUserAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)TotalsForUserWithQueryUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters ;
- (void)TotalsForUserWithQueryAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)VisitedAirportsUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters ;
- (void)VisitedAirportsAsyncUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)FlightsWithQueryAndOffsetUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters ;
- (void)FlightsWithQueryAndOffsetAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)FlightsWithQueryUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters ;
- (void)FlightsWithQueryAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeleteLogbookEntryUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters ;
- (void)DeleteLogbookEntryAsyncUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)CommitFlightWithOptionsUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters ;
- (void)CommitFlightWithOptionsAsyncUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)FlightPathForFlightUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters ;
- (void)FlightPathForFlightAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)FlightPathForFlightGPXUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters ;
- (void)FlightPathForFlightGPXAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AvailablePropertyTypesUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters ;
- (void)AvailablePropertyTypesAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AvailablePropertyTypesForUserUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters ;
- (void)AvailablePropertyTypesForUserAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)PropertiesForFlightUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters ;
- (void)PropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeletePropertiesForFlightUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters ;
- (void)DeletePropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeletePropertyForFlightUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters ;
- (void)DeletePropertyForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeleteImageUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters ;
- (void)DeleteImageAsyncUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)UpdateImageAnnotationUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters ;
- (void)UpdateImageAnnotationAsyncUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AuthTokenForUserUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters ;
- (void)AuthTokenForUserAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)CreateUserUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters ;
- (void)CreateUserAsyncUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)GetNamedQueriesForUserUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters ;
- (void)GetNamedQueriesForUserAsyncUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AddNamedQueryForUserUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters ;
- (void)AddNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)DeleteNamedQueryForUserUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters ;
- (void)DeleteNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)SuggestModelsUsingParameters:(MFBWebServiceSvc_SuggestModels *)aParameters ;
- (void)SuggestModelsAsyncUsingParameters:(MFBWebServiceSvc_SuggestModels *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)PreviouslyUsedTextPropertiesUsingParameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters ;
- (void)PreviouslyUsedTextPropertiesAsyncUsingParameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoapBindingResponse *)AirportsInBoundingBoxUsingParameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters ;
- (void)AirportsInBoundingBoxAsyncUsingParameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
@end
@interface MFBWebServiceSoapBindingOperation : NSOperation {
	MFBWebServiceSoapBinding *binding;
	MFBWebServiceSoapBindingResponse *response;
	id<MFBWebServiceSoapBindingResponseDelegate> delegate;
	NSMutableData *responseData;
}
@property (nonatomic, retain) MFBWebServiceSoapBinding *binding;
@property (nonatomic, readonly) MFBWebServiceSoapBindingResponse *response;
@property (nonatomic, assign) id<MFBWebServiceSoapBindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate;
- (void)didFailWithError:(NSError *)error;
- (void)didReceiveResponse:(NSURLResponse *)urlResponse;
- (void)didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading;
@end
@interface MFBWebServiceSoapBinding_AircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AddAircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AddAircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AddAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateMaintenanceForAircraft : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateMaintenanceForAircraftWithFlagsAndNotes : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteAircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteAircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_MakesAndModels : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_MakesAndModels * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_MakesAndModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_MakesAndModels *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_GetCurrencyForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_GetCurrencyForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_GetCurrencyForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_TotalsForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_TotalsForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_TotalsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_TotalsForUserWithQuery : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_VisitedAirports : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_VisitedAirports * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_VisitedAirports * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_VisitedAirports *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightsWithQueryAndOffset : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightsWithQuery : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightsWithQuery * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightsWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteLogbookEntry : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteLogbookEntry * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteLogbookEntry * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CommitFlightWithOptions : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CommitFlightWithOptions * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_CommitFlightWithOptions * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightPathForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightPathForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightPathForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightPathForFlightGPX : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AvailablePropertyTypes : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypes * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AvailablePropertyTypes * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AvailablePropertyTypesForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_PropertiesForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_PropertiesForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_PropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeletePropertiesForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeletePropertyForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeletePropertyForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeletePropertyForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteImage : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteImage * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteImage * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteImage *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateImageAnnotation : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateImageAnnotation * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateImageAnnotation * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AuthTokenForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AuthTokenForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AuthTokenForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CreateUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CreateUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_CreateUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreateUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_GetNamedQueriesForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AddNamedQueryForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AddNamedQueryForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AddNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteNamedQueryForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_SuggestModels : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_SuggestModels * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_SuggestModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_SuggestModels *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_PreviouslyUsedTextProperties : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_PreviouslyUsedTextProperties * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_PreviouslyUsedTextProperties * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AirportsInBoundingBox : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AirportsInBoundingBox * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AirportsInBoundingBox * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_envelope : NSObject {
}
+ (MFBWebServiceSoapBinding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface MFBWebServiceSoapBindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
@class MFBWebServiceSoap12BindingResponse;
@class MFBWebServiceSoap12BindingOperation;
@protocol MFBWebServiceSoap12BindingResponseDelegate <NSObject>
- (void) operation:(MFBWebServiceSoap12BindingOperation *)operation completedWithResponse:(MFBWebServiceSoap12BindingResponse *)response;
@end
#define kServerAnchorCertificates   @"kServerAnchorCertificates"
#define kServerAnchorsOnly          @"kServerAnchorsOnly"
#define kClientIdentity             @"kClientIdentity"
#define kClientCertificates         @"kClientCertificates"
#define kClientUsername             @"kClientUsername"
#define kClientPassword             @"kClientPassword"
#define kNSURLCredentialPersistence @"kNSURLCredentialPersistence"
#define kValidateResult             @"kValidateResult"
@interface MFBWebServiceSoap12Binding : NSObject <MFBWebServiceSoap12BindingResponseDelegate> {
	NSURL *address;
	NSTimeInterval timeout;
	NSMutableArray *cookies;
	NSMutableDictionary *customHeaders;
	BOOL logXMLInOut;
	BOOL ignoreEmptyResponse;
	BOOL synchronousOperationComplete;
	id<SSLCredentialsManaging> sslManager;
	SOAPSigner *soapSigner;
}
@property (nonatomic, copy) NSURL *address;
@property (nonatomic) BOOL logXMLInOut;
@property (nonatomic) BOOL ignoreEmptyResponse;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic, retain) NSMutableArray *cookies;
@property (nonatomic, retain) NSMutableDictionary *customHeaders;
@property (nonatomic, retain) id<SSLCredentialsManaging> sslManager;
@property (nonatomic, retain) SOAPSigner *soapSigner;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(MFBWebServiceSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (MFBWebServiceSoap12BindingResponse *)AircraftForUserUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters ;
- (void)AircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AddAircraftForUserUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters ;
- (void)AddAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)UpdateMaintenanceForAircraftUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters ;
- (void)UpdateMaintenanceForAircraftAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)UpdateMaintenanceForAircraftWithFlagsAndNotesUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters ;
- (void)UpdateMaintenanceForAircraftWithFlagsAndNotesAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeleteAircraftForUserUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters ;
- (void)DeleteAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)MakesAndModelsUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters ;
- (void)MakesAndModelsAsyncUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)GetCurrencyForUserUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters ;
- (void)GetCurrencyForUserAsyncUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)TotalsForUserUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters ;
- (void)TotalsForUserAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)TotalsForUserWithQueryUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters ;
- (void)TotalsForUserWithQueryAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)VisitedAirportsUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters ;
- (void)VisitedAirportsAsyncUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)FlightsWithQueryAndOffsetUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters ;
- (void)FlightsWithQueryAndOffsetAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)FlightsWithQueryUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters ;
- (void)FlightsWithQueryAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeleteLogbookEntryUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters ;
- (void)DeleteLogbookEntryAsyncUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)CommitFlightWithOptionsUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters ;
- (void)CommitFlightWithOptionsAsyncUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)FlightPathForFlightUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters ;
- (void)FlightPathForFlightAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)FlightPathForFlightGPXUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters ;
- (void)FlightPathForFlightGPXAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AvailablePropertyTypesUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters ;
- (void)AvailablePropertyTypesAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AvailablePropertyTypesForUserUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters ;
- (void)AvailablePropertyTypesForUserAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)PropertiesForFlightUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters ;
- (void)PropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeletePropertiesForFlightUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters ;
- (void)DeletePropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeletePropertyForFlightUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters ;
- (void)DeletePropertyForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeleteImageUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters ;
- (void)DeleteImageAsyncUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)UpdateImageAnnotationUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters ;
- (void)UpdateImageAnnotationAsyncUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AuthTokenForUserUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters ;
- (void)AuthTokenForUserAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)CreateUserUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters ;
- (void)CreateUserAsyncUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)GetNamedQueriesForUserUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters ;
- (void)GetNamedQueriesForUserAsyncUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AddNamedQueryForUserUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters ;
- (void)AddNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)DeleteNamedQueryForUserUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters ;
- (void)DeleteNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)SuggestModelsUsingParameters:(MFBWebServiceSvc_SuggestModels *)aParameters ;
- (void)SuggestModelsAsyncUsingParameters:(MFBWebServiceSvc_SuggestModels *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)PreviouslyUsedTextPropertiesUsingParameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters ;
- (void)PreviouslyUsedTextPropertiesAsyncUsingParameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (MFBWebServiceSoap12BindingResponse *)AirportsInBoundingBoxUsingParameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters ;
- (void)AirportsInBoundingBoxAsyncUsingParameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface MFBWebServiceSoap12BindingOperation : NSOperation {
	MFBWebServiceSoap12Binding *binding;
	MFBWebServiceSoap12BindingResponse *response;
	id<MFBWebServiceSoap12BindingResponseDelegate> delegate;
	NSMutableData *responseData;
}
@property (nonatomic, retain) MFBWebServiceSoap12Binding *binding;
@property (nonatomic, readonly) MFBWebServiceSoap12BindingResponse *response;
@property (nonatomic, assign) id<MFBWebServiceSoap12BindingResponseDelegate> delegate;
@property (nonatomic, retain) NSMutableData *responseData;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate;
- (void)didFailWithError:(NSError *)error;
- (void)didReceiveResponse:(NSURLResponse *)urlResponse;
- (void)didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading;
@end
@interface MFBWebServiceSoap12Binding_AircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AddAircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AddAircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AddAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateMaintenanceForAircraft : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateMaintenanceForAircraftWithFlagsAndNotes : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteAircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteAircraftForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_MakesAndModels : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_MakesAndModels * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_MakesAndModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_MakesAndModels *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_GetCurrencyForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_GetCurrencyForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_GetCurrencyForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_TotalsForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_TotalsForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_TotalsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_TotalsForUserWithQuery : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_VisitedAirports : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_VisitedAirports * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_VisitedAirports * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_VisitedAirports *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightsWithQueryAndOffset : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightsWithQuery : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightsWithQuery * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightsWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteLogbookEntry : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteLogbookEntry * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteLogbookEntry * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CommitFlightWithOptions : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CommitFlightWithOptions * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_CommitFlightWithOptions * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightPathForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightPathForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightPathForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightPathForFlightGPX : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AvailablePropertyTypes : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypes * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AvailablePropertyTypes * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AvailablePropertyTypesForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_PropertiesForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_PropertiesForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_PropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeletePropertiesForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeletePropertyForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeletePropertyForFlight * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeletePropertyForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteImage : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteImage * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteImage * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteImage *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateImageAnnotation : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateImageAnnotation * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_UpdateImageAnnotation * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AuthTokenForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AuthTokenForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AuthTokenForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CreateUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CreateUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_CreateUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreateUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_GetNamedQueriesForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AddNamedQueryForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AddNamedQueryForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AddNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteNamedQueryForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_SuggestModels : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_SuggestModels * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_SuggestModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_SuggestModels *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_PreviouslyUsedTextProperties : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_PreviouslyUsedTextProperties * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_PreviouslyUsedTextProperties * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PreviouslyUsedTextProperties *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AirportsInBoundingBox : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AirportsInBoundingBox * parameters;
}
@property (nonatomic, retain) MFBWebServiceSvc_AirportsInBoundingBox * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AirportsInBoundingBox *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_envelope : NSObject {
}
+ (MFBWebServiceSoap12Binding_envelope *)sharedInstance;
- (NSString *)serializedFormUsingHeaderElements:(NSDictionary *)headerElements bodyElements:(NSDictionary *)bodyElements bodyKeys:(NSArray *)bodyKeys;
@end
@interface MFBWebServiceSoap12BindingResponse : NSObject {
	NSArray *headers;
	NSArray *bodyParts;
	NSError *error;
}
@property (nonatomic, retain) NSArray *headers;
@property (nonatomic, retain) NSArray *bodyParts;
@property (nonatomic, retain) NSError *error;
@end
