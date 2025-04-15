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
@class MFBWebServiceSvc_ArrayOfInt;
@class MFBWebServiceSvc_MFBImageInfo;
@class MFBWebServiceSvc_MFBImageInfoBase;
@class MFBWebServiceSvc_LatLong;
@class MFBWebServiceSvc_AddAircraftForUser;
@class MFBWebServiceSvc_AddAircraftForUserResponse;
@class MFBWebServiceSvc_AircraftMatchingPrefix;
@class MFBWebServiceSvc_AircraftMatchingPrefixResponse;
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
@class MFBWebServiceSvc_LogbookEntryBase;
@class MFBWebServiceSvc_LogbookEntryCore;
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
@class MFBWebServiceSvc_CheckFlight;
@class MFBWebServiceSvc_CheckFlightResponse;
@class MFBWebServiceSvc_CreatePendingFlight;
@class MFBWebServiceSvc_CreatePendingFlightResponse;
@class MFBWebServiceSvc_ArrayOfPendingFlight;
@class MFBWebServiceSvc_PendingFlight;
@class MFBWebServiceSvc_PendingFlightsForUser;
@class MFBWebServiceSvc_PendingFlightsForUserResponse;
@class MFBWebServiceSvc_UpdatePendingFlight;
@class MFBWebServiceSvc_UpdatePendingFlightResponse;
@class MFBWebServiceSvc_DeletePendingFlight;
@class MFBWebServiceSvc_DeletePendingFlightResponse;
@class MFBWebServiceSvc_CommitPendingFlight;
@class MFBWebServiceSvc_CommitPendingFlightResponse;
@class MFBWebServiceSvc_AvailablePropertyTypes;
@class MFBWebServiceSvc_AvailablePropertyTypesResponse;
@class MFBWebServiceSvc_AvailablePropertyTypesForUser;
@class MFBWebServiceSvc_AvailablePropertyTypesForUserResponse;
@class MFBWebServiceSvc_PropertiesAndTemplatesForUser;
@class MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse;
@class MFBWebServiceSvc_TemplatePropTypeBundle;
@class MFBWebServiceSvc_ArrayOfPropertyTemplate;
@class MFBWebServiceSvc_PropertyTemplate;
@class MFBWebServiceSvc_PropertiesForFlight;
@class MFBWebServiceSvc_PropertiesForFlightResponse;
@class MFBWebServiceSvc_DeletePropertiesForFlight;
@class MFBWebServiceSvc_DeletePropertiesForFlightResponse;
@class MFBWebServiceSvc_DeletePropertyForFlight;
@class MFBWebServiceSvc_DeletePropertyForFlightResponse;
@class MFBWebServiceSvc_DeleteImage;
@class MFBWebServiceSvc_DeleteImageResponse;
@class MFBWebServiceSvc_UpdateImageAnnotation;
@class MFBWebServiceSvc_UpdateImageAnnotationResponse;
@class MFBWebServiceSvc_AuthTokenForUser;
@class MFBWebServiceSvc_AuthTokenForUserResponse;
@class MFBWebServiceSvc_AuthTokenForUserNew;
@class MFBWebServiceSvc_AuthTokenForUserNewResponse;
@class MFBWebServiceSvc_AuthResult;
@class MFBWebServiceSvc_RefreshAuthToken;
@class MFBWebServiceSvc_RefreshAuthTokenResponse;
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
@interface MFBWebServiceSvc_AircraftForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
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
@interface MFBWebServiceSvc_LatLong : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * Latitude;
@property (nonatomic, strong) NSNumber * Longitude;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MFBImageInfoBase : NSObject <NSCoding, NSSecureCoding> {
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
+ (MFBWebServiceSvc_MFBImageInfoBase *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * Width;
@property (nonatomic, strong) NSNumber * Height;
@property (nonatomic, strong) NSNumber * WidthThumbnail;
@property (nonatomic, strong) NSNumber * HeightThumbnail;
@property (nonatomic, assign) MFBWebServiceSvc_ImageFileType ImageType;
@property (nonatomic, strong) NSString * Comment;
@property (nonatomic, strong) NSString * VirtualPath;
@property (nonatomic, strong) NSString * ThumbnailFile;
@property (nonatomic, strong) MFBWebServiceSvc_LatLong * Location;
@property (nonatomic, strong) NSString * URLFullImage;
@property (nonatomic, strong) NSString * URLThumbnail;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MFBImageInfo : MFBWebServiceSvc_MFBImageInfoBase {
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_MFBImageInfo *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfMFBImageInfo : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
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
@interface MFBWebServiceSvc_ArrayOfInt : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addInt_:(NSNumber *)toAdd;
@property (nonatomic, readonly) NSMutableArray * int_;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_AvionicsTechnologyType_none = 0,
	MFBWebServiceSvc_AvionicsTechnologyType_None,
	MFBWebServiceSvc_AvionicsTechnologyType_Glass,
	MFBWebServiceSvc_AvionicsTechnologyType_TAA,
} MFBWebServiceSvc_AvionicsTechnologyType;
MFBWebServiceSvc_AvionicsTechnologyType MFBWebServiceSvc_AvionicsTechnologyType_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AvionicsTechnologyType_stringFromEnum(MFBWebServiceSvc_AvionicsTechnologyType enumValue);
@interface MFBWebServiceSvc_Aircraft : NSObject <NSCoding, NSSecureCoding> {
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
	USBoolean * CopyPICNameWithCrossfill;
	NSDate * RegistrationDue;
	NSString * PublicNotes;
	NSString * PrivateNotes;
	MFBWebServiceSvc_ArrayOfInt * DefaultTemplates;
	NSString * ICAO;
	NSDate * GlassUpgradeDate;
	MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnologyUpgrade;
	NSString * MaintenanceNote;
	NSNumber * Revision;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_Aircraft *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * InstanceTypeID;
@property (nonatomic, assign) MFBWebServiceSvc_AircraftInstanceTypes InstanceType;
@property (nonatomic, strong) NSString * InstanceTypeDescription;
@property (nonatomic, strong) NSDate * LastVOR;
@property (nonatomic, strong) NSDate * LastAltimeter;
@property (nonatomic, strong) NSDate * LastTransponder;
@property (nonatomic, strong) NSDate * LastELT;
@property (nonatomic, strong) NSDate * LastStatic;
@property (nonatomic, strong) NSNumber * Last100;
@property (nonatomic, strong) NSNumber * LastOilChange;
@property (nonatomic, strong) NSNumber * LastNewEngine;
@property (nonatomic, strong) NSDate * LastAnnual;
@property (nonatomic, strong) USBoolean * IsGlass;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfMFBImageInfo * AircraftImages;
@property (nonatomic, strong) NSNumber * AircraftID;
@property (nonatomic, strong) NSString * ModelCommonName;
@property (nonatomic, strong) NSString * TailNumber;
@property (nonatomic, strong) NSNumber * ModelID;
@property (nonatomic, strong) NSString * ModelDescription;
@property (nonatomic, strong) NSString * ErrorString;
@property (nonatomic, strong) USBoolean * HideFromSelection;
@property (nonatomic, strong) NSNumber * Version;
@property (nonatomic, strong) NSString * DefaultImage;
@property (nonatomic, assign) MFBWebServiceSvc_PilotRole RoleForPilot;
@property (nonatomic, strong) USBoolean * CopyPICNameWithCrossfill;
@property (nonatomic, strong) NSDate * RegistrationDue;
@property (nonatomic, strong) NSString * PublicNotes;
@property (nonatomic, strong) NSString * PrivateNotes;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfInt * DefaultTemplates;
@property (nonatomic, strong) NSString * ICAO;
@property (nonatomic, strong) NSDate * GlassUpgradeDate;
@property (nonatomic, assign) MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnologyUpgrade;
@property (nonatomic, strong) NSString * MaintenanceNote;
@property (nonatomic, strong) NSNumber * Revision;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfAircraft : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addAircraft:(MFBWebServiceSvc_Aircraft *)toAdd;
@property (nonatomic, readonly) NSMutableArray * Aircraft;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AircraftForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfAircraft * AircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddAircraftForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSString * szTail;
@property (nonatomic, strong) NSNumber * idModel;
@property (nonatomic, strong) NSNumber * idInstanceType;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddAircraftForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfAircraft * AddAircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AircraftMatchingPrefix : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthToken;
	NSString * szPrefix;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AircraftMatchingPrefix *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) NSString * szPrefix;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AircraftMatchingPrefixResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfAircraft * AircraftMatchingPrefixResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AircraftMatchingPrefixResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfAircraft * AircraftMatchingPrefixResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraft : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_Aircraft * ac;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_Aircraft * ac;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteAircraftForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idAircraft;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteAircraftForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfAircraft * DeleteAircraftForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MakesAndModels : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_SimpleMakeModel : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * ModelID;
@property (nonatomic, strong) NSString * Description;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfSimpleMakeModel : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addSimpleMakeModel:(MFBWebServiceSvc_SimpleMakeModel *)toAdd;
@property (nonatomic, readonly) NSMutableArray * SimpleMakeModel;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_MakesAndModelsResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfSimpleMakeModel * MakesAndModelsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetCurrencyForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
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
@interface MFBWebServiceSvc_CategoryClass : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * CatClass;
@property (nonatomic, strong) NSString * Category_;
@property (nonatomic, strong) NSString * Class_;
@property (nonatomic, strong) NSNumber * AltCatClass;
@property (nonatomic, assign) MFBWebServiceSvc_CatClassID IdCatClass;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCategoryClass : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
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
@interface MFBWebServiceSvc_ArrayOfString : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addString:(NSString *)toAdd;
@property (nonatomic, readonly) NSMutableArray * string;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CustomPropertyType : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * PropTypeID;
@property (nonatomic, strong) NSString * Title;
@property (nonatomic, strong) NSString * SortKey;
@property (nonatomic, strong) USBoolean * IsFavorite;
@property (nonatomic, strong) NSString * FormatString;
@property (nonatomic, assign) MFBWebServiceSvc_CFPPropertyType Type;
@property (nonatomic, strong) NSString * Description;
@property (nonatomic, strong) NSNumber * Flags;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfString * PreviousValues;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCustomPropertyType : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addCustomPropertyType:(MFBWebServiceSvc_CustomPropertyType *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CustomPropertyType;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_GroupConjunction_none = 0,
	MFBWebServiceSvc_GroupConjunction_Any,
	MFBWebServiceSvc_GroupConjunction_All,
	MFBWebServiceSvc_GroupConjunction_None,
} MFBWebServiceSvc_GroupConjunction;
MFBWebServiceSvc_GroupConjunction MFBWebServiceSvc_GroupConjunction_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_GroupConjunction_stringFromEnum(MFBWebServiceSvc_GroupConjunction enumValue);
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
@interface MFBWebServiceSvc_MakeModel : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, assign) MFBWebServiceSvc_AllowedAircraftTypes AllowedTypes;
@property (nonatomic, strong) NSString * CategoryClassDisplay;
@property (nonatomic, strong) NSString * ManufacturerDisplay;
@property (nonatomic, assign) MFBWebServiceSvc_AvionicsTechnologyType AvionicsTechnology;
@property (nonatomic, strong) NSString * ArmyMDS;
@property (nonatomic, strong) NSString * ErrorString;
@property (nonatomic, strong) NSNumber * MakeModelID;
@property (nonatomic, strong) NSString * Model;
@property (nonatomic, strong) NSString * ModelName;
@property (nonatomic, strong) NSString * TypeName;
@property (nonatomic, strong) NSString * FamilyName;
@property (nonatomic, assign) MFBWebServiceSvc_CatClassID CategoryClassID;
@property (nonatomic, strong) NSNumber * ManufacturerID;
@property (nonatomic, strong) USBoolean * IsComplex;
@property (nonatomic, strong) USBoolean * IsHighPerf;
@property (nonatomic, strong) USBoolean * Is200HP;
@property (nonatomic, assign) MFBWebServiceSvc_HighPerfType PerformanceType;
@property (nonatomic, strong) USBoolean * IsTailWheel;
@property (nonatomic, strong) USBoolean * IsConstantProp;
@property (nonatomic, strong) USBoolean * HasFlaps;
@property (nonatomic, strong) USBoolean * IsRetract;
@property (nonatomic, assign) MFBWebServiceSvc_TurbineLevel EngineType;
@property (nonatomic, strong) USBoolean * IsCertifiedSinglePilot;
@property (nonatomic, strong) USBoolean * IsMotorGlider;
@property (nonatomic, strong) USBoolean * IsMultiEngineHelicopter;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfMakeModel : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
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
@interface MFBWebServiceSvc_FlightQuery : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_DateRanges DateRange;
	MFBWebServiceSvc_FlightDistance Distance;
	MFBWebServiceSvc_ArrayOfCategoryClass * CatClasses;
	MFBWebServiceSvc_ArrayOfCustomPropertyType * PropertyTypes;
	MFBWebServiceSvc_GroupConjunction PropertiesConjunction;
	NSString * UserName;
	USBoolean * IsPublic;
	MFBWebServiceSvc_GroupConjunction FlightCharacteristicsConjunction;
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, assign) MFBWebServiceSvc_DateRanges DateRange;
@property (nonatomic, assign) MFBWebServiceSvc_FlightDistance Distance;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCategoryClass * CatClasses;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomPropertyType * PropertyTypes;
@property (nonatomic, assign) MFBWebServiceSvc_GroupConjunction PropertiesConjunction;
@property (nonatomic, strong) NSString * UserName;
@property (nonatomic, strong) USBoolean * IsPublic;
@property (nonatomic, assign) MFBWebServiceSvc_GroupConjunction FlightCharacteristicsConjunction;
@property (nonatomic, strong) USBoolean * HasNightLandings;
@property (nonatomic, strong) USBoolean * HasFullStopLandings;
@property (nonatomic, strong) USBoolean * HasLandings;
@property (nonatomic, strong) USBoolean * HasApproaches;
@property (nonatomic, strong) USBoolean * HasHolds;
@property (nonatomic, strong) USBoolean * HasXC;
@property (nonatomic, strong) USBoolean * HasSimIMCTime;
@property (nonatomic, strong) USBoolean * HasGroundSim;
@property (nonatomic, strong) USBoolean * HasIMC;
@property (nonatomic, strong) USBoolean * HasAnyInstrument;
@property (nonatomic, strong) USBoolean * HasNight;
@property (nonatomic, strong) USBoolean * HasDual;
@property (nonatomic, strong) USBoolean * HasCFI;
@property (nonatomic, strong) USBoolean * HasSIC;
@property (nonatomic, strong) USBoolean * HasPIC;
@property (nonatomic, strong) USBoolean * HasTotalTime;
@property (nonatomic, strong) USBoolean * IsSigned;
@property (nonatomic, strong) NSDate * DateMin;
@property (nonatomic, strong) NSDate * DateMax;
@property (nonatomic, strong) NSString * GeneralText;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfAircraft * AircraftList;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfString * AirportList;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfMakeModel * MakeList;
@property (nonatomic, strong) NSString * ModelName;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfString * TypeNames;
@property (nonatomic, strong) USBoolean * IsComplex;
@property (nonatomic, strong) USBoolean * HasFlaps;
@property (nonatomic, strong) USBoolean * IsHighPerformance;
@property (nonatomic, strong) USBoolean * IsConstantSpeedProp;
@property (nonatomic, strong) USBoolean * IsRetract;
@property (nonatomic, strong) USBoolean * IsTechnicallyAdvanced;
@property (nonatomic, strong) USBoolean * IsGlass;
@property (nonatomic, strong) USBoolean * IsTailwheel;
@property (nonatomic, assign) MFBWebServiceSvc_EngineTypeRestriction EngineType;
@property (nonatomic, strong) USBoolean * IsMultiEngineHeli;
@property (nonatomic, strong) USBoolean * IsTurbine;
@property (nonatomic, strong) USBoolean * HasTelemetry;
@property (nonatomic, strong) USBoolean * HasImages;
@property (nonatomic, strong) USBoolean * IsMotorglider;
@property (nonatomic, assign) MFBWebServiceSvc_AircraftInstanceRestriction AircraftInstanceTypes;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CurrencyStatusItem : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * Attribute;
@property (nonatomic, strong) NSString * Value;
@property (nonatomic, assign) MFBWebServiceSvc_CurrencyState Status;
@property (nonatomic, strong) NSString * Discrepancy;
@property (nonatomic, strong) NSNumber * AssociatedResourceID;
@property (nonatomic, assign) MFBWebServiceSvc_CurrencyGroups CurrencyGroup;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * Query;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCurrencyStatusItem : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addCurrencyStatusItem:(MFBWebServiceSvc_CurrencyStatusItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CurrencyStatusItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetCurrencyForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCurrencyStatusItem * GetCurrencyForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) NSDate * dtMin;
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
typedef enum {
	MFBWebServiceSvc_TotalsGroup_none = 0,
	MFBWebServiceSvc_TotalsGroup_None,
	MFBWebServiceSvc_TotalsGroup_CategoryClass,
	MFBWebServiceSvc_TotalsGroup_ICAO,
	MFBWebServiceSvc_TotalsGroup_Model,
	MFBWebServiceSvc_TotalsGroup_Capabilities,
	MFBWebServiceSvc_TotalsGroup_CoreFields,
	MFBWebServiceSvc_TotalsGroup_Properties,
	MFBWebServiceSvc_TotalsGroup_Total,
} MFBWebServiceSvc_TotalsGroup;
MFBWebServiceSvc_TotalsGroup MFBWebServiceSvc_TotalsGroup_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_TotalsGroup_stringFromEnum(MFBWebServiceSvc_TotalsGroup enumValue);
@interface MFBWebServiceSvc_TotalsItem : NSObject <NSCoding, NSSecureCoding> {
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
	MFBWebServiceSvc_TotalsGroup Group;
	NSString * GroupName;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TotalsItem *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * Value;
@property (nonatomic, strong) NSString * Description;
@property (nonatomic, strong) NSString * SubDescription;
@property (nonatomic, assign) MFBWebServiceSvc_NumType NumericType;
@property (nonatomic, strong) USBoolean * IsInt;
@property (nonatomic, strong) USBoolean * IsTime;
@property (nonatomic, strong) USBoolean * IsCurrency;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * Query;
@property (nonatomic, assign) MFBWebServiceSvc_TotalsGroup Group;
@property (nonatomic, strong) NSString * GroupName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfTotalsItem : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addTotalsItem:(MFBWebServiceSvc_TotalsItem *)toAdd;
@property (nonatomic, readonly) NSMutableArray * TotalsItem;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserWithQuery : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TotalsForUserWithQueryResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfTotalsItem * TotalsForUserWithQueryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirports : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_airport : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * DistanceFromPosition;
	NSString * UserName;
	NSString * FacilityTypeCode;
	NSString * FacilityType;
	NSString * Code;
	NSString * Name;
	NSString * Country;
	NSString * Admin1;
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * DistanceFromPosition;
@property (nonatomic, strong) NSString * UserName;
@property (nonatomic, strong) NSString * FacilityTypeCode;
@property (nonatomic, strong) NSString * FacilityType;
@property (nonatomic, strong) NSString * Code;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * Country;
@property (nonatomic, strong) NSString * Admin1;
@property (nonatomic, strong) MFBWebServiceSvc_LatLong * LatLong;
@property (nonatomic, strong) NSString * Latitude;
@property (nonatomic, strong) NSString * Longitude;
@property (nonatomic, strong) NSString * ErrorText;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirport : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * Code;
@property (nonatomic, strong) NSString * Aliases;
@property (nonatomic, strong) MFBWebServiceSvc_airport * Airport;
@property (nonatomic, strong) NSDate * EarliestVisitDate;
@property (nonatomic, strong) NSDate * LatestVisitDate;
@property (nonatomic, strong) NSNumber * NumberOfVisits;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfVisitedAirport : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addVisitedAirport:(MFBWebServiceSvc_VisitedAirport *)toAdd;
@property (nonatomic, readonly) NSMutableArray * VisitedAirport;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_VisitedAirportsResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfVisitedAirport * VisitedAirportsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryAndOffset : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, strong) NSNumber * offset;
@property (nonatomic, strong) NSNumber * maxCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CustomFlightProperty : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * PropID;
@property (nonatomic, strong) NSNumber * FlightID;
@property (nonatomic, strong) NSNumber * PropTypeID;
@property (nonatomic, strong) NSNumber * IntValue;
@property (nonatomic, strong) USBoolean * BoolValue;
@property (nonatomic, strong) NSNumber * DecValue;
@property (nonatomic, strong) NSDate * DateValue;
@property (nonatomic, strong) NSString * TextValue;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCustomFlightProperty : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
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
@interface MFBWebServiceSvc_VideoRef : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * ID_;
@property (nonatomic, strong) NSNumber * FlightID;
@property (nonatomic, strong) NSString * VideoReference;
@property (nonatomic, assign) MFBWebServiceSvc_VideoSource Source;
@property (nonatomic, strong) NSString * Comment;
@property (nonatomic, strong) NSString * ErrorString;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfVideoRef : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addVideoRef:(MFBWebServiceSvc_VideoRef *)toAdd;
@property (nonatomic, readonly) NSMutableArray * VideoRef;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_LogbookEntryCore : NSObject <NSCoding, NSSecureCoding> {
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
	USBoolean * IsOverridden;
	NSString * FlightColorHex;
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
	NSString * SendFlightLink;
	NSString * SocialMediaLink;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_LogbookEntryCore *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * User;
@property (nonatomic, strong) NSNumber * AircraftID;
@property (nonatomic, strong) NSNumber * CatClassOverride;
@property (nonatomic, strong) NSNumber * NightLandings;
@property (nonatomic, strong) NSNumber * FullStopLandings;
@property (nonatomic, strong) NSNumber * Approaches;
@property (nonatomic, strong) NSNumber * PrecisionApproaches;
@property (nonatomic, strong) NSNumber * NonPrecisionApproaches;
@property (nonatomic, strong) NSNumber * Landings;
@property (nonatomic, strong) NSNumber * CrossCountry;
@property (nonatomic, strong) NSNumber * Nighttime;
@property (nonatomic, strong) NSNumber * IMC;
@property (nonatomic, strong) NSNumber * SimulatedIFR;
@property (nonatomic, strong) NSNumber * GroundSim;
@property (nonatomic, strong) NSNumber * Dual;
@property (nonatomic, strong) NSNumber * CFI;
@property (nonatomic, strong) NSNumber * PIC;
@property (nonatomic, strong) NSNumber * SIC;
@property (nonatomic, strong) NSNumber * TotalFlightTime;
@property (nonatomic, strong) USBoolean * fHoldingProcedures;
@property (nonatomic, strong) NSString * Route;
@property (nonatomic, strong) NSString * Comment;
@property (nonatomic, strong) USBoolean * fIsPublic;
@property (nonatomic, strong) NSDate * Date;
@property (nonatomic, strong) USBoolean * IsOverridden;
@property (nonatomic, strong) NSString * FlightColorHex;
@property (nonatomic, strong) NSString * ErrorString;
@property (nonatomic, strong) NSNumber * FlightID;
@property (nonatomic, strong) NSDate * FlightStart;
@property (nonatomic, strong) NSDate * FlightEnd;
@property (nonatomic, strong) NSDate * EngineStart;
@property (nonatomic, strong) NSDate * EngineEnd;
@property (nonatomic, strong) NSNumber * HobbsStart;
@property (nonatomic, strong) NSNumber * HobbsEnd;
@property (nonatomic, strong) NSString * ModelDisplay;
@property (nonatomic, strong) NSString * TailNumDisplay;
@property (nonatomic, strong) NSString * CatClassDisplay;
@property (nonatomic, strong) NSString * FlightData;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomFlightProperty * CustomProperties;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfMFBImageInfo * FlightImages;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfVideoRef * Videos;
@property (nonatomic, strong) NSString * SendFlightLink;
@property (nonatomic, strong) NSString * SocialMediaLink;
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
@interface MFBWebServiceSvc_LogbookEntryBase : MFBWebServiceSvc_LogbookEntryCore {
/* elements */
	NSString * CFIComments;
	NSDate * CFISignatureDate;
	NSString * CFICertificate;
	NSDate * CFIExpiration;
	NSString * CFIEmail;
	NSString * CFIName;
	MFBWebServiceSvc_SignatureState CFISignatureState;
	USBoolean * HasDigitizedSig;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_LogbookEntryBase *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, strong) NSString * CFIComments;
@property (nonatomic, strong) NSDate * CFISignatureDate;
@property (nonatomic, strong) NSString * CFICertificate;
@property (nonatomic, strong) NSDate * CFIExpiration;
@property (nonatomic, strong) NSString * CFIEmail;
@property (nonatomic, strong) NSString * CFIName;
@property (nonatomic, assign) MFBWebServiceSvc_SignatureState CFISignatureState;
@property (nonatomic, strong) USBoolean * HasDigitizedSig;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_LogbookEntry : MFBWebServiceSvc_LogbookEntryBase {
/* elements */
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_LogbookEntry *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfLogbookEntry : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addLogbookEntry:(MFBWebServiceSvc_LogbookEntry *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LogbookEntry;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryAndOffsetResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQuery : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, strong) NSNumber * maxCount;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightsWithQueryResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfLogbookEntry * FlightsWithQueryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteLogbookEntry : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteLogbookEntryResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) USBoolean * DeleteLogbookEntryResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PostingOptions : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitFlightWithOptions : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_LogbookEntry * le;
@property (nonatomic, strong) MFBWebServiceSvc_PostingOptions * po;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitFlightWithOptionsResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_LogbookEntry * CommitFlightWithOptionsResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlight : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfLatLong : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addLatLong:(MFBWebServiceSvc_LatLong *)toAdd;
@property (nonatomic, readonly) NSMutableArray * LatLong;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfLatLong * FlightPathForFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightGPX : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_FlightPathForFlightGPXResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * FlightPathForFlightGPXResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CheckFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_LogbookEntry * le;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CheckFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_LogbookEntry * le;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CheckFlightResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfString * CheckFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CheckFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfString * CheckFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreatePendingFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_LogbookEntry * le;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CreatePendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_LogbookEntry * le;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PendingFlight : MFBWebServiceSvc_LogbookEntry {
/* elements */
	NSString * PendingID;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
/* elements */
@property (nonatomic, strong) NSString * PendingID;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfPendingFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *PendingFlight;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfPendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addPendingFlight:(MFBWebServiceSvc_PendingFlight *)toAdd;
@property (nonatomic, readonly) NSMutableArray * PendingFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreatePendingFlightResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfPendingFlight * CreatePendingFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CreatePendingFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPendingFlight * CreatePendingFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PendingFlightsForUser : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PendingFlightsForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PendingFlightsForUserResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfPendingFlight * PendingFlightsForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PendingFlightsForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPendingFlight * PendingFlightsForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdatePendingFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_PendingFlight * pf;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdatePendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_PendingFlight * pf;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdatePendingFlightResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfPendingFlight * UpdatePendingFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_UpdatePendingFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPendingFlight * UpdatePendingFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePendingFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	NSString * idpending;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSString * idpending;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePendingFlightResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfPendingFlight * DeletePendingFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_DeletePendingFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPendingFlight * DeletePendingFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitPendingFlight : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
	MFBWebServiceSvc_PendingFlight * pf;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CommitPendingFlight *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_PendingFlight * pf;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CommitPendingFlightResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfPendingFlight * CommitPendingFlightResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_CommitPendingFlightResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPendingFlight * CommitPendingFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypes : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AvailablePropertyTypesForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomPropertyType * AvailablePropertyTypesForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesAndTemplatesForUser : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAuthUserToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PropertiesAndTemplatesForUser *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertyTemplate : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSNumber * ID_;
	NSString * Name;
	NSString * Description;
	NSNumber * GroupAsInt;
	NSString * GroupDisplayName;
	MFBWebServiceSvc_ArrayOfInt * PropertyTypes;
	USBoolean * IsDefault;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PropertyTemplate *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSNumber * ID_;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * Description;
@property (nonatomic, strong) NSNumber * GroupAsInt;
@property (nonatomic, strong) NSString * GroupDisplayName;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfInt * PropertyTypes;
@property (nonatomic, strong) USBoolean * IsDefault;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfPropertyTemplate : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSMutableArray *PropertyTemplate;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_ArrayOfPropertyTemplate *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addPropertyTemplate:(MFBWebServiceSvc_PropertyTemplate *)toAdd;
@property (nonatomic, readonly) NSMutableArray * PropertyTemplate;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_TemplatePropTypeBundle : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_ArrayOfCustomPropertyType * UserProperties;
	MFBWebServiceSvc_ArrayOfPropertyTemplate * UserTemplates;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_TemplatePropTypeBundle *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomPropertyType * UserProperties;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfPropertyTemplate * UserTemplates;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_TemplatePropTypeBundle * PropertiesAndTemplatesForUserResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_TemplatePropTypeBundle * PropertiesAndTemplatesForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesForFlight : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_PropertiesForFlightResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCustomFlightProperty * PropertiesForFlightResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertiesForFlight : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfInt * rgPropIds;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertiesForFlightResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertyForFlight : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) NSNumber * idFlight;
@property (nonatomic, strong) NSNumber * propId;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeletePropertyForFlightResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteImage : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteImageResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateImageAnnotation : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthUserToken;
@property (nonatomic, strong) MFBWebServiceSvc_MFBImageInfo * mfbii;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_UpdateImageAnnotationResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAppToken;
@property (nonatomic, strong) NSString * szUser;
@property (nonatomic, strong) NSString * szPass;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * AuthTokenForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUserNew : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAppToken;
	NSString * szUser;
	NSString * szPass;
	NSString * sz2FactorAuth;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AuthTokenForUserNew *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAppToken;
@property (nonatomic, strong) NSString * szUser;
@property (nonatomic, strong) NSString * szPass;
@property (nonatomic, strong) NSString * sz2FactorAuth;
/* attributes */
- (NSDictionary *)attributes;
@end
typedef enum {
	MFBWebServiceSvc_AuthStatus_none = 0,
	MFBWebServiceSvc_AuthStatus_Failed,
	MFBWebServiceSvc_AuthStatus_TwoFactorCodeRequired,
	MFBWebServiceSvc_AuthStatus_Success,
} MFBWebServiceSvc_AuthStatus;
MFBWebServiceSvc_AuthStatus MFBWebServiceSvc_AuthStatus_enumFromString(NSString *string);
NSString * MFBWebServiceSvc_AuthStatus_stringFromEnum(MFBWebServiceSvc_AuthStatus enumValue);
@interface MFBWebServiceSvc_AuthResult : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_AuthStatus Result;
	NSString * AuthToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AuthResult *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, assign) MFBWebServiceSvc_AuthStatus Result;
