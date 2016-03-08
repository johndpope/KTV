//
// Created by Alexander Babaev on 13.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

enum KTVModelObjectSerializableError: ErrorType {
    case CantSerializeValueToObject
}

public protocol KTVSerializable {
    func ktvObject() throws -> KTVObject
}

extension KTVSerializable {
    public func json() throws -> String {
        return try ktvObject().json()
    }

    public func ktv() throws -> String {
        return try ktvObject().ktv()
    }

    //MARK: Helpers

    static func valueFromString(value:String) -> KTVValue {
        return KTVValue.string(value)
    }

    func getObjectDictionary<T>(dictionary:[String:T]) throws -> KTVObject {
        let result = KTVObject()

        for (name, value) in dictionary {
            var ktvValue:KTVValue = .nilValue

            switch value {
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

        return result
    }
}
