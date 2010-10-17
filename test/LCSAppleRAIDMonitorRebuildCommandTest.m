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
    NSData* fixture = [taskFixtureEnumerator nextObject];
    
    if(fixture == nil) {
        GHFail(@"Ran out of fixtures for test");
    }
    
    id taskMock = [OCMockObject mockTask:cmd.task withTerminationStatus:0 stdoutData:fixture stderrData:[NSData data]];
    cmd.task = taskMock;
    [taskMocks addObject:taskMock];
}

- (void)setUp
{
    taskMocks = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskInitNotification:)
                                                 name:LCSTestExternalCommandTaskInitNotification
                                               object:nil];
}

- (void)tearDown
{
    [taskMocks release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LCSTestExternalCommandTaskInitNotification
                                                  object:nil];    
}

-(void) testMonitorRebuild
{
    /* Build up the array of fixture-arrays to use. */
    NSArray *taskFixtures = [[NSArray alloc]
                             initWithObjects:
                             [NSData dataWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-1"
                                                              ofType:@"txt"]],
                             [NSData dataWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-2"
                                                              ofType:@"txt"]],
                             [NSData dataWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-degraded-rebuilding-3"
                                                              ofType:@"txt"]],
                             [NSData dataWithContentsOfFile:
                              [[NSBundle mainBundle] pathForResource:@"diskutil-appleraid-list-ok" ofType:@"txt"]],
                             nil];
    
    taskFixtureEnumerator = [[taskFixtures objectEnumerator] retain];
                                 
    LCSAppleRAIDMonitorRebuildCommand *cmd = [LCSAppleRAIDMonitorRebuildCommand
                                              commandWithRaidUUID:@"76898140-1ED1-41AB-931F-2E30D015829F"
                                              devicePath:@"/dev/disk3s1"];
    cmd.updateInterval = 0;
    LCSCommandController *ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    
    [ctl start];
    [ctl waitUntilDone];
    
    for (id taskMock in taskMocks) {
        [taskMock verify];
    }
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expected LCSCommandStateFinished");
    
    [ctl release];
    [taskFixtures release];
    [taskFixtureEnumerator release];
}

@end
