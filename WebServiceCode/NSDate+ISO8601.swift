//
//  NSDate+ISO8601.swift
//  MyFlightbook
//
//  Swift replacement for the NSDate+ISO8601Parsing / NSDate+ISO8601Unparsing Objective-C categories
//  (originally by Peter Hosey, modified by Matthew Faupel).
//
//  Parsing accepts the ISO 8601 forms that the MyFlightbook service, GPX/KML files and the app itself produce:
//
//      date:   YYYY-MM-DD   YYYYMMDD   YYYY-MM   YYYY   YYYY-DDD   YYYYDDD   YYYY-Www-D   YYYYWwwD
//      time:   Thh   Thh:mm   Thh:mm:ss   Thh:mm:ss.fff        (also accepts a space instead of the T, and a bare "Thh:mm")
//      zone:   Z   +hh   +hh:mm   +hhmm   -hh:mm              (no zone = UTC, as the original did)
//
//  Like the original "loose" parser, leading whitespace is ignored and anything after the date is ignored.
//  The original's two-digit-year / implied-year forms ("-YY-MM", "--MMDD", ...) are not supported; nothing used them.
//
//  Formatting always produces UTC: "yyyy-MM-dd'T'HH:mm:ss'Z'" (or just "yyyy-MM-dd").
//

import Foundation

