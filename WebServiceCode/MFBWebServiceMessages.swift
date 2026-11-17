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
//  MFBWebServiceMessages.swift
//
//  The request and response messages of the web service, one pair per operation, in WSDL order.
//
//  Adding a web service: add a request class (whose `Response` typealias names the response class) and the response class here,
//  then (only if legacy delegate-style callers need it) a one-line method in the extension at the bottom of SoapClient.swift.
//  New code can call it immediately:
//
//      client.call(MFBWebServiceSvc_MyNewCall(), onSuccess: { response in ... })
//

import Foundation

// MARK: AircraftForUser
/// Request for `AircraftForUser`.
@objc(MFBWebServiceSvc_AircraftForUser)
public class MFBWebServiceSvc_AircraftForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AircraftForUserResponse

    public var szAuthUserToken : String!

    public override class var soapElementName : String { return "AircraftForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AircraftForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken)
        ]
    }
}

/// Response from `AircraftForUser`.
@objc(MFBWebServiceSvc_AircraftForUserResponse)
public class MFBWebServiceSvc_AircraftForUserResponse : SoapObject {
    public var aircraftForUserResult : MFBWebServiceSvc_ArrayOfAircraft!

    public override class var soapElementName : String { return "AircraftForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AircraftForUserResponse>()
        return super.soapFields + [
            f.object("AircraftForUserResult", \.aircraftForUserResult)
        ]
    }
}

// MARK: AddAircraftForUser
/// Request for `AddAircraftForUser`.
@objc(MFBWebServiceSvc_AddAircraftForUser)
public class MFBWebServiceSvc_AddAircraftForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AddAircraftForUserResponse

    public var szAuthUserToken : String!
    public var szTail : String!
    public var idModel : NSNumber!
    public var idInstanceType : NSNumber!

    public override class var soapElementName : String { return "AddAircraftForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AddAircraftForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.string("szTail", \.szTail),
            f.number("idModel", \.idModel),
            f.number("idInstanceType", \.idInstanceType)
        ]
    }
}

/// Response from `AddAircraftForUser`.
@objc(MFBWebServiceSvc_AddAircraftForUserResponse)
public class MFBWebServiceSvc_AddAircraftForUserResponse : SoapObject {
    public var addAircraftForUserResult : MFBWebServiceSvc_ArrayOfAircraft!

    public override class var soapElementName : String { return "AddAircraftForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AddAircraftForUserResponse>()
        return super.soapFields + [
            f.object("AddAircraftForUserResult", \.addAircraftForUserResult)
        ]
    }
}

// MARK: AircraftMatchingPrefix
/// Request for `AircraftMatchingPrefix`.
@objc(MFBWebServiceSvc_AircraftMatchingPrefix)
public class MFBWebServiceSvc_AircraftMatchingPrefix : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AircraftMatchingPrefixResponse

    public var szAuthToken : String!
    public var szPrefix : String!

    public override class var soapElementName : String { return "AircraftMatchingPrefix" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AircraftMatchingPrefix>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.string("szPrefix", \.szPrefix)
        ]
    }
}

/// Response from `AircraftMatchingPrefix`.
@objc(MFBWebServiceSvc_AircraftMatchingPrefixResponse)
public class MFBWebServiceSvc_AircraftMatchingPrefixResponse : SoapObject {
    public var aircraftMatchingPrefixResult : MFBWebServiceSvc_ArrayOfAircraft!

    public override class var soapElementName : String { return "AircraftMatchingPrefixResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AircraftMatchingPrefixResponse>()
        return super.soapFields + [
            f.object("AircraftMatchingPrefixResult", \.aircraftMatchingPrefixResult)
        ]
    }
}

// MARK: UpdateMaintenanceForAircraft
/// Request for `UpdateMaintenanceForAircraft`.
@objc(MFBWebServiceSvc_UpdateMaintenanceForAircraft)
public class MFBWebServiceSvc_UpdateMaintenanceForAircraft : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse

    public var szAuthUserToken : String!
    public var ac : MFBWebServiceSvc_Aircraft!

    public override class var soapElementName : String { return "UpdateMaintenanceForAircraft" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UpdateMaintenanceForAircraft>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("ac", \.ac)
        ]
    }
}

/// Response from `UpdateMaintenanceForAircraft`.
@objc(MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse)
public class MFBWebServiceSvc_UpdateMaintenanceForAircraftResponse : SoapObject {
    public override class var soapElementName : String { return "UpdateMaintenanceForAircraftResponse" }

}

// MARK: UpdateMaintenanceForAircraftWithFlagsAndNotes
/// Request for `UpdateMaintenanceForAircraftWithFlagsAndNotes`.
@objc(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes)
public class MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse

    public var szAuthUserToken : String!
    public var ac : MFBWebServiceSvc_Aircraft!

    public override class var soapElementName : String { return "UpdateMaintenanceForAircraftWithFlagsAndNotes" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotes>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("ac", \.ac)
        ]
    }
}

/// Response from `UpdateMaintenanceForAircraftWithFlagsAndNotes`.
@objc(MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse)
public class MFBWebServiceSvc_UpdateMaintenanceForAircraftWithFlagsAndNotesResponse : SoapObject {
    public override class var soapElementName : String { return "UpdateMaintenanceForAircraftWithFlagsAndNotesResponse" }

}

