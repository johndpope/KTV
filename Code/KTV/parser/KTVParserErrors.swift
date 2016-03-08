//
// Created by Alexander Babaev on 06.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public enum KTVParserError: ErrorType {
    case WrongRootObject // Only object or array can be a root object
    case TypePlacementError // Type can only be placed after the property name like "name(type)", () is forbidden in other places, use screening \ or quotes "" to use () in values
    case ObjectNotInPlace // Object can be only as a root or a value
    case ArrayNotInPlace // Object can be only as a root or a value

    case CommaPlacementError // Comma can be used only as a property delimiter
    case SemicolonPlacementError // Semicolon can be used only as a property delimiter

    case ReferencePlacementError // References can be used only in values or types
    case FunctionPlacementError // Functions can be used only in values

    case BadBoolValue // Badly formatted bool value
    case BadIntValue // Badly formatted int value
    case BadDoubleValue // Badly formatted double value

    case BadArrayWithTypeSymbol // Type can't be in array
    case BadArrayWithColonSymbol // : can't be in array

    case BadReferenceObjectDoesNotExist // referenced object does not exist
    case BadFunctionDoesNotExist // function does not exist

    case MixedInValueIsNotAnObject // we can only mix in objects
    case MixedInValueIsNotTheSameType // we can only mix in objects with same types (?)

    case MergingObjectWithNonObject // when we use includes or several styles, we can not merge properties that are not objects
}
