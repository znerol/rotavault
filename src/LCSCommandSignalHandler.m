//
//  LCSCommandSignalHandler.m
//  rotavault
//
//  Created by Lorenz Schori on 31.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommandSignalHandler.h"
#import "LCSSignalHandler.h"


@implementation LCSCommandSignalHandler
-(id)initWithCommand:(LCSCommand*)command
{
    if(!(self = [super init])) {
        return nil;
    }

    target = [command retain];

    /* setup signal handler and signal pipe */
    LCSSignalHandler *sh = [LCSSignalHandler defaultSignalHandler];
    [sh setDelegate:self];
    [sh addSignal:SIGHUP];
    [sh addSignal:SIGINT];
    [sh addSignal:SIGPIPE];
    [sh addSignal:SIGALRM];
    [sh addSignal:SIGTERM];

    return self;
}

-(void)dealloc
{
    LCSSignalHandler *sh = [LCSSignalHandler defaultSignalHandler];
    [sh setDelegate:nil];
    [target release];
    [super dealloc];
}

-(void)handleSignal:(NSNumber*)signal
{
    [target cancel];
}
@end
