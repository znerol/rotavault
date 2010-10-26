//
//  LCSCommandCollectionTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "LCSCommandCollection.h"
#import "LCSTestCommand.h"
#import "LCSTestNotificationConsumer.h"

@interface LCSCommandCollectionTest : GHTestCase
@end

@implementation LCSCommandCollectionTest

-(void)tearDown
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)testOneCommandWatchOneState
{
    LCSCommand *ctl = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    
    LCSCommandCollection *col = [LCSCommandCollection collection];
    [col addCommand:ctl];
    [col watchState:LCSCommandStateFinished];
    
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[mockall expect] consumeNotification:[OCMArg any]];
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[OCMArg any]];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:col];
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                               object:col];
    [ctl start];
    [ctl waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mockall];
    [[NSNotificationCenter defaultCenter] removeObserver:mockany];
    
    [mockall verify];
    [mockany verify];
}

-(void)testManyCommandsWatchOneState
{
    LCSCommand *ctl1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl3 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    
    LCSCommandCollection *col = [LCSCommandCollection collection];
    [col addCommand:ctl1];
    [col addCommand:ctl2];
    [col addCommand:ctl3];
    [col watchState:LCSCommandStateFinished];
    
    
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl1 forKey:LCSCommandCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl2 forKey:LCSCommandCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl3 forKey:LCSCommandCollectionOriginalSenderKey]]];
        
    /* FIXME: replace [OCMArg any] with properly initialized NSNotification. */
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[mockall expect] consumeNotification:[OCMArg any]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
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
    [col removeCommand:ctl1];
    [col removeCommand:ctl2];
    [col removeCommand:ctl3];
    
    [mockany verify];
    [mockall verify];
}

-(void)testManyCommandsOneFailingWatchOneState
{
    LCSCommand *ctl1 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl2 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFinished];
    LCSCommand *ctl3 = [LCSTestCommand commandWithDelay:0 finalState:LCSCommandStateFailed];
    
    LCSCommandCollection *col = [LCSCommandCollection collection];
    [col watchState:LCSCommandStateFinished];
    [col addCommand:ctl1];
    [col addCommand:ctl2];
    [col addCommand:ctl3];
    
    /* watch one more time */
    [col watchState:LCSCommandStateFinished];
    
    id mockany = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl1 forKey:LCSCommandCollectionOriginalSenderKey]]];
    [[mockany expect] consumeNotification:[NSNotification notificationWithName:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                                                        object:col
                                                                      userInfo:[NSDictionary dictionaryWithObject:ctl2 forKey:LCSCommandCollectionOriginalSenderKey]]];
    
    /* Don't expect anything */
    id mockall = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:mockany
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAnyCommandEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [[NSNotificationCenter defaultCenter] addObserver:mockall
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:col];
    
    [ctl1 start];
    [ctl2 start];
    [ctl3 start];
    [ctl1 waitUntilDone];
    [ctl2 waitUntilDone];
    [ctl3 waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:mockany];
    [[NSNotificationCenter defaultCenter] removeObserver:mockall];
    
    [col removeCommand:ctl1];
    [col removeCommand:ctl2];
    [col removeCommand:ctl3];    
    [col unwatchState:LCSCommandStateFinished];
    
    /* unwatch one more (test) */
    [col unwatchState:LCSCommandStateFinished];
    

    [mockany verify];
    [mockall verify];
}

@end
