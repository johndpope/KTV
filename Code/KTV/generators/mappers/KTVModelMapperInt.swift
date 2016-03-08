//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperInt: KTVModelMapper<Int> {
    static let instance = KTVModelMapperInt()

    public override func parseOptionalValue(ktvValue:KTVValue?, defaultValue:Int?) throws -> Int? {
        if let value = ktvValue {
            return try KTVValue.intResolver(value)
        } else {
            return defaultValue
        }
    }

    public override func compose(value:Int?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.int(value!)
    }
}
