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
//  CommentedImage.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/24/23.
//

import Foundation
import MapKit
import CoreMedia
import AVFoundation
import Photos
import MediaPlayer
import Security

@objc public class CommentedImage :NSObject, MKAnnotation, NSCoding, NSSecureCoding {
    
    @objc public var imgInfo : MFBWebServiceSvc_MFBImageInfo? = MFBWebServiceSvc_MFBImageInfo()
    @objc public var errorString = ""
    
    private var imgCached : UIImage? = nil
    private var imgPendingToSave : UIImage? = nil
    private var szCacheFileName = ""
    
    private static let THUMB_WIDTH = 120.0
    private static let THUMB_HEIGHT = 120.0
    
    private static let szTmpExtension = "tmp-img.jpg"
    private static let szTmpVidExtension = "tmp-vid.mov"
    
    // MARK: Directories and paths and file management
    static var ImageDocsDir : String {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
    }
    
    static func FullFilePathName(_ szFile : String) -> String {
        return (ImageDocsDir as NSString).appendingPathComponent(szFile)
    }
    
    @objc public func FullFilePathName() -> String {
        return CommentedImage.FullFilePathName(szCacheFileName)
    }
    
    @objc public func LocalFileURL() -> URL {
        return URL(string: String(format: "file://%@", FullFilePathName()))!
    }
    
    func CleanUpFile() {
        if !szCacheFileName.isEmpty {
            do {
                try FileManager.default.removeItem(atPath: FullFilePathName())
            }
            catch {
                NSLog("Error cleaning up file \(FullFilePathName()): \(error.localizedDescription)")
            }
        }
    }
    
    
    // Clean up any files that are not used in the specified list of images, just
    // in case they didn't get cleaned up before (which they should at dealloc time)
    static func cleanupObsoleteFiles(_ rgImages: [CommentedImage]) {
        let filemanager = FileManager.default
        do {
            let rgFiles = try filemanager.contentsOfDirectory(atPath: ImageDocsDir)
            for szFile in rgFiles {
                if szFile.hasSuffix(CommentedImage.szTmpExtension) {
                    var fOKDelete = true
                    for ci in rgImages {
                        if (ci.szCacheFileName == szFile) {
                            fOKDelete = false
                        }
                    }
                    if (fOKDelete) {
                        try filemanager.removeItem(atPath: CommentedImage.FullFilePathName(szFile))
                    }
                }
            }
        }
        catch {
            NSLog("Error cleaning contents of directory \(ImageDocsDir): \(error.localizedDescription)")
        }
    }
    
    deinit {
        CleanUpFile()
    }
    
    // MARK: Misc
    @objc public var isVideo : Bool {
        get {
            return imgInfo?.imageType == MFBWebServiceSvc_ImageFileType_S3VideoMP4
        }
    }
    
    @objc public func flushCachedImage() {
        imgCached = nil
    }
    
