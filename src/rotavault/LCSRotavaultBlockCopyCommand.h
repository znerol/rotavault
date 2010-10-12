//
//  LCSRotavaultBlockCopyCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSCommandRunner.h"
#import "LCSCommandControllerCollection.h"


@interface LCSRotavaultBlockCopyCommand : NSObject <LCSCommand>
{
    LCSCommandController* controller;
    id <LCSCommandRunner> runner;
    
    NSString* sourceDevice;
    NSString* sourceChecksum;
    NSString* targetDevice;
    NSString* targetChecksum;
    
    LCSCommandControllerCollection* activeControllers;
    BOOL needsSourceRemount;
    
    LCSCommandController *sourceInfoCtl;
    LCSCommandController *targetInfoCtl;
}

+(LCSRotavaultBlockCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                         sourceChecksum:(NSString*)sourcecheck
                                           targetDevice:(NSString*)targetdev
                                         targetChecksum:(NSString*)targetcheck;

-(id)initWithSourceDevice:(NSString*)sourcedev
           sourceChecksum:(NSString*)sourcecheck
             targetDevice:(NSString*)targetdev
           targetChecksum:(NSString*)targetcheck;
@end
