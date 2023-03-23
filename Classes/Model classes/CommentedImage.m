/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2023 MyFlightbook, LLC
 
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
//  CommentedImage.m
//  MFBSample
//
//  Created by Eric Berman on 2/5/10.
//

#import <MyFlightbook-Swift.h>
#import "CommentedImage.h"
#import <Security/SecRandom.h>
#import "EXF.h"
#import "EXFUtils.h"
#import "Reachability.h"
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface CommentedImage ()
@property (strong) UIImage * imgCached;
@property (strong) UIImage * imgPendingToSave;
- (NSData *) GeoTagWithLocation:(CLLocation *) imageLocation andAdditionalData:(NSDictionary *) dictExif;
@end


@implementation CommentedImage
@synthesize imgInfo, errorString, szCacheFileName, imgCached, imgPendingToSave;

NSString * const szTmpExtension = @"tmp-img.jpg";
NSString * const szTmpVidExtension = @"tmp-vid.mov";

+ (NSString *) ImageDocsDir
{
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString * documentsDirectory = paths[0];
	return documentsDirectory;
}

+ (NSString *) FullFilePathName:(NSString *) szFile
{
	return [[self ImageDocsDir] stringByAppendingPathComponent:szFile];
}

- (NSString *) FullFilePathName
{
	return [CommentedImage FullFilePathName:self.szCacheFileName];
}

- (NSURL *) LocalFileURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", self.FullFilePathName]];
}

- (void) CleanUpFile
{
	if ([self.szCacheFileName length] > 0)
	{
        NSError * err;
        if (![[NSFileManager defaultManager] removeItemAtPath:[self FullFilePathName] error:&err])
            NSLog(@"Error cleaning up file: %@", err.description);
	}
}

// Clean up any files that are not used in the specified list of images, just 
// in case they didn't get cleaned up before (which they should at dealloc time)
+ (void) cleanupObsoleteFiles:(NSArray *) rgImages
{
	NSFileManager * filemanager = [NSFileManager defaultManager];
	NSArray * rgFiles = [filemanager contentsOfDirectoryAtPath:[self ImageDocsDir] error:NULL];
	if (rgFiles != nil)
	{
		for (NSString * szFile in rgFiles) {
			if ([szFile hasSuffix:szTmpExtension])
			{
				BOOL fOKDelete = YES;
				NSError * e;
				for (CommentedImage * ci in rgImages)
					if ([ci.szCacheFileName compare:szFile] == NSOrderedSame)
						fOKDelete = NO;
				if (fOKDelete)
					if (![filemanager removeItemAtPath:[CommentedImage FullFilePathName:szFile] error:&e])
						NSLog(@"Error deleting file %@: %@", szFile, [e localizedDescription]);
			}
		}
	}
}

- (void)dealloc {
	[self CleanUpFile];
}

- (instancetype) init
{
	if ((self = [super init]))
	{
		self.imgInfo = [[MFBWebServiceSvc_MFBImageInfo alloc] init];
		self.szCacheFileName = @"";
		self.errorString = @"";
		self.imgCached = nil;
	}
	return self;
}

- (BOOL) IsVideo
{
    return self.imgInfo.ImageType == MFBWebServiceSvc_ImageFileType_S3VideoMP4;
}

- (void) flushCachedImage
{
	if (self.imgCached != nil)
		self.imgCached = nil;
}

- (UIImage *) loadImageFromMFBInfo
{
	if (!MFBAppDelegate.threadSafeAppDelegate.isOnLine)
		return nil;
	
	NSURL * url = [self.imgInfo urlForImage];
	if (url != nil)
	{
		NSData * d = [NSData dataWithContentsOfURL:url];
		if (d != nil)
		{
			UIImage * img = [[UIImage alloc] initWithData:d];
			return img;
		}
	}
	
	return nil;
}

