//
//  LCSSignalHandler.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSignalHandler.h"
#import "LCSInitMacros.h"

/* 
 * http://lists.apple.com/archives/Cocoa-dev/2001/Dec/msg00160.html
 */

int _LCSSignalHandlerPipeWriteEnd = -1;
void _LCSSignalHandlerCallback(int signal)
{
    write(_LCSSignalHandlerPipeWriteEnd, &signal, sizeof(signal));
}

LCSSignalHandler* _LCSSignalHandlerSharedInstance = nil;

@implementation LCSSignalHandler
@synthesize delegate;

+(id)defaultSignalHandler
{
    if(!_LCSSignalHandlerSharedInstance) {
        _LCSSignalHandlerSharedInstance = [[LCSSignalHandler alloc] init];
    }
    return _LCSSignalHandlerSharedInstance;
}

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    sigpipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sigpipe);

    [[sigpipe fileHandleForReading] readInBackgroundAndNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInputFromSignalPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[sigpipe fileHandleForReading]];

    _LCSSignalHandlerPipeWriteEnd = [[sigpipe fileHandleForWriting] fileDescriptor];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(_LCSSignalHandlerPipeWriteEnd);

    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    /* FIXME: remove all signal handlers */
    [sigpipe release];
    [super dealloc];
}

-(void)handleInputFromSignalPipe:(NSNotification*)nfc
{
    NSData *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    int sig;
    [data getBytes:&sig length:sizeof(int)];

    if (!delegate) {
        return;
    }

    [delegate performSelectorOnMainThread:@selector(handleSignal:)
                               withObject:[NSNumber numberWithInt:sig]
                            waitUntilDone:YES];
}

-(void)addSignal:(int)sig
{
    signal(sig, _LCSSignalHandlerCallback);
}
@end