public enum ISO8601 {
    private static var utc : Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }()

    private static let formatter : DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")   // otherwise AM/PM can be appended on some devices
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()

    // MARK: Formatting
    public static func string(from date: Date, includeTime: Bool = true) -> String {
        formatter.dateFormat = includeTime ? "yyyy-MM-dd'T'HH:mm:ss'Z'" : "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // MARK: Parsing
    /// A tiny cursor over the UTF-8 bytes of the string being parsed.
    private struct Scanner {
        let b : [UInt8]
        var i = 0
        init(_ s : String) { b = Array(s.utf8) }

        var cur : UInt8 { return i < b.count ? b[i] : 0 }
        var isDigit : Bool { return cur >= 48 && cur <= 57 }
        mutating func skipSpace() { while cur == 32 || (cur >= 9 && cur <= 13) { i += 1 } }
        mutating func accept(_ c : Character) -> Bool {
            if cur == c.asciiValue! { i += 1; return true }
            return false
        }
        /// Reads up to `max` digits; returns the value and how many were read.
        mutating func digits(max : Int = Int.max) -> (value : Int, count : Int) {
            var v = 0, n = 0
            while isDigit && n < max { v = v * 10 + Int(cur - 48); i += 1; n += 1 }
            return (v, n)
        }
        /// Digits with an optional fraction, using '.' or ','.  "30.5" -> 30.5
        mutating func decimal() -> Double {
            var v = Double(digits().value)
            if cur == 46 || cur == 44 {
                i += 1
                var scale = 0.1
                while isDigit { v += Double(cur - 48) * scale; scale /= 10; i += 1 }
            }
            return v
        }
    }

    /// Returns the parsed date, or nil if the string doesn't begin with a recognizable ISO 8601 date.
    public static func date(from string: String) -> Date? {
        var s = Scanner(string)
        s.skipSpace()
        guard s.i < s.b.count else { return nil }

        var base : Date      // midnight UTC on the date (or "today" for a bare time)

        if s.cur == 84 /* T */ {
            // Time only - use today's date
            let c = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
            guard let d = utc.date(from: c) else { return nil }
            base = d
            s.i += 1
            guard s.isDigit else { return nil }
        } else {
            let first = s.digits()
            var year = 0, month = 1, day = 1
            var ordinal : Int? = nil
            var week : (w : Int, d : Int)? = nil

            switch first.count {
            case 8:     // YYYYMMDD
                day = first.value % 100; month = (first.value / 100) % 100; year = first.value / 10000
            case 7:     // YYYYDDD
                ordinal = first.value % 1000; year = first.value / 1000
            case 4:
                year = first.value
                _ = s.accept("-")
                if s.cur == 87 /* W */ {
                    s.i += 1
                    week = parseWeek(&s)
                } else if s.isDigit {
                    let seg = s.digits()
                    switch seg.count {
                    case 4: month = seg.value / 100; day = seg.value % 100          // MMDD
                    case 2:                                                         // MM[-DD]
                        month = seg.value
                        _ = s.accept("-")
                        if s.isDigit { day = s.digits().value }
                    case 3: ordinal = seg.value                                     // DDD
                    default: return nil
                    }
                }
            default:
                return nil
            }

            guard let jan1 = utc.date(from: DateComponents(year: year, month: 1, day: 1)) else { return nil }
            if let o = ordinal {
                base = utc.date(byAdding: .day, value: o - 1, to: jan1)!
            } else if let wk = week {
                // ISO weeks: week 1 contains January 4th; weeks start on Monday
                let jan4 = utc.date(byAdding: .day, value: 3, to: jan1)!
                let isoWeekday = (utc.component(.weekday, from: jan4) + 5) % 7 + 1    // Monday = 1
                let monday = utc.date(byAdding: .day, value: -(isoWeekday - 1), to: jan4)!
                base = utc.date(byAdding: .day, value: (wk.w - 1) * 7 + (wk.d - 1), to: monday)!
            } else {
                guard let d = utc.date(from: DateComponents(year: year, month: month, day: day)) else { return nil }
                base = d
            }

            if s.cur == 84 /* T */ || s.cur == 32 { s.i += 1 }
        }

        var seconds = 0.0
        var offset = 0

        if s.isDigit {
            let hour = Double(s.digits(max: 2).value)
            var minute = 0.0, second = 0.0
            if s.accept(":") {
                minute = s.decimal()                    // may carry a fraction of a minute
                let whole = minute.rounded(.down)
                let frac = minute - whole
                minute = whole
                if frac > Double.ulpOfOne {
                    second = frac * 60
                } else if s.accept(":") {
                    second = s.decimal()
                }
            }
            seconds = hour * 3600 + minute * 60 + second

            // Time zone: Z, or +hh[:mm] / -hh[:mm]; absent means UTC
            if s.cur == 43 || s.cur == 45 {
                let sign = s.cur == 45 ? -1 : 1
                s.i += 1
                if s.isDigit {
                    let h = s.digits(max: 2).value
                    _ = s.accept(":")
                    let m = s.isDigit ? s.digits(max: 2).value : 0
                    offset = sign * (h * 3600 + m * 60)
                }
            }
        }

        return base.addingTimeInterval(seconds - Double(offset))
    }

    private static func parseWeek(_ s : inout Scanner) -> (w : Int, d : Int)? {
        let w = s.digits(max: 2)
        guard w.count == 2 else { return nil }
        _ = s.accept("-")
        let d = s.isDigit ? s.digits(max: 1).value : 1
        return (w.value, d)
    }
}

// MARK: - NSDate / Date API (same spellings the old categories had when imported into Swift)

extension NSDate {
    /// Parses an ISO 8601 string; nil if it can't be parsed.  (Was `+dateWithISO8601String:`.)
    public convenience init!(iso8601String str : String!) {
        guard let str = str, let d = ISO8601.date(from: str) else { return nil }
        self.init(timeIntervalSinceReferenceDate: d.timeIntervalSinceReferenceDate)
    }

    /// "yyyy-MM-dd'T'HH:mm:ssZ" in UTC.  (Was `-ISO8601DateString`.)
    @objc public func iso8601DateString() -> String {
        return ISO8601.string(from: self as Date)
    }

    /// With includeTime false, just "yyyy-MM-dd".  (Was `-ISO8601DateStringWithTime:`.)
    @objc public func iso8601DateString(includeTime : Bool) -> String {
        return ISO8601.string(from: self as Date, includeTime: includeTime)
    }
}

extension Date {
    public init?(iso8601String str : String) {
        guard let d = ISO8601.date(from: str) else { return nil }
        self = d
    }

    public func iso8601DateString(includeTime : Bool = true) -> String {
        return ISO8601.string(from: self, includeTime: includeTime)
    }
}
