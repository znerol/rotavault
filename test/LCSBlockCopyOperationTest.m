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
-(void)delegateCleanup
{
    if (result) {
        [result release];
        result = nil;
    }
    if (error) {
        [error release];
        error = nil;
    }
    progress = 0.0;
}

- (void) setUp
{
    testdir = [[LCSTestdir alloc] init];
    result = nil;
    error = nil;
}

- (void) tearDown
{
    [self delegateCleanup];
    [testdir remove];
    [testdir release];
    testdir = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

-(void)operation:(LCSTaskOperation*)operation handleResult:(id)inResult
{
    result = [inResult retain];
}

-(void)operation:(LCSOperation*)operation updateProgress:(NSNumber*)inProgress
{
    float newProgress = [inProgress floatValue];
    
    /*
     * filter out -1
     */
    if (newProgress >= 0) {
        progress = newProgress;
    }
}

- (void)testBlockCopy
{
    /* setup source with filesystem*/
    NSString *spath = [[testdir path] stringByAppendingPathComponent:@"source.dmg"];
    NSArray *screateargs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", spath, @"-plist", @"-layout",
                           @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *screateop = [[LCSPlistTaskOperation alloc] init];
    screateop.launchPath = @"/usr/bin/hdiutil";
    screateop.arguments = screateargs;
    [screateop bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];

    [screateop setDelegate:self];
    [screateop start];

    STAssertNotNil(result, @"return value of hdiutil must not be nil");
    NSString *srcdev = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(srcdev, @"source device must not be nil");
    NSString *srcmount = [[[[result objectForKey:@"system-entities"] objectAtIndex:0]
                           objectForKey:@"mount-point"] retain];
    STAssertNotNil(srcmount, @"source mount must not be nil");
    [self delegateCleanup];
    
    /* populate the source */
    [[NSFileManager defaultManager] createFileAtPath:[srcmount stringByAppendingPathComponent:@"test.txt"]
                                            contents:[NSData dataWithBytes:"Hello World\n" length:12]
                                          attributes:[NSDictionary dictionary]];
    
    /* setup target without filesystem */
    NSString *tpath = [[testdir path] stringByAppendingPathComponent:@"target.dmg"];
    NSArray *tcreateargs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", tpath, @"-plist", @"-layout",
                            @"NONE", nil];
    LCSPlistTaskOperation *tcreateop = [[LCSPlistTaskOperation alloc] init];
    tcreateop.launchPath = @"/usr/bin/hdiutil";
    tcreateop.arguments = tcreateargs;
    [tcreateop bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];

    [tcreateop setDelegate:self];
    [tcreateop start];

    STAssertNotNil(result, @"return value of hdiutil must not be nil");
    [self delegateCleanup];
    
    /* attach target */
    NSArray *atargs = [NSArray arrayWithObjects:@"attach", tpath, @"-plist", @"-nomount", nil];
    LCSPlistTaskOperation *atop = [[LCSPlistTaskOperation alloc] init];
    atop.launchPath = @"/usr/bin/hdiutil";
    atop.arguments = atargs;
    [atop bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];

    [atop setDelegate:self];
    [atop start];

    STAssertNotNil(result, @"return value of hdiutil must not be nil");
    NSString *dstdev = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(dstdev, @"target device must not be nil");
    [self delegateCleanup];
    
    /* perform block copy operation */
    LCSBlockCopyOperation* op = [[LCSBlockCopyOperation alloc] init];
    op.source = srcdev;
    op.target = dstdev;

    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"error must be nil if operation was successfull");
    STAssertEquals(progress, (float)100, @"progress must be 100.0 after completion of the operation");
    [self delegateCleanup];

    /* mount target */
    
    /* 
     * "hdiutil mount /dev/diskX" does not work for a freshly restored volume (osx bug?). Instead we have to stick with
     * "diskutil mount /dev/diskX", followed by "diskutil info -plist /dev/diskX" in order to retreive the mount point.
     */
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                              arguments:[NSArray arrayWithObjects:@"mount", dstdev, nil]] waitUntilExit];

    NSArray *infargs = [NSArray arrayWithObjects:@"info", @"-plist", dstdev, nil];
    LCSPlistTaskOperation *infop = [[LCSPlistTaskOperation alloc] init];
    [infop setLaunchPath:@"/usr/sbin/diskutil"];
    [infop bindParameter:@"result" direction:LCSParameterOut toObject:self withKeyPath:@"result"];
    [infop setArguments:infargs];
    [infop setDelegate:self];
    [infop start];

    STAssertNotNil(result, @"return value of diskutil must not be nil");
    NSString *dstmount = [[result objectForKey:@"MountPoint"] retain];
    STAssertNotNil(dstmount, @"target mount must not be nil");
    [self delegateCleanup];
    
    /* now we compare the mounts using NSFileManager */
    STAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:srcmount andPath:dstmount],
                 @"contents of the two images must be the same after restoreFromSource:toTarget");
    
    /* eject devices */
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil"
                              arguments:[NSArray arrayWithObjects:@"detach", srcdev, nil]] waitUntilExit];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/bin/hdiutil"
                              arguments:[NSArray arrayWithObjects:@"detach", dstdev, nil]] waitUntilExit];
    
    /* release stuff */
    [srcdev release];
    [srcmount release];
    [dstdev release];
    [dstmount release];
    [screateop release];
    [tcreateop release];
    [atop release];
    [op release];
    [infop release];
}

@end
