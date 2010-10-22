//
//  LCSFailingTestCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandTemp.h"
#import "LCSCommandController.h"


@interface LCSTestCommand : NSObject <LCSCommandTemp> {
    NSTimeInterval delay;
    LCSCommandState finalState;
    LCSCommandController *controller;
}

-(id)initWithDelay:(NSTimeInterval)delay finalState:(LCSCommandState)state;
+(LCSTestCommand*)commandWithDelay:(NSTimeInterval)delay finalState:(LCSCommandState)state;
@end
