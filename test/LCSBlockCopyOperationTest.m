//
//  LCSBlockCopyOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperationTest.h"
#import "LCSBlockCopyOperation.h"
#import "LCSPlistTaskOutputHandler.h"


@implementation LCSBlockCopyOperationTest
- (void) setUp
{
    testdir = [[LCSTestdir alloc] init];
}

- (void) tearDown
{
    [testdir remove];
    [testdir release];
    testdir = nil;
}

- (void)testBlockCopy
{
    /* setup source with filesystem*/
    NSString* spath = [[testdir path] stringByAppendingPathComponent:@"source.dmg"];
    NSDictionary *sresult = [LCSPlistTaskOutputHandler resultsFromTerminatedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000", spath, @"-plist", @"-layout", @"NONE", @"-fs", @"HFS+", @"-attach", nil]];
    STAssertNotNil(sresult, @"return value of hdiutil must not be nil");
    NSString *srcdev = [[[sresult objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
    STAssertNotNil(srcdev, @"source device must not be nil");
    NSString *srcmount = [[[sresult objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"mount-point"];
    STAssertNotNil(srcmount, @"source mount must not be nil");
    
    /* populate the source */
    NSFileManager *fm = [NSFileManager defaultManager];    
    [fm createFileAtPath:[srcmount stringByAppendingPathComponent:@"test.txt"] contents:[NSData dataWithBytes:"Hello World\n" length:12] attributes:[NSDictionary dictionary]];
    
    /* setup target without filesystem */
    NSString* tpath = [[testdir path] stringByAppendingPathComponent:@"target.dmg"];    
    NSDictionary* tresult = [LCSPlistTaskOutputHandler resultsFromTerminatedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[NSArray arrayWithObjects:@"create", @"-sectors", @"2000", tpath, @"-plist", @"-layout", @"NONE", nil]];
    STAssertNotNil(tresult, @"return value of hdiutil must not be nil");
    
    /* attach destination */
    NSDictionary *atresult = [LCSPlistTaskOutputHandler resultsFromTerminatedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[NSArray arrayWithObjects:@"attach", tpath, @"-plist", @"-nomount", nil]];
    STAssertNotNil(atresult, @"return value of hdiutil must not be nil");
    NSString *dstdev = [[[atresult objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
    STAssertNotNil(dstdev, @"target device must not be nil");
    
    /* perform test */
    LCSBlockCopyOperation* op = [[LCSBlockCopyOperation alloc] initWithSourceDevice:srcdev targetDevice:dstdev];
    [op start];
    STAssertNil(op.error, @"error must be nil if operation was successfull");
    STAssertEquals(op.progress, (float)100, @"progress must be 100.0 after completion of the operation");
    
    /* mount target */
    
    /* 
     * "hdiutil mount /dev/diskX" does not work for a freshly restored volume (osx bug?). Instead we have to stick with
     * "diskutil mount /dev/diskX", followed by "diskutil info -plist /dev/diskX" in order to retreive the mount point.
     */
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:[NSArray arrayWithObjects:@"mount", dstdev, nil]] waitUntilExit];
    NSDictionary *infresult = [LCSPlistTaskOutputHandler resultsFromTerminatedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:[NSArray arrayWithObjects:@"info", @"-plist", dstdev, nil]];
    STAssertNotNil(infresult, @"return value of diskutil must not be nil");
    NSString *dstmount = [infresult objectForKey:@"MountPoint"];
    STAssertNotNil(dstmount, @"target mount must not be nil");
    
    /* now we compare the mounts using NSFileManager */
    STAssertTrue([fm contentsEqualAtPath:srcmount andPath:dstmount], @"contents of the two images must be the same after restoreFromSource:toTarget");
    [fm release];
    
    /* eject devices */
    NSTask *sdetach = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[NSArray arrayWithObjects:@"detach", srcdev, nil]];
    [sdetach waitUntilExit];
    NSTask *tdetach = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil" arguments:[NSArray arrayWithObjects:@"detach", dstdev, nil]];
    [tdetach waitUntilExit];
}

@end
