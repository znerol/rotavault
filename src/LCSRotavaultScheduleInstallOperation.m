//
//  LCSRotavaultScheduleInstallOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"

@implementation LCSRotavaultScheduleInstallOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    sourceInfo = nil;
    targetInfo = nil;
    launchdPlist = nil;
    plistPath = nil;
    
    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    /* targetInfoOperation.device */
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];
    
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    /* targetInfoOperation.device */
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];
    
    bootdiskInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    bootdiskInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/"];
    bootdiskInfoOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"bootdiskInfo"];
    [queue addOperation:bootdiskInfoOperation];
    
    validateDiskInfoOperation = [[LCSBlockCopyValidateDiskInfoOperation alloc] init];
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
    
    plistGenOperation = [[LCSGenerateRotavaultCopyLaunchdPlistOperation alloc] init];
    /* plistGenOperation.runAtDate */
    plistGenOperation.sourceInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.result =
        [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    [plistGenOperation addDependency:validateDiskInfoOperation];
    [queue addOperation:plistGenOperation];
    
    plistInstallOperation = 
    [[LCSWritePlistOperation alloc] init];
    plistInstallOperation.plistPath =
        [LCSKeyValueOperationInOutParameter parameterWithTarget:self keyPath:@"plistPath"];
    plistInstallOperation.plist =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"launchdPlist"];
    [plistInstallOperation addDependency:plistGenOperation];
    [queue addOperation:plistInstallOperation];
    
    launchctlRemoveOperation = [[LCSLaunchctlRemoveOperation alloc] init];
    launchctlRemoveOperation.label = [LCSSimpleOperationInputParameter parameterWithValue:@"ch.znerol.rvcopyd"];
    [launchctlRemoveOperation addDependency:plistInstallOperation];
    [queue addOperation:launchctlRemoveOperation];
    
    launchctlLoadOperation = [[LCSLaunchctlLoadOperation alloc] init];
    launchctlLoadOperation.path = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"plistPath"];
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
