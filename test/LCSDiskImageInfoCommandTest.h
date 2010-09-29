//
//  LCSDiskImageInfoCommandTest.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSDiskImageInfoCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"


@interface LCSDiskImageInfoCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSCommandManager *mgr;
    LCSDiskImageInfoCommand *cmd;
    LCSCommandController *ctl;
}

@end