// MARK: DeleteAircraftForUser
/// Request for `DeleteAircraftForUser`.
@objc(MFBWebServiceSvc_DeleteAircraftForUser)
public class MFBWebServiceSvc_DeleteAircraftForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeleteAircraftForUserResponse

    public var szAuthUserToken : String!
    public var idAircraft : NSNumber!

    public override class var soapElementName : String { return "DeleteAircraftForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteAircraftForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idAircraft", \.idAircraft)
        ]
    }
}

/// Response from `DeleteAircraftForUser`.
@objc(MFBWebServiceSvc_DeleteAircraftForUserResponse)
public class MFBWebServiceSvc_DeleteAircraftForUserResponse : SoapObject {
    public var deleteAircraftForUserResult : MFBWebServiceSvc_ArrayOfAircraft!

    public override class var soapElementName : String { return "DeleteAircraftForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteAircraftForUserResponse>()
        return super.soapFields + [
            f.object("DeleteAircraftForUserResult", \.deleteAircraftForUserResult)
        ]
    }
}

// MARK: MakesAndModels
/// Request for `MakesAndModels`.
@objc(MFBWebServiceSvc_MakesAndModels)
public class MFBWebServiceSvc_MakesAndModels : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_MakesAndModelsResponse

    public override class var soapElementName : String { return "MakesAndModels" }

}

/// Response from `MakesAndModels`.
@objc(MFBWebServiceSvc_MakesAndModelsResponse)
public class MFBWebServiceSvc_MakesAndModelsResponse : SoapObject {
    public var makesAndModelsResult : MFBWebServiceSvc_ArrayOfSimpleMakeModel!

    public override class var soapElementName : String { return "MakesAndModelsResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_MakesAndModelsResponse>()
        return super.soapFields + [
            f.object("MakesAndModelsResult", \.makesAndModelsResult)
        ]
    }
}

// MARK: ModelsWithIDs
/// Request for `ModelsWithIDs`.
@objc(MFBWebServiceSvc_ModelsWithIDs)
public class MFBWebServiceSvc_ModelsWithIDs : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_ModelsWithIDsResponse

    public var szAuthToken : String!
    public var rgIDs : MFBWebServiceSvc_ArrayOfInt!

    public override class var soapElementName : String { return "ModelsWithIDs" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ModelsWithIDs>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.object("rgIDs", \.rgIDs)
        ]
    }
}

/// Response from `ModelsWithIDs`.
@objc(MFBWebServiceSvc_ModelsWithIDsResponse)
public class MFBWebServiceSvc_ModelsWithIDsResponse : SoapObject {
    public var modelsWithIDsResult : MFBWebServiceSvc_ArrayOfMakeModel!

    public override class var soapElementName : String { return "ModelsWithIDsResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_ModelsWithIDsResponse>()
        return super.soapFields + [
            f.object("ModelsWithIDsResult", \.modelsWithIDsResult)
        ]
    }
}

// MARK: GetCurrencyForUser
/// Request for `GetCurrencyForUser`.
@objc(MFBWebServiceSvc_GetCurrencyForUser)
public class MFBWebServiceSvc_GetCurrencyForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_GetCurrencyForUserResponse

    public var szAuthToken : String!

    public override class var soapElementName : String { return "GetCurrencyForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_GetCurrencyForUser>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken)
        ]
    }
}

/// Response from `GetCurrencyForUser`.
@objc(MFBWebServiceSvc_GetCurrencyForUserResponse)
public class MFBWebServiceSvc_GetCurrencyForUserResponse : SoapObject {
    public var getCurrencyForUserResult : MFBWebServiceSvc_ArrayOfCurrencyStatusItem!

    public override class var soapElementName : String { return "GetCurrencyForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_GetCurrencyForUserResponse>()
        return super.soapFields + [
            f.object("GetCurrencyForUserResult", \.getCurrencyForUserResult)
        ]
    }
}

// MARK: TotalsForUser
/// Request for `TotalsForUser`.
@objc(MFBWebServiceSvc_TotalsForUser)
public class MFBWebServiceSvc_TotalsForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_TotalsForUserResponse

    public var szAuthToken : String!
    public var dtMin : Date!

    public override class var soapElementName : String { return "TotalsForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TotalsForUser>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.date("dtMin", \.dtMin)
        ]
    }
}

/// Response from `TotalsForUser`.
@objc(MFBWebServiceSvc_TotalsForUserResponse)
public class MFBWebServiceSvc_TotalsForUserResponse : SoapObject {
    public var totalsForUserResult : MFBWebServiceSvc_ArrayOfTotalsItem!

    public override class var soapElementName : String { return "TotalsForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TotalsForUserResponse>()
        return super.soapFields + [
            f.object("TotalsForUserResult", \.totalsForUserResult)
        ]
    }
}

// MARK: TotalsForUserWithQuery
/// Request for `TotalsForUserWithQuery`.
@objc(MFBWebServiceSvc_TotalsForUserWithQuery)
public class MFBWebServiceSvc_TotalsForUserWithQuery : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_TotalsForUserWithQueryResponse

    public var szAuthToken : String!
    public var fq : MFBWebServiceSvc_FlightQuery!

    public override class var soapElementName : String { return "TotalsForUserWithQuery" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TotalsForUserWithQuery>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.object("fq", \.fq)
        ]
    }
}

