//
//  LCSOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationTest.h"
#import "LCSOperation.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"

#import <OCMock/OCMock.h>

@interface LCSTestOperationThrowingException : LCSOperation
@end

@implementation LCSTestOperationThrowingException
-(void)execute
{
    [[NSException exceptionWithName:@"test exception" reason:@"unknown" userInfo:nil] raise];
}
@end


@implementation LCSOperationTest
-(void)testOperationThrowingException
{
    LCSTestOperationThrowingException *op = [[LCSTestOperationThrowingException alloc] init];

    id mock = [[OCMockObject mockForProtocol:@protocol(LCSOperationDelegate)] retain];
    [[mock expect] operation:op handleException:[NSException exceptionWithName:@"test exception"
                                                                        reason:@"unknown" userInfo:nil]];
    op.delegate = mock;
    [op start];
    
    [op release];
    
    [mock verify];
    [mock release];
}

-(void)testOperationThrowingExceptionInQueue
{
    LCSTestOperationThrowingException *op = [[LCSTestOperationThrowingException alloc] init];
    
    id mock = [[OCMockObject mockForProtocol:@protocol(LCSOperationDelegate)] retain];
    [[mock expect] operation:op handleException:[NSException exceptionWithName:@"test exception"
                                                                        reason:@"unknown" userInfo:nil]];
    op.delegate = mock;
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:op];
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];

    [queue release];
    [op release];
    
    [mock verify];
    [mock release];
}
@end
