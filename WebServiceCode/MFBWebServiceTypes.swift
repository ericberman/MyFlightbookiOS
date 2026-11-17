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
//  MFBWebServiceTypes.swift
//
//  The data structures of the MyFlightbook web service (the complex types and enumerations in the WSDL),
//  in WSDL order.  Class and property names are the same as the old WSDLToObjC output, so existing code is
//  unaffected.
//
//  - Adding a property: add the Swift property and a line in `soapFields`, at the position matching the WSDL's sequence.
//  - Adding a type:     copy a similar class; `@objc(MFBWebServiceSvc_Name)` must match the WSDL type name since the
//                       name is used both to resolve xsi:type in responses and as the NSKeyedArchiver class name.
//  - Adding an enum:    copy a similar enum; raw values start at 1 in WSDL order (0 means "not specified").
//

import Foundation

// MARK: - Enumerations

public struct MFBWebServiceSvc_AircraftInstanceTypes : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AircraftInstanceTypes)] { return [
        ("RealAircraft", MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft),
        ("Mintype", MFBWebServiceSvc_AircraftInstanceTypes_Mintype),
        ("UncertifiedSimulator", MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator),
        ("CertifiedIFRSimulator", MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator),
        ("CertifiedIFRAndLandingsSimulator", MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator),
        ("CertifiedATD", MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD),
        ("MaxType", MFBWebServiceSvc_AircraftInstanceTypes_MaxType)
    ] }
}
public let MFBWebServiceSvc_AircraftInstanceTypes_none = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 0)
public let MFBWebServiceSvc_AircraftInstanceTypes_RealAircraft = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 1)
public let MFBWebServiceSvc_AircraftInstanceTypes_Mintype = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 2)
public let MFBWebServiceSvc_AircraftInstanceTypes_UncertifiedSimulator = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 3)
public let MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRSimulator = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 4)
public let MFBWebServiceSvc_AircraftInstanceTypes_CertifiedIFRAndLandingsSimulator = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 5)
public let MFBWebServiceSvc_AircraftInstanceTypes_CertifiedATD = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 6)
public let MFBWebServiceSvc_AircraftInstanceTypes_MaxType = MFBWebServiceSvc_AircraftInstanceTypes(rawValue: 7)

public struct MFBWebServiceSvc_ImageFileType : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_ImageFileType)] { return [
        ("JPEG", MFBWebServiceSvc_ImageFileType_JPEG),
        ("PDF", MFBWebServiceSvc_ImageFileType_PDF),
        ("S3PDF", MFBWebServiceSvc_ImageFileType_S3PDF),
        ("S3VideoMP4", MFBWebServiceSvc_ImageFileType_S3VideoMP4),
        ("Unknown", MFBWebServiceSvc_ImageFileType_Unknown)
    ] }
}
public let MFBWebServiceSvc_ImageFileType_none = MFBWebServiceSvc_ImageFileType(rawValue: 0)
public let MFBWebServiceSvc_ImageFileType_JPEG = MFBWebServiceSvc_ImageFileType(rawValue: 1)
public let MFBWebServiceSvc_ImageFileType_PDF = MFBWebServiceSvc_ImageFileType(rawValue: 2)
public let MFBWebServiceSvc_ImageFileType_S3PDF = MFBWebServiceSvc_ImageFileType(rawValue: 3)
public let MFBWebServiceSvc_ImageFileType_S3VideoMP4 = MFBWebServiceSvc_ImageFileType(rawValue: 4)
public let MFBWebServiceSvc_ImageFileType_Unknown = MFBWebServiceSvc_ImageFileType(rawValue: 5)

public struct MFBWebServiceSvc_PilotRole : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_PilotRole)] { return [
        ("None", MFBWebServiceSvc_PilotRole_None),
        ("PIC", MFBWebServiceSvc_PilotRole_PIC),
        ("SIC", MFBWebServiceSvc_PilotRole_SIC),
        ("CFI", MFBWebServiceSvc_PilotRole_CFI)
    ] }
}
public let MFBWebServiceSvc_PilotRole_none = MFBWebServiceSvc_PilotRole(rawValue: 0)
public let MFBWebServiceSvc_PilotRole_None = MFBWebServiceSvc_PilotRole(rawValue: 1)
public let MFBWebServiceSvc_PilotRole_PIC = MFBWebServiceSvc_PilotRole(rawValue: 2)
public let MFBWebServiceSvc_PilotRole_SIC = MFBWebServiceSvc_PilotRole(rawValue: 3)
public let MFBWebServiceSvc_PilotRole_CFI = MFBWebServiceSvc_PilotRole(rawValue: 4)

public struct MFBWebServiceSvc_AvionicsTechnologyType : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AvionicsTechnologyType)] { return [
        ("None", MFBWebServiceSvc_AvionicsTechnologyType_None),
        ("Glass", MFBWebServiceSvc_AvionicsTechnologyType_Glass),
        ("TAA", MFBWebServiceSvc_AvionicsTechnologyType_TAA)
    ] }
}
public let MFBWebServiceSvc_AvionicsTechnologyType_none = MFBWebServiceSvc_AvionicsTechnologyType(rawValue: 0)
public let MFBWebServiceSvc_AvionicsTechnologyType_None = MFBWebServiceSvc_AvionicsTechnologyType(rawValue: 1)
public let MFBWebServiceSvc_AvionicsTechnologyType_Glass = MFBWebServiceSvc_AvionicsTechnologyType(rawValue: 2)
public let MFBWebServiceSvc_AvionicsTechnologyType_TAA = MFBWebServiceSvc_AvionicsTechnologyType(rawValue: 3)

public struct MFBWebServiceSvc_AllowedAircraftTypes : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AllowedAircraftTypes)] { return [
        ("Any", MFBWebServiceSvc_AllowedAircraftTypes_Any),
        ("SimulatorOnly", MFBWebServiceSvc_AllowedAircraftTypes_SimulatorOnly),
        ("SimOrAnonymous", MFBWebServiceSvc_AllowedAircraftTypes_SimOrAnonymous)
    ] }
}
public let MFBWebServiceSvc_AllowedAircraftTypes_none = MFBWebServiceSvc_AllowedAircraftTypes(rawValue: 0)
public let MFBWebServiceSvc_AllowedAircraftTypes_Any = MFBWebServiceSvc_AllowedAircraftTypes(rawValue: 1)
public let MFBWebServiceSvc_AllowedAircraftTypes_SimulatorOnly = MFBWebServiceSvc_AllowedAircraftTypes(rawValue: 2)
public let MFBWebServiceSvc_AllowedAircraftTypes_SimOrAnonymous = MFBWebServiceSvc_AllowedAircraftTypes(rawValue: 3)

public struct MFBWebServiceSvc_CatClassID : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_CatClassID)] { return [
        ("ASEL", MFBWebServiceSvc_CatClassID_ASEL),
        ("AMEL", MFBWebServiceSvc_CatClassID_AMEL),
        ("ASES", MFBWebServiceSvc_CatClassID_ASES),
        ("AMES", MFBWebServiceSvc_CatClassID_AMES),
        ("Glider", MFBWebServiceSvc_CatClassID_Glider),
        ("Helicopter", MFBWebServiceSvc_CatClassID_Helicopter),
        ("Gyroplane", MFBWebServiceSvc_CatClassID_Gyroplane),
        ("PoweredLift", MFBWebServiceSvc_CatClassID_PoweredLift),
        ("Airship", MFBWebServiceSvc_CatClassID_Airship),
        ("HotAirBalloon", MFBWebServiceSvc_CatClassID_HotAirBalloon),
        ("GasBalloon", MFBWebServiceSvc_CatClassID_GasBalloon),
        ("PoweredParachuteLand", MFBWebServiceSvc_CatClassID_PoweredParachuteLand),
        ("PoweredParachuteSea", MFBWebServiceSvc_CatClassID_PoweredParachuteSea),
        ("WeightShiftControlLand", MFBWebServiceSvc_CatClassID_WeightShiftControlLand),
        ("WeightShiftControlSea", MFBWebServiceSvc_CatClassID_WeightShiftControlSea),
        ("UnmannedAerialSystem", MFBWebServiceSvc_CatClassID_UnmannedAerialSystem),
        ("PoweredParaglider", MFBWebServiceSvc_CatClassID_PoweredParaglider)
    ] }
}
public let MFBWebServiceSvc_CatClassID_none = MFBWebServiceSvc_CatClassID(rawValue: 0)
public let MFBWebServiceSvc_CatClassID_ASEL = MFBWebServiceSvc_CatClassID(rawValue: 1)
public let MFBWebServiceSvc_CatClassID_AMEL = MFBWebServiceSvc_CatClassID(rawValue: 2)
public let MFBWebServiceSvc_CatClassID_ASES = MFBWebServiceSvc_CatClassID(rawValue: 3)
public let MFBWebServiceSvc_CatClassID_AMES = MFBWebServiceSvc_CatClassID(rawValue: 4)
public let MFBWebServiceSvc_CatClassID_Glider = MFBWebServiceSvc_CatClassID(rawValue: 5)
public let MFBWebServiceSvc_CatClassID_Helicopter = MFBWebServiceSvc_CatClassID(rawValue: 6)
public let MFBWebServiceSvc_CatClassID_Gyroplane = MFBWebServiceSvc_CatClassID(rawValue: 7)
public let MFBWebServiceSvc_CatClassID_PoweredLift = MFBWebServiceSvc_CatClassID(rawValue: 8)
public let MFBWebServiceSvc_CatClassID_Airship = MFBWebServiceSvc_CatClassID(rawValue: 9)
public let MFBWebServiceSvc_CatClassID_HotAirBalloon = MFBWebServiceSvc_CatClassID(rawValue: 10)
public let MFBWebServiceSvc_CatClassID_GasBalloon = MFBWebServiceSvc_CatClassID(rawValue: 11)
public let MFBWebServiceSvc_CatClassID_PoweredParachuteLand = MFBWebServiceSvc_CatClassID(rawValue: 12)
public let MFBWebServiceSvc_CatClassID_PoweredParachuteSea = MFBWebServiceSvc_CatClassID(rawValue: 13)
public let MFBWebServiceSvc_CatClassID_WeightShiftControlLand = MFBWebServiceSvc_CatClassID(rawValue: 14)
public let MFBWebServiceSvc_CatClassID_WeightShiftControlSea = MFBWebServiceSvc_CatClassID(rawValue: 15)
public let MFBWebServiceSvc_CatClassID_UnmannedAerialSystem = MFBWebServiceSvc_CatClassID(rawValue: 16)
public let MFBWebServiceSvc_CatClassID_PoweredParaglider = MFBWebServiceSvc_CatClassID(rawValue: 17)

