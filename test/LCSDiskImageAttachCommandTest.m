//
//  LCSDiskImageAttachTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSDiskImageAttachCommand.h"
#import "LCSCommandController.h"
#import "LCSTestdir.h"


@interface LCSDiskImageAttachCommandTest : GHTestCase
@end


@implementation LCSDiskImageAttachCommandTest
-(void)testDiskImageAttachCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *dmgpath = [[testdir path] stringByAppendingPathComponent:@"test.dmg"];
    
    NSTask *dmgcreate = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil"
                                                 arguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000",
                                                            @"-layout", @"NONE", dmgpath, nil]];
    [dmgcreate waitUntilExit];
    
    LCSDiskImageAttachCommand *cmd = [LCSDiskImageAttachCommand commandWithImagePath:dmgpath];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    NSString *devpath = [[ctl.result valueForKeyPath:@"system-entities.dev-entry"] objectAtIndex:0];
    GHAssertTrue([devpath isKindOfClass:[NSString class]], @"Expecting string value for device path");
    
    NSTask *ejectTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                                arguments:[NSArray arrayWithObjects:@"eject", devpath, nil]];
    [ejectTask waitUntilExit];
    
    [testdir remove];
    [testdir release];
    
}

-(void)testDiskImageAttachNonExistingPathCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *dmgpath = [[testdir path] stringByAppendingPathComponent:@"test.dmg"];
    
    LCSDiskImageAttachCommand *cmd = [LCSDiskImageAttachCommand commandWithImagePath:dmgpath];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
    
    [testdir remove];
    [testdir release];
}
@end
