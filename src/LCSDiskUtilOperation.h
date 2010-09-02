//
//  LCSDiskUtilOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperationBase.h"
#import "LCSTaskOperationBase.h"


@interface LCSListDisksOperation : LCSPlistTaskOperationBase
@end

@interface LCSInformationForDiskOperation : LCSPlistTaskOperationBase {
    id <LCSOperationInputParameter> device;
}
@property(retain) id <LCSOperationInputParameter> device;
@end

@interface LCSMountOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> device;
}
@property(retain) id <LCSOperationInputParameter> device;
@end

@interface LCSUnmountOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> device;
}
@property(retain) id <LCSOperationInputParameter> device;
@end