public struct MFBWebServiceSvc_HighPerfType : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_HighPerfType)] { return [
        ("NotHighPerf", MFBWebServiceSvc_HighPerfType_NotHighPerf),
        ("HighPerf", MFBWebServiceSvc_HighPerfType_HighPerf),
        ("Is200HP", MFBWebServiceSvc_HighPerfType_Is200HP)
    ] }
}
public let MFBWebServiceSvc_HighPerfType_none = MFBWebServiceSvc_HighPerfType(rawValue: 0)
public let MFBWebServiceSvc_HighPerfType_NotHighPerf = MFBWebServiceSvc_HighPerfType(rawValue: 1)
public let MFBWebServiceSvc_HighPerfType_HighPerf = MFBWebServiceSvc_HighPerfType(rawValue: 2)
public let MFBWebServiceSvc_HighPerfType_Is200HP = MFBWebServiceSvc_HighPerfType(rawValue: 3)

public struct MFBWebServiceSvc_TurbineLevel : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_TurbineLevel)] { return [
        ("Piston", MFBWebServiceSvc_TurbineLevel_Piston),
        ("TurboProp", MFBWebServiceSvc_TurbineLevel_TurboProp),
        ("Jet", MFBWebServiceSvc_TurbineLevel_Jet),
        ("UnspecifiedTurbine", MFBWebServiceSvc_TurbineLevel_UnspecifiedTurbine),
        ("Electric", MFBWebServiceSvc_TurbineLevel_Electric)
    ] }
}
public let MFBWebServiceSvc_TurbineLevel_none = MFBWebServiceSvc_TurbineLevel(rawValue: 0)
public let MFBWebServiceSvc_TurbineLevel_Piston = MFBWebServiceSvc_TurbineLevel(rawValue: 1)
public let MFBWebServiceSvc_TurbineLevel_TurboProp = MFBWebServiceSvc_TurbineLevel(rawValue: 2)
public let MFBWebServiceSvc_TurbineLevel_Jet = MFBWebServiceSvc_TurbineLevel(rawValue: 3)
public let MFBWebServiceSvc_TurbineLevel_UnspecifiedTurbine = MFBWebServiceSvc_TurbineLevel(rawValue: 4)
public let MFBWebServiceSvc_TurbineLevel_Electric = MFBWebServiceSvc_TurbineLevel(rawValue: 5)

public struct MFBWebServiceSvc_CurrencyState : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_CurrencyState)] { return [
        ("NotCurrent", MFBWebServiceSvc_CurrencyState_NotCurrent),
        ("GettingClose", MFBWebServiceSvc_CurrencyState_GettingClose),
        ("OK", MFBWebServiceSvc_CurrencyState_OK),
        ("NoDate", MFBWebServiceSvc_CurrencyState_NoDate)
    ] }
}
public let MFBWebServiceSvc_CurrencyState_none = MFBWebServiceSvc_CurrencyState(rawValue: 0)
public let MFBWebServiceSvc_CurrencyState_NotCurrent = MFBWebServiceSvc_CurrencyState(rawValue: 1)
public let MFBWebServiceSvc_CurrencyState_GettingClose = MFBWebServiceSvc_CurrencyState(rawValue: 2)
public let MFBWebServiceSvc_CurrencyState_OK = MFBWebServiceSvc_CurrencyState(rawValue: 3)
public let MFBWebServiceSvc_CurrencyState_NoDate = MFBWebServiceSvc_CurrencyState(rawValue: 4)

public struct MFBWebServiceSvc_CurrencyGroups : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_CurrencyGroups)] { return [
        ("None", MFBWebServiceSvc_CurrencyGroups_None),
        ("FlightExperience", MFBWebServiceSvc_CurrencyGroups_FlightExperience),
        ("FlightReview", MFBWebServiceSvc_CurrencyGroups_FlightReview),
        ("Aircraft", MFBWebServiceSvc_CurrencyGroups_Aircraft),
        ("AircraftDeadline", MFBWebServiceSvc_CurrencyGroups_AircraftDeadline),
        ("Certificates", MFBWebServiceSvc_CurrencyGroups_Certificates),
        ("Medical", MFBWebServiceSvc_CurrencyGroups_Medical),
        ("Deadline", MFBWebServiceSvc_CurrencyGroups_Deadline),
        ("CustomCurrency", MFBWebServiceSvc_CurrencyGroups_CustomCurrency)
    ] }
}
public let MFBWebServiceSvc_CurrencyGroups_none = MFBWebServiceSvc_CurrencyGroups(rawValue: 0)
public let MFBWebServiceSvc_CurrencyGroups_None = MFBWebServiceSvc_CurrencyGroups(rawValue: 1)
public let MFBWebServiceSvc_CurrencyGroups_FlightExperience = MFBWebServiceSvc_CurrencyGroups(rawValue: 2)
public let MFBWebServiceSvc_CurrencyGroups_FlightReview = MFBWebServiceSvc_CurrencyGroups(rawValue: 3)
public let MFBWebServiceSvc_CurrencyGroups_Aircraft = MFBWebServiceSvc_CurrencyGroups(rawValue: 4)
public let MFBWebServiceSvc_CurrencyGroups_AircraftDeadline = MFBWebServiceSvc_CurrencyGroups(rawValue: 5)
public let MFBWebServiceSvc_CurrencyGroups_Certificates = MFBWebServiceSvc_CurrencyGroups(rawValue: 6)
public let MFBWebServiceSvc_CurrencyGroups_Medical = MFBWebServiceSvc_CurrencyGroups(rawValue: 7)
public let MFBWebServiceSvc_CurrencyGroups_Deadline = MFBWebServiceSvc_CurrencyGroups(rawValue: 8)
public let MFBWebServiceSvc_CurrencyGroups_CustomCurrency = MFBWebServiceSvc_CurrencyGroups(rawValue: 9)

public struct MFBWebServiceSvc_DateRanges : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_DateRanges)] { return [
        ("AllTime", MFBWebServiceSvc_DateRanges_AllTime),
        ("YTD", MFBWebServiceSvc_DateRanges_YTD),
        ("Tailing6Months", MFBWebServiceSvc_DateRanges_Tailing6Months),
        ("Trailing12Months", MFBWebServiceSvc_DateRanges_Trailing12Months),
        ("ThisMonth", MFBWebServiceSvc_DateRanges_ThisMonth),
        ("PrevMonth", MFBWebServiceSvc_DateRanges_PrevMonth),
        ("PrevYear", MFBWebServiceSvc_DateRanges_PrevYear),
        ("Trailing30", MFBWebServiceSvc_DateRanges_Trailing30),
        ("Trailing90", MFBWebServiceSvc_DateRanges_Trailing90),
        ("Custom", MFBWebServiceSvc_DateRanges_Custom)
    ] }
}
public let MFBWebServiceSvc_DateRanges_none = MFBWebServiceSvc_DateRanges(rawValue: 0)
public let MFBWebServiceSvc_DateRanges_AllTime = MFBWebServiceSvc_DateRanges(rawValue: 1)
public let MFBWebServiceSvc_DateRanges_YTD = MFBWebServiceSvc_DateRanges(rawValue: 2)
public let MFBWebServiceSvc_DateRanges_Tailing6Months = MFBWebServiceSvc_DateRanges(rawValue: 3)
public let MFBWebServiceSvc_DateRanges_Trailing12Months = MFBWebServiceSvc_DateRanges(rawValue: 4)
public let MFBWebServiceSvc_DateRanges_ThisMonth = MFBWebServiceSvc_DateRanges(rawValue: 5)
public let MFBWebServiceSvc_DateRanges_PrevMonth = MFBWebServiceSvc_DateRanges(rawValue: 6)
public let MFBWebServiceSvc_DateRanges_PrevYear = MFBWebServiceSvc_DateRanges(rawValue: 7)
public let MFBWebServiceSvc_DateRanges_Trailing30 = MFBWebServiceSvc_DateRanges(rawValue: 8)
public let MFBWebServiceSvc_DateRanges_Trailing90 = MFBWebServiceSvc_DateRanges(rawValue: 9)
public let MFBWebServiceSvc_DateRanges_Custom = MFBWebServiceSvc_DateRanges(rawValue: 10)

public struct MFBWebServiceSvc_FlightDistance : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_FlightDistance)] { return [
        ("AllFlights", MFBWebServiceSvc_FlightDistance_AllFlights),
        ("LocalOnly", MFBWebServiceSvc_FlightDistance_LocalOnly),
        ("NonLocalOnly", MFBWebServiceSvc_FlightDistance_NonLocalOnly)
    ] }
}
public let MFBWebServiceSvc_FlightDistance_none = MFBWebServiceSvc_FlightDistance(rawValue: 0)
public let MFBWebServiceSvc_FlightDistance_AllFlights = MFBWebServiceSvc_FlightDistance(rawValue: 1)
public let MFBWebServiceSvc_FlightDistance_LocalOnly = MFBWebServiceSvc_FlightDistance(rawValue: 2)
public let MFBWebServiceSvc_FlightDistance_NonLocalOnly = MFBWebServiceSvc_FlightDistance(rawValue: 3)

