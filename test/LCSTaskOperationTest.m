//
//  LCSTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationTest.h"
#import "LCSTaskOperation.h"
#import "LCSTestdir.h"


@implementation LCSTaskOperationTest
- (void)testEchoTask
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/echo"
                                                              arguments:[NSArray arrayWithObject:@"hello"]];

    [op start];

    STAssertNil(op.error, @"LCSTaskOperation must not set error on successfull run");
    NSString *outString = [[NSString alloc] initWithData:op.output encoding:NSUTF8StringEncoding];
    STAssertTrue([outString isEqualToString:@"hello\n"], @"LCSTaskOperation must aggregate the correct output");
    [outString release];
    [op release];
}

- (void)testCancelBeforeStart
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/echo"
                                                              arguments:[NSArray arrayWithObject:@"hello"]];

    [op cancel];
    [op start];

    STAssertNotNil(op.error, @"error must be set if operation was canceled");
    STAssertEquals([op.output length], (NSUInteger)0,
                   @"the output must be empty for a task which was canceled before started");
    STAssertTrue([op.error code] == NSUserCancelledError, @"error must be a user canceled error.");    
    [op release];
}

- (void)testCancelWhileRunning
{
    /* create a task doing nothing during ten seconds */
    NSArray *args = [NSArray arrayWithObject:@"10"];
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/sleep" arguments:args];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];

    /* poll runloop for 0.2 seconds */
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];

    /* cancel operations */
    [queue cancelAllOperations];
    [queue waitUntilAllOperationsAreFinished];

    STAssertNotNil(op.error, @"error must be set if operation was canceled");
    STAssertEquals([op.error code], (NSInteger)NSUserCancelledError, @"error must be a user canceled error.");    

    [op release];
    [queue release];
}

- (void)testNonExistingBinary
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];

    NSString *nowhere = [[testdir path] stringByAppendingPathComponent:@"nowhere"];
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:nowhere arguments:[NSArray array]];
    [op start];

    STAssertNotNil(op.error, @"LCSTaskOperation set an error if binary cannot be launched");
    STAssertEquals([op.error class], [LCSTaskOperationError class],
                   @"LCSTaskOperation must return an LCSTaskOperationError if launch path is not accessible");
    STAssertEquals([op.error code], (NSInteger)LCSLaunchOfExecutableFailed,
                   @"LCSTaskOperation must set the error code to LCSLaunchOfExecutableFailed if launch path is not "
                   @"accessible");

    [op release];
    [testdir remove];
    [testdir release];
}

- (void)testBinaryReturningNonZeroStatus
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/usr/bin/false"
                                                              arguments:[NSArray arrayWithObject:@"hello"]];

    [op start];

    STAssertNotNil(op.error, @"error must be set if task did exit with a non-zero status code");
    STAssertEquals([op.error class], [LCSTaskOperationError class],
                   @"LCSTaskOperation must return an LCSTaskOperationError if task did exit with a non-zero status "
                   @"code");
    STAssertEquals([op.error code], (NSInteger)LCSExecutableReturnedNonZeroStatus,
                   @"LCSTaskOperation must set the error code to LCSLaunchOfExecutableFailed task did exit with a "
                   @"non-zero status code");
    STAssertEquals([[op.error userInfo] objectForKey:LCSExecutableReturnStatus], [NSNumber numberWithInt:1],
                   @"LCSTaskOperation must set LCSExecutableReturnStatus to the proper value");
    [op release];    
}
@end
