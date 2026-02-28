/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2009-2026 MyFlightbook, LLC
 
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
//  MFBTabBar.swift
//  MFBSample
//
//  Created by Eric Berman on 9/21/25.
//

public class MFBTabBarController: UITabBarController {
    
    @IBOutlet var leMain : UITableViewController!
    @IBOutlet var tabNewFlight : UINavigationController!
    @IBOutlet var tabRecents : UINavigationController!
    @IBOutlet var tabProfile : UINavigationController!
    @IBOutlet var tabTotals : UINavigationController!
    @IBOutlet var tabCurrency : UINavigationController!
    @IBOutlet var tbiRecent : UITabBarItem!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for keyboard changes globally
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        // 1. Extract keyboard frame and handle coordinate conversion
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let window = view.window else { return }
        
        // Convert the keyboard's screen-relative frame to the Tab Bar's view space
        let keyboardFrameInView = view.convert(keyboardFrame, from: window)
        
        // Calculate how much the keyboard overlaps the bottom of the current view
        // This handles hardware keyboards, split keyboards, and 'Liquid Glass' overlays
        let intersectHeight = view.bounds.height - keyboardFrameInView.origin.y
        let bottomPadding = max(0, intersectHeight)
        
        // 2. Target the active Navigation Stack
        if let nav = selectedViewController as? UINavigationController {
            
            // 3. Drill down to find the visible Table View
            // Works for UITableViewController subclasses...
            if let tableVC = nav.topViewController as? UITableViewController {
                applyPadding(bottomPadding, to: tableVC.tableView)
            }
            // ...and for regular ViewControllers that happen to have a TableView in the XIB
            else if let customVC = nav.topViewController,
                    let tableView = customVC.view.subviews.first(where: { $0 is UITableView }) as? UITableView {
                applyPadding(bottomPadding, to: tableView)
            }
        }
    }
    
    private func applyPadding(_ padding: CGFloat, to tableView: UITableView?) {
        guard let tableView = tableView else { return }
        
        // Animate to match the keyboard's slide-up speed
        UIView.animate(withDuration: 0.3) {
            tableView.contentInset.bottom = padding
            
            // Fix for the iOS 13+ deprecation warning:
            tableView.verticalScrollIndicatorInsets.bottom = padding
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
