//
//  LCSAsrRestoreTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSAsrRestoreCommand.h"
#import "LCSCommandController.h"
#import "LCSTestdir.h"
#import "LCSPlistExternalCommand.h"


@interface LCSAsrRestoreCommandTest : GHTestCase
@end


@implementation LCSAsrRestoreCommandTest
-(void)testAsrRestoreCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *dmgsourcepath = [[testdir path] stringByAppendingPathComponent:@"source.dmg"];
    NSString *dmgtargetpath = [[testdir path] stringByAppendingPathComponent:@"target.dmg"];
    
    /** create source and target images **/
    LCSPlistExternalCommand *createsource = [[[LCSPlistExternalCommand alloc] init] autorelease];
    [createsource.task setLaunchPath:@"/usr/bin/hdiutil"];
    [createsource.task setArguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000", @"-layout", @"NONE",
                                     @"-fs", @"JHFS+", @"-plist", @"-attach", dmgsourcepath, nil]];
    LCSCommandController *sourcectl = [LCSCommandController controllerWithCommand:createsource];
    [sourcectl start];
    
    LCSPlistExternalCommand *createtarget = [[[LCSPlistExternalCommand alloc] init] autorelease];
    [createtarget.task setLaunchPath:@"/usr/bin/hdiutil"];
    [createtarget.task setArguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000", @"-layout", @"NONE",
                                     @"-fs", @"JHFS+", @"-plist", @"-attach", dmgtargetpath, nil]];
    LCSCommandController *targetctl = [LCSCommandController controllerWithCommand:createtarget];
    [targetctl start];
    
    [sourcectl waitUntilDone];
    [targetctl waitUntilDone];
    
    GHAssertEquals(sourcectl.exitState, LCSCommandStateFinished, @"Expected LCSCommandStateFinished as a result of creating the source image");
    GHAssertTrue([sourcectl.result isKindOfClass:[NSDictionary class]], @"Expecting an NSDictionary as a result of creating the source image");
    NSString *sourcedev = [[sourcectl.result valueForKeyPath:@"system-entities.dev-entry"] objectAtIndex:0];
    GHAssertTrue([sourcedev isKindOfClass:[NSString class]], @"Expecting string value for device path");
    GHAssertEquals(targetctl.exitState, LCSCommandStateFinished, @"Expected LCSCommandStateFinished as a result of creating the target image");
    GHAssertTrue([targetctl.result isKindOfClass:[NSDictionary class]], @"Expecting an NSDictionary as a result of creating the target image");
    NSString *targetdev = [[targetctl.result valueForKeyPath:@"system-entities.dev-entry"] objectAtIndex:0];
    GHAssertTrue([targetdev isKindOfClass:[NSString class]], @"Expecting string value for device path");
    
    /** test the asr command **/
    LCSAsrRestoreCommand *cmd = [LCSAsrRestoreCommand commandWithSource:sourcedev target:targetdev];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [ctl start];
    [ctl waitUntilDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    NSTask *ejectSourceTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                                 arguments:[NSArray arrayWithObjects:@"eject", sourcedev, nil]];
    NSTask *ejectTargetTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                                 arguments:[NSArray arrayWithObjects:@"eject", targetdev, nil]];
    [ejectSourceTask waitUntilExit];
    [ejectTargetTask waitUntilExit];
    
    [testdir remove];
    [testdir release];
}
@end
