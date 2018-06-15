# FSJSON

FSJSON is a generic JSON serialization library for use in iOS and macOS apps, employing a clean and flexible API. Supported types include all primitives, Objective-C types compatible with the JSON format (arrays, dictionaries, `NSNumber`, and `NSNull`), and C types (`struct` and `union`). Instance variables are also serializable, not just properties.

This frees you up from much of the tedious work in managing the serialization/deserialization process of your model objects. This is especially noticeable during development as properties and instance variables of your classes change (by name and/or type), or are added/removed. Generic serialization utilizing introspection of your models handle much of this boilerplate work for you.  

Note that this library does __not__ work with Swift classes due to differences in the inner workings of Objective-C and Swift. With some basic testing, however, it looks like this library can be interoperable with Swift if the classes you want to serialize are written in Objective-C, then imported via a bridging header into your Swift project.

## Installation
Simply download this repository and copy _FSJSON.h_ & _FSJSON.m_ into your project.

## Usage
Adopt the `FSJSONSerializable` protocol for objects that you will be serializing/deserializing (no subclassing required!).
```
@interface SerializableClass : NSObject<FSJSONSerializable>
@property (nonatomic, strong) NSString *aString;
@property (nonatomic) NSInteger anInteger;
@end
```
#### Serializing
To serialize an object to a JSON model:
```
SerializableClass *obj = ...;
NSDictionary *json = [FSJSONSerialization JSONFromObject:obj];
```
To serialize an object directly to a JSON file:
```
SerializableClass *obj = ...;
NSString *filePath = ...;
NSError *error;
BOOL success = [FSJSONSerialization serializeObject:obj toFile:filePath: error:&error];
```
If you don't want to serialize directly to a file, you can write the JSON model object to a file at a later time:
```
SerializableClass *obj = ...;
NSDictionary *json = [FSJSONSerialization JSONFromObject:obj];

...

NSString *filePath = ...;
NSError *error;
BOOL success = [FSJSONSerialization writeJSON:json toFile:filePath error:&error];
```
#### Deserializing
To deserialize an object from a JSON model object:
```
NSDictionary *json = ...;
SerializableClass *obj = [FSJSONSerialization objectOfClass:[SerializableClass class] fromJSON:json];
```
If you already have an instance of the class that you wish to set or update with a JSON model object:
```
NSDictionary *json = ...;
SerializableClass *obj = ...;
BOOL success = [FSJSONSerialization setObject:obj fromJSON:json];
```
To directly deserialize an object from a JSON file:
```
NSString *filePath = ...;
NSError *error;
SerializableClass *obj = [FSJSONSerialization deserializeObjectOfClass:[SerializableClass class] fromFile:filePath error:&error];
```
To load a JSON model object from a file:
```
NSString *filePath = ...;
NSError *error;
NSDictionary *json = [FSJSONSerialization JSONFromFile:filePath error:&error];
```
## Advanced
FSJSON automatically handles the following types:
- `NSString` & `NSMutableString`
- `NSNumber`
- `NSDate`
- `NSData` & `NSMutableData`
- `NSArray` & `NSMutableArray`
- `NSDictionary` & `NSMutableDictionary`
- `BOOL` & `bool`
- `char` & `unsigned char`
- `int` (`NSInteger` on 32-bit platforms) & `unsigned int` (`NSUInteger` on 32-bit platforms)
- `long` (`NSInteger` on 64-bit platforms) & `unsigned long` (`NSUInteger` on 64-bit platforms)
- `long long` & `unsigned long long`
- `float` (`CGFloat` on 32-bit platforms)
- `double` (`CGFloat` on 64-bit platforms)
- objects that conform to `FSJSONSerializable`

#### Instance variables
By default, instance variables are included in serialization/deserialization. e.g.:
```
@implementation MyClass {
    NSInteger _aValue;
}
```
`_aValue` will be serialized as "aValue". This can be ignored by implementing `-doNotSerialize` (see below for details).

#### Arrays
Arrays must be a homogenous collection of supported types. If an array contains custom objects conforming to `FSJSONSerializable`, implement the `-classForArrayElementsOfProperty:` method from the `FSJSONSerializable` protocol:
```
- (Class)classForArrayElementsOfProperty:(NSString *)property {
    if ([property isEqualToString:@"anArray"]) {
        return [AClass class];
    }
    return NULL;
}
```
If an array does not contain a homogeneous collection of objects, it can still be serialized using a value transformer by implementing `-valueTransformerForProperty:`.

#### Dictionaries
Dictionaries must use `NSString`s as keys. Values, like arrays, can be any supported type. If a value in a dictionary is a custom class conforming to `FSJSONSerializable`, implement the `-classForDictionaryObjectWithKeyPath:` method:
```
- (Class)classForDictionaryObjectWithKeyPath:(NSString *)keyPath {
    NSArray<NSString*> *kpComponents = [keyPath componentsSeparatedByString:@"."];
    if (kpComponents.count == 2 && [kpComponents.firstObject isEqualToString:@"aDictionary"]) {
        NSString *key = kpComponents.lastObject;
        if ([key isEqualToString:@"foo"]) {
            return [Foo class];
        }
    }
    return nil;
}
```

#### C types
C `struct`s and `union`s are handled but require the object to implement the `-valueTransformerForProperty:` method from the `FSJSONSerializable` protocol:
```
- (NSValueTransformer *)valueTransformerForProperty:(NSString *)property {
    if ([property isEqualToString:@"aStruct"]) {
        AStructValueTransformer *transformer = [AStructValueTransformer new];
        return transformer;
    }
    return nil;
}
```
For an example of creating an `NSValueTransformer` subclass, see the `FSStructValueTransformer` class used by `FSSerializableObject` in the unit tests. There are also 2 value transformers included in _FSJSON.h_/_FSJSON.m_: one for transforming `NSDate` objects into Unix time, and another for serializing `NSRange` values.

#### Dates
By default, `NSDate` properties are serialized as strings using the [RFC 3339](https://www.ietf.org/rfc/rfc3339.txt) profile of the [ISO 8601](https://www.iso.org/iso-8601-date-and-time-format.html) standard. To serialize using a different format or standard, implement the `-dateFormatterForDateProperty:` method:
```
- (NSDateFormatter *)dateFormatterForDateProperty:(NSString *)property {
    if ([property isEqualToString:@"aDate"]) {
        static NSDateFormatter *formatter;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            formatter = [NSDateFormatter new];
            formatter.dateStyle = NSDateFormatterMediumStyle;
            formatter.timeStyle = NSDateFormatterNoStyle;
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_CA"];
        });
        return formatter;
    }
    return nil;
}
```

#### Key mapping
To serialize a property with a different key in the JSON model object, return its mapping in `-keyMap`, which maps the property's name (the key in the returned dictionary) to its serialization key (the corresponding value). e.g.:
```
- (NSDictionary<NSString*,NSString*> *)keyMap {
    return @{@"userName": @"user"};
}
```
In the above example, the property `userName` will be serialized as "user" in the JSON representation. When deserializing, it will map "user" back to `userName`.

#### Ignored properties
To ignore properties or instance variables from serialization, implement the `-doNotSerialize` method, returning a set of strings identifying the properties to ignore:
```
- (NSSet<NSString*> *)doNotSerialize {
    return [NSSet setWithObject:@"ignored"];
}
```

## License
FSJSON is released under the MIT license. See [LICENSE](https://github.com/cfloisand/FSJSON/blob/master/LICENSE.txt) for more details.
