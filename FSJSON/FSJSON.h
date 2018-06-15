//  MIT License
//
//  Copyright (c) 2017 Flyingsand
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Christian Floisand on 2016-07-28.
//

#import <Foundation/Foundation.h>


#pragma mark - FSJSONSerializable
@protocol FSJSONSerializable <NSObject>
@optional

/*! @brief Return a mapping of the receiver's property name to its corresponding serialization key.
    @details Implement this to map a property's name to a different string on serialization. The same 
    mapping is used when deserializing the receiver. */
- (NSDictionary<NSString*,NSString*> *)keyMap;

/*! @brief Return a set of property names that should not be included in serialization or deserialization. 
    @details This set can include instance variables as well. */
- (NSSet<NSString*> *)doNotSerialize;

/*! @brief Return a date formatter to convert NSDate objects into a string representation.
    @details The default behavior for NSDate values is to serialize them as strings conforming to the RFC 3339 profile of the ISO 8601 standard.
    e.g. \c yyyy-MM-dd'T'HH:mm:ssZZZZZ, with the timezone set to GMT. Implement this method to serialize dates in a different format.
    @note This method is only called if the date is serialized/deserialized as a string. i.e. -valueTransformerForProperty: 
    has not transformed the date into Unix time. */
- (NSDateFormatter *)dateFormatterForDateProperty:(NSString *)property;

/*! @brief Return a value transformer for the given property, allowing the property to be serialized as a different type or representation.
    @details Example uses of this method include transforming a date into Unix time instead of a string representation, or 
    transforming an unsupported type into a serializable format. For transforming dates into Unix time, \c UCDateToUnixTimeTransformer 
    is provided as a convenience. It is important to note that this method is \e not called for values in collections, so if collection 
    objects should be transformed in some way (e.g. serialize an array of NSDates to Unix time or some other format),
    return a value transformer for the array property that transforms the array's contents into the desired format.
    @note The returned value transformer must be reversible. */
- (NSValueTransformer *)valueTransformerForProperty:(NSString *)property;

/*! @brief Return the class of the elements contained in the array with the given property name for deserialization.
    @details Implement this method when the array identified by the given property name contains custom objects so that the objects will 
    be properly deserialized. If this method is not implemented, custom objects will be deserialized as  NSDictionaries.
    @note Array properties should be homogeneous. i.e. They cannot contain a mixture of different types. If an array property 
    does contain non-homogeneous types, a value transformer can be used to transform the property into a custom format 
    (e.g. potentially an encoded string). */
- (Class)classForArrayElementsOfProperty:(NSString *)property;

/*! @brief Return the class of the object with the given key path, with the root object being an NSDictionary.
    @details Implement this method when a dictionary contains a custom object as a value in a key-value pair. The key path
    always contains the root dictionary's property as its first element, and follows the Cocoa convention of a dot-separated 
    string of keys. */
- (Class)classForDictionaryObjectWithKeyPath:(NSString *)keyPath;

@end


#pragma mark - FSJSONSerialization
@interface FSJSONSerialization : NSObject

/*! @brief Returns the JSON representation of the given object, or nil if a valid JSON object could not be created or if \c object was nil. */
+ (NSDictionary *)JSONFromObject:(id<FSJSONSerializable>)object;

/*! @brief Loads the JSON from the given file. 
    @details This method is the same as calling -JSONFromFile:withOptions:error: with \c NSJSONReadingMutableContainers as the option. 
    @return The JSON representation of the data in the given file, or nil if the file could not be opened, was nil, or a valid JSON object could 
    not be created. */
+ (NSDictionary *)JSONFromFile:(NSString *)file error:(NSError * __autoreleasing *)error;

/*! @brief Loads the JSON from the given file with options.
    @sa JSONFromFile:error: */
+ (NSDictionary *)JSONFromFile:(NSString *)file withOptions:(NSJSONReadingOptions)options error:(NSError * __autoreleasing *)error;

/*! @brief Writes the JSON representation to the given file.
    @details This method is the same as calling -writeJSON:toFile:withOptions:error: with \c NSJSONWritingPrettyPrinted as the option. 
    @return YES if the JSON object was written successfully to the file, otherwise NO. Failure to write the JSON object will occur if 
    either \c json or \c file are nil, if the file could not be opened, or if there was an error writing to the file. */
+ (BOOL)writeJSON:(NSDictionary *)json toFile:(NSString *)file error:(NSError * __autoreleasing *)error;

/*! @brief Writes the JSON representation to the given file with options. 
    @sa writeJSON:toFile:error: */
+ (BOOL)writeJSON:(NSDictionary *)json toFile:(NSString *)file withOptions:(NSJSONWritingOptions)options error:(NSError * __autoreleasing *)error;

/*! @brief Sets the data in the given object from its JSON representation. 
    @return YES on success, or NO if there was an error. An error will occur if either \c object or \c json are nil, if \c json is not a valid 
    JSON object, or \c object does not conform to \c FSJSONSerializable. */
+ (BOOL)setObject:(id<FSJSONSerializable>)object fromJSON:(NSDictionary *)json;

/*! @brief Serializes the given object to JSON and writes it to the specified file.
    @return YES on success, or NO on error. An error will occur if either \c object or \c file are nil, if the file could not be opened, if object could not 
    be serialized into a valid JSON object, or if there was an error writing to the file. */
+ (BOOL)serializeObject:(id<FSJSONSerializable>)object toFile:(NSString *)file error:(NSError * __autoreleasing *)error;

/*! @brief Creates a new instance of an object whose type is the given class from the JSON representation.
    @return A new instance of the given class with data from \c json, or nil on error. An error will occur if either \c cl or \c json are nil, if \c json is
    not a valid JSON object, or if instances of the given class do not conform to \c FSJSONSerializable. */
+ (id)objectOfClass:(Class)cl fromJSON:(NSDictionary *)json;

/*! @brief Creates a new instance of an object whose type is the given class from the JSON data in the file.
    @return A new instance of the given class with data from the JSON file, or nil on error. An error will occur if either \c cl or \c file are nil, or if the 
    file could not be opened, or a valid JSON object could be created from the data in \c file. */
+ (id)deserializeObjectOfClass:(Class)cl fromFile:(NSString *)file error:(NSError * __autoreleasing *)error;

/*! @brief Returns the default date formatter used when serializing \c NSDate objects. */
+ (NSDateFormatter *)defaultDateFormatter;

@end


#pragma mark - Value transformers
@interface FSDateToUnixTimeTransformer : NSValueTransformer
@end

@interface FSRangeTransformer : NSValueTransformer
@end