/// Response from `TotalsForUserWithQuery`.
@objc(MFBWebServiceSvc_TotalsForUserWithQueryResponse)
public class MFBWebServiceSvc_TotalsForUserWithQueryResponse : SoapObject {
    public var totalsForUserWithQueryResult : MFBWebServiceSvc_ArrayOfTotalsItem!

    public override class var soapElementName : String { return "TotalsForUserWithQueryResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_TotalsForUserWithQueryResponse>()
        return super.soapFields + [
            f.object("TotalsForUserWithQueryResult", \.totalsForUserWithQueryResult)
        ]
    }
}

// MARK: VisitedAirports
/// Request for `VisitedAirports`.
@objc(MFBWebServiceSvc_VisitedAirports)
public class MFBWebServiceSvc_VisitedAirports : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_VisitedAirportsResponse

    public var szAuthToken : String!

    public override class var soapElementName : String { return "VisitedAirports" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_VisitedAirports>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken)
        ]
    }
}

/// Response from `VisitedAirports`.
@objc(MFBWebServiceSvc_VisitedAirportsResponse)
public class MFBWebServiceSvc_VisitedAirportsResponse : SoapObject {
    public var visitedAirportsResult : MFBWebServiceSvc_ArrayOfVisitedAirport!

    public override class var soapElementName : String { return "VisitedAirportsResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_VisitedAirportsResponse>()
        return super.soapFields + [
            f.object("VisitedAirportsResult", \.visitedAirportsResult)
        ]
    }
}

// MARK: FlightsWithQueryAndOffset
/// Request for `FlightsWithQueryAndOffset`.
@objc(MFBWebServiceSvc_FlightsWithQueryAndOffset)
public class MFBWebServiceSvc_FlightsWithQueryAndOffset : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse

    public var szAuthUserToken : String!
    public var fq : MFBWebServiceSvc_FlightQuery!
    public var offset : NSNumber!
    public var maxCount : NSNumber!

    public override class var soapElementName : String { return "FlightsWithQueryAndOffset" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightsWithQueryAndOffset>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("fq", \.fq),
            f.number("offset", \.offset),
            f.number("maxCount", \.maxCount)
        ]
    }
}

/// Response from `FlightsWithQueryAndOffset`.
@objc(MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse)
public class MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse : SoapObject {
    public var flightsWithQueryAndOffsetResult : MFBWebServiceSvc_ArrayOfLogbookEntry!

    public override class var soapElementName : String { return "FlightsWithQueryAndOffsetResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightsWithQueryAndOffsetResponse>()
        return super.soapFields + [
            f.object("FlightsWithQueryAndOffsetResult", \.flightsWithQueryAndOffsetResult)
        ]
    }
}

// MARK: FlightsWithQuery
/// Request for `FlightsWithQuery`.
@objc(MFBWebServiceSvc_FlightsWithQuery)
public class MFBWebServiceSvc_FlightsWithQuery : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_FlightsWithQueryResponse

    public var szAuthUserToken : String!
    public var fq : MFBWebServiceSvc_FlightQuery!
    public var maxCount : NSNumber!

    public override class var soapElementName : String { return "FlightsWithQuery" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightsWithQuery>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("fq", \.fq),
            f.number("maxCount", \.maxCount)
        ]
    }
}

/// Response from `FlightsWithQuery`.
@objc(MFBWebServiceSvc_FlightsWithQueryResponse)
public class MFBWebServiceSvc_FlightsWithQueryResponse : SoapObject {
    public var flightsWithQueryResult : MFBWebServiceSvc_ArrayOfLogbookEntry!

    public override class var soapElementName : String { return "FlightsWithQueryResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightsWithQueryResponse>()
        return super.soapFields + [
            f.object("FlightsWithQueryResult", \.flightsWithQueryResult)
        ]
    }
}

// MARK: DeleteLogbookEntry
/// Request for `DeleteLogbookEntry`.
@objc(MFBWebServiceSvc_DeleteLogbookEntry)
public class MFBWebServiceSvc_DeleteLogbookEntry : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeleteLogbookEntryResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!

    public override class var soapElementName : String { return "DeleteLogbookEntry" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteLogbookEntry>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight)
        ]
    }
}

/// Response from `DeleteLogbookEntry`.
@objc(MFBWebServiceSvc_DeleteLogbookEntryResponse)
public class MFBWebServiceSvc_DeleteLogbookEntryResponse : SoapObject {
    public var deleteLogbookEntryResult : USBoolean!

    public override class var soapElementName : String { return "DeleteLogbookEntryResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteLogbookEntryResponse>()
        return super.soapFields + [
            f.bool("DeleteLogbookEntryResult", \.deleteLogbookEntryResult)
        ]
    }
}

// MARK: CommitFlightWithOptions
/// Request for `CommitFlightWithOptions`.
@objc(MFBWebServiceSvc_CommitFlightWithOptions)
public class MFBWebServiceSvc_CommitFlightWithOptions : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_CommitFlightWithOptionsResponse

    public var szAuthUserToken : String!
    public var le : MFBWebServiceSvc_LogbookEntry!
    public var po : MFBWebServiceSvc_PostingOptions!

    public override class var soapElementName : String { return "CommitFlightWithOptions" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CommitFlightWithOptions>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("le", \.le),
            f.object("po", \.po)
        ]
    }
}

