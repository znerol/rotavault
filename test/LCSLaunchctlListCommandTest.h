//
//  LCSLaunchctlListCommandTest.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSCommandManager.h"
#import "LCSLaunchctlListCommand.h"
#import "LCSCommandController.h"


@interface LCSLaunchctlListCommandTest : GHTestCase {
    LCSCommandManager *mgr;
    LCSLaunchctlListCommand *cmd;
    LCSCommandController *ctl;    
}

@end
