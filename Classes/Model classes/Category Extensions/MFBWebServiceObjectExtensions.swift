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

// MARK: TotalsItem extensions
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
               return self.value.formatAs(Type: .Decimal, inHHMM: fHHMM, useGrouping: true)
           case MFBWebServiceSvc_NumType_Time:
               return self.value.formatAs(Type: .Time, inHHMM: fHHMM, useGrouping: true)
           default:
               return value.formatAsInteger()
           }
   }
   
   @objc public static func Group(items : Array<MFBWebServiceSvc_TotalsItem>) -> NSMutableArray {
       let d = NSMutableDictionary()
       for ti in items {
           let key = Int(ti.group.rawValue)
           if (d[key] == nil) {
               d[key] = NSMutableArray()
           }
           if let arr = d[key] as? NSMutableArray {
               arr.add(ti)
           }
       }
       
       let result = NSMutableArray()
       for group in MFBWebServiceSvc_TotalsGroup_none.rawValue ... MFBWebServiceSvc_TotalsGroup_Total.rawValue {
           let key = Int(group)
           if let arr = d[key] {
               result.add(arr)
           }
       }
       return result
   }
    
    @objc(toSimpleItem:) public func toSimpleItem(fHHMM : Bool) -> SimpleTotalItem {
        let sti = SimpleTotalItem()!
        sti.title = description
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

// MARK: CurrencyStatusItem extensions
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
        let sci = SimpleCurrencyItem()!
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

// MARK: MFBWebServiceSvc_LogbookEntry extensions
extension MFBWebServiceSvc_LogbookEntry {

    @objc public static func idNewFlight() -> NSNumber {
        return NSNumber(integerLiteral: -1)
    }
    
    @objc public static func idPendingFlight() -> NSNumber {
        return NSNumber(integerLiteral: -2)
    }
    
    @objc public static func idQueuedFlight() -> NSNumber {
        return NSNumber(integerLiteral: -3)
    }
    
    @objc(toSimpleItem:) public func toSimpleItem(fHHMM : Bool) -> SimpleLogbookEntry {
        let sle = SimpleLogbookEntry()
        sle.comment = comment
        sle.route = route
        sle.date = date
        sle.totalTimeDisplay = self.totalFlightTime.formatAs(Type: .Time, inHHMM: fHHMM, useGrouping: true) as String
        sle.tailNumDisplay = tailNumDisplay
        return sle
    }
    
    @objc(toSimpleItems:inHHMM:) public static func toSimpleItems(items : [MFBWebServiceSvc_LogbookEntry], fHHMM : Bool) ->[SimpleLogbookEntry] {
        var arr = [SimpleLogbookEntry]()
        for le in items {
            arr.append(le.toSimpleItem(fHHMM: fHHMM))
        }
        return arr
    }
    
    @objc public func isKnownFlightStart() -> Bool  {
        return !NSDate.isUnknownDate(dt: flightStart);
    }

    @objc public func isKnownEngineStart() -> Bool  {
        return !NSDate.isUnknownDate(dt: engineStart);
    }

    @objc public func isKnownFlightEnd() -> Bool  {
        return !NSDate.isUnknownDate(dt: flightEnd);
    }

    @objc public func isKnownEngineEnd() -> Bool  {
        return !NSDate.isUnknownDate(dt: engineEnd);
    }

    @objc public func isKnownFlightTime() -> Bool {
        return isKnownFlightStart() && isKnownFlightEnd()
    }

    @objc public func isKnownEngineTime() -> Bool {
        return isKnownEngineStart() && isKnownEngineEnd()
    }
    
    @objc public func isNewFlight() -> Bool {
        return flightID?.intValue == -1
    }

    @objc public func isAwaitingUpload() -> Bool {
        return flightID?.intValue ?? 0 < -1
    }

    @objc public func isNewOrAwaitingUpload() -> Bool {
        return flightID?.intValue ?? 0 < 0
    }

    @objc public func isQueued() -> Bool {
        return flightID?.intValue == MFBWebServiceSvc_LogbookEntry.idQueuedFlight().intValue
    }

    // Below is not yet tested but can't be implemented here until flightprops are migrated to swift
    /*
    // isInitialState means a basically empty flight, but it COULD have a pre-initialized hobbs starting time.
    @objc public func isInInitialState() -> Bool {
        if (self.comment?.isEmpty ?? true &&
            self.route?.isEmpty ?? true &&
            approaches?.intValue == 0 &&
            cfi?.doubleValue == 0.0 &&
            crossCountry?.doubleValue == 0.0 &&
            dual?.doubleValue == 0.0 &&
            fullStopLandings?.intValue == 0 &&
            hobbsEnd?.doubleValue == 0.0 &&
            imc?.doubleValue == 0.0 &&
            landings?.intValue == 0 &&
            nightLandings?.intValue == 0 &&
            nighttime?.doubleValue == 0.0 &&
            pic?.doubleValue == 0.0 &&
            sic?.doubleValue == 0.0 &&
            simulatedIFR?.doubleValue == 0.0 &&
            totalFlightTime?.doubleValue == 0.0 &&
            customProperties?.customFlightProperty?.count == 0) {
            return true;
        }

        // see if any properties are empty
        if ((customProperties?.customFlightProperty?.count ?? 0) > 0) {
            return (FlightProps.getNoNet().distillList(customProperties.customFlightProperty as? [MFBWebServiceSvc_CustomFlightProperty], includeLockedProps: false, include: nil).count ) == 0
        }
        
        return false
    }
    
    @objc public func isEmpty() -> Bool {
        return hobbsStart.doubleValue == 0.0 && isInInitialState()
    }
     */


    @objc public func isSigned() -> Bool {
        return self.cfiSignatureState == MFBWebServiceSvc_SignatureState_Valid || self.cfiSignatureState == MFBWebServiceSvc_SignatureState_Invalid;
    }
}

// MARK: MFBWebServiceSvc_CategoryClass extensions
extension MFBWebServiceSvc_CategoryClass {    
    @objc(initWithID:) public convenience init(ccid : MFBWebServiceSvc_CatClassID) {
        self.init()
        self.idCatClass = ccid
    }
    
    @objc public func localizedDescription() -> String {
        switch (self.idCatClass) {
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
            return self.description;
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
