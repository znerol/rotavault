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

-(void)setUp
{
    result = nil;
    error = nil;
}

-(void)tearDown
{
    if(result) {
        [result release];
        result = nil;
    }
    if(error) {
        [error release];
        error = nil;
    }
}

-(void)operation:(LCSTaskOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

-(void)operation:(LCSTaskOperation*)operation handleResult:(id)inResult
{
    result = [inResult retain];
}

- (void)testSimplePlistTaskOperation
{
    NSArray *args = [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil];
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc]
                                 initWithLaunchPath:@"/usr/sbin/system_profiler" arguments:args];

    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"error must be nil for successfull run");
    STAssertNotNil(result, @"Result must not be nil");
    [op release];
}

- (void)testNonPlistTaskOperation
{
    NSArray *args = [NSArray arrayWithObjects: @"SPDiagnosticsDataType", nil];
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc]
                                 initWithLaunchPath:@"/usr/sbin/system_profiler" arguments:args];

    [op setDelegate:self];
    [op start];

    STAssertNil(result, @"must not return any result for output in the wrong format");
    STAssertNotNil(error, @"error must be set if the output of the task is not a property list");
    STAssertEquals([error class], [LCSTaskOperationError class],
                   @"LCSTaskOperation must return an LCSTaskOperationError if the output of the task is not a property"
                   @"list");
    STAssertEquals([error code], (NSInteger)LCSUnexpectedOutputReceived,
                   @"LCSTaskOperation must set the error code to LCSLaunchOfExecutableFailed if the output of the "
                   @"task is not a property list");
    [op release];
}

@end
