//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperString: KTVModelMapper<String> {
    static let instance = KTVModelMapperString()

    public override func parseOptionalValue(ktvValue:KTVValue?, defaultValue:String? = String?()) throws -> String? {
        if let value = ktvValue {
            return try KTVValue.stringResolver(value)
        } else {
            return defaultValue
        }
    }

    public override func compose(value:String?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.string(value!)
    }
}
