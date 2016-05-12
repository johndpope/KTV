//
// Created by Alexander Babaev on 05.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

extension KTVValue {
    //MARK: simple resolvers

    static func stringResolver(value:KTVValue) throws -> String? {
        if case .string(let result) = value {
            return result
        } else if case .int(let result) = value {
            return "\(result)"
        } else if case .double(let result) = value {
            return "\(result)"
        } else if case .bool(let result) = value {
            return "\(result)"
        } else if case .nilValue = value {
            return nil
        }

        throw KTVModelObjectParseableError.WrongStringValue
    }

    static func intResolver(value:KTVValue) throws -> Int? {
        if case .int(let result) = value {
            return result
        } else if case .nilValue = value {
            return nil
        }

        throw KTVModelObjectParseableError.WrongIntValue
    }

    static func boolResolver(value:KTVValue) throws -> Bool? {
        if case .bool(let result) = value {
            return result
        } else if case .nilValue = value {
            return nil
        }

        throw KTVModelObjectParseableError.WrongBoolValue
    }

    static func doubleResolver(value:KTVValue) throws -> Double? {
        if case .int(let result) = value {
            return Double(result)
        } else if case .double(let result) = value {
            return result
        } else if case .nilValue = value {
            return nil
        }

        throw KTVModelObjectParseableError.WrongDoubleValue
    }

    static func arrayResolver<T>(value:KTVValue, valueResolver:(value:KTVValue) throws -> T?) throws -> [T]? {
        var resultArray:[T]? = nil

        if case .array(_, let items) = value {
            var resultArray_:[T] = []
            for item in items {
                if let value = try valueResolver(value:item) {
                    resultArray_.append(value)
                } else {
                    throw KTVModelObjectParseableError.WrongArrayItemValue
                }
            }

            resultArray = resultArray_
        } else if case .nilValue = value {
            return nil
        } else {
            throw KTVModelObjectParseableError.WrongArrayValue
        }

        return resultArray
    }

    static func dictionaryResolver<T>(value:KTVValue, valueResolver:(value:KTVValue) throws -> T?) throws -> [String:T]? {
        var resultDictionary:[String:T]? = nil

        if case .object(_, let object) = value {
            var resultDictionary_:[String:T] = [:]
            for (key, item) in object.properties {
                if let value = try valueResolver(value:item) {
                    resultDictionary_[key] = value
                } else {
                    throw KTVModelObjectParseableError.WrongDictionaryItemValue
                }
            }

            resultDictionary = resultDictionary_
        } else if case .nilValue = value {
            return nil
        } else {
            throw KTVModelObjectParseableError.WrongDictionaryValue
        }

        return resultDictionary
    }
}

extension KTVValue {
    //MARK: complex resolvers

    static func dateResolver(value:KTVValue) throws -> NSDate? {
        if case .string(let string) = value {
            return DateUtils.parseStandardFormats(string)
        } else if case .int(let int) = value {
            return DateUtils.dateFromUnixTimestamp(int)
        } else if case .double(let double) = value {
            return DateUtils.dateFromMacTimestamp(double)
        } else if case .nilValue = value {
            return nil
        }

        throw KTVModelObjectParseableError.WrongDateValue
    }
}