//
//  ImageComment.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/29/23.
//

import Foundation
import MediaPlayer
import WebKit

@objc public class ImageComment : UIViewController, UITextFieldDelegate, WKUIDelegate, WKNavigationDelegate {
    @objc public var ci : CommentedImage!
    @IBOutlet weak var txtComment : UITextField!
    @IBOutlet weak var vwWebHost : UIView!
    @IBOutlet var vwWebImage : WKWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        txtComment.placeholder = String(localized: "Add a comment for this image", comment: "Add a comment for this image")

        let conf = WKWebViewConfiguration()
        conf.allowsInlineMediaPlayback = true
        conf.mediaTypesRequiringUserActionForPlayback = .all
        
        vwWebImage = WKWebView(frame: CGRectMake(0, 0, vwWebHost.frame.size.width, vwWebHost.frame.size.height), configuration: conf)
        vwWebImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vwWebHost.addSubview(vwWebImage)

        vwWebImage.navigationDelegate = self
        vwWebImage.uiDelegate = self
    }
    
    public override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .all
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        txtComment.text = ci.imgInfo?.comment ?? ""

        // use the full-size image if it's available to show, not the thumbnail.
        if ci.imgInfo?.livesOnServer ?? false && !(ci.imgInfo?.urlFullImage?.isEmpty ?? true) {
            vwWebImage.load(URLRequest(url: URL(string: "https://\(MFBHOSTNAME)\(ci.imgInfo!.urlFullImage!)")!))
        } else if ci.isVideo {
            vwWebImage.load(URLRequest(url: ci.LocalFileURL()))
        } else {
            vwWebImage.load(URLRequest(url: URL(string: "file://\(ci.FullFilePathName())")!))
        }
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        // see if the comment has changed; if so, update the annotation synchronously
        if txtComment.text != (ci.imgInfo?.comment ?? "") {
            ci.imgInfo?.comment = txtComment.text
            ci.updateAnnotation(MFBProfile.sharedProfile.AuthToken)
        }
        super.viewWillDisappear(animated)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if !(navigationAction.targetFrame?.isMainFrame ?? true) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
