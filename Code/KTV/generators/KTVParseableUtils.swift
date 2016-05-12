//
// Created by Alexander Babaev on 04.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public protocol KTVMapper {
    associatedtype KTVType
    associatedtype SwiftType

    var value:SwiftType { get set }

    func parseFromKTV(ktvValue:KTVType)
    func formatToKTV() -> KTVType
}

public class KTVDateMapper: KTVMapper {
    let formatter:NSDateFormatter

    public var value:NSDate

    public func parseFromKTV(ktvValue:String) {
        if let value = self.formatter.dateFromString(ktvValue) {
            self.value = value
        }
    }

    public func formatToKTV() -> String {
        return self.formatter.stringFromDate(self.value)
    }

    init(format:String) {
        value = NSDate()

        formatter = NSDateFormatter()
        formatter.dateFormat = format
    }
}

public class KTVTimestampDateMapper: KTVMapper {
    public var value:NSDate = NSDate()

    public func parseFromKTV(ktvValue:Int) {
        value = NSDate(timeIntervalSince1970:NSTimeInterval(ktvValue))
    }

    public func formatToKTV() -> Int {
        return Int(value.timeIntervalSince1970)
    }
}
