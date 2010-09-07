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
    sourceInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifySourceInfoOperation =
    [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifySourceInfoOperation.delegate = self;
    verifySourceInfoOperation.diskinfo = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    verifySourceInfoOperation.checksum = [LCSSimpleOperationInputParameter parameterWithValue:sourceChecksum];
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];
    
    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifyTargetInfoOperation =
    [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifyTargetInfoOperation.delegate = self;
    verifyTargetInfoOperation.diskinfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    verifyTargetInfoOperation.checksum = [LCSSimpleOperationInputParameter parameterWithValue:targetChecksum];
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];
    
    LCSBlockCopyOperation *blockCopyOperation = [[[LCSBlockCopyOperation alloc] init] autorelease];
    blockCopyOperation.delegate = self;
    blockCopyOperation.source = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    blockCopyOperation.target = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    [blockCopyOperation addDependency:verifySourceInfoOperation];
    [blockCopyOperation addDependency:verifyTargetInfoOperation];
    [queue addOperation:blockCopyOperation];
    
    sourceRemountOperation = [[LCSMountOperation alloc] init];
    sourceRemountOperation.delegate = self;
    sourceRemountOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    
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