public struct MFBWebServiceSvc_CFPPropertyType : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_CFPPropertyType)] { return [
        ("cfpInteger", MFBWebServiceSvc_CFPPropertyType_cfpInteger),
        ("cfpDecimal", MFBWebServiceSvc_CFPPropertyType_cfpDecimal),
        ("cfpBoolean", MFBWebServiceSvc_CFPPropertyType_cfpBoolean),
        ("cfpDate", MFBWebServiceSvc_CFPPropertyType_cfpDate),
        ("cfpDateTime", MFBWebServiceSvc_CFPPropertyType_cfpDateTime),
        ("cfpString", MFBWebServiceSvc_CFPPropertyType_cfpString),
        ("cfpCurrency", MFBWebServiceSvc_CFPPropertyType_cfpCurrency)
    ] }
}
public let MFBWebServiceSvc_CFPPropertyType_none = MFBWebServiceSvc_CFPPropertyType(rawValue: 0)
public let MFBWebServiceSvc_CFPPropertyType_cfpInteger = MFBWebServiceSvc_CFPPropertyType(rawValue: 1)
public let MFBWebServiceSvc_CFPPropertyType_cfpDecimal = MFBWebServiceSvc_CFPPropertyType(rawValue: 2)
public let MFBWebServiceSvc_CFPPropertyType_cfpBoolean = MFBWebServiceSvc_CFPPropertyType(rawValue: 3)
public let MFBWebServiceSvc_CFPPropertyType_cfpDate = MFBWebServiceSvc_CFPPropertyType(rawValue: 4)
public let MFBWebServiceSvc_CFPPropertyType_cfpDateTime = MFBWebServiceSvc_CFPPropertyType(rawValue: 5)
public let MFBWebServiceSvc_CFPPropertyType_cfpString = MFBWebServiceSvc_CFPPropertyType(rawValue: 6)
public let MFBWebServiceSvc_CFPPropertyType_cfpCurrency = MFBWebServiceSvc_CFPPropertyType(rawValue: 7)

public struct MFBWebServiceSvc_GroupConjunction : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_GroupConjunction)] { return [
        ("Any", MFBWebServiceSvc_GroupConjunction_Any),
        ("All", MFBWebServiceSvc_GroupConjunction_All),
        ("None", MFBWebServiceSvc_GroupConjunction_None)
    ] }
}
public let MFBWebServiceSvc_GroupConjunction_none = MFBWebServiceSvc_GroupConjunction(rawValue: 0)
public let MFBWebServiceSvc_GroupConjunction_Any = MFBWebServiceSvc_GroupConjunction(rawValue: 1)
public let MFBWebServiceSvc_GroupConjunction_All = MFBWebServiceSvc_GroupConjunction(rawValue: 2)
public let MFBWebServiceSvc_GroupConjunction_None = MFBWebServiceSvc_GroupConjunction(rawValue: 3)

public struct MFBWebServiceSvc_EngineTypeRestriction : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_EngineTypeRestriction)] { return [
        ("AllEngines", MFBWebServiceSvc_EngineTypeRestriction_AllEngines),
        ("Piston", MFBWebServiceSvc_EngineTypeRestriction_Piston),
        ("Jet", MFBWebServiceSvc_EngineTypeRestriction_Jet),
        ("Turboprop", MFBWebServiceSvc_EngineTypeRestriction_Turboprop),
        ("AnyTurbine", MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine),
        ("Electric", MFBWebServiceSvc_EngineTypeRestriction_Electric)
    ] }
}
public let MFBWebServiceSvc_EngineTypeRestriction_none = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 0)
public let MFBWebServiceSvc_EngineTypeRestriction_AllEngines = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 1)
public let MFBWebServiceSvc_EngineTypeRestriction_Piston = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 2)
public let MFBWebServiceSvc_EngineTypeRestriction_Jet = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 3)
public let MFBWebServiceSvc_EngineTypeRestriction_Turboprop = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 4)
public let MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 5)
public let MFBWebServiceSvc_EngineTypeRestriction_Electric = MFBWebServiceSvc_EngineTypeRestriction(rawValue: 6)

public struct MFBWebServiceSvc_AircraftInstanceRestriction : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AircraftInstanceRestriction)] { return [
        ("AllAircraft", MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft),
        ("RealOnly", MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly),
        ("TrainingOnly", MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly)
    ] }
}
public let MFBWebServiceSvc_AircraftInstanceRestriction_none = MFBWebServiceSvc_AircraftInstanceRestriction(rawValue: 0)
public let MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft = MFBWebServiceSvc_AircraftInstanceRestriction(rawValue: 1)
public let MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly = MFBWebServiceSvc_AircraftInstanceRestriction(rawValue: 2)
public let MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly = MFBWebServiceSvc_AircraftInstanceRestriction(rawValue: 3)

public struct MFBWebServiceSvc_NumType : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_NumType)] { return [
        ("Integer", MFBWebServiceSvc_NumType_Integer),
        ("Decimal", MFBWebServiceSvc_NumType_Decimal),
        ("Time", MFBWebServiceSvc_NumType_Time),
        ("Currency", MFBWebServiceSvc_NumType_Currency)
    ] }
}
public let MFBWebServiceSvc_NumType_none = MFBWebServiceSvc_NumType(rawValue: 0)
public let MFBWebServiceSvc_NumType_Integer = MFBWebServiceSvc_NumType(rawValue: 1)
public let MFBWebServiceSvc_NumType_Decimal = MFBWebServiceSvc_NumType(rawValue: 2)
public let MFBWebServiceSvc_NumType_Time = MFBWebServiceSvc_NumType(rawValue: 3)
public let MFBWebServiceSvc_NumType_Currency = MFBWebServiceSvc_NumType(rawValue: 4)

public struct MFBWebServiceSvc_TotalsGroup : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_TotalsGroup)] { return [
        ("None", MFBWebServiceSvc_TotalsGroup_None),
        ("CategoryClass", MFBWebServiceSvc_TotalsGroup_CategoryClass),
        ("ICAO", MFBWebServiceSvc_TotalsGroup_ICAO),
        ("Model", MFBWebServiceSvc_TotalsGroup_Model),
        ("Capabilities", MFBWebServiceSvc_TotalsGroup_Capabilities),
        ("CoreFields", MFBWebServiceSvc_TotalsGroup_CoreFields),
        ("Properties", MFBWebServiceSvc_TotalsGroup_Properties),
        ("Total", MFBWebServiceSvc_TotalsGroup_Total)
    ] }
}
public let MFBWebServiceSvc_TotalsGroup_none = MFBWebServiceSvc_TotalsGroup(rawValue: 0)
public let MFBWebServiceSvc_TotalsGroup_None = MFBWebServiceSvc_TotalsGroup(rawValue: 1)
public let MFBWebServiceSvc_TotalsGroup_CategoryClass = MFBWebServiceSvc_TotalsGroup(rawValue: 2)
public let MFBWebServiceSvc_TotalsGroup_ICAO = MFBWebServiceSvc_TotalsGroup(rawValue: 3)
public let MFBWebServiceSvc_TotalsGroup_Model = MFBWebServiceSvc_TotalsGroup(rawValue: 4)
public let MFBWebServiceSvc_TotalsGroup_Capabilities = MFBWebServiceSvc_TotalsGroup(rawValue: 5)
public let MFBWebServiceSvc_TotalsGroup_CoreFields = MFBWebServiceSvc_TotalsGroup(rawValue: 6)
public let MFBWebServiceSvc_TotalsGroup_Properties = MFBWebServiceSvc_TotalsGroup(rawValue: 7)
public let MFBWebServiceSvc_TotalsGroup_Total = MFBWebServiceSvc_TotalsGroup(rawValue: 8)

public struct MFBWebServiceSvc_VideoSource : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_VideoSource)] { return [
        ("Unknown", MFBWebServiceSvc_VideoSource_Unknown),
        ("YouTube", MFBWebServiceSvc_VideoSource_YouTube),
        ("Vimeo", MFBWebServiceSvc_VideoSource_Vimeo)
    ] }
}
public let MFBWebServiceSvc_VideoSource_none = MFBWebServiceSvc_VideoSource(rawValue: 0)
public let MFBWebServiceSvc_VideoSource_Unknown = MFBWebServiceSvc_VideoSource(rawValue: 1)
public let MFBWebServiceSvc_VideoSource_YouTube = MFBWebServiceSvc_VideoSource(rawValue: 2)
public let MFBWebServiceSvc_VideoSource_Vimeo = MFBWebServiceSvc_VideoSource(rawValue: 3)

public struct MFBWebServiceSvc_SignatureState : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_SignatureState)] { return [
        ("None", MFBWebServiceSvc_SignatureState_None),
        ("Valid", MFBWebServiceSvc_SignatureState_Valid),
        ("Invalid", MFBWebServiceSvc_SignatureState_Invalid)
    ] }
}
public let MFBWebServiceSvc_SignatureState_none = MFBWebServiceSvc_SignatureState(rawValue: 0)
public let MFBWebServiceSvc_SignatureState_None = MFBWebServiceSvc_SignatureState(rawValue: 1)
public let MFBWebServiceSvc_SignatureState_Valid = MFBWebServiceSvc_SignatureState(rawValue: 2)
public let MFBWebServiceSvc_SignatureState_Invalid = MFBWebServiceSvc_SignatureState(rawValue: 3)

public struct MFBWebServiceSvc_AutoFillTotalOption : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AutoFillTotalOption)] { return [
        ("None", MFBWebServiceSvc_AutoFillTotalOption_None),
        ("FlightTime", MFBWebServiceSvc_AutoFillTotalOption_FlightTime),
        ("EngineTime", MFBWebServiceSvc_AutoFillTotalOption_EngineTime),
        ("HobbsTime", MFBWebServiceSvc_AutoFillTotalOption_HobbsTime),
        ("BlockTime", MFBWebServiceSvc_AutoFillTotalOption_BlockTime)
    ] }
}
public let MFBWebServiceSvc_AutoFillTotalOption_none = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 0)
public let MFBWebServiceSvc_AutoFillTotalOption_None = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 1)
public let MFBWebServiceSvc_AutoFillTotalOption_FlightTime = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 2)
public let MFBWebServiceSvc_AutoFillTotalOption_EngineTime = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 3)
public let MFBWebServiceSvc_AutoFillTotalOption_HobbsTime = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 4)
public let MFBWebServiceSvc_AutoFillTotalOption_BlockTime = MFBWebServiceSvc_AutoFillTotalOption(rawValue: 5)