// Retrieves the image from disk
- (UIImage *) GetImage
{
	if (self.imgCached != nil)
		return self.imgCached;
	else if (self.imgPendingToSave != nil)
		return (self.imgCached = self.imgPendingToSave);
	else if ([self.imgInfo livesOnServer])
		return [self loadImageFromMFBInfo];
	else if (self.IsVideo)
    {
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:self.LocalFileURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        self.imgCached = [[UIImage alloc] initWithCGImage:oneRef];
        CFRelease(oneRef);  // issue #263
        return self.imgCached;
    }
	else
        return self.szCacheFileName.length == 0 ? nil : (self.imgCached = [UIImage imageWithContentsOfFile:[self FullFilePathName]]);
}

- (BOOL) hasThumbnailCache {
    return self.imgInfo.cachedThumb != nil;
}

// gets lightweight thumbnail, which is always cached.  But this also always flushes the big image out of the cache
- (UIImage *) GetThumbnail
{
    if (self.imgInfo.cachedThumb != nil)
        return self.imgInfo.cachedThumb;
	else
	{
        UIImage * img = [CommentedImage imageWithImage:[self GetImage] scaledToSize:CGSizeMake(THUMB_WIDTH, THUMB_HEIGHT)];
        self.imgInfo.cachedThumb = img;
		[self flushCachedImage];
		return img;
	}
}

- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo:(void *) contextInfo
{
	if (error != nil)
        [WPSAlertController presentOkayAlertWithError:error];
}

- (void) saveImageDataToLibrary: (NSData *) taggedJPG {
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], @"img.jpg"];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    NSError * error = nil;
    [taggedJPG writeToURL:fileURL options:NSDataWritingAtomic error:&error];

    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // UIImage * image = [UIImage imageWithData:taggedJPG];
        // [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"Saved image: %@, error: %@", success ? @"success" : @"failed", error == nil ? @"(no error)" : error.localizedDescription);
        error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
        if (error != nil)
            NSLog(@"Error cleaning up temp file: %@", error.localizedDescription);
    }];
}

- (void) saveVideoDataToLibrary:(NSURL *) url {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"Saved video: %@, error: %@", success ? @"success" : @"failed", error == nil ? @"(no error)" : error.localizedDescription);
    }];
}

- (void) saveImageFromCameraWorker:(NSDictionary *) dictMetaData
{
    @autoreleasepool {
        MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
        
        // save a local copy for ourselves, with GPS data
        NSMutableDictionary * dictAdditionalData = [[NSMutableDictionary alloc] init];
        
        NSDictionary * dictExif = nil;

        // UIImagePickerControllerMediaMetadata is only available in 4.1 or later
        dictExif = (NSDictionary *) dictMetaData[UIImagePickerControllerMediaMetadata];
        
        if (dictExif != nil)
        {
            NSDictionary * oExif = (NSDictionary *) dictExif[@"{Exif}"];
            NSNumber * oOrientation = (NSNumber *) dictExif[@"Orientation"];
            
            if (oExif != nil && [oExif isKindOfClass:[NSDictionary class]])
                [dictAdditionalData setDictionary:oExif];
            if (oOrientation != nil && [oOrientation isKindOfClass:[NSNumber class]])
                dictAdditionalData[@"Orientation"] = oOrientation;
        }
            
        NSData * taggedJPG = [self GeoTagWithLocation:app.mfbloc.lastSeenLoc andAdditionalData:dictAdditionalData];
        self.imgPendingToSave = nil;
        
        if ([PHPhotoLibrary class] == nil)
        {
            // save a copy of the image to the photos album.  This currently loses metadata
            UIImageWriteToSavedPhotosAlbum([self GetImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
        else
        {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            switch (status) {
                case PHAuthorizationStatusNotDetermined: {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        [self saveImageDataToLibrary:taggedJPG];
                    }];
                }
                    break;
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusLimited:
                    break;
                case PHAuthorizationStatusAuthorized:
                    [self saveImageDataToLibrary:taggedJPG];
                    break;
            }
        }
    }
}

// Save the video from the camera to the user's assets.  This will also provide the persisted video storage.
- (void) saveVideoFromCameraWorker
{
    @autoreleasepool {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    [self saveVideoDataToLibrary:[NSURL URLWithString:self.imgInfo.URLFullImage]];
                }];
            }
                break;
            case PHAuthorizationStatusDenied:
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusLimited:
                break;
            case PHAuthorizationStatusAuthorized:
                [self saveVideoDataToLibrary:[NSURL URLWithString:self.imgInfo.URLFullImage]];
                break;
        }

    }
}

