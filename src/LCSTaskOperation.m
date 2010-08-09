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
    return self;
}

-(void)dealloc
{
    [task release];
    [super dealloc];
}

-(void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
}

-(BOOL)delegateSelector:(SEL)selector withArguments:(NSArray*)arguments
{

    /* nothing to perform if there is no delegate */
    if (delegate == nil) {
        return NO;
    }

    /* nothing to perform if the delegate does not respond to the specified selector */
    NSMethodSignature *sig = [delegate methodSignatureForSelector:selector];
    if (sig == nil) {
        return NO;
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
    return YES;
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
    [self delegateSelector:@selector(taskOperation:handleError:)
             withArguments:[NSArray arrayWithObjects:self, cancelError, nil]];
}

-(void)updateOutput:(NSData*)data isAtEnd:(BOOL)atEnd
{
    [self delegateSelector:@selector(taskOperation:updateOutput:isAtEnd:)
             withArguments:[NSArray arrayWithObjects:self, data, [NSNumber numberWithBool:atEnd], nil]];
}

-(void)updateError:(NSData*)data isAtEnd:(BOOL)atEnd
{
    [self delegateSelector:@selector(taskOperation:updateError:isAtEnd:)
             withArguments:[NSArray arrayWithObjects:self, data, [NSNumber numberWithBool:atEnd], nil]];
}

-(void)handleOutputPipe:(NSNotification*)nfc
{
    /* parameters for taskOperation:updateOutput:isAtEnd: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateOutput:data isAtEnd:NO];
}

-(void)handleErrorPipe:(NSNotification*)nfc
{
    /* parameters for taskOperation:updateOutput:isAtEnd: */
    NSData  *data = [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem];
    [self updateError:data isAtEnd:NO];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"isFinished"]) {
        [self delegateSelector:@selector(taskOperationFinished:) withArguments:[NSArray arrayWithObject:self]];
    }
}

-(void)main
{
    /* register finished handler */
    [self addObserver:self forKeyPath:@"isFinished" options:0 context:nil];

    /* check for cancelation */
    if ([self isCancelled]) {
        NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                   code:NSUserCancelledError
                                               userInfo:[NSDictionary dictionary]];
        [self delegateSelector:@selector(taskOperation:handleError:)
                 withArguments:[NSArray arrayWithObjects:self, cancelError, nil]];
    }

    /* install standard error pipe */
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleErrorPipe:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[errPipe fileHandleForReading]];
    [[errPipe fileHandleForReading] readInBackgroundAndNotify];

    /* install progress meter */
    NSPipe *outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOutputPipe:)
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
        [self delegateSelector:@selector(taskOperation:handleError:)
                 withArguments:[NSArray arrayWithObjects:self, error, nil]];
        return;
    }

    [task waitUntilExit];

    [self delegateSelector:@selector(taskOperation:terminatedWithStatus:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithInt:[task terminationStatus]], nil]];

    /* read the remaining data from the output pipe */
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self updateOutput:[[outPipe fileHandleForReading] readDataToEndOfFile] isAtEnd:YES];
    [self updateError:[[errPipe fileHandleForReading] readDataToEndOfFile] isAtEnd:YES];
}

@end