public struct MFBWebServiceSvc_AutoFillHobbsOption : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AutoFillHobbsOption)] { return [
        ("None", MFBWebServiceSvc_AutoFillHobbsOption_None),
        ("FlightTime", MFBWebServiceSvc_AutoFillHobbsOption_FlightTime),
        ("EngineTime", MFBWebServiceSvc_AutoFillHobbsOption_EngineTime),
        ("TotalTime", MFBWebServiceSvc_AutoFillHobbsOption_TotalTime)
    ] }
}
public let MFBWebServiceSvc_AutoFillHobbsOption_none = MFBWebServiceSvc_AutoFillHobbsOption(rawValue: 0)
public let MFBWebServiceSvc_AutoFillHobbsOption_None = MFBWebServiceSvc_AutoFillHobbsOption(rawValue: 1)
public let MFBWebServiceSvc_AutoFillHobbsOption_FlightTime = MFBWebServiceSvc_AutoFillHobbsOption(rawValue: 2)
public let MFBWebServiceSvc_AutoFillHobbsOption_EngineTime = MFBWebServiceSvc_AutoFillHobbsOption(rawValue: 3)
public let MFBWebServiceSvc_AutoFillHobbsOption_TotalTime = MFBWebServiceSvc_AutoFillHobbsOption(rawValue: 4)

public struct MFBWebServiceSvc_NightCritera : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_NightCritera)] { return [
        ("EndOfCivilTwilight", MFBWebServiceSvc_NightCritera_EndOfCivilTwilight),
        ("Sunset", MFBWebServiceSvc_NightCritera_Sunset),
        ("SunsetPlus15", MFBWebServiceSvc_NightCritera_SunsetPlus15),
        ("SunsetPlus30", MFBWebServiceSvc_NightCritera_SunsetPlus30),
        ("SunsetPlus60", MFBWebServiceSvc_NightCritera_SunsetPlus60)
    ] }
}
public let MFBWebServiceSvc_NightCritera_none = MFBWebServiceSvc_NightCritera(rawValue: 0)
public let MFBWebServiceSvc_NightCritera_EndOfCivilTwilight = MFBWebServiceSvc_NightCritera(rawValue: 1)
public let MFBWebServiceSvc_NightCritera_Sunset = MFBWebServiceSvc_NightCritera(rawValue: 2)
public let MFBWebServiceSvc_NightCritera_SunsetPlus15 = MFBWebServiceSvc_NightCritera(rawValue: 3)
public let MFBWebServiceSvc_NightCritera_SunsetPlus30 = MFBWebServiceSvc_NightCritera(rawValue: 4)
public let MFBWebServiceSvc_NightCritera_SunsetPlus60 = MFBWebServiceSvc_NightCritera(rawValue: 5)

public struct MFBWebServiceSvc_NightLandingCriteria : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_NightLandingCriteria)] { return [
        ("SunsetPlus60", MFBWebServiceSvc_NightLandingCriteria_SunsetPlus60),
        ("Night", MFBWebServiceSvc_NightLandingCriteria_Night)
    ] }
}
public let MFBWebServiceSvc_NightLandingCriteria_none = MFBWebServiceSvc_NightLandingCriteria(rawValue: 0)
public let MFBWebServiceSvc_NightLandingCriteria_SunsetPlus60 = MFBWebServiceSvc_NightLandingCriteria(rawValue: 1)
public let MFBWebServiceSvc_NightLandingCriteria_Night = MFBWebServiceSvc_NightLandingCriteria(rawValue: 2)

public struct MFBWebServiceSvc_AuthStatus : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_AuthStatus)] { return [
        ("Failed", MFBWebServiceSvc_AuthStatus_Failed),
        ("TwoFactorCodeRequired", MFBWebServiceSvc_AuthStatus_TwoFactorCodeRequired),
        ("Success", MFBWebServiceSvc_AuthStatus_Success)
    ] }
}
public let MFBWebServiceSvc_AuthStatus_none = MFBWebServiceSvc_AuthStatus(rawValue: 0)
public let MFBWebServiceSvc_AuthStatus_Failed = MFBWebServiceSvc_AuthStatus(rawValue: 1)
public let MFBWebServiceSvc_AuthStatus_TwoFactorCodeRequired = MFBWebServiceSvc_AuthStatus(rawValue: 2)
public let MFBWebServiceSvc_AuthStatus_Success = MFBWebServiceSvc_AuthStatus(rawValue: 3)

public struct MFBWebServiceSvc_MembershipCreateStatus : SoapEnum {
    public var rawValue : UInt32
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ rawValue: UInt32) { self.rawValue = rawValue }
    public static var soapValues : [(String, MFBWebServiceSvc_MembershipCreateStatus)] { return [
        ("Success", MFBWebServiceSvc_MembershipCreateStatus_Success),
        ("InvalidUserName", MFBWebServiceSvc_MembershipCreateStatus_InvalidUserName),
        ("InvalidPassword", MFBWebServiceSvc_MembershipCreateStatus_InvalidPassword),
        ("InvalidQuestion", MFBWebServiceSvc_MembershipCreateStatus_InvalidQuestion),
        ("InvalidAnswer", MFBWebServiceSvc_MembershipCreateStatus_InvalidAnswer),
        ("InvalidEmail", MFBWebServiceSvc_MembershipCreateStatus_InvalidEmail),
        ("DuplicateUserName", MFBWebServiceSvc_MembershipCreateStatus_DuplicateUserName),
        ("DuplicateEmail", MFBWebServiceSvc_MembershipCreateStatus_DuplicateEmail),
        ("UserRejected", MFBWebServiceSvc_MembershipCreateStatus_UserRejected),
        ("InvalidProviderUserKey", MFBWebServiceSvc_MembershipCreateStatus_InvalidProviderUserKey),
        ("DuplicateProviderUserKey", MFBWebServiceSvc_MembershipCreateStatus_DuplicateProviderUserKey),
        ("ProviderError", MFBWebServiceSvc_MembershipCreateStatus_ProviderError)
    ] }
}
public let MFBWebServiceSvc_MembershipCreateStatus_none = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 0)
public let MFBWebServiceSvc_MembershipCreateStatus_Success = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 1)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidUserName = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 2)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidPassword = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 3)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidQuestion = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 4)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidAnswer = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 5)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidEmail = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 6)
public let MFBWebServiceSvc_MembershipCreateStatus_DuplicateUserName = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 7)
public let MFBWebServiceSvc_MembershipCreateStatus_DuplicateEmail = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 8)
public let MFBWebServiceSvc_MembershipCreateStatus_UserRejected = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 9)
public let MFBWebServiceSvc_MembershipCreateStatus_InvalidProviderUserKey = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 10)
public let MFBWebServiceSvc_MembershipCreateStatus_DuplicateProviderUserKey = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 11)
public let MFBWebServiceSvc_MembershipCreateStatus_ProviderError = MFBWebServiceSvc_MembershipCreateStatus(rawValue: 12)

// MARK: - Data structures

// MARK: ArrayOfAircraft
/// WSDL type `ArrayOfAircraft`
@objc(MFBWebServiceSvc_ArrayOfAircraft)
public class MFBWebServiceSvc_ArrayOfAircraft : SoapObject {
    public var aircraft : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_Aircraft?) {
        if let o = toAdd { aircraft.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfAircraft>()
        return super.soapFields + [
            f.objects("Aircraft", \.aircraft, of: MFBWebServiceSvc_Aircraft.self)
        ]
    }
}

// MARK: Aircraft
/// WSDL type `Aircraft`
@objc(MFBWebServiceSvc_Aircraft)
public class MFBWebServiceSvc_Aircraft : SoapObject {
    public var instanceTypeID : NSNumber!
    public var instanceType = MFBWebServiceSvc_AircraftInstanceTypes_none
    public var instanceTypeDescription : String!
    public var lastVOR : Date!
    public var lastAltimeter : Date!
    public var lastTransponder : Date!
    public var lastELT : Date!
    public var lastStatic : Date!
    public var last100 : NSNumber!
    public var lastOilChange : NSNumber!
    public var lastNewEngine : NSNumber!
    public var lastAnnual : Date!
    public var isGlass : USBoolean!
    public var aircraftImages : MFBWebServiceSvc_ArrayOfMFBImageInfo!
    public var aircraftID : NSNumber!
    public var modelCommonName : String!
    public var tailNumber : String!
    public var modelID : NSNumber!
    public var modelDescription : String!
    public var errorString : String!
    public var hideFromSelection : USBoolean!
    public var version : NSNumber!
    public var defaultImage : String!
    public var roleForPilot = MFBWebServiceSvc_PilotRole_none
    public var copyPICNameWithCrossfill : USBoolean!
    public var registrationDue : Date!
    public var publicNotes : String!
    public var privateNotes : String!
    public var defaultTemplates : MFBWebServiceSvc_ArrayOfInt!
    public var icao : String!
    public var glassUpgradeDate : Date!
    public var avionicsTechnologyUpgrade = MFBWebServiceSvc_AvionicsTechnologyType_none
    public var maintenanceNote : String!
    public var revision : NSNumber!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_Aircraft>()
        return super.soapFields + [
            f.number("InstanceTypeID", \.instanceTypeID),
            f.enumeration("InstanceType", \.instanceType),
            f.string("InstanceTypeDescription", \.instanceTypeDescription),
            f.date("LastVOR", \.lastVOR),
            f.date("LastAltimeter", \.lastAltimeter),
            f.date("LastTransponder", \.lastTransponder),
            f.date("LastELT", \.lastELT),
            f.date("LastStatic", \.lastStatic),
            f.number("Last100", \.last100),
            f.number("LastOilChange", \.lastOilChange),
            f.number("LastNewEngine", \.lastNewEngine),
            f.date("LastAnnual", \.lastAnnual),
            f.bool("IsGlass", \.isGlass),
            f.object("AircraftImages", \.aircraftImages),
            f.number("AircraftID", \.aircraftID),
            f.string("ModelCommonName", \.modelCommonName),
            f.string("TailNumber", \.tailNumber),
            f.number("ModelID", \.modelID),
            f.string("ModelDescription", \.modelDescription),
            f.string("ErrorString", \.errorString),
            f.bool("HideFromSelection", \.hideFromSelection),
            f.number("Version", \.version),
            f.string("DefaultImage", \.defaultImage),
            f.enumeration("RoleForPilot", \.roleForPilot),
            f.bool("CopyPICNameWithCrossfill", \.copyPICNameWithCrossfill),
            f.date("RegistrationDue", \.registrationDue),
            f.string("PublicNotes", \.publicNotes),
            f.string("PrivateNotes", \.privateNotes),
            f.object("DefaultTemplates", \.defaultTemplates),
            f.string("ICAO", \.icao),
            f.date("GlassUpgradeDate", \.glassUpgradeDate),
            f.enumeration("AvionicsTechnologyUpgrade", \.avionicsTechnologyUpgrade),
            f.string("MaintenanceNote", \.maintenanceNote),
            f.number("Revision", \.revision)
        ]
    }
}

