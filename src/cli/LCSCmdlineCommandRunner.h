//
//  LCSCmdlineCommandRunner.h
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSSignalHandler.h"
#import "LCSCommand.h"


@interface LCSCmdlineCommandRunner : NSObject <LCSSignalHandlerDelegate> {
    LCSCommand *cmd;
    NSString *label;
    NSString *title;
    NSError* error;
}
-(id)initWithCommand:(LCSCommand*)command label:(NSString*)lbl title:(NSString*)tit;
-(NSError*)run;
@end
