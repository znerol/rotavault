//
//  LCSCommandControllerCollectionTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "LCSCommandControllerCollection.h"
#import "LCSTestCommand.h"

@interface LCSCommandControllerCollectionTest : GHTestCase
@end


@protocol LCSCommandControllerCollectionTestNotificationConsumer
-(void)consumeNotification:(NSNotification*)ntf;
@end


@implementation LCSCommandControllerCollectionTest

-(void)testOneControllerWatchOneState
{
    LCSCommand *ctl = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    
    LCSCommandControllerCollection *col = [LCSCommandControllerCollection collection];
    [col addController:ctl];
    [col watchState:LCSCommandStateFinished];
    
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    [[mockall expect] consumeNotification:[OCMArg any]];
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[OCMArg any]];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:col];
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                               object:col];
    [ctl start];
    [ctl waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mockall];
    [[NSNotificationCenter defaultCenter] removeObserver:mockany];
    
    [mockall verify];
    [mockany verify];
}

-(void)testManyControllersWatchOneState
{
    LCSCommand *ctl1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl3 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    
    LCSCommandControllerCollection *col = [LCSCommandControllerCollection collection];
    [col addController:ctl1];
    [col addController:ctl2];
    [col addController:ctl3];
    [col watchState:LCSCommandStateFinished];
    
    
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl1 forKey:LCSCommandControllerCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl2 forKey:LCSCommandControllerCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl3 forKey:LCSCommandControllerCollectionOriginalSenderKey]]];
        
    /* FIXME: replace [OCMArg any] with properly initialized NSNotification. */
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    [[mockall expect] consumeNotification:[OCMArg any]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [ctl1 start];
    [ctl2 start];
    [ctl3 start];
    [ctl1 waitUntilDone];
    [ctl2 waitUntilDone];
    [ctl3 waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mockany];
    [[NSNotificationCenter defaultCenter] removeObserver:mockall];
    
    [col unwatchState:LCSCommandStateFinished];
    [col removeController:ctl1];
    [col removeController:ctl2];
    [col removeController:ctl3];
    
    [mockany verify];
    [mockall verify];
}

-(void)testManyControllersOneFailingWatchOneState
{
    LCSCommand *ctl1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl3 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFailed];
    
    LCSCommandControllerCollection *col = [LCSCommandControllerCollection collection];
    [col watchState:LCSCommandStateFinished];
    [col addController:ctl1];
    [col addController:ctl2];
    [col addController:ctl3];
    
    /* watch one more time */
    [col watchState:LCSCommandStateFinished];
    
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl1 forKey:LCSCommandControllerCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl2 forKey:LCSCommandControllerCollectionOriginalSenderKey]]];
    
    /* Don't expect anything */
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSCommandControllerCollectionTestNotificationConsumer)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [ctl1 start];
    [ctl2 start];
    [ctl3 start];
    [ctl1 waitUntilDone];
    [ctl2 waitUntilDone];
    [ctl3 waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mockany];
    [[NSNotificationCenter defaultCenter] removeObserver:mockall];
    
    [col removeController:ctl1];
    [col removeController:ctl2];
    [col removeController:ctl3];    
    [col unwatchState:LCSCommandStateFinished];
    
    /* unwatch one more (test) */
    [col unwatchState:LCSCommandStateFinished];
    

    [mockany verify];
    [mockall verify];
}

@end
