//
//  LCSQuickExternalCommandTest.h
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSQuickExternalCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"


@interface LCSQuickExternalCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSCommandManager *mgr;
    LCSQuickExternalCommand *cmd;
    LCSCommandController *ctl;
}
@end
