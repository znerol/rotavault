//
//  LCSCommandSignalHandler.h
//  rotavault
//
//  Created by Lorenz Schori on 31.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSCommandSignalHandler : NSObject {
    LCSCommand* target;
}
-(id)initWithCommand:(LCSCommand*)command;
@end
