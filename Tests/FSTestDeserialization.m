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
//  Created by Christian Floisand on 2017-06-12.
//

#import <XCTest/XCTest.h>
#import "FSSerializableObject.h"
#import "FSTests.h"


@interface FSJSONDeserializationTestCase : XCTestCase
@property (nonatomic, strong) FSSerializableObject *serializableObject;
@property (nonatomic, strong) NSDictionary *json;
@end

@implementation FSJSONDeserializationTestCase

- (void)setUp {
    [super setUp];
    self.serializableObject = [FSSerializableObject new];
    
    NSDate *date = [NSDate date];
    NSString *dateString = [[FSJSONSerialization defaultDateFormatter] stringFromDate:date];
    NSString *customDateString = [[self.serializableObject dateFormatterForDateProperty:@"customDate"] stringFromDate:date];
    const uint8_t bytes[] = {0xDA, 0xDA, 0xBA, 0xDC, 0xFF, 0xEE};
    NSString *dataString = [[NSData dataWithBytes:bytes length:sizeof(bytes)] base64EncodedStringWithOptions:0];
    NSString *mutableDataString = [[NSMutableData dataWithBytes:bytes length:sizeof(bytes)] base64EncodedStringWithOptions:0];
    NSTimeInterval unixTime = date.timeIntervalSince1970;
    
    self.json = @{@"name": @"Uppercut",
                  @"mutableName": @"Mutable Uppercut",
                  @"aNumber": @(24),
                  @"anInteger": @(24),
                  @"aBool": @YES,
                  @"aCBool": @(true),
                  @"aChar": @('u'),
                  @"aShort": @(SHRT_MIN),
                  @"anInt": @(INT_MAX),
                  @"aLong": @(LONG_MIN),
                  @"aLongLong": @(LONG_LONG_MAX),
                  @"aUChar": @('p'),
                  @"aUShort": @(USHRT_MAX),
                  @"aUInt": @(UINT_MAX),
                  @"aULong": @(ULONG_MAX),
                  @"aULongLong": @(ULONG_LONG_MAX),
                  @"aFloat": @(3.14f),
                  @"aDouble": @(5.33),
                  @"aDate": dateString,
                  @"customDate": customDateString,
                  @"someData": dataString,
                  @"someMutableData": mutableDataString,
                  @"nullObject": [NSNull null],
                  @"anArray": @[@"three", @"two", @"one"],
                  @"aMutableArray": [NSMutableArray arrayWithObjects:@"three", @"two", @"one", nil],
                  @"aDictionary": @{@"oneKey": @"one", @"twoKey": @"two", @"threeKey": @"three"},
                  @"aMutableDictionary": [NSMutableDictionary dictionaryWithObjectsAndKeys:@"red", @"redKey", @"green", @"greenKey", @"blue", @"blueKey", nil],
                  @"arrayWithNull": @[@"NotNull", [NSNull null]],
                  @"dictionaryWithNull": @{@"NotNullKey": @"NotNull", @"NullKey": [NSNull null]},
                  @"foo": @{@"foo": @"bar"},
                  @"aFooArray": @[@{@"foo": @"bar0"}, @{@"foo": @"bar1"}, @{@"foo": @"bar2"}],
                  @"aFooDictionary": @{@"foo0": @{@"foo": @"foo0"}, @"foo1": @{@"foo": @"foo1"}, @"foo2": @{@"foo": @"foo2"}},
                  @"aStruct": @{@"num": @(2121)},
                  @"aUnion": @{@"ch": @('c'), @"num": @(99)},
                  @"unixDate": @(unixTime),
                  @"aRange": @{@"location": @(3), @"length": @(99)},
                  @"saila": @"baz",
                  @"anIvar": @(29)};
    
    BOOL success = [FSJSONSerialization setObject:self.serializableObject fromJSON:self.json];
    XCTAssertTrue(success, @"");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDeserializeNilObject {
    BOOL success = [FSJSONSerialization setObject:nil fromJSON:self.json];
    XCTAssertFalse(success, @"");
}

- (void)testDeserializeNilJSON {
    BOOL success = [FSJSONSerialization setObject:self.serializableObject fromJSON:nil];
    XCTAssertFalse(success, @"");
}

- (void)testDeserializeInvalidObject {
    FSInvalidObject *invalidObject = [FSInvalidObject new];
    invalidObject.invalid = @"foobar";
    BOOL success = [FSJSONSerialization setObject:(id<FSJSONSerializable>)invalidObject fromJSON:self.json];
    XCTAssertFalse(success, @"");
}

- (void)testDeserializeInvalidJSON {
    BOOL success = [FSJSONSerialization setObject:self.serializableObject fromJSON:@{@(10): @"ten"}];
    XCTAssertFalse(success, @"");
}

#pragma mark - Strings
// ------------------------------------------------------------------------------------------

- (void)testDeserializeString {
    XCTAssertTrue([self.serializableObject.name isEqualToString:self.json[@"name"]], @"");
}

- (void)testDeserializeMutableString {
    XCTAssertTrue([self.serializableObject.mutableName isKindOfClass:[NSMutableString class]], @"");
    XCTAssertTrue([self.serializableObject.mutableName isEqualToString:self.json[@"mutableName"]], @"");
}

#pragma mark - Numbers and primitives
// ------------------------------------------------------------------------------------------

- (void)testDeserializeNumber {
    NSNumber *deserializedNumber = self.serializableObject.aNumber;
    XCTAssertNotNil(deserializedNumber);
    XCTAssertEqualObjects(deserializedNumber, self.json[@"aNumber"], @"");
}

- (void)testDeserializeInteger {
    NSInteger deserializedInteger = self.serializableObject.anInteger;
    XCTAssertEqual(deserializedInteger, [self.json[@"anInteger"] integerValue], @"");
}

- (void)testDeserializeBool {
    BOOL deserializedBool = self.serializableObject.aBool;
    XCTAssertEqual(deserializedBool, [self.json[@"aBool"] boolValue], @"");
}

- (void)testDeserializeCBool {
    bool deserializedCBool = self.serializableObject.aCBool;
    XCTAssertEqual(deserializedCBool, [self.json[@"aCBool"] boolValue], @"");
}

- (void)testDeserializeChar {
    char deserializedChar = self.serializableObject.aChar;
    XCTAssertEqual(deserializedChar, [self.json[@"aChar"] charValue], @"");
}

- (void)testDeserializeShort {
    short deserializedShort = self.serializableObject.aShort;
    XCTAssertEqual(deserializedShort, [self.json[@"aShort"] shortValue], @"");
}

- (void)testDeserializeInt {
    int deserializedInt = self.serializableObject.anInt;
    XCTAssertEqual(deserializedInt, [self.json[@"anInt"] intValue], @"");
}

- (void)testDeserializeLong {
    long deserializedLong = self.serializableObject.aLong;
    XCTAssertEqual(deserializedLong, [self.json[@"aLong"] longValue], @"");
}

- (void)testDeserializeLongLong {
    long long deserializedLongLong = self.serializableObject.aLongLong;
    XCTAssertEqual(deserializedLongLong, [self.json[@"aLongLong"] longLongValue], @"");
}

- (void)testDeserializeUnsignedChar {
    unsigned char deserializedUChar = self.serializableObject.aUChar;
    XCTAssertEqual(deserializedUChar, [self.json[@"aUChar"] unsignedCharValue], @"");
}

- (void)testDeserializeUnsignedShort {
    unsigned short deserializedUShort = self.serializableObject.aUShort;
    XCTAssertEqual(deserializedUShort, [self.json[@"aUShort"] unsignedShortValue], @"");
}

- (void)testDeserializeUnsignedInt {
    unsigned int deserializedUInt = self.serializableObject.aUInt;
    XCTAssertEqual(deserializedUInt, [self.json[@"aUInt"] unsignedIntValue], @"");
}

- (void)testDeserializeUnsignedLong {
    unsigned long deserializedULong = self.serializableObject.aULong;
    XCTAssertEqual(deserializedULong, [self.json[@"aULong"] unsignedLongValue], @"");
}

- (void)testDeserializeUnsignedLongLong {
    unsigned long long deserializedULongLong = self.serializableObject.aULongLong;
    XCTAssertEqual(deserializedULongLong, [self.json[@"aULongLong"] unsignedLongLongValue], @"");
}

- (void)testDeserializeFloat {
    float deserializedFloat = self.serializableObject.aFloat;
    XCTAssertEqualWithAccuracy(deserializedFloat, [self.json[@"aFloat"] floatValue], FSJSON_TESTS_FLOAT_ACCURACY, @"");
}

- (void)testDeserializeDouble {
    double deserializedDouble = self.serializableObject.aDouble;
    XCTAssertEqualWithAccuracy(deserializedDouble, [self.json[@"aDouble"] doubleValue], FSJSON_TESTS_DOUBLE_ACCURACY, @"");
}

#pragma mark - Other object types
// ------------------------------------------------------------------------------------------

- (void)testDeserializeDefaultDate {
    NSDate *deserializedDate = self.serializableObject.aDate;
    XCTAssertNotNil(deserializedDate, @"");
    NSDateFormatter *defaultDateFormatter = [FSJSONSerialization defaultDateFormatter];
    NSString *deserializedDateString = [defaultDateFormatter stringFromDate:deserializedDate];
    XCTAssertNotNil(deserializedDateString, @"");
    XCTAssertTrue([deserializedDateString isEqualToString:self.json[@"aDate"]], @"");
}

- (void)testDeserializeCustomDate {
    NSDate *deserializedCustomDate = self.serializableObject.customDate;
    XCTAssertNotNil(deserializedCustomDate, @"");
    NSDateFormatter *dateFormatter = [self.serializableObject dateFormatterForDateProperty:@"customDate"];
    NSString *deserializedCustomDateString = [dateFormatter stringFromDate:deserializedCustomDate];
    XCTAssertNotNil(deserializedCustomDateString, @"");
    XCTAssertTrue([deserializedCustomDateString isEqualToString:self.json[@"customDate"]], @"");
}

- (void)testDeserializeData {
    NSData *deserializedData = self.serializableObject.someData;
    XCTAssertNotNil(deserializedData, @"");
    XCTAssertTrue([deserializedData isEqualToData:[[NSData alloc] initWithBase64EncodedString:self.json[@"someData"] options:NSDataBase64DecodingIgnoreUnknownCharacters]]);
}

- (void)testDeserializeMutableData {
    NSMutableData *deserializedMutableData = self.serializableObject.someMutableData;
    XCTAssertNotNil(deserializedMutableData, @"");
    XCTAssertTrue([deserializedMutableData isKindOfClass:[NSMutableData class]], @"");
    XCTAssertTrue([deserializedMutableData isEqualToData:[[NSData alloc] initWithBase64EncodedString:self.json[@"someMutableData"] options:NSDataBase64DecodingIgnoreUnknownCharacters]]);
}

- (void)testDeserializeNull {
    NSNull *deserializedNull = self.serializableObject.nullObject;
    XCTAssertNotNil(deserializedNull, @"");
    XCTAssertEqualObjects(deserializedNull, self.json[@"nullObject"], @"");
}

#pragma mark - Collections
// ------------------------------------------------------------------------------------------

- (void)testDeserializeArray {
    NSArray *deserializedArray = self.serializableObject.anArray;
    XCTAssertNotNil(deserializedArray, @"");
    XCTAssertEqualObjects(deserializedArray, self.json[@"anArray"], @"");
}

- (void)testDeserializeMutableArray {
    NSMutableArray *deserializedMutableArray = self.serializableObject.aMutableArray;
    XCTAssertNotNil(deserializedMutableArray, @"");
    XCTAssertTrue([deserializedMutableArray isKindOfClass:[NSMutableArray class]], @"");
    XCTAssertEqualObjects(deserializedMutableArray, self.json[@"aMutableArray"], @"");
}

- (void)testDeserializeDictionary {
    NSDictionary *deserializedDictionary = self.serializableObject.aDictionary;
    XCTAssertNotNil(deserializedDictionary, @"");
    XCTAssertEqualObjects(deserializedDictionary, self.json[@"aDictionary"], @"");
}

- (void)testDeserializeMutableDictionary {
    NSMutableDictionary *deserializedMutableDictionary = self.serializableObject.aMutableDictionary;
    XCTAssertNotNil(deserializedMutableDictionary, @"");
    XCTAssertTrue([deserializedMutableDictionary isKindOfClass:[NSMutableDictionary class]], @"");
    XCTAssertEqualObjects(deserializedMutableDictionary, self.json[@"aMutableDictionary"], @"");
}

- (void)testDeserializeArrayWithNull {
    NSArray *deserializedArray = self.serializableObject.arrayWithNull;
    XCTAssertNotNil(deserializedArray, @"");
    XCTAssertEqual(deserializedArray.count, [self.json[@"arrayWithNull"] count], @"");
    XCTAssertEqualObjects(deserializedArray, self.json[@"arrayWithNull"], @"");
}

- (void)testDeserializeDictionaryWithNull {
    NSDictionary *deserializedDictionary = self.serializableObject.dictionaryWithNull;
    XCTAssertNotNil(deserializedDictionary, @"");
    XCTAssertEqual(deserializedDictionary.count, [self.json[@"dictionaryWithNull"] count], @"");
    XCTAssertEqualObjects(deserializedDictionary, self.json[@"dictionaryWithNull"], @"");
}

#pragma mark - Custom objects
// ------------------------------------------------------------------------------------------

- (void)testDeserializeCustomObject {
    FSFoo *deserializedFoo = self.serializableObject.foo;
    XCTAssertNotNil(deserializedFoo, @"");
    XCTAssertTrue([deserializedFoo.foo isEqualToString:[self.json[@"foo"] objectForKey:@"foo"]], @"");
}

#pragma mark - Custom object collections
// ------------------------------------------------------------------------------------------

- (void)testDeserializeCustomObjectArray {
    NSArray<FSFoo*> *deserializedFooArray = self.serializableObject.aFooArray;
    XCTAssertNotNil(deserializedFooArray, @"");
    [deserializedFooArray enumerateObjectsUsingBlock:^(FSFoo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XCTAssertTrue([obj.foo isEqualToString:[[self.json[@"aFooArray"] objectAtIndex:idx] objectForKey:@"foo"]]);
    }];
}

- (void)testDeserializeCustomObjectDictionary {
    NSDictionary<NSString*,FSFoo*> *deserializedFooDictionary = self.serializableObject.aFooDictionary;
    XCTAssertNotNil(deserializedFooDictionary, @"");
    [deserializedFooDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, FSFoo * _Nonnull obj, BOOL * _Nonnull stop) {
        XCTAssertTrue([obj.foo isEqualToString:[[self.json[@"aFooDictionary"] objectForKey:key] objectForKey:@"foo"]]);
    }];
}

