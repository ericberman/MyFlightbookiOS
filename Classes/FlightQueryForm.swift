/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2024 MyFlightbook, LLC
 
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
//  FlightQueryForm.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/30/23.
//

import Foundation

@objc public protocol QueryDelegate {
    func queryUpdated(_ fq : MFBWebServiceSvc_FlightQuery)
}


@objc public class FlightQueryForm : CollapsibleTableSw, UITextFieldDelegate, MFBSoapCallDelegate, DateRangeChanged {
    
    @objc public var delegate : QueryDelegate? = nil
    
    private var fq : MFBWebServiceSvc_FlightQuery = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()

    private var fSuppressRefresh = false
    private var fShowAllAircraft = false
    private var fSkipLoadText = false
    
    private var rgUsedProps : [MFBWebServiceSvc_CustomPropertyType] = []
    private static var _rgCannedQueries : [MFBWebServiceSvc_CannedQuery]? = nil
    private static var makesInUse : [MFBWebServiceSvc_MakeModel]? = nil
    
    private var ecText : EditCell? = nil
    private var ecModelName : EditCell? = nil
    private var ecAirports : EditCell? = nil
    private var ecQueryName : EditCell? = nil
    private var conjCellFlightFeatures : ConjunctionCell? = nil
    private var conjCellProps : ConjunctionCell? = nil
    
    @objc public var query : MFBWebServiceSvc_FlightQuery {
        get {
            return fq
        }
        set(f) {
            fq = f
            // Make sure that conjunctions are specified
            if fq.propertiesConjunction == MFBWebServiceSvc_GroupConjunction_none || fq.propertiesConjunction == MFBWebServiceSvc_GroupConjunction_None {
                fq.propertiesConjunction = MFBWebServiceSvc_GroupConjunction_Any
            }
            if fq.flightCharacteristicsConjunction == MFBWebServiceSvc_GroupConjunction_none || fq.propertiesConjunction == MFBWebServiceSvc_GroupConjunction_None {
                fq.flightCharacteristicsConjunction = MFBWebServiceSvc_GroupConjunction_All
            }
            autoExpand()
        }
    }
    
    // MARK: Enums for sections, rows
    // Sections
    enum fqSections : Int, CaseIterable {
        case fqsText = 0, fqsDate, fqsAirports, fqsAircraft, fqsAircraftFeatures, fqsMakes, fqsCatClass, fqsFlightFeatures, fqsProperties, fqsNameQueriesPrompt, fqsNamedQueries
    }
    
    // Aircraft feature rows
    enum afRows : Int, CaseIterable {
        case afTailwheel = 1, afHighPerf, afGlass, afTAA, afComplex, afRetract, afCSProp, afFlaps, afMotorGlider, afMultiEngineHeli,
            afEngineAny, afEnginePiston, afEngineTurboProp, afEngineJet, afEngineTurbine, afEngineElectric,
            afInstanceAny, afInstanceReal, afInstanceTraining
    }
    
    // Flight feature rows
    enum ffRows : Int, CaseIterable {
        case ffConjunction = 1, ffAnyLandings, ffFSLanding, ffFSNightLanding, ffApproaches, ffHold, ffXC, ffSimIMC, ffActualIMC, ffAnyInstrument, ffGroundSim, ffNight,
             ffDual, ffCFI, ffSIC, ffPIC, ffTotalTime, ffIsPublic, ffTelemetry, ffImages, ffSigned
    }
    
    // MARK: - Initialization
    @objc public static func queryController(_ fq : MFBWebServiceSvc_FlightQuery, delegate d : QueryDelegate) -> FlightQueryForm {
        let fqv = FlightQueryForm(style: .grouped)
        fqv.delegate = d
        fqv.query = fq
        return fqv
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: View lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionHeaderTopPadding = 0
        tableView.sectionHeaderHeight = 48.0
        initMakes()
        refreshUsedProps()
        
        navigationItem.rightBarButtonItem  = UIBarButtonItem(title: String(localized: "Reset", comment: "Reset button on flight entry"),
                                     style: .plain, target: self, action: #selector(resetQuery))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: String(localized: "ApplySearch", comment: "Apply Search"), style: .plain, target: self, action: #selector(doSearch))
        navigationItem.title = String(localized: "FindFlights", comment: "Find Flights title")
        
        if FlightQueryForm._rgCannedQueries == nil {
            refreshCannedQueries()
        }
    }
    
    @objc public func doSearch() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        loadText()
        fq.flightCharacteristicsConjunction = conjCellFlightFeatures?.conjunction ?? fq.flightCharacteristicsConjunction
        fq.propertiesConjunction = conjCellProps?.conjunction ?? fq.propertiesConjunction
        if fSuppressRefresh {
            fSuppressRefresh = false
            return
        }
        delegate?.queryUpdated(fq)
        super.viewWillDisappear(animated)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fSkipLoadText = false
    }
    
    
    // MARK: - Data Management
    func refreshMakes() {
        if FlightQueryForm.makesInUse != nil {
            return
        }
        
        let modelsInUse = Aircraft.sharedAircraft.modelsInUse()
        FlightQueryForm.makesInUse = []
        for smm in modelsInUse {
            let mm = MFBWebServiceSvc_MakeModel()
            mm.makeModelID = smm.modelID
            mm.modelName = smm.unamibiguousDescription
            FlightQueryForm.makesInUse?.append(mm)
        }
        tableView.reloadData()
    }
    
