//
//  LCSHelperInstallRotavaultJobCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 18.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSHelperInstallRotavaultJobCommand.h"

@interface LCSHelperInstallRotavaultJobCommandTest : GHTestCase
@end

@implementation LCSHelperInstallRotavaultJobCommandTest
-(void)testHelperCreateRotavaultJobDictionaryWithoutSchedule
{
    NSDictionary *result = (NSDictionary*)LCSHelperCreateRotavaultJobDictionary(CFSTR("test"), CFSTR("asr"), (CFDateRef)[NSNull null],
                                                                                CFSTR("/dev/disk0s1"), CFSTR("/dev/disk1s1"),
                                                                                CFSTR("uuid:F0117216-C262-41AC-BF4E-8D189E77FB93"),
                                                                                CFSTR("sha1:e5fa44f2b31c1fb553b6021e7360d07d5d91ff5e"));
    GHAssertNotNil(result, @"Result must not be null");
    NSDictionary *expect = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                       pathForResource:@"launchd-rvcopyd-runatload"
                                                                       ofType:@"plist"]];
    
    GHAssertEqualObjects(result, expect, @"Unexpected output");
}

-(void)testHelperCreateRotavaultJobDictionaryWithDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSDate *date = [dateFormatter dateFromString:@"2010-07-05 03:01"];
    [dateFormatter release];
    NSDictionary *result = (NSDictionary*)LCSHelperCreateRotavaultJobDictionary(CFSTR("test"), CFSTR("asr"), (CFDateRef)date,
                                                                                CFSTR("/dev/disk0s1"), CFSTR("/dev/disk1s1"),
                                                                                CFSTR("uuid:F0117216-C262-41AC-BF4E-8D189E77FB93"),
                                                                                CFSTR("sha1:e5fa44f2b31c1fb553b6021e7360d07d5d91ff5e"));
    GHAssertNotNil(result, @"Result must not be null");
    NSDictionary *expect = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                       pathForResource:@"launchd-rvcopyd-withrundate"
                                                                       ofType:@"plist"]];
    
    GHAssertEqualObjects(result, expect, @"Unexpected output");
}
@end
