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
//  MFBWebServiceObjectExtensions.swift
//  MFBSample
//
//  Created by Eric Berman on 2/21/23.
//

import Foundation

// MARK: - TotalsItem extensions
extension MFBWebServiceSvc_TotalsItem {
   @objc public func formattedValue(fHHMM : Bool) -> NSString {
       let nt = numericType as MFBWebServiceSvc_NumType
       switch (nt) {
           case MFBWebServiceSvc_NumType_Integer:
               return value.formatAsInteger()
           case MFBWebServiceSvc_NumType_Currency:
               let nsf = NumberFormatter()
               nsf.numberStyle = .currency
               return nsf.string(from: value)! as NSString
           case MFBWebServiceSvc_NumType_Decimal:
               return value.formatAs(Type: .Decimal, inHHMM: fHHMM, useGrouping: true)
           case MFBWebServiceSvc_NumType_Time:
               return value.formatAs(Type: .Time, inHHMM: fHHMM, useGrouping: true)
           default:
               return value.formatAsInteger()
           }
   }
   
   @objc public static func group(items : Array<MFBWebServiceSvc_TotalsItem>) -> [[MFBWebServiceSvc_TotalsItem]] {
       var d : [Int : [MFBWebServiceSvc_TotalsItem]] = [:]
       for ti in items {
           let key = Int(ti.group.rawValue)
           if (d[key] == nil) {
               d[key] = []
           }
           d[key]!.append(ti)
       }
       
       var result : [[MFBWebServiceSvc_TotalsItem]] = []
       for group in MFBWebServiceSvc_TotalsGroup_none.rawValue ... MFBWebServiceSvc_TotalsGroup_Total.rawValue {
           let key = Int(group)
           if let arr = d[key] {
               result.append(arr)
           }
       }
       return result
   }
    
    @objc(toSimpleItem:) public func toSimpleItem(fHHMM : Bool) -> SimpleTotalItem {
        let sti = SimpleTotalItem()
        sti.title = description!
        sti.subDesc = subDescription
        sti.valueDisplay = formattedValue(fHHMM: fHHMM) as String
        return sti
    }
    
    @objc(toSimpleItems: inHHMM:) public static func toSimpleItems(items : [MFBWebServiceSvc_TotalsItem], fHHMM: Bool) -> [SimpleTotalItem] {
        var arr = [SimpleTotalItem]()
        for ti in items {
            arr.append(ti.toSimpleItem(fHHMM: fHHMM))
        }
        return arr
    }
}

// MARK: - CurrencyStatusItem extensions
extension MFBWebServiceSvc_CurrencyStatusItem {
   @objc public func formattedTitle() -> String {
       if (attribute.range(of:"<a href", options: .caseInsensitive) != nil) {
           let csHtmlTag = CharacterSet(charactersIn: "<>")
           let a = attribute.components(separatedBy: csHtmlTag)
           return "\(a[2])\(a[4])"
       }
       return attribute
   }

    @objc public func toSimpleItem() -> SimpleCurrencyItem {
        let sci = SimpleCurrencyItem()
        sci.attribute = formattedTitle()
        sci.value = value
        sci.discrepancy = discrepancy
        sci.state = status
        return sci
    }
    
    @objc(toSimpleItems:) public static func toSimpleItems(items : [MFBWebServiceSvc_CurrencyStatusItem]) -> [SimpleCurrencyItem] {
        var arr = [SimpleCurrencyItem]()
        for csi in items {
            arr.append(csi.toSimpleItem())
        }
        return arr
    }
    
    @objc(colorForState:) public static func colorForState(state : MFBWebServiceSvc_CurrencyState) -> UIColor {
        switch (state) {
        case MFBWebServiceSvc_CurrencyState_OK:
            return UIColor.systemGreen
        case MFBWebServiceSvc_CurrencyState_GettingClose:
            return UIColor.systemBlue
        case MFBWebServiceSvc_CurrencyState_NotCurrent:
            return UIColor.systemRed
        case MFBWebServiceSvc_CurrencyState_NoDate:
            return UIColor.label
        default:
            return UIColor.label
        }
    }
}