- (void) saveImageWorker:(NSDictionary *) dictMetaData
{
    @autoreleasepool {
        // No metadata, no GPS provided (even in the dictionary above), so just write it out where we won't lose it.
        if (self.imgInfo.Location == nil)
            [UIImageJPEGRepresentation([self GetImage], 1.0) writeToFile:[self FullFilePathName] atomically:YES];
        else
            [self GeoTagWithLocation:[[CLLocation alloc] initWithLatitude:self.imgInfo.Location.coordinate.latitude longitude:self.imgInfo.Location.coordinate.longitude] andAdditionalData:dictMetaData];
        
        self.imgPendingToSave = nil;
    }
}

// sets the image, saving it to disk in the background
- (void) SetImage:(UIImage *) img fromCamera:(BOOL)fFromCamera withMetaData:(NSDictionary *) dict
{
	// cache the image
	self.imgCached = img;
	self.imgPendingToSave = nil;
	
	// generate a cache filename and save the image
	if ([self.szCacheFileName length] == 0 && ![self.imgInfo livesOnServer])
	{
		NSLog(@"New image, not on server - need to save it");
		uint8_t b[4] = {0, 0, 0, 0};
		int i = SecRandomCopyBytes(kSecRandomDefault, sizeof(b), b);
		if (i != 0)
			NSLog(@"Error setting image - generating random bytes");
		CGSize s = img.size;
		self.szCacheFileName = [NSString stringWithFormat:@"%d%d-%d%d%d%d%@", (int) s.height, (int) s.width, (int) b[0], (int) b[1], (int) b[2], (int) b[3], szTmpExtension];

		// if it's from the camera, geotag it and save it to the album
		// else, just save it so that we have it.
		self.imgPendingToSave = self.imgCached;
		[NSThread detachNewThreadSelector:(fFromCamera) ? @selector(saveImageFromCameraWorker:) : @selector(saveImageWorker:) toTarget:self withObject:dict];
	}
}

- (void) SetVideo:(NSURL *) szVideoURL fromCamera:(BOOL) fFromCamera
{
    self.imgPendingToSave = nil;
    self.imgInfo.ImageType = MFBWebServiceSvc_ImageFileType_S3VideoMP4;
    self.imgInfo.URLFullImage = szVideoURL.absoluteString;
    
    // Save a local copy regardless of whether or not it was from the camera
    self.szCacheFileName = [NSString stringWithFormat:@"%@%@", [[NSUUID UUID] UUIDString], szTmpVidExtension];
    NSData *videoData = [NSData dataWithContentsOfURL:szVideoURL];
    [videoData writeToFile:self.FullFilePathName atomically:NO];
    
    if (fFromCamera)
        [NSThread detachNewThreadSelector:@selector(saveVideoFromCameraWorker) toTarget:self withObject:nil];
}

- (void) updateAnnotation:(NSString *) szAuthToken
{
	NSLog(@"updateAnnotation");
	self.errorString = @"";
	
	// return success if this has never actually been saved.
	if (![self.imgInfo livesOnServer])
		return;
	
	MFBWebServiceSvc_UpdateImageAnnotation * iaSvc = [MFBWebServiceSvc_UpdateImageAnnotation new];
	
	iaSvc.mfbii = self.imgInfo;
	iaSvc.szAuthUserToken = szAuthToken;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = nil;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b UpdateImageAnnotationAsyncUsingParameters:iaSvc delegate:sc];
    }];
}

