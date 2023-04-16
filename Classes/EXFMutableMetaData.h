/*
 *  EXFMutableMetaData.h
 *  iphoneGeo
 *
 *  Created by steve woodcock on 23/03/2008.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#import "EXFMetaData.h"
#import "EXFJFIF.h"

/* Mutable interface Category for EXFJFIF */

@interface EXFJFIF ()


- (void) parseJfif:(CFDataRef*) theJfifData;

@property (readwrite, strong) NSString* identifier;
@property (readwrite, strong) NSString* version;

@property (readwrite, strong) NSData* thumbnail;

// primitive attributes
@property (readwrite) JFIFUnits units;
@property (readwrite) int length;
@property (readwrite) int resolutionX;
@property (readwrite) int resolutionY;

@property (readwrite) int thumbnailX;
@property (readwrite) int thumbnailY;

@end

/* Mutable interface Category for EXFObject */
@interface EXFMetaData ()



- (void) parseExif:(CFDataRef*) theExifData;
- (void) getData: (NSMutableData*) imageData;

-(void) setupHandlers;


@property (readwrite,strong) NSMutableDictionary* userKeyedHandlers;

@property (readwrite,strong) NSMutableDictionary* keyedHandlers;
@property (readwrite,strong) EXFTagDefinitionHolder* tagDefinitions;
@property (readwrite, strong) NSMutableDictionary* keyedTagValues;

@property (readwrite,strong) NSMutableDictionary* keyedThumbnailTagValues;

@property (readwrite,strong) NSData* thumbnailBytes;

@property (readwrite) int compression;
@property (readwrite) int bitsPerPixel;
@property (readwrite) int height;
@property (readwrite) int width;
@property (readwrite) CFIndex byteLength;

@property (readwrite) BOOL bigEndianOrder;
@property (readwrite) ByteArray* exif_ptr;


@end
