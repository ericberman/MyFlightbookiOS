/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2023 MyFlightbook, LLC
 
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
//  PreferenceEditor.swift
//  MyFlightbook
//
//  Created by Eric Berman on 2/24/23.
//

import Foundation
import MapKit

@objc public class AutodetectOptions : UITableViewController {
    // MARK: connected controls
    @IBOutlet public var idswAutoDetect : UISwitch?
    @IBOutlet public var idswRecordFlight : UISwitch?
    @IBOutlet public var idswRecordHighRes : UISwitch?
    @IBOutlet public var idswUseHHMM : UISwitch?
    @IBOutlet public var idswRoundNearestTenth : UISwitch?
    @IBOutlet public var idswUseLocal : UISwitch?
    @IBOutlet public var idswUseHeliports : UISwitch?
    @IBOutlet public var idswShowImages : UISwitch?
    @IBOutlet public var idswShowFlightTimes : UISegmentedControl?
    @IBOutlet public var idswTakeoffSpeed : UISegmentedControl?
    @IBOutlet public var idswMapOptions : UISegmentedControl?

    @IBOutlet public var cellAutoOptions : UITableViewCell?
    @IBOutlet public var cellHHMM : UITableViewCell?
    @IBOutlet public var cellLocalTime : UITableViewCell?
    @IBOutlet public var cellHeliports : UITableViewCell?
    @IBOutlet public var cellWarnings : UITableViewCell?
    @IBOutlet public var cellTOSpeed : UITableViewCell?
    @IBOutlet public var cellMapOptions : UITableViewCell?
    @IBOutlet public var cellImages : UITableViewCell?
    @IBOutlet public var txtWarnings : UILabel?
    @IBOutlet public var colorRoute : UIColorWell?
    @IBOutlet public var colorPath : UIColorWell?
    @IBOutlet public var lblPathPrompt : UILabel?
    @IBOutlet public var lblRoutePrompt : UILabel?
    
    // MARK: Initialization
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: Table management
    private enum prefSections : Int {
        case sectAutoFill
        case sectTimes
        case sectGPSWarnings
        case sectAutoOptions
        case sectCockpit
        case sectAirports
        case sectMaps
        case sectUnits
        case sectImages
        case sectOnlineSettings
        case sectLast
    }
    
    private enum prefRows : Int {
        case rowWarnings
        case rowAutoDetect
        case rowTOSpeed
        case rowNightFlightOptions
        case rowAutoHobbs
        case rowAutoTotal
        case rowLocal
        case rowHHMM
        case rowHeliports
        case rowTach
        case rowHobbs
        case rowEngine
        case rowBlock
        case rowFlight
        case rowMaps
        case rowUnitsSpeed
        case rowUnitsAlt
        case rowShowFlightImages
        case rowOnlineSettings
        case rowManageAccount
        case rowDeleteAccount
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.cellWarnings?.makeTransparent()
        self.txtWarnings?.text = String(localized: "AutodetectWarning", comment: "Autodetect Warning")
        let routeColorPrompt = String(localized: "routeColorPrompt", comment: "Prompt to pick a color for the route of flight")
        self.lblRoutePrompt?.text = routeColorPrompt
        self.colorRoute?.title = routeColorPrompt
        let pathColorPrompt = String(localized: "pathColorPrompt", comment: "Prompt to pick a color for the path of flight")
        self.lblPathPrompt?.text = pathColorPrompt
        self.colorPath?.title = pathColorPrompt
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
        let up = UserPreferences.current
        idswAutoDetect?.isOn = up.autodetectTakeoffs
        idswRecordFlight?.isOn = up.recordTelemetry
        idswRecordHighRes?.isOn = up.recordHighRes
        idswUseHeliports?.isOn = up.includeHeliports
        idswUseHHMM?.isOn = up.HHMMPref
        idswUseLocal?.isOn = up.UseLocalTime
        idswRoundNearestTenth?.isOn = up.roundTotalToNearestTenth
        idswShowImages?.isOn = up.showFlightImages
        idswShowFlightTimes?.selectedSegmentIndex = up.showFlightTimes.rawValue
        
        colorRoute?.selectedColor = up.routeColor;
        colorPath?.selectedColor = up.pathColor;
        
