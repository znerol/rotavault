//
//  LCSExternalCommandTest.h
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSExternalCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"


@interface LCSExternalCommandTest : GHTestCase {
    NSMutableArray *states;
    LCSCommandManager *mgr;
    LCSExternalCommand *cmd;
    LCSCommandController *ctl;
}
@end
