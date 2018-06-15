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

#import "FSSerializableObject.h"


#pragma mark - FSSerializableObject
@implementation FSSerializableObject {
    NSUInteger _anIvar;
}

- (id)init {
    self = [super init];
    if (self) {
        _anIvar = 0xDADA;
    }
    return self;
}

- (NSSet<NSString*> *)doNotSerialize {
    return [NSSet setWithObject:@"ignored"];
}

- (NSDictionary<NSString*,NSString*> *)keyMap {
    static NSDictionary *keyMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyMap = @{@"alias": @"saila"};
    });
    return keyMap;
}

- (NSDateFormatter *)dateFormatterForDateProperty:(NSString *)property {
    if ([property isEqualToString:@"customDate"]) {
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

- (Class)classForArrayElementsOfProperty:(NSString *)property {
    if ([property isEqualToString:@"aFooArray"]) {
        return [FSFoo class];
    }
    return NULL;
}

- (Class)classForDictionaryObjectWithKeyPath:(NSString *)keyPath {
    NSArray<NSString*> *keyPathComponents = [keyPath componentsSeparatedByString:@"."];
    if ((keyPathComponents.count == 2) && [keyPathComponents.firstObject isEqualToString:@"aFooDictionary"]) {
        NSString *key = keyPathComponents.lastObject;
        if ([key isEqualToString:@"foo0"] || [key isEqualToString:@"foo1"] || [key isEqualToString:@"foo2"]) {
            return [FSFoo class];
        }
    }
    return NULL;
}

- (NSValueTransformer *)valueTransformerForProperty:(NSString *)property {
    if ([property isEqualToString:@"unixDate"]) {
        FSDateToUnixTimeTransformer *transformer = [FSDateToUnixTimeTransformer new];
        return transformer;
    } else if ([property isEqualToString:@"aRange"]) {
        FSRangeTransformer *transformer = [FSRangeTransformer new];
        return transformer;
    } else if ([property isEqualToString:@"aStruct"]) {
        FSStructValueTransformer *transformer = [FSStructValueTransformer new];
        return transformer;
    } else if ([property isEqualToString:@"aUnion"]) {
        FSUnionValueTransformer *transformer = [FSUnionValueTransformer new];
        return transformer;
    }
    return nil;
}

- (NSUInteger)getIvar {
    return _anIvar;
}

@end


#pragma mark - FSFoo
@implementation FSFoo

@end


#pragma mark - FSSubObject
@implementation FSSubObject

@end


#pragma mark - FSInvalidObject
@implementation FSInvalidObject

@end


#pragma mark - FSInvalidPropertyObject
@implementation FSInvalidPropertyObject

@end


#pragma mark - FSStructValueTransformer
@implementation FSStructValueTransformer

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    NSDictionary *dictValue = nil;
    if (value) {
        FSStruct structValue;
        [value getValue:&structValue];
        dictValue = @{@"num": @(structValue.num)};
    }
    return dictValue;
}

- (id)reverseTransformedValue:(id)value {
    NSValue *structValue = nil;
    if (value) {
        FSStruct str;
        str.num = [[value objectForKey:@"num"] intValue];
        structValue = [NSValue valueWithBytes:&str objCType:@encode(FSStruct)];
    }
    return structValue;
}

@end


#pragma mark - FSUnionValueTransformer
@implementation FSUnionValueTransformer

+ (Class)transformedValueClass {
    return [NSDictionary class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    NSDictionary *dictValue = nil;
    if (value) {
        FSUnion unionValue;
        [value getValue:&unionValue];
        dictValue = @{@"ch": @(unionValue.ch), @"num": @(unionValue.num)};
    }
    return dictValue;
}

- (id)reverseTransformedValue:(id)value {
    NSValue *structValue = nil;
    if (value) {
        FSUnion uni;
        uni.ch = [[value objectForKey:@"ch"] charValue];
        uni.num = [[value objectForKey:@"num"] intValue];
        structValue = [NSValue valueWithBytes:&uni objCType:@encode(FSUnion)];
    }
    return structValue;
}

@end
