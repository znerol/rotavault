//
//  LCSHdiUtilPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperationBase.h"
#import "LCSTaskOperationBase.h"


@interface LCSHdiInfoOperation : LCSPlistTaskOperationBase
@end

@interface LCSAttachImageOperation : LCSPlistTaskOperationBase {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;
@end

@interface LCSDetachImageOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;
@end
