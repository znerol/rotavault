//
//  LCSPlistTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperationTest.h"
#import "LCSPlistTaskOperation.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSPlistTaskOperationTest

-(void)setUp
{
    error = nil;
}

-(void)tearDown
{
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
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/sbin/system_profiler"];
    op.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:
                    [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil]];

    id result;
    op.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];

    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"error must be nil for successfull run");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"Result must contain an array");
    [op release];
}

- (void)testNonPlistTaskOperation
{
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/sbin/system_profiler"];
    op.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:
                    [NSArray arrayWithObjects: @"SPDiagnosticsDataType", nil]];

    id result;
    op.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    
    [op setDelegate:self];
    [op start];

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
