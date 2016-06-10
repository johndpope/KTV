//
// Created by Alexander Babaev on 10.06.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

enum KTVObjectError: ErrorType {
    case WrongStringValue
    case WrongIntValue
    case WrongDoubleValue
    case WrongBoolValue

    case WrongArrayValue
    case WrongArrayItemValue
    case WrongDictionaryValue
    case WrongDictionaryItemValue

    case WrongObjectValue

    case WrongDateValue
}
