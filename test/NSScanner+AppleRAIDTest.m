//
//  NSScanner+AppleRAIDTest.m
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "NSScanner+AppleRAID.h"

@interface NSScannerAppleRAIDTest : GHTestCase
@end

@implementation NSScannerAppleRAIDTest
- (void)testEmptyRAIDList
{
    NSScanner *scanner = [NSScanner scannerWithString:@"No AppleRAID sets found\n"];
    NSArray *result = nil;
    BOOL ok = [scanner scanAppleRAIDList:&result];
    
    GHAssertTrue(ok, @"Scanner must report success");
    GHAssertTrue([scanner isAtEnd], @"Scanner must have reached the end");
    GHAssertEqualObjects(result, [NSArray array], @"Result must be an empty array");
}

- (void)testOneEntryRAIDList
{
    NSString *fixture = [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:fixture encoding:NSUTF8StringEncoding error:nil];
    
    NSScanner *scanner = [NSScanner scannerWithString:content];
    NSArray *result = nil;
    BOOL ok = [scanner scanAppleRAIDList:&result];
    
    GHAssertTrue(ok, @"Scanner must report success");
    GHAssertTrue([scanner isAtEnd], @"Scanner must have reached the end");
    GHAssertTrue([result isKindOfClass:[NSArray class]], @"Result must be an array");
    GHAssertEquals([result count], (NSUInteger)2, @"Result must contain exactly one entry");
}

- (void)testFailOnEmptyString
{
    NSScanner *scanner = [NSScanner scannerWithString:@""];
    NSArray *result = nil;
    BOOL ok = [scanner scanAppleRAIDList:&result];
    
    GHAssertFalse(ok, @"Scanner must report failure");
    GHAssertTrue([scanner isAtEnd], @"Scanner must have reached the end");
}

- (void)testFailOnAppleRAIDFailureMessage
{
    NSScanner *scanner = [NSScanner scannerWithString:@"AppleRAID: failed trying to get controller object, rc = 0xe00002c5."];
    NSArray *result = nil;
    BOOL ok = [scanner scanAppleRAIDList:&result];
    
    GHAssertFalse(ok, @"Scanner must report failure");
    GHAssertFalse([scanner isAtEnd], @"Scanner must not have reached the end");
}
@end
