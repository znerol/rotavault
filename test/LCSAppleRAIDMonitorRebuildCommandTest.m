//
//  LCSAppleRAIDMonitorRebuildCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 14.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "LCSAppleRAIDMonitorRebuildCommand.h"
#import "OCMockObject+NSTask.h"
#import "LCSExternalCommand.h"
#import "LCSExternalCommand+MockableTask.h"
#import "LCSCommandController.h"

@protocol LCSTestNotificationConsumer
-(void)consumeNotification:(NSNotification*)ntf;
@end

@interface LCSAppleRAIDMonitorRebuildCommandTest : GHTestCase
{
    NSEnumerator* taskFixtureEnumerator;
    NSMutableArray* taskMocks;
}
@end

@implementation LCSAppleRAIDMonitorRebuildCommandTest
- (void)taskInitNotification:(NSNotification*)ntf
{
    LCSExternalCommand* cmd = [ntf object];
    NSArray* fixture = [taskFixtureEnumerator nextObject];
    
    if(fixture == nil) {
        GHFail(@"Ran out of fixtures for test");
    }
    
    id taskMock = [OCMockObject mockTask:cmd.task
                   withTerminationStatus:[[fixture objectAtIndex:0] intValue]
                              stdoutData:[fixture objectAtIndex:1]
                              stderrData:[fixture objectAtIndex:2]];
    cmd.task = taskMock;
    [taskMocks addObject:taskMock];
}

-(void) testMonitorRebuild
{
    /* Build up the array of fixture-arrays to use. */
    NSArray *taskFixtures = [[NSArray alloc] initWithObjects:
                             [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:0],
                              [NSData dataWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-1"
                                                               ofType:@"txt"]],
                              [NSData data],
                              nil],
                             [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:0],
                              [NSData dataWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-2"
                                                               ofType:@"txt"]],
                              [NSData data],
                              nil],
                             [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:0],
                              [NSData dataWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-3"
                                                               ofType:@"txt"]],
                              [NSData data],
                              nil],
                             [NSArray arrayWithObjects:
                              [NSNumber numberWithInt:0],
                              [NSData dataWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-ok" ofType:@"txt"]],
                              [NSData data],
                              nil],
                             nil];
    taskFixtureEnumerator = [[taskFixtures objectEnumerator] retain];
    taskMocks = [[NSMutableArray alloc] init];
                                 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskInitNotification:)
                                                 name:LCSTestExternalCommandTaskInitNotification
                                               object:nil];
    
    LCSAppleRAIDMonitorRebuildCommand *cmd = [LCSAppleRAIDMonitorRebuildCommand
                                              commandWithRaidUUID:@"76898140-1ED1-41AB-931F-2E30D015829F"
                                              devicePath:@"/dev/disk3s1"];
    LCSCommandController *ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    
    id ctlMock = [OCMockObject mockForProtocol:@protocol(LCSTestNotificationConsumer)];
    [[ctlMock expect] consumeNotification:[OCMArg any]];
    [[NSNotificationCenter defaultCenter] addObserver:ctlMock
                                             selector:@selector(consumeNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                               object:ctl];
    
    [ctl start];
    [ctl waitUntilDone];
    
    for (id taskMock in taskMocks) {
        [taskMock verify];
    }
    [ctlMock verify];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSTestExternalCommandTaskInitNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:ctlMock
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFinished]
                                                  object:ctl];
    
    [ctl release];
    [taskMocks release];
    [taskFixtureEnumerator release];
}

@end
