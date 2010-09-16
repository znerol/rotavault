//
//  LCSTaskOperationBase.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationBase.h"
#import "LCSInitMacros.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultError.h"


@implementation LCSTaskOperationBase

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    task = [[NSTask alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(task);
    
    errEOF = NO;
    errPipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(errPipe);
    
    outEOF = NO;
    outPipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(outPipe);
    
    return self;
}

-(void)dealloc
{
    [errPipe release];
    [outPipe release];
    [task release];
    [super dealloc];
}

-(void)updateStandardOutput:(NSData*)data
{
    [self delegateSelector:@selector(operation:updateStandardOutput:)
             withArguments:[NSArray arrayWithObjects:self, data, nil]];
}

-(void)updateStandardError:(NSData*)data
{
    [self delegateSelector:@selector(operation:updateStandardError:)
             withArguments:[NSArray arrayWithObjects:self, data, nil]];
}

-(void)taskLaunched
{
    [self delegateSelector:@selector(taskOperationLaunched:) withArguments:[NSArray arrayWithObject:self]];    
}

-(void)taskTerminatedWithStatus:(int)status
{
    if (status != 0 && [self isCancelled] == NO) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSExecutableReturnedNonZeroStatusError,
                                         LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]),
                                         LCSERROR_EXECUTABLE_TERMINATION_STATUS(status));
        [self handleError:error];
    }
    [self delegateSelector:@selector(operation:terminatedWithStatus:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithInt:status], nil]];
}

/* override */
-(void)taskSetup
{
}

/* override */
-(void)taskOutputComplete
{
}

-(void)handleStandardOutputPipe:(NSNotification*)nfc
{
    /* parameters for operation:updateStandardOutput: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateStandardOutput:data];
    
    outEOF = ([data length] == 0);
    if (!outEOF) {
        [[outPipe fileHandleForReading] readInBackgroundAndNotify];
    }
}

-(void)handleStandardErrorPipe:(NSNotification*)nfc
{
    /* parameters for operation:updateStandardError: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateStandardError:data];
    
    errEOF = ([data length] == 0);
    if (!errEOF) {
        [[errPipe fileHandleForReading] readInBackgroundAndNotify];
    }
}

-(void)execute
{
    operationThread = [NSThread currentThread];
    
    [self taskSetup];
    
    /* install standard error pipe */
    [task setStandardError:errPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStandardErrorPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[errPipe fileHandleForReading]];
    [[errPipe fileHandleForReading] readInBackgroundAndNotify];
    
    /* install progress meter */
    [task setStandardOutput:outPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStandardOutputPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[outPipe fileHandleForReading]];
    [[outPipe fileHandleForReading] readInBackgroundAndNotify];
    
    /* 
     * launch the task, process output and wait until its finished or canceled. Because we're inside an NSOperation
     * we *must* catch any exception!
     */
    @try {
        [task launch];
    }
    @catch (NSException *exc) {
        /* 
         * It's very important to remove ourselves as the receiver of stdout, stderr events here, otherwise the 
         * notification center possibly sends notifications after the operation was destroyed already.
         */
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        /* Give the delegate a chance to notice */
        NSError* error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSLaunchOfExecutableFailedError,
                                         LCSERROR_LOCALIZED_FAILURE_REASON([exc reason]),
                                         LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:error];
        return;
    }
    
    [self taskLaunched];
    [task waitUntilExit];
    [self taskTerminatedWithStatus:[task terminationStatus]];

    if (![self isCancelled]) {
        /* spin until eof is reached for both streams */
        while(outEOF == NO || errEOF == NO){
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

        /* last chance to interpret and store output */
        [self taskOutputComplete];
    }

    /* finally remove us from the notification center */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)stopTask
{
    if ([task isRunning]) {
        [task interrupt];
    }
}

-(void)cancel
{
    [self performSelector:@selector(stopTask) onThread:operationThread withObject:nil waitUntilDone:NO];
    [super cancel];
}

@end
