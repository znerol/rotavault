//
//  LCSCmdlineCommandRunner.h
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandManager.h"
#import "LCSCommand.h"


@interface LCSCmdlineCommandRunner : NSObject {
    id <LCSCommand> cmd;
    LCSCommandManager *mgr;
    NSError* error;
}
-(id)initWithCommand:(id <LCSCommand>)command;
-(NSError*)run;
@end
