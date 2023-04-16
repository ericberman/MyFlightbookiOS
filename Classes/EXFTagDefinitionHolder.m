//
//  EXFTagDefinition.m
//  iphone-test
//
//  Created by steve woodcock on 26/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
/*
The Follwoing specifications were used for tag data:
http://www.exif.org/Exif2-2.PDF
http://ceres.informatik.fh-kl.de/pbw/lehre/20041/foto/resourcen/Dokumentation/Exif/cp3461.pdf
*/

#import "EXFTagDefinitionHolder.h"
#import "EXFMetaData.h"




@implementation EXFTagDefinitionHolder: NSObject

@synthesize definitions;

-(void) addTagDefinition: (EXFTag*) aTagDefinition forKey: (NSNumber*) aTagKey{
   // [definitions setObject:aTagDefinition forKey:aTagKey];
}

-(void) createTags {
    NSMutableDictionary* tags = [[NSMutableDictionary alloc] init];
    
    EXFTag* tag = [[EXFTag alloc] initWith: 0x0100 : FMT_ULONG :@"ImageWidth":-1: TRUE:1];
    tags[@0x100] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0101 : FMT_ULONG :@"ImageLength":-1: TRUE:1];
    tags[@0x101] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0102 : FMT_USHORT :@"BitsPerSample":-1: TRUE:3];
    tags[@0x102] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0103 : FMT_USHORT :@"Compression":-1: TRUE:1];
    tags[@0x103] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0106 : FMT_USHORT :@"PhotometricInterpretation":-1: TRUE:1];
    tags[@0x106] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0111 : FMT_ULONG :@"StripOffsets":-1: TRUE:-1];
    tags[@0x111] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0112 : FMT_USHORT :@"Orientation":-1: TRUE:1];
    tags[@0x112] = tag;
     
    tag = [[EXFTag alloc] initWith:0x0115 : FMT_USHORT :@"SamplesPerPixel":-1:TRUE:1];
    tags[@0x115] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0116 : FMT_ULONG :@"RowsPerStrip":-1:TRUE:1];
    tags[@0x116] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0117 : FMT_ULONG :@"StripByteCounts":-1:TRUE:-1];
    tags[@0x117] = tag;
    
    tag = [[EXFTag alloc] initWith:0x010e : FMT_STRING :@"ImageDescription":-1:  TRUE:-99];
    tags[@0x010e] = tag;
    
    tag = [[EXFTag alloc] initWith:0x010f : FMT_STRING :@"Make":-1:  TRUE:-99];
    tags[@0x010f] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0110 : FMT_STRING :@"Model":-1:  TRUE:-99];
    tags[@0x0110] = tag;
    
    
    tag = [[EXFTag alloc] initWith:0x011a : FMT_URATIONAL :@"XResolution":-1:TRUE:1];
    tags[@0x011a] = tag;
    
    tag = [[EXFTag alloc] initWith:0x011b : FMT_URATIONAL :@"YResolution":-1:TRUE:1];
    tags[@0x011b] = tag;
    
    tag = [[EXFTag alloc] initWith:0x011c : FMT_USHORT :@"PlanarConfiguration":-1:TRUE:1];
    tags[@0x011c] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0128 : FMT_USHORT :@"ResolutionUnit":-1:TRUE:1];
    tags[@0x0128] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0131 : FMT_STRING :@"Software":-1:  TRUE:-99];
    tags[@0x0131] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0132 : FMT_STRING :@"DateTime":-1:  TRUE:20];
    tags[@0x0132] = tag;
    
    tag = [[EXFTag alloc] initWith:0x013b : FMT_STRING :@"Artist":-1:  TRUE:-99];
    tags[@0x013b] = tag;
    
    tag = [[EXFTag alloc] initWith:0x013c : FMT_STRING :@"HostComputer":-1:  TRUE:-99];
    tags[@0x013c] = tag;
    
    tag = [[EXFTag alloc] initWith:0x013d : FMT_USHORT :@"Predictor":-1:  TRUE:1];
    tags[@0x013d] = tag;
    
    tag = [[EXFTag alloc] initWith:0x013e : FMT_URATIONAL :@"WhitePoint":-1:  TRUE:2];
    tags[@0x013e] = tag;
    
    tag = [[EXFTag alloc] initWith:0x013f : FMT_URATIONAL :@"PrimaryChromaticities":-1:  TRUE:6];
    tags[@0x013f] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0201 : FMT_ULONG :@"JPEGInterchangeFormat":-1:  TRUE:1];
    tags[@0x0201] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0202 : FMT_ULONG :@"JPEGInterchangeFormatLength":-1:  TRUE:1];
    tags[@0x0202] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0211 : FMT_URATIONAL :@"YCbCrCoefficients":-1:  TRUE:3];
    tags[@0x0211] = tag;
    
    
    tag = [[EXFTag alloc] initWith:0x0212 : FMT_USHORT :@"YCbCrSubSampling":-1:  TRUE:2];
    tags[@0x0212] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0213 : FMT_USHORT :@"YCbCrPositioning":-1:  TRUE:1];
    tags[@0x0213] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0214 : FMT_URATIONAL :@"ReferenceBlackWhite":-1:  TRUE:6];
    tags[@0x0214] = tag;
    
    tag = [[EXFTag alloc] initWith:0x8298 : FMT_STRING :@"Copyright":-1:  TRUE:-99];
    tags[@0x08298] = tag;
    
    // Exif ID Tags
    
    tag = [[EXFTag alloc] initWith:0x829a : FMT_URATIONAL :@"ExposureTime":0x8769:TRUE:1];
    tags[@0x829a] = tag;
    
    tag = [[EXFTag alloc] initWith:0x829d : FMT_URATIONAL :@"FNumber":0x8769:TRUE:1];
    tags[@0x829d] = tag;
    
    tag = [[EXFTag alloc] initWith:0x8822 : FMT_USHORT :@"ExposureProgram":0x8769:TRUE:-99];
    tags[@0x8822] = tag;
    
    tag = [[EXFTag alloc] initWith:0x8824 : FMT_STRING :@"SpectralSensitivity":0x8769:TRUE:-99];
    tags[@0x8824] = tag;
    
    tag = [[EXFTag alloc] initWith:0x8827 : FMT_STRING :@"ISOSpeedratings":0x8769:TRUE:-99];
    tags[@0x8827] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9000 : FMT_UNDEFINED :@"ExifVersion":0x8769:TRUE:4];
    tags[@0x9000] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9003 : FMT_STRING :@"DateTimeOriginal":0x8769:TRUE:20];
    tags[@0x9003] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9004 : FMT_STRING :@"DateTimeDigitized":0x8769:TRUE:20];
    tags[@0x9004] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9102 : FMT_URATIONAL :@"CompressedBitsPerPixel":0x8769:TRUE:1];
    tags[@0x9102] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9201 : FMT_SRATIONAL :@"ShutterSpeedValue":0x8769:TRUE:1];
    tags[@0x9201] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9202 : FMT_URATIONAL :@"ApertureValue":0x8769:TRUE:1];
    tags[@0x9202] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9203 : FMT_SRATIONAL :@"BrightnessValue":0x8769:TRUE:1];
    tags[@0x9203] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9204 : FMT_SRATIONAL :@"ExposureBiasValue":0x8769:TRUE:1];
    tags[@0x9204] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9205 : FMT_URATIONAL :@"MaxApertureRatioValue":0x8769:TRUE:1];
    tags[@0x9205] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9206 : FMT_URATIONAL :@"SubjectDistance":0x8769:TRUE:1];
    tags[@0x9206] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9207 : FMT_USHORT :@"MeteringMode":0x8769:TRUE:1];
    tags[@0x9207] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9208 : FMT_USHORT :@"LightSource":0x8769:TRUE:1];
    tags[@0x9208] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9209 : FMT_USHORT :@"Flash":0x8769:TRUE:1];
    tags[@0x9209] = tag;
    
    tag = [[EXFTag alloc] initWith:0x920a : FMT_URATIONAL :@"FocalLength":0x8769:TRUE:1];
    tags[@0x920a] = tag;
    
    tag = [[EXFTag alloc] initWith:0x927c : FMT_UNDEFINED :@"MakerNote":0x8769:TRUE:-99];
    tags[@0x927c] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9286 : FMT_UNDEFINED :@"UserComment":0x8769:TRUE:-99];
    tags[@0x9286] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9290 : FMT_STRING :@"SubSecTime":0x8769:TRUE:-99];
    tags[@0x9290] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9291 : FMT_STRING :@"SubSecTimeOriginal":0x8769:TRUE:-99];
    tags[@0x9291] = tag;
    
    tag = [[EXFTag alloc] initWith:0x9292 : FMT_STRING :@"SubSecTimeDigitized":0x8769:TRUE:-99];
    tags[@0x9292] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa300 : FMT_UNDEFINED :@"FileSource":0x8769:TRUE:1];
    tags[@0xa300] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa301 : FMT_UNDEFINED :@"SceneType":0x8769:TRUE:1];
    tags[@0xa301] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa302 : FMT_UNDEFINED :@"CFAPattern":0x8769:TRUE:-99];
    tags[@0xa302] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa000 : FMT_UNDEFINED :@"FlashpixVersion":0x8769:TRUE:4];
    tags[@0xa000] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa001 : FMT_USHORT :@"ColorSpace":0x8769:TRUE:1];
    tags[@0xa001] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa002 : FMT_ULONG :@"PixelXDimension":0x8769:TRUE:1];
    tags[@0xa002] = tag;

    
    tag = [[EXFTag alloc] initWith:0xa003 : FMT_ULONG :@"PixelYDimension":0x8769:TRUE:1];
    tags[@0xa003] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa20e : FMT_URATIONAL :@"FocalPlaneXResolution":0x8769:TRUE:1];
    tags[@0xa20e] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa20f : FMT_URATIONAL :@"FocalPlaneYResolution":0x8769:TRUE:1];
    tags[@0xa20f] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa210 : FMT_USHORT :@"FocalPlaneResolutionUnit":0x8769:TRUE:1];
    tags[@0xa210] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa214 : FMT_USHORT :@"SubjectLocation":0x8769:TRUE:2];
    tags[@0xa214] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa215 : FMT_URATIONAL :@"ExposureTime":0x8769:TRUE:1];
    tags[@0xa215] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa217 : FMT_USHORT :@"SensingMethod":0x8769:TRUE:1];
    tags[@0xa217] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa300 : FMT_UNDEFINED :@"FileSource":0x8769:TRUE:1];
    tags[@0xa300] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa302 : FMT_UNDEFINED :@"CFAPattern":0x8769:TRUE:-99];
    tags[@0xa302] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa301 : FMT_UNDEFINED :@"SceneType":0x8769:TRUE:1];
    tags[@0xa301] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa401 : FMT_USHORT :@"CustomRendered":0x8769:TRUE:1];
    tags[@0xa401] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa402 : FMT_USHORT :@"ExposureMode":0x8769:TRUE:1];
    tags[@0xa402] = tag;
    
    
    tag = [[EXFTag alloc] initWith:0xa403 : FMT_USHORT :@"WhiteBalance":0x8769:TRUE:1];
    tags[@0xa403] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa404 : FMT_URATIONAL :@"DigitalZoomRatio":0x8769:TRUE:1];
    tags[@0xa404] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa405 : FMT_USHORT :@"FocalLengthIn35mmFilm":0x8769:TRUE:1];
    tags[@0xa405] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa406 : FMT_USHORT :@"SceneCaptureType":0x8769:TRUE:1];
    tags[@0xa406] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa407 : FMT_URATIONAL :@"GainControl":0x8769:TRUE:1];
    tags[@0xa407] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa408 : FMT_USHORT :@"Contrast":0x8769:TRUE:1];
    tags[@0xa408] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa409 : FMT_USHORT :@"Saturation":0x8769:TRUE:1];
    tags[@0xa409] = tag;
    
    
    tag = [[EXFTag alloc] initWith:0xa40a : FMT_USHORT :@"Sharpness":0x8769:TRUE:1];
    tags[@0xa40a] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa40b : FMT_UNDEFINED :@"DeviceSettingDescription":0x8769:TRUE:-99];
    tags[@0xa40b] = tag;
    
    tag = [[EXFTag alloc] initWith:0xa40c : FMT_USHORT :@"SubjectDistanceRange":0x8769:TRUE:1];
    tags[@0xa40c] = tag;
    
    
    tag = [[EXFTag alloc] initWith:0xa500 : FMT_URATIONAL :@"Gamma":0x8769:FALSE:1];
    tags[@0xa500] = tag;
    // gps tags
    tag = [[EXFTag alloc] initWith:0x0000 : FMT_BYTE :@"GPSVersion":0x8825:TRUE:4];
    tags[@0x0000] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0001 : FMT_STRING :@"GPSLatitudeRef":0x8825:  TRUE:2];
    tags[@0x0001] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0002 : FMT_URATIONAL :@"GPSLatitude":0x8825:  TRUE:3];
    tags[@0x0002] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0003 : FMT_STRING :@"GPSLongitudeRef":0x8825:  TRUE:2];
    tags[@0x0003] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0004 : FMT_URATIONAL :@"GPSLongitude":0x8825:  TRUE:3];
    tags[@0x0004] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0005 : FMT_BYTE :@"GPSAltitudeRef":0x8825:  TRUE:1];
    tags[@0x0005] = tag;
    
    tag = [[EXFTag alloc] initWith:0x0006 : FMT_URATIONAL :@"GPSAltitude":0x8825:  TRUE:1];
    tags[@0x0006] = tag;
     
     tag = [[EXFTag alloc] initWith:0x0007 : FMT_URATIONAL :@"GPSTimeStamp":0x8825:  TRUE:3];
     tags[@0x0007] = tag;
      
      tag = [[EXFTag alloc] initWith:0x0008 : FMT_STRING :@"GPSSatellites":0x8825:  TRUE:-99];
      tags[@0x0008] = tag;
       
       tag = [[EXFTag alloc] initWith:0x0009 : FMT_STRING :@"GPSStatus":0x8825:  TRUE:2];
       tags[@0x0009] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000a : FMT_STRING :@"GPSMeasureMode":0x8825:  TRUE:2];
        tags[@0x000a] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000b : FMT_URATIONAL :@"GPSDOP":0x8825:  TRUE:1];
        tags[@0x000b] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000c : FMT_STRING :@"GPSSpeedRef":0x8825:  TRUE:2];
        tags[@0x000c] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000d : FMT_URATIONAL :@"GPSSpeed":0x8825:  TRUE:1];
        tags[@0x000d] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000e : FMT_STRING :@"GPSTrackRef":0x8825:  TRUE:2];
        tags[@0x000e] = tag;
        
        tag = [[EXFTag alloc] initWith:0x000f : FMT_URATIONAL :@"GPSTrack":0x8825:  TRUE:1];
        tags[@0x000f] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0010 : FMT_STRING :@"GPSImgDirectionRef":0x8825:  TRUE:2];
        tags[@0x0010] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0011 : FMT_URATIONAL :@"GPSImgDirection":0x8825:  TRUE:1];
        tags[@0x0011] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0012 : FMT_STRING :@"GPSMapDatum":0x8825:  TRUE:-99];
        tags[@0x0012] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0013 : FMT_STRING :@"GPSDestLatitudeRef":0x8825:  TRUE:2];
        tags[@0x0013] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0014 : FMT_URATIONAL :@"GPSDestLatitude":0x8825:  TRUE:3];
        tags[@0x0014] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0015 : FMT_STRING :@"GPSDestLongitudeRef":0x8825:  TRUE:2];
        tags[@0x0015] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0016 : FMT_URATIONAL :@"GPSDestLongitude":0x8825:  TRUE:3];
        tags[@0x0016] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0017 : FMT_STRING :@"GPSDestBearingRef":0x8825:  TRUE:2];
        tags[@0x0017] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0018 : FMT_URATIONAL :@"GPSDestBearing":0x8825:  TRUE:1];
        tags[@0x0018] = tag;
        
        tag = [[EXFTag alloc] initWith:0x0019 : FMT_STRING :@"GPSDestDistanceRef":0x8825:  TRUE:2];
        tags[@0x0019] = tag;
        
        tag = [[EXFTag alloc] initWith:0x001a : FMT_URATIONAL :@"GPSDestDistance":0x8825:  TRUE:1];
        tags[@0x001a] = tag;
        
        
        
        self.definitions = tags;
        
        
        
     
        }
        
-(instancetype) init {

    if (self = [super init]) {
        [self createTags];
    }
    return self;
}


@end
