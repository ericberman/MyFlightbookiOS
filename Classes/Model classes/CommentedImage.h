/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2010-2020 MyFlightbook, LLC
 
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
//  CommentedImage.h
//  MFBSample
//
//  Created by Eric Berman on 2/5/10.
//  Copyright 2010-2019 MyFlightbook LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFBWebServiceSvc.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CommentedImage : NSObject <MKAnnotation, NSCoding, NSSecureCoding> {
	MFBWebServiceSvc_MFBImageInfo * imgInfo;
	NSString * errorString;
	
@private
	UIImage * imgCached;
	UIImage * imgPendingToSave;
}

#define THUMB_WIDTH 120
#define THUMB_HEIGHT 120

@property (nonatomic, strong) MFBWebServiceSvc_MFBImageInfo * imgInfo;
@property (nonatomic, strong) NSString * errorString;
@property (nonatomic, strong) NSString * szCacheFileName;

+ (void) uploadImages:(NSArray *) rgImages progressUpdate:(void (^)(NSString *))progress toPage:(NSString *) pageName authString:(NSString *) szAuth keyName:(NSString *) keyName keyValue:(NSString *) keyValue;
+ (BOOL) initCommentedImagesFromMFBII:(NSArray *) rgmfbii toArray:(NSMutableArray *)rgImages;
+ (void) addCommentedImages:(NSArray *) rgImages toImageView:(UIImageView *) imgView;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (void) cleanupObsoleteFiles:(NSArray *) rgImages;
+ (BOOL) canSubmitImages:(NSArray *) rg;

- (void) updateAnnotation:(NSString *) szAuthToken;
- (void) deleteImage:(NSString *) szAuthToken;

- (void) flushCachedImage;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (instancetype)initWithCoder:(NSCoder *)decoder;

- (NSString *) FullFilePathName;
- (NSURL *) LocalFileURL;

- (UIImage *) GetThumbnail;
- (BOOL) hasThumbnailCache;
- (void) SetImage:(UIImage *) img fromCamera:(BOOL)fFromCamera withMetaData:(NSDictionary *) dict;
- (void) SetVideo:(NSURL *) szVideoURL fromCamera:(BOOL) fFromCamera;
- (BOOL) IsVideo;

@end
