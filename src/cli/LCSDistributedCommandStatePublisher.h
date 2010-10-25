//
//  LCSCommandStatePublisher.h
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSDistributedCommandStatePublisher : NSObject {
    LCSCommand* command;
    NSString* label;
    NSMutableArray* states;
}

- (id)initWithCommand:(LCSCommand*)cmd label:(NSString*)sndlabel;
- (void)watch;
- (void)unwatch;
@end
