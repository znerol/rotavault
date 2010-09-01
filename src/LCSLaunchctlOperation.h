//
//  LCSLaunchctlOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationBase.h"
#import "LCSPlistTaskOperationBase.h"


@interface LCSLaunchctlLoadOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;
@end

@interface LCSLaunchctlUnloadOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;

@end

@interface LCSLaunchctlRemoveOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> label;
}
@property(retain) id <LCSOperationInputParameter> label;
@end

@interface LCSLaunchctlListOperation : LCSTaskOperationBase {
    id <LCSOperationOutputParameter> result; //NSArray*
    NSMutableData*  stdoutData;
}
@property(retain) id <LCSOperationOutputParameter> result;
@end

@interface LCSLaunchctlInfoOperation : LCSPlistTaskOperationBase {
    id <LCSOperationInputParameter> label;
}
@property(retain) id <LCSOperationInputParameter> label;
@end