/// Response from `CommitFlightWithOptions`.
@objc(MFBWebServiceSvc_CommitFlightWithOptionsResponse)
public class MFBWebServiceSvc_CommitFlightWithOptionsResponse : SoapObject {
    public var commitFlightWithOptionsResult : MFBWebServiceSvc_LogbookEntry!

    public override class var soapElementName : String { return "CommitFlightWithOptionsResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CommitFlightWithOptionsResponse>()
        return super.soapFields + [
            f.object("CommitFlightWithOptionsResult", \.commitFlightWithOptionsResult)
        ]
    }
}

// MARK: FlightPathForFlight
/// Request for `FlightPathForFlight`.
@objc(MFBWebServiceSvc_FlightPathForFlight)
public class MFBWebServiceSvc_FlightPathForFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_FlightPathForFlightResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!

    public override class var soapElementName : String { return "FlightPathForFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightPathForFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight)
        ]
    }
}

/// Response from `FlightPathForFlight`.
@objc(MFBWebServiceSvc_FlightPathForFlightResponse)
public class MFBWebServiceSvc_FlightPathForFlightResponse : SoapObject {
    public var flightPathForFlightResult : MFBWebServiceSvc_ArrayOfLatLong!

    public override class var soapElementName : String { return "FlightPathForFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightPathForFlightResponse>()
        return super.soapFields + [
            f.object("FlightPathForFlightResult", \.flightPathForFlightResult)
        ]
    }
}

// MARK: FlightPathForFlightGPX
/// Request for `FlightPathForFlightGPX`.
@objc(MFBWebServiceSvc_FlightPathForFlightGPX)
public class MFBWebServiceSvc_FlightPathForFlightGPX : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_FlightPathForFlightGPXResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!

    public override class var soapElementName : String { return "FlightPathForFlightGPX" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightPathForFlightGPX>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight)
        ]
    }
}

/// Response from `FlightPathForFlightGPX`.
@objc(MFBWebServiceSvc_FlightPathForFlightGPXResponse)
public class MFBWebServiceSvc_FlightPathForFlightGPXResponse : SoapObject {
    public var flightPathForFlightGPXResult : String!

    public override class var soapElementName : String { return "FlightPathForFlightGPXResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_FlightPathForFlightGPXResponse>()
        return super.soapFields + [
            f.string("FlightPathForFlightGPXResult", \.flightPathForFlightGPXResult)
        ]
    }
}

// MARK: CheckFlight
/// Request for `CheckFlight`.
@objc(MFBWebServiceSvc_CheckFlight)
public class MFBWebServiceSvc_CheckFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_CheckFlightResponse

    public var szAuthUserToken : String!
    public var le : MFBWebServiceSvc_LogbookEntry!

    public override class var soapElementName : String { return "CheckFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CheckFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("le", \.le)
        ]
    }
}

/// Response from `CheckFlight`.
@objc(MFBWebServiceSvc_CheckFlightResponse)
public class MFBWebServiceSvc_CheckFlightResponse : SoapObject {
    public var checkFlightResult : MFBWebServiceSvc_ArrayOfString!

    public override class var soapElementName : String { return "CheckFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CheckFlightResponse>()
        return super.soapFields + [
            f.object("CheckFlightResult", \.checkFlightResult)
        ]
    }
}

// MARK: AutofillFlight
/// Request for `AutofillFlight`.
@objc(MFBWebServiceSvc_AutofillFlight)
public class MFBWebServiceSvc_AutofillFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AutofillFlightResponse

    public var szAuthUserToken : String!
    public var le : MFBWebServiceSvc_LogbookEntry!
    public var options : MFBWebServiceSvc_AutoFillOptions!

    public override class var soapElementName : String { return "AutofillFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AutofillFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("le", \.le),
            f.object("options", \.options)
        ]
    }
}

/// Response from `AutofillFlight`.
@objc(MFBWebServiceSvc_AutofillFlightResponse)
public class MFBWebServiceSvc_AutofillFlightResponse : SoapObject {
    public var autofillFlightResult : MFBWebServiceSvc_LogbookEntry!

    public override class var soapElementName : String { return "AutofillFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AutofillFlightResponse>()
        return super.soapFields + [
            f.object("AutofillFlightResult", \.autofillFlightResult)
        ]
    }
}

// MARK: InitFlightFromFlightDeckScan
/// Request for `InitFlightFromFlightDeckScan`.
@objc(MFBWebServiceSvc_InitFlightFromFlightDeckScan)
public class MFBWebServiceSvc_InitFlightFromFlightDeckScan : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_InitFlightFromFlightDeckScanResponse

    public var szAuthUserToken : String!
    public var le : MFBWebServiceSvc_LogbookEntry!
    public var szScannedFlight : String!

    public override class var soapElementName : String { return "InitFlightFromFlightDeckScan" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_InitFlightFromFlightDeckScan>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("le", \.le),
            f.string("szScannedFlight", \.szScannedFlight)
        ]
    }
}

/// Response from `InitFlightFromFlightDeckScan`.
@objc(MFBWebServiceSvc_InitFlightFromFlightDeckScanResponse)
public class MFBWebServiceSvc_InitFlightFromFlightDeckScanResponse : SoapObject {
    public var initFlightFromFlightDeckScanResult : MFBWebServiceSvc_LogbookEntry!

