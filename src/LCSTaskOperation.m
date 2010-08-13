//
//  LCSTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperation.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSTaskOperation

-(id)init
{
    self = [super init];
    task = [[NSTask alloc] init];
    errPipe = [[NSPipe alloc] init];
    errEOF = NO;
    outPipe = [[NSPipe alloc] init];
    outEOF = NO;
    launchPath = [[NSNull null] retain];
    arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:[NSArray array]];
    return self;
}

-(void)dealloc
{
    [errPipe release];
    [outPipe release];
    [task release];
    [(NSObject*)launchPath release];
    [(NSObject*)arguments release];
    [super dealloc];
}

@synthesize launchPath;
@synthesize arguments;

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
    if (status != 0) {
        NSError *error = [LCSTaskOperationError errorWithLaunchPath:[task launchPath] status:status];
        [self handleError:error];
    }
    [self delegateSelector:@selector(operation:terminatedWithStatus:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithInt:status], nil]];
}

/* override */
-(void)taskBuildArguments
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
    [self taskBuildArguments];
    [task setLaunchPath:launchPath.value];
    [task setArguments:arguments.value];

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
    
    /* last chance to interpret and store output */
    [self taskOutputComplete];
}

-(void)cancel
{
    if ([task isRunning]) {
        [task interrupt];
    }
    [super cancel];
}

@end