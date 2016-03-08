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