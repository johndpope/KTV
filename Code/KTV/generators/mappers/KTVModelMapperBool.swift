//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperBool: KTVModelMapper<Bool> {
    static let instance = KTVModelMapperBool()

    public override func parseOptionalValue(ktvValue:KTVValue?, defaultValue:Bool?) throws -> Bool? {
        if let value = ktvValue {
            return try KTVValue.boolResolver(value)
        } else {
            return defaultValue
        }
    }

    public override func compose(value:Bool?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.bool(value!)
    }
}