// MARK: - MFBWebServiceSvc_CategoryClass extensions
extension MFBWebServiceSvc_CategoryClass {    
    @objc(initWithID:) public convenience init(ccid : MFBWebServiceSvc_CatClassID) {
        self.init()
        idCatClass = ccid
    }
    
    @objc public func localizedDescription() -> String {
        switch (idCatClass) {
            case MFBWebServiceSvc_CatClassID_none:
                return String(localized: "ccAny", comment: "Any category-class")
            case MFBWebServiceSvc_CatClassID_ASEL:
                return String(localized: "ccASEL", comment: "ASEL")
            case MFBWebServiceSvc_CatClassID_AMEL:
                return String(localized: "ccAMEL", comment: "AMEL")
            case MFBWebServiceSvc_CatClassID_ASES:
                return String(localized: "ccASES", comment: "ASES")
            case MFBWebServiceSvc_CatClassID_AMES:
                return String(localized: "ccAMES", comment: "AMES")
            case MFBWebServiceSvc_CatClassID_Glider:
                return String(localized: "ccGlider", comment: "Glider")
            case MFBWebServiceSvc_CatClassID_Helicopter:
                return String(localized: "ccHelicopter", comment: "Helicopter")
            case MFBWebServiceSvc_CatClassID_Gyroplane:
                return String(localized: "ccGyroplane", comment: "Gyroplane")
            case MFBWebServiceSvc_CatClassID_PoweredLift:
                return String(localized: "ccPoweredLift", comment: "Powered Lift")
            case MFBWebServiceSvc_CatClassID_Airship:
                return String(localized: "ccAirship", comment: "Airship")
            case MFBWebServiceSvc_CatClassID_HotAirBalloon:
                return String(localized: "ccHotAirBalloon", comment: "Hot Air Balloon")
            case MFBWebServiceSvc_CatClassID_GasBalloon:
                return String(localized: "ccGasBalloon", comment: "Gas Balloon")
            case MFBWebServiceSvc_CatClassID_PoweredParachuteLand:
                return String(localized: "ccPoweredParachuteLand", comment: "Powered Parachute Land")
            case MFBWebServiceSvc_CatClassID_PoweredParachuteSea:
                return String(localized: "ccPoweredParachuteSea", comment: "Powered Parachute Sea")
            case MFBWebServiceSvc_CatClassID_WeightShiftControlLand:
                return String(localized: "ccWeightShiftControlLand", comment: "WeightShiftControlLand")
            case MFBWebServiceSvc_CatClassID_WeightShiftControlSea:
                return String(localized: "ccWeightShiftControlSea", comment: "WeightShiftControlSea")
            case MFBWebServiceSvc_CatClassID_UnmannedAerialSystem:
                return String(localized: "ccUAS", comment: "UAS")
            case MFBWebServiceSvc_CatClassID_PoweredParaglider:
                return String(localized: "ccPoweredParaglider", comment: "Powered Paraglider")
        default:
            return description;
        }
    }
    
    @objc(isEqual:) override public func isEqual(_ anObject : (Any)?) -> Bool {
        if (anObject != nil) {
            if let cc = anObject as? MFBWebServiceSvc_CategoryClass {
                return idCatClass == cc.idCatClass
            }
        }
        return false
    }
}

// MARK: - MFBWebServiceSvc MFBWebServiceSvc_FlightQuery extensions
extension MFBWebServiceSvc_FlightQuery {
    public var aircraftAsArray : [MFBWebServiceSvc_Aircraft] {
        get {
            return (aircraftList.aircraft as? [MFBWebServiceSvc_Aircraft]) ?? []
        }
    }

    public var propsAsArray : [MFBWebServiceSvc_CustomPropertyType] {
        get {
            return (propertyTypes.customPropertyType as? [MFBWebServiceSvc_CustomPropertyType]) ?? []
        }
    }
    
    public var airporstAsArray : [String] {
        get {
            return (airportList.string as? [String]) ?? []
        }
    }

    public var makesAsArray : [MFBWebServiceSvc_MakesAndModels] {
        get {
            return (makeList.makeModel as? [MFBWebServiceSvc_MakesAndModels]) ?? []
        }
    }
    
    public var catclassesAsArray : [MFBWebServiceSvc_CategoryClass] {
        get {
            return (catClasses.categoryClass as? [MFBWebServiceSvc_CategoryClass]) ?? []
        }
    }
    
