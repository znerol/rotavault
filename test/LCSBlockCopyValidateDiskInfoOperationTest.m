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
    sourceCreateOp.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/bin/hdiutil"];
    sourceCreateOp.arguments = [LCSSimpleOperationInputParameter parameterWithValue:sourceCreateArgs];
    sourceCreateOp.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    [sourceCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *sourceDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(sourceDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    [result release];
    result = nil;

    /* source get info */
    LCSInformationForDiskOperation *sourceInfoOp = [[LCSInformationForDiskOperation alloc] init];
    sourceInfoOp.delegate = self;
    sourceInfoOp.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    sourceInfoOp.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
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
    targetCreateOp.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/bin/hdiutil"];
    targetCreateOp.arguments = [LCSSimpleOperationInputParameter parameterWithValue:targetCreateArgs];
    targetCreateOp.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    [targetCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *targetDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(targetDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    [result release];
    result = nil;
    
    /* target get info */
    LCSInformationForDiskOperation *targetInfoOp = [[LCSInformationForDiskOperation alloc] init];
    targetInfoOp.delegate = self;
    targetInfoOp.device = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    targetInfoOp.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
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
    smallTargetCreateOp.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/bin/hdiutil"];
    smallTargetCreateOp.arguments = [LCSSimpleOperationInputParameter parameterWithValue:smallTargetCreateArgs];
    smallTargetCreateOp.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    [smallTargetCreateOp start];
    STAssertNil(error, @"No error expected at this time");
    NSString *smallTargetDevice = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(smallTargetDevice, @"source device must not be nil");
    
    [error release];
    error = nil;
    [result release];
    result = nil;
    
    /* unmount small target device */
    NSTask *unmountSmallTarget = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:
                                  [NSArray arrayWithObjects:@"unmount", smallTargetDevice, nil]];
    [unmountSmallTarget waitUntilExit];
    STAssertEquals([unmountSmallTarget terminationStatus], 0, @"Unmount of small target image failed");

    /* smallTarget get info */
    LCSInformationForDiskOperation *smallTargetInfoOp = [[LCSInformationForDiskOperation alloc] init];
    smallTargetInfoOp.delegate = self;
    smallTargetInfoOp.device = [LCSSimpleOperationInputParameter parameterWithValue:smallTargetDevice];
    smallTargetInfoOp.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"smallTargetInfo"];
    [smallTargetInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(smallTargetInfo, @"Failed to fetch information for smallTarget image");

    [error release];
    error = nil;

    
    
    /* bootdisk get info */
    LCSInformationForDiskOperation *bootdiskInfoOp = [[LCSInformationForDiskOperation alloc] init];
    bootdiskInfoOp.delegate = self;
    bootdiskInfoOp.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/"];
    bootdiskInfoOp.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    [bootdiskInfoOp start];
    STAssertNil(error, @"No error expected at this time");
    STAssertNotNil(bootdiskInfo, @"Failed to fetch information for startup disk");

    [error release];
    error = nil;
    
    
    
    /* test source == startup disk */
    LCSBlockCopyValidateDiskInfoOperation *validateSourceIsBoot = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSourceIsBoot.delegate = self;
    validateSourceIsBoot.sourceInfo = [LCSSimpleOperationInputParameter parameterWithValue:bootdiskInfo];
    validateSourceIsBoot.targetInfo = [LCSSimpleOperationInputParameter parameterWithValue:targetInfo];
    validateSourceIsBoot.bootdiskInfo = [LCSSimpleOperationInputParameter parameterWithValue:bootdiskInfo];
    [validateSourceIsBoot start];
    STAssertNotNil(error, @"Validation must fail if source is the startup disk");
    
    [error release];
    error = nil;
    

    
    /* test source == target */
    LCSBlockCopyValidateDiskInfoOperation *validateSameSourceAndTarget =
        [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSameSourceAndTarget.delegate = self;
    validateSameSourceAndTarget.sourceInfo = [LCSSimpleOperationInputParameter parameterWithValue:sourceInfo];
    validateSameSourceAndTarget.targetInfo = [LCSSimpleOperationInputParameter parameterWithValue:sourceInfo];
    validateSameSourceAndTarget.bootdiskInfo = [LCSSimpleOperationInputParameter parameterWithValue:bootdiskInfo];
    [validateSameSourceAndTarget start];
    STAssertNotNil(error, @"Validation must fail if source and target are equal");
    
    [error release];
    error = nil;


    
    /* test mounted target */
    LCSBlockCopyValidateDiskInfoOperation *validateMountedTarget = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateMountedTarget.delegate = self;
    validateMountedTarget.sourceInfo = [LCSSimpleOperationInputParameter parameterWithValue:sourceInfo];
    validateMountedTarget.targetInfo = [LCSSimpleOperationInputParameter parameterWithValue:targetInfo];
    validateMountedTarget.bootdiskInfo = [LCSSimpleOperationInputParameter parameterWithValue:bootdiskInfo];
    [validateMountedTarget start];
    STAssertNotNil(error, @"Validation must fail if target is mounted");
    
    [error release];
    error = nil;
    
    
    /* test too small target target */
    LCSBlockCopyValidateDiskInfoOperation *validateSmallTarget = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    validateSmallTarget.delegate = self;
    validateSmallTarget.sourceInfo = [LCSSimpleOperationInputParameter parameterWithValue:sourceInfo];
    validateSmallTarget.targetInfo = [LCSSimpleOperationInputParameter parameterWithValue:smallTargetInfo];
    validateSmallTarget.bootdiskInfo = [LCSSimpleOperationInputParameter parameterWithValue:bootdiskInfo];
    [validateSmallTarget start];
    STAssertNotNil(error, @"Validation must fail if target is too small");
    
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
    
    [sourceDevice release];
    [targetDevice release];
    [smallTargetDevice release];
    
    [sourceCreateOp release];
    [sourceInfoOp release];
    [targetCreateOp release];
    [targetInfoOp release];
    [smallTargetCreateOp release];
    [smallTargetInfoOp release];
    [bootdiskInfoOp release];
    [validateSourceIsBoot release];
    [validateSameSourceAndTarget release];
    [validateMountedTarget release];
    [validateSmallTarget release];
}
@end
