//
//  LCSBlockCopyOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperationTest.h"
#import "LCSBlockCopyOperation.h"
#import "LCSPlistTaskOperation.h"


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
    NSString *spath = [[testdir path] stringByAppendingPathComponent:@"source.dmg"];
    NSArray *screateargs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", spath, @"-plist", @"-layout",
                           @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *screateop = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil"
                                                                              arguments:screateargs];
    [screateop start];

    STAssertNotNil(screateop.result, @"return value of hdiutil must not be nil");
    NSString *srcdev = [[[screateop.result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
    STAssertNotNil(srcdev, @"source device must not be nil");
    NSString *srcmount = [[[screateop.result objectForKey:@"system-entities"] objectAtIndex:0]
                          objectForKey:@"mount-point"];
    STAssertNotNil(srcmount, @"source mount must not be nil");
    
    /* populate the source */
    [[NSFileManager defaultManager] createFileAtPath:[srcmount stringByAppendingPathComponent:@"test.txt"]
                                            contents:[NSData dataWithBytes:"Hello World\n" length:12]
                                          attributes:[NSDictionary dictionary]];
    
    /* setup target without filesystem */
    NSString *tpath = [[testdir path] stringByAppendingPathComponent:@"target.dmg"];
    NSArray *tcreateargs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", tpath, @"-plist", @"-layout",
                            @"NONE", nil];
    LCSPlistTaskOperation *tcreateop = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil"
                                                                               arguments:tcreateargs];
    [tcreateop start];
    STAssertNotNil(tcreateop.result, @"return value of hdiutil must not be nil");
    
    /* attach target */
    NSArray *atargs = [NSArray arrayWithObjects:@"attach", tpath, @"-plist", @"-nomount", nil];
    LCSPlistTaskOperation *atop = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil"
                                                                          arguments:atargs];
    [atop start];
    STAssertNotNil(atop.result, @"return value of hdiutil must not be nil");
    NSString *dstdev = [[[atop.result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
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
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                              arguments:[NSArray arrayWithObjects:@"mount", dstdev, nil]] waitUntilExit];

    NSArray *infargs = [NSArray arrayWithObjects:@"info", @"-plist", dstdev, nil];
    LCSPlistTaskOperation *infop = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/sbin/diskutil"
                                                                           arguments:infargs];
    [infop start];
    STAssertNotNil(infop.result, @"return value of diskutil must not be nil");
    NSString *dstmount = [infop.result objectForKey:@"MountPoint"];
    STAssertNotNil(dstmount, @"target mount must not be nil");
    
    /* now we compare the mounts using NSFileManager */
    STAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:srcmount andPath:dstmount],
                 @"contents of the two images must be the same after restoreFromSource:toTarget");
    
    /* eject devices */
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil"
                              arguments:[NSArray arrayWithObjects:@"detach", srcdev, nil]] waitUntilExit];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil"
                              arguments:[NSArray arrayWithObjects:@"detach", dstdev, nil]] waitUntilExit];
    
    /* release stuff */
    [screateop release];
    [tcreateop release];
    [atop release];
    [op release];
    [infop release];
}

@end
