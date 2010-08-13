//
//  LCSCalculateVolumeUsedSpaceOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSCalculateVolumeUsedSpaceOperation : LCSOperation {
    NSDictionary *diskinfo;
    NSNumber* result;
}
@property(retain)NSDictionary *diskinfo;
@property(readonly)NSNumber *result;

@end
