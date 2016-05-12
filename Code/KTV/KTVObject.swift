//
// Created by Alexander Babaev on 13.01.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public class KTVObject: CustomStringConvertible {
    public private(set) var properties:[String:KTVValue] = [:]

    // It is needed for property ordering, it's easy to use when all the properties are always in the same order
    public private(set) var propertyNamesInAddedOrder:[String] = []

    private lazy var _parentObject:KTVObject = self // is needed for reference resolving
    private var rootObject:KTVObject {
        var root = self
        while root._parentObject !== root {
            root = root._parentObject
        }

        return root
    }

    private var _resolvedObject:KTVObject? = nil

    public init() {}

    public func setProperty(name name:String, value: KTVValue) {
        _resolvedObject = nil

        //ToDo: возможно, проверить валидность значения
        if !propertyNamesInAddedOrder.contains(name) {
            propertyNamesInAddedOrder.append(name)
            if case .object(_, let objectValue) = value {
                objectValue._parentObject = self
            } else if case .array(_, let values) = value {
                for valueValue in values {
                    if case .object(_, let objectValue) = valueValue {
                        objectValue._parentObject = self
                    }
                }
            }
        }
        properties[name] = value
    }

    public func setPropertiesFromObject(object:KTVObject, replaceExisting:Bool) throws {
        _resolvedObject = nil

        //ToDo: maybe, proper merging is needed. Not supported right now
        for (name, value) in object.properties {
            if replaceExisting || properties[name] == nil {
                setProperty(name:name, value:value)
            }
        }
    }

    public func resolvedObject(mixinsOnly mixinsOnly:Bool) -> KTVObject {
        var result = KTVObject()

        if let resolvedObject = _resolvedObject {
            result = resolvedObject
        } else {
            result._parentObject = result
            result.mergeWithResolvedObject(self, mixinsOnly:mixinsOnly)
        }

        return result
    }

    public typealias ktvFunctionResolver = (functionName:String, parameters:[String], object:KTVObject) throws -> KTVValue

    public func findObjectByReference(reference:String, functionResolver:ktvFunctionResolver = { _, _, _ in return KTVValue.nilValue } ) throws -> KTVValue {
        var currentValue = KTVValue.object("_root", rootObject)

        if reference.rangeOfString("(") != nil {
            // This is function, that has to look like: "FUNCTION(PARAMETER1, PARAMETER2, PARAMETER3...)
            //ToDo: Update parameters parser to allow commas or other more complex situations
            let functionParts = reference
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    .componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"~()"))
                    .filter({return !$0.isEmpty})
            let functionName = functionParts.isEmpty ? "" : functionParts[0]
            let parameters = functionParts.count < 2 ?
                             [] :
                             functionParts[1].componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:", ")).filter({return !$0.isEmpty})
            currentValue = try functionResolver(functionName:functionName, parameters:parameters, object:self)
        } else {
            // This is a general reference, that starts with "@"
            var referenceParts = reference.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"@./"))
            while !referenceParts.isEmpty {
                let firstReferencePart = referenceParts.first?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if let firstReferencePart_ = firstReferencePart where !firstReferencePart_.isEmpty {
                    switch currentValue {
                        case .object(_, let object):
                            let objectWithMixins = object.resolvedObject(mixinsOnly:true)
                            if let newValue = objectWithMixins.properties[firstReferencePart_] {
                                currentValue = newValue
                            } else {
                                throw KTVParserError.BadReferenceObjectDoesNotExist
                            }
                        default:
                            throw KTVParserError.BadReferenceObjectDoesNotExist
                    }
                }

                referenceParts.removeFirst()
            }

            // process recursive references
            //ToDo: update code to catch and report cyclic references, if needed
            if case .reference(let referenceLink) = currentValue {
                currentValue = try rootObject.findObjectByReference(referenceLink)
            }
        }

        return currentValue
    }

    private func mergeWithResolvedObject(object:KTVObject, mixinsOnly:Bool) {
        for name in object.propertyNamesInAddedOrder {
            if let value = object.properties[name] {
                switch value {
                    case .reference(let referenceLink):
                        if !mixinsOnly {
                            do {
                                var referencedValue = try object.findObjectByReference(referenceLink)
                                if case .object(let type, let object) = referencedValue {
                                    referencedValue = KTVValue.object(type, object.resolvedObject(mixinsOnly:false))
                                }

                                setProperty(name:name, value:referencedValue)
                            } catch {
                                print("Reference \(referenceLink) resolving error: \(error)")
                            }
                        } else {
                            setProperty(name:name, value:value)
                        }
                    case .object(let type, let object):
                        let resolvedObject = object.resolvedObject(mixinsOnly:true)
                        var resolvedValue = KTVValue.object(type, resolvedObject)

                        if type.hasPrefix("+") {
                            do {
                                resolvedValue = try resolvedObject.updateWithMixins(type)
                            } catch {
                                print("Mixins \(type) error: \(error)")
                            }
                        }

                        setProperty(name:name, value:resolvedValue)
                    default:
                        setProperty(name:name, value:value)
                }
            }
        }
    }

    private func updateWithMixins(mixInNames:String) throws -> KTVValue {
        var resolvedType = ""

        let mixins = mixInNames.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"+,;"))
        for mixinName in mixins {
            if !mixinName.isEmpty {
                let referencedValue = try findObjectByReference(mixinName)
                switch referencedValue {
                    case .object(let type, let object):
                        if !resolvedType.isEmpty && resolvedType != type {
                            throw KTVParserError.MixedInValueIsNotTheSameType
                        } else {
                            resolvedType = type
                            self.mergeWithResolvedObject(object, mixinsOnly:true)
                        }
                    default:
                        throw KTVParserError.MixedInValueIsNotAnObject
                }
            }
        }

        return KTVValue.object(resolvedType, self)
    }

    //MARK - CustomStringConvertible

    public var description: String {
        return ktv()
    }
}

