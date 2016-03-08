//
// Created by Alexander Babaev on 13.01.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

enum KTVParsingState {
    case Name
    case Type
    case Value
    case Root // in this state we can read only object or array
}

enum KTVParsingQuoteState {
    case Outside
    case Inside
}

enum KTVCharType {
    case Space
    case Quote
    case Meaningful
}

/*
    name (type): value
*/

public class KTVParser {
    private let _charGenerator: KTVParserCharGenerator

    private var _state = KTVParsingState.Value
    private var _quotesState = KTVParsingQuoteState.Outside

    private var _elementEnded = false

    private var _tokenStartedWithQuote = false
    private var _nextCharIsScreened = false

    private var _inComment = false

    private var _weAreParsingArray = false
    private let _currentElement = KTVObject()
    private var _currentArray:[KTVValue] = []

    private var _currentPropertyName = ""
    private var _currentPropertyType = ""
    private var _currentPropertyValue:KTVValue = .nilValue
    private var _currentToken = ""

    private var _currentLineIndex = 1
    private var _currentColumnIndex = 0
    public var currentPosition:String {
        return "[\(_currentLineIndex):\(_currentColumnIndex)]"
    }

    public init(fileName:String) {
        let fileString = try! String(contentsOfFile:fileName)
        _charGenerator = KTVParserCharGeneratorFromString(string:fileString)
    }

    public init(charGenerator: KTVParserCharGenerator) {
        _charGenerator = charGenerator
    }

