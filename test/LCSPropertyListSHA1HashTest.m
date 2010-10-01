//
//  LCSPropertyListSHA1HashTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LCSPropertyListSHA1Hash.h"


@interface LCSPropertyListSHA1HashTest : SenTestCase
@end
    
@implementation LCSPropertyListSHA1HashTest

-(void)testSha1HashFromPropertyListContainingString
{
    NSString *teststring = @"Hello World";
    NSData *testhash = [LCSPropertyListSHA1Hash sha1HashFromPropertyList:teststring];

    unsigned char expectedBytes[] = {0x28, 0xe0, 0xb3, 0xee, 0x9b, 0x81, 0xa7, 0x7a, 0xf5, 0x03, 0xb7, 0x80, 0xa0,
        0x8e, 0x7f, 0x26, 0x20, 0xd7, 0xb5, 0x65};
    NSData *expected = [NSData dataWithBytes:expectedBytes length:sizeof(expectedBytes)];

    STAssertTrue([testhash isEqualTo:expected], @"%@", @"base64 representation of hash value does not match expected value");
}
@end
