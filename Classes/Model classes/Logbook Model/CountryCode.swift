//
//  CountryCode.swift
//  MyFlightbook
//
//  Created by Eric Berman on 3/9/23.
//

import Foundation
import SQLite3

@objc public class CountryCode : NSObject {
    private let ID : Int
    private let LocaleCode : String
    @objc public let Prefix : String
    private let CountryName : String
    
    private static var rgAllCountryCodes : [CountryCode] = []
    
    private init(_ row: OpaquePointer!) {
        ID = Int(sqlite3_column_int(row, 0))
        var sz = sqlite3_column_text(row, 1)
        Prefix = sz == nil ? "" : String(cString: sz!)
        sz = sqlite3_column_text(row, 2)
        LocaleCode = sz == nil ? "" : String(cString: sz!)
        sz = sqlite3_column_text(row, 3)
        CountryName = sz == nil ? "" : String(cString: sz!)
        super.init()
    }
    
    public override var description : String {
        get {
            return String(format: "%d: %@ %@ %@", ID, Prefix, LocaleCode, CountryName)
        }
    }
    
    private static var AllCountryCodes : [CountryCode] {
        get {
            if (!rgAllCountryCodes.isEmpty) {
                return rgAllCountryCodes
            }
            
            var sqlCountryCodes : OpaquePointer?
            let db = MFBSqlLite.current
            
            if (sqlite3_prepare(db, "SELECT * FROM countrycodes ORDER BY Prefix ASC".cString(using: .ascii), -1, &sqlCountryCodes, nil) != SQLITE_OK) {
                NSLog("Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db))
            }
            
            while (sqlite3_step(sqlCountryCodes) == SQLITE_ROW) {
                rgAllCountryCodes.append(CountryCode(sqlCountryCodes))
            }
            
            sqlite3_finalize(sqlCountryCodes)
            return rgAllCountryCodes
        }
    }
    
    @objc public static func BestGuessForLocale(_ locale : String) -> CountryCode {
        let rg = AllCountryCodes
        
        let rgMatches = rg.filter() { $0.LocaleCode.compare(locale, options:.caseInsensitive) == .orderedSame }

        if (rgMatches.isEmpty) {
            return rg[0]
        }
        
        let rgSorted = rgMatches.sorted { cc1, cc2 in
            return cc1.Prefix.compare(cc2.Prefix, options: .caseInsensitive) != .orderedDescending
        }
        
        return rgSorted[0]
    }
    
    @objc public static func BestGuessForCurrentLocale() -> CountryCode {
        return BestGuessForLocale((Locale.current as NSLocale).object(forKey: .countryCode) as! String)
    }
    
    // return the longest country code that is a prefix for the given tail number
    @objc public static func BestGuessPrefixForTail(_ szTail : String) -> CountryCode? {
        var result : CountryCode? = nil
        var maxLength = 0
        
        let rg = AllCountryCodes
        var idx = rg.count - 1
        for cc in rg {
            if (szTail.hasPrefix(cc.Prefix) && cc.Prefix.count > maxLength) {
                result = cc
                maxLength = cc.Prefix.count
            }
            idx -= 1
        }
        
        return result
    }
}
