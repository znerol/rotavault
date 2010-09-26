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


@interface LCSExternalCommand (overrides)
-(void)taskCompleted;
-(void)invalidate;
@end


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

-(void)taskCompleteIfDone
{
    if (!taskTerminated || !stdoutData || !stderrData) {
        return;
    }
    
    self.controller.result = [NSArray arrayWithObjects:stdoutData, stderrData, nil];
    [super taskCompleted];
}

-(void)handleReadToEndOfFileNotification:(NSNotification*)ntf
{
    NSData **targetData;
    
    NSNumber *unixError = [[ntf userInfo] objectForKey:@"NSFileHandleError"];

    if ([unixError intValue] != 0) {
        self.controller.state = LCSCommandStateFailed;
        [self invalidate];
    }
    
    if ([ntf object] == [stdoutPipe fileHandleForReading]) {
        targetData = &stdoutData;
    }
    else if ([ntf object] == [stderrPipe fileHandleForReading]) {
        targetData = &stderrData;
    }
    else {
        return;
    }
    
    *targetData = [[[ntf userInfo] objectForKey:NSFileHandleNotificationDataItem] retain];
    
    [self taskCompleteIfDone];
}

-(void)taskCompleted
{
    taskTerminated = YES;
    [self taskCompleteIfDone];
}

-(void)start
{
    [self.task setStandardOutput:stdoutPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadToEndOfFileNotification:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:[stdoutPipe fileHandleForReading]];
    [[stdoutPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    [self.task setStandardError:stderrPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadToEndOfFileNotification:)
                                                 name:NSFileHandleReadToEndOfFileCompletionNotification
                                               object:[stderrPipe fileHandleForReading]];
    [[stderrPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    
    [super start];
}
@end
