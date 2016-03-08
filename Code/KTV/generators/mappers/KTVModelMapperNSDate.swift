//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperNSDate: KTVModelMapper<NSDate> {
    static let instance = KTVModelMapperNSDate()

    public override func parseOptionalValue(ktvValue:KTVValue?, defaultValue:NSDate?) throws -> NSDate? {
        if let value = ktvValue {
            return try KTVValue.dateResolver(value)
        } else {
            return defaultValue
        }
    }

    public override func compose(value:NSDate?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.string(DateUtils.stringFromDate(value!))
    }
}
