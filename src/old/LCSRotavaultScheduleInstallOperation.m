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
#import "LCSForwardOperationParameter.h"
#import "LCSOperationParameterMarker.h"

@implementation LCSRotavaultScheduleInstallOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourceDevice = [[LCSOperationRequiredInputParameterMarker alloc] init];
    targetDevice = [[LCSOperationRequiredInputParameterMarker alloc] init];
    runAtDate = [[LCSOperationOptionalInputParameterMarker alloc] initWithDefaultValue:nil];
    rvcopydLaunchPath = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice && targetDevice && runAtDate);
    
    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    sourceInfoOperation.device = [LCSForwardOperationInputParameter parameterWithParameterPointer:&sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.device && sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];
    
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    targetInfoOperation.device = [LCSForwardOperationInputParameter parameterWithParameterPointer:&targetDevice];
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
    plistGenOperation.runAtDate = [LCSForwardOperationInputParameter parameterWithParameterPointer:&runAtDate];
    plistGenOperation.sourceInfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.rvcopydLaunchPath =
        [LCSForwardOperationInputParameter parameterWithParameterPointer:&rvcopydLaunchPath];
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
    
    [sourceDevice release];
    [targetDevice release];
    [runAtDate release];
    [rvcopydLaunchPath release];
    
    [super dealloc];
}

-(void)setDelegate:(id)newDelegate
{
    [super setDelegate:newDelegate];
    /* this is a hack to avoid errors promoting to runner when removing not-existing launchd job */
    [launchctlRemoveOperation setDelegate:nil];
}

@synthesize sourceDevice;
@synthesize targetDevice;
@synthesize runAtDate;
@synthesize rvcopydLaunchPath;
@end
