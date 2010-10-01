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
#import "LCSForwardOperationParameter.h"
#import "LCSOperationParameterMarker.h"


@implementation LCSRotavaultCopyOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourceDevice = [[LCSOperationRequiredInputParameterMarker alloc] init];
    sourceChecksum = [[LCSOperationRequiredInputParameterMarker alloc] init];
    targetDevice = [[LCSOperationRequiredInputParameterMarker alloc] init];
    targetChecksum = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceDevice && sourceChecksum && targetDevice && targetChecksum);
    
    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation);
    sourceInfoOperation.device = [LCSForwardOperationInputParameter parameterWithParameterPointer:&sourceDevice];
    sourceInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"sourceInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfoOperation.device && sourceInfoOperation.result);
    [queue addOperation:sourceInfoOperation];
    
    verifySourceInfoOperation = [[LCSVerifyDiskInfoChecksumOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation);
    verifySourceInfoOperation.diskinfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self
                                                                                         keyPath:@"sourceInfo"];
    verifySourceInfoOperation.checksum =
        [LCSForwardOperationInputParameter parameterWithParameterPointer:&sourceChecksum];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifySourceInfoOperation.diskinfo && verifySourceInfoOperation.checksum);
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];
    
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation);
    targetInfoOperation.device = [LCSForwardOperationInputParameter parameterWithParameterPointer:&targetDevice];
    targetInfoOperation.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"targetInfo"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfoOperation.device && targetInfoOperation.result);
    [queue addOperation:targetInfoOperation];
    
    verifyTargetInfoOperation = [[LCSVerifyDiskInfoChecksumOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation);
    verifyTargetInfoOperation.diskinfo = [LCSKeyValueOperationInputParameter parameterWithTarget:self
                                                                                         keyPath:@"targetInfo"];
    verifyTargetInfoOperation.checksum =
        [LCSForwardOperationInputParameter parameterWithParameterPointer:&targetChecksum];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(verifyTargetInfoOperation.diskinfo && verifyTargetInfoOperation.checksum);
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];
    
    blockCopyOperation = [[LCSBlockCopyOperation alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation);
    blockCopyOperation.source = [LCSForwardOperationInputParameter parameterWithParameterPointer:&sourceDevice];
    blockCopyOperation.target = [LCSForwardOperationInputParameter parameterWithParameterPointer:&targetDevice];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(blockCopyOperation.source && blockCopyOperation.target);
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
