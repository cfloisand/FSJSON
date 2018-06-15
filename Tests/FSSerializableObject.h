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
//  Created by Christian Floisand on 2017-06-09.
//

#import <Foundation/Foundation.h>
#import "FSJSON.h"


@class FSFoo;

struct _fs_struct {
    int num;
};
typedef struct _fs_struct FSStruct;

union _fs_union {
    char ch;
    int num;
};
typedef union _fs_union FSUnion;


#pragma mark - FSSerializableObject
@interface FSSerializableObject : NSObject<FSJSONSerializable>
// Strings
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableString *mutableName;

// Numbers and primitives
@property (nonatomic, strong) NSNumber *aNumber;
@property (nonatomic) NSInteger anInteger;
@property (nonatomic) BOOL aBool;
@property (nonatomic) bool aCBool;
@property (nonatomic) char aChar;
@property (nonatomic) short aShort;
@property (nonatomic) int anInt;
@property (nonatomic) long aLong;
@property (nonatomic) long long aLongLong;
@property (nonatomic) unsigned char aUChar;
@property (nonatomic) unsigned short aUShort;
@property (nonatomic) unsigned int aUInt;
@property (nonatomic) unsigned long aULong;
@property (nonatomic) unsigned long long aULongLong;
@property (nonatomic) float aFloat;
@property (nonatomic) double aDouble;

// Other object types
@property (nonatomic, strong) NSDate *aDate;
@property (nonatomic, strong) NSData *someData;
@property (nonatomic, strong) NSMutableData *someMutableData;
@property (nonatomic, strong) NSNull *nullObject;

// Collections
@property (nonatomic, strong) NSArray *anArray;
@property (nonatomic, strong) NSMutableArray *aMutableArray;
@property (nonatomic, strong) NSDictionary *aDictionary;
@property (nonatomic, strong) NSMutableDictionary *aMutableDictionary;
@property (nonatomic, strong) NSArray *arrayWithNull;
@property (nonatomic, strong) NSDictionary *dictionaryWithNull;

// Custom objects
@property (nonatomic, strong) FSFoo *foo;

// Custom object collections
@property (nonatomic, strong) NSArray<FSFoo*> *aFooArray;
@property (nonatomic, strong) NSDictionary<NSString*,FSFoo*> *aFooDictionary;

// C types
@property (nonatomic) FSStruct aStruct;
@property (nonatomic) FSUnion aUnion;

// Value transforming
@property (nonatomic, strong) NSDate *unixDate;
@property (nonatomic, strong) NSDate *customDate;
@property (nonatomic) NSRange aRange;

// Ignored properties
@property (nonatomic, strong) NSString *ignored;

// Key mapping
@property (nonatomic, strong) NSString *alias;

// Instance variables
- (NSUInteger)getIvar;

@end


#pragma mark - FSFoo
@interface FSFoo : NSObject<FSJSONSerializable>
@property (nonatomic, strong) NSString *foo;

@end


#pragma mark - FSSubObject
@interface FSSubObject : FSSerializableObject
@property (nonatomic, strong) NSString *subString;

@end


#pragma mark - FSInvalidObject
@interface FSInvalidObject : NSObject
@property (nonatomic, strong) NSString *invalid;

@end


#pragma mark - FSInvalidPropertyObject
@interface FSInvalidPropertyObject : NSObject<FSJSONSerializable>
@property (nonatomic, strong) NSSet *aSet;

@end


#pragma mark - 
@interface FSStructValueTransformer : NSValueTransformer
@end

@interface FSUnionValueTransformer : NSValueTransformer
@end