    public override class var soapElementName : String { return "InitFlightFromFlightDeckScanResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_InitFlightFromFlightDeckScanResponse>()
        return super.soapFields + [
            f.object("InitFlightFromFlightDeckScanResult", \.initFlightFromFlightDeckScanResult)
        ]
    }
}

// MARK: CreatePendingFlight
/// Request for `CreatePendingFlight`.
@objc(MFBWebServiceSvc_CreatePendingFlight)
public class MFBWebServiceSvc_CreatePendingFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_CreatePendingFlightResponse

    public var szAuthUserToken : String!
    public var le : MFBWebServiceSvc_LogbookEntry!

    public override class var soapElementName : String { return "CreatePendingFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CreatePendingFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("le", \.le)
        ]
    }
}

/// Response from `CreatePendingFlight`.
@objc(MFBWebServiceSvc_CreatePendingFlightResponse)
public class MFBWebServiceSvc_CreatePendingFlightResponse : SoapObject {
    public var createPendingFlightResult : MFBWebServiceSvc_ArrayOfPendingFlight!

    public override class var soapElementName : String { return "CreatePendingFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CreatePendingFlightResponse>()
        return super.soapFields + [
            f.object("CreatePendingFlightResult", \.createPendingFlightResult)
        ]
    }
}

// MARK: PendingFlightsForUser
/// Request for `PendingFlightsForUser`.
@objc(MFBWebServiceSvc_PendingFlightsForUser)
public class MFBWebServiceSvc_PendingFlightsForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_PendingFlightsForUserResponse

    public var szAuthUserToken : String!

    public override class var soapElementName : String { return "PendingFlightsForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PendingFlightsForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken)
        ]
    }
}

/// Response from `PendingFlightsForUser`.
@objc(MFBWebServiceSvc_PendingFlightsForUserResponse)
public class MFBWebServiceSvc_PendingFlightsForUserResponse : SoapObject {
    public var pendingFlightsForUserResult : MFBWebServiceSvc_ArrayOfPendingFlight!

    public override class var soapElementName : String { return "PendingFlightsForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PendingFlightsForUserResponse>()
        return super.soapFields + [
            f.object("PendingFlightsForUserResult", \.pendingFlightsForUserResult)
        ]
    }
}

// MARK: UpdatePendingFlight
/// Request for `UpdatePendingFlight`.
@objc(MFBWebServiceSvc_UpdatePendingFlight)
public class MFBWebServiceSvc_UpdatePendingFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_UpdatePendingFlightResponse

    public var szAuthUserToken : String!
    public var pf : MFBWebServiceSvc_PendingFlight!

    public override class var soapElementName : String { return "UpdatePendingFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UpdatePendingFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("pf", \.pf)
        ]
    }
}

/// Response from `UpdatePendingFlight`.
@objc(MFBWebServiceSvc_UpdatePendingFlightResponse)
public class MFBWebServiceSvc_UpdatePendingFlightResponse : SoapObject {
    public var updatePendingFlightResult : MFBWebServiceSvc_ArrayOfPendingFlight!

    public override class var soapElementName : String { return "UpdatePendingFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UpdatePendingFlightResponse>()
        return super.soapFields + [
            f.object("UpdatePendingFlightResult", \.updatePendingFlightResult)
        ]
    }
}

// MARK: DeletePendingFlight
/// Request for `DeletePendingFlight`.
@objc(MFBWebServiceSvc_DeletePendingFlight)
public class MFBWebServiceSvc_DeletePendingFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeletePendingFlightResponse

    public var szAuthUserToken : String!
    public var idpending : String!

    public override class var soapElementName : String { return "DeletePendingFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeletePendingFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.string("idpending", \.idpending)
        ]
    }
}

/// Response from `DeletePendingFlight`.
@objc(MFBWebServiceSvc_DeletePendingFlightResponse)
public class MFBWebServiceSvc_DeletePendingFlightResponse : SoapObject {
    public var deletePendingFlightResult : MFBWebServiceSvc_ArrayOfPendingFlight!

    public override class var soapElementName : String { return "DeletePendingFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeletePendingFlightResponse>()
        return super.soapFields + [
            f.object("DeletePendingFlightResult", \.deletePendingFlightResult)
        ]
    }
}

// MARK: CommitPendingFlight
/// Request for `CommitPendingFlight`.
@objc(MFBWebServiceSvc_CommitPendingFlight)
public class MFBWebServiceSvc_CommitPendingFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_CommitPendingFlightResponse

    public var szAuthUserToken : String!
    public var pf : MFBWebServiceSvc_PendingFlight!

    public override class var soapElementName : String { return "CommitPendingFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CommitPendingFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("pf", \.pf)
        ]
    }
}

/// Response from `CommitPendingFlight`.
@objc(MFBWebServiceSvc_CommitPendingFlightResponse)
public class MFBWebServiceSvc_CommitPendingFlightResponse : SoapObject {
    public var commitPendingFlightResult : MFBWebServiceSvc_ArrayOfPendingFlight!

    public override class var soapElementName : String { return "CommitPendingFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CommitPendingFlightResponse>()
        return super.soapFields + [
            f.object("CommitPendingFlightResult", \.commitPendingFlightResult)
        ]
    }
}

