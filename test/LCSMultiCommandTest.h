//
//  LCSMultiCommandTest.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSCommandManager.h"
#import "LCSMultiCommand.h"
#import "LCSCommandController.h"


@interface LCSMultiCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSCommandManager *mgr;
    LCSMultiCommand *cmd;
    LCSCommandController *ctl;    
}

@end