    func loadImageFromMFBInfo() -> UIImage? {
        if !MFBNetworkManager.shared.isOnLine {
            return nil
        }
        
        if let url = imgInfo?.urlForImage {
            do {
                let d = try Data(contentsOf: url)
                return UIImage(data: d)
            }
            catch {
                NSLog("Error loading image: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    // Retrieves the image from disk
    func getImage() -> UIImage? {
        if imgCached != nil {
            return imgCached
        } else if imgPendingToSave != nil {
            imgCached = imgPendingToSave
            return imgCached
        } else if (imgInfo?.livesOnServer ?? false) {
            return loadImageFromMFBInfo()
        } else if isVideo {
            let asset1 = AVURLAsset(url: LocalFileURL())
            let generate1 = AVAssetImageGenerator(asset: asset1)
            generate1.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 2)
            do {
                let oneRef = try generate1.copyCGImage(at: time, actualTime: nil)
                imgCached = UIImage(cgImage: oneRef)
                return imgCached
            }
            catch {
                NSLog("Error getting thumbnail of video: \(error.localizedDescription)")
                return nil
            }
            
        } else if szCacheFileName.isEmpty {
            return nil
        } else {
            imgCached = UIImage(contentsOfFile: FullFilePathName())
            return imgCached
        }
    }
    
    @objc public var hasThumbnailCache : Bool {
        get {
            return imgInfo?.cachedThumb != nil
        }
    }
    
    // gets lightweight thumbnail, which is always cached.  But this also always flushes the big image out of the cache
    @objc @discardableResult public func GetThumbnail() -> UIImage? {
        if hasThumbnailCache {
            return imgInfo?.cachedThumb
        } else {
            let img = CommentedImage.imageWithImage(getImage(), scaledToSize: CGSizeMake(CommentedImage.THUMB_WIDTH, CommentedImage.THUMB_HEIGHT))
            imgInfo?.cachedThumb = img
            flushCachedImage()
            return img
        }
    }
    
    func saveImageDataToLibrary(_ taggedJPG : Data) {
        let fileName = String(format: "%@_%@", ProcessInfo.processInfo.globallyUniqueString, "img.jpg")
        let fileURL = NSURL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent(fileName)) as URL
        
        do {
            try taggedJPG.write(to: fileURL, options: .atomic)
            
            PHPhotoLibrary.shared().performChanges({
                // UIImage * image = [UIImage imageWithData:taggedJPG];
                // [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)
            }, completionHandler: { success, error in
                NSLog("Saved image: %@, error: %@", success ? "success" : "failed", error == nil ? "(no error)" : error!.localizedDescription)
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    NSLog("Error cleaning up temp file: \(error.localizedDescription)")
                }
            })
        } catch {
            NSLog("Error in saveImageDataToLibrary writing to file URL - \(error.localizedDescription)")
        }
    }
    
    func saveVideoDataToLibrary(_ url : URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { success, error in
            NSLog("Saved video: %@, error: %@", success ? "success" : "failed", error == nil ? "(no error)" : error!.localizedDescription);
        })
    }
    