- (void) deleteImage:(NSString *) szAuthToken
{
	NSLog(@"deleteImage");
	self.errorString = @"";
	
	// return success if this has never actually been saved
	if (![self.imgInfo livesOnServer])
		return;
	
	MFBWebServiceSvc_DeleteImage * diSvc = [MFBWebServiceSvc_DeleteImage new];
	diSvc.szAuthUserToken = szAuthToken;
	diSvc.mfbii = self.imgInfo;
	
	MFBSoapCall * sc = [[MFBSoapCall alloc] init];
	sc.delegate = nil;
	
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b DeleteImageAsyncUsingParameters:diSvc delegate:sc];
    }];
}

// MKAnnotation protocol methods
- (NSString *) title
{
    NSString * szTitle = self.imgInfo.Comment;
    if ([szTitle length] == 0)
        szTitle = NSLocalizedString(@"(Untitled Image)", @"Default comment to show for an image with no comment");
    return szTitle;
}

- (NSString *) subtitle
{
    return @"";
}

- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coord;
    
    coord.latitude = [self.imgInfo.Location.Latitude doubleValue];
    coord.longitude = [self.imgInfo.Location.Longitude doubleValue];
    return coord;
}

// EXIF helper utilities, from http://iphone-land.blogspot.com
// Helper methods for location conversion
-(NSMutableArray*) createLocArray:(double) val{
	val = fabs(val);
	NSMutableArray* array = [[NSMutableArray alloc] init];
	double deg = (int)val;
	[array addObject:@(deg)];
	val = val - deg;
	val = val*60;
	double minutes = (int) val;
	[array addObject:@(minutes)];
	val = val - minutes;
	val = val *60;
	double seconds = val;
	[array addObject:@(seconds)];
	return array;
} 

-(void) populateGPS: (EXFGPSLoc*)gpsLoc :(NSArray*) locArray{
	long numDenumArray[2];
	long* arrPtr = numDenumArray;
	[EXFUtils convertRationalToFraction:&arrPtr :locArray[0]];
	EXFraction* fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
	gpsLoc.degrees = fract;
	[EXFUtils convertRationalToFraction:&arrPtr :locArray[1]];
	fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
	gpsLoc.minutes = fract;
	[EXFUtils convertRationalToFraction:&arrPtr :locArray[2]];
	fract = [[EXFraction alloc] initWith:numDenumArray[0] :numDenumArray[1]];
	gpsLoc.seconds = fract;
}
// end of helper methods

- (NSData *) GeoTagWithLocation:(CLLocation *) imageLocation andAdditionalData:(NSDictionary *) dictExif
{
	if (imageLocation == nil)
		return nil;
	
	NSData * jpegData = nil;
	NSError * errorPtr = nil;
	
	jpegData = UIImageJPEGRepresentation([self GetImage], 1.0);

	if (jpegData == nil)
	{
		NSLog(@"Error geotagging - could not get jpeg data: %@", [errorPtr localizedDescription]);
		return nil;
	}


    EXFJpeg* jpegScanner = [[EXFJpeg alloc] init];
    [jpegScanner scanImageData: jpegData];
	
    EXFMetaData* exifMetaData = jpegScanner.exifMetaData;

	if (imageLocation != nil)
	{
		NSLog(@"Geotagging at location {@%.8f, @%.8F}", imageLocation.coordinate.latitude, imageLocation.coordinate.longitude);
		// adding GPS data to the Exif object 
		NSMutableArray* locArray = [self createLocArray:imageLocation.coordinate.latitude]; 
		EXFGPSLoc* gpsLoc = [[EXFGPSLoc alloc] init]; 
		[self populateGPS: gpsLoc :locArray]; 
		[exifMetaData addTagValue:gpsLoc forKey:@EXIF_GPSLatitude ]; 
		locArray = [self createLocArray:imageLocation.coordinate.longitude]; 
		gpsLoc = [[EXFGPSLoc alloc] init]; 
		[self populateGPS: gpsLoc :locArray]; 
		[exifMetaData addTagValue:gpsLoc forKey:@EXIF_GPSLongitude ]; 
		NSString* ref;
		if (imageLocation.coordinate.latitude <0.0)
			ref = @"S"; 
		else
			ref =@"N"; 
		[exifMetaData addTagValue: ref forKey:@EXIF_GPSLatitudeRef ]; 
		if (imageLocation.coordinate.longitude <0.0)
			ref = @"W"; 
		else
			ref =@"E"; 
		[exifMetaData addTagValue: ref forKey:@EXIF_GPSLongitudeRef ];
	}
	
	// add any relevant properties that are present
	NSNumber * orientation = (NSNumber *) dictExif[@"Orientation"];
	if (orientation != nil)
		[exifMetaData addTagValue:orientation forKey:@EXIF_Orientation];
	
	NSString * szDateTime = (NSString *) dictExif[(NSString *) @"DateTimeOriginal"];
	if (szDateTime != nil)
		[exifMetaData addTagValue:szDateTime forKey:@EXIF_DateTimeOriginal];

	szDateTime = (NSString *) dictExif[(NSString *) @"DateTimeDigitized"];
    if (szDateTime != nil)
		[exifMetaData addTagValue:szDateTime forKey:@EXIF_DateTimeDigitized];
	
    NSMutableData* taggedJpegData = [[NSMutableData alloc] init];
		
    [jpegScanner populateImageData:taggedJpegData];

	if ([taggedJpegData writeToFile:self.FullFilePathName atomically:YES])
        return taggedJpegData;
    else
        return nil;
}

