//
// Created by Alexander Babaev on 12.02.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public protocol KTVParserCharGenerator {
    func goBackOneChar(char:Character)

    func pokeNextChar() -> Character?
    func peekNextChar() -> Character?
}

public class KTVParserCharGeneratorFromString: KTVParserCharGenerator {
    private var _generator:EnumerateGenerator<IndexingGenerator<String.CharacterView>>

    private var _backOneCharacter:Character? = nil
    private var _nextCharacterPeeked:Character? = nil

    public init(string:String) {
        _generator = string.characters.enumerate().generate()
    }

    public func goBackOneChar(char:Character) {
        _backOneCharacter = char
    }

    public func pokeNextChar() -> Character? {
        var result:Character? = nil

        if let backOneCharacter = _backOneCharacter {
            result = backOneCharacter
            _backOneCharacter = nil
        } else if let nextCharacterAlreadyGenerated = _nextCharacterPeeked {
            result = nextCharacterAlreadyGenerated
            _nextCharacterPeeked = nil
        } else {
            if let (_, char) = _generator.next() {
                result = char
            } else {
                result = nil
            }
        }

        return result
    }

    public func peekNextChar() -> Character? {
        if _nextCharacterPeeked == nil {
            _nextCharacterPeeked = pokeNextChar()
        }

        return _nextCharacterPeeked
    }
}
