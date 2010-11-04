//
//  LCSAppleRAIDObserver.h
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSObserver.h"
#import "LCSCommand.h"


@interface LCSAppleRAIDObserver : LCSObserver {
    LCSCommand      *raidListCommand;
    NSTimeInterval  shortTimeout;
    NSTimeInterval  longTimeout;
}
@end
