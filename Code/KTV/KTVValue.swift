//
// Created by Alexander Babaev on 13.01.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public enum KTVValue {
    case nilValue                         // nil

    case string(String)                   // "..."
    case bool(Bool)                       // true or false
    case int(Int)                         // 123
    case double(Double)                   // -23.123

    case color(String)                    // #RRGGBBAA

    case object(String, KTVObject)        // object
    case array(String, [KTVValue])        // array

    case reference(String)                // reference to another value in a format @name.name.name. All names except last must refer to an object

    var type:String {
        var result = ""

        switch self {
            case .nilValue:
                result = "nil"
            case .bool(_):
                result = "bool"
            case .string(_):
                result = "string"
            case .int(_):
                result = "int"
            case .double(_):
                result = "double"

            case .color(_):
                result = "color"

            case .object(_, _):
                result = "object"
            case .array(_, _):
                result = "array"

            case .reference(_):
                result = "reference"
        }

        return result
    }

    var description:String {
        return asString(asJson:false)
    }

    public func asString(asJson asJson:Bool) -> String {
        var result = ""

        switch self {
            case .nilValue:
                result.appendContentsOf(asJson ? ": null" : ": nil")
            case .bool(let bool):
                result.appendContentsOf((asJson ? "" : "(bool)") + ": \(bool)")
            case .string(let string):
                result.appendContentsOf((asJson ? "" : "(string)") + ": \"\(string)\"")
            case .int(let int):
                result.appendContentsOf((asJson ? "" : "(int)") + ": \(int)")
            case .double(let double):
                result.appendContentsOf((asJson ? "" : "(double)") + ": \(double)")

            case .color(let string):
                result.appendContentsOf(asJson ? ": \"\(string)\"" : "(color): #\(string)")

            case .object(let type, let element):
                let typeName = type.isEmpty || asJson ? ": " : "(\(type)): "

                var objectString:String = asJson ? element.json() : element.ktv()
                objectString = objectString.stringByReplacingOccurrencesOfString("\n", withString:"\n  ")

                result.appendContentsOf("\(typeName)\(objectString)")
            case .array(let type, let elements):
                let typeName = type.isEmpty || asJson ? ": " : "(\(type)): "

                var arrayString:String = "[\n"
                var isFirst = true
                for element in elements {
                    if !isFirst {
                        arrayString = arrayString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        arrayString.appendContentsOf(",\n  ")
                    } else {
                        arrayString.appendContentsOf("  ")
                        isFirst = false
                    }

                    var elementDescription = element.asString(asJson:asJson).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    if !typeName.isEmpty {
                        elementDescription = elementDescription.stringByReplacingOccurrencesOfString(typeName, withString:"")
                    }
                    if elementDescription.hasPrefix(": ") {
                        elementDescription = elementDescription.substringFromIndex(elementDescription.startIndex.advancedBy(2))
                    }
                    arrayString.appendContentsOf(elementDescription)
                }
                arrayString.appendContentsOf("\n]")

                arrayString = arrayString.stringByReplacingOccurrencesOfString("\n", withString:"\n  ")

                result.appendContentsOf("\(typeName)\(arrayString)")

            case .reference(let referenceLink):
                result.appendContentsOf(asJson ? ": \"@\(referenceLink)\"" : "(reference): \(referenceLink)")
        }

        return result
    }
}
