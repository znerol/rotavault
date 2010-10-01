//
//  LCSOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperation.h"
#import "LCSInitMacros.h"


@implementation LCSOperation

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    return self;
}

-(void)dealloc
{
    delegate = nil;
    delegateThread = nil;
    [super dealloc];
}

-(void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
    delegateThread = [NSThread currentThread];
}

-(id)delegate
{
    return delegate;
}

/* override */
-(void)updateProgress:(float)progress
{
    [self delegateSelector:@selector(operation:updateProgress:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithFloat:progress], nil]];
}

/* override */
-(void)handleError:(NSError*)error
{
    [self delegateSelector:@selector(operation:handleError:)
             withArguments:[NSArray arrayWithObjects:self, error, nil]];
}

/* override */
-(void)handleException:(NSException*)exception
{
    [self delegateSelector:@selector(operation:handleException:)
             withArguments:[NSArray arrayWithObjects:self, exception, nil]];
}

/* perform a selector on the delegate in main thread */
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
        [inv performSelector:@selector(invokeWithTarget:) onThread:delegateThread withObject:delegate waitUntilDone:YES];
    }
    @catch (NSException * e) {
        NSLog(@"Operation %@ failed to perform selector %@ on delegate %@: %@", [self description],
              NSStringFromSelector(selector), [delegate description], [e description]);
        if (selector == @selector(operation:handleException:)) {
            [self cancel];
        }
        else {
            [self handleException:e];
        }
    }
}

-(void)execute
{
    /* override */
}

-(void)main
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    @try {
        if (![self isCancelled]) {
            [self execute];
        }
    }
    @catch (NSException *e) {
        [self handleException:e];
    }
    @finally {
        [pool drain];
    }
}

-(void)cancel
{
    /* check for cancelation */
    if ([self isCancelled]) {
        return;
    }

    [super cancel];

    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                               code:NSUserCancelledError
                                           userInfo:[NSDictionary dictionary]];
    [self handleError:cancelError];
}
@end
