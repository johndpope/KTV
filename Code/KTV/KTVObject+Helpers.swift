//
// Created by Alexander Babaev on 03.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

extension KTVObject {
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

    //MARK: Value or reference

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
}