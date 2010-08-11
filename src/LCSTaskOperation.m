//
//  LCSTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperation.h"
#import "LCSOperationPrivate.h"

@implementation LCSTaskOperation

-(id)initWithLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments
{
    self = [super init];
    task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    if (arguments) {
        [task setArguments:arguments];
    }
    errPipe = [[NSPipe pipe] retain];
    errEOF = NO;
    outPipe = [[NSPipe pipe] retain];
    outEOF = NO;

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
    [self delegateSelector:@selector(operation:terminatedWithStatus:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithInt:status], nil]];
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

-(void)main
{
    [super prepareMain];

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
        NSError* error = [LCSTaskOperationError errorExecutionOfPathFailed:[task launchPath] message:[exc reason]];
        [self handleError:error];
        return;
    }

    [self taskLaunched];

    [task waitUntilExit];

    [self taskTerminatedWithStatus:[task terminationStatus]];

    /* spin until eof is reached for both streams */
    while(outEOF == NO || errEOF == NO){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    /* finally remove us from the notification center */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)cancel
{
    if ([task isRunning]) {
        [task interrupt];
    }
    [super cancel];
}

@end