// MARK: AvailablePropertyTypes
/// Request for `AvailablePropertyTypes`.
@objc(MFBWebServiceSvc_AvailablePropertyTypes)
public class MFBWebServiceSvc_AvailablePropertyTypes : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AvailablePropertyTypesResponse

    public override class var soapElementName : String { return "AvailablePropertyTypes" }

}

/// Response from `AvailablePropertyTypes`.
@objc(MFBWebServiceSvc_AvailablePropertyTypesResponse)
public class MFBWebServiceSvc_AvailablePropertyTypesResponse : SoapObject {
    public var availablePropertyTypesResult : MFBWebServiceSvc_ArrayOfCustomPropertyType!

    public override class var soapElementName : String { return "AvailablePropertyTypesResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AvailablePropertyTypesResponse>()
        return super.soapFields + [
            f.object("AvailablePropertyTypesResult", \.availablePropertyTypesResult)
        ]
    }
}

// MARK: AvailablePropertyTypesForUser
/// Request for `AvailablePropertyTypesForUser`.
@objc(MFBWebServiceSvc_AvailablePropertyTypesForUser)
public class MFBWebServiceSvc_AvailablePropertyTypesForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AvailablePropertyTypesForUserResponse

    public var szAuthUserToken : String!

    public override class var soapElementName : String { return "AvailablePropertyTypesForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AvailablePropertyTypesForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken)
        ]
    }
}

/// Response from `AvailablePropertyTypesForUser`.
@objc(MFBWebServiceSvc_AvailablePropertyTypesForUserResponse)
public class MFBWebServiceSvc_AvailablePropertyTypesForUserResponse : SoapObject {
    public var availablePropertyTypesForUserResult : MFBWebServiceSvc_ArrayOfCustomPropertyType!

    public override class var soapElementName : String { return "AvailablePropertyTypesForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AvailablePropertyTypesForUserResponse>()
        return super.soapFields + [
            f.object("AvailablePropertyTypesForUserResult", \.availablePropertyTypesForUserResult)
        ]
    }
}

// MARK: PropertiesAndTemplatesForUser
/// Request for `PropertiesAndTemplatesForUser`.
@objc(MFBWebServiceSvc_PropertiesAndTemplatesForUser)
public class MFBWebServiceSvc_PropertiesAndTemplatesForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse

    public var szAuthUserToken : String!

    public override class var soapElementName : String { return "PropertiesAndTemplatesForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PropertiesAndTemplatesForUser>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken)
        ]
    }
}

/// Response from `PropertiesAndTemplatesForUser`.
@objc(MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse)
public class MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse : SoapObject {
    public var propertiesAndTemplatesForUserResult : MFBWebServiceSvc_TemplatePropTypeBundle!

    public override class var soapElementName : String { return "PropertiesAndTemplatesForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PropertiesAndTemplatesForUserResponse>()
        return super.soapFields + [
            f.object("PropertiesAndTemplatesForUserResult", \.propertiesAndTemplatesForUserResult)
        ]
    }
}

// MARK: PropertiesForFlight
/// Request for `PropertiesForFlight`.
@objc(MFBWebServiceSvc_PropertiesForFlight)
public class MFBWebServiceSvc_PropertiesForFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_PropertiesForFlightResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!

    public override class var soapElementName : String { return "PropertiesForFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PropertiesForFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight)
        ]
    }
}

/// Response from `PropertiesForFlight`.
@objc(MFBWebServiceSvc_PropertiesForFlightResponse)
public class MFBWebServiceSvc_PropertiesForFlightResponse : SoapObject {
    public var propertiesForFlightResult : MFBWebServiceSvc_ArrayOfCustomFlightProperty!

    public override class var soapElementName : String { return "PropertiesForFlightResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_PropertiesForFlightResponse>()
        return super.soapFields + [
            f.object("PropertiesForFlightResult", \.propertiesForFlightResult)
        ]
    }
}

// MARK: DeletePropertiesForFlight
/// Request for `DeletePropertiesForFlight`.
@objc(MFBWebServiceSvc_DeletePropertiesForFlight)
public class MFBWebServiceSvc_DeletePropertiesForFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeletePropertiesForFlightResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!
    public var rgPropIds : MFBWebServiceSvc_ArrayOfInt!

    public override class var soapElementName : String { return "DeletePropertiesForFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeletePropertiesForFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight),
            f.object("rgPropIds", \.rgPropIds)
        ]
    }
}

/// Response from `DeletePropertiesForFlight`.
@objc(MFBWebServiceSvc_DeletePropertiesForFlightResponse)
public class MFBWebServiceSvc_DeletePropertiesForFlightResponse : SoapObject {
    public override class var soapElementName : String { return "DeletePropertiesForFlightResponse" }

}

// MARK: DeletePropertyForFlight
/// Request for `DeletePropertyForFlight`.
@objc(MFBWebServiceSvc_DeletePropertyForFlight)
public class MFBWebServiceSvc_DeletePropertyForFlight : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeletePropertyForFlightResponse

    public var szAuthUserToken : String!
    public var idFlight : NSNumber!
    public var propId : NSNumber!

    public override class var soapElementName : String { return "DeletePropertyForFlight" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeletePropertyForFlight>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.number("idFlight", \.idFlight),
            f.number("propId", \.propId)
        ]
    }
}

