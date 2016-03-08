//
// Created by Alexander Babaev on 06.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

//public protocol KTVModelMapper {}

public struct KTVModelBasicMapper {
    //MARK: Helpers

//    static func parseKTVFromString_<T: KTVParseable>(string:String) -> T {
//        do {
//            return T(ktvLenient:try KTVParser(charGenerator:KTVParserCharGeneratorFromString(string:string)).parseAsObject())
//        } catch {
//            print("Error parsing \(T.self) from string")
//        }
//
//        return T(ktvLenient:KTVObject())
//    }

    static func printErrors(errors:[String:ErrorType]) {
        if !errors.isEmpty {
            print("RootObject parsing errors:")
            for (name, error) in errors {
                print("  property \(name): \(error)")
            }
        }
    }

    static private func deoptionizeValue<T>(value:T?, defaultValue:T) -> T {
        if let value_ = value {
            return value_
        } else {
            return defaultValue
        }
    }

    static public func getGeneralObject(name name:String, ktv:KTVObject) throws -> KTVObject? {
        var result:KTVObject? = nil

        if let property = ktv.properties[name], case .object(_, let object) = property {
            result = object
        }

        return result
    }
}
