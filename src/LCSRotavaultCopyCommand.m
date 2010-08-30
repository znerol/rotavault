//
//  LCSRotavaultCopyCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultCopyCommand.h"
#import "LCSBlockCopyOperation.h"
#import "LCSDiskUtilOperation.h"
#import "LCSVerifyDiskInfoChecksumOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"


@implementation LCSRotavaultCopyCommand
-(id)initWithSourceDevice:(NSString*)sourceDevice
              sourceCheck:(NSString*)sourceChecksum
             targetDevice:(NSString*)targetDevice
           targetChecksum:(NSString*)targetChecksum
{
    if(!(self = [super init])) {
        return nil;
    }
    
    sourceInfo = nil;
    targetInfo = nil;
    
    LCSInformationForDiskOperation *sourceInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    sourceInfoOperation.delegate = self;
    sourceInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    sourceInfoOperation.result =
    [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifySourceInfoOperation =
    [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifySourceInfoOperation.delegate = self;
    verifySourceInfoOperation.diskinfo =
    [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"sourceInfo"];
    verifySourceInfoOperation.checksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceChecksum];
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];
    
    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDevice];
    targetInfoOperation.result =
    [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifyTargetInfoOperation =
    [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifyTargetInfoOperation.delegate = self;
    verifyTargetInfoOperation.diskinfo =
    [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"targetInfo"];
    verifyTargetInfoOperation.checksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetChecksum];
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];
    
    LCSBlockCopyOperation *blockCopyOperation = [[[LCSBlockCopyOperation alloc] init] autorelease];
    blockCopyOperation.delegate = self;
    blockCopyOperation.source = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    blockCopyOperation.target = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDevice];
    [blockCopyOperation addDependency:verifySourceInfoOperation];
    [blockCopyOperation addDependency:verifyTargetInfoOperation];
    [queue addOperation:blockCopyOperation];
    
    sourceRemountOperation = [[LCSMountOperation alloc] init];
    sourceRemountOperation.delegate = self;
    sourceRemountOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    
    return self;
}

-(void)dealloc
{
    [sourceInfo release];
    [targetInfo release];
    [sourceRemountOperation release];
    [super dealloc];
}

-(NSError*)execute
{
    NSError *err = [super execute];
    
    if(err)
    {
        /* try to mount the source volume */
        [sourceRemountOperation execute];
    }
    
    return err;
}
@end
