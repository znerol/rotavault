//
//  LCSPlistTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperationBase.h"


@interface LCSPlistTaskOperation : LCSPlistTaskOperationBase {
    id <LCSOperationInputParameter> launchPath;    /* NSString */
    id <LCSOperationInputParameter> arguments;     /* NSArray of NSString */
}

@property(retain) id <LCSOperationInputParameter> launchPath;
@property(retain) id <LCSOperationInputParameter> arguments;
@end