#pragma mark - C types
// ------------------------------------------------------------------------------------------

- (void)testDeserializeCStruct {
    FSStruct deserializedStruct = self.serializableObject.aStruct;
    XCTAssertEqual(deserializedStruct.num, [[self.json[@"aStruct"] objectForKey:@"num"] intValue], @"");
}

- (void)testDeserializeCUnion {
    FSUnion deserializedUnion = self.serializableObject.aUnion;
    XCTAssertEqual(deserializedUnion.ch, [[self.json[@"aUnion"] objectForKey:@"ch"] charValue], @"");
}

#pragma mark - Value transforming
// ------------------------------------------------------------------------------------------

- (void)testDeserializeValueTransformingDateToUnixTime {
    NSDate *deserializedUnixDate = self.serializableObject.unixDate;
    XCTAssertNotNil(deserializedUnixDate, @"");
    XCTAssertEqualWithAccuracy(deserializedUnixDate.timeIntervalSince1970, [self.json[@"unixDate"] doubleValue], FSJSON_TESTS_DOUBLE_ACCURACY, @"");
}

- (void)testDeserializeRange {
    NSRange deserializedRange = self.serializableObject.aRange;
    XCTAssertEqual(deserializedRange.location, [[self.json[@"aRange"] objectForKey:@"location"] integerValue], @"");
    XCTAssertEqual(deserializedRange.length, [[self.json[@"aRange"] objectForKey:@"length"] integerValue], @"");
}

