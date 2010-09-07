//
//  LCSRotavaultScheduleInstallCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallCommand.h"
#import "LCSInitMacros.h"
#import "LCSGenerateRotavaultCopyLaunchdPlistOperation.h"
#import "LCSBlockCopyValidateDiskInfoOperation.h"
#import "LCSWritePlistOperation.h"
#import "LCSDiskUtilOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSLaunchctlOperation.h"


@implementation LCSRotavaultScheduleInstallCommand
-(id)initWithSourceDevice:(NSString*)sourceDevice targetDevice:(NSString*)targetDevice runAt:(NSDate*)targetDate
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    sourceInfo = nil;
    targetInfo = nil;
    launchdPlist = nil;
    plistPath = nil;

    LCSInformationForDiskOperation *sourceInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    sourceInfoOperation.delegate = self;
    sourceInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];

    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.result);
    [queue addOperation:targetInfoOperation];

    LCSInformationForDiskOperation *bootdiskInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation);
    bootdiskInfoOperation.delegate = self;
    bootdiskInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/"];
    bootdiskInfoOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation.result);
    [queue addOperation:bootdiskInfoOperation];

    LCSBlockCopyValidateDiskInfoOperation *validateDiskInfoOperation =
        [[[LCSBlockCopyValidateDiskInfoOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(validateDiskInfoOperation);
    validateDiskInfoOperation.delegate = self;
    validateDiskInfoOperation.sourceInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    validateDiskInfoOperation.targetInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    validateDiskInfoOperation.bootdiskInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(validateDiskInfoOperation.sourceInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(validateDiskInfoOperation.targetInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(validateDiskInfoOperation.bootdiskInfo);
    [validateDiskInfoOperation addDependency:sourceInfoOperation];
    [validateDiskInfoOperation addDependency:targetInfoOperation];
    [validateDiskInfoOperation addDependency:bootdiskInfoOperation];
    [queue addOperation:validateDiskInfoOperation];

    LCSGenerateRotavaultCopyLaunchdPlistOperation *plistGenOperation =
        [[[LCSGenerateRotavaultCopyLaunchdPlistOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation);
    plistGenOperation.delegate = self;
    plistGenOperation.runAtDate = [LCSSimpleOperationInputParameter parameterWithValue:targetDate];
    plistGenOperation.sourceInfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.runAtDate);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.sourceInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.targetInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.result);
    [plistGenOperation addDependency:validateDiskInfoOperation];
    [queue addOperation:plistGenOperation];

    LCSWritePlistOperation *plistInstallOperation = 
        [[[LCSWritePlistOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation);
    plistInstallOperation.delegate = self;
    plistInstallOperation.plistPath =
        [LCSKeyValueOperationInOutParameter parameterWithTarget:self keyPath:@"plistPath"];
    plistInstallOperation.plist = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation.plistPath);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation.plist);
    [plistInstallOperation addDependency:plistGenOperation];
    [queue addOperation:plistInstallOperation];

    launchctlRemoveOperation = [[LCSLaunchctlRemoveOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlRemoveOperation);
    launchctlRemoveOperation.delegate = self;
    launchctlRemoveOperation.label = [LCSSimpleOperationInputParameter parameterWithValue:@"ch.znerol.rvcopyd"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlRemoveOperation.label);
    [launchctlRemoveOperation addDependency:plistInstallOperation];
    [queue addOperation:launchctlRemoveOperation];

    LCSLaunchctlLoadOperation *launchctlLoadOperation = [[[LCSLaunchctlLoadOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlLoadOperation);
    launchctlLoadOperation.delegate = self;
    launchctlLoadOperation.path = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"plistPath"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlLoadOperation.path);
    [launchctlLoadOperation addDependency: launchctlRemoveOperation];
    [queue addOperation:launchctlLoadOperation];

    return self;
}

-(void)dealloc
{
    [sourceInfo release];
    [targetInfo release];
    [launchdPlist release];
    [super dealloc];
}

-(void)operation:(LCSOperation *)operation handleError:(NSError *)error
{
    /* we ignore errors from the launchctl remove operation */
    if (operation == launchctlRemoveOperation) {
        return;
    }

    /* let's delegate everything else to our superclass */
    [super operation:operation handleError:error];
}
@end
