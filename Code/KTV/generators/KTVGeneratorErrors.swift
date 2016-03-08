//
// Created by Alexander Babaev on 13.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

enum KTVGeneratorError: ErrorType {
    case CantFindPathWhereToSearchClasses

    case ErrorParsingFile

    case DictionariesCantHaveKeysOtherThanStrings

    case TypesDefinitionsAreMandatory

    case ColorSerializationNotSupportedYet
    case CGPointSerializationNotSupportedYet
    case CGSizeSerializationNotSupportedYet
    case CGRectSerializationNotSupportedYet
    case UIEdgeInsetsSerializationNotSupportedYet
}
