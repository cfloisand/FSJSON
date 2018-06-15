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
//  Created by Christian Floisand on 2017-06-13.
//

#import <XCTest/XCTest.h>
#import "FSSerializableObject.h"


@interface FSJSONFileOperationsTestCase : XCTestCase
@property (nonatomic, strong) NSString *testsDir;
@end

@implementation FSJSONFileOperationsTestCase

- (void)setUp {
    [super setUp];
    
    // NOTE(christian): Set this value in the target's scheme:
    // (This needs to be done manually since Xcode scheme settings are not checked in with the repository.)
    // - Edit scheme...
    // - Select Test
    // - Uncheck 'Use the Run action's arguments and environment variables
    // - Set 'Expand Environment Variables Based On' to the target
    // - Add the environment variable: 'Name' = PROJECT_DIR, 'Value' = $PROJECT_DIR
    const char *projectDir = getenv("PROJECT_DIR");
    if (projectDir) {
        self.testsDir = [[NSString stringWithUTF8String:projectDir] stringByAppendingPathComponent:@"Tests"];
    } else {
        XCTAssert(NO, @"PROJECT_DIR environment variable not set in target's scheme!");
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadValidJSONFile {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingPathComponent:@"Serialized.json"];
        NSDictionary *json = [FSJSONSerialization JSONFromFile:filePath error:&error];
        XCTAssertNotNil(json, @"");
        XCTAssertNil(error, @"");
    }
}

- (void)testLoadUnknownJSONFile {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingString:@"Unknown.json"];
        NSDictionary *json = [FSJSONSerialization JSONFromFile:filePath error:&error];
        XCTAssertNil(json, @"");
        XCTAssertNotNil(error, @"");
    }
}

- (void)testLoadInvalidJSONFile {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingString:@"Invalid.json"];
        NSDictionary *json = [FSJSONSerialization JSONFromFile:filePath error:&error];
        XCTAssertNil(json, @"");
        XCTAssertNotNil(error, @"");
    }
}

- (void)testWriteValidJSONToFile {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingPathComponent:@"ValidOut.json"];
        BOOL success = [FSJSONSerialization writeJSON:@{@"foo": @"bar"} toFile:filePath error:&error];
        XCTAssertTrue(success, @"");
        XCTAssertNil(error, @"");
    }
}

- (void)testWriteInvalidJSONToFile {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingPathComponent:@"InvalidOut.json"];
        BOOL success = [FSJSONSerialization writeJSON:@{@(0): @"zero"} toFile:filePath error:&error];
        XCTAssertFalse(success, @"");
        XCTAssertNotNil(error, @"");
    }
}

- (void)testWriteValidJSONToUnknownFilePath {
    if (self.testsDir) {
        NSError *error;
        NSString *filePath = [self.testsDir stringByAppendingPathComponent:@"/Unknown/Unknown.json"];
        BOOL success = [FSJSONSerialization writeJSON:@{@"foo": @"bar"} toFile:filePath error:&error];
        XCTAssertFalse(success, @"");
        XCTAssertNotNil(error, @"");
    }
}

@end
