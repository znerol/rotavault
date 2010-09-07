//
//  LCSRotavaultScheduleInstallCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallCommand.h"
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
    if(!(self = [super init])) {
        return nil;
    }

    sourceInfo = nil;
    targetInfo = nil;
    launchdPlist = nil;
    plistPath = nil;

    LCSInformationForDiskOperation *sourceInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    sourceInfoOperation.delegate = self;
    sourceInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];

    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];

    LCSInformationForDiskOperation *bootdiskInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    bootdiskInfoOperation.delegate = self;
    bootdiskInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/"];
    bootdiskInfoOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    [queue addOperation:bootdiskInfoOperation];

    LCSBlockCopyValidateDiskInfoOperation *validateDiskInfoOperation =
        [[[LCSBlockCopyValidateDiskInfoOperation alloc] init] autorelease];
    validateDiskInfoOperation.delegate = self;
    validateDiskInfoOperation.sourceInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    validateDiskInfoOperation.targetInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    validateDiskInfoOperation.bootdiskInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    [validateDiskInfoOperation addDependency:sourceInfoOperation];
    [validateDiskInfoOperation addDependency:targetInfoOperation];
    [validateDiskInfoOperation addDependency:bootdiskInfoOperation];
    [queue addOperation:validateDiskInfoOperation];

    LCSGenerateRotavaultCopyLaunchdPlistOperation *plistGenOperation =
        [[[LCSGenerateRotavaultCopyLaunchdPlistOperation alloc] init] autorelease];
    plistGenOperation.delegate = self;
    plistGenOperation.runAtDate = [LCSSimpleOperationInputParameter parameterWithValue:targetDate];
    plistGenOperation.sourceInfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    [plistGenOperation addDependency:validateDiskInfoOperation];
    [queue addOperation:plistGenOperation];

    LCSWritePlistOperation *plistInstallOperation = 
        [[[LCSWritePlistOperation alloc] init] autorelease];
    plistInstallOperation.delegate = self;
    plistInstallOperation.plistPath =
        [LCSKeyValueOperationInOutParameter parameterWithTarget:self keyPath:@"plistPath"];
    plistInstallOperation.plist = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    [plistInstallOperation addDependency:plistGenOperation];
    [queue addOperation:plistInstallOperation];

    launchctlRemoveOperation = [[LCSLaunchctlRemoveOperation alloc] init];
    launchctlRemoveOperation.delegate = self;
    launchctlRemoveOperation.label = [LCSSimpleOperationInputParameter parameterWithValue:@"ch.znerol.rvcopyd"];
    [launchctlRemoveOperation addDependency:plistInstallOperation];
    [queue addOperation:launchctlRemoveOperation];

    LCSLaunchctlLoadOperation *launchctlLoadOperation = [[[LCSLaunchctlLoadOperation alloc] init] autorelease];
    launchctlLoadOperation.delegate = self;
    launchctlLoadOperation.path = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"plistPath"];
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
