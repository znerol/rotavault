//
//  LCSTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationTest.h"
#import "LCSTaskOperationDelegate.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSTaskOperation.h"
#import "LCSTestdir.h"

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
    finished = NO;
    launched = NO;
    dataout = [[NSMutableData alloc] init];
    dataerr = [[NSMutableData alloc] init];
    
    /* stub calls into aggregate object */
    mock = [[OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)] retain];
    [[[mock stub] andCall:@selector(taskOperation:updateStandardOutput:) onObject:self] taskOperation:[OCMArg any] updateStandardOutput:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperation:updateStandardError:) onObject:self] taskOperation:[OCMArg any] updateStandardError:[OCMArg any]];
    [[mock stub] taskOperationPreparing:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationLaunched:) onObject:self] taskOperationLaunched:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationFinished:) onObject:self] taskOperationFinished:[OCMArg any]];
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

-(void)taskOperation:(LCSTaskOperation*)operation updateStandardOutput:(NSData*)stdoutData
{
    [dataout appendData:stdoutData];
}

-(void)taskOperation:(LCSTaskOperation*)operation updateStandardError:(NSData*)stderrData
{
    [dataerr appendData:stderrData];
}

-(void)taskOperationLaunched:(LCSTaskOperation*)operation
{
    launched = YES;
}

-(void)taskOperationFinished:(LCSTaskOperation*)operation
{
    finished = YES;
}

- (void)testSuccessfullTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/usr/bin/true" arguments:nil];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:0]];

    [op setDelegate:mock];
    [op start];
    
    STAssertTrue(finished, @"Operation must be finished by now");
    [mock verify];
    [op release];
}

- (void)testNonZeroStatusTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/usr/bin/false" arguments:nil];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:1]];
    
    [op setDelegate:mock];
    [op start];

    STAssertTrue(finished, @"Operation must be finished by now");
    [mock verify];
    [op release];
}

- (void)testCancel
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/sleep"
                                                              arguments:[NSArray arrayWithObject:@"10"]];
    
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSUserCancelledError
                                     userInfo:[NSDictionary dictionary]];
    id equalToError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:error];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:2]];
    [[mock expect] taskOperation:op handleError:equalToError];
    [op setDelegate:mock];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];

    while(!launched) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    /* FIXME: hum... race condition here? usleep seems to help */
    usleep(1000);

    [op cancel];

    while(!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [mock verify];
    [op release];
    [queue release];
}

- (void)testNonExistingBinary
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];

    NSString *nowhere = [[testdir path] stringByAppendingPathComponent:@"nowhere"];
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:nowhere arguments:[NSArray array]];

    NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain
                                         code:LCSLaunchOfExecutableFailed
                                     userInfo:[NSDictionary dictionary]];
    id equalToError = [OCMArg checkWithSelector:@selector(isEqualToError:) onObject:error];
    [[mock expect] taskOperation:op handleError:equalToError];
    
    [op setDelegate:mock];
    [op start];

    STAssertTrue(finished, @"Operation must be finished by now");
    [mock verify];
    [op release];
    
    [testdir remove];
    [testdir release];
}

- (void)testEchoHello
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/echo"
                                                              arguments:[NSArray arrayWithObject:@"Hello"]];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:0]];

    [op setDelegate:mock];
    [op start];

    STAssertTrue(finished, @"Operation must be finished by now");
    NSString *outstring = [[NSString alloc] initWithData:dataout encoding:NSUTF8StringEncoding];
    STAssertTrue([outstring isEqualToString:@"Hello\n"], @"Output missmatch");
    [outstring release];

    [mock verify];
    [op release];    
}
@end
