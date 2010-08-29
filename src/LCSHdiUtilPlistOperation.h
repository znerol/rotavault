//
//  LCSHdiUtilPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperation.h"
#import "LCSTaskOperationBase.h"


@interface LCSHdiInfoOperation : LCSPlistTaskOperation
@end

@interface LCSAttachImageOperation : LCSPlistTaskOperation {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;
@end

@interface LCSDetachImageOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> path;
}
@property(retain) id <LCSOperationInputParameter> path;
@end
