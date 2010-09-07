//
//  LCSRotavaultScheduleInstallOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallOperation.h"
#import "LCSInitMacros.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"

@implementation LCSRotavaultScheduleInstallOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    /* initialization of targetInfoOperation.device left out on purpose*/
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];
    
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    /* initialization of targetInfoOperation.device left out on purpose */
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.result);
    [queue addOperation:targetInfoOperation];
    
    bootdiskInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation);
    bootdiskInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/"];
    bootdiskInfoOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfoOperation.result);
    [queue addOperation:bootdiskInfoOperation];
    
    validateDiskInfoOperation = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(validateDiskInfoOperation);
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
    
    plistGenOperation = [[LCSGenerateRotavaultCopyLaunchdPlistOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation);
    /* initialization of plistGenOperation.runAtDate left out on purpose*/
    plistGenOperation.sourceInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.sourceInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.targetInfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistGenOperation.result);
    [plistGenOperation addDependency:validateDiskInfoOperation];
    [queue addOperation:plistGenOperation];
    
    plistInstallOperation = [[LCSWritePlistOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation);
    plistInstallOperation.plistPath =
        [LCSKeyValueOperationInOutParameter parameterWithTarget:self keyPath:@"plistPath"];
    plistInstallOperation.plist =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation.plistPath);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistInstallOperation.plist);
    [plistInstallOperation addDependency:plistGenOperation];
    [queue addOperation:plistInstallOperation];
    
    launchctlRemoveOperation = [[LCSLaunchctlRemoveOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlRemoveOperation);
    launchctlRemoveOperation.label = [LCSSimpleOperationInputParameter parameterWithValue:@"ch.znerol.rvcopyd"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlRemoveOperation.label);
    [launchctlRemoveOperation addDependency:plistInstallOperation];
    [queue addOperation:launchctlRemoveOperation];
    
    launchctlLoadOperation = [[LCSLaunchctlLoadOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchctlLoadOperation);
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
    [bootdiskInfo release];
    [launchdPlist release];
    [plistPath release];

    [sourceInfoOperation release];
    [targetInfoOperation release];
    [bootdiskInfoOperation release];
    [validateDiskInfoOperation release];
    [plistGenOperation release];
    [plistInstallOperation release];
    [launchctlRemoveOperation release];
    [launchctlLoadOperation release];
    
    [super dealloc];
}

-(void)setDelegate:(id)newDelegate
{
    [super setDelegate:newDelegate];
    /* this is a hack to avoid errors promoting to runner when removing not-existing launchd job */
    [launchctlRemoveOperation setDelegate:nil];
}

-(void)setSourceDevice:(id <LCSOperationInputParameter>)sourceDeviceParam
{
    [sourceInfoOperation setDevice:sourceDeviceParam];
}

-(id <LCSOperationInputParameter>)sourceDevice
{
    return [sourceInfoOperation device];
}

-(void)setTargetDevice:(id <LCSOperationInputParameter>)targetDeviceParam
{
    [targetInfoOperation setDevice:targetDeviceParam];
}

-(id <LCSOperationInputParameter>)targetDevice
{
    return [targetInfoOperation device];
}

-(void)setRunAtDate:(id <LCSOperationInputParameter>)runAtDateParam
{
    [plistGenOperation setRunAtDate:runAtDateParam];
}

-(id <LCSOperationInputParameter>)runAtDate
{
    return [plistGenOperation runAtDate];
}
@end