#pragma mark - Ignored properties
// ------------------------------------------------------------------------------------------

- (void)testDeserializeIgnoredProperty {
    NSString *ignoredString = self.serializableObject.ignored;
    XCTAssertNil(ignoredString, @"");
}

#pragma mark - Key mapping
// ------------------------------------------------------------------------------------------

- (void)testDeserializeKeyMapping {
    NSString *aliasString = self.serializableObject.alias;
    XCTAssertNotNil(aliasString, @"");
    XCTAssertTrue([aliasString isEqualToString:self.json[self.serializableObject.keyMap[@"alias"]]], @"");
}

#pragma mark - Instance variables
// ------------------------------------------------------------------------------------------

- (void)testDeserializeInstanceVariable {
    NSUInteger deserializedIvar = [self.serializableObject getIvar];
    XCTAssertEqual(deserializedIvar, [self.json[@"anIvar"] integerValue], @"");
}

#pragma mark - Subclasses
// ------------------------------------------------------------------------------------------

- (void)testDeserializeSubclass {
    FSSubObject *subObject = [FSSubObject new];
    NSDictionary *json = @{@"name": @"super", @"subString": @"sub"};
    BOOL success = [FSJSONSerialization setObject:subObject fromJSON:json];
    XCTAssertTrue(success, @"");
    
    NSString *deserializedSuperString = subObject.name;
    NSString *deserializedSubString = subObject.subString;
    XCTAssertNotNil(deserializedSuperString, @"");
    XCTAssertNotNil(deserializedSubString, @"");
    XCTAssertTrue([deserializedSuperString isEqualToString:json[@"name"]], @"");
    XCTAssertTrue([deserializedSubString isEqualToString:json[@"subString"]], @"");
}

@end
