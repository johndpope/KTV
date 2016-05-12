//
// Created by Alexander Babaev on 07.03.16.
// Copyright (c) 2016 LonelyBytes. All rights reserved.
//

import Foundation

public protocol KTVModelAnyMapper {}

/**
  Правила парсинга (по которым работает автогенеренный парсер)
    — если пропертя есть и тип правильный — парсим
    — если пропертя есть, но неверного типа, то ошибка
    — если проперти нет, используем значение по-умолчанию
 */
// это, вообще-то, абстрактный класс, которым нельзя пользоваться. Но, поскольку protocol with associated type — страшное говно,
// приходится делать так
public class KTVModelMapper<MappingType>: KTVModelAnyMapper {
    public func parseOptionalValue(ktvValue:KTVValue?, defaultValue:MappingType?) throws -> MappingType? { return nil }
    public func compose(value:MappingType?) throws -> KTVValue { return .nilValue }

    public func parseNotOptionalValue(ktvValue:KTVValue?, defaultValue:MappingType) throws -> MappingType {
        if let result = try parseOptionalValue(ktvValue, defaultValue:defaultValue) {
            return result
        } else {
            throw KTVModelObjectParseableError.ValueIsNotOptionalButWeGotNull
        }
    }
}

public class KTVModelMapperFactory {
    private var _mappersByType = [String:KTVModelAnyMapper]()
    private var _mappersByPropertyName = [String:KTVModelAnyMapper]()

    private var _nameMappings = [String:String]()

    public init() {
        buildMappers()
    }

    // можно переопределить, если требуется поменять имя для проперти
    public func ktvNameFor(propertyName:String) -> String {
        if let nameMapping = _nameMappings[propertyName] {
            return nameMapping
        } else {
            return propertyName
        }
    }

    public func mapper<T>(type:String, propertyName:String) throws -> KTVModelMapper<T> {
        if let mapper = _mappersByPropertyName[propertyName] as? KTVModelMapper<T> {
            return mapper
        } else if let mapper = _mappersByType[type] as? KTVModelMapper<T> {
            return mapper
        } else {
            throw KTVModelObjectParseableError.CantFindTypeMapper
        }
    }

    public func addNameMappingForProperty(name:String, toKtvName ktvName:String) {
        _nameMappings[name] = ktvName
    }

    private func addTypeMapper(name:String, mapper:KTVModelAnyMapper) {
        _mappersByType[name] = mapper
    }

    public func addTypeMapperByPropertyName(propertyName:String, mapper:KTVModelAnyMapper) {
        _mappersByPropertyName[propertyName] = mapper
    }

    private func buildMappers() {
        addTypeMapper("String", mapper:KTVModelMapperString.instance)
        addTypeMapper("Int", mapper:KTVModelMapperInt.instance)
        addTypeMapper("Double", mapper:KTVModelMapperDouble.instance)
        addTypeMapper("Bool", mapper:KTVModelMapperBool.instance)

        addTypeMapper("[String]", mapper:KTVModelMapperArray(valueMapper:KTVModelMapperString.instance))
        addTypeMapper("[Int]", mapper:KTVModelMapperArray(valueMapper:KTVModelMapperInt.instance))
        addTypeMapper("[Double]", mapper:KTVModelMapperArray(valueMapper:KTVModelMapperDouble.instance))
        addTypeMapper("[Bool]", mapper:KTVModelMapperArray(valueMapper:KTVModelMapperBool.instance))

        addTypeMapper("[String:String]", mapper:KTVModelMapperDictionary(valueMapper:KTVModelMapperString.instance))
        addTypeMapper("[String:Int]", mapper:KTVModelMapperDictionary(valueMapper:KTVModelMapperInt.instance))
        addTypeMapper("[String:Double]", mapper:KTVModelMapperDictionary(valueMapper:KTVModelMapperDouble.instance))
        addTypeMapper("[String:Bool]", mapper:KTVModelMapperDictionary(valueMapper:KTVModelMapperBool.instance))

        addTypeMapper("NSDate", mapper:KTVModelMapperNSDate.instance)
    }
}