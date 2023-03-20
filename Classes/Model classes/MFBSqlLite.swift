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
//  MFBSqlLite.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/9/23.
//

import Foundation
import SQLite3

/// Class to provide support for sqlite in MyFlightbook.
@objc public class MFBSqlLite : NSObject {
    private static var _db : OpaquePointer? = nil
    
    @objc public static var current : OpaquePointer {
        get {
            if (_db == nil) {
                createCopyOfDatabaseIfNeeded()
            }
            assert(_db != nil, "Database was not created!")
            return _db!
        }
    }

    @objc public static func closeDB() {
        if (_db != nil) {
            sqlite3_close(_db)
            _db = nil
        }
    }
    
    private static func createCopyOfDatabaseIfNeeded() {
        // commented code below copies the database to the user's document directory.
        // this makes sense if we want read/write, but we don't need write capabilities,
        // so we can just use it in-situ.
        
        /*
        BOOL success = NO;
        NSFileManager * filemanager = [NSFileManager defaultManager];
        NSError * error;
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * szDBPath = [documentsDirectory stringByAppendingPathComponent:@"mfb.sqlite"];
        success = [filemanager fileExistsAtPath:szDBPath];
        if (!success) // needs to be copied - should only ever need to do this once.
        {
            NSString * szDefault = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mfb.sqlite"];
            success = [filemanager copyItemAtPath:szDefault toPath:szDBPath error:&error];
        }
        
        if (success) // should be true here - now initialize the db
        {
            if (sqlite3_open([szDBPath UTF8String], &db) != SQLITE_OK)
            {
                NSLog(@"Failed to open database at path %@", szDBPath);
                sqlite3_close(db);
                db = nil;
            }
        }
        else
            NSLog(@"Failed to create database file with message '%@'.", [error localizedDescription]);
      */
        
        let szDBPath = Bundle.main.resourceURL!.appendingPathComponent("mfb.sqlite")

        if (sqlite3_open_v2(szDBPath.path, &MFBSqlLite._db, SQLITE_OPEN_READONLY, nil) != SQLITE_OK) {
            NSLog("Failed to open database at path %@", szDBPath.description)
            sqlite3_close(MFBSqlLite._db)
            MFBSqlLite._db = nil;
        }
        
        // thanks to http://www.thismuchiknow.co.uk/?p=71 for this code & instructions.
        sqlite3_create_function(MFBSqlLite._db,                     // database
                                "distance".cString(using: .utf8),   // name of the function
                                4,                                  // Number of arguments
                                SQLITE_UTF8,                        // text encoding
                                nil,                                // Arbitrary - unused
                                {context, argc, arguments in        // the function

            // check that we have four arguments (lat1, lon1, lat2, lon2)
            assert(argc == 4, "Incorrect number of arguments for distance function")
            let argv = Array(UnsafeBufferPointer(start: arguments, count: Int(argc)))
            if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
                sqlite3_result_null(context);
                return;
            }
            
            // get the four argument values
            let lat1 = sqlite3_value_double(argv[0]);
            let lon1 = sqlite3_value_double(argv[1]);
            let lat2 = sqlite3_value_double(argv[2]);
            let lon2 = sqlite3_value_double(argv[3]);
            
            // convert lat1 and lat2 into radians now, to avoid doing it twice below
            let lat1rad = lat1.degreesToRadians()
            let lat2rad = lat2.degreesToRadians()
            
            // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
            // 6378.1 is the approximate radius of the earth in kilometres
            sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(lon2.degreesToRadians() - lon1.degreesToRadians())) * 3440.06479);
        },
                                nil,                                // scalar - unneded
                                nil);                               // also unneded
    }
}
