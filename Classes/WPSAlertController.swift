//
// WPSAlertController.h
//
// Created by Kirby Turner, from https://github.com/kirbyt/WPSKit/blob/master/WPSKit/UIKit/WPSAlertController.h
// Copyright 2015 White Peak Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

//  WPSAlertController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/13/23.
//

import Foundation

/**
 `WPSAlertController` is a replacement for the deprecated `UIAlertView`. With `WPSAlertController`, you can display an alert without using a view controller.
 */
@objc public class WPSAlertController : UIAlertController {
    private var alertWindow : UIWindow? = nil
    
    @objc public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
    }
    
    @objc public func show() {
        showAnimated(true)
    }
    
    @objc public func showAnimated(_ animated : Bool) {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(self, animated: animated)
            return
        }
        
        // fallback if no active scene window
        let blankViewController = UIViewController()
        blankViewController.view.backgroundColor = .clear
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = blankViewController
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        alertWindow = window
        
        blankViewController.present(self, animated: animated)
    }
    
    @objc @discardableResult public static func presentProgressAlertWithTitle(
        _ message : String?,
        onViewController parent: UIViewController? = nil
    ) -> UIAlertController {
        let alert = (parent == nil) ?
        WPSAlertController(title: message, message: nil, preferredStyle: .alert) :
            UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        
        let customVC = UIViewController()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        customVC.view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: customVC.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: customVC.view.centerYAnchor)
        ])
        
        alert.setValue(customVC, forKey: "contentViewController")
        
        if let a = alert as? WPSAlertController {
            a.show()
        } else if let parent = parent {
            parent.present(alert, animated: true)
        } else if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(alert, animated: true)
        }
        
        return alert
    }
    
    @objc public static func presentOkayAlertWithTitle(
        _ title : String?, message : String?, button buttonTitle:String
    ) {
        let alertController = WPSAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: buttonTitle, style: .default)
        alertController.addAction(okayAction)
        alertController.show()
    }
    
    @objc public static func presentOkayAlertWithTitle(_ title : String?, message : String?) {
        presentOkayAlertWithTitle(title, message: message, button: String(localized: "Close", comment: "Close button on error message"))
    }

    @objc public static func presentAlertWithErrorMessage(_ message : String?) {
        presentOkayAlertWithTitle(String(localized:"Error", comment: "Title for generic error message"), message:message)
    }

    @objc public static func presentOkayAlertWithError(_ error : NSError?) {
        let title = String(localized: "Error", comment: "Title for generic error message")
        let message = error?.localizedDescription ?? "(Unknown)"
        presentOkayAlertWithTitle(title, message:message)
    }
}