    @objc static public func getNewFlightQuery() -> MFBWebServiceSvc_FlightQuery {
        let f = MFBWebServiceSvc_FlightQuery()
        f.aircraftList = MFBWebServiceSvc_ArrayOfAircraft()
        f.propertyTypes = MFBWebServiceSvc_ArrayOfCustomPropertyType()
        f.airportList = MFBWebServiceSvc_ArrayOfString()
        f.makeList = MFBWebServiceSvc_ArrayOfMakeModel()
        f.catClasses = MFBWebServiceSvc_ArrayOfCategoryClass()
        f.dateRange = MFBWebServiceSvc_DateRanges_AllTime
        f.distance = MFBWebServiceSvc_FlightDistance_AllFlights
        f.dateMin = NSDate().UTCDateFromLocalDate()
        f.dateMax = NSDate().UTCDateFromLocalDate()
        
        f.hasApproaches = USBoolean(bool: false)
        f.hasCFI = USBoolean(bool: false)
        f.hasDual = USBoolean(bool: false)
        f.hasDual = USBoolean(bool: false)
        f.hasFlaps = USBoolean(bool: false)
        f.hasFullStopLandings = USBoolean(bool: false)
        f.hasLandings = USBoolean(bool: false)
        f.hasGroundSim = USBoolean(bool: false)
        f.hasHolds = USBoolean(bool: false)
        f.hasIMC = USBoolean(bool: false)
        f.hasAnyInstrument = USBoolean(bool: false)
        f.hasNight = USBoolean(bool: false)
        f.hasNightLandings = USBoolean(bool: false)
        f.hasPIC = USBoolean(bool: false)
        f.hasSIC = USBoolean(bool: false)
        f.hasTotalTime = USBoolean(bool: false)
        f.hasSimIMCTime = USBoolean(bool: false)
        f.hasTelemetry = USBoolean(bool: false)
        f.hasImages = USBoolean(bool: false)
        f.hasXC = USBoolean(bool: false)
        f.isComplex = USBoolean(bool: false)
        f.isConstantSpeedProp = USBoolean(bool: false)
        f.isGlass = USBoolean(bool: false)
        f.isHighPerformance = USBoolean(bool: false)
        f.isPublic = USBoolean(bool: false)
        f.isRetract = USBoolean(bool: false)
        f.isTailwheel = USBoolean(bool: false)
        f.isTechnicallyAdvanced = USBoolean(bool: false)
        f.isTurbine = USBoolean(bool: false)
        f.isSigned = USBoolean(bool: false)
        f.isMotorglider = USBoolean(bool: false)
        f.isMultiEngineHeli = USBoolean(bool: false)
        f.engineType = MFBWebServiceSvc_EngineTypeRestriction_AllEngines
        f.aircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft
        f.modelName = ""
        f.typeNames = MFBWebServiceSvc_ArrayOfString()
        
        f.propertiesConjunction = MFBWebServiceSvc_GroupConjunction_Any
        f.flightCharacteristicsConjunction = MFBWebServiceSvc_GroupConjunction_All
        
        return f
    }
    
    @objc public func hasDate() -> Bool {
        return dateRange != MFBWebServiceSvc_DateRanges_AllTime && dateRange != MFBWebServiceSvc_DateRanges_none
    }

    @objc public func hasText() -> Bool {
        return !(generalText ?? "").isEmpty
    }

    @objc public func hasFlightCharacteristics() -> Bool {
        return (hasApproaches.boolValue || hasCFI.boolValue || hasDual.boolValue || hasFullStopLandings.boolValue || hasLandings.boolValue || hasAnyInstrument.boolValue || hasTotalTime.boolValue ||
                hasGroundSim.boolValue || hasHolds.boolValue || hasIMC.boolValue || hasNight.boolValue || hasNightLandings.boolValue ||
                hasPIC.boolValue || isPublic.boolValue || hasSIC.boolValue || hasSimIMCTime.boolValue || hasTelemetry.boolValue || hasImages.boolValue || hasXC.boolValue || isSigned.boolValue)
    }

