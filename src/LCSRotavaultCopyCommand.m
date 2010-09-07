//
//  LCSRotavaultCopyCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultCopyCommand.h"
#import "LCSInitMacros.h"
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
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    LCSInformationForDiskOperation *sourceInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    sourceInfoOperation.delegate = self;
    sourceInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifySourceInfoOperation =
        [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation);
    verifySourceInfoOperation.delegate = self;
    verifySourceInfoOperation.diskinfo = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    verifySourceInfoOperation.checksum = [LCSSimpleOperationInputParameter parameterWithValue:sourceChecksum];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation.diskinfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation.checksum);
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];
    
    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.device);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.result);
    [queue addOperation:targetInfoOperation];
    
    LCSVerifyDiskInfoChecksumOperation *verifyTargetInfoOperation =
        [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation);
    verifyTargetInfoOperation.delegate = self;
    verifyTargetInfoOperation.diskinfo =
        [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    verifyTargetInfoOperation.checksum = [LCSSimpleOperationInputParameter parameterWithValue:targetChecksum];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation.diskinfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation.checksum);
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];
    
    LCSBlockCopyOperation *blockCopyOperation = [[[LCSBlockCopyOperation alloc] init] autorelease];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation);
    blockCopyOperation.delegate = self;
    blockCopyOperation.source = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    blockCopyOperation.target = [LCSSimpleOperationInputParameter parameterWithValue:targetDevice];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation.source);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation.target);
    [blockCopyOperation addDependency:verifySourceInfoOperation];
    [blockCopyOperation addDependency:verifyTargetInfoOperation];
    [queue addOperation:blockCopyOperation];
    
    sourceRemountOperation = [[LCSMountOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceRemountOperation);
    sourceRemountOperation.delegate = self;
    sourceRemountOperation.device = [LCSSimpleOperationInputParameter parameterWithValue:sourceDevice];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceRemountOperation.device);
    
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
