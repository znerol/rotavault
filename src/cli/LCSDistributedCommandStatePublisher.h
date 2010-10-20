//
//  LCSCommandStatePublisher.h
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandController.h"


@interface LCSDistributedCommandStatePublisher : NSObject {
    LCSCommandController* controller;
    NSString* label;
}

- (id)initWithCommandController:(LCSCommandController*)ctl label:(NSString*)sndlabel;
- (void)watch;
- (void)unwatch;
@end
