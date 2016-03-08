//
// Created by Alexander Babaev on 05.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public struct DateUtils {
    private static let dateISOFull = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    private static var _formattersCache = [String:NSDateFormatter]()

    public static func formatter(format:String) -> NSDateFormatter {
        if let result = _formattersCache[format] {
            return result
        } else {
            let result = NSDateFormatter()
            result.dateFormat = format
            _formattersCache[format] = result

            return result
        }
    }

    public static func parseStandardFormats(presumablyDate:String) -> NSDate? {
        let formatsToTry = [
                dateISOFull,
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd HH:mm:ssZ",
                "yyyy-MM-dd HH:mm:ss",
                "yyyy-MM-dd HH:mm",
                "yyyy-MM-dd",
                "dd-MM-yyyy",
                "MM-dd-yyyy",
        ]

        var result:NSDate? = nil

        for format in formatsToTry {
            if let result_ = formatter(format).dateFromString(presumablyDate) {
                result = result_
                break
            }
        }

        return result
    }

    public static func dateFromUnixTimestamp(value:Int) -> NSDate? {
        guard value >= 0 else {
            return nil
        }

        return NSDate(timeIntervalSince1970:Double(value))
    }

    public static func dateFromMacTimestamp(value:Double) -> NSDate? {
        guard value >= 0 else {
            return nil
        }

        return NSDate(timeIntervalSince1970:value)
    }

    public static func stringFromDate(value:NSDate) -> String {
        return formatter(dateISOFull).stringFromDate(value)
    }
}
