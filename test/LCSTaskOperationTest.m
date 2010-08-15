//
//  LCSTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationTest.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSTaskOperation.h"
#import "LCSTestdir.h"
#import "LCSSimpleOperationParameter.h"

#import <OCMock/OCMock.h>

@interface NSError (EqualToError)
-(BOOL)isEqualToError:(NSError*)other;
@end

@implementation NSError (EqualToError)
-(BOOL)isEqualToError:(NSError*)other
{
    BOOL same = ([self code] == [other code] && [[self domain] isEqualToString:[other domain]]);
    return same;
}
@end

@implementation LCSTaskOperationTest

- (void)setUp
{
    launched = NO;
    dataout = [[NSMutableData alloc] init];
    dataerr = [[NSMutableData alloc] init];

    /* stub calls into aggregate object */
    mock = [[OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)] retain];

    /* forward these to test case */
    [[[mock stub] andCall:@selector(operation:updateStandardOutput:) onObject:self] operation:[OCMArg any] updateStandardOutput:[OCMArg any]];
    [[[mock stub] andCall:@selector(operation:updateStandardError:) onObject:self] operation:[OCMArg any] updateStandardError:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationLaunched:) onObject:self] taskOperationLaunched:[OCMArg any]];
}

- (void)tearDown
{
    [mock release];
    mock = nil;
    [dataout release];
    [dataerr release];
    dataout = nil;
    dataerr = nil;
}

-(void)operation:(LCSTaskOperationBase*)operation updateStandardOutput:(NSData*)stdoutData
{
    [dataout appendData:stdoutData];
}

-(void)operation:(LCSTaskOperationBase*)operation updateStandardError:(NSData*)stderrData
{
    [dataerr appendData:stderrData];
}

-(void)taskOperationLaunched:(LCSTaskOperationBase*)operation
{
    launched = YES;
}

- (void)testSuccessfullTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/bin/true"];

    [[mock expect] operation:op terminatedWithStatus:[NSNumber numberWithInt:0]];

    [op setDelegate:mock];
    [op start];
    
    [mock verify];
    [op release];
}

- (void)testNonZeroStatusTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/bin/false"];

    /* expect non-zero status error */
    NSError *termError = [NSError errorWithDomain:LCSRotavaultErrorDomain
                                             code:LCSExecutableReturnedNonZeroStatus
                                         userInfo:[NSDictionary dictionary]];
    id equalToTermError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:termError];
    [[mock expect] operation:op handleError:equalToTermError];

    /* expect call to delegate */
    [[mock expect] operation:op terminatedWithStatus:[NSNumber numberWithInt:1]];
    
    [op setDelegate:mock];
    [op start];

    [mock verify];
    [op release];
}

- (void)testCancel
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/bin/sleep"];
    op.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:[NSArray arrayWithObject:@"10"]];

    /* expect cancel error */
    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                               code:NSUserCancelledError
                                           userInfo:[NSDictionary dictionary]];
    id equalToCancelError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:cancelError];
    
    /* expect non-zero status error */
    [[mock expect] operation:op handleError:equalToCancelError];
    NSError *termError = [NSError errorWithDomain:LCSRotavaultErrorDomain
                                               code:LCSExecutableReturnedNonZeroStatus
                                           userInfo:[NSDictionary dictionary]];
    id equalToTermError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:termError];
    [[mock expect] operation:op handleError:equalToTermError];
    
    [[mock expect] operation:op terminatedWithStatus:[NSNumber numberWithInt:2]];
    [op setDelegate:mock];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];

    while(!launched) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    /* FIXME: hum... race condition here? */
    usleep(1000);

    [op cancel];

    /* from NSOperationQueue+NonBlockingWaitUntilFinished */
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];
    
    [mock verify];
    [op release];
    [queue release];
}

- (void)testNonExistingBinary
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];

    NSString *nowhere = [[testdir path] stringByAppendingPathComponent:@"nowhere"];
    LCSTaskOperation* op = [[LCSTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:nowhere];

    NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain
                                         code:LCSLaunchOfExecutableFailed
                                     userInfo:[NSDictionary dictionary]];
    id equalToError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:error];
    [[mock expect] operation:op handleError:equalToError];
    
    [op setDelegate:mock];
    [op start];

    [mock verify];
    [op release];
    
    [testdir remove];
    [testdir release];
}

- (void)testEchoHello
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] init];
    op.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/bin/echo"];
    op.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:[NSArray arrayWithObject:@"Hello"]];
    [[mock expect] operation:op terminatedWithStatus:[NSNumber numberWithInt:0]];

    [op setDelegate:mock];
    [op start];

    NSString *outstring = [[NSString alloc] initWithData:dataout encoding:NSUTF8StringEncoding];
    STAssertTrue([outstring isEqualToString:@"Hello\n"], @"Output missmatch");
    [outstring release];

    [mock verify];
    [op release];    
}
@end
