# KTV
Key-Type-Value format. Swift parser implementation

## What is it?
It is a prototype library for the parsing of ktv, format that is close to JSON, but is a little bit more strict and has ability to store type information. 

It looks like this:

```
// it does have comments.
// file can contain an array or an object, same as JSON
{
	// property names can be written without quotes
	someProperty: "string value"
	
	// colons/semicolons are optional. They are required when several properties are written on the same line
	anotherProperty: 239
	
	// basic types are: string, int, double, bool, null/nil, color (#rrggbbaa or #rrggbb or #rgb)
	exampleRedColor: #ff0000
	
	// you can write arrays, array must contain same type items
	array: [
		1, 2, 3, 4
		5 // colons/semicolons are optional here too
	]
	
	reference: @someProperty
	
	// here we specify object type, that can be used for verification or more accurate model mapping
	myFont(font): {
		name: Helvetica
		size: 16
	}
	
	// arrays also can have types
	point(CGPoint): [23.2, 33.2]
	
	//sometimes it is useful to derive object from another
	biggerFont(+myFont): {
		size: 22
	}
}
```

## Introduction (in russian)

https://habrahabr.ru/post/278763/

## Installation

Presumably, simply use KTVKit.framework from _binaries, that is all.

## Using

#### Reading KTV and JSON files

```
let parser = KTVParser(fileName:filePath)
let ktvObject:KTVObject = try parser.parse()
```

parser can return `KTVObject` or its descendant, `KTVArray`.

#### Accessing data within KTVObject

Everything is stored in a dictionary-like structure, that is called `properties`. Keys are `Strings`, values are enum `KTVValue`. Properties can be accessed via subscript (by key in the case of object and by index, if it is a KTVArray.

If you need some value and do not want to mess with `KTVValue` enum, you can use methods:
```
public func string(key key:String, defaultValue:String? = "") throws -> String?
public func double(key key:String, defaultValue:Double? = 0.0) throws -> Double?
public func int(key key:String, defaultValue:Int? = 0) throws -> Int?
public func bool(key key:String, defaultValue:Bool? = false) throws -> Bool?
public func nsDate(key key:String, defaultValue:NSDate? = NSDate()) throws -> NSDate?
public func array<T>(key key:String, defaultValue:[T]? = nil, itemResolver:(value:KTVValue) throws -> T?) throws -> [T]?
public func dictionary<T>(key key:String, defaultValue:[String:T]? = nil, itemResolver:(value:KTVValue) throws -> T?) throws -> [String:T]?
```
or similar methods for colors. These methods will automatically resolve references etc.

But messing with raw values is not fun. Much better is to parse ktv into a model object (object hierarchy) and use it in a native way.

This can be done in several steps:

1. Write a model object. It is a simple object (struct, class, can be @objc, public, whatever)
2. Run ktvModelGenerator, that will generate extension for the model objects that it will find. 
3. Add extensions file to the project.
4. Repeat steps 2 and 3 for all paths with model files.
5. Use the model object.

#### Let's look at examples.

Model object one, simple with @objc annotation

```
@objc
class ChildObject : NSObject, KTVModelObject {
    var somethingElse:String = ""
}
```

Model object two, more complex, with different types

```
public struct RootObject: KTVModelObject {
    var date:NSDate

    var string:String
    var stringOrNil:String? = nil

    var int:Int
    var double:Double

    var stringArray:[String]
    var stringDictionary:[String:Int]

    var object:ChildObject?

    // constants will not participate in mapping process
    let _constantString:String = ""

    // private vars, won't take part in parsing generators
    private var _privateString:String
    private(set) var _privateSetString:String
}
```

Executing ktvModelGenerator

```
./ktvModelGenerator -s ~/Programming/DPLS/Tests/KTV -o ~/Programming/DPLS/Tests/KTV/generated
```

Generated code (interface only, without private methods) 

```
extension RootObject: KTVParseable {
    public init?(ktvStrict ktv:KTVObject)
    public init(ktvLenient ktv:KTVObject)
}

extension RootObject: KTVSerializable {
    public func ktvObject() throws -> KTVObject
}

extension ChildObject: KTVParseable {
    convenience init?(ktvStrict ktv:KTVObject)
    convenience init(ktvLenient ktv:KTVObject)
}

extension ChildObject: KTVSerializable {
    func ktvObject() throws -> KTVObject
}
```

Now you can use initializers and `ktvObject().ktv()`/`ktvObject().json()` to read KTVObjects or write them back.

#### Model configuration

- naming
- standard date formats
- custom mappers (non-standard date formats)
