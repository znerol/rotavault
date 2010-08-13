//
//  LCSDiskUtilOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperation.h"


@interface LCSListDisksOperation : LCSPlistTaskOperation
@end

@interface LCSInformationForDiskOperation : LCSPlistTaskOperation {
    NSString *device;
}
@property(retain) NSString *device;
@end
