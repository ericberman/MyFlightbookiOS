/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2010-2026 MyFlightbook, LLC
 
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
    
    func saveImageFromCameraWorker(_ dictMetaData : [UIImagePickerController.InfoKey : Any]) {
        autoreleasepool {
            let app = MFBAppDelegate.threadSafeAppDelegate
            
            // save a local copy for ourselves, with GPS data
            var dictAdditionalData : [NSString : Any] = [:]
            
            if let dictExif = dictMetaData[UIImagePickerController.InfoKey.mediaMetadata] as? [NSString : Any] {
                let oExif = dictExif["{Exif}"] as? [NSString : Any]
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
                        DispatchQueue.main.async {
                            self.saveImageDataToLibrary(taggedJPG)
                        }
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
                        DispatchQueue.main.async {
                            self.saveVideoDataToLibrary(URL(string: self.imgInfo!.urlFullImage)!)
                        }
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
    
    func saveImageWorker(_ dictMetaData : [UIImagePickerController.InfoKey : Any]) {
        autoreleasepool {
            // No metadata, no GPS provided (even in the dictionary above), so just write it out where we won't lose it.
            if imgInfo?.location == nil {
                if let d = getImage()?.jpegData(compressionQuality: 1.0) as? NSData {
                    d.write(toFile: FullFilePathName(), atomically: true)
                }
            }
            else {
                let _ = GeoTag(coordinate: CLLocation(latitude: imgInfo!.location.latitude.doubleValue, longitude: imgInfo!.location.longitude.doubleValue), additionalData: (dictMetaData[UIImagePickerController.InfoKey.mediaMetadata] as? [NSString : Any]) ?? [:])
            }
            
            self.imgPendingToSave = nil;
        }
    }
    
    // sets the image, saving it to disk in the background
    @objc public func SetImage(_ img : UIImage, fromCamera fFromCamera : Bool, withMetaData dict : [UIImagePickerController.InfoKey : Any]) {
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
            szCacheFileName = String(format: "%d%d-%hhu%hhu%hhu%hhu%@", Int(s.height), Int(s.width), bytes[0], bytes[1], bytes[2], bytes[3], CommentedImage.szTmpExtension)
            
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
    
    func GeoTag(coordinate imageLocation : CLLocation?, additionalData dictExif : [NSString : Any]) -> Data? {
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
    
    @objc public static func uploadImages(_ rgImages: [AnyObject]?,
                                          progressUpdate progress: @escaping (String) -> Void,
                                          toPage pageName: String,
                                          authString szAuth: String,
                                          keyName: String,
                                          keyValue: String,
                                          completionHandler: @escaping () -> Void) {
        
        let images = (rgImages as? [CommentedImage])?.filter {
            !($0.imgInfo?.livesOnServer ?? true) && !$0.szCacheFileName.isEmpty
        } ?? []
        
        guard !pageName.isEmpty, !images.isEmpty else {
            completionHandler()
            return
        }
        
        progress(String(localized: "UploadingImagesStart"))
        
        let uploadManager = ImageUploadManager(
            images: images,
            pageName: pageName,
            authString: szAuth,
            keyName: keyName,
            keyValue: keyValue,
            progress: progress,
            completion: completionHandler
        )
        
        uploadManager.start()
    }
     
    @objc public static func initCommentedImagesFromMFBII(_ rgmfbii : [MFBWebServiceSvc_MFBImageInfo], toArray rgImages: NSMutableArray) -> Bool {
        var fResult = false
        
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

// MARK: - Upload Manager

// MARK: - Upload Manager

private class ImageUploadManager: NSObject, @unchecked Sendable {
    private let images: [CommentedImage]
    private let pageName: String
    private let authString: String
    private let keyName: String
    private let keyValue: String
    private let progress: (String) -> Void
    private let completion: () -> Void
    
    private let operationQueue: OperationQueue
    private var completedCount = 0
    private var errorCount = 0
    private var lastError = ""
    private let lock = NSLock()
    
    init(images: [CommentedImage],
         pageName: String,
         authString: String,
         keyName: String,
         keyValue: String,
         progress: @escaping (String) -> Void,
         completion: @escaping () -> Void) {
        
        self.images = images
        self.pageName = pageName
        self.authString = authString
        self.keyName = keyName
        self.keyValue = keyValue
        self.progress = progress
        self.completion = completion
        
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 3
        self.operationQueue.qualityOfService = .userInitiated
        
        super.init()
    }
    
    func start() {
        // Retain self until all operations complete
        var retainedSelf: ImageUploadManager? = self
        
        for (index, image) in images.enumerated() {
            let operation = ImageUploadOperation(
                image: image,
                index: index,
                totalCount: images.count,
                pageName: pageName,
                authString: authString,
                keyName: keyName,
                keyValue: keyValue
            ) { success, error in
                // Use the retained self directly
                retainedSelf?.handleCompletion(success: success, error: error)
            }
            operationQueue.addOperation(operation)
        }
        
        // Add a barrier operation that releases the retain
        operationQueue.addBarrierBlock {
            DispatchQueue.main.async {
                // This ensures retainedSelf lives until all operations complete
                _ = retainedSelf
                retainedSelf = nil
            }
        }
    }
    
    private func handleCompletion(success: Bool, error: String?) {
        lock.lock()
        completedCount += 1
        if !success {
            errorCount += 1
            lastError = error ?? "Unknown error"
        }
        let current = completedCount
        let total = images.count
        let errors = errorCount
        let errorMsg = lastError
        lock.unlock()
        
        DispatchQueue.main.async {
            self.progress(String(format: String(localized: "Uploading Image %d of %d", comment: "Progress"), current, total))
            
            if current == total {
                self.completion()
                if errors > 0 {
                    let message = String(format: String(localized: "%d of %d images uploaded. Error: %@", comment: "Status"),
                                       (total - errors), total, errorMsg)
                    UIViewController.topViewControllerForScenes(UIApplication.shared.connectedScenes)?
                        .showErrorAlertWithMessage(msg: message)
                }
            }
        }
    }
}

// MARK: - Upload Operation
private class ImageUploadOperation: Operation, @unchecked Sendable {
    private let image: CommentedImage
    private let index: Int
    private let totalCount: Int
    private let pageName: String
    private let authString: String
    private let keyName: String
    private let keyValue: String
    private let completionHandler: (Bool, String?) -> Void
    
    private var task: URLSessionUploadTask?
    private var tempFileURL: URL?
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
        return URLSession(configuration: config, delegate: nil, delegateQueue: queue)
    }()
    
    init(image: CommentedImage,
         index: Int,
         totalCount: Int,
         pageName: String,
         authString: String,
         keyName: String,
         keyValue: String,
         completionHandler: @escaping (Bool, String?) -> Void) {
        
        self.image = image
        self.index = index
        self.totalCount = totalCount
        self.pageName = pageName
        self.authString = authString
        self.keyName = keyName
        self.keyValue = keyValue
        self.completionHandler = completionHandler
    }
    
    override func main() {
        guard !isCancelled else {
            completionHandler(false, "Cancelled")
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        autoreleasepool {
            performUpload(semaphore: semaphore)
        }
        
        semaphore.wait()
        
        // Clean up
        session.finishTasksAndInvalidate()
        if let tempURL = tempFileURL {
            try? FileManager.default.removeItem(at: tempURL)
        }
    }
    
    private func performUpload(semaphore: DispatchSemaphore) {
        let fileURL = URL(fileURLWithPath: image.FullFilePathName())
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            completionHandler(false, "File not found")
            semaphore.signal()
            return
        }
        
        // Build multipart body to disk
        let boundary = "IMAGEBOUNDARY"
        let filename = image.isVideo ? "myvideo.mov" : "myimage.jpg"
        let mimeType = image.isVideo ? "video/mp4" : "image/jpeg"
        
        guard let multipartFileURL = createMultipartFile(
            boundary: boundary,
            authString: authString,
            comment: image.imgInfo?.comment ?? "",
            keyName: keyName,
            keyValue: keyValue,
            fileName: filename,
            mimeType: mimeType,
            sourceFileURL: fileURL
        ) else {
            completionHandler(false, "Failed to create multipart file")
            semaphore.signal()
            return
        }
        
        self.tempFileURL = multipartFileURL
        
        // Create request
        let urlString = "https://\(MFBHOSTNAME)\(pageName)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Use our custom session (not .shared!)
        task = session.uploadTask(with: request, fromFile: multipartFileURL) { [weak self] data, response, error in
            defer { semaphore.signal() }
            
            guard let self = self, !self.isCancelled else {
                self?.completionHandler(false, "Cancelled")
                return
            }
            
            // Free up memory
            self.image.flushCachedImage()
            
            if let error = error {
                self.completionHandler(false, error.localizedDescription)
                return
            }
            
            if let data = data,
               let responseString = String(data: data, encoding: .utf8),
               responseString.contains("OK") {
                self.completionHandler(true, nil)
            } else {
                let errorMsg = String(data: data ?? Data(), encoding: .utf8) ?? "Invalid response"
                self.completionHandler(false, errorMsg)
            }
        }
        task?.resume()
    }
    
    private func createMultipartFile(
        boundary: String,
        authString: String,
        comment: String,
        keyName: String,
        keyValue: String,
        fileName: String,
        mimeType: String,
        sourceFileURL: URL
    ) -> URL? {
        
        // Create temp file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("multipart")
        
        guard let outputStream = OutputStream(url: tempFileURL, append: false) else {
            return nil
        }
        
        outputStream.open()
        defer { outputStream.close() }
        
        // Write form fields
        writeFormField(name: "txtAuthToken", value: authString, boundary: boundary, to: outputStream)
        writeFormField(name: "txtComment", value: comment, boundary: boundary, to: outputStream)
        writeFormField(name: keyName, value: keyValue, boundary: boundary, to: outputStream)
        
        // Write file header
        var fileHeader = ""
        fileHeader += "--\(boundary)\r\n"
        fileHeader += "Content-Disposition: form-data; name=\"imgPicture\"; filename=\"\(fileName)\"\r\n"
        fileHeader += "Content-Type: \(mimeType)\r\n"
        fileHeader += "Content-Transfer-Encoding: binary\r\n\r\n"
        
        guard let headerData = fileHeader.data(using: .utf8) else { return nil }
        headerData.withUnsafeBytes { bytes in
            if let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                outputStream.write(baseAddress, maxLength: bytes.count)
            }
        }
        
        // Stream the actual file data in chunks
        guard let inputStream = InputStream(url: sourceFileURL) else {
            return nil
        }
        
        inputStream.open()
        defer { inputStream.close() }
        
        let bufferSize = 65536 // 64KB chunks
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(buffer, maxLength: bufferSize)
            if bytesRead > 0 {
                var bytesWritten = 0
                while bytesWritten < bytesRead {
                    let result = outputStream.write(buffer.advanced(by: bytesWritten), maxLength: bytesRead - bytesWritten)
                    if result <= 0 {
                        return nil
                    }
                    bytesWritten += result
                }
            } else if bytesRead < 0 {
                // Error reading
                return nil
            } else {
                // End of stream
                break
            }
        }
        
        // Write closing boundary
        let footer = "\r\n--\(boundary)--\r\n"
        guard let footerData = footer.data(using: .utf8) else { return nil }
        footerData.withUnsafeBytes { bytes in
            if let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                outputStream.write(baseAddress, maxLength: bytes.count)
            }
        }
        
        return tempFileURL
    }
    
    private func writeFormField(name: String, value: String, boundary: String, to stream: OutputStream) {
        var field = ""
        field += "--\(boundary)\r\n"
        field += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
        field += value
        field += "\r\n"
        
        guard let data = field.data(using: .utf8) else { return }
        data.withUnsafeBytes { bytes in
            if let baseAddress = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) {
                stream.write(baseAddress, maxLength: bytes.count)
            }
        }
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
