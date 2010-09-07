//
//  LCSRotavaultCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 07.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultCopyOperation.h"
#import "LCSInitMacros.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"


@implementation LCSRotavaultCopyOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    /* sourceInfoOperation.device set in execute */
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];
    
    verifySourceInfoOperation = [[LCSVerifyDiskInfoChecksumOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation);
    verifySourceInfoOperation.diskinfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self
                                                                                         keyPath:@"sourceInfo"];
    /* verifySourceInfoOperation.checksum set in execute */
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation.diskinfo);
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];
    
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    /*targetInfoOperation.device set in execute */
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.result);
    [queue addOperation:targetInfoOperation];
    
    verifyTargetInfoOperation = [[LCSVerifyDiskInfoChecksumOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation);
    verifyTargetInfoOperation.diskinfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self
                                                                                         keyPath:@"targetInfo"];
    /* verifyTargetInfoOperation.checksum set in execute */
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation.diskinfo);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation.checksum);
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];
    
    blockCopyOperation = [[LCSBlockCopyOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation);
    /* blockCopyOperation.source set in execute */
    /* blockCopyOperation.target set in execute */
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation.source);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation.target);
    [blockCopyOperation addDependency:verifySourceInfoOperation];
    [blockCopyOperation addDependency:verifyTargetInfoOperation];
    [queue addOperation:blockCopyOperation];
    
    return self;
    
}

-(void)dealloc
{
    [sourceInfo release];
    [targetInfo release];
    
    [sourceDevice release];
    [targetDevice release];
    [sourceChecksum release];
    [targetChecksum release];
    
    [sourceInfoOperation release];
    [verifySourceInfoOperation release];
    [targetInfoOperation release];
    [verifyTargetInfoOperation release];
    [blockCopyOperation release];
    
    [super dealloc];
}

-(void)execute
{
    sourceInfoOperation.device = sourceDevice;
    verifySourceInfoOperation.checksum = sourceChecksum;
    targetInfoOperation.device = targetDevice;
    verifyTargetInfoOperation.checksum = targetChecksum;
    blockCopyOperation.source = sourceDevice;
    blockCopyOperation.target = targetDevice;

    [super execute];

    /* try to remount the source device if operation was not successfull */
    if ([self isCancelled]) {
        LCSMountOperation* sourceRemount = [[LCSMountOperation alloc] init];
        sourceRemount.device = sourceDevice;
        [sourceRemount start];
        [sourceRemount release];
    }
}

@synthesize sourceDevice;
@synthesize targetDevice;
@synthesize sourceChecksum;
@synthesize targetChecksum;
@end