// MARK: ArrayOfMFBImageInfo
/// WSDL type `ArrayOfMFBImageInfo`
@objc(MFBWebServiceSvc_ArrayOfMFBImageInfo)
public class MFBWebServiceSvc_ArrayOfMFBImageInfo : SoapObject {
    public var mfbImageInfo : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_MFBImageInfo?) {
        if let o = toAdd { mfbImageInfo.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfMFBImageInfo>()
        return super.soapFields + [
            f.objects("MFBImageInfo", \.mfbImageInfo, of: MFBWebServiceSvc_MFBImageInfo.self)
        ]
    }
}

// MARK: MFBImageInfo
/// WSDL type `MFBImageInfo` (extends `MFBImageInfoBase`)
@objc(MFBWebServiceSvc_MFBImageInfo)
public class MFBWebServiceSvc_MFBImageInfo : MFBWebServiceSvc_MFBImageInfoBase {
    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

}

// MARK: MFBImageInfoBase
/// WSDL type `MFBImageInfoBase`
@objc(MFBWebServiceSvc_MFBImageInfoBase)
public class MFBWebServiceSvc_MFBImageInfoBase : SoapObject {
    public var width : NSNumber!
    public var height : NSNumber!
    public var widthThumbnail : NSNumber!
    public var heightThumbnail : NSNumber!
    public var imageType = MFBWebServiceSvc_ImageFileType_none
    public var comment : String!
    public var virtualPath : String!
    public var thumbnailFile : String!
    public var location : MFBWebServiceSvc_LatLong!
    public var urlFullImage : String!
    public var urlThumbnail : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_MFBImageInfoBase>()
        return super.soapFields + [
            f.number("Width", \.width),
            f.number("Height", \.height),
            f.number("WidthThumbnail", \.widthThumbnail),
            f.number("HeightThumbnail", \.heightThumbnail),
            f.enumeration("ImageType", \.imageType),
            f.string("Comment", \.comment),
            f.string("VirtualPath", \.virtualPath),
            f.string("ThumbnailFile", \.thumbnailFile),
            f.object("Location", \.location),
            f.string("URLFullImage", \.urlFullImage),
            f.string("URLThumbnail", \.urlThumbnail)
        ]
    }
}

// MARK: LatLong
/// WSDL type `LatLong`
@objc(MFBWebServiceSvc_LatLong)
public class MFBWebServiceSvc_LatLong : SoapObject {
    public var latitude : NSNumber!
    public var longitude : NSNumber!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_LatLong>()
        return super.soapFields + [
            f.number("Latitude", \.latitude),
            f.number("Longitude", \.longitude)
        ]
    }
}

// MARK: ArrayOfInt
/// WSDL type `ArrayOfInt`
@objc(MFBWebServiceSvc_ArrayOfInt)
public class MFBWebServiceSvc_ArrayOfInt : SoapObject {
    public var int_ : NSMutableArray! = NSMutableArray()

    public func addInt_(_ toAdd : NSNumber?) {
        if let o = toAdd { int_.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfInt>()
        return super.soapFields + [
            f.numbers("int", \.int_, key: "int_")
        ]
    }
}

// MARK: ArrayOfSimpleMakeModel
/// WSDL type `ArrayOfSimpleMakeModel`
@objc(MFBWebServiceSvc_ArrayOfSimpleMakeModel)
public class MFBWebServiceSvc_ArrayOfSimpleMakeModel : SoapObject {
    public var simpleMakeModel : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_SimpleMakeModel?) {
        if let o = toAdd { simpleMakeModel.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfSimpleMakeModel>()
        return super.soapFields + [
            f.objects("SimpleMakeModel", \.simpleMakeModel, of: MFBWebServiceSvc_SimpleMakeModel.self)
        ]
    }
}

// MARK: SimpleMakeModel
/// WSDL type `SimpleMakeModel`
@objc(MFBWebServiceSvc_SimpleMakeModel)
public class MFBWebServiceSvc_SimpleMakeModel : SoapObject {
    public var modelID : NSNumber!
    public var descriptionText : String!
    public override var description : String {
        get { return descriptionText ?? "" }
        set { descriptionText = newValue }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_SimpleMakeModel>()
        return super.soapFields + [
            f.number("ModelID", \.modelID),
            f.string("Description", \.descriptionText)
        ]
    }
}

// MARK: ArrayOfMakeModel
/// WSDL type `ArrayOfMakeModel`
@objc(MFBWebServiceSvc_ArrayOfMakeModel)
public class MFBWebServiceSvc_ArrayOfMakeModel : SoapObject {
    public var makeModel : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_MakeModel?) {
        if let o = toAdd { makeModel.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfMakeModel>()
        return super.soapFields + [
            f.objects("MakeModel", \.makeModel, of: MFBWebServiceSvc_MakeModel.self)
        ]
    }
}

// MARK: MakeModel
/// WSDL type `MakeModel`
@objc(MFBWebServiceSvc_MakeModel)
public class MFBWebServiceSvc_MakeModel : SoapObject {
    public var allowedTypes = MFBWebServiceSvc_AllowedAircraftTypes_none
    public var categoryClassDisplay : String!
    public var manufacturerDisplay : String!
    public var avionicsTechnology = MFBWebServiceSvc_AvionicsTechnologyType_none
    public var armyMDS : String!
    public var errorString : String!
    public var makeModelID : NSNumber!
    public var model : String!
    public var modelName : String!
    public var typeName : String!
    public var familyName : String!
    public var categoryClassID = MFBWebServiceSvc_CatClassID_none
    public var manufacturerID : NSNumber!
    public var isComplex : USBoolean!
    public var isHighPerf : USBoolean!
    public var is200HP : USBoolean!
    public var performanceType = MFBWebServiceSvc_HighPerfType_none
    public var isTailWheel : USBoolean!
    public var isConstantProp : USBoolean!
    public var hasFlaps : USBoolean!
    public var isRetract : USBoolean!
    public var engineType = MFBWebServiceSvc_TurbineLevel_none
    public var isCertifiedSinglePilot : USBoolean!
    public var isMotorGlider : USBoolean!
    public var isMultiEngineHelicopter : USBoolean!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_MakeModel>()
        return super.soapFields + [
            f.enumeration("AllowedTypes", \.allowedTypes),
            f.string("CategoryClassDisplay", \.categoryClassDisplay),
            f.string("ManufacturerDisplay", \.manufacturerDisplay),
            f.enumeration("AvionicsTechnology", \.avionicsTechnology),
            f.string("ArmyMDS", \.armyMDS),
            f.string("ErrorString", \.errorString),
            f.number("MakeModelID", \.makeModelID),
            f.string("Model", \.model),
            f.string("ModelName", \.modelName),
            f.string("TypeName", \.typeName),
            f.string("FamilyName", \.familyName),
            f.enumeration("CategoryClassID", \.categoryClassID),
            f.number("ManufacturerID", \.manufacturerID),
            f.bool("IsComplex", \.isComplex),
            f.bool("IsHighPerf", \.isHighPerf),
            f.bool("Is200HP", \.is200HP),
            f.enumeration("PerformanceType", \.performanceType),
            f.bool("IsTailWheel", \.isTailWheel),
            f.bool("IsConstantProp", \.isConstantProp),
            f.bool("HasFlaps", \.hasFlaps),
            f.bool("IsRetract", \.isRetract),
            f.enumeration("EngineType", \.engineType),
            f.bool("IsCertifiedSinglePilot", \.isCertifiedSinglePilot),
            f.bool("IsMotorGlider", \.isMotorGlider),
            f.bool("IsMultiEngineHelicopter", \.isMultiEngineHelicopter)
        ]
    }
}

// MARK: ArrayOfCurrencyStatusItem
/// WSDL type `ArrayOfCurrencyStatusItem`
@objc(MFBWebServiceSvc_ArrayOfCurrencyStatusItem)
public class MFBWebServiceSvc_ArrayOfCurrencyStatusItem : SoapObject {
    public var currencyStatusItem : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_CurrencyStatusItem?) {
        if let o = toAdd { currencyStatusItem.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfCurrencyStatusItem>()
        return super.soapFields + [
            f.objects("CurrencyStatusItem", \.currencyStatusItem, of: MFBWebServiceSvc_CurrencyStatusItem.self)
        ]
    }
}

// MARK: CurrencyStatusItem
/// WSDL type `CurrencyStatusItem` (extends `CurrencyStatusItemBase`)
@objc(MFBWebServiceSvc_CurrencyStatusItem)
public class MFBWebServiceSvc_CurrencyStatusItem : MFBWebServiceSvc_CurrencyStatusItemBase {
    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

}

