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

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

- (void)testSimplePlistTaskOperation
{
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc] init];
    op.launchPath = @"/usr/sbin/system_profiler";
    op.arguments = [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil];
    [op bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];

    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"error must be nil for successfull run");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"Result must contain an array");
    [op release];
}

- (void)testNonPlistTaskOperation
{
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc] init];
    op.launchPath = @"/usr/sbin/system_profiler";
    op.arguments = [NSArray arrayWithObject: @"SPDiagnosticsDataType"];
    [op bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];

    [op setDelegate:self];
    [op start];

    STAssertTrue([result isKindOfClass:[NSNull class]], @"must not return any result for output in the wrong format");
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
