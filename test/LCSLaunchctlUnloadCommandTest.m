//
//  LCSLaunchctlUnloadTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSLaunchctlUnloadCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"
#import "LCSTestdir.h"


@interface LCSLaunchctlUnloadCommandTest : GHTestCase
@end


@implementation LCSLaunchctlUnloadCommandTest
-(void)testLaunchctlUnloadCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    
//    srandom(time(NULL));
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSTask *submitTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl"
                                                  arguments:[NSArray arrayWithObjects:@"submit", @"-l", label,
                                                             @"/bin/sleep", @"10", nil]];
    [submitTask waitUntilExit];
    
    NSString* plistPath = [[testdir path] stringByAppendingPathComponent:@"testjob.plist"];
    NSDictionary *job = [NSDictionary dictionaryWithObjectsAndKeys:
                         label, @"Label",
                         [NSArray arrayWithObjects:@"/bin/sleep", @"10", nil], @"ProgramArguments",
                         [NSNumber numberWithBool:YES], @"RunAtUnload",
                         nil];
    
    [job writeToFile:plistPath atomically:NO];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlUnloadCommand *cmd = [LCSLaunchctlUnloadCommand commandWithPath:plistPath];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    

    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    [mgr release];
    
    [testdir remove];
    [testdir release];
    
}

-(void)testLaunchctlUnloadNonExistingLabel
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString* plistPath = [[testdir path] stringByAppendingPathComponent:@"testjob.plist"];
    
//    srandom(time(NULL));
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSDictionary *job = [NSDictionary dictionaryWithObjectsAndKeys:
                         label, @"Label",
                         [NSArray arrayWithObjects:@"/bin/sleep", @"10", nil], @"ProgramArguments",
                         [NSNumber numberWithBool:YES], @"RunAtUnload",
                         nil];
    
    [job writeToFile:plistPath atomically:NO];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSLaunchctlUnloadCommand *cmd = [LCSLaunchctlUnloadCommand commandWithPath:plistPath];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
        
    [mgr release];
    
    [testdir remove];
    [testdir release];
}
@end
