//
//  LCSDiskUtilOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperation.h"
#import "LCSOperationParameter.h"


@interface LCSListDisksOperation : LCSPlistTaskOperation
@end

@interface LCSInformationForDiskOperation : LCSPlistTaskOperation {
    id <LCSOperationInputParameter> device;
}
@property(retain) id <LCSOperationInputParameter> device;
@end
