//
//  LCSBlockCopyValidateDiskInfoOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSBlockCopyValidateDiskInfoOperation : LCSOperation {
    id <LCSOperationInputParameter> sourceInfo;
    id <LCSOperationInputParameter> targetInfo;
    id <LCSOperationInputParameter> bootdiskInfo;
}

@property(retain) id <LCSOperationInputParameter> sourceInfo;
@property(retain) id <LCSOperationInputParameter> targetInfo;
@property(retain) id <LCSOperationInputParameter> bootdiskInfo;
@end
