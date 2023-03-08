/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2009-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
//
// FlightProps.swift
// MyFlightbook
//
// Created by Eric Berman on 3/5/23.
//

import Foundation

enum PropTypeID : Int {
    case nightTakeOff = 73
    case solo = 77
    case IPC = 41
    case BFR = 44
    case nameOfPIC = 183
    case nameOfSIC = 184
    case nameOfCFI = 92
    case nameOfStudent = 166
    case tachStart = 95
    case tachEnd = 96
    case approachName = 267
    case blockOut = 187
    case blockIn = 186
    case flightCost = 415
    case lessonStart = 668
    case lessonEnd = 669
    case groundInstructionGiven = 198
    case groundInstructionReceived = 158
    case fuelAtStart = 622
    case fuelAtEnd = 72
    case fuelConsumed = 71
    case fuelBurnRate = 381
    
    case NEW_PROP_ID = -1
}
