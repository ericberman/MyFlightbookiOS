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
//  SharedWatch.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/22/23.
//

import Foundation

@objc public enum NewFlightStages : Int {
    case unknown
    case unstarted
    case inprogress
    case done
}

// Dictionary key for kinds of messages
public let WATCH_MESSAGE_REQUEST_DATA = "messageRequestData"
public let WATCH_MESSAGE_ACTION = "messageRequestAction"

// Dictionary key for data requests
public let WATCH_REQUEST_STATUS = "watchRequestStatus"
public let WATCH_REQUEST_CURRENCY = "watchRequestCurrency"
public let WATCH_REQUEST_TOTALS = "watchRequestTotals"
public let WATCH_REQUEST_RECENTS = "watchRequestRecents"
public let WATCH_REQUEST_GLANCE = "watchRequestGlance"

// Dictionary key for result data
public let WATCH_RESPONSE_STATUS  = "sharedwatchStatus"
public let WATCH_RESPONSE_CURRENCY = "sharedwatchCurrency"
public let WATCH_RESPONSE_TOTALS = "sharedwatchTotals"
public let WATCH_RESPONSE_RECENTS = "sharedWatchRecents"

// Dictionary key for requested actions
public let WATCH_ACTION_START = "actionStartFlight"
public let WATCH_ACTION_END = "actionEndFlight"
public let WATCH_ACTION_TOGGLE_PAUSE = "actionTogglePause"

// Note that we MUST decorate the classes with "@objc(name-of-class)" so that these are correctly received from a namespace perspective by the watchkit extension.
// Otherwise archive/dearchive doesn't work because the class names (with namespaces) don't line up.
// Alternatively, we could also put these into a framework
// See https://stackoverflow.com/questions/29472935/cannot-decode-object-of-class for more information.

@objc(SharedWatch) public class SharedWatch : NSObject, NSCoding, NSSecureCoding {
    private let keyWatchLatitude = "LAT"
    private let keyWatchLongitude = "LON"
    private let keyWatchSpeed = "SPEED"
    private let keyWatchAlt = "ALT"
    private let keyWatchFlightStatus = "FLIGHTSTATUS"
    private let keyWatchElapsed = "FLIGHTELAPSED"
    private let keyWatchIsPaused = "FLIGHTPAUSED"
    private let keyWatchIsRecording = "FLIGHTRECORDING"
    private let keyWatchFlightStage = "FlightStage"
    private let keyWatchLatestFlight = "LASTFLIGHT"
    
    @objc public var latDisplay = ""
    @objc public var lonDisplay = ""
    @objc public var speedDisplay = ""
    @objc public var altDisplay = ""
    @objc public var flightstatus = ""
    @objc public var isPaused = false
    @objc public var isRecording = false
    @objc public var elapsedSeconds = 0.0
    @objc public var flightStage = NewFlightStages.unknown
    @objc public var latestFlight : SimpleLogbookEntry? = nil
    
    @objc public override init() {
        super.init()
    }

    @objc public required init?(coder: NSCoder) {
        latDisplay = coder.decodeObject(forKey: keyWatchLatitude) as? String ?? ""
        lonDisplay = coder.decodeObject(forKey: keyWatchLongitude) as? String ?? ""
        altDisplay = coder.decodeObject(forKey: keyWatchAlt) as? String ?? ""
        speedDisplay = coder.decodeObject(forKey: keyWatchSpeed) as? String ?? ""
        flightstatus = coder.decodeObject(forKey: keyWatchFlightStatus) as? String ?? ""
        latestFlight = coder.decodeObject(forKey: keyWatchLatestFlight) as? SimpleLogbookEntry
        isPaused = coder.decodeBool(forKey: keyWatchIsPaused)
        isRecording = coder.decodeBool(forKey: keyWatchIsRecording)
        elapsedSeconds = coder.decodeDouble(forKey: keyWatchElapsed)
        flightStage = NewFlightStages(rawValue: coder.decodeInteger(forKey: keyWatchFlightStage))!
    }
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode(latDisplay, forKey: keyWatchLatitude)
        coder.encode(lonDisplay, forKey: keyWatchLongitude)
        coder.encode(altDisplay, forKey: keyWatchAlt)
        coder.encode(speedDisplay, forKey: keyWatchSpeed)
        coder.encode(flightstatus, forKey: keyWatchFlightStatus)
        coder.encode(latestFlight, forKey: keyWatchLatestFlight)
        coder.encode(isPaused, forKey: keyWatchIsPaused)
        coder.encode(isRecording, forKey: keyWatchIsRecording)
        coder.encode(elapsedSeconds, forKey: keyWatchElapsed)
        coder.encode(flightStage.rawValue, forKey: keyWatchFlightStage)
    }
    
    @objc public static var supportsSecureCoding: Bool {
        return true
    }
}
