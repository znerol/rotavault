//
//  LCSTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperation.h"

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

-(void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

-(void)delegateSelector:(SEL)selector withArguments:(NSArray*)arguments
{

    /* nothing to perform if there is no delegate */
    if (delegate == nil) {
        return;
    }

    /* nothing to perform if the delegate does not respond to the specified selector */
    NSMethodSignature *sig = [delegate methodSignatureForSelector:selector];
    if (sig == nil) {
        return;
    }
    

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:selector];

    NSInteger argIndex=2;
    for(id arg in arguments) {
        [inv setArgument:&arg atIndex:argIndex++];
    }

    @try {
        [inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:delegate waitUntilDone:YES];
    }
    @catch (NSException * e) {
        NSLog(@"Failed to perform delegate method 1: %@", [e description]);
    }
}

-(void)updateStandardOutput:(NSData*)data
{
    [self delegateSelector:@selector(taskOperation:updateStandardOutput:)
             withArguments:[NSArray arrayWithObjects:self, data, nil]];
}

-(void)updateStandardError:(NSData*)data
{
    [self delegateSelector:@selector(taskOperation:updateStandardError:)
             withArguments:[NSArray arrayWithObjects:self, data, nil]];
}

-(void)handleError:(NSError*)error
{
    [self delegateSelector:@selector(taskOperation:handleError:)
             withArguments:[NSArray arrayWithObjects:self, error, nil]];
}

-(void)handleResult:(id)result
{
    [self delegateSelector:@selector(taskOperation:handleResult:)
             withArguments:[NSArray arrayWithObjects:self, result, nil]];
}

-(void)taskPreparingToLaunch
{
    [self delegateSelector:@selector(taskOperationPreparing:) withArguments:[NSArray arrayWithObject:self]];
}

-(void)taskLaunched
{
    [self delegateSelector:@selector(taskOperationLaunched:) withArguments:[NSArray arrayWithObject:self]];    
}

-(void)updateProgress:(float)progress
{
    [self delegateSelector:@selector(taskOperation:updateProgress:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithFloat:progress], nil]];
}

-(void)taskTerminatedWithStatus:(int)status
{
    [self delegateSelector:@selector(taskOperation:terminatedWithStatus:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithInt:status], nil]];
}

-(void)operationFinished
{
    [self delegateSelector:@selector(taskOperationFinished:) withArguments:[NSArray arrayWithObject:self]];
}

-(void)handleStandardOutputPipe:(NSNotification*)nfc
{
    /* parameters for taskOperation:updateStandardOutput: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateStandardOutput:data];

    outEOF = ([data length] == 0);
    if (!outEOF) {
        [[outPipe fileHandleForReading] readInBackgroundAndNotify];
    }
}

-(void)handleStandardErrorPipe:(NSNotification*)nfc
{
    /* parameters for taskOperation:updateStandardError: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateStandardError:data];

    errEOF = ([data length] == 0);
    if (!errEOF) {
        [[errPipe fileHandleForReading] readInBackgroundAndNotify];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"isFinished"]) {
        [self operationFinished];
    }
}

-(void)main
{
    /* check for cancelation */
    if ([self isCancelled]) {
        NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                   code:NSUserCancelledError
                                               userInfo:[NSDictionary dictionary]];
        [self handleError:cancelError];
    }
    
    /* notify delegate that we're preparing for launch now */
    [self taskPreparingToLaunch];

    /* register finished handler */
    [self addObserver:self forKeyPath:@"isFinished" options:0 context:nil];


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
    [super cancel];
    
    if ([task isRunning]) {
        [task interrupt];
    }
    
    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                               code:NSUserCancelledError
                                           userInfo:[NSDictionary dictionary]];
    [self handleError:cancelError];
}

@end