    @objc public func hasAircraftCharacteristics() -> Bool {
        return (isComplex.boolValue || isConstantSpeedProp.boolValue || isGlass.boolValue || isHighPerformance.boolValue || isMotorglider.boolValue || isMultiEngineHeli.boolValue ||
                isTurbine.boolValue || isRetract.boolValue || isTailwheel.boolValue || isTechnicallyAdvanced.boolValue || hasFlaps.boolValue ||
                aircraftInstanceTypes.rawValue > MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft.rawValue ||
                engineType.rawValue > MFBWebServiceSvc_EngineTypeRestriction_AllEngines.rawValue)
    }

    @objc public func hasAirport() -> Bool {
        return airportList.string.count > 0 ||
        (distance != MFBWebServiceSvc_FlightDistance_AllFlights && distance != MFBWebServiceSvc_FlightDistance_none)
    }

    @objc public func hasProperties() -> Bool {
        return propertyTypes.customPropertyType.count > 0
    }

    @objc public func hasPropertyType(_ cpt : MFBWebServiceSvc_CustomPropertyType) -> Bool {
        for cpt2 in propsAsArray {
            if (cpt2.propTypeID.intValue == cpt.propTypeID.intValue) {
                return true
            }
        }
        return false
    }

    @objc public func togglePropertyType(_ cpt : MFBWebServiceSvc_CustomPropertyType) {
        var cptFound : MFBWebServiceSvc_CustomPropertyType? = nil
        for cpt2 in propsAsArray {
            if (cpt2.propTypeID.intValue == cpt.propTypeID.intValue) {
                cptFound = cpt2;
                break;
            }
        }
        
        if (cptFound == nil) {
            propertyTypes.customPropertyType.add(cpt)
        }
        else {
            propertyTypes.customPropertyType.remove(cptFound as Any)
        }
    }

    @objc public func hasAircraft() -> Bool {
        return (aircraftList?.aircraft ?? []).count > 0
    }

    @objc public func hasMakes() -> Bool {
        return (makeList?.makeModel ?? []).count > 0 || !(modelName ?? "").isEmpty || (typeNames?.string ?? []).count > 0
    }

    @objc public func hasCatClasses() -> Bool {
        return (catClasses?.categoryClass ?? []).count > 0
    }

    @objc public func isUnrestricted() -> Bool {
        return !(hasDate() ||
            hasText() ||
            hasFlightCharacteristics() ||
            hasAircraftCharacteristics() ||
            hasAirport() ||
            hasProperties() ||
            hasAircraft() ||
            hasMakes() ||
            hasCatClasses())
    }
    
    @objc static public func stringForDateRange(_ dr : MFBWebServiceSvc_DateRanges) -> String {
        switch (dr) {
            case MFBWebServiceSvc_DateRanges_AllTime, MFBWebServiceSvc_DateRanges_none:
                return String(localized: "All Time", comment: "Totals - All Time")
            case MFBWebServiceSvc_DateRanges_Trailing12Months:
                return String(localized: "12 Months", comment: "Totals - Trailing 12 months")
            case MFBWebServiceSvc_DateRanges_Tailing6Months:
                return String(localized: "6 Months", comment: "Totals - Trailing 6 months")
            case MFBWebServiceSvc_DateRanges_YTD:
                return String(localized: "YTD", comment: "Totals - Year-to-date")
            case MFBWebServiceSvc_DateRanges_PrevMonth:
                return String(localized: "Previous Month", comment: "Totals - Previous Month")
            case MFBWebServiceSvc_DateRanges_PrevYear:
                return String(localized: "Previous Year", comment: "Totals - Previous Year")
            case MFBWebServiceSvc_DateRanges_ThisMonth:
                return String(localized: "This Month", comment: "Totals - This month")
            case MFBWebServiceSvc_DateRanges_Trailing30:
                return String(localized: "Trailing 30", comment: "Totals - Trailing 30 days")
            case MFBWebServiceSvc_DateRanges_Trailing90:
                return String(localized: "Trailing 90", comment: "Totals - Trailing 90 days")
            default:
                return ""
        }
    }
}