// MARK: CurrencyStatusItemBase
/// WSDL type `CurrencyStatusItemBase`
@objc(MFBWebServiceSvc_CurrencyStatusItemBase)
public class MFBWebServiceSvc_CurrencyStatusItemBase : SoapObject {
    public var attribute : String!
    public var value : String!
    public var status = MFBWebServiceSvc_CurrencyState_none
    public var discrepancy : String!
    public var associatedResourceID : NSNumber!
    public var currencyGroup = MFBWebServiceSvc_CurrencyGroups_none
    public var query : MFBWebServiceSvc_FlightQuery!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CurrencyStatusItemBase>()
        return super.soapFields + [
            f.string("Attribute", \.attribute),
            f.string("Value", \.value),
            f.enumeration("Status", \.status),
            f.string("Discrepancy", \.discrepancy),
            f.number("AssociatedResourceID", \.associatedResourceID),
            f.enumeration("CurrencyGroup", \.currencyGroup),
            f.object("Query", \.query)
        ]
    }
}

// MARK: FlightQuery
/// WSDL type `FlightQuery`
@objc(MFBWebServiceSvc_FlightQuery)
public class MFBWebServiceSvc_FlightQuery : SoapObject {
    public var dateRange = MFBWebServiceSvc_DateRanges_none
    public var distance = MFBWebServiceSvc_FlightDistance_none
    public var catClasses : MFBWebServiceSvc_ArrayOfCategoryClass!
    public var propertyTypes : MFBWebServiceSvc_ArrayOfCustomPropertyType!
    public var propertiesConjunction = MFBWebServiceSvc_GroupConjunction_none
    public var userName : String!
    public var isPublic : USBoolean!
    public var flightCharacteristicsConjunction = MFBWebServiceSvc_GroupConjunction_none
    public var hasNightLandings : USBoolean!
    public var hasFullStopLandings : USBoolean!
    public var hasLandings : USBoolean!
    public var hasApproaches : USBoolean!
    public var hasHolds : USBoolean!
    public var hasXC : USBoolean!
    public var hasSimIMCTime : USBoolean!
    public var hasGroundSim : USBoolean!
    public var hasIMC : USBoolean!
    public var hasAnyInstrument : USBoolean!
    public var hasNight : USBoolean!
    public var hasDual : USBoolean!
    public var hasCFI : USBoolean!
    public var hasSIC : USBoolean!
    public var hasPIC : USBoolean!
    public var hasTotalTime : USBoolean!
    public var isSigned : USBoolean!
    public var dateMin : Date!
    public var dateMax : Date!
    public var generalText : String!
    public var aircraftList : MFBWebServiceSvc_ArrayOfAircraft!
    public var airportList : MFBWebServiceSvc_ArrayOfString!
    public var makeList : MFBWebServiceSvc_ArrayOfMakeModel!
    public var modelName : String!
    public var typeNames : MFBWebServiceSvc_ArrayOfString!
    public var isComplex : USBoolean!
    public var hasFlaps : USBoolean!
    public var isHighPerformance : USBoolean!
    public var isConstantSpeedProp : USBoolean!
    public var isRetract : USBoolean!
    public var isTechnicallyAdvanced : USBoolean!
    public var isGlass : USBoolean!
    public var isTailwheel : USBoolean!
    public var engineType = MFBWebServiceSvc_EngineTypeRestriction_none
    public var isMultiEngineHeli : USBoolean!
    public var isTurbine : USBoolean!
    public var hasTelemetry : USBoolean!
    public var hasImages : USBoolean!
    public var isMotorglider : USBoolean!
    public var aircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_none

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightQuery>()
        return super.soapFields + [
            f.enumeration("DateRange", \.dateRange),
            f.enumeration("Distance", \.distance),
            f.object("CatClasses", \.catClasses),
            f.object("PropertyTypes", \.propertyTypes),
            f.enumeration("PropertiesConjunction", \.propertiesConjunction),
            f.string("UserName", \.userName),
            f.bool("IsPublic", \.isPublic),
            f.enumeration("FlightCharacteristicsConjunction", \.flightCharacteristicsConjunction),
            f.bool("HasNightLandings", \.hasNightLandings),
            f.bool("HasFullStopLandings", \.hasFullStopLandings),
            f.bool("HasLandings", \.hasLandings),
            f.bool("HasApproaches", \.hasApproaches),
            f.bool("HasHolds", \.hasHolds),
            f.bool("HasXC", \.hasXC),
            f.bool("HasSimIMCTime", \.hasSimIMCTime),
            f.bool("HasGroundSim", \.hasGroundSim),
            f.bool("HasIMC", \.hasIMC),
            f.bool("HasAnyInstrument", \.hasAnyInstrument),
            f.bool("HasNight", \.hasNight),
            f.bool("HasDual", \.hasDual),
            f.bool("HasCFI", \.hasCFI),
            f.bool("HasSIC", \.hasSIC),
            f.bool("HasPIC", \.hasPIC),
            f.bool("HasTotalTime", \.hasTotalTime),
            f.bool("IsSigned", \.isSigned),
            f.date("DateMin", \.dateMin),
            f.date("DateMax", \.dateMax),
            f.string("GeneralText", \.generalText),
            f.object("AircraftList", \.aircraftList),
            f.object("AirportList", \.airportList),
            f.object("MakeList", \.makeList),
            f.string("ModelName", \.modelName),
            f.object("TypeNames", \.typeNames),
            f.bool("IsComplex", \.isComplex),
            f.bool("HasFlaps", \.hasFlaps),
            f.bool("IsHighPerformance", \.isHighPerformance),
            f.bool("IsConstantSpeedProp", \.isConstantSpeedProp),
            f.bool("IsRetract", \.isRetract),
            f.bool("IsTechnicallyAdvanced", \.isTechnicallyAdvanced),
            f.bool("IsGlass", \.isGlass),
            f.bool("IsTailwheel", \.isTailwheel),
            f.enumeration("EngineType", \.engineType),
            f.bool("IsMultiEngineHeli", \.isMultiEngineHeli),
            f.bool("IsTurbine", \.isTurbine),
            f.bool("HasTelemetry", \.hasTelemetry),
            f.bool("HasImages", \.hasImages),
            f.bool("IsMotorglider", \.isMotorglider),
            f.enumeration("AircraftInstanceTypes", \.aircraftInstanceTypes)
        ]
    }
}

// MARK: ArrayOfCategoryClass
/// WSDL type `ArrayOfCategoryClass`
@objc(MFBWebServiceSvc_ArrayOfCategoryClass)
public class MFBWebServiceSvc_ArrayOfCategoryClass : SoapObject {
    public var categoryClass : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_CategoryClass?) {
        if let o = toAdd { categoryClass.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfCategoryClass>()
        return super.soapFields + [
            f.objects("CategoryClass", \.categoryClass, of: MFBWebServiceSvc_CategoryClass.self)
        ]
    }
}

// MARK: CategoryClass
/// WSDL type `CategoryClass`
@objc(MFBWebServiceSvc_CategoryClass)
public class MFBWebServiceSvc_CategoryClass : SoapObject {
    public var catClass : String!
    public var category_ : String!
    public var class_ : String!
    public var altCatClass : NSNumber!
    public var idCatClass = MFBWebServiceSvc_CatClassID_none

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CategoryClass>()
        return super.soapFields + [
            f.string("CatClass", \.catClass),
            f.string("Category", \.category_, key: "Category_"),
            f.string("Class", \.class_, key: "Class_"),
            f.number("AltCatClass", \.altCatClass),
            f.enumeration("IdCatClass", \.idCatClass)
        ]
    }
}

// MARK: ArrayOfCustomPropertyType
/// WSDL type `ArrayOfCustomPropertyType`
@objc(MFBWebServiceSvc_ArrayOfCustomPropertyType)
public class MFBWebServiceSvc_ArrayOfCustomPropertyType : SoapObject {
    public var customPropertyType : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_CustomPropertyType?) {
        if let o = toAdd { customPropertyType.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfCustomPropertyType>()
        return super.soapFields + [
            f.objects("CustomPropertyType", \.customPropertyType, of: MFBWebServiceSvc_CustomPropertyType.self)
        ]
    }
}

// MARK: CustomPropertyType
/// WSDL type `CustomPropertyType`
@objc(MFBWebServiceSvc_CustomPropertyType)
public class MFBWebServiceSvc_CustomPropertyType : SoapObject {
    public var propTypeID : NSNumber!
    public var title : String!
    public var sortKey : String!
    public var isFavorite : USBoolean!
    public var formatString : String!
    public var type = MFBWebServiceSvc_CFPPropertyType_none
    public var descriptionText : String!
    public override var description : String {
        get { return descriptionText ?? "" }
        set { descriptionText = newValue }
    }
    public var flags : NSNumber!
    public var previousValues : MFBWebServiceSvc_ArrayOfString!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CustomPropertyType>()
        return super.soapFields + [
            f.number("PropTypeID", \.propTypeID),
            f.string("Title", \.title),
            f.string("SortKey", \.sortKey),
            f.bool("IsFavorite", \.isFavorite),
            f.string("FormatString", \.formatString),
            f.enumeration("Type", \.type),
            f.string("Description", \.descriptionText),
            f.number("Flags", \.flags),
            f.object("PreviousValues", \.previousValues)
        ]
    }
}

// MARK: ArrayOfString
/// WSDL type `ArrayOfString`
@objc(MFBWebServiceSvc_ArrayOfString)
public class MFBWebServiceSvc_ArrayOfString : SoapObject {
    public var string : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : String?) {
        if let o = toAdd { string.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfString>()
        return super.soapFields + [
            f.strings("string", \.string)
        ]
    }
}

// MARK: ArrayOfTotalsItem
/// WSDL type `ArrayOfTotalsItem`
@objc(MFBWebServiceSvc_ArrayOfTotalsItem)
public class MFBWebServiceSvc_ArrayOfTotalsItem : SoapObject {
    public var totalsItem : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_TotalsItem?) {
        if let o = toAdd { totalsItem.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfTotalsItem>()
        return super.soapFields + [
            f.objects("TotalsItem", \.totalsItem, of: MFBWebServiceSvc_TotalsItem.self)
        ]
    }
}