// Determines if we can submit the specified images.
// We can submit if on WiFi OR if no videos.
+ (BOOL) canSubmitImages:(NSArray *) rg
{
    // if we are on wifi, no restrictions
    if (MFBAppDelegate.threadSafeAppDelegate.lastKnownNetworkStatus == ReachableViaWiFi)
        return true;

    // else, we can't submit if any videos are found.
    for (CommentedImage * ci in rg)
    {
        if (ci.IsVideo)
            return false;
    }
    
    return true;
}

+ (void) uploadImages:(NSArray *) rgImages progressUpdate:(void (^)(NSString *))progress toPage:(NSString *) pageName authString:(NSString *) szAuth keyName:(NSString *) keyName keyValue:(NSString *) keyValue
{	
	int cImages = 0;
	__block int cErrors = 0;
	__block NSString * szLastErr = nil;

	if (pageName == nil || [pageName length] == 0)
		return;
	
    for (CommentedImage * ci in rgImages)
	{
		// skip if this isn't a commented image
		if (![ci isKindOfClass:[CommentedImage class]])
			continue;
				
		cImages++;
		
        if (progress != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress([NSString stringWithFormat:NSLocalizedString(@"Uploading Image %d of %lu", @"Progress message when uploading an image; the %d is replaced by numbers (e.g. '2 of 4')"), cImages, (unsigned long)[rgImages count]]);
            });
        }

		// skip if this isn't a new file
		if (ci.imgInfo.livesOnServer)
			continue;

		// skip if this isn't a file on disk
		if ([ci.szCacheFileName length] == 0)
			continue;

        BOOL fVideo = ci.IsVideo;
        
        @autoreleasepool {
            NSData * imgData = [NSData dataWithContentsOfFile:ci.FullFilePathName];

            if (imgData == nil)
                continue;

            NSString * szBase = [NSString stringWithFormat:@"https://%@", MFBHOSTNAME];
            NSString * szURL = [NSString stringWithFormat:@"%@%@", szBase, pageName];
            NSString * boundary = @"IMAGEBOUNDARY";
            
            NSURL *url = [NSURL URLWithString:szURL];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
            [req setHTTPMethod:@"POST"];
            
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
            [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
            
            //adding the body:
            NSMutableData *postBody = [NSMutableData data];
            [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Disposition: form-data; name=\"txtAuthToken\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[szAuth dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Disposition: form-data; name=\"txtComment\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[ci.imgInfo.Comment dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", keyName] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[keyValue dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            NSString * szFileNameUpload = fVideo ? @"myvideo.mov" : @"myimage.jpg";
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imgPicture\"; filename=\"%@\"\r\n", szFileNameUpload] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\nContent-Transfer-Encoding: binary\r\n\r\n", (fVideo ? @"video/mp4" : @"image/jpeg")] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postBody appendData:imgData];

            // save some memory
            [ci flushCachedImage];
            
            [postBody appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [req setHTTPBody:postBody];
            
            NSError * callError;
            __block NSString * szResponse = nil;
            
            NSURLSession *session = [NSURLSession sharedSession];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [[session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data != nil)
                    szResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if (szResponse == nil || [szResponse rangeOfString:@"OK"].location != 0)
                {
                    cErrors++;
                    
                    if (szResponse != nil)
                        szLastErr = [[NSString alloc] initWithString:szResponse];
                    else
                        szLastErr = [callError localizedDescription];
                }
                dispatch_semaphore_signal(semaphore);
            }] resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
	}
    
	if (cErrors > 0)
	{
		NSString * szText = [NSString stringWithFormat:NSLocalizedString(@"%d of %d images uploaded.  Error: %@", @"Status after uploading images; %d and %@ get replaced by numbers and the error message, respectively; keep them"), (cImages - cErrors), cImages, szLastErr];
        dispatch_async(dispatch_get_main_queue(), ^{
            [WPSAlertController presentOkayAlertWithTitle:NSLocalizedString(@"Error uploading Pictures", @"Error message if there were errors uploading an image") message:szText];
        });
	}

}

