//
//  LCSBlockCopyValidateDiskInfoOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 04.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyValidateDiskInfoOperationTest.h"
#import "LCSBlockCopyValidateDiskInfoOperation.h"
#import "LCSTestdir.h"
#import "LCSPlistTaskOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSDiskUtilOperation.h"


@implementation LCSBlockCopyValidateDiskInfoOperationTest
-(void)setUp
{
    error = nil;
    sourceInfo = nil;
    targetInfo = nil;
    smallTargetInfo = nil;
    bootdiskInfo = nil;
}

-(void)tearDown
{
    [error release];
    error = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)newError
{
    [newError retain];
    [error release];
    error = newError;
}

-(void)testBlockCopyValidateDiskInfoOperation
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];
    id result = nil;
    
    /* setup source dmg */
    NSString *sourcePath = [[testdir path] stringByAppendingPathComponent:@"source.dmg"];
    NSArray *sourceCreateArgs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", sourcePath, @"-plist",
                                 @"-layout", @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *sourceCreateOp = [[LCSPlistTaskOperation alloc] init];
    sourceCreateOp.delegate = self;
    sourceCreateOp.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/bin/hdiutil"];
    sourceCreateOp.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceCreateArgs];
    sourceCreateOp.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    [sourceCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *sourceDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(sourceDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    result = nil;

    /* source get info */
    LCSInformationForDiskOperation *sourceInfoOp = [[LCSInformationForDiskOperation alloc] init];
    sourceInfoOp.delegate = self;
    sourceInfoOp.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    sourceInfoOp.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"sourceInfo"];
    [sourceInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(sourceInfo, @"Failed to fetch information for source image");

    [error release];
    error = nil;
    
    
    
    /* setup target dmg */
    NSString *targetPath = [[testdir path] stringByAppendingPathComponent:@"target.dmg"];
    NSArray *targetCreateArgs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", targetPath, @"-plist",
                                 @"-layout", @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *targetCreateOp = [[LCSPlistTaskOperation alloc] init];
    targetCreateOp.delegate = self;
    targetCreateOp.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/bin/hdiutil"];
    targetCreateOp.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetCreateArgs];
    targetCreateOp.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    [targetCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *targetDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(targetDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    result = nil;
    
    /* target get info */
    LCSInformationForDiskOperation *targetInfoOp = [[LCSInformationForDiskOperation alloc] init];
    targetInfoOp.delegate = self;
    targetInfoOp.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDevice];
    targetInfoOp.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"targetInfo"];
    [targetInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(targetInfo, @"Failed to fetch information for target image");
    
    [error release];
    error = nil;
    
    
    
    /* setup smallTarget dmg */
    NSString *smallTargetPath = [[testdir path] stringByAppendingPathComponent:@"smallTarget.dmg"];
    NSArray *smallTargetCreateArgs = [NSArray arrayWithObjects:@"create", @"-sectors", @"1999", smallTargetPath, @"-plist",
                                 @"-layout", @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *smallTargetCreateOp = [[LCSPlistTaskOperation alloc] init];
    smallTargetCreateOp.delegate = self;
    smallTargetCreateOp.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/bin/hdiutil"];
    smallTargetCreateOp.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:smallTargetCreateArgs];
    smallTargetCreateOp.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    [smallTargetCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *smallTargetDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(smallTargetDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    result = nil;
    
    /* unmount small target device */
    NSTask *unmountSmallTarget = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:
                                  [NSArray arrayWithObjects:@"unmount", smallTargetDevice, nil]];
    [unmountSmallTarget waitUntilExit];
    STAssertEquals([unmountSmallTarget terminationStatus], 0, @"Unmount of small target image failed");

    /* smallTarget get info */
    LCSInformationForDiskOperation *smallTargetInfoOp = [[LCSInformationForDiskOperation alloc] init];
    smallTargetInfoOp.delegate = self;
    smallTargetInfoOp.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:smallTargetDevice];
    smallTargetInfoOp.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"smallTargetInfo"];
    [smallTargetInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(smallTargetInfo, @"Failed to fetch information for smallTarget image");

    [error release];
    error = nil;

    
    
    /* bootdisk get info */
    LCSInformationForDiskOperation *bootdiskInfoOp = [[LCSInformationForDiskOperation alloc] init];
    bootdiskInfoOp.delegate = self;
    bootdiskInfoOp.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/"];
    bootdiskInfoOp.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"bootdiskInfo"];
    [bootdiskInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(bootdiskInfo, @"Failed to fetch information for startup disk");

    [error release];
    error = nil;
    
    
    
    /* test source == startup disk */
    LCSBlockCopyValidateDiskInfoOperation *validateSourceIsBoot = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSourceIsBoot.delegate = self;
    validateSourceIsBoot.sourceInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:bootdiskInfo];
    validateSourceIsBoot.targetInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetInfo];
    validateSourceIsBoot.bootdiskInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:bootdiskInfo];
    [validateSourceIsBoot start];
    STAssertNotNil(error, @"Validation must fail if source is the startup disk");
    [validateSourceIsBoot release];
    
    [error release];
    error = nil;
    

    
    /* test source == target */
    LCSBlockCopyValidateDiskInfoOperation *validateSameSourceAndTarget =
        [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSameSourceAndTarget.delegate = self;
    validateSameSourceAndTarget.sourceInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceInfo];
    validateSameSourceAndTarget.targetInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceInfo];
    validateSameSourceAndTarget.bootdiskInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:bootdiskInfo];
    [validateSameSourceAndTarget start];
    STAssertNotNil(error, @"Validation must fail if source and target are equal");
    [validateSameSourceAndTarget release];
    
    [error release];
    error = nil;


    
    /* test mounted target */
    LCSBlockCopyValidateDiskInfoOperation *validateMountedTarget = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateMountedTarget.delegate = self;
    validateMountedTarget.sourceInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceInfo];
    validateMountedTarget.targetInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetInfo];
    validateMountedTarget.bootdiskInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:bootdiskInfo];
    [validateMountedTarget start];
    STAssertNotNil(error, @"Validation must fail if target is mounted");
    [validateMountedTarget release];
    
    [error release];
    error = nil;
    
    
    /* test too small target target */
    LCSBlockCopyValidateDiskInfoOperation *validateSmallTarget = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSmallTarget.delegate = self;
    validateSmallTarget.sourceInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceInfo];
    validateSmallTarget.targetInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:smallTargetInfo];
    validateSmallTarget.bootdiskInfo = [[LCSSimpleOperationInputParameter alloc] initWithValue:bootdiskInfo];
    [validateSmallTarget start];
    STAssertNotNil(error, @"Validation must fail if target is too small");
    [validateSmallTarget release];
    
    [error release];
    error = nil;
    

    
    /* eject disk images and cleanup temporary directory */
    for(NSString *device in [NSArray arrayWithObjects:sourceDevice, targetDevice, smallTargetDevice, nil]) {
        NSTask *ejectTask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                                     arguments:[NSArray arrayWithObjects:@"eject", device, nil]];
        [ejectTask waitUntilExit];
    }
    [testdir remove];
    [testdir release];
}
@end
