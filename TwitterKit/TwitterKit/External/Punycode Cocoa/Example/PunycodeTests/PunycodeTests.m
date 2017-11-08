//
//  PunycodeTests.m
//  PunycodeTests
//
//  Created by Nate Weaver on 3/2/12.
//  Copyright (c) 2012 Derailer. All rights reserved.
//

#import "PunycodeTests.h"
#import "NSStringPunycodeAdditions.h"

@interface NSString (PunycodePrivate)

@property (readonly, copy) NSString *stringByDeletingVariationSelectors;

@end

@implementation PunycodeTests

- (void)setUp
{
    [super setUp];

    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testPunycodeEncoding
{
    NSDictionary *dict = @{ @"bücher": @"bcher-kva", @"президент": @"d1abbgf6aiiy", @"例え": @"r8jz45g" };

    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.punycodeEncodedString isEqualToString:obj], @"%@ should encode to %@", key, obj);
    }];
}

- (void)testPunycodeDecoding
{
    NSDictionary *dict = @{ @"bcher-kva": @"bücher", @"d1abbgf6aiiy": @"президент", @"r8jz45g": @"例え" };

    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.punycodeDecodedString isEqualToString:obj], @"%@ should decode to %@", key, obj);
    }];
}

- (void)testIDNAEncoding
{
    NSDictionary *dict = @{
        @"http://www.bücher.ch/": @"http://www.xn--bcher-kva.ch/",
    };
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.IDNAEncodedString isEqualToString:obj], @"%@ should encode to %@", key, obj);
    }];
}

- (void)testIDNDecoding
{
    NSDictionary *dict = @{ @"http://www.xn--bcher-kva.ch/": @"http://www.bücher.ch/" };
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.IDNADecodedString isEqualToString:obj], @"%@ should decode to %@", key, obj);
    }];
}

- (void)testFullURLEncoding
{
    NSDictionary *dict = @{
        @"http://www.bücher.ch/": @"http://www.xn--bcher-kva.ch/",
        @"http://www.bücher.ch/bücher": @"http://www.xn--bcher-kva.ch/b%C3%BCcher",
        @"https://www.google.co.jp/webhp?foo#q=渋谷": @"https://www.google.co.jp/webhp?foo#q=%E6%B8%8B%E8%B0%B7",
        @"https://www.google.co.jp/webhp?foo#q=%20渋谷": @"https://www.google.co.jp/webhp?foo#q=%20%E6%B8%8B%E8%B0%B7",
        @"http://foo:bar@example.com/": @"http://foo:bar@example.com/",
        @"http://föo:bår@example.com/": @"http://f%C3%B6o:b%C3%A5r@example.com/",
        @"http://föo@example.com/": @"http://f%C3%B6o@example.com/"
    };
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.encodedURLString isEqualToString:obj], @"%@ should encode to %@; encoded to %@", key, obj, key.encodedURLString);
    }];
}

- (void)testFullURLDecoding
{
    NSDictionary *dict = @{ @"http://www.xn--bcher-kva.ch/": @"http://www.bücher.ch/", @"http://www.xn--bcher-kva.ch/b%C3%BCcher": @"http://www.bücher.ch/bücher", @"https://www.google.co.jp/webhp?foo#q=%E6%B8%8B%E8%B0%B7": @"https://www.google.co.jp/webhp?foo#q=渋谷", @"http://foo:bar@example.com/": @"http://foo:bar@example.com/", @"http://f%C3%B6o:b%C3%A5r@example.com/": @"http://föo:bår@example.com/", @"http://f%C3%B6o@example.com/": @"http://föo@example.com/" };
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        XCTAssertTrue([key.decodedURLString isEqualToString:obj], @"%@ should decode to %@; decoded to %@", key, obj, key.decodedURLString);
    }];
}

- (void)testConvenienceMethods
{
    XCTAssertTrue([[NSURL URLWithUnicodeString:@"http://www.bücher.ch/"] isEqual:[NSURL URLWithString:@"http://www.xn--bcher-kva.ch/"]]);
    XCTAssertTrue([[NSURL URLWithString:@"http://www.xn--bcher-kva.ch/"].decodedURLString isEqualToString:@"http://www.bücher.ch/"]);
}

- (void)testVariationSelectorPerformance
{
    NSString *testString = @"ksfjlksfdjklfjfklfjkljskfljsklfjsl";
    [self measureBlock:^{
        for (NSUInteger i = 0; i < 100000; ++i) {
            (void)testString.stringByDeletingVariationSelectors;
        }
    }];
}

@end