+ (BOOL) initCommentedImagesFromMFBII:(NSArray *) rgmfbii toArray:(NSMutableArray *)rgImages
{
    BOOL fResult = NO;
    
    @synchronized (rgmfbii) {
        // add existing images to the image array
        for (MFBWebServiceSvc_MFBImageInfo * mfbii in rgmfbii)
        {
            // add it to the list IF not already in the list.
            BOOL fAlreadyInList = NO;
            for (CommentedImage * ciExisting in rgImages)
                if ([ciExisting.imgInfo.ThumbnailFile compare:mfbii.ThumbnailFile] == NSOrderedSame)
                    fAlreadyInList = YES;
            if (!fAlreadyInList)
            {
                CommentedImage * ci = [[CommentedImage alloc] init];
                ci.imgInfo = mfbii;
                UIImage * img = [ci loadImageFromMFBInfo];
                if (img != nil && img.CGImage != nil)
                {
                    [ci SetImage:img fromCamera:NO withMetaData:nil];
                    [rgImages addObject:ci];
                    fResult = YES;
                }
            }
        }
    }
    return fResult;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    if (image == nil)
        return nil;
    
	// compute the size that preserves the aspect ratio.
	CGFloat ratioX = newSize.width / image.size.width;
	CGFloat ratioY = newSize.height / image.size.height;
	CGFloat ratio = 1.0; // default ratio
	
	if (ratioX < 1.0 || ratioY < 1.0)
		ratio = (ratioX < ratioY) ? ratioX : ratioY;
	
	newSize.width = image.size.width * ratio;
	newSize.height = image.size.height * ratio;
	
	// Create a graphics image context
	UIGraphicsBeginImageContext(newSize);
	
	// Tell the old image to draw in this new context, with the desired
	// new size
	[image drawInRect:CGRectMake(0,0,image.size.width * ratio,image.size.height * ratio)];
	
	// Get the new image from the context
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	// End the context
	UIGraphicsEndImageContext();
	
	// Return the new image.
	return newImage;
}


+ (void) addCommentedImages:(NSArray *) rgImages toImageView:(UIImageView *) imgView
{
	// the objects here are commented images, so we need to create an array of the actual images.
	NSMutableArray * rgImg = [[NSMutableArray alloc] init];
	for (CommentedImage * ci in rgImages)
	{
		/// create a resized image to store.
		UIImage * imgNew = [ci GetThumbnail];
		if (imgNew != NULL)
			[rgImg addObject:imgNew];
	}
	
	imgView.animationImages = rgImg;
	imgView.animationDuration = 2 * [rgImg count]; // 2 seconds/image
	[imgView startAnimating];
}

