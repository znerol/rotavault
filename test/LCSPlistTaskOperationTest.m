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
#import "LCSRotavaultError.h"


@implementation LCSPlistTaskOperationTest

-(void)setUp
{
    error = nil;
}

-(void)tearDown
{
    [error release];
    error = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    if (error == inError) {
        return;
    }
    [error release];
    error = [inError retain];
}

- (void)testSimplePlistTaskOperation
{
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc] init];
    op.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/sbin/system_profiler"];
    op.arguments = [LCSSimpleOperationInputParameter parameterWithValue:
                    [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil]];

    id result = nil;
    op.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];

    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"%@", @"error must be nil for successfull run");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"%@", @"Result must contain an array");
    [result release];
    [op release];
}

- (void)testNonPlistTaskOperation
{
    LCSPlistTaskOperation* op = [[LCSPlistTaskOperation alloc] init];
    op.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/sbin/system_profiler"];
    op.arguments = [LCSSimpleOperationInputParameter parameterWithValue:
                    [NSArray arrayWithObjects: @"SPDiagnosticsDataType", nil]];

    id result = nil;
    op.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    
    [op setDelegate:self];
    [op start];

    STAssertNotNil(error, @"%@", @"error must be set if the output of the task is not a property list");
    STAssertEquals([error class], [NSError class], @"%@",
                   @"LCSTaskOperation must return an LCSTaskOperationError if the output of the task is not a property"
                   @"list");
    STAssertEquals([error code], (NSInteger)LCSPropertyListParseError, @"%@",
                   @"LCSTaskOperation must set the error code to LCSLaunchOfExecutableFailed if the output of the "
                   @"task is not a property list");
    [result release];
    [op release];
}

@end
