//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperArray<T>: KTVModelMapper<[T]> {
    private let valueMapper:KTVModelMapper<T>

    init(valueMapper:KTVModelMapper<T>) {
        self.valueMapper = valueMapper
    }

    public override func parseOptionalValue(ktvValue: KTVValue?, defaultValue: [T]? = [T]?()) throws -> [T]? {
        if let value = ktvValue {
            return try KTVValue.arrayResolver(value, valueResolver:{
                try self.valueMapper.parseOptionalValue($0, defaultValue:nil)
            })
        } else {
            return defaultValue
        }
    }

    public override func compose(value:[T]?) throws -> KTVValue {
        return value == nil ? KTVValue.nilValue : KTVValue.array("", try value!.map({
            try self.valueMapper.compose($0)
        }))
    }
}