@property (nonatomic, strong) NSString * AuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AuthTokenForUserNewResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	MFBWebServiceSvc_AuthResult * AuthTokenForUserNewResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_AuthTokenForUserNewResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_AuthResult * AuthTokenForUserNewResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_RefreshAuthToken : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * szAppToken;
	NSString * szUser;
	NSString * szPass;
	NSString * szPreviousToken;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_RefreshAuthToken *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAppToken;
@property (nonatomic, strong) NSString * szUser;
@property (nonatomic, strong) NSString * szPass;
@property (nonatomic, strong) NSString * szPreviousToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_RefreshAuthTokenResponse : NSObject <NSCoding, NSSecureCoding> {
SOAPSigner *soapSigner;
/* elements */
	NSString * RefreshAuthTokenResult;
/* attributes */
}
- (NSString *)nsPrefix;
- (xmlNodePtr)xmlNodeForDoc:(xmlDocPtr)doc elementName:(NSString *)elName elementNSPrefix:(NSString *)elNSPrefix;
- (void)addAttributesToNode:(xmlNodePtr)node;
- (void)addElementsToNode:(xmlNodePtr)node;
+ (MFBWebServiceSvc_RefreshAuthTokenResponse *)deserializeNode:(xmlNodePtr)cur;
- (void)deserializeAttributesFromNode:(xmlNodePtr)cur;
- (void)deserializeElementsFromNode:(xmlNodePtr)cur;
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * RefreshAuthTokenResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreateUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAppToken;
@property (nonatomic, strong) NSString * szEmail;
@property (nonatomic, strong) NSString * szPass;
@property (nonatomic, strong) NSString * szFirst;
@property (nonatomic, strong) NSString * szLast;
@property (nonatomic, strong) NSString * szQuestion;
@property (nonatomic, strong) NSString * szAnswer;
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
@interface MFBWebServiceSvc_UserEntity : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) NSString * szUsername;
@property (nonatomic, assign) MFBWebServiceSvc_MembershipCreateStatus mcs;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CreateUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_UserEntity * CreateUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetNamedQueriesForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_CannedQuery : MFBWebServiceSvc_FlightQuery {
/* elements */
	NSString * QueryName;
	NSString * ColorString;
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
@property (nonatomic, strong) NSString * QueryName;
@property (nonatomic, strong) NSString * ColorString;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_ArrayOfCannedQuery : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
- (void)addCannedQuery:(MFBWebServiceSvc_CannedQuery *)toAdd;
@property (nonatomic, readonly) NSMutableArray * CannedQuery;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_GetNamedQueriesForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCannedQuery * GetNamedQueriesForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddNamedQueryForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
@property (nonatomic, strong) NSString * szName;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_AddNamedQueryForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCannedQuery * AddNamedQueryForUserResult;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteNamedQueryForUser : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) NSString * szAuthToken;
@property (nonatomic, strong) MFBWebServiceSvc_CannedQuery * cq;
/* attributes */
- (NSDictionary *)attributes;
@end
@interface MFBWebServiceSvc_DeleteNamedQueryForUserResponse : NSObject <NSCoding, NSSecureCoding> {
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
@property (strong) SOAPSigner *soapSigner;
/* elements */
@property (nonatomic, strong) MFBWebServiceSvc_ArrayOfCannedQuery * DeleteNamedQueryForUserResult;
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
@property (nonatomic, strong) NSMutableArray *cookies;
@property (nonatomic, strong) NSMutableDictionary *customHeaders;
@property (nonatomic, strong) id<SSLCredentialsManaging> sslManager;
@property (nonatomic, strong) SOAPSigner *soapSigner;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(MFBWebServiceSoapBindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (void)AircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AddAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AircraftMatchingPrefixAsyncUsingParameters:(MFBWebServiceSvc_AircraftMatchingPrefix *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)UpdateMaintenanceForAircraftAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)UpdateMaintenanceForAircraftWithFlagsAndNotesAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeleteAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)MakesAndModelsAsyncUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)GetCurrencyForUserAsyncUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)TotalsForUserAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)TotalsForUserWithQueryAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)VisitedAirportsAsyncUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)FlightsWithQueryAndOffsetAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)FlightsWithQueryAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeleteLogbookEntryAsyncUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)CommitFlightWithOptionsAsyncUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)FlightPathForFlightAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)FlightPathForFlightGPXAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)CheckFlightAsyncUsingParameters:(MFBWebServiceSvc_CheckFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)CreatePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_CreatePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)PendingFlightsForUserAsyncUsingParameters:(MFBWebServiceSvc_PendingFlightsForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)UpdatePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_UpdatePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeletePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)CommitPendingFlightAsyncUsingParameters:(MFBWebServiceSvc_CommitPendingFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AvailablePropertyTypesAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AvailablePropertyTypesForUserAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)PropertiesAndTemplatesForUserAsyncUsingParameters:(MFBWebServiceSvc_PropertiesAndTemplatesForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)PropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeletePropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeletePropertyForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeleteImageAsyncUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)UpdateImageAnnotationAsyncUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AuthTokenForUserAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AuthTokenForUserNewAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUserNew *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)RefreshAuthTokenAsyncUsingParameters:(MFBWebServiceSvc_RefreshAuthToken *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)CreateUserAsyncUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)GetNamedQueriesForUserAsyncUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)AddNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
- (void)DeleteNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)responseDelegate;
@end
@interface MFBWebServiceSoapBindingOperation : NSOperation {
	MFBWebServiceSoapBinding *binding;
	MFBWebServiceSoapBindingResponse * response;
	id<MFBWebServiceSoapBindingResponseDelegate> __weak delegate;
	NSMutableData *responseData;
}
@property (nonatomic, strong) MFBWebServiceSoapBinding *binding;
@property (nonatomic, strong) MFBWebServiceSoapBindingResponse *response;
@property (nonatomic, weak) id<MFBWebServiceSoapBindingResponseDelegate> delegate;
@property (nonatomic, strong) NSMutableData *responseData;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate;
- (void)didFailWithError:(NSError *)error;
- (void)didReceiveResponse:(NSURLResponse *)urlResponse;
- (void)didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading;
@end
@interface MFBWebServiceSoapBinding_AircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AddAircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AddAircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AddAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AircraftMatchingPrefix : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AircraftMatchingPrefix * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AircraftMatchingPrefix * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftMatchingPrefix *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateMaintenanceForAircraft : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateMaintenanceForAircraftWithFlagsAndNotes : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteAircraftForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteAircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_MakesAndModels : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_MakesAndModels * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_MakesAndModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_MakesAndModels *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_GetCurrencyForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_GetCurrencyForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_GetCurrencyForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_TotalsForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_TotalsForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_TotalsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_TotalsForUserWithQuery : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_VisitedAirports : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_VisitedAirports * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_VisitedAirports * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_VisitedAirports *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightsWithQueryAndOffset : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightsWithQuery : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightsWithQuery * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightsWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteLogbookEntry : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteLogbookEntry * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteLogbookEntry * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CommitFlightWithOptions : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CommitFlightWithOptions * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CommitFlightWithOptions * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightPathForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightPathForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightPathForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_FlightPathForFlightGPX : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CheckFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CheckFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CheckFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CheckFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CreatePendingFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CreatePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CreatePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreatePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_PendingFlightsForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_PendingFlightsForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PendingFlightsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PendingFlightsForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdatePendingFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdatePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdatePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdatePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeletePendingFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeletePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CommitPendingFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CommitPendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CommitPendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitPendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AvailablePropertyTypes : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypes * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AvailablePropertyTypes * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AvailablePropertyTypesForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_PropertiesAndTemplatesForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_PropertiesAndTemplatesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PropertiesAndTemplatesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesAndTemplatesForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_PropertiesForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_PropertiesForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeletePropertiesForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeletePropertyForFlight : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeletePropertyForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePropertyForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteImage : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteImage * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteImage * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteImage *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_UpdateImageAnnotation : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_UpdateImageAnnotation * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateImageAnnotation * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AuthTokenForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AuthTokenForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AuthTokenForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AuthTokenForUserNew : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AuthTokenForUserNew * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AuthTokenForUserNew * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUserNew *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_RefreshAuthToken : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_RefreshAuthToken * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_RefreshAuthToken * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_RefreshAuthToken *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_CreateUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_CreateUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CreateUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreateUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_GetNamedQueriesForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_AddNamedQueryForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_AddNamedQueryForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AddNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoapBinding_DeleteNamedQueryForUser : MFBWebServiceSoapBindingOperation {
	MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoapBinding *)aBinding delegate:(id<MFBWebServiceSoapBindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters
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
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) NSArray *bodyParts;
@property (nonatomic, strong) NSError *error;
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
@property (nonatomic, strong) NSMutableArray *cookies;
@property (nonatomic, strong) NSMutableDictionary *customHeaders;
@property (nonatomic, strong) id<SSLCredentialsManaging> sslManager;
@property (nonatomic, strong) SOAPSigner *soapSigner;
+ (NSTimeInterval) defaultTimeout;
- (id)initWithAddress:(NSString *)anAddress;
- (void)sendHTTPCallUsingBody:(NSString *)body soapAction:(NSString *)soapAction forOperation:(MFBWebServiceSoap12BindingOperation *)operation;
- (void)addCookie:(NSHTTPCookie *)toAdd;
- (NSString *)MIMEType;
- (void)AircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AddAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AircraftMatchingPrefixAsyncUsingParameters:(MFBWebServiceSvc_AircraftMatchingPrefix *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)UpdateMaintenanceForAircraftAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)UpdateMaintenanceForAircraftWithFlagsAndNotesAsyncUsingParameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeleteAircraftForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)MakesAndModelsAsyncUsingParameters:(MFBWebServiceSvc_MakesAndModels *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)GetCurrencyForUserAsyncUsingParameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)TotalsForUserAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)TotalsForUserWithQueryAsyncUsingParameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)VisitedAirportsAsyncUsingParameters:(MFBWebServiceSvc_VisitedAirports *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)FlightsWithQueryAndOffsetAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)FlightsWithQueryAsyncUsingParameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeleteLogbookEntryAsyncUsingParameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)CommitFlightWithOptionsAsyncUsingParameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)FlightPathForFlightAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)FlightPathForFlightGPXAsyncUsingParameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)CheckFlightAsyncUsingParameters:(MFBWebServiceSvc_CheckFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)CreatePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_CreatePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)PendingFlightsForUserAsyncUsingParameters:(MFBWebServiceSvc_PendingFlightsForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)UpdatePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_UpdatePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeletePendingFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePendingFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)CommitPendingFlightAsyncUsingParameters:(MFBWebServiceSvc_CommitPendingFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AvailablePropertyTypesAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AvailablePropertyTypesForUserAsyncUsingParameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)PropertiesAndTemplatesForUserAsyncUsingParameters:(MFBWebServiceSvc_PropertiesAndTemplatesForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)PropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeletePropertiesForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeletePropertyForFlightAsyncUsingParameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeleteImageAsyncUsingParameters:(MFBWebServiceSvc_DeleteImage *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)UpdateImageAnnotationAsyncUsingParameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AuthTokenForUserAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AuthTokenForUserNewAsyncUsingParameters:(MFBWebServiceSvc_AuthTokenForUserNew *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)RefreshAuthTokenAsyncUsingParameters:(MFBWebServiceSvc_RefreshAuthToken *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)CreateUserAsyncUsingParameters:(MFBWebServiceSvc_CreateUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)GetNamedQueriesForUserAsyncUsingParameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)AddNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
- (void)DeleteNamedQueryForUserAsyncUsingParameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters  delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)responseDelegate;
@end
@interface MFBWebServiceSoap12BindingOperation : NSOperation {
	MFBWebServiceSoap12Binding *binding;
	MFBWebServiceSoap12BindingResponse * response;
	id<MFBWebServiceSoap12BindingResponseDelegate> __weak delegate;
	NSMutableData *responseData;
}
@property (nonatomic, strong) MFBWebServiceSoap12Binding *binding;
@property (nonatomic, strong) MFBWebServiceSoap12BindingResponse *response;
@property (nonatomic, weak) id<MFBWebServiceSoap12BindingResponseDelegate> delegate;
@property (nonatomic, strong) NSMutableData *responseData;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate;
- (void)didFailWithError:(NSError *)error;
- (void)didReceiveResponse:(NSURLResponse *)urlResponse;
- (void)didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading;
@end
@interface MFBWebServiceSoap12Binding_AircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AddAircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AddAircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AddAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AircraftMatchingPrefix : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AircraftMatchingPrefix * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AircraftMatchingPrefix * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AircraftMatchingPrefix *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateMaintenanceForAircraft : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateMaintenanceForAircraft * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraft *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateMaintenanceForAircraftWithFlagsAndNotes : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteAircraftForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteAircraftForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteAircraftForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteAircraftForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_MakesAndModels : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_MakesAndModels * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_MakesAndModels * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_MakesAndModels *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_GetCurrencyForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_GetCurrencyForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_GetCurrencyForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetCurrencyForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_TotalsForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_TotalsForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_TotalsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_TotalsForUserWithQuery : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_TotalsForUserWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_TotalsForUserWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_VisitedAirports : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_VisitedAirports * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_VisitedAirports * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_VisitedAirports *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightsWithQueryAndOffset : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightsWithQueryAndOffset * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQueryAndOffset *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightsWithQuery : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightsWithQuery * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightsWithQuery * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightsWithQuery *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteLogbookEntry : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteLogbookEntry * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteLogbookEntry * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteLogbookEntry *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CommitFlightWithOptions : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CommitFlightWithOptions * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CommitFlightWithOptions * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitFlightWithOptions *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightPathForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightPathForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightPathForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_FlightPathForFlightGPX : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_FlightPathForFlightGPX * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_FlightPathForFlightGPX *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CheckFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CheckFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CheckFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CheckFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CreatePendingFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CreatePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CreatePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreatePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_PendingFlightsForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_PendingFlightsForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PendingFlightsForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PendingFlightsForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdatePendingFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdatePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdatePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdatePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeletePendingFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeletePendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CommitPendingFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CommitPendingFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CommitPendingFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CommitPendingFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AvailablePropertyTypes : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypes * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AvailablePropertyTypes * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypes *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AvailablePropertyTypesForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AvailablePropertyTypesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AvailablePropertyTypesForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_PropertiesAndTemplatesForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_PropertiesAndTemplatesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PropertiesAndTemplatesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesAndTemplatesForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_PropertiesForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_PropertiesForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_PropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_PropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeletePropertiesForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePropertiesForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertiesForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeletePropertyForFlight : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeletePropertyForFlight * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeletePropertyForFlight * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeletePropertyForFlight *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteImage : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteImage * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteImage * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteImage *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_UpdateImageAnnotation : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_UpdateImageAnnotation * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_UpdateImageAnnotation * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_UpdateImageAnnotation *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AuthTokenForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AuthTokenForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AuthTokenForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AuthTokenForUserNew : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AuthTokenForUserNew * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AuthTokenForUserNew * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AuthTokenForUserNew *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_RefreshAuthToken : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_RefreshAuthToken * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_RefreshAuthToken * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_RefreshAuthToken *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_CreateUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_CreateUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_CreateUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_CreateUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_GetNamedQueriesForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_GetNamedQueriesForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_GetNamedQueriesForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_AddNamedQueryForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_AddNamedQueryForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_AddNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_AddNamedQueryForUser *)aParameters
;
@end
@interface MFBWebServiceSoap12Binding_DeleteNamedQueryForUser : MFBWebServiceSoap12BindingOperation {
	MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
}
@property (nonatomic, strong) MFBWebServiceSvc_DeleteNamedQueryForUser * parameters;
- (id)initWithBinding:(MFBWebServiceSoap12Binding *)aBinding delegate:(id<MFBWebServiceSoap12BindingResponseDelegate>)aDelegate
	parameters:(MFBWebServiceSvc_DeleteNamedQueryForUser *)aParameters
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
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) NSArray *bodyParts;
@property (nonatomic, strong) NSError *error;
@end
