//
//  LCSPlistTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperationTest.h"
#import "LCSPlistTaskOperation.h"


@implementation LCSPlistTaskOperationTest
- (void)testSimplePlistTaskOperation
{
    NSArray *args = [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil];
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc]
                                       initWithLaunchPath:@"/usr/sbin/system_profiler" arguments:args];
    [op start];
    STAssertNil(op.error, @"error must be nil for successfull run");
    STAssertNotNil(op.result, @"should not return nil");
    [op release];
}

- (void)testNonPlistTaskOperation
{
    NSArray *args = [NSArray arrayWithObjects: @"SPDiagnosticsDataType", nil];
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc]
                                 initWithLaunchPath:@"/usr/sbin/system_profiler" arguments:args];
    [op start];
    STAssertNil(op.result, @"must not return any result for output in the wrong format");
    STAssertNotNil(op.error, @"error must be set if the output of the task is not a property list");
    STAssertEquals([op.error class], [LCSTaskOperationError class],
                   @"LCSTaskOperation must return an LCSTaskOperationError if the output of the task is not a property"
                   @"list");
    STAssertEquals([op.error code], (NSInteger)LCSUnexpectedOutputReceived,
                   @"LCSTaskOperation must set the error code to LCSLaunchOfExecutableFailed if the output of the "
                   @"task is not a property list");
    [op release];
}

@end
