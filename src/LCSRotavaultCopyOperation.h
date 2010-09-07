//
//  LCSRotavaultCopyOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 07.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationQueueOperation.h"
#import "LCSDiskUtilOperation.h"
#import "LCSVerifyDiskInfoChecksumOperation.h"
#import "LCSBlockCopyOperation.h"


@interface LCSRotavaultCopyOperation : LCSOperationQueueOperation {
    id <LCSOperationInputParameter> sourceDevice;   // NSString*
    id <LCSOperationInputParameter> targetDevice;   // NSString*
    id <LCSOperationInputParameter> sourceChecksum; // NSString*
    id <LCSOperationInputParameter> targetChecksum; // NSString*
    
    LCSInformationForDiskOperation      *sourceInfoOperation;
    LCSVerifyDiskInfoChecksumOperation  *verifySourceInfoOperation;
    LCSInformationForDiskOperation      *targetInfoOperation;
    LCSVerifyDiskInfoChecksumOperation  *verifyTargetInfoOperation;
    LCSBlockCopyOperation               *blockCopyOperation;
    
    NSDictionary* sourceInfo;
    NSDictionary* targetInfo;
}

@property(retain) id <LCSOperationInputParameter> sourceDevice;
@property(retain) id <LCSOperationInputParameter> targetDevice;
@property(retain) id <LCSOperationInputParameter> sourceChecksum;
@property(retain) id <LCSOperationInputParameter> targetChecksum;
@end
