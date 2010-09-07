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
    delegate = nil;
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

@synthesize delegate;

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
        [inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:delegate waitUntilDone:YES];
    }
    @catch (NSException * e) {
        NSLog(@"Failed to perform delegate method: %@", [e description]);
    }
}

-(void)execute
{
    /* override */
}

-(void)main
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* check for cancelation */
    if ([self isCancelled]) {
        return;
    }

    /* perform operation */
    [self execute];

    [pool drain];
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