// MARK: - MFBWebServiceSvc_ArrayOfMFBImageInfo
extension MFBWebServiceSvc_ArrayOfMFBImageInfo {
    static let imgKey = "RGMFBImages"
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(mfbImageInfo, forKey: MFBWebServiceSvc_ArrayOfMFBImageInfo.imgKey)
    }
    
    @objc(initWithCoderMFB:) convenience init(_ decoder : NSCoder) {
        var rgImages : [MFBWebServiceSvc_MFBImageInfo] = []
        do {
            let x = try decoder.decodeTopLevelObject(of: [NSArray.self, MFBWebServiceSvc_MFBImageInfo.self], forKey: MFBWebServiceSvc_ArrayOfMFBImageInfo.imgKey)
            rgImages = x as? [MFBWebServiceSvc_MFBImageInfo] ?? []
        }
        catch {
            rgImages = []
        }
        self.init()
        setImages(rgImages)
    }
    
    func setImages(_ rgImages : [MFBWebServiceSvc_MFBImageInfo]) {
        mfbImageInfo.addObjects(from: rgImages)
    }
}

// MARK: - MFBWebServiceSvc_MFBImageInfo
private var UIB_CACHEDTHUMB_KEY: UInt8 = 0

extension MFBWebServiceSvc_MFBImageInfo {
    private static let keyComment = "MFBIIComment"
    private static let keyThumbnailFile = "MFBIIThumbFile"
    private static let keyVirtualPath = "MFBIIVirtPath"
    private static let keyURLFullImage = "MFBIIFullImageURL"
    private static let keyImageType = "MFBIIImageType"
    private static let keycachedThumb = "MFBIICachedThumb"
    private static let keyURLThumbnail = "MFBIIURLThumb"
    
    @objc public var cachedThumb : UIImage? {
        get {
            return objc_getAssociatedObject(self, &UIB_CACHEDTHUMB_KEY) as? UIImage
        }
        set (img) {
            objc_setAssociatedObject(self, &UIB_CACHEDTHUMB_KEY, img, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc public func encodeWithCoderMFB(_ encoder : NSCoder) {
        encoder.encode(comment, forKey: MFBWebServiceSvc_MFBImageInfo.keyComment)
        encoder.encode(thumbnailFile, forKey: MFBWebServiceSvc_MFBImageInfo.keyThumbnailFile)
        encoder.encode(virtualPath, forKey: MFBWebServiceSvc_MFBImageInfo.keyVirtualPath)
        encoder.encode(urlFullImage, forKey: MFBWebServiceSvc_MFBImageInfo.keyURLFullImage)
        encoder.encode(imageType.rawValue, forKey: MFBWebServiceSvc_MFBImageInfo.keyImageType)
        encoder.encode(cachedThumb, forKey: MFBWebServiceSvc_MFBImageInfo.keycachedThumb)
        encoder.encode(urlThumbnail, forKey: MFBWebServiceSvc_MFBImageInfo.keyURLThumbnail)
    }
    
    @objc(initWithCoderMFB:) convenience init(_ decoder : NSCoder) {
        self.init()
        comment = decoder.decodeObject(of: NSString.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyComment) as? String
        thumbnailFile = decoder.decodeObject(of: NSString.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyThumbnailFile) as? String
        virtualPath = decoder.decodeObject(of: NSString.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyVirtualPath) as? String
        urlFullImage = decoder.decodeObject(of: NSString.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyURLFullImage) as? String
        urlThumbnail = decoder.decodeObject(of: NSString.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyURLThumbnail) as? String
        if let raw = decoder.decodeObject(of: NSNumber.self, forKey: MFBWebServiceSvc_MFBImageInfo.keyImageType) as? Int {
            imageType = MFBWebServiceSvc_ImageFileType(rawValue: UInt32(raw))
        } else {
            imageType = MFBWebServiceSvc_ImageFileType_JPEG
        }
  
        cachedThumb = decoder.decodeObject(of: UIImage.self, forKey: MFBWebServiceSvc_MFBImageInfo.keycachedThumb)
    }
    
    @objc var urlForImage : URL {
        get {
            let szURLImage = urlThumbnail.hasPrefix("/") ? String(format: "https://%@%@", MFBHOSTNAME, urlThumbnail) : urlThumbnail ?? ""
            return URL(string: szURLImage)!
        }
    }
    
    @objc var livesOnServer : Bool {
        get {
            return !(virtualPath ?? "").isEmpty
        }
    }
}

