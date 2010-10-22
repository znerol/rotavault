//
//  LCSLaunchctlLoadTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlLoadCommand.h"
#import "LCSCommand.h"
#import "LCSTestdir.h"


@interface LCSLaunchctlLoadCommandTest : GHTestCase
@end


@implementation LCSLaunchctlLoadCommandTest
-(void)testLaunchctlLoadCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString* plistPath = [[testdir path] stringByAppendingPathComponent:@"testjob.plist"];
    
//    srandom(time(NULL));
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSDictionary *job = [NSDictionary dictionaryWithObjectsAndKeys:
                         label, @"Label",
                         [NSArray arrayWithObjects:@"/bin/sleep", @"10", nil], @"ProgramArguments",
                         [NSNumber numberWithBool:YES], @"RunAtLoad",
                         nil];
    
    [job writeToFile:plistPath atomically:NO];
    
    LCSLaunchctlLoadCommand *cmd = [LCSLaunchctlLoadCommand commandWithPath:plistPath];
    
    [cmd start];
    [cmd waitUntilDone];
    
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    NSTask *removeTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"remove", label, nil]];
    [removeTask waitUntilExit];
    
    [testdir remove];
    [testdir release];
    
}

-(void)testLaunchctlLoadDuplicateLabelCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString* plistPath = [[testdir path] stringByAppendingPathComponent:@"testjob.plist"];
    
//    srandom(time(NULL));
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSDictionary *job = [NSDictionary dictionaryWithObjectsAndKeys:
                         label, @"Label",
                         [NSArray arrayWithObjects:@"/bin/sleep", @"10", nil], @"ProgramArguments",
                         [NSNumber numberWithBool:YES], @"RunAtLoad",
                         nil];
    
    [job writeToFile:plistPath atomically:NO];
    
    LCSLaunchctlLoadCommand *cmd = [LCSLaunchctlLoadCommand commandWithPath:plistPath];
    
    [cmd start];
    [cmd waitUntilDone];
    
    GHAssertEquals(cmd.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    LCSLaunchctlLoadCommand *cmd2 = [LCSLaunchctlLoadCommand commandWithPath:plistPath];
    
    [cmd2 start];
    [cmd2 waitUntilDone];

    GHAssertEquals(cmd2.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");

    NSTask *removeTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"remove", label, nil]];
    [removeTask waitUntilExit];
    
    [testdir remove];
    [testdir release];
}

@end
