//
//  LCSTaskOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationTest.h"
#import "LCSTaskOperationDelegate.h"
#import "LCSTaskOperation.h"
#import "LCSTestdir.h"

#import <OCMock/OCMock.h>

@interface LCSTaskOperationTestAggregator : NSObject{
    BOOL finished;
    NSMutableData *dataout;
    NSMutableData *dataerr;
}
@property(readonly) BOOL finished;
@property(readonly) NSMutableData *dataout;
@property(readonly) NSMutableData *dataerr;
@end

@implementation LCSTaskOperationTestAggregator
@synthesize finished;
@synthesize dataout;
@synthesize dataerr;
-(id)init
{
    self = [super init];
    dataout = [[NSMutableData alloc]init];
    dataerr = [[NSMutableData alloc]init];
    finished = NO;
    return self;
}
-(void)taskOperation:(LCSTaskOperation*)operation
        updateOutput:(NSData*)stdoutData
             isAtEnd:(NSNumber*)atEnd
{
    [dataout appendData:stdoutData];
}

-(void)taskOperation:(LCSTaskOperation*)operation
         updateError:(NSData*)stderrData
             isAtEnd:(NSNumber*)atEnd
{
    [dataerr appendData:stderrData];
}

-(void)taskOperationFinished:(LCSTaskOperation*)operation
{
    finished = YES;
}

@end

@implementation LCSTaskOperationTest

- (void)testSuccessfullTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/usr/bin/true" arguments:nil];
    id mock = [OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:0]];

    /* stub calls into aggregate object */
    LCSTaskOperationTestAggregator *agg = [[LCSTaskOperationTestAggregator alloc] init];
    [[[mock stub] andCall:@selector(taskOperation:updateOutput:isAtEnd:) onObject:agg]
     taskOperation:op updateOutput:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperation:updateError:isAtEnd:) onObject:agg]
     taskOperation:op updateError:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationFinished:) onObject:agg] taskOperationFinished:op];

    [op setDelegate:mock];
    [op start];

    [mock verify];
    [op release];
    [agg release];
}

- (void)testNonZeroStatusTermination
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/usr/bin/false" arguments:nil];
    id mock = [OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:1]];
    
    /* stub calls into aggregate object */
    LCSTaskOperationTestAggregator *agg = [[LCSTaskOperationTestAggregator alloc] init];
    [[[mock stub] andCall:@selector(taskOperation:updateOutput:isAtEnd:) onObject:agg]
     taskOperation:op updateOutput:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperation:updateError:isAtEnd:) onObject:agg]
     taskOperation:op updateError:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationFinished:) onObject:agg] taskOperationFinished:op];
    
    [op setDelegate:mock];
    [op start];
    
    [mock verify];
    [op release];
    [agg release];
}

- (void)testCancel
{
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:@"/bin/sleep" arguments:[NSArray arrayWithObject:@"10"]];
    
    NSError *expectUserCancelledError = [OCMArg any];
    //        [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:[NSDictionary dictionary]];
    id mock = [OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)];
    [[mock expect] taskOperation:op terminatedWithStatus:[NSNumber numberWithInt:2]];
    [[mock expect] taskOperation:op handleError:expectUserCancelledError];
    
    /* stub calls into aggregate object */
    LCSTaskOperationTestAggregator *agg = [[LCSTaskOperationTestAggregator alloc] init];
    [[[mock stub] andCall:@selector(taskOperation:updateOutput:isAtEnd:) onObject:agg]
     taskOperation:op updateOutput:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperation:updateError:isAtEnd:) onObject:agg]
     taskOperation:op updateError:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationFinished:) onObject:agg] taskOperationFinished:op];
    
    [op setDelegate:mock];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];

    /* wait half a second before canceling the operation */
    usleep(100000);
    [op cancel];

    while(!agg.finished) {
        /* the dirty way */
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    [queue waitUntilAllOperationsAreFinished];
    
    [mock verify];
    [op release];
    [queue release];
    [agg release];
}

- (void)testNonExistingBinary
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];

    NSString *nowhere = [[testdir path] stringByAppendingPathComponent:@"nowhere"];
    LCSTaskOperation* op = [[LCSTaskOperation alloc] initWithLaunchPath:nowhere arguments:[NSArray array]];

    NSError *expectUserCancelledError = [OCMArg any];
    //        [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:[NSDictionary dictionary]];
    id mock = [OCMockObject mockForProtocol:@protocol(LCSTaskOperationDelegate)];
    [[mock expect] taskOperation:op handleError:expectUserCancelledError];
    
    /* stub calls into aggregate object */
    LCSTaskOperationTestAggregator *agg = [[LCSTaskOperationTestAggregator alloc] init];
    [[[mock stub] andCall:@selector(taskOperation:updateOutput:isAtEnd:) onObject:agg]
     taskOperation:op updateOutput:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperation:updateError:isAtEnd:) onObject:agg]
     taskOperation:op updateError:[OCMArg any] isAtEnd:[OCMArg any]];
    [[[mock stub] andCall:@selector(taskOperationFinished:) onObject:agg] taskOperationFinished:op];
    
    [op setDelegate:mock];
    [op start];

    [mock verify];
    [op release];
    [agg release];
}
@end