        idswTakeoffSpeed?.selectedSegmentIndex = 0;
        let toCurrent = up.TakeoffSpeed;
        for i in 0 ..< UserPreferences.toSpeeds.count {
            if (UserPreferences.toSpeeds[i] == toCurrent) {
                idswTakeoffSpeed?.selectedSegmentIndex = i;
            }
        }
        
        idswMapOptions?.selectedSegmentIndex = Int(up.mapType.rawValue);
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        UserPreferences.current.commit()
        super.viewWillDisappear(animated)
    }
        
    // MARK: Tableview Data Source
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func cellIDFromIndexPath(ip : IndexPath) -> Int {
        if let sect = prefSections(rawValue: ip.section) {
            switch (sect) {
            case .sectGPSWarnings:
                return prefRows.rowWarnings.rawValue;
            case .sectAutoOptions:
                return prefRows.rowAutoDetect.rawValue + ip.row;
            case .sectAutoFill:
                return prefRows.rowAutoHobbs.rawValue + ip.row;
            case .sectTimes:
                return prefRows.rowLocal.rawValue + ip.row;
            case .sectAirports:
                return prefRows.rowHeliports.rawValue;
            case .sectCockpit:
                return prefRows.rowTach.rawValue + ip.row;
            case .sectMaps:
                return prefRows.rowMaps.rawValue + ip.row;
            case .sectOnlineSettings:
                return prefRows.rowOnlineSettings.rawValue + ip.row;
            case .sectImages:
                return prefRows.rowShowFlightImages.rawValue;
            case .sectUnits:
                return prefRows.rowUnitsSpeed.rawValue + ip.row;
            default:
                return 0;
            }
        }
        return 0
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sect = prefSections(rawValue: section) {
            switch (sect) {
            case .sectGPSWarnings:
                return 1;
            case .sectAutoOptions:
                return 3;
            case .sectAutoFill:
                return 2;
            case .sectTimes:
                return 2;
            case .sectCockpit:
                return 5;
            case .sectAirports:
                return 1;
            case .sectMaps:
                return 1;
            case .sectOnlineSettings:
                return 3;
            case .sectUnits:
                return 2;
            case .sectImages:
                return 1;
            default:
                return 0;
            }
        }
        return 0
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return prefSections.sectLast.rawValue
    }
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sect = prefSections(rawValue: section) {
            switch (sect) {
            case .sectAutoFill:
                return String(localized: "Auto-Fill", comment: "Auto-Fill")
            case .sectTimes:
                return String(localized: "Entering Times", comment: "Entering Times")
            case .sectAirports:
                return String(localized: "Nearest Airports", comment: "Nearest Airports")
            case .sectCockpit:
                return String(localized: "InTheCockpit", comment: "In-the-cockpit")
            case .sectMaps:
                return String(localized: "MapOptions", comment: "Maps")
            case .sectOnlineSettings:
                return String(localized: "OnlineSettingsExplanation", comment: "Explanation about additional functionality on MyFlightbook")
            case .sectImages:
                return String(localized: "ImageOptions", comment: "Image Options")
            case .sectUnits:
                return String(localized: "Units", comment: "Units - Section Header")
            case .sectAutoOptions, .sectGPSWarnings:
                return ""
            default:
                return "";
            }
        }
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellID = cellIDFromIndexPath(ip: indexPath)
        if let prefrow = prefRows(rawValue: cellID) {
            switch (prefrow) {
            case .rowAutoDetect:
                return cellAutoOptions?.frame.size.height ?? UITableView.automaticDimension
            case .rowTOSpeed:
                return cellTOSpeed?.frame.size.height ?? UITableView.automaticDimension
            case .rowLocal:
                return cellLocalTime?.frame.size.height ?? UITableView.automaticDimension
            case .rowHHMM:
                return cellHHMM?.frame.size.height ?? UITableView.automaticDimension
            case .rowShowFlightImages:
                return cellImages?.frame.size.height ?? UITableView.automaticDimension
            case .rowHeliports:
                return cellHeliports?.frame.size.height ?? UITableView.automaticDimension
            case .rowWarnings:
                let size = (txtWarnings?.text ?? "").boundingRect(with: CGSize(width: txtWarnings?.frame.size.width ?? 300, height: 1000),
                                                                      options: .usesLineFragmentOrigin,
                                                                    attributes: [.font : txtWarnings?.font ?? UIFont()],
                                                                      context: nil).size

                
                txtWarnings?.frame = CGRect(x: txtWarnings?.frame.origin.x ?? 0,
                                            y: txtWarnings?.frame.origin.y ?? 0,
                                            width: tableView.frame.size.width - 20,
                                            height: ceil(size.height))
                txtWarnings?.text = self.txtWarnings?.text  // force a relayout

                return ceil(size.height + 20);  // account for margins on all sides + rounding.
            case .rowMaps:
                return cellMapOptions?.frame.size.height ?? UITableView.automaticDimension;
            default:
                return UITableView.automaticDimension;
            }
        }
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let row = prefRows(rawValue: cellIDFromIndexPath(ip: indexPath)) {
            if (row == .rowWarnings) {
                txtWarnings?.backgroundColor = UIColor.clear
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        if let row = prefRows(rawValue: cellIDFromIndexPath(ip: indexPath)) {
            switch (row) {
            case .rowAutoDetect:
                return cellAutoOptions!
            case .rowTOSpeed:
                return cellTOSpeed!
            case .rowAutoTotal, .rowAutoHobbs:
                let cellID = "CellNormal2"
                cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .value1, reuseIdentifier: cellID)
                cell?.textLabel?.text = (row == .rowAutoHobbs) ? String(localized: "Ending Hobbs", comment: "Option for auto-fill of ending Hobbs") : String(localized: "Total Time", comment: "Option for auto-fill total time")
                cell?.detailTextLabel?.text = (row == .rowAutoHobbs) ? UserPreferences.current.autoHobbsMode.localizedName() : UserPreferences.current.autoTotalMode.localizedName()
                cell?.accessoryType = .disclosureIndicator
                return cell!
            case .rowLocal:
                return cellLocalTime!
            case .rowHHMM:
                return cellHHMM!
            case .rowHeliports:
                return cellHeliports!
            case .rowWarnings:
                return cellWarnings!
            case .rowMaps:
                return cellMapOptions!
            case .rowShowFlightImages:
                return cellImages!
            case .rowOnlineSettings, .rowManageAccount, .rowDeleteAccount, .rowNightFlightOptions:
                let cellID = "CellNormal"
                cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .value1, reuseIdentifier: cellID)
                cell?.textLabel?.text = (row == .rowOnlineSettings) ? String(localized: "AdditionalOptions", comment: "Link to additional preferences") :
                (row == .rowManageAccount) ? String(localized: "ManageAccount", comment: "Link to manage your account") :
                (row == .rowDeleteAccount) ? String(localized: "DeleteAccount", comment: "Link to delete your account because Apple fucking sucks and requires it ") :
                      String(localized: "NightOptions", comment: "Night Section")
                cell?.accessoryType = .disclosureIndicator
                return cell!
            case .rowUnitsSpeed, .rowUnitsAlt:
                let cellID = "CellNormal3"
                cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .value1, reuseIdentifier: cellID)
                cell?.textLabel?.text = (row == .rowUnitsSpeed) ? String(localized: "UnitsSpeed", comment: "Units - Speed Header") : NSLocalizedString("UnitsAlt", comment: "Units - Altitude Header")
                cell?.detailTextLabel?.text = (row == .rowUnitsSpeed) ? UserPreferences.current.speedUnits.localizedName() : UserPreferences.current.altitudeUnits.localizedName()
                cell?.accessoryType = .disclosureIndicator;
                return cell!;
            case .rowTach:
                 return cockpitToggleCell(isChecked: UserPreferences.current.showTach, label: String(localized: "InTheCockpitTach", comment: "Cockpit: Tach"))
            case .rowHobbs:
                 return cockpitToggleCell(isChecked: UserPreferences.current.showHobbs, label: String(localized: "InTheCockpitHobbs", comment: "Cockpit: Hobbs"))
            case .rowBlock:
                 return cockpitToggleCell(isChecked: UserPreferences.current.showBlock, label: String(localized: "InTheCockpitBlock", comment: "Cockpit: Block"))
            case .rowEngine:
                 return cockpitToggleCell(isChecked: UserPreferences.current.showEngine, label: String(localized: "InTheCockpitEngine", comment: "Cockpit: Engine"))
            case .rowFlight:
                 return cockpitToggleCell(isChecked: UserPreferences.current.showFlight, label: String(localized: "InTheCockpitFlight", comment: "Cockpit: Flight"))
            }
        }
        return cell!  // should never happen
    }
    
    func cockpitToggleCell(isChecked: Bool, label: String) -> UITableViewCell {
        let cellID = "CellCockpit"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) ?? UITableViewCell(style: .value1, reuseIdentifier: cellID)
        cell.accessoryType = isChecked ? .checkmark : .none
        cell.textLabel?.text = label
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = prefRows(rawValue: cellIDFromIndexPath(ip: indexPath)) {
            switch (row) {
            case .rowNightFlightOptions:
                let mvos = MultiValOptionSelector()
                mvos.title = String(localized: "NightOptions", comment: "Night Section")
                var flightOptionNames : [String] = []
                for fo in nightFlightOptions.allCases {
                    if (fo != .invalidLast) {
                        flightOptionNames.append(fo.localizedName())
                    }
                }
                var landingOptionNames : [String] = []
                for lo in nightLandingOptions.allCases {
                    if (lo != .invalidLast) {
                        landingOptionNames.append(lo.localizedName())
                    }
                }
                
                mvos.optionGroups = [OptionSelection(szTitle: String(localized: "NightFlightStarts", comment: "Night flight options"), key: UserPreferences.current.keyNightFlightPref, options: flightOptionNames),
                                     OptionSelection(szTitle: String(localized: "NightLandingsStart", comment: "Night Landing options"), key: UserPreferences.current.keyNightLandingPref, options: landingOptionNames)]
                navigationController?.pushViewController(mvos, animated: true)
            case .rowAutoHobbs:
                let mvos = MultiValOptionSelector()
                mvos.title = String(localized: "Ending Hobbs", comment: "Option for auto-fill of ending Hobbs")
                var optionNames : [String] = []
                for opt in autoHobbs.allCases {
                    if (opt != .invalidLast) {
                        optionNames.append(opt.localizedName())
                    }
                }
                mvos.optionGroups = [OptionSelection(szTitle: "", key: UserPreferences.current.szPrefAutoHobbs, options: optionNames)]
                navigationController?.pushViewController(mvos, animated: true)
            case .rowAutoTotal:
                let mvos = MultiValOptionSelector()
                mvos.title = String(localized: "Total Time", comment: "Option for auto-fill total time")
                var optionNames : [String] = []
                for opt in autoTotal.allCases {
                    if (opt != .invalidLast) {
                        optionNames.append(opt.localizedName())
                    }
                }
                mvos.optionGroups = [OptionSelection(szTitle: "", key: UserPreferences.current.szPrefAutoTotal, options: optionNames)]
                navigationController?.pushViewController(mvos, animated: true)
            case .rowUnitsSpeed:
                let mvos = MultiValOptionSelector()
                mvos.title = String(localized: "UnitsSpeed", comment: "Units - Speed Header")
                var optionNames : [String] = []
                for opt in unitsSpeed.allCases {
                    if (opt != .invalidLast) {
                        optionNames.append(opt.localizedName())
                    }
                }
                mvos.optionGroups = [OptionSelection(szTitle: "", key: UserPreferences.current.keySpeedUnitPref, options: optionNames)]
                navigationController?.pushViewController(mvos, animated: true)
            case .rowUnitsAlt:
                let mvos = MultiValOptionSelector()
                mvos.title = String(localized: "UnitsAlt", comment: "Units - Altitude Header")
                var optionNames : [String] = []
                for opt in unitsAlt.allCases {
                    if (opt != .invalidLast) {
                        optionNames.append(opt.localizedName())
                    }
                }
                mvos.optionGroups = [OptionSelection(szTitle: "", key: UserPreferences.current.keyAltUnitPref, options: optionNames)]
                navigationController?.pushViewController(mvos, animated: true)
            case .rowOnlineSettings:
                UIApplication.shared.open(URL(string: MFBProfile.sharedProfile.authRedirForUser(params: "d=profile"))!, options:[:], completionHandler:nil)
            case .rowManageAccount:
                UIApplication.shared.open(URL(string: MFBProfile.sharedProfile.authRedirForUser(params: "d=account"))!, options:[:], completionHandler:nil)
            case .rowDeleteAccount:
                let vwWeb = HostedWebViewController(url: MFBProfile.sharedProfile.authRedirForUser(params: "d=bigredbuttons"))
                                                 
         // ...and then sign out in anticipation of deletion.
                let prof = MFBProfile.sharedProfile
                prof.UserName = ""
                prof.Password = ""
                prof.AuthToken = ""
                prof.clearCache()
                prof.clearOldUserContent()
                prof.SavePrefs()
                navigationController?.pushViewController(vwWeb, animated: true)
            case .rowTach:
                UserPreferences.current.showTach = !UserPreferences.current.showTach;
                tableView.reloadData()
            case .rowHobbs:
                UserPreferences.current.showHobbs = !UserPreferences.current.showHobbs;
                tableView.reloadData()
            case .rowBlock:
                UserPreferences.current.showBlock = !UserPreferences.current.showBlock;
                tableView.reloadData()
            case .rowEngine:
                UserPreferences.current.showEngine = !UserPreferences.current.showEngine;
                tableView.reloadData()
            case .rowFlight:
                UserPreferences.current.showFlight = !UserPreferences.current.showFlight;
                tableView.reloadData()
            default:
                break;
            }
        }
    }

    @IBAction public func autoDetectClicked(_ sender : UISwitch) {
        UserPreferences.current.autodetectTakeoffs = sender.isOn
    }
    
    @IBAction public func recordFlightClicked(_ sender : UISwitch) {
        UserPreferences.current.recordTelemetry = sender.isOn
        SwiftHackBridge.setRecord(sender.isOn)
    }
    
    @IBAction public func recordHighResClicked(_ sender : UISwitch) {
        UserPreferences.current.recordHighRes = sender.isOn
        SwiftHackBridge.setRecordHighRes(sender.isOn)
    }
    
    @IBAction public func roundNearestTenthClicked(_ sender : UISwitch) {
        UserPreferences.current.roundTotalToNearestTenth = sender.isOn
    }
    
    @IBAction public func useHHMMClicked(_ sender : UISwitch) {
        UserPreferences.current.HHMMPref = sender.isOn;
        UserDefaults.init(suiteName: "group.com.myflightbook.mfbapps")?.set(sender.isOn, forKey: UserPreferences.current.szPrefKeyHHMM)
    }
    
    @IBAction public func useLocalClicked(_ sender : UISwitch) {
        UserPreferences.current.UseLocalTime = sender.isOn
    }
    
    @IBAction public func useHeliportsChanged(_ sender : UISwitch) {
        UserPreferences.current.includeHeliports = sender.isOn
    }
    
    @IBAction public func takeOffSpeedCanged(_ sender : UISegmentedControl) {
        UserPreferences.current.TakeoffSpeed = UserPreferences.toSpeeds[sender.selectedSegmentIndex]
        SwiftHackBridge.refreshTakeoffSpeed()
    }
    
    @IBAction public func mapTypeChanged(_ sender : UISegmentedControl) {
        UserPreferences.current.mapType = MKMapType(rawValue: UInt(sender.selectedSegmentIndex))!
    }
    
    @IBAction public func showImagesClicked(_ sender : UISwitch) {
        UserPreferences.current.showFlightImages = sender.isOn
    }
    
    @IBAction public func showFlightTimesClicked(_ sender : UISegmentedControl) {
        UserPreferences.current.showFlightTimes = flightTimeDetail(rawValue: sender.selectedSegmentIndex)!
    }
    
    @IBAction public func routeColorChanged(_ sender : UIColorWell) {
        UserPreferences.current.routeColor = sender.selectedColor!
    }
    
    @IBAction public func pathColorChanged(_ sender : UIColorWell) {
        UserPreferences.current.pathColor = sender.selectedColor!
    }
}
