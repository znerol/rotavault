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
    NSDictionary *diskinfo;
    NSString *checksum;
}
@property(retain)NSDictionary *diskinfo;
@property(retain)NSString *checksum;
@end
