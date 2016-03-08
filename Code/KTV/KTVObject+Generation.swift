//
// Created by Alexander Babaev on 03.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

extension KTVObject {
    public func ktv() -> String {
        var result = "{\n"

        for name in propertyNamesInAddedOrder {
            if let value = properties[name] {
                result += "  \(name)"
                result += value.asString(asJson:false)
                result += "\n"
            }
        }
        result += "}"

        return result
    }

    public func json() -> String {
        var result = "{\n"

        let lastPropertyName = propertyNamesInAddedOrder.last
        for name in propertyNamesInAddedOrder {
            if let value = properties[name] {
                result += "  \"\(name)\""
                result += value.asString(asJson:true)
                result += lastPropertyName == name ? "\n" : ",\n"
            }
        }
        result += "}"

        return result
    }
}