// MARK: TotalsItem
/// WSDL type `TotalsItem`
@objc(MFBWebServiceSvc_TotalsItem)
public class MFBWebServiceSvc_TotalsItem : SoapObject {
    public var value : NSNumber!
    public var descriptionText : String!
    public override var description : String {
        get { return descriptionText ?? "" }
        set { descriptionText = newValue }
    }
    public var subDescription : String!
    public var numericType = MFBWebServiceSvc_NumType_none
    public var isInt : USBoolean!
    public var isTime : USBoolean!
    public var isCurrency : USBoolean!
    public var query : MFBWebServiceSvc_FlightQuery!
    public var group = MFBWebServiceSvc_TotalsGroup_none
    public var groupName : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TotalsItem>()
        return super.soapFields + [
            f.number("Value", \.value),
            f.string("Description", \.descriptionText),
            f.string("SubDescription", \.subDescription),
            f.enumeration("NumericType", \.numericType),
            f.bool("IsInt", \.isInt),
            f.bool("IsTime", \.isTime),
            f.bool("IsCurrency", \.isCurrency),
            f.object("Query", \.query),
            f.enumeration("Group", \.group),
            f.string("GroupName", \.groupName)
        ]
    }
}

// MARK: ArrayOfVisitedAirport
/// WSDL type `ArrayOfVisitedAirport`
@objc(MFBWebServiceSvc_ArrayOfVisitedAirport)
public class MFBWebServiceSvc_ArrayOfVisitedAirport : SoapObject {
    public var visitedAirport : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_VisitedAirport?) {
        if let o = toAdd { visitedAirport.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfVisitedAirport>()
        return super.soapFields + [
            f.objects("VisitedAirport", \.visitedAirport, of: MFBWebServiceSvc_VisitedAirport.self)
        ]
    }
}

// MARK: VisitedAirport
/// WSDL type `VisitedAirport`
@objc(MFBWebServiceSvc_VisitedAirport)
public class MFBWebServiceSvc_VisitedAirport : SoapObject {
    public var code : String!
    public var aliases : String!
    public var airport : MFBWebServiceSvc_airport!
    public var earliestVisitDate : Date!
    public var latestVisitDate : Date!
    public var numberOfVisits : NSNumber!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_VisitedAirport>()
        return super.soapFields + [
            f.string("Code", \.code),
            f.string("Aliases", \.aliases),
            f.object("Airport", \.airport),
            f.date("EarliestVisitDate", \.earliestVisitDate),
            f.date("LatestVisitDate", \.latestVisitDate),
            f.number("NumberOfVisits", \.numberOfVisits)
        ]
    }
}

// MARK: airport
/// WSDL type `airport`
@objc(MFBWebServiceSvc_airport)
public class MFBWebServiceSvc_airport : SoapObject {
    public var distanceFromPosition : NSNumber!
    public var userName : String!
    public var facilityTypeCode : String!
    public var facilityType : String!
    public var code : String!
    public var name : String!
    public var country : String!
    public var admin1 : String!
    public var latLong : MFBWebServiceSvc_LatLong!
    public var latitude : String!
    public var longitude : String!
    public var errorText : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_airport>()
        return super.soapFields + [
            f.number("DistanceFromPosition", \.distanceFromPosition),
            f.string("UserName", \.userName),
            f.string("FacilityTypeCode", \.facilityTypeCode),
            f.string("FacilityType", \.facilityType),
            f.string("Code", \.code),
            f.string("Name", \.name),
            f.string("Country", \.country),
            f.string("Admin1", \.admin1),
            f.object("LatLong", \.latLong),
            f.string("Latitude", \.latitude),
            f.string("Longitude", \.longitude),
            f.string("ErrorText", \.errorText)
        ]
    }
}

// MARK: ArrayOfLogbookEntry
/// WSDL type `ArrayOfLogbookEntry`
@objc(MFBWebServiceSvc_ArrayOfLogbookEntry)
public class MFBWebServiceSvc_ArrayOfLogbookEntry : SoapObject {
    public var logbookEntry : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_LogbookEntry?) {
        if let o = toAdd { logbookEntry.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfLogbookEntry>()
        return super.soapFields + [
            f.objects("LogbookEntry", \.logbookEntry, of: MFBWebServiceSvc_LogbookEntry.self)
        ]
    }
}

// MARK: LogbookEntry
/// WSDL type `LogbookEntry` (extends `LogbookEntryBase`)
@objc(MFBWebServiceSvc_LogbookEntry)
public class MFBWebServiceSvc_LogbookEntry : MFBWebServiceSvc_LogbookEntryBase {
    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

}

// MARK: LogbookEntryBase
/// WSDL type `LogbookEntryBase` (extends `LogbookEntryCore`)
@objc(MFBWebServiceSvc_LogbookEntryBase)
public class MFBWebServiceSvc_LogbookEntryBase : MFBWebServiceSvc_LogbookEntryCore {
    public var cfiComments : String!
    public var cfiSignatureDate : Date!
    public var cfiCertificate : String!
    public var cfiExpiration : Date!
    public var cfiEmail : String!
    public var cfiName : String!
    public var cfiSignatureState = MFBWebServiceSvc_SignatureState_none
    public var hasDigitizedSig : USBoolean!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_LogbookEntryBase>()
        return super.soapFields + [
            f.string("CFIComments", \.cfiComments),
            f.date("CFISignatureDate", \.cfiSignatureDate),
            f.string("CFICertificate", \.cfiCertificate),
            f.date("CFIExpiration", \.cfiExpiration),
            f.string("CFIEmail", \.cfiEmail),
            f.string("CFIName", \.cfiName),
            f.enumeration("CFISignatureState", \.cfiSignatureState),
            f.bool("HasDigitizedSig", \.hasDigitizedSig)
        ]
    }
}

// MARK: LogbookEntryCore
/// WSDL type `LogbookEntryCore`
@objc(MFBWebServiceSvc_LogbookEntryCore)
public class MFBWebServiceSvc_LogbookEntryCore : SoapObject {
    public var user : String!
    public var aircraftID : NSNumber!
    public var catClassOverride : NSNumber!
    public var nightLandings : NSNumber!
    public var fullStopLandings : NSNumber!
    public var approaches : NSNumber!
    public var precisionApproaches : NSNumber!
    public var nonPrecisionApproaches : NSNumber!
    public var landings : NSNumber!
    public var crossCountry : NSNumber!
    public var nighttime : NSNumber!
    public var imc : NSNumber!
    public var simulatedIFR : NSNumber!
    public var groundSim : NSNumber!
    public var dual : NSNumber!
    public var cfi : NSNumber!
    public var pic : NSNumber!
    public var sic : NSNumber!
    public var totalFlightTime : NSNumber!
    public var fHoldingProcedures : USBoolean!
    public var route : String!
    public var comment : String!
    public var fIsPublic : USBoolean!
    public var date : Date!
    public var isOverridden : USBoolean!
    public var flightColorHex : String!
    public var errorString : String!
    public var flightID : NSNumber!
    public var flightStart : Date!
    public var flightEnd : Date!
    public var engineStart : Date!
    public var engineEnd : Date!
    public var hobbsStart : NSNumber!
    public var hobbsEnd : NSNumber!
    public var modelDisplay : String!
    public var tailNumDisplay : String!
    public var catClassDisplay : String!
    public var flightData : String!
    public var customProperties : MFBWebServiceSvc_ArrayOfCustomFlightProperty!
    public var flightImages : MFBWebServiceSvc_ArrayOfMFBImageInfo!
    public var videos : MFBWebServiceSvc_ArrayOfVideoRef!
    public var sendFlightLink : String!
    public var socialMediaLink : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_LogbookEntryCore>()
        return super.soapFields + [
            f.string("User", \.user),
            f.number("AircraftID", \.aircraftID),
            f.number("CatClassOverride", \.catClassOverride),
            f.number("NightLandings", \.nightLandings),
            f.number("FullStopLandings", \.fullStopLandings),
            f.number("Approaches", \.approaches),
            f.number("PrecisionApproaches", \.precisionApproaches),
            f.number("NonPrecisionApproaches", \.nonPrecisionApproaches),
            f.number("Landings", \.landings),
            f.number("CrossCountry", \.crossCountry),
            f.number("Nighttime", \.nighttime),
            f.number("IMC", \.imc),
            f.number("SimulatedIFR", \.simulatedIFR),
            f.number("GroundSim", \.groundSim),
            f.number("Dual", \.dual),
            f.number("CFI", \.cfi),
            f.number("PIC", \.pic),
            f.number("SIC", \.sic),
            f.number("TotalFlightTime", \.totalFlightTime),
            f.bool("fHoldingProcedures", \.fHoldingProcedures),
            f.string("Route", \.route),
            f.string("Comment", \.comment),
            f.bool("fIsPublic", \.fIsPublic),
            f.date("Date", \.date),
            f.bool("IsOverridden", \.isOverridden),
            f.string("FlightColorHex", \.flightColorHex),
            f.string("ErrorString", \.errorString),
            f.number("FlightID", \.flightID),
            f.date("FlightStart", \.flightStart),
            f.date("FlightEnd", \.flightEnd),
            f.date("EngineStart", \.engineStart),
            f.date("EngineEnd", \.engineEnd),
            f.number("HobbsStart", \.hobbsStart),
            f.number("HobbsEnd", \.hobbsEnd),
            f.string("ModelDisplay", \.modelDisplay),
            f.string("TailNumDisplay", \.tailNumDisplay),
            f.string("CatClassDisplay", \.catClassDisplay),
            f.string("FlightData", \.flightData),
            f.object("CustomProperties", \.customProperties),
            f.object("FlightImages", \.flightImages),
            f.object("Videos", \.videos),
            f.string("SendFlightLink", \.sendFlightLink),
            f.string("SocialMediaLink", \.socialMediaLink)
        ]
    }
}

// MARK: ArrayOfCustomFlightProperty
/// WSDL type `ArrayOfCustomFlightProperty`
@objc(MFBWebServiceSvc_ArrayOfCustomFlightProperty)
public class MFBWebServiceSvc_ArrayOfCustomFlightProperty : SoapObject {
    public var customFlightProperty : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_CustomFlightProperty?) {
        if let o = toAdd { customFlightProperty.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfCustomFlightProperty>()
        return super.soapFields + [
            f.objects("CustomFlightProperty", \.customFlightProperty, of: MFBWebServiceSvc_CustomFlightProperty.self)
        ]
    }
}

