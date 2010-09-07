//
//  LCSCommandSignalHandler.m
//  rotavault
//
//  Created by Lorenz Schori on 31.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommandSignalHandler.h"
#import "LCSSignalHandler.h"
#import "LCSInitMacros.h"


@implementation LCSCommandSignalHandler
-(id)initWithCommand:(LCSCommand*)command
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    target = [command retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(target);

    /* setup signal handler and signal pipe */
    LCSSignalHandler *sh = [LCSSignalHandler defaultSignalHandler];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sh);
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
