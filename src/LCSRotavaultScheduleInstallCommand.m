//
//  LCSRotavaultScheduleInstallCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallCommand.h"
#import "LCSGenerateRotavaultCopyLaunchdPlistOperation.h"
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
    sourceInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    sourceInfoOperation.result =
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];

    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDevice];
    targetInfoOperation.result =
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];

    LCSGenerateRotavaultCopyLaunchdPlistOperation *plistGenOperation =
        [[[LCSGenerateRotavaultCopyLaunchdPlistOperation alloc] init] autorelease];
    plistGenOperation.delegate = self;
    plistGenOperation.runAtDate = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDate];
    plistGenOperation.sourceInfo =
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"sourceInfo"];
    plistGenOperation.targetInfo = 
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"targetInfo"];
    plistGenOperation.result =
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"launchdPlist"];
    [plistGenOperation addDependency:sourceInfoOperation];
    [plistGenOperation addDependency:targetInfoOperation];
    [queue addOperation:plistGenOperation];

    LCSWritePlistOperation *plistInstallOperation = 
        [[[LCSWritePlistOperation alloc] init] autorelease];
    plistInstallOperation.delegate = self;
    plistInstallOperation.plistPath = [[LCSKeyValueOperationInOutParameter alloc] initWithTarget:self keyPath:@"plistPath"];
    plistInstallOperation.plist =
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"launchdPlist"];
    [plistInstallOperation addDependency:plistGenOperation];
    [queue addOperation:plistInstallOperation];

    launchctlRemoveOperation = [[LCSLaunchctlRemoveOperation alloc] init];
    launchctlRemoveOperation.delegate = self;
    launchctlRemoveOperation.label = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"ch.znerol.rvcopyd"];
    [launchctlRemoveOperation addDependency:plistInstallOperation];
    [queue addOperation:launchctlRemoveOperation];

    LCSLaunchctlLoadOperation *launchctlLoadOperation = [[LCSLaunchctlLoadOperation alloc] init];
    launchctlLoadOperation.delegate = self;
    launchctlLoadOperation.path = [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"plistPath"];
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
