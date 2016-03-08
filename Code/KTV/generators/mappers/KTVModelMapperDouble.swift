//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperDouble: KTVModelMapper<Double> {
    static let instance = KTVModelMapperDouble()

    public override func parseOptionalValue(ktvValue:KTVValue?, defaultValue:Double?) throws -> Double? {
        if let value = ktvValue {
            return try KTVValue.doubleResolver(value)
        } else {
            return defaultValue
        }
    }

    public override func compose(value:Double?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.double(value!)
    }
}