// MARK: CustomFlightProperty
/// WSDL type `CustomFlightProperty`
@objc(MFBWebServiceSvc_CustomFlightProperty)
public class MFBWebServiceSvc_CustomFlightProperty : SoapObject {
    public var propID : NSNumber!
    public var flightID : NSNumber!
    public var propTypeID : NSNumber!
    public var intValue : NSNumber!
    public var boolValue : USBoolean!
    public var decValue : NSNumber!
    public var dateValue : Date!
    public var textValue : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CustomFlightProperty>()
        return super.soapFields + [
            f.number("PropID", \.propID),
            f.number("FlightID", \.flightID),
            f.number("PropTypeID", \.propTypeID),
            f.number("IntValue", \.intValue),
            f.bool("BoolValue", \.boolValue),
            f.number("DecValue", \.decValue),
            f.date("DateValue", \.dateValue),
            f.string("TextValue", \.textValue)
        ]
    }
}

// MARK: ArrayOfVideoRef
/// WSDL type `ArrayOfVideoRef`
@objc(MFBWebServiceSvc_ArrayOfVideoRef)
public class MFBWebServiceSvc_ArrayOfVideoRef : SoapObject {
    public var videoRef : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_VideoRef?) {
        if let o = toAdd { videoRef.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfVideoRef>()
        return super.soapFields + [
            f.objects("VideoRef", \.videoRef, of: MFBWebServiceSvc_VideoRef.self)
        ]
    }
}

// MARK: VideoRef
/// WSDL type `VideoRef`
@objc(MFBWebServiceSvc_VideoRef)
public class MFBWebServiceSvc_VideoRef : SoapObject {
    public var id_ : NSNumber!
    public var flightID : NSNumber!
    public var videoReference : String!
    public var source = MFBWebServiceSvc_VideoSource_none
    public var comment : String!
    public var errorString : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_VideoRef>()
        return super.soapFields + [
            f.number("ID", \.id_, key: "ID_"),
            f.number("FlightID", \.flightID),
            f.string("VideoReference", \.videoReference),
            f.enumeration("Source", \.source),
            f.string("Comment", \.comment),
            f.string("ErrorString", \.errorString)
        ]
    }
}

// MARK: PostingOptions
/// WSDL type `PostingOptions`
@objc(MFBWebServiceSvc_PostingOptions)
public class MFBWebServiceSvc_PostingOptions : SoapObject {
    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

}

// MARK: ArrayOfLatLong
/// WSDL type `ArrayOfLatLong`
@objc(MFBWebServiceSvc_ArrayOfLatLong)
public class MFBWebServiceSvc_ArrayOfLatLong : SoapObject {
    public var latLong : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_LatLong?) {
        if let o = toAdd { latLong.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfLatLong>()
        return super.soapFields + [
            f.objects("LatLong", \.latLong, of: MFBWebServiceSvc_LatLong.self)
        ]
    }
}

// MARK: AutoFillOptions
/// WSDL type `AutoFillOptions`
@objc(MFBWebServiceSvc_AutoFillOptions)
public class MFBWebServiceSvc_AutoFillOptions : SoapObject {
    public var timeZoneOffset : NSNumber!
    public var autoFillTotal = MFBWebServiceSvc_AutoFillTotalOption_none
    public var autoFillHobbs = MFBWebServiceSvc_AutoFillHobbsOption_none
    public var night = MFBWebServiceSvc_NightCritera_none
    public var nightLanding = MFBWebServiceSvc_NightLandingCriteria_none
    public var crossCountryThreshold : NSNumber!
    public var takeOffSpeed : NSNumber!
    public var landingSpeed : NSNumber!
    public var includeHeliports : USBoolean!
    public var autoSynthesizePath : USBoolean!
    public var roundToTenth : USBoolean!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AutoFillOptions>()
        return super.soapFields + [
            f.number("TimeZoneOffset", \.timeZoneOffset),
            f.enumeration("AutoFillTotal", \.autoFillTotal),
            f.enumeration("AutoFillHobbs", \.autoFillHobbs),
            f.enumeration("Night", \.night),
            f.enumeration("NightLanding", \.nightLanding),
            f.number("CrossCountryThreshold", \.crossCountryThreshold),
            f.number("TakeOffSpeed", \.takeOffSpeed),
            f.number("LandingSpeed", \.landingSpeed),
            f.bool("IncludeHeliports", \.includeHeliports),
            f.bool("AutoSynthesizePath", \.autoSynthesizePath),
            f.bool("RoundToTenth", \.roundToTenth)
        ]
    }
}

// MARK: ArrayOfPendingFlight
/// WSDL type `ArrayOfPendingFlight`
@objc(MFBWebServiceSvc_ArrayOfPendingFlight)
public class MFBWebServiceSvc_ArrayOfPendingFlight : SoapObject {
    public var pendingFlight : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_PendingFlight?) {
        if let o = toAdd { pendingFlight.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfPendingFlight>()
        return super.soapFields + [
            f.objects("PendingFlight", \.pendingFlight, of: MFBWebServiceSvc_PendingFlight.self)
        ]
    }
}

// MARK: PendingFlight
/// WSDL type `PendingFlight` (extends `LogbookEntry`)
@objc(MFBWebServiceSvc_PendingFlight)
public class MFBWebServiceSvc_PendingFlight : MFBWebServiceSvc_LogbookEntry {
    public var pendingID : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PendingFlight>()
        return super.soapFields + [
            f.string("PendingID", \.pendingID)
        ]
    }
}

// MARK: TemplatePropTypeBundle
/// WSDL type `TemplatePropTypeBundle`
@objc(MFBWebServiceSvc_TemplatePropTypeBundle)
public class MFBWebServiceSvc_TemplatePropTypeBundle : SoapObject {
    public var userProperties : MFBWebServiceSvc_ArrayOfCustomPropertyType!
    public var userTemplates : MFBWebServiceSvc_ArrayOfPropertyTemplate!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TemplatePropTypeBundle>()
        return super.soapFields + [
            f.object("UserProperties", \.userProperties),
            f.object("UserTemplates", \.userTemplates)
        ]
    }
}

// MARK: ArrayOfPropertyTemplate
/// WSDL type `ArrayOfPropertyTemplate`
@objc(MFBWebServiceSvc_ArrayOfPropertyTemplate)
public class MFBWebServiceSvc_ArrayOfPropertyTemplate : SoapObject {
    public var propertyTemplate : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_PropertyTemplate?) {
        if let o = toAdd { propertyTemplate.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfPropertyTemplate>()
        return super.soapFields + [
            f.objects("PropertyTemplate", \.propertyTemplate, of: MFBWebServiceSvc_PropertyTemplate.self)
        ]
    }
}

// MARK: PropertyTemplate
/// WSDL type `PropertyTemplate`
@objc(MFBWebServiceSvc_PropertyTemplate)
public class MFBWebServiceSvc_PropertyTemplate : SoapObject {
    public var id_ : NSNumber!
    public var name : String!
    public var descriptionText : String!
    public override var description : String {
        get { return descriptionText ?? "" }
        set { descriptionText = newValue }
    }
    public var groupAsInt : NSNumber!
    public var groupDisplayName : String!
    public var propertyTypes : MFBWebServiceSvc_ArrayOfInt!
    public var isDefault : USBoolean!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PropertyTemplate>()
        return super.soapFields + [
            f.number("ID", \.id_, key: "ID_"),
            f.string("Name", \.name),
            f.string("Description", \.descriptionText),
            f.number("GroupAsInt", \.groupAsInt),
            f.string("GroupDisplayName", \.groupDisplayName),
            f.object("PropertyTypes", \.propertyTypes),
            f.bool("IsDefault", \.isDefault)
        ]
    }
}

// MARK: AuthResult
/// WSDL type `AuthResult`
@objc(MFBWebServiceSvc_AuthResult)
public class MFBWebServiceSvc_AuthResult : SoapObject {
    public var result = MFBWebServiceSvc_AuthStatus_none
    public var authToken : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AuthResult>()
        return super.soapFields + [
            f.enumeration("Result", \.result),
            f.string("AuthToken", \.authToken)
        ]
    }
}

// MARK: UserEntity
/// WSDL type `UserEntity`
@objc(MFBWebServiceSvc_UserEntity)
public class MFBWebServiceSvc_UserEntity : SoapObject {
    public var szAuthToken : String!
    public var szUsername : String!
    public var mcs = MFBWebServiceSvc_MembershipCreateStatus_none

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UserEntity>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.string("szUsername", \.szUsername),
            f.enumeration("mcs", \.mcs)
        ]
    }
}

// MARK: ArrayOfCannedQuery
/// WSDL type `ArrayOfCannedQuery`
@objc(MFBWebServiceSvc_ArrayOfCannedQuery)
public class MFBWebServiceSvc_ArrayOfCannedQuery : SoapObject {
    public var cannedQuery : NSMutableArray! = NSMutableArray()

    public func add(_ toAdd : MFBWebServiceSvc_CannedQuery?) {
        if let o = toAdd { cannedQuery.add(o) }
    }

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ArrayOfCannedQuery>()
        return super.soapFields + [
            f.objects("CannedQuery", \.cannedQuery, of: MFBWebServiceSvc_CannedQuery.self)
        ]
    }
}

// MARK: CannedQuery
/// WSDL type `CannedQuery` (extends `FlightQuery`)
@objc(MFBWebServiceSvc_CannedQuery)
public class MFBWebServiceSvc_CannedQuery : MFBWebServiceSvc_FlightQuery {
    public var queryName : String!
    public var colorString : String!

    public override class var supportsSecureCoding : Bool { return true }   // required on each archivable class

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CannedQuery>()
        return super.soapFields + [
            f.string("QueryName", \.queryName),
            f.string("ColorString", \.colorString)
        ]
    }
}
