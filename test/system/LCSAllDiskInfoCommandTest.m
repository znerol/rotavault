//
//  LCSAllDiskInfoCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSAllDiskInfoCommand.h"
#import "LCSCommand.h"


@interface LCSAllDiskInfoCommandTest : GHTestCase
@end


@implementation LCSAllDiskInfoCommandTest
-(void)testAllDiskInfoCommand
{
    LCSAllDiskInfoCommand *cmd = [LCSAllDiskInfoCommand command];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertTrue([cmd.result isKindOfClass:[NSArray class]], @"Result should be an array");
    GHAssertEqualObjects([[cmd.result objectAtIndex:0] valueForKey:@"DeviceIdentifier"], @"disk0",
                         @"Result should contain at least a whole-disk entry for the startup disk");
    GHAssertEqualObjects([[cmd.result objectAtIndex:1] valueForKey:@"DeviceIdentifier"], @"disk0s1",
                         @"Result should contain at least one partition on the startup disk");
}
@end