/// Response from `DeletePropertyForFlight`.
@objc(MFBWebServiceSvc_DeletePropertyForFlightResponse)
public class MFBWebServiceSvc_DeletePropertyForFlightResponse : SoapObject {
    public override class var soapElementName : String { return "DeletePropertyForFlightResponse" }

}

// MARK: DeleteImage
/// Request for `DeleteImage`.
@objc(MFBWebServiceSvc_DeleteImage)
public class MFBWebServiceSvc_DeleteImage : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeleteImageResponse

    public var szAuthUserToken : String!
    public var mfbii : MFBWebServiceSvc_MFBImageInfo!

    public override class var soapElementName : String { return "DeleteImage" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteImage>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("mfbii", \.mfbii)
        ]
    }
}

/// Response from `DeleteImage`.
@objc(MFBWebServiceSvc_DeleteImageResponse)
public class MFBWebServiceSvc_DeleteImageResponse : SoapObject {
    public override class var soapElementName : String { return "DeleteImageResponse" }

}

// MARK: UpdateImageAnnotation
/// Request for `UpdateImageAnnotation`.
@objc(MFBWebServiceSvc_UpdateImageAnnotation)
public class MFBWebServiceSvc_UpdateImageAnnotation : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_UpdateImageAnnotationResponse

    public var szAuthUserToken : String!
    public var mfbii : MFBWebServiceSvc_MFBImageInfo!

    public override class var soapElementName : String { return "UpdateImageAnnotation" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_UpdateImageAnnotation>()
        return super.soapFields + [
            f.string("szAuthUserToken", \.szAuthUserToken),
            f.object("mfbii", \.mfbii)
        ]
    }
}

/// Response from `UpdateImageAnnotation`.
@objc(MFBWebServiceSvc_UpdateImageAnnotationResponse)
public class MFBWebServiceSvc_UpdateImageAnnotationResponse : SoapObject {
    public override class var soapElementName : String { return "UpdateImageAnnotationResponse" }

}

// MARK: AuthTokenForUser
/// Request for `AuthTokenForUser`.
@objc(MFBWebServiceSvc_AuthTokenForUser)
public class MFBWebServiceSvc_AuthTokenForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AuthTokenForUserResponse

    public var szAppToken : String!
    public var szUser : String!
    public var szPass : String!

    public override class var soapElementName : String { return "AuthTokenForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AuthTokenForUser>()
        return super.soapFields + [
            f.string("szAppToken", \.szAppToken),
            f.string("szUser", \.szUser),
            f.string("szPass", \.szPass)
        ]
    }
}

/// Response from `AuthTokenForUser`.
@objc(MFBWebServiceSvc_AuthTokenForUserResponse)
public class MFBWebServiceSvc_AuthTokenForUserResponse : SoapObject {
    public var authTokenForUserResult : String!

    public override class var soapElementName : String { return "AuthTokenForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AuthTokenForUserResponse>()
        return super.soapFields + [
            f.string("AuthTokenForUserResult", \.authTokenForUserResult)
        ]
    }
}

// MARK: AuthTokenForUserNew
/// Request for `AuthTokenForUserNew`.
@objc(MFBWebServiceSvc_AuthTokenForUserNew)
public class MFBWebServiceSvc_AuthTokenForUserNew : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AuthTokenForUserNewResponse

    public var szAppToken : String!
    public var szUser : String!
    public var szPass : String!
    public var sz2FactorAuth : String!

    public override class var soapElementName : String { return "AuthTokenForUserNew" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AuthTokenForUserNew>()
        return super.soapFields + [
            f.string("szAppToken", \.szAppToken),
            f.string("szUser", \.szUser),
            f.string("szPass", \.szPass),
            f.string("sz2FactorAuth", \.sz2FactorAuth)
        ]
    }
}

/// Response from `AuthTokenForUserNew`.
@objc(MFBWebServiceSvc_AuthTokenForUserNewResponse)
public class MFBWebServiceSvc_AuthTokenForUserNewResponse : SoapObject {
    public var authTokenForUserNewResult : MFBWebServiceSvc_AuthResult!

    public override class var soapElementName : String { return "AuthTokenForUserNewResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AuthTokenForUserNewResponse>()
        return super.soapFields + [
            f.object("AuthTokenForUserNewResult", \.authTokenForUserNewResult)
        ]
    }
}

// MARK: RefreshAuthToken
/// Request for `RefreshAuthToken`.
@objc(MFBWebServiceSvc_RefreshAuthToken)
public class MFBWebServiceSvc_RefreshAuthToken : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_RefreshAuthTokenResponse

    public var szAppToken : String!
    public var szUser : String!
    public var szPass : String!
    public var szPreviousToken : String!

    public override class var soapElementName : String { return "RefreshAuthToken" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_RefreshAuthToken>()
        return super.soapFields + [
            f.string("szAppToken", \.szAppToken),
            f.string("szUser", \.szUser),
            f.string("szPass", \.szPass),
            f.string("szPreviousToken", \.szPreviousToken)
        ]
    }
}

