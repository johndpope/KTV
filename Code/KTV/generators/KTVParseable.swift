//
// Created by Alexander Babaev on 13.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

enum KTVModelObjectParseableError: ErrorType {
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

    case ValueIsNotOptionalButWeGotNull

    case CantFindTypeMapper
}

/**
 Правила парсинга (по которым работает автогенеренный парсер)
 — если пропертя есть и тип правильный — парсим
 — если пропертя есть, но неверного типа, то ошибка
 — если проперти нет, используем значение по-умолчанию
 */
public protocol KTVParseable {
    init?(ktvStrict ktv:KTVObject)
    init(ktvLenient ktv:KTVObject)
}