    func initMakes() {
        if Aircraft.sharedAircraft.rgMakeModels == nil {
            let a = Aircraft()
            a.setDelegate(self) { b, ao in
                Aircraft.sharedAircraft.rgMakeModels = (ao as! Aircraft).rgMakeModels
                self.refreshMakes()
            }
            a.loadMakeModels()
        } else {
            refreshMakes()
        }
    }
    
    func refreshUsedProps() {
        let fp = FlightProps.getFlightPropsNoNet()
        rgUsedProps = fp.rgPropTypes.filter({ cpt in
            cpt.isFavorite.boolValue
        })
        
        if rgUsedProps.isEmpty {
            let allProps = (fp.rgFlightProps.customFlightProperty as? [MFBWebServiceSvc_CustomPropertyType]) ?? []
            rgUsedProps.append(contentsOf: allProps)
        }
    }
    
    // MARK: - form management
    @objc func resetQuery() {
        fq = MFBWebServiceSvc_FlightQuery.getNewFlightQuery()
        expandedSections.removeAll()
        ecText?.txt.text = ""
        ecAirports?.txt.text = ""
        conjCellProps?.conjunction = fq.flightCharacteristicsConjunction
        conjCellProps?.conjunction = fq.propertiesConjunction
        tableView.reloadData()
    }
    
    func loadText() {
        if fSkipLoadText {
            return
        }
        
        // update the text fields
        fq.generalText = ecText?.txt.text ?? ""
        fq.modelName = ecModelName?.txt.text ?? ""
        
        let szAirports = ecAirports?.txt.text ?? ""
     
        let reAirports = try! NSRegularExpression(pattern: "!?@?[a-zA-Z0-9]+!?", options: .caseInsensitive)
        fq.airportList.string.removeAllObjects()
        let matches = reAirports.matches(in: szAirports, range: NSRange(location: 0, length: szAirports.count))
        for match in matches {
            fq.airportList.string.add(szAirports[Range(match.range)!])
        }
        
        if !(ecQueryName?.txt.text ?? "").isEmpty {
            addCannedQuery(fq, name: ecQueryName!.txt.text!)
        }
    }
    
    // Determines the number of aircraft to hide.
    // This is 0 if:
    // a) The user has clicked on "show all aircraft"
    // b) All aircraft are active
    // c) The current query references an inactive aircraft
    // Otherwise, it is the number of hidden (inactive) aircraft
    func numberHiddenAircraft() -> Int {
        if (fShowAllAircraft) {
            return 0
        }
        
        let rgAllAircraft = Aircraft.sharedAircraft.rgAircraftForUser ?? []
        let rgActiveAircraft = Aircraft.sharedAircraft.AircraftForSelection(-1)
        
        // check for all aircraft are active
        if rgAllAircraft.count == rgActiveAircraft.count {
            fShowAllAircraft = true
            return 0
        }
        
        for obj in fq.aircraftList.aircraft {
            let ac = obj as! MFBWebServiceSvc_Aircraft
            let ac2 = rgActiveAircraft.first { acIn in
                acIn.aircraftID.intValue == ac.aircraftID.intValue
            }
            if ac2 == nil {
                // aircraft was not found in active aircraft
                fShowAllAircraft = true
                return 0
            }
        }
        
        return rgAllAircraft.count - rgActiveAircraft.count
    }
    
    func availableAircraft() -> [MFBWebServiceSvc_Aircraft] {
        return numberHiddenAircraft() == 0 ? Aircraft.sharedAircraft.rgAircraftForUser ?? [] : Aircraft.sharedAircraft.AircraftForSelection(-1)
    }
    
    // MARK: - Canned query management
    func refreshCannedQueries() {
        if !MFBNetworkManager.shared.isOnLine {
            return
        }
        
        let authtoken = MFBProfile.sharedProfile.AuthToken
        if authtoken.isEmpty {
            return
        }

        let gnqSVC = MFBWebServiceSvc_GetNamedQueriesForUser()
        gnqSVC.szAuthToken = authtoken

        let sc = MFBSoapCall(delegate: self)
        
        sc.makeCallAsync { b, sc in
            b.getNamedQueriesForUserAsync(usingParameters: gnqSVC, delegate: sc)
        }
    }
    
    func deleteCannedQuery(_ fq : MFBWebServiceSvc_CannedQuery) {
        if !MFBNetworkManager.shared.isOnLine {
            return
        }
        
        let authtoken = MFBProfile.sharedProfile.AuthToken
        if authtoken.isEmpty {
            return
        }

        let dnqSVC = MFBWebServiceSvc_DeleteNamedQueryForUser()
        dnqSVC.szAuthToken = authtoken
        dnqSVC.cq = fq

        let sc = MFBSoapCall(delegate: self)
        
        sc.makeCallAsync { b, sc in
            b.deleteNamedQueryForUserAsync(usingParameters: dnqSVC, delegate: sc)
        }
    }
    
    func addCannedQuery(_ fq : MFBWebServiceSvc_FlightQuery, name szName : String) {
        if !MFBNetworkManager.shared.isOnLine {
            return
        }
        
        let authtoken = MFBProfile.sharedProfile.AuthToken
        if authtoken.isEmpty {
            return
        }
        
        let anqSVC = MFBWebServiceSvc_AddNamedQueryForUser()
        anqSVC.szAuthToken = authtoken
        anqSVC.fq = fq
        anqSVC.szName = szName
        
        let sc = MFBSoapCall(delegate: self)
        
        sc.makeCallAsync { b, sc in
            b.addNamedQueryForUserAsync(usingParameters: anqSVC, delegate: sc)
        }
    }
    
