//
//  LCSCmdlineCommandRunner.h
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSSignalHandler.h"


@interface LCSCmdlineCommandRunner : NSObject <LCSSignalHandlerDelegate> {
    id <LCSCommand> cmd;
    LCSCommandController *ctl;
    NSString *label;
    NSString *title;
    NSError* error;
}
-(id)initWithCommand:(id <LCSCommand>)command label:(NSString*)lbl title:(NSString*)tit;
-(NSError*)run;
@end