    private func processChar() throws {
        let char_:Character? = _charGenerator.pokeNextChar()
        let charNext_:Character? = _charGenerator.peekNextChar()

        _currentColumnIndex += 1

        guard let char = char_ else {
            return
        }

        guard let charNext = charNext_ else {
            return
        }

        guard !_nextCharIsScreened else {
            // adding screened character without any other questions
            addChar(char)
            return
        }

        guard !(_inComment && !(char == "\n" || char == "\r")) else {
            // we are in a comment
            return
        }

        switch char {
            case "\"": // quote
                if _state == .Root {
                    throw KTVParserError.WrongRootObject
                }

                if _state == .Name || _state == .Value {
                    if _quotesState == .Outside {
                        _quotesState = .Inside
                        _tokenStartedWithQuote = true
                    } else if _quotesState == .Inside && _tokenStartedWithQuote {
                        _quotesState = .Outside
                        try processToken()
                    }
                } else {
                    addChar(char)
                }
            case "\\": // screen
                _nextCharIsScreened = true
            case "{": // object start
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    if _state == .Root {
                        _state = .Name
                    } else if _state == .Value {
                        _charGenerator.goBackOneChar(char)
                        let parser = KTVParser(charGenerator:_charGenerator)
                        parser._currentLineIndex = _currentLineIndex
                        parser._currentColumnIndex = _currentColumnIndex

                        let value = try parser.parse()
                        if _currentPropertyType.isEmpty {
                            _currentPropertyType = tryToDetermineTypeStringFromObjectValue(value)
                        }
                        _currentPropertyValue = KTVValue.object(_currentPropertyType, value)

                        _currentLineIndex = parser._currentLineIndex
                        _currentColumnIndex = parser._currentColumnIndex
                    } else {
                        throw KTVParserError.ObjectNotInPlace
                    }
                }
            case "}": // object end
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    try processProperty()
                    _elementEnded = true
                }
            case "[": // array start
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    if _state == .Root {
                        _weAreParsingArray = true
                        _state = .Value
                    } else if _state == .Value {
                        _charGenerator.goBackOneChar(char)
                        let parser = KTVParser(charGenerator:_charGenerator)
                        parser._currentLineIndex = _currentLineIndex
                        parser._currentColumnIndex = _currentColumnIndex

                        try parser.parse()
                        if _currentPropertyType.isEmpty {
                            _currentPropertyType = tryToDetermineTypeStringFromArrayValue(parser._currentArray)
                        }
                        _currentPropertyValue = KTVValue.array(_currentPropertyType, parser._currentArray)

                        _currentLineIndex = parser._currentLineIndex
                        _currentColumnIndex = parser._currentColumnIndex
                    } else {
                        throw KTVParserError.ObjectNotInPlace
                    }
                }
            case "]": // array end
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    try processProperty()
                    _elementEnded = true
                }
            case "(": // type start
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    if _state == .Root {
                        throw KTVParserError.WrongRootObject
                    } else if _weAreParsingArray {
                        throw KTVParserError.BadArrayWithTypeSymbol
                    } else if (_state == .Value || _state == .Type) {
                        throw KTVParserError.TypePlacementError
                    } else if _state == .Name && _currentToken.isEmpty {
                        throw KTVParserError.TypePlacementError
                    }

                    try processToken()
                    _state = .Type
                }
            case ")": // type end
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    if _state == .Root {
                        throw KTVParserError.WrongRootObject
                    } else if _weAreParsingArray {
                        throw KTVParserError.BadArrayWithTypeSymbol
                    } else if _state != .Type {
                        throw KTVParserError.TypePlacementError
                    } else if _state == .Name && _currentToken.isEmpty {
                        throw KTVParserError.TypePlacementError
                    }

                    try processToken()
                    _state = .Name
                }
            case ":": // delimiter between name and value
                if _quotesState == .Inside {
                    addChar(char)
                } else {
                    if _state == .Root {
                        throw KTVParserError.WrongRootObject
                    } else if _weAreParsingArray {
                        throw KTVParserError.BadArrayWithColonSymbol
                    } else if _state == .Name || _state == .Type {
                        try processToken()
                        _state = .Value
                    }
                }

                break
            case "~": // function
                if _state == .Root {
                    throw KTVParserError.WrongRootObject
                } else if _state == .Value {
                    addChar(char)
                } else {
                    throw KTVParserError.ReferencePlacementError
                }
            case "@": // reference or parent object
                if _state == .Root {
                    throw KTVParserError.WrongRootObject
                } else if _state == .Value || _state == .Name {
                    addChar(char)
                } else {
                    throw KTVParserError.ReferencePlacementError
                }
            case "/": // comment
                if _quotesState != .Inside && charNext == "/" {
                    _inComment = true
                } else {
                    addChar(char)
                }
            case "#": // comment (if not color)
                if _quotesState != .Inside && _state != .Value {
                    _inComment = true
                } else if _state == .Value && _currentToken.isEmpty && _currentPropertyType.isEmpty {
                    _currentPropertyType = "color"
                } else {
                    addChar(char)
                }
            case ",": // property delimiter
                fallthrough
            case ";": // property delimiter
                if _quotesState != .Inside {
                    if _state == .Value {
                        try processProperty()
                        _state = _weAreParsingArray ? .Value : .Name
                    } else if _state != .Type {
                        throw char == "," ? KTVParserError.CommaPlacementError : KTVParserError.SemicolonPlacementError
                    } else {
                        addChar(char)
                    }
                } else {
                    addChar(char)
                }
            case " ", " ", "\t": // space
                if _quotesState == .Inside {
                    addChar(char)
                } else if !_currentToken.isEmpty {
                    addChar(char)
                }
            case "\n", "\r": // new line
                _currentLineIndex += 1
                _currentColumnIndex = 0

                if _quotesState == .Inside {
                    addChar(char)
                    _quotesState = .Outside
                }

                try processProperty()
                _state = _weAreParsingArray ? .Value : .Name

                _inComment = false
            default:
                addChar(char)
        }
    }

    func processProperty() throws {
        try processToken()

        guard !_currentPropertyName.isEmpty || (_weAreParsingArray && _currentPropertyValue.type != "nil") else {
            return
        }

        if _weAreParsingArray {
            _currentArray.append(_currentPropertyValue)
        } else {
            _currentElement.setProperty(name:_currentPropertyName, value:_currentPropertyValue)
        }

        _currentPropertyName = ""
        _currentPropertyType = ""
        _currentPropertyValue = .nilValue
    }

    func processToken() throws {
        guard !_currentToken.isEmpty else {
            return
        }

        switch _state {
            case .Root:
                break
            case .Name:
                _currentPropertyName = _currentToken
                break
            case .Type:
                _currentPropertyType = _currentToken
                break
            case .Value:
                _currentPropertyValue = try processStringAsValue(_currentToken)
                break
        }

        _currentToken = ""
    }

    func processStringAsValue(string:String) throws -> KTVValue {
        if _currentPropertyType.isEmpty {
            _currentPropertyType = tryToDetermineTypeStringFromStringValue(string)
        }

        _currentPropertyType = _currentPropertyType.lowercaseString

        var result = KTVValue.nilValue

        if string.hasPrefix("@") {
            result = KTVValue.reference(string)
        } else if string.hasPrefix("~") {
            result = KTVValue.reference(string)
        } else {
            switch _currentPropertyType {
                case "string", "s":
                    result = KTVValue.string(string)
                case "bool", "b":
                    let lowerString = string.lowercaseString
                    if lowerString == "true" || lowerString == "yes" || lowerString == "y" || lowerString == "1" {
                        result = KTVValue.bool(true)
                    } else if lowerString == "false" || lowerString == "no" || lowerString == "n" || lowerString == "0" {
                        result = KTVValue.bool(false)
                    } else {
                        throw KTVParserError.BadBoolValue
                    }
                case "int", "i", "integer":
                    if let int = Int(string) {
                        result = KTVValue.int(int)
                    } else {
                        throw KTVParserError.BadIntValue
                    }
                case "double", "d":
                    if let double = Double(string) {
                        result = KTVValue.double(double)
                    } else {
                        throw KTVParserError.BadDoubleValue
                    }
                case "colour", "color", "c":
                    result = KTVValue.color(string)
                    break
                default:
                    break
            }
        }

        return result
    }

    func tryToDetermineTypeStringFromObjectValue(value:KTVObject) -> String {
        return ""
    }

    func tryToDetermineTypeStringFromArrayValue(value:[KTVValue]) -> String {
        var result = ""

        if !value.isEmpty {
            result = value[0].type
        }

        return result
    }

    func tryToDetermineTypeStringFromStringValue(value:String) -> String {
        var result = "string"

        if value != "#" {
            let lowerValue = value.lowercaseString

            if lowerValue == "true" || lowerValue == "false" {
                result = "bool"
            } else if lowerValue == "nil" || lowerValue == "null" {
                result = "nil"
            } else if value.stringByReplacingOccurrencesOfString("[\\+\\-]?[  \\d]+", withString:"#", options:[.RegularExpressionSearch], range:Range(value.startIndex..<value.endIndex)) == "#" {
                result = "int"
            } else if value.stringByReplacingOccurrencesOfString("[\\+\\-]?[  \\d]*[\\.\\,]\\d+", withString:"#", options:[.RegularExpressionSearch], range:Range(value.startIndex..<value.endIndex)) == "#" {
                result = "double"
            } else if lowerValue.stringByReplacingOccurrencesOfString("#[0-9a-f]+", withString:"#", options:[.RegularExpressionSearch], range:Range(value.startIndex..<value.endIndex)) == "#" {
                result = "color"
            } else if value.stringByReplacingOccurrencesOfString("@[a-z_][a-z_\\.]*", withString:"#", options:[.RegularExpressionSearch], range:Range(value.startIndex..<value.endIndex)) == "#" {
                result = "reference"
            }
        }

        return result
    }

    func addChar(char:Character) {
        if !_inComment {
            _currentToken.append(char)
        }

        _nextCharIsScreened = false
    }

    public func parse() throws -> KTVObject {
        _state = .Root

        do {
            while _charGenerator.peekNextChar() != nil && !_elementEnded {
                try processChar()
            }
        } catch {
            throw error
        }

        var result = _currentElement
        if _currentArray.count != 0 {
            result = KTVArray(values:KTVValue.array(tryToDetermineTypeStringFromArrayValue(_currentArray), _currentArray))
        }

        return result
    }
}