    public func BodyReturned(body: AnyObject) {
        if let resp = body as? MFBWebServiceSvc_GetNamedQueriesForUserResponse {
            FlightQueryForm._rgCannedQueries = resp.getNamedQueriesForUserResult.cannedQuery as? [MFBWebServiceSvc_CannedQuery]
            
        } else if let resp = body as? MFBWebServiceSvc_DeleteNamedQueryForUserResponse {
            FlightQueryForm._rgCannedQueries = resp.deleteNamedQueryForUserResult.cannedQuery as? [MFBWebServiceSvc_CannedQuery]
            
        } else if let resp = body as? MFBWebServiceSvc_AddNamedQueryForUserResponse {
            FlightQueryForm._rgCannedQueries = resp.addNamedQueryForUserResult.cannedQuery as? [MFBWebServiceSvc_CannedQuery]
        }
    }
    
    public func ResultCompleted(sc: MFBSoapCall) {
        tableView.reloadData()
        // silently fail any error, since this is all background anyhow.  But still log it
        if !sc.errorString.isEmpty {
            NSLog("CannedQuery error: \(sc.errorString)")
        }
    }
    
    // MARK: Expand/collapse functionality
    func canExpandSection(_ section : Int) -> Bool {
        if let fqs = fqSections(rawValue: section) {
            return fqs != .fqsText && fqs != .fqsNameQueriesPrompt
        } else {
            return false
        }
    }
    
    func expandSection(_ fqs : fqSections) {
        expandSection(fqs.rawValue)
    }
    
    func autoExpand() {
        expandedSections.removeAll()
        if fq.hasDate() {
            expandSection(.fqsDate)
        }
        if fq.hasAircraft() {
            expandSection(.fqsAircraft)
        }
        if fq.hasMakes() {
            expandSection(.fqsMakes)
        }
        if fq.hasAirport() {
            expandSection(.fqsAirports)
        }
        if fq.hasAircraftCharacteristics() {
            expandSection(.fqsAircraftFeatures)
        }
        if fq.hasCatClasses() {
            expandSection(.fqsCatClass)
        }
        if fq.hasFlightCharacteristics() {
            expandSection(.fqsFlightFeatures)
        }
        if fq.hasProperties() {
            expandSection(.fqsProperties)
        }
        if !(FlightQueryForm._rgCannedQueries ?? []).isEmpty {
            expandSection(.fqsNamedQueries)
        }
    }
    
    func rowsInSection(_ fq : fqSections, itemCount items : Int) -> Int {
        return self.canExpandSection(fq.rawValue) ? (isExpanded(fq.rawValue) ? items + 1 : 1) : items
    }
    
    // MARK: - Cell types
    func getSubtitleCell() -> UITableViewCell {
        let cellIdentifier = "cellSubtitle"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.selectionStyle = .blue
        var config = cell.defaultContentConfiguration()
        config.text = ""
        cell.contentConfiguration = config
        return cell
    }
    
    func getSmallSubtitleCell() -> UITableViewCell {
        let cellIdentifier = "CellSubtitleSmall"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        cell.selectionStyle = .blue
        var config = cell.defaultContentConfiguration()
        config.text = ""
        config.textProperties.font = UIFont.systemFont(ofSize: 12.0)
        cell.contentConfiguration = config
        return cell
    }
    
    // MARK: TableView Data Source    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return fqSections.allCases.count
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fqs = fqSections(rawValue: section) {
            switch fqs {
            case .fqsText:
                return 1
            case .fqsAirports:
                return rowsInSection(fqs, itemCount: 4)
            case .fqsDate:
                return rowsInSection(fqs, itemCount: Int(MFBWebServiceSvc_DateRanges_Custom.rawValue))
            case .fqsAircraft:
                return rowsInSection(fqs, itemCount: availableAircraft().count + (fShowAllAircraft ? 0 : 1))
            case .fqsMakes:
                return rowsInSection(fqs, itemCount: (FlightQueryForm.makesInUse?.count ?? 0) + 1)
            case .fqsAircraftFeatures:
                return rowsInSection(fqs, itemCount: afRows.allCases.count)
            case .fqsFlightFeatures:
                return rowsInSection(fqs, itemCount: ffRows.allCases.count)
            case .fqsCatClass:
                return rowsInSection(fqs, itemCount: Int(MFBWebServiceSvc_CatClassID_PoweredParaglider.rawValue))
            case .fqsProperties:
                return rowsInSection(fqs, itemCount: rgUsedProps.count + 1)
            case .fqsNameQueriesPrompt:
                return 1
            case .fqsNamedQueries:
                return rowsInSection(fqs, itemCount: 1 + (FlightQueryForm._rgCannedQueries?.count ?? 0))
            }
        } else {
            fatalError("section \(section) does not correspond to an fqSections enum")
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let fqs = fqSections(rawValue: indexPath.section) {
            switch (fqs) {
            case .fqsDate:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "FlightDate", comment: "Date criteria"), forSection: indexPath.section, initialState: isExpanded(indexPath.section))
                }
                
                let cell = getSubtitleCell()
                var config = cell.defaultContentConfiguration()
                
                let dr = MFBWebServiceSvc_DateRanges(rawValue: UInt32(indexPath.row))
                
