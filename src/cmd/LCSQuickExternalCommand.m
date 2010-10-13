//
//  LCSQuickExternalCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSQuickExternalCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"


@implementation LCSQuickExternalCommand

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    stderrPipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(stderrPipe);
    stdoutPipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(stderrPipe);
    
    return self;
}

-(void)dealloc
{
    [stdoutData release];
    [stderrData release];
    [stdoutPipe release];
    [stderrPipe release];
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadToEndOfFileCompletionNotification
                                                  object:[stdoutPipe fileHandleForReading]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadToEndOfFileCompletionNotification
                                                  object:[stderrPipe fileHandleForReading]];
    [super invalidate];
}

-(void)collectResults
{
    controller.result = [NSArray arrayWithObjects:stdoutData, stderrData, nil];
}

-(void)completeIfDone
{
    if (!taskTerminated || !stdoutCollected || !stderrCollected) {
        return;
    }
    
    [self collectResults];
    [super handleTaskTermination];
}

-(void)stderrDataAvailable:(NSData*)data
{
    stderrCollected = YES;
    stderrData = [data retain];
}

-(void)stdoutDataAvailable:(NSData*)data
{
    stdoutCollected = YES;
    stdoutData = [data retain];
}

-(void)handleReadToEndOfFileNotification:(NSNotification*)ntf
{
    NSNumber *unixError = [[ntf userInfo] objectForKey:@"NSFileHandleError"];

    if ([unixError intValue] != 0) {
        controller.state = LCSCommandStateFailed;
        [self invalidate];
    }
    
    if ([ntf object] == [stdoutPipe fileHandleForReading]) {
        [self stdoutDataAvailable:[[ntf userInfo] objectForKey:NSFileHandleNotificationDataItem]];
    }
    else if ([ntf object] == [stderrPipe fileHandleForReading]) {
        [self stderrDataAvailable:[[ntf userInfo] objectForKey:NSFileHandleNotificationDataItem]];
    }
    else {
        return;
    }
    
    [self completeIfDone];
}

-(void)handleTaskTermination
{
    taskTerminated = YES;
    [self completeIfDone];
}

-(void)start
{
    [task setStandardOutput:stdoutPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadToEndOfFileNotification:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:[stdoutPipe fileHandleForReading]];
    [[stdoutPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    [task setStandardError:stderrPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadToEndOfFileNotification:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:[stderrPipe fileHandleForReading]];
    [[stderrPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    [super start];
}
@end