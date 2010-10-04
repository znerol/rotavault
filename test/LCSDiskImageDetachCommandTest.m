//
//  LCSDiskImageDetachTest.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSDiskImageDetachCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"
#import "LCSTestdir.h"


@interface LCSDiskImageDetachCommandTest : GHTestCase
@end


@implementation LCSDiskImageDetachCommandTest
-(void)testDiskImageDetachCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *dmgpath = [[testdir path] stringByAppendingPathComponent:@"test.dmg"];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSCommandController *ctl = nil;
    
    /** create test image file and figure out device path **/
    NSTask *dmgcreate = [[NSTask alloc] init];
    NSPipe *dmgpipe = [NSPipe pipe];
    [dmgcreate setLaunchPath:@"/usr/bin/hdiutil"];
    [dmgcreate setArguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000", @"-layout", @"NONE", @"-fs",
                             @"JHFS+", @"-plist", @"-attach",dmgpath, nil]];
    [dmgcreate setStandardOutput:dmgpipe];
    [dmgcreate launch];
    [dmgcreate waitUntilExit];
    
    NSData *data = [[dmgpipe fileHandleForReading] readDataToEndOfFile];
    NSDictionary *dmgoutput = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:0 format:nil errorDescription:nil];
    GHAssertTrue([dmgoutput isKindOfClass:[NSDictionary class]], @"Expect a dictionary from hdiutil helper tool");
    
    NSString *devpath = [[dmgoutput valueForKeyPath:@"system-entities.dev-entry"] objectAtIndex:0];
    GHAssertTrue([devpath isKindOfClass:[NSString class]], @"Expecting string value for device path");
    /** end creation of image file **/
    
    LCSDiskImageDetachCommand *cmd = [LCSDiskImageDetachCommand commandWithDevicePath:devpath];
    ctl = [mgr run:cmd];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFinished, @"Expecting LCSCommandStateFinished");
    
    [mgr release];
    
    [dmgcreate release];
    [testdir remove];
    [testdir release];
}

-(void)testDiskImageDetachNonExistingDeviceCommand
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    NSString *devpath = [[testdir path] stringByAppendingPathComponent:@"diskXsY"];
    
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSCommandController *ctl = nil;
    LCSDiskImageDetachCommand *cmd = [LCSDiskImageDetachCommand commandWithDevicePath:devpath];
    
    ctl = [mgr run:cmd];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertEquals(ctl.exitState, LCSCommandStateFailed, @"Expecting LCSCommandStateFailed");
    
    [mgr release];
    
    [testdir remove];
    [testdir release];
}
@end