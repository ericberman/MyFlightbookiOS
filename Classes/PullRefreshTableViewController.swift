//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//  Adapted to swift (c) 2023 by Eric Berman
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

//
//  Pull.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/27/23.
//

import Foundation

public class PullRefreshTableViewControllerSW : CollapsibleTableSw {
    private let REFRESH_HEADER_HEIGHT = 60.0
    
    private let textPull = String(localized: "Pull to refresh...", comment: "Displayed when pulling to refresh")
    private let textRelease = String(localized: "Release to refresh", comment: "Displayed after pulling to indicate that a release will refresh")
    private let textLoading = String(localized: "Loading...", comment: "Loading... prompt")
    
    private var refreshHeaderView : UIView!
    private var refreshLabel : UILabel!
    private var refreshArrow : UIImageView!
    private var refreshSpinner : UIActivityIndicatorView!
    private var isDragging = false
    
    public var isLoading = false
    public var callInProgress = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addPullToRefreshHeader()
    }
    
    func addPullToRefreshHeader() {
        refreshHeaderView = UIView(frame: CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT))
        refreshHeaderView.backgroundColor = .clear

        refreshLabel = UILabel(frame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT))
        refreshLabel.backgroundColor = .clear
        refreshLabel.font = UIFont.boldSystemFont(ofSize:12.0)
        refreshLabel.textAlignment = .center

        refreshArrow = UIImageView(image: UIImage(named: "arrow.png"))
        refreshArrow.frame = CGRectMake(floor((REFRESH_HEADER_HEIGHT - 18.0) / 2.0),
                                        (floor(REFRESH_HEADER_HEIGHT - 18.0) / 2.0),
                                        36, 36)

        refreshSpinner = UIActivityIndicatorView(style: .medium)
        refreshSpinner.frame = CGRectMake(floor(floor(REFRESH_HEADER_HEIGHT - 20.0) / 2.0), floor((REFRESH_HEADER_HEIGHT - 20.0) / 2.0), 20, 20)
        refreshSpinner.hidesWhenStopped = true

        refreshHeaderView.addSubview(refreshLabel)
        refreshHeaderView.addSubview(refreshArrow)
        refreshHeaderView.addSubview(refreshSpinner)
        
        tableView.addSubview(refreshHeaderView)
    }
    
    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (isLoading) {
            return
        }
        isDragging = true
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (isLoading) {
            // Update the content inset, good for section headers
            if (scrollView.contentOffset.y > 0) {
                tableView.contentInset = .zero
            } else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT) {
                tableView.contentInset = UIEdgeInsets(top: -scrollView.contentOffset.y, left: 0, bottom: 0, right: 0)
            }
        } else if (isDragging && scrollView.contentOffset.y < 0) {
            // Update the arrow direction and label
            UIView.animate(withDuration: 0.3) {
                if (scrollView.contentOffset.y < -self.REFRESH_HEADER_HEIGHT) {
                    // User is scrolling above the header
                    self.refreshLabel.text = self.textRelease
                    self.refreshArrow.layer.transform = CATransform3DMakeRotation(Double.pi, 0, 0, 1)
                } else { // User is scrolling somewhere within the header
                    self.refreshLabel.text = self.textPull;
                    self.refreshArrow.layer.transform = CATransform3DMakeRotation(Double.pi * 2, 0, 0, 1)
                }
            }
        }
    }
    
    public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isLoading {
            return
        }
        isDragging = false
        if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
            // Released above the header
            startLoading()
        }
    }
    
    func startLoading() {
        isLoading = true
        
        // show the header
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentInset = UIEdgeInsets(top: self.REFRESH_HEADER_HEIGHT, left: 0, bottom: 0, right: 0)
            self.refreshLabel.text = self.textLoading
            self.refreshArrow.isHidden = true
            self.refreshSpinner.startAnimating()
        }
        
        // Refresh action!
        refresh()
    }
    
    public func stopLoading() {
        isLoading = false
        
        // Hide the header
        UIView.animate(withDuration: 0.3) {
            self.tableView.contentInset = .zero;
            var tableContentInset = self.tableView.contentInset
            tableContentInset.top = 0.0
            self.tableView.contentInset = tableContentInset
            self.refreshArrow.layer.transform = CATransform3DMakeRotation(Double.pi * 2, 0, 0, 1)
        } completion: { _ in
            self.stopLoadingComplete(nil, finished: nil, context: nil)
        }
    }
    
    func stopLoadingComplete(_ animationID: String?, finished: NSNumber?, context: Any?) {
        // Reset the header
        refreshLabel.text = textPull
        refreshArrow.isHidden = false
        refreshSpinner.stopAnimating()
    }
    
    public func refresh() {
        // This is just a demo. Override this method with your custom reload action.
        // Don't forget to call stopLoading at the end.
        fatalError("Refresh called in pullRefreshTableViewController - must be implemented in subclass")
    }
    
    // MARK: Progress indicator utilities
    public func startCall() {
        callInProgress = true
        tableView.reloadData()
    }
    
    public func endCall() {
        callInProgress = false
        tableView.reloadData()
    }
    
    public func waitCellWithText(_ s : String) -> WaitCell {
        let cellTextIdentifier = "CellWait"
        var _cell = tableView.dequeueReusableCell(withIdentifier: cellTextIdentifier) as? WaitCell
        if (_cell == nil) {
            let topLevelObjects = Bundle.main.loadNibNamed("WaitCell", owner: self)!
            if let firstObj = topLevelObjects[0] as? WaitCell {
                _cell = firstObj
            } else {
                _cell = topLevelObjects[1] as? WaitCell
            }
        }
        
        let cell = _cell!
        cell.Prompt.text = s
        cell.ActivityIndicator.style = .medium
        cell.ActivityIndicator.startAnimating()
        return cell
    }
    
    // MARK: Error Handling
    public func showError(_ szMsg : String, withTitle szTitle : String) {
        showAlertWithTitle(title: szTitle, message: szMsg)
        if isLoading {
            stopLoading()
        }
        callInProgress = false
        tableView.reloadData()
    }
}
