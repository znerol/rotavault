//
//  LCSVerifyDiskInfoChecksumOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSVerifyDiskInfoChecksumOperation : LCSOperation
{
    id <LCSOperationInputParameter> diskinfo;
    id <LCSOperationInputParameter> checksum;
}
@property(retain)id <LCSOperationInputParameter> diskinfo;
@property(retain)id <LCSOperationInputParameter> checksum;
@end