+ (BOOL) supportsSecureCoding {return YES; }

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.imgInfo forKey:@"mfbImageInfo"];
	[encoder encodeObject:self.szCacheFileName forKey:@"cacheName"];
}
 
 - (instancetype)initWithCoder:(NSCoder *)decoder
{
	self = [self init];
	self.errorString = @"";
	self.imgInfo = [decoder decodeObjectOfClass:MFBWebServiceSvc_MFBImageInfo.class forKey:@"mfbImageInfo"];
    self.szCacheFileName = [decoder	decodeObjectOfClass:NSString.class forKey:@"cacheName"];
	return self;
}	 	 
@end

@implementation  MFBWebServiceSvc_MFBImageInfo (NSCodingSupport)
static char UIB_CACHEDTHUMB_KEY;
- (void) setCachedThumb:(UIImage *) img {
    objc_setAssociatedObject(self, &UIB_CACHEDTHUMB_KEY, img, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *) cachedThumb {
    return (UIImage *) objc_getAssociatedObject(self, &UIB_CACHEDTHUMB_KEY);
}

- (void)encodeWithCoderMFB:(NSCoder *)encoder;
{
	[encoder encodeObject:self.Comment forKey:@"MFBIIComment"];
	[encoder encodeObject:self.ThumbnailFile forKey:@"MFBIIThumbFile"];
	[encoder encodeObject:self.VirtualPath forKey:@"MFBIIVirtPath"];
	[encoder encodeObject:self.URLFullImage forKey:@"MFBIIFullImageURL"];
    [encoder encodeInteger:self.ImageType forKey:@"MFBIIImageType"];
    [encoder encodeObject:self.cachedThumb forKey:@"MFBIICachedThumb"];
    [encoder encodeObject:self.URLThumbnail forKey:@"MFBIIURLThumb"];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];
	self.Comment = [decoder decodeObjectOfClass:NSString.class forKey:@"MFBIIComment"];
	self.ThumbnailFile = [decoder decodeObjectOfClass:NSString.class forKey:@"MFBIIThumbFile"];
	self.VirtualPath = [decoder decodeObjectOfClass:NSString.class forKey:@"MFBIIVirtPath"];
	self.URLFullImage = [decoder decodeObjectOfClass:NSString.class forKey:@"MFBIIFullImageURL"];
    self.URLThumbnail = [decoder decodeObjectOfClass:NSString.class forKey:@"MFBIIURLThumb"];
    @try {
        self.ImageType = (MFBWebServiceSvc_ImageFileType) [decoder decodeIntegerForKey:@"MFBIIImageType"];
        self.cachedThumb = (UIImage *) [decoder decodeObjectOfClass:UIImage.class forKey:@"MFBIICachedThumb"];
    }
    @catch (NSException *exception) {
        self.ImageType = MFBWebServiceSvc_ImageFileType_JPEG;
        self.cachedThumb = nil;
    }
    @finally {
    }
	return self;
}

- (NSURL *) urlForImage
{
    NSString * szURLImage = [self.URLThumbnail hasPrefix:@"/"] ? [NSString stringWithFormat:@"https://%@%@", MFBHOSTNAME, self.URLThumbnail] : self.URLThumbnail;
	return [NSURL URLWithString:szURLImage];
}

- (BOOL) livesOnServer
{
	return (self.VirtualPath != nil && [self.VirtualPath length] > 0);
}

@end

@implementation MFBWebServiceSvc_ArrayOfMFBImageInfo (NSCodingSupport)
- (void)encodeWithCoderMFB:(NSCoder *)encoder;
{
	[encoder encodeObject:self.MFBImageInfo forKey:@"RGMFBIImages"];
}

- (instancetype)initWithCoderMFB:(NSCoder *)decoder
{
	self = [self init];

    NSError * err;
    NSMutableArray * rgImages = [decoder decodeTopLevelObjectOfClasses:[NSSet setWithArray:@[NSArray.class, MFBWebServiceSvc_MFBImageInfo.class]] forKey:@"RGMFBIImages" error:&err];
	[self setImages:rgImages];
	
	return self;
}

- (void) setImages:(NSMutableArray *) rgImages
{
	MFBImageInfo = rgImages;
}
@end