                if (dr == MFBWebServiceSvc_DateRanges_Custom) {
                    config.text = String(localized: "Date Range", comment: "Select Dates for totals")
                    if fq.dateRange == dr {
                        cell.accessoryType = .checkmark
                        let df = DateFormatter()
                        df.dateFormat = "MMM dd, yyyy"
                        config.secondaryText = "\(df.string(from: MFBSoapCall.LocalDateFromUTCDate(dt: fq.dateMin))) - \(df.string(from: MFBSoapCall.LocalDateFromUTCDate(dt: fq.dateMax)))"
                    } else {
                        
                        config.secondaryText = ""
                        cell.accessoryType = .disclosureIndicator;
                    }
                }
                else {
                    config.text = MFBWebServiceSvc_FlightQuery.stringForDateRange(dr)
                    cell.accessoryType = (dr == fq.dateRange) ? .checkmark : .none;
                    config.secondaryText = ""
                }
                cell.contentConfiguration = config
                return cell;
            case .fqsText:
                assert(indexPath.row == 0)  // only general text here
                if ecText == nil {
                    ecText = EditCell.getEditCell(tableView, withAccessory: nil)
                    ecText!.lbl.text = String(localized: "TextContains", comment: "General Text")
                    ecText!.txt.placeholder = String(localized: "TextContainsPrompt", comment: "General Text Prompt")
                    ecText!.txt.returnKeyType = .done
                    ecText!.txt.autocapitalizationType = .sentences
                    ecText!.txt.delegate = self
                }
                ecText!.txt.text = fq.generalText
                return ecText!
            case .fqsAirports:
                if (indexPath.row == 0) {
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "AirportsVisited",  comment: "Airport Criteria"), forSection:indexPath.section, initialState:isExpanded(indexPath.section))
                }
                
                if (indexPath.row == 1) { // airports (0 is header cell)
                    
                    if (self.ecAirports == nil) {
                        ecAirports = EditCell.getEditCell(tableView, withAccessory: nil)
                        ecAirports!.lbl.text = String(localized: "AirportsVisited", comment: "Airport Criteria")
                        ecAirports!.txt.placeholder = String(localized: "AirportsVisitedPrompt", comment: "Airport Criteria Prompt")
                        ecAirports!.txt.returnKeyType = .done
                        ecAirports!.txt.autocapitalizationType = .allCharacters
                        ecAirports!.txt.autocorrectionType = .no
                        ecAirports!.txt.delegate = self
                    }
                    ecAirports!.txt.text = fq.airportList.string.componentsJoined(by: " ")
                    return ecAirports!
                }
                else {
                    let cell = getSubtitleCell()
                    let distance = MFBWebServiceSvc_FlightDistance(rawValue: UInt32(indexPath.row - 1))
                    cell.accessoryType = (distance == fq.distance) ? .checkmark : .none
                    var config = cell.defaultContentConfiguration()
                    switch (distance) {
                    case MFBWebServiceSvc_FlightDistance_none, MFBWebServiceSvc_FlightDistance_AllFlights:
                        config.text = String(localized: "FlightQueryDistanceAllFlights", comment: "All flights that visit a given airport")
                    case MFBWebServiceSvc_FlightDistance_LocalOnly:
                        config.text = String(localized: "FlightQueryDistanceLocalFlights", comment: "Local flights only at a given airport")
                    case MFBWebServiceSvc_FlightDistance_NonLocalOnly:
                        config.text = String(localized: "FlightQueryDistanceNonLocalFlights", comment: "Non-local flights that left or arrived at a given airport")
                    default:
                        break
                    }
                    cell.contentConfiguration = config
                    return cell
                }
            case .fqsCatClass:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "ccHeader", comment: "Category-class Criteria"), forSection:indexPath.section, initialState:isExpanded(indexPath.section))
                }
                
                let cell = getSubtitleCell()
                let cc = MFBWebServiceSvc_CategoryClass(ccid: MFBWebServiceSvc_CatClassID(rawValue: UInt32(indexPath.row)))
                
                var config = cell.defaultContentConfiguration()
                config.text = cc.localizedDescription()
                config.secondaryText = ""
                cell.contentConfiguration = config
                cell.accessoryType = fq.catClasses.categoryClass.contains(where: { cc2 in
                    (cc2 as! MFBWebServiceSvc_CategoryClass).idCatClass.rawValue == cc.idCatClass.rawValue
                }) ? .checkmark : .none
                return cell;
            case .fqsAircraft:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "FlightAircraft", comment: "Aircraft Criteria"), forSection:indexPath.section, initialState:isExpanded(indexPath.section))
                }
                
                let cell = getSubtitleCell()
                var config = cell.defaultContentConfiguration()
                
                let rgAircraft = self.availableAircraft()
                if !fShowAllAircraft && indexPath.row == rgAircraft.count + 1 {
                    config.text = String(localized: "ShowAllAircraft", comment: "Show all aircraft")
                    config.secondaryText = ""
                    cell.contentConfiguration = config
                    cell.accessoryType = .none
                    return cell
                }
                
                let ac = rgAircraft[indexPath.row - 1]
                config.text = ac.tailNumber
                config.secondaryText = "\(ac.modelCommonName ?? "") \(ac.modelDescription ?? "")"
                cell.contentConfiguration = config
                cell.accessoryType = fq.aircraftList.aircraft.contains(where: { ac2 in
                    (ac2 as! MFBWebServiceSvc_Aircraft).aircraftID.intValue == ac.aircraftID.intValue
                }) ? .checkmark : .none
                return cell
            case .fqsMakes:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "FlightModel", comment: "Make/Model Criteria"), forSection:indexPath.section, initialState:isExpanded(indexPath.section))
                }
                
                if (indexPath.row == (FlightQueryForm.makesInUse?.count ?? 0) + 1) { // modelname field
                    if ecModelName == nil {
                        ecModelName = EditCell.getEditCell(tableView, withAccessory: nil)
                        ecModelName!.lbl.text = String(localized: "FlightModelName", comment: "Model Free-text")
                        ecModelName!.txt.placeholder = String(localized: "FlightModelNamePrompt", comment: "Model Free-text Prompt")
                        ecModelName!.txt.returnKeyType = .done;
                        ecModelName!.txt.autocapitalizationType = .sentences;
                        ecModelName!.txt.delegate = self
                    }
                    ecModelName!.txt.text = fq.modelName
                    return ecModelName!
                } else {
                    let cell = getSmallSubtitleCell()
                    let mm = FlightQueryForm.makesInUse?[indexPath.row - 1]
                    var config = cell.defaultContentConfiguration()
                    config.text = mm?.modelName ?? ""
                    config.secondaryText = ""
                    cell.contentConfiguration = config
                    
                    cell.accessoryType = fq.makeList.makeModel.contains(where: { mm2 in
                        (mm2 as! MFBWebServiceSvc_MakeModel).makeModelID.intValue == (mm?.makeModelID.intValue ?? -1)
                    }) ? .checkmark : .none
                    return cell
                }
            case .fqsFlightFeatures:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "FlightFeatures", comment: "Flight Features"), forSection: indexPath.section, initialState: isExpanded(indexPath.section))
                }
                
                let ffRow = ffRows(rawValue: indexPath.row)
                if (ffRow == .ffConjunction) {
                    if conjCellFlightFeatures == nil {
                        conjCellFlightFeatures = ConjunctionCell.getConjunctionCell(tableView, withConjunction: fq.flightCharacteristicsConjunction)
                    }
                    return conjCellFlightFeatures!
                }
                
                let cell = getSubtitleCell()
                var config = cell.defaultContentConfiguration()
                switch (ffRow) {
                case .ffActualIMC:
                    config.text = String(localized: "ffIMC", comment: "Flight has actual IMC time");
                    cell.accessoryType = fq.hasIMC.boolValue ? .checkmark : .none
                case .ffSimIMC:
                    config.text = String(localized: "ffSimIMC", comment: "Flight has simulated IMC");
                    cell.accessoryType = fq.hasSimIMCTime.boolValue ? .checkmark : .none
                case .ffAnyInstrument:
                    config.text = String(localized: "ffAnyInstrument", comment: "Flight has ANY instrument");
                    cell.accessoryType = fq.hasAnyInstrument.boolValue ? .checkmark : .none
                case .ffApproaches:
                    config.text = String(localized: "ffApproaches", comment: "Flight has instrument approaches");
                    cell.accessoryType = fq.hasApproaches.boolValue ? .checkmark : .none
                case .ffCFI:
                    config.text = String(localized: "ffCFI", comment: "Flight has CFI time logged");
                    cell.accessoryType = fq.hasCFI.boolValue ? .checkmark : .none
                case .ffDual:
                    config.text = String(localized: "ffDual", comment: "Flight has Dual time logged");
                    cell.accessoryType = fq.hasDual.boolValue ? .checkmark : .none
                case .ffFSLanding:
                    config.text = String(localized: "ffFSLanding", comment: "Flight has full-stop landings");
                    cell.accessoryType = fq.hasFullStopLandings.boolValue ? .checkmark : .none
                case .ffFSNightLanding:
                    config.text = String(localized: "ffFSNightLanding", comment: "Flight has full-stop night-landings");
                    cell.accessoryType = fq.hasNightLandings.boolValue ? .checkmark : .none
                case .ffAnyLandings:
                    config.text = String(localized: "ffLandings", comment: "Flight has landings");
                    cell.accessoryType = fq.hasLandings.boolValue ? .checkmark : .none
                case .ffGroundSim:
                    config.text = String(localized: "ffGroundSim", comment: "Flight has Ground Sim");
                    cell.accessoryType = fq.hasGroundSim.boolValue ? .checkmark : .none
                case .ffHold:
                    config.text = String(localized: "ffHold", comment: "Flight has holding procedures");
                    cell.accessoryType = fq.hasHolds.boolValue ? .checkmark : .none
                case .ffIsPublic:
                    config.text = String(localized: "ffIsPublic", comment: "Flight is public");
                    cell.accessoryType = fq.isPublic.boolValue ? .checkmark : .none
                case .ffNight:
                    config.text = String(localized: "ffNight", comment: "Flight has night flight time");
                    cell.accessoryType = fq.hasNight.boolValue ? .checkmark : .none
                case .ffPIC:
                    config.text = String(localized: "ffPIC", comment: "Aircraft Feature = Tailwheel");
                    cell.accessoryType = fq.hasPIC.boolValue ? .checkmark : .none
                case .ffSIC:
                    config.text = String(localized: "ffSIC", comment: "Flight has SIC time logged");
                    cell.accessoryType = fq.hasSIC.boolValue ? .checkmark : .none
                case .ffTotalTime:
                    config.text = String(localized: "ffTotal", comment: "Flight has Total Time logged");
                    cell.accessoryType = fq.hasTotalTime.boolValue ? .checkmark : .none
                case .ffTelemetry:
                    config.text = String(localized: "ffTelemetry", comment: "Flight has Telemetry Data");
                    cell.accessoryType = fq.hasTelemetry.boolValue ? .checkmark : .none
                case .ffImages:
                    config.text = String(localized: "ffImages", comment: "Flight has Images or Videos");
                    cell.accessoryType = fq.hasImages.boolValue ? .checkmark : .none
                case .ffXC:
                    config.text = String(localized: "ffXC", comment: "Flight has PIC time logged");
                    cell.accessoryType = fq.hasXC.boolValue ? .checkmark : .none
                case .ffSigned:
                    config.text = String(localized: "ffSigned", comment: "Flight is signed");
                    cell.accessoryType = fq.isSigned.boolValue ? .checkmark : .none
                default:
                    fatalError("Unknown flight feature \(ffRow.debugDescription)")
                }
                cell.contentConfiguration = config
                return cell;
            case .fqsProperties:
                if (indexPath.row == 0) { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "Properties", comment: "Properties Header"), forSection:indexPath.section, initialState:isExpanded(indexPath.section))
                }
                if (indexPath.row == 1) {
                    if conjCellProps == nil {
                        conjCellProps = ConjunctionCell.getConjunctionCell(tableView, withConjunction: fq.propertiesConjunction)
                    }
                    return conjCellProps!
                }
                
                let cell = getSubtitleCell()
                var config = cell.defaultContentConfiguration()
                
                let cpt = rgUsedProps[indexPath.row - 2]
                config.text = cpt.title
                cell.contentConfiguration = config
                cell.accessoryType = fq.hasPropertyType(cpt) ? .checkmark : .none
                return cell
            case .fqsAircraftFeatures:
                if indexPath.row == 0 { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "AircraftFeatures", comment: "Aircraft Features for search"), forSection: indexPath.section, initialState: isExpanded(indexPath.section))
                }
                
                let cell = getSubtitleCell()
                var config = cell.defaultContentConfiguration()
                let af = afRows(rawValue: indexPath.row)
                
                switch (af)
                {
                case .afTailwheel:
                    config.text = String(localized: "afTailwheel", comment: "Aircraft Feature = Tailwheel")
                    cell.accessoryType = fq.isTailwheel.boolValue ? .checkmark : .none
                    break;
                case .afHighPerf:
                    config.text = String(localized: "afHighPerf", comment: "Aircraft Feature = High Performance")
                    cell.accessoryType = fq.isHighPerformance.boolValue ? .checkmark : .none
                    break;
                case .afGlass:
                    config.text = String(localized: "afGlass", comment: "Aircraft Feature = Glass Cockpit")
                    cell.accessoryType = fq.isGlass.boolValue ? .checkmark : .none
                    break;
                case .afTAA:
                    config.text = String(localized: "afTAA", comment: "Aircraft Features = TAA")
                    cell.accessoryType = fq.isTechnicallyAdvanced.boolValue ? .checkmark : .none
                    break;
                case .afComplex:
                    config.text = String(localized: "afComplex", comment: "Aircraft Feature = Complex")
                    cell.accessoryType = fq.isComplex.boolValue ? .checkmark : .none
                    break;
                case .afRetract:
                    config.text = String(localized: "afRetract", comment: "Aircraft Feature = Retractable gear")
                    cell.accessoryType = fq.isRetract.boolValue ? .checkmark : .none
                    break;
                case .afCSProp:
                    config.text = String(localized: "afCSProp", comment: "Aircraft Feature = Controllable Pitch Propellor")
                    cell.accessoryType = fq.isConstantSpeedProp.boolValue ? .checkmark : .none
                    break;
                case .afFlaps:
                    config.text = String(localized: "afFlaps", comment: "Aircraft Feature = Flaps")
                    cell.accessoryType = fq.hasFlaps.boolValue ? .checkmark : .none
                    break;
                case .afMotorGlider:
                    config.text = String(localized: "afMotorGlider", comment: "Aircraft Feature = Motorglider")
                    cell.accessoryType = fq.isMotorglider.boolValue ? .checkmark : .none
                    break;
                case .afMultiEngineHeli:
                    config.text = String(localized: "afMultiHeli", comment: "Aircraft Feature = Multi-Engine Helicopter")
                    cell.accessoryType = fq.isMultiEngineHeli.boolValue ? .checkmark : .none
                    break;
                case .afEngineAny:
                    config.text = String(localized: "afEngineAny", comment: "Aircraft Feature = Engine Type Any")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_AllEngines) ? .checkmark : .none
                    break;
                case .afEngineJet:
                    config.text = String(localized: "afEngineJet", comment: "Aircraft Feature = Engine Type Jet")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_Jet) ? .checkmark : .none
                    break;
                case .afEnginePiston:
                    config.text = String(localized: "afEnginePiston", comment: "Aircraft Feature = Engine Type Piston")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_Piston) ? .checkmark : .none
                    break;
                case .afEngineTurbine:
                    config.text = String(localized: "afEngineTurbine", comment: "Aircraft Feature = Turbine (Any) ")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine) ? .checkmark : .none
                    break;
                case .afEngineElectric:
                    config.text = String(localized: "afEngineElectric", comment: "Aircraft Feature = Engine Type Electric")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_Electric) ? .checkmark : .none
                    break;
                case .afEngineTurboProp:
                    config.text = String(localized: "afEngineTurboprop", comment: "Aircraft Feature = TurboProp")
                    cell.accessoryType = (fq.engineType == MFBWebServiceSvc_EngineTypeRestriction_Turboprop) ? .checkmark : .none
                    break;
                case .afInstanceAny:
                    config.text = String(localized: "afInstanceAny", comment: "Any Aircraft")
                    cell.accessoryType = (fq.aircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft) ? .checkmark : .none
                    break;
                case .afInstanceReal:
                    config.text = String(localized: "afInstanceReal", comment: "Real Aircraft")
                    cell.accessoryType = (fq.aircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly) ? .checkmark : .none
                    break;
                case .afInstanceTraining:
                    config.text = String(localized: "afInstanceTraining", comment: "Training Device")
                    cell.accessoryType = (fq.aircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly) ? .checkmark : .none
                    break;
                default:
                    fatalError("Unknown flight feature \(af.debugDescription)")
                    
                }
                cell.contentConfiguration = config
                return cell
            case .fqsNameQueriesPrompt:
                let tc = TextCell.getTextCellTransparent(tableView)
                tc.txt.text = String(localized: "QueryNameHeaderDesc", comment: "Query name header description").uppercased()
                tc.txt.lineBreakMode = .byWordWrapping
                tc.txt.textColor = .systemGray
                return tc
            case .fqsNamedQueries:
                if indexPath.row == 0 { // header row
                    return ExpandHeaderCell.getHeaderCell(tableView, withTitle: String(localized: "QueryNameHeader", comment: "Header for query names"), forSection: indexPath.section, initialState: isExpanded(indexPath.section))
                }
                else if (indexPath.row == 1) {
                    if ecQueryName == nil {
                        ecQueryName = EditCell.getEditCell(tableView, withAccessory: nil)
                        ecQueryName!.txt.placeholder = String(localized: "QueryNamePrompt", comment: "Prompt for query name")
                        ecQueryName!.txt.returnKeyType = .done
                        ecQueryName!.txt.autocapitalizationType = .words
                        ecQueryName!.txt.delegate = self
                    }
                    ecQueryName!.lbl.text = String(localized: "QueryNamePrompt", comment: "Prompt for query name")

                    return ecQueryName!
                }
                else {
                    let cell = getSubtitleCell()
                    var config = cell.defaultContentConfiguration()
                    config.text = FlightQueryForm._rgCannedQueries?[indexPath.row - 2].queryName ?? ""
                    cell.contentConfiguration = config
                    cell.accessoryType = .none
                    return cell
                }
            }
        }
        
        // If we are here, something went very wrong
        fatalError("Somehow we missed a scenario for a row")
    }
    
    // MARK: - Table view delegate
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // only editable cells are named queries
        return MFBNetworkManager.shared.isOnLine && fqSections(rawValue: indexPath.section) == .fqsNamedQueries && indexPath.row >= 2
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && self.tableView(tableView, canEditRowAt: indexPath) {
            if let cq = FlightQueryForm._rgCannedQueries?[indexPath.row - 2] {
                
                let alertController = UIAlertController(title: "", message: String(localized: "QueryDeleteConfirm", comment: "Confirm Delete Named Query"), preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: String(localized: "OK", comment: "OK"), style: .default, handler: { action in
                    self.deleteCannedQuery(cq)
                }))
                alertController.addAction(UIAlertAction(title: String(localized: "Cancel", comment: "Cancel (button)"), style: .cancel))
                present(alertController, animated: true)
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // check for header row; just handle it here.
        if indexPath.row == 0 && canExpandSection(indexPath.section) {
            toggleSection(indexPath.section)
            return
        }
        
        let fqs = fqSections(rawValue: indexPath.section)
        switch (fqs) {
        case .fqsDate:
            fq.dateRange = MFBWebServiceSvc_DateRanges(rawValue: UInt32(indexPath.row))
            if (fq.dateRange == MFBWebServiceSvc_DateRanges_Custom) {
                let drs = DateRangeViewController(nibName: "DateRangeViewController", bundle:nil)
                drs.delegate = self;
                drs.dtStart = MFBSoapCall.LocalDateFromUTCDate(dt: fq.dateMin)
                drs.dtEnd = MFBSoapCall.LocalDateFromUTCDate(dt: fq.dateMax)
                fSuppressRefresh = true
                navigationController?.pushViewController(drs, animated: true)
            }
            else {
                tableView.reloadData()
            }
        case .fqsAircraft:
            let rgAircraft = availableAircraft()
            if !self.fShowAllAircraft && indexPath.row == rgAircraft.count + 1 {
                // show all
                let newRowCount = numberHiddenAircraft() - 1  // remove one for the "Show all" row
                fShowAllAircraft = true
                var rg : [IndexPath] = []
                for i in 1...newRowCount {
                    rg.append(IndexPath(row: i, section: indexPath.section))
                }
                
                tableView.insertRows(at: rg, with: .top)
            } else {
                let ac = rgAircraft[indexPath.row - 1]
                
                if (fq.aircraftList.aircraft.contains(ac)) {
                    fq.aircraftList.aircraft.remove(ac)
                } else {
                    fq.aircraftList.aircraft.add(ac)
                }
            }
            tableView.reloadData()
        case .fqsCatClass:
            
            let cc = MFBWebServiceSvc_CategoryClass(ccid: MFBWebServiceSvc_CatClassID(UInt32(indexPath.row)))
            if fq.catClasses.categoryClass.contains(cc) {
                fq.catClasses.categoryClass.remove(cc)
            } else {
                fq.catClasses.categoryClass.add(cc)
            }
            tableView.reloadData()
        case .fqsAirports:
            fq.distance = MFBWebServiceSvc_FlightDistance(UInt32(indexPath.row - 1))
            tableView.reloadData()
        case .fqsMakes:
            if let mm = FlightQueryForm.makesInUse?[indexPath.row - 1] {
                if fq.makeList.makeModel.contains(mm) {
                    fq.makeList.makeModel.remove(mm)
                } else {
                    fq.makeList.makeModel.add(mm)
                }
                tableView.reloadData()
            }
        case .fqsAircraftFeatures:
            let afr = afRows(rawValue: indexPath.row)
            switch afr {
            case .afTailwheel:
                fq.isTailwheel.boolValue = !fq.isTailwheel.boolValue
            case .afHighPerf:
                fq.isHighPerformance.boolValue = !fq.isHighPerformance.boolValue
            case .afGlass:
                fq.isGlass.boolValue = !fq.isGlass.boolValue
            case .afTAA:
                fq.isTechnicallyAdvanced.boolValue = !fq.isTechnicallyAdvanced.boolValue
            case .afComplex:
                fq.isComplex.boolValue = !fq.isComplex.boolValue
            case .afRetract:
                fq.isRetract.boolValue = !fq.isRetract.boolValue
            case .afCSProp:
                fq.isConstantSpeedProp.boolValue = !fq.isConstantSpeedProp.boolValue
            case .afFlaps:
                fq.hasFlaps.boolValue = !fq.hasFlaps.boolValue
            case .afMotorGlider:
                fq.isMotorglider.boolValue = !fq.isMotorglider.boolValue
            case .afMultiEngineHeli:
                fq.isMultiEngineHeli.boolValue = !fq.isMultiEngineHeli.boolValue
            case .afEngineAny:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_AllEngines
            case .afEngineJet:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_Jet
            case .afEnginePiston:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_Piston
            case .afEngineTurbine:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine
            case .afEngineElectric:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_Electric
            case .afEngineTurboProp:
                fq.engineType = MFBWebServiceSvc_EngineTypeRestriction_Turboprop
            case .afInstanceAny:
                fq.aircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft
            case .afInstanceReal:
                fq.aircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly
            case .afInstanceTraining:
                fq.aircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly
            default:
                fatalError("unknown row: \(afr.debugDescription)")
            }
            tableView.reloadData()
        case .fqsProperties:
            fq.togglePropertyType(rgUsedProps[indexPath.row - 2])
            tableView.reloadData()
        case .fqsFlightFeatures:
            let ffr = ffRows(rawValue: indexPath.row)
            switch ffr {
            case .ffActualIMC:
                fq.hasIMC.boolValue = !fq.hasIMC.boolValue
            case .ffApproaches:
                fq.hasApproaches.boolValue = !fq.hasApproaches.boolValue
            case .ffCFI:
                fq.hasCFI.boolValue = !fq.hasCFI.boolValue
            case .ffDual:
                fq.hasDual.boolValue = !fq.hasDual.boolValue
            case .ffFSLanding:
                fq.hasFullStopLandings.boolValue = !fq.hasFullStopLandings.boolValue
            case .ffFSNightLanding:
                fq.hasNightLandings.boolValue = !fq.hasNightLandings.boolValue
            case .ffAnyLandings:
                fq.hasLandings.boolValue = !fq.hasLandings.boolValue
            case .ffAnyInstrument:
                fq.hasAnyInstrument.boolValue = !fq.hasAnyInstrument.boolValue
            case .ffGroundSim:
                fq.hasGroundSim.boolValue = !fq.hasGroundSim.boolValue
            case .ffHold:
                fq.hasHolds.boolValue = !fq.hasHolds.boolValue
            case .ffIsPublic:
                fq.isPublic.boolValue = !fq.isPublic.boolValue
            case .ffNight:
                fq.hasNight.boolValue = !fq.hasNight.boolValue
                break;
            case .ffPIC:
                fq.hasPIC.boolValue = !fq.hasPIC.boolValue
                break;
            case .ffSIC:
                fq.hasSIC.boolValue = !fq.hasSIC.boolValue
                break;
            case .ffTotalTime:
                fq.hasTotalTime.boolValue = !fq.hasTotalTime.boolValue
                break;
            case .ffSimIMC:
                fq.hasSimIMCTime.boolValue = !fq.hasSimIMCTime.boolValue
                break;
            case .ffTelemetry:
                fq.hasTelemetry.boolValue = !fq.hasTelemetry.boolValue
                break;
            case .ffImages:
                fq.hasImages.boolValue = !fq.hasImages.boolValue
                break;
            case .ffXC:
                fq.hasXC.boolValue = !fq.hasXC.boolValue
                break;
            case .ffSigned:
                fq.isSigned.boolValue = !fq.isSigned.boolValue
                break;
            default:
                fatalError("unknown flight feature row \(ffr.debugDescription)")
            }
            tableView.reloadData()
        case .fqsNameQueriesPrompt:  // nothing to click on
            break
        case .fqsNamedQueries:
            if indexPath.row > 1 {
                if let cq = FlightQueryForm._rgCannedQueries?[indexPath.row - 2] {
                    fq = cq
                    fSkipLoadText = true   // as we disappear, don't re-read from text cells - it can overwrite the saved query!
                    navigationController?.popViewController(animated: true)
                }
            }
        case .fqsText:
            if let ec = tableView.cellForRow(at: indexPath) as? EditCell {
                ec.txt.becomeFirstResponder()
            }
            break
        case .none:
            // should never happen.
            break
        }
    }
    
    // MARK: - Date range selector delegate
    public func setStartDate(_ dtStart: Date?, andEndDate dtEnd: Date?) {
        fq.dateRange = MFBWebServiceSvc_DateRanges_Custom
        fq.dateMin = MFBSoapCall.UTCDateFromLocalDate(dt: dtStart ?? NSDate.distantPast)
        fq.dateMax = MFBSoapCall.UTCDateFromLocalDate(dt: dtEnd ?? NSDate.distantFuture)
        tableView.reloadData()
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loadText()
        return true
    }
}
