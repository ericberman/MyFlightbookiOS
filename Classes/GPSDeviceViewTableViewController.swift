/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2019-2023 MyFlightbook, LLC
 
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
//  GPSDeviceViewTableViewController.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/6/23.
//

import Foundation
import ExternalAccessory

@objc public class GPSDeviceViewTableViewController : UITableViewController {
    @objc public var eaaccessory : EAAccessory?
    
    private var loc : CLMutableLocation? = nil
    private var satelliteStatus : NMEASatelliteStatus? = nil
    private var dataReceived = ""
    
    private func dataFromHexString(_ sz : String) -> NSData {
        let data = NSMutableData()
        // code below adapted from https://stackoverflow.com/questions/42731023/how-do-i-convert-hexstring-to-bytearray-in-swift-3,
        // rather than converting the old objective-C code that used unsafe pointers
        let length = sz.count

        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = sz.startIndex
        for _ in 0..<length/2 {
            let nextIndex = sz.index(index, offsetBy: 2)
            if let b = UInt8(sz[index..<nextIndex], radix: 16) {
                data.append(Data([b]))
            }
            index = nextIndex
        }
        return data
    }
    
    private var isBadElf : Bool {
        get {
            return eaaccessory?.name.hasPrefix("Bad Elf") ?? false
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.loc = nil
        self.satelliteStatus = nil
        EAAccessoryManager.shared().registerForLocalNotifications()
        if isBadElf && eaaccessory != nil {
            let badElfSess = BESessionController.sharedController
            badElfSess.setupController(forAccessory: eaaccessory!, withProtocolString: eaaccessory!.protocolStrings[0])
            if badElfSess.openSession() {
                let notc = NotificationCenter.default
                notc.addObserver(self, selector: #selector(dataReceived(notification:)), name: Notification.Name("BESessionDataReceivedNotification"), object: nil)
                notc.addObserver(self, selector: #selector(deviceDisconnected(notification:)), name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
                
                // Get data at 1hz with satellite information
                let data = dataFromHexString("24be00110b0102ff310132043302630d0a")
                badElfSess.writeData(data: data)
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BESessionController.sharedController.closeSession()
        EAAccessoryManager.shared().unregisterForLocalNotifications()
        let notc = NotificationCenter.default
        notc.removeObserver(self, name: Notification.Name("BESessionDataReceivedNotification"), object: nil)
        notc.removeObserver(self, name: NSNotification.Name.EAAccessoryDidDisconnect, object: nil)
        
        loc = nil
        dataReceived = ""
        eaaccessory = nil
    }
    
    @objc(dataReceived:) public func dataReceived(notification : NSNotification) {
        let badElfSess = BESessionController.sharedController
        if let sz = badElfSess.dataAsString() as? String {
            dataReceived.append(sz)
            
            let separator = CharacterSet.newlines
            let sentences = dataReceived.components(separatedBy: separator)
            
            for sentence in sentences {
                if sentence.count <= 2 {
                    continue
                }
                
                if let result = NMEAParser.parseSentence(sentence) {
                    // We got some kind of result - trim through this point.
                    dataReceived = sentence
                    
                    if let newLoc = result as? CLMutableLocation {
                        let locPrev = loc
                        loc = newLoc
                        if (locPrev?.hasAlt ?? false) && !loc!.hasAlt {
                            loc?.addAlt(locPrev!.altitude)
                        }
                    } else if let stat = result as? NMEASatelliteStatus {
                        satelliteStatus = stat
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    @objc(deviceDisconnected:) public func deviceDisconnected(notification : NSNotification) {
        eaaccessory = nil
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    @objc public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @objc override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (isBadElf && loc != nil ? 2 : 0)
    }
    
    private static let cellIdentifier = "CellStatic"

    @objc override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: GPSDeviceViewTableViewController.cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: GPSDeviceViewTableViewController.cellIdentifier))!
        
        switch (indexPath.row) {
        case 0:
            cell.textLabel!.text = eaaccessory!.modelNumber.count > 0 ? "\(eaaccessory!.name) (\(eaaccessory!.modelNumber))" : eaaccessory!.name
            cell.detailTextLabel!.text = String(format: String(localized: "DeviceSerial", comment: "Device Serial and firmware"), eaaccessory!.serialNumber, eaaccessory!.firmwareRevision)
            if self.isBadElf {
                cell.imageView!.image = UIImage(named: "BadElfCircle-Vertical-Transparent")
            }
        case 1:
            let l = loc!
            cell.textLabel!.text = "\(l.latitude.asLatString()), \(l.longitude.asLonString())"
            cell.detailTextLabel!.text = String(format: String(localized: "DevicePosition", comment: "Position status"),
                                                l.hasAlt ? UserPreferences.current.altitudeUnits.formatMetersAlt(l.altitude) : String(localized: "MissingData", comment: "Device Data Missing"),
                                                l.hasSpeed ? UserPreferences.current.speedUnits.formatSpeedMpS(l.speed) : String(localized: "MissingData", comment: "Device Data Missing"),
                                                l.hasTime ? (l.timeStamp! as NSDate).iso8601DateString() : "")
            cell.imageView!.image = nil
        case 2:
            let stat = satelliteStatus!
            cell.textLabel!.text = String(format: String(localized: "Satellites", comment: "Device Satellites"), stat.satellites.count)
            cell.detailTextLabel!.text = String(format: "PDOP: %.1f, HDOP: %.1f, VDOP: %.1f, %@",
                                                stat.PDOP,
                                                stat.HDOP,
                                                stat.VDOP,
                                                stat.Mode)
            
            cell.imageView!.image = nil
        default:
            break;
        }
        
        cell.textLabel!.adjustsFontSizeToFitWidth = true
        cell.detailTextLabel!.adjustsFontSizeToFitWidth = true
        
        return cell
    }

}
