//
// Created by Alexander Babaev on 07.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVArray: CustomStringConvertible {
    private var values_:KTVValue = KTVValue.array("", [])

    init(values:KTVValue) {
        values_ = values
    }

    //MARK - CustomStringConvertible

    public var description: String {
        return values_.description
    }
}
