//
// Created by Alexander Babaev on 07.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVArray: KTVObject {
    init(values:KTVValue) {
        super.init()
        setProperty(name:"__array__", value:values)
    }
}

extension KTVArray {
    public var count:Int {
        get {
            if let array = properties["__array__"] {
                if case KTVValue.array(_, let values) = array {
                    return values.count
                }
            }

            return 0
        }
    }

    public subscript (index:Int) -> KTVValue {
        if let array = properties["__array__"] {
            if case KTVValue.array(_, let values) = array {
                return values[index]
            }
        }

        return KTVValue.nilValue
    }
}
