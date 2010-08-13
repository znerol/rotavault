//
//  LCSHdiUtilWithProgressOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSHdiUtilWithProgressOperation : LCSTaskOperation
@end

@interface LCSCreateEncryptedImageOperation : LCSHdiUtilWithProgressOperation {
    NSString *path;
    uint64_t sectors;
}
@property(retain) NSString  *path;
@property(assign) uint64_t  sectors;
@end