// Referencing objects of different types. With resolving references if needed.
extension KTVObject {
    private func valueAndReferenceForKey(key:String, resolveReferences:Bool = true) throws -> (value:KTVValue?, reference:String?) {
        var result:KTVValue? = properties[key]
        var reference:String? = nil

        if let result_ = result {
            switch result_ {
                case .reference(let link):
                    if resolveReferences || link.hasPrefix("~") {
                        result = try findObjectByReference(link)
                    } else {
                        result = nil
                        reference = link.stringByReplacingOccurrencesOfString("@", withString:"")
                    }
                default:
                    break
            }
        }

        return (result, reference)
    }

private func specificValueForKey<T>(key:String, defaultValue:T?, resolveReferences:Bool, valueResolver:(value:KTVValue) throws -> T?) throws -> (value:T?, reference:String?) {
    let (resultValue, reference) = try valueAndReferenceForKey(key, resolveReferences:resolveReferences)
    var result = defaultValue

    if let result_ = resultValue {
        result = try valueResolver(value:result_)
    }

    return (result, reference)
}

    //MARK: values or references

    func valueForKey(key:String) throws -> KTVValue? {
         return try valueAndReferenceForKey(key).value
    }

    public func stringOrReference(key key:String, defaultValue:String = "", resolveReferences:Bool = true) throws -> (value:String, reference:String?) {
        let (value, reference) = try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:resolveReferences, valueResolver:KTVValue.stringResolver)
        if let value_ = value {
            return (value_, reference)
        } else {
            return (defaultValue, reference)
        }
    }

    public func doubleOrReference(key key:String, defaultValue:Double = 0.0, resolveReferences:Bool = true) throws -> (value:Double, reference:String?) {
        let (value, reference) = try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:resolveReferences, valueResolver:KTVValue.doubleResolver)
        if let value_ = value {
            return (value_, reference)
        } else {
            return (defaultValue, reference)
        }
    }

    //MARK: plain values

    public func string(key key:String, defaultValue:String? = "") throws -> String? {
        return try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:true, valueResolver:KTVValue.stringResolver).value
    }

    public func double(key key:String, defaultValue:Double? = 0.0) throws -> Double? {
        return try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:true, valueResolver:KTVValue.doubleResolver).value
    }

    public func int(key key:String, defaultValue:Int? = 0) throws -> Int? {
        return try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:true, valueResolver:KTVValue.intResolver).value
    }

    public func bool(key key:String, defaultValue:Bool? = false) throws -> Bool? {
        return try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:true, valueResolver:KTVValue.boolResolver).value
    }

    public func nsDate(key key:String, defaultValue:NSDate? = NSDate()) throws -> NSDate? {
        return try specificValueForKey(key, defaultValue:defaultValue, resolveReferences:true, valueResolver:KTVValue.dateResolver).value
    }

    public func array<T>(key key:String, defaultValue:[T]? = nil, itemResolver:(value:KTVValue) throws -> T?) throws -> [T]? {
        let (resultValue, _) = try valueAndReferenceForKey(key, resolveReferences:true)
        var result:[T]? = defaultValue

        if let result_ = resultValue {
            if let result__ = try KTVValue.arrayResolver(result_, valueResolver:itemResolver) {
                result = result__
            }
        }

        return result
    }

    public func dictionary<T>(key key:String, defaultValue:[String:T]? = nil, itemResolver:(value:KTVValue) throws -> T?) throws -> [String:T]? {
        let (resultValue, _) = try valueAndReferenceForKey(key, resolveReferences:true)
        var result:[String:T]? = defaultValue

        if let result_ = resultValue {
            if let result__ = try KTVValue.dictionaryResolver(result_, valueResolver:itemResolver) {
                result = result__
            }
        }

        return result
    }
}

extension KTVObject {
    public subscript (key:String) -> KTVValue? {
        do {
            return try valueForKey(key)
        } catch {
            return .nilValue
        }
    }
}

// Trying to create an iterator for walking through all the object hierarchy
// ToDo: Not finished yet
extension KTVObject {
    // closure is "full property name" - "array index or 0", "value". Result — do we need to stop iterating deeper
    // every object/array calls actor on itself, and if true was returned — then goes inside and iterates over its descendants
    func iterateEveryProperty(prefix prefix:String, actor:(String, Int, KTVValue) -> Bool) {
        for name in propertyNamesInAddedOrder {
            if let value = properties[name] {
                let weNeedToContinue = actor(prefix + name, 0, value)

                if weNeedToContinue {
                    switch value {
                        case .nilValue, .bool(_), .string(_), .int(_), .double(_), .color(_), .reference(_):
                            break
                        case .object(_, let object):
                            var newPrefix = prefix
                            if !newPrefix.isEmpty {
                                newPrefix += "." + name
                            } else {
                                newPrefix = name
                            }
                            object.iterateEveryProperty(prefix:newPrefix, actor:actor)
                        case .array(_, let values):
                            var index = 0
                            for arrayValue in values {
                                actor(prefix + name, index, arrayValue)
                                index += 1
                            }
                    }
                }
            }
        }
    }
}