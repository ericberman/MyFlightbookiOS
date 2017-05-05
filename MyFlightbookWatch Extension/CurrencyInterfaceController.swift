/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  CurrencyInterfaceController.swift
//  MFBSample
//
//  Created by Eric Berman on 10/29/15.
//
//

import WatchKit
import WatchConnectivity
import Foundation

class CurrencyInterfaceController: RefreshableTableController {
    
    var lastData : [SimpleCurrencyItem]?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

        // force a refresh of totals if (a) we have no data, (b) we have no totals, (c) we have no lastUpdate or (d) lastUpdate is more than 1 hour old
        if (lastData == nil || self.dataIsExpired()) {
            refresh();
        }
        updateTable()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func updateTable() {
        if let items = lastData {
            self.table.setNumberOfRows(items.count, withRowType: "tblCurrency")
            if (items.count == 0) {
                lblError.setHidden(false)
            }
            for (index, item) in items.enumerated() {
                let row = self.table.rowController(at: index) as! CurrencyTableRowController
                row.lblCurrencyTitle.setText(item.attribute as String)
                row.lblCurrencyStatus.setText(item.value as String)
                row.lblCurrencyDiscrepancy.setText(item.discrepancy as String)
                
                switch (item.state) {
                case MFBWebServiceSvc_CurrencyState_NotCurrent:
                    row.lblCurrencyStatus.setTextColor(UIColor.red)
                case MFBWebServiceSvc_CurrencyState_GettingClose:
                    row.lblCurrencyStatus.setTextColor(UIColor.blue)
                case MFBWebServiceSvc_CurrencyState_OK:
                    row.lblCurrencyStatus.setTextColor(UIColor(colorLiteralRed: 0, green: 0.5, blue: 0, alpha: 1.0))
                default:
                    break;
                }
            }
        }
    }

    override func refreshRequest() -> [String : String] {
        return [WATCH_MESSAGE_REQUEST_DATA : WATCH_REQUEST_CURRENCY]
    }
    
    override func bindRefreshResult(_ dictResult: NSDictionary!) {
        if let statusData = dictResult[WATCH_RESPONSE_CURRENCY] as? Data {
            if let data = NSKeyedUnarchiver.unarchiveObject(with: statusData) as? [SimpleCurrencyItem] {
                self.lastData = data
                self.lastUpdate = Date()
                self.updateTable()
            }
        }
    }
}