    func saveImageFromCameraWorker(_ dictMetaData : [String : Any]) {
        autoreleasepool {
            let app = MFBAppDelegate.threadSafeAppDelegate
            
            // save a local copy for ourselves, with GPS data
            var dictAdditionalData : [String : Any] = [:]
            
            if let dictExif = dictMetaData[UIImagePickerController.InfoKey.mediaMetadata.rawValue] as? [String : Any] {
                let oExif = dictExif["{Exif}"] as? [String : Any]
                let oOrientation = dictExif["Orientation"] as? NSNumber
                
                if oExif != nil {
                    dictAdditionalData.merge(oExif!) { a, b in a }
                }
                if oOrientation != nil {
                    dictAdditionalData["Orientation"] = oOrientation;
                }
            }
            
            if let taggedJPG = GeoTag(coordinate: app.mfbloc.lastSeenLoc, additionalData: dictAdditionalData) {
                imgPendingToSave = nil
                
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                switch (status) {
                case .notDetermined:
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                        self.saveImageDataToLibrary(taggedJPG)
                    }
                case .denied, .restricted, .limited:
                    break
                case .authorized:
                    saveImageDataToLibrary(taggedJPG)
                default:
                    break
                }
            }
        }
    }
    
    // Save the video from the camera to the user's assets.  This will also provide the persisted video storage.
    func saveVideoFromCameraWorker() {
        autoreleasepool {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    if self.imgInfo?.urlFullImage != nil {
                        self.saveVideoDataToLibrary(URL(string: self.imgInfo!.urlFullImage)!)
                    }
                }
            case .denied, .restricted, .limited:
                break
            case .authorized:
                if self.imgInfo?.urlFullImage != nil {
                    saveVideoDataToLibrary(URL(string: imgInfo!.urlFullImage)!)
                }
            @unknown default:
                break
            }
        }
    }
    
    func saveImageWorker(_ dictMetaData : [String : Any]) {
        autoreleasepool {
            // No metadata, no GPS provided (even in the dictionary above), so just write it out where we won't lose it.
            if imgInfo?.location == nil {
                if let d = getImage()?.jpegData(compressionQuality: 1.0) as? NSData {
                    d.write(toFile: FullFilePathName(), atomically: true)
                }
            }
            else {
                let _ = GeoTag(coordinate: CLLocation(latitude: imgInfo!.location.latitude.doubleValue, longitude: imgInfo!.location.longitude.doubleValue), additionalData: dictMetaData)
            }
            
            self.imgPendingToSave = nil;
        }
    }
    
    // sets the image, saving it to disk in the background
    @objc public func SetImage(_ img : UIImage, fromCamera fFromCamera : Bool, withMetaData dict : [String : Any]) {
        // cache the image
        imgCached = img
        imgPendingToSave = nil
        
        // generate a cache filename and save the image
        if szCacheFileName.isEmpty && !(imgInfo?.livesOnServer ?? false) {
            NSLog("New image, not on server - need to save it")
            
            var bytes = [UInt8](repeating: 0, count: 32)
            let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
            
            guard result == errSecSuccess else {
                NSLog("Error copying random bytes")
                return
            }
            
            let s = img.size
            szCacheFileName = String(format: "%d%d-%d%d%d%d%@", s.height, s.width, bytes[0], bytes[1], bytes[2], bytes[3], CommentedImage.szTmpExtension)
            
            // if it's from the camera, geotag it and save it to the album
            // else, just save it so that we have it.
            imgPendingToSave = imgCached
            DispatchQueue.global(qos: .background).async {
                if (fFromCamera) {
                    self.saveImageFromCameraWorker(dict)
                } else {
                    self.saveImageWorker(dict)
                }
            }
        }
    }
    
    @objc public func SetVideo(_ szVideoURL : URL, fromCamera fFromCamera : Bool) {
        imgPendingToSave = nil
        imgInfo?.imageType = MFBWebServiceSvc_ImageFileType_S3VideoMP4
        imgInfo?.urlFullImage = szVideoURL.absoluteString
        
        // Save a local copy regardless of whether or not it was from the camera
        szCacheFileName = "\(UUID().uuidString)\(CommentedImage.szTmpVidExtension)"
        let videoData = NSData(contentsOf: szVideoURL)
        videoData?.write(toFile: FullFilePathName(), atomically: false)
        
        if (fFromCamera){
            DispatchQueue.global(qos: .background).async {
                self.saveVideoFromCameraWorker()
            }
        }
    }
    
    // MARK: Web Service functionality
    @objc public func updateAnnotation(_ szAuthToken : String) {
        NSLog("updateAnnotation")
        errorString = ""
        
        // return success if this has never actually been saved.
        if !(imgInfo?.livesOnServer ?? false) {
            return;
        }
        
        let iaSvc = MFBWebServiceSvc_UpdateImageAnnotation()
        iaSvc.mfbii = imgInfo
        iaSvc.szAuthUserToken = szAuthToken
        
        let sc = MFBSoapCall()
        sc.delegate = nil
        
        sc.makeCallAsync { b, sc in
            b.updateImageAnnotationAsync(usingParameters: iaSvc, delegate: sc)
        }
    }
    
    @objc public func deleteImage(_ szAuthToken : String) {
        NSLog("deleteImage")
        errorString = ""
        
        // return success if this has never actually been saved
        if !(imgInfo?.livesOnServer ?? false) {
            return;
        }

        let diSvc = MFBWebServiceSvc_DeleteImage()
        diSvc.szAuthUserToken = szAuthToken
        diSvc.mfbii = imgInfo
        
        let sc = MFBSoapCall()
        sc.delegate = nil
        
        sc.makeCallAsync { b, sc in
            b.deleteImageAsync(usingParameters: diSvc, delegate: sc)
        }
    }
    
    // MARK: MKAnnotation protocol methods
    @objc public var title: String? {
        get {
            var szTitle = imgInfo?.comment ?? ""
            if szTitle.isEmpty {
                szTitle = String(localized: "(Untitled Image)", comment: "Default comment to show for an image with no comment")
            }
            return szTitle;
        }
    }

    @objc public var subtitle: String? {
        get {
            return ""
        }
    }

    @objc public var coordinate: CLLocationCoordinate2D {
        get {
            return imgInfo!.location.coordinate()
        }
    }
    
    func GeoTag(coordinate imageLocation : CLLocation?, additionalData dictExif : [String : Any]) -> Data? {
        if imageLocation == nil {
            return nil
        }
        
        let loc = imageLocation!
        
        guard let jpegData = getImage()?.jpegData(compressionQuality: 1.0) else {
            NSLog("Error geotagging - could not get jpeg data")
            return nil
        }
        
        let jpegScanner = EXFJpeg()
        jpegScanner.scanImageData(jpegData)
        
        let exifMetaData = jpegScanner.exifMetaData
        
        NSLog("Geotagging at location {@%.8f, @%.8F}", loc.coordinate.latitude, loc.coordinate.longitude)
        // adding GPS data to the Exif object
        
        var locArray = EXFGPSLoc.createLocArray(loc.coordinate.latitude)
        var gpsLoc = EXFGPSLoc()
        EXFGPSLoc.populateGPS(gpsLoc, locArray as? [Any])
        exifMetaData?.addTagValue(gpsLoc, forKey: NSNumber(integerLiteral: Int(EXIF_GPSLatitude)))
        
        locArray = EXFGPSLoc.createLocArray(loc.coordinate.longitude)
        gpsLoc = EXFGPSLoc()
        EXFGPSLoc.populateGPS(gpsLoc, locArray as? [Any])
        exifMetaData?.addTagValue(gpsLoc, forKey: NSNumber(integerLiteral: Int(EXIF_GPSLongitude)))
        
        let refLat = (loc.coordinate.latitude < 0.0) ? "S" : "N"
        exifMetaData?.addTagValue(refLat, forKey: NSNumber(integerLiteral: Int(EXIF_GPSLatitudeRef)))
        
        let refLon = (loc.coordinate.longitude < 0.0) ? "W" : "E"
        exifMetaData?.addTagValue(refLon, forKey: NSNumber(integerLiteral: Int(EXIF_GPSLongitudeRef)))
        
        // add any relevant properties that are present
        if let orientation = dictExif["Orientation"] as? NSNumber {
            exifMetaData?.addTagValue(orientation, forKey: NSNumber(integerLiteral: Int(EXIF_Orientation)))
        }
        
        if let szDateTime = dictExif["DateTimeOriginal"] as? String {
            exifMetaData?.addTagValue(szDateTime, forKey:NSNumber(integerLiteral: Int(EXIF_DateTimeOriginal)))
        }
        
        if let szDateTime = dictExif["DateTimeDigitized"] as? String {
            exifMetaData?.addTagValue(szDateTime, forKey:NSNumber(integerLiteral: Int(EXIF_DateTimeDigitized)))
        }
        
        let taggedJpegData = NSMutableData()
        
        jpegScanner.populateImageData(taggedJpegData)
        
        return taggedJpegData.write(toFile: FullFilePathName(), atomically: true) ? taggedJpegData as Data : nil
    }
    
    // Determines if we can submit the specified images.
    // We can submit if on WiFi OR if no videos.
    @objc public static func canSubmitImages(_ rg : [CommentedImage]?) -> Bool {
        // if we are on wifi, no restrictions
        if MFBNetworkManager.shared.lastKnownNetworkStatus == .reachableViaWifi {
            return true
        }
        
        // else, we can't submit if any videos are found.
        return !(rg ?? []).contains(where: { ci in
            ci.isVideo && !(ci.imgInfo?.livesOnServer ?? true)
        })
    }
    
    @objc public static func uploadImages(_ rgImages : [AnyObject]?,
                                          progressUpdate progress : @escaping (_ : String) -> Void,
                                          toPage pageName :String,
                                          authString szAuth : String,
                                          keyName: String,
                                          keyValue : String,
                                          completionHandler: @escaping () -> Void) {
        var cImages = 0
        var cErrors = 0;
        var szLastErr = ""
        
        let rg = rgImages ?? []
        
        if pageName.isEmpty || rg.isEmpty {
            completionHandler()
            return
        }
        
        // We will first build up an array of uploads that need to happen
        // We will then call them, OR we will call completion handler
        var rgPendingUploads : [URLRequest] = []
        
        progress(String(localized: "UploadingImagesStart", comment: "Progress message when starting upload of images"))
        
        for x in rg {
            // skip if this isn't a commented image
            guard let ci = x as? CommentedImage else {
                continue
            }
            
            // skip if this isn't a new file
            if ci.imgInfo?.livesOnServer ?? true {
                continue
            }
            
            // skip if this isn't a file on disk
            if ci.szCacheFileName.isEmpty {
                continue
            }
            
            let fVideo = ci.isVideo
            
            let szBase = "https://\(MFBHOSTNAME)"
            let szURL = "\(szBase)\(pageName)"
            let boundary = "IMAGEBOUNDARY"
            
            let url = URL(string: szURL)!
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            
            let contentType = "multipart/form-data; boundary=\(boundary)"
            req.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            //adding the body:
            var postBody = Data()
            postBody.append("--\(boundary)\r\n".data(using: .utf8)!)
            postBody.append("Content-Disposition: form-data; name=\"txtAuthToken\"\r\n\r\n".data(using: .utf8)!)
            postBody.append(szAuth.data(using: .utf8)!)
            
            postBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            postBody.append("Content-Disposition: form-data; name=\"txtComment\"\r\n\r\n".data(using: .utf8)!)
            postBody.append((ci.imgInfo!.comment ?? "").data(using: .utf8)!)
            
            postBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            postBody.append("Content-Disposition: form-data; name=\"\(keyName)\"\r\n\r\n".data(using: .utf8)!)
            postBody.append(keyValue.data(using: .utf8)!)
            
            postBody.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            let szFileNameUpload = fVideo ? "myvideo.mov" : "myimage.jpg"
            postBody.append("Content-Disposition: form-data; name=\"imgPicture\"; filename=\"\(szFileNameUpload)\"\r\n".data(using: .utf8)!)
            postBody.append("Content-Type: \(fVideo ? "video/mp4" : "image/jpeg")\r\nContent-Transfer-Encoding: binary\r\n\r\n".data(using: .utf8)!)
            
            guard let imgData = NSData(contentsOfFile: ci.FullFilePathName()) as? Data else {
                continue
            }
            
            postBody.append(imgData)
            
            // save some memory
            ci.flushCachedImage()
            
            postBody.append("\r\n\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            req.httpBody = postBody
            
            // We'll do these all in parallel, completing when we've done all of them
            // But for now, hold on to the request - we'll send it below asynchronously.
            rgPendingUploads.append(req)
        }
        
        let cTotalImages = rgPendingUploads.count
        
        if rgPendingUploads.isEmpty {
            // Make sure completion handler is called!!!
            completionHandler()
        } else {
            for req in rgPendingUploads {
                let sess = URLSession(configuration: .default)
                sess.dataTask(with: req) { data, response, error in
                    DispatchQueue.main.async {
                        objc_sync_enter(cImages)
                        cImages += 1
                        
                        progress(String(format: String(localized: "Uploading Image %d of %lu", comment: "Progress message when uploading an image; the %d is replaced by numbers (e.g. '2 of 4')"),
                                        cImages, cTotalImages))
                        
                        var szResponse : String? = nil
                        if (data != nil) {
                            szResponse = String(data: data!, encoding: .utf8)
                        }
                        
                        if (szResponse ?? "").isEmpty || !szResponse!.contains("OK") {
                            cErrors += 1
                            szLastErr = szResponse ?? error!.localizedDescription
                        }
                        
                        if (cImages == cTotalImages) {
                            // Done!
                            completionHandler()
                            if (cErrors > 0) {
                                let szText = String(format: String(localized: "%d of %d images uploaded.  Error: %@", comment: "Status after uploading images; %d and %@ get replaced by numbers and the error message, respectively; keep them"), (cImages - cErrors), cImages, szLastErr)
                                WPSAlertController.presentOkayAlertWithTitle(String(localized: "Error uploading Pictures", comment: "Error message if there were errors uploading an image"), message:szText)
                            }
                        }
                        
                        objc_sync_exit(cImages)
                    }
                }.resume()
            }
        }
    }
 
    @objc public static func initCommentedImagesFromMFBII(_ rgmfbii : [MFBWebServiceSvc_MFBImageInfo], toArray rgImages: NSMutableArray) -> Bool {
        var fResult = false
        
        objc_sync_enter(rgmfbii)
        
        // add existing images to the image array
        for mfbii in rgmfbii {
            // add it to the list IF not already in the list.
            let fAlreadyInList = (rgImages as! [CommentedImage]).contains { ciExisting in
                ciExisting.imgInfo?.thumbnailFile.compare(mfbii.thumbnailFile) == .orderedSame
            }
            
            if (!fAlreadyInList) {
                let ci = CommentedImage()
                ci.imgInfo = mfbii
                let img = ci.loadImageFromMFBInfo()
                if img?.cgImage != nil {
                    ci.SetImage(img!, fromCamera: false, withMetaData: [:])
                    rgImages.add(ci)
                    fResult = true
                }
            }
        }
        
        objc_sync_exit(rgmfbii)
        
        return fResult
    }
    
    static func imageWithImage(_ image : UIImage?, scaledToSize newSizeIn : CGSize) -> UIImage? {
        if (image == nil) {
            return nil
        }
        
        // compute the size that preserves the aspect ratio.
        let ratioX = newSizeIn.width / image!.size.width;
        let ratioY = newSizeIn.height / image!.size.height;
        var ratio = 1.0; // default ratio
        
        if (ratioX < 1.0 || ratioY < 1.0) {
            ratio = (ratioX < ratioY) ? ratioX : ratioY;
        }
        
        var newSize = newSizeIn
        newSize.width = image!.size.width * ratio;
        newSize.height = image!.size.height * ratio;
        
        // Create a graphics image context
        UIGraphicsBeginImageContext(newSize);
        
        // Tell the old image to draw in this new context, with the desired
        // new size
        image!.draw(in: CGRectMake(0,0,image!.size.width * ratio,image!.size.height * ratio))
        
        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context
        UIGraphicsEndImageContext()
        
        // Return the new image.
        return newImage
    }
    
    /*
    // code below appears unused
     
    static func addCommentedImages(_ rgImages : [CommentedImage], toImageView imgView : UIImageView) {
        // the objects here are commented images, so we need to create an array of the actual images.
        var rgImg : [UIImage] = []

        for ci in rgImages {
            /// create a resized image to store.
            if let imgNew = ci.GetThumbnail() {
                rgImg.append(imgNew)
            }
        }
        
        imgView.animationImages = rgImg;
        imgView.animationDuration = 2.0 * Double(rgImg.count) // 2 seconds/image
        imgView.startAnimating()
    }
     */
 
    // MARK: Coding support
    static public var supportsSecureCoding: Bool {
        get {
            return true
        }
    }

    private let keyMFBII = "mfbImageInfo"
    private let keyCacheFileName = "cacheName"
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode(imgInfo, forKey: keyMFBII)
        coder.encode(szCacheFileName, forKey: keyCacheFileName)
    }
    
    @objc convenience public required init?(coder: NSCoder) {
        self.init()
        imgInfo = coder.decodeObject(of: MFBWebServiceSvc_MFBImageInfo.self, forKey: keyMFBII) ?? MFBWebServiceSvc_MFBImageInfo()
        szCacheFileName = coder.decodeObject(of: NSString.self, forKey: keyCacheFileName) as? String ?? ""
        
    }
}
