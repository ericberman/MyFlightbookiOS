/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023-2025 MyFlightbook, LLC
 
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
//  HostedWebViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

import Foundation
import UIKit
@preconcurrency import WebKit

@objc public class HostedWebViewController : UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    private var szurl : String

    public func webview() -> WKWebView? {
        return self.view as? WKWebView
    }
    
    @objc public init(url: String) {
        self.szurl = url
        var sz = self.szurl
        if (MFBTheme.isDarkMode() && !sz.contains("night=")) {
            sz += sz.contains("?") ? "&night=yes" : "?night=yes"
            self.szurl = sz
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        self.szurl = ""
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        let conf = WKWebViewConfiguration()
        self.view = WKWebView(frame: self.view.frame, configuration: conf)
        self.webview()?.navigationDelegate = self
        self.webview()?.uiDelegate = self
        
        let nsurl = URL(string: szurl)
        let nsRequest = URLRequest(url: nsurl!)
        self.webview()?.load(nsRequest)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        edgesForExtendedLayout = []
        
        let imgBack = UIImage(named: "btnBack.png")
        let imgForward = UIImage(named: "btnForward.png")
        
        let bbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let bbStop = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(stopLoading))
        let bbReload = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        let bbBack = UIBarButtonItem(image: imgBack, style: .plain, target: self, action: #selector(goBack))
        let bbForward = UIBarButtonItem(image: imgForward, style: .plain, target: self, action: #selector(goForward))
        
        bbStop.style = .plain
        bbReload.style = .plain
        
//        self.toolbarItems = [bbBack, bbForward, bbSpacer, bbStop, bbReload]
        setCompatibleToolbarItems([bbBack, bbForward, bbSpacer, bbStop, bbReload], tintColor:MFBTheme.MFBBrandColor())
        setCompatibleToolbarHidden(false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setCompatibleToolbarHidden(true)
    }
    
    // MARK: - Navigation
    @objc public func stopLoading() {
        self.webview()?.stopLoading()
    }

    @objc public func reload() {
        self.webview()?.reload()
    }

    @objc public func goBack() {
        if (self.webview()?.canGoBack ?? false) {
            self.webview()?.goBack()
        }
    }

    @objc public func goForward() {
        if (self.webview()?.canGoForward ?? false) {
            self.webview()?.goForward()
        }
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (!(navigationAction.targetFrame?.isMainFrame ?? false)) {
            webview()?.load(navigationAction.request)
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if (navigationResponse.response.mimeType == "text/calendar") {
            decisionHandler(.cancel)
            UIApplication.shared.open(navigationResponse.response.url!)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style: .cancel, handler: { action in
            completionHandler()
        }))
        self.present(alert, animated: true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style: .default, handler: { action in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel"), style: .cancel, handler: { action in
            completionHandler(false)
        }))
        self.present(alert, animated: true)
    }
}
