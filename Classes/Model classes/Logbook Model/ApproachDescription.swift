/*
    MyFlightbook for iOS - provides native access to MyFlightbook
    pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  ApproachDescription.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/11/23.
//

import Foundation

@objc public class ApproachDescription : NSObject {
    @objc public var approachCount = 0
    @objc public var approachName = ""
    @objc public var runwayName = ""
    @objc public var airportName = ""
    @objc public var addToTotals = true

    @objc public override init() {
        super.init()
    }
    
    @objc public static var ApproachNames : [String] {
        get {
            return ["CONTACT",
                     "COPTER",
                     "GCA",
                     "GLS",
                     "ILS",
                     "ILS (Cat I)",
                     "ILS (Cat II)",
                     "ILS (Cat III)",
                     "ILS/PRM",
                     "JPLAS",
                     "LAAS",
                     "LDA",
                     "LOC",
                     "LOC-BC",
                     "MLS",
                     "NDB",
                     "OSAP",
                     "PAR",
                     "RNAV/GPS",
                     "SDF",
                     "SRA/ASR",
                     "TACAN",
                     "TYPE1",
                     "TYPE2",
                     "TYPE3",
                     "TYPE4",
                     "TYPEA",
                     "TYPEB",
                     "VISUAL",
                     "VOR",
                     "VOR/DME",
                     "VOR/DME-ARC"]
        }
    }
    
    @objc public static var ApproachSuffixes : [String] {
        get {
            return ["", "-A", "-B", "-C", "-D", "-V", "-W", "-X", "-Y", "-Z"]
        }
    }
    
    @objc public static var RunwayNames : [String] {
        return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18",
                 "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36"]
    }
    
    @objc public static var RunwayModifiers : [String] {
        ["", "L", "R", "C"];
    }
    
    @objc public override var description: String {
        get {
            return self.approachCount == 0 ? "" : "\(approachCount)\(approachName.isEmpty ? "" : "-" + approachName)\(runwayName.isEmpty ? "" :"-RWY")\(self.runwayName)\(airportName.isEmpty ? "" : airportName)"
        }
    }
}