/// Response from `RefreshAuthToken`.
@objc(MFBWebServiceSvc_RefreshAuthTokenResponse)
public class MFBWebServiceSvc_RefreshAuthTokenResponse : SoapObject {
    public var refreshAuthTokenResult : String!

    public override class var soapElementName : String { return "RefreshAuthTokenResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_RefreshAuthTokenResponse>()
        return super.soapFields + [
            f.string("RefreshAuthTokenResult", \.refreshAuthTokenResult)
        ]
    }
}

// MARK: CreateUser
/// Request for `CreateUser`.
@objc(MFBWebServiceSvc_CreateUser)
public class MFBWebServiceSvc_CreateUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_CreateUserResponse

    public var szAppToken : String!
    public var szEmail : String!
    public var szPass : String!
    public var szFirst : String!
    public var szLast : String!
    public var szQuestion : String!
    public var szAnswer : String!

    public override class var soapElementName : String { return "CreateUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CreateUser>()
        return super.soapFields + [
            f.string("szAppToken", \.szAppToken),
            f.string("szEmail", \.szEmail),
            f.string("szPass", \.szPass),
            f.string("szFirst", \.szFirst),
            f.string("szLast", \.szLast),
            f.string("szQuestion", \.szQuestion),
            f.string("szAnswer", \.szAnswer)
        ]
    }
}

/// Response from `CreateUser`.
@objc(MFBWebServiceSvc_CreateUserResponse)
public class MFBWebServiceSvc_CreateUserResponse : SoapObject {
    public var createUserResult : MFBWebServiceSvc_UserEntity!

    public override class var soapElementName : String { return "CreateUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_CreateUserResponse>()
        return super.soapFields + [
            f.object("CreateUserResult", \.createUserResult)
        ]
    }
}

// MARK: GetNamedQueriesForUser
/// Request for `GetNamedQueriesForUser`.
@objc(MFBWebServiceSvc_GetNamedQueriesForUser)
public class MFBWebServiceSvc_GetNamedQueriesForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_GetNamedQueriesForUserResponse

    public var szAuthToken : String!

    public override class var soapElementName : String { return "GetNamedQueriesForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_GetNamedQueriesForUser>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken)
        ]
    }
}

/// Response from `GetNamedQueriesForUser`.
@objc(MFBWebServiceSvc_GetNamedQueriesForUserResponse)
public class MFBWebServiceSvc_GetNamedQueriesForUserResponse : SoapObject {
    public var getNamedQueriesForUserResult : MFBWebServiceSvc_ArrayOfCannedQuery!

    public override class var soapElementName : String { return "GetNamedQueriesForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_GetNamedQueriesForUserResponse>()
        return super.soapFields + [
            f.object("GetNamedQueriesForUserResult", \.getNamedQueriesForUserResult)
        ]
    }
}

// MARK: AddNamedQueryForUser
/// Request for `AddNamedQueryForUser`.
@objc(MFBWebServiceSvc_AddNamedQueryForUser)
public class MFBWebServiceSvc_AddNamedQueryForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_AddNamedQueryForUserResponse

    public var szAuthToken : String!
    public var fq : MFBWebServiceSvc_FlightQuery!
    public var szName : String!

    public override class var soapElementName : String { return "AddNamedQueryForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AddNamedQueryForUser>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.object("fq", \.fq),
            f.string("szName", \.szName)
        ]
    }
}

/// Response from `AddNamedQueryForUser`.
@objc(MFBWebServiceSvc_AddNamedQueryForUserResponse)
public class MFBWebServiceSvc_AddNamedQueryForUserResponse : SoapObject {
    public var addNamedQueryForUserResult : MFBWebServiceSvc_ArrayOfCannedQuery!

    public override class var soapElementName : String { return "AddNamedQueryForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_AddNamedQueryForUserResponse>()
        return super.soapFields + [
            f.object("AddNamedQueryForUserResult", \.addNamedQueryForUserResult)
        ]
    }
}

// MARK: DeleteNamedQueryForUser
/// Request for `DeleteNamedQueryForUser`.
@objc(MFBWebServiceSvc_DeleteNamedQueryForUser)
public class MFBWebServiceSvc_DeleteNamedQueryForUser : SoapObject, SoapRequest {
    public typealias Response = MFBWebServiceSvc_DeleteNamedQueryForUserResponse

    public var szAuthToken : String!
    public var cq : MFBWebServiceSvc_CannedQuery!

    public override class var soapElementName : String { return "DeleteNamedQueryForUser" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteNamedQueryForUser>()
        return super.soapFields + [
            f.string("szAuthToken", \.szAuthToken),
            f.object("cq", \.cq)
        ]
    }
}

/// Response from `DeleteNamedQueryForUser`.
@objc(MFBWebServiceSvc_DeleteNamedQueryForUserResponse)
public class MFBWebServiceSvc_DeleteNamedQueryForUserResponse : SoapObject {
    public var deleteNamedQueryForUserResult : MFBWebServiceSvc_ArrayOfCannedQuery!

    public override class var soapElementName : String { return "DeleteNamedQueryForUserResponse" }

    public override class var soapFields : [SoapField] {
        let f = SoapFieldBuilder<MFBWebServiceSvc_DeleteNamedQueryForUserResponse>()
        return super.soapFields + [
            f.object("DeleteNamedQueryForUserResult", \.deleteNamedQueryForUserResult)
        ]
    }
}
