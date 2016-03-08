//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVModelMapperDictionary<T>: KTVModelMapper<[String:T]> {
    private let valueMapper:KTVModelMapper<T>

    init(valueMapper:KTVModelMapper<T>) {
        self.valueMapper = valueMapper
    }

    public override func parseOptionalValue(ktvValue: KTVValue?, defaultValue: [String:T]?) throws -> [String:T]? {
        if let value = ktvValue {
            return try KTVValue.dictionaryResolver(value, valueResolver:{
                try self.valueMapper.parseOptionalValue($0, defaultValue:nil)
            })
        } else {
            return defaultValue
        }
    }

    public override func compose(value:[String:T]?) throws -> KTVValue {
        let result = KTVObject()

        if let value = value {
            for (name, item) in value {
                var ktvValue:KTVValue = .nilValue

                switch item {
                    case let string as String:
                        ktvValue = .string(string)
                    case let int as Int:
                        ktvValue = .int(int)
                    case let double as Double:
                        ktvValue = .double(double)
                    case let bool as Bool:
                        ktvValue = .bool(bool)
                    case let object as KTVSerializable:
                        ktvValue = .object("", try object.ktvObject())
                    default:
                        throw KTVModelObjectSerializableError.CantSerializeValueToObject
                }

                result.setProperty(name:name, value:ktvValue)
            }
        }

        return KTVValue.object("", result)
    }
}
