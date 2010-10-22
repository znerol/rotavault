//
//  LCSExecuteBASCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSExecuteBASCommand.h"
#import "LCSInitMacros.h"


@implementation LCSExecuteBASCommand
@synthesize controller;
@synthesize bundleID;

+ (LCSExecuteBASCommand*)commandWithRequest:(NSDictionary*)req
                                    fromSet:(BASCommandSpec*)cmdSet
                          withAuthorization:(AuthorizationRef)auth
{
    return [[[LCSExecuteBASCommand alloc] initWithRequest:req fromSet:cmdSet withAuthorization:auth] autorelease];
}

- (id)initWithRequest:(NSDictionary*)req fromSet:(const BASCommandSpec*)cmdSet withAuthorization:(AuthorizationRef)auth
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    authorization = auth;
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(auth);
    commandSet = cmdSet;
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(cmdSet);
    request = [req retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(request);
    
    bundleID = [[NSBundle mainBundle] bundleIdentifier];
    return self;
}

- (void)dealloc
{
    [request release];
    [response release];
    [super dealloc];
}

- (void)collectResults
{
    /* Left empty intentionally. Subclasses may override this method. */
}

- (void)execRequest
{
    OSStatus err = BASExecuteRequestInHelperTool(authorization,
                                                 commandSet,
                                                 (CFStringRef)bundleID,
                                                 (CFDictionaryRef)request,
                                                 (CFDictionaryRef*)&response);
    
    /* FIXME: handle IPC error */
    if (err != noErr) {
        controller.state = LCSCommandStateFailed;
        controller.state = LCSCommandStateInvalidated;
        return;
    }
    
    /* FIXME: handle command error */
    err = BASGetErrorFromResponse((CFDictionaryRef)response);
    if (err != noErr) {
        controller.state = LCSCommandStateFailed;
        controller.state = LCSCommandStateInvalidated;
        return;
    }
    
    [self collectResults];
    
    controller.state = LCSCommandStateFinished;
    controller.state = LCSCommandStateInvalidated;    
}

- (void)start
{
    if (![controller tryStart]) {
        return;
    }
    
    controller.state = LCSCommandStateRunning;
    [self performSelector:@selector(execRequest) withObject:nil afterDelay:0];
}
@end
