//
//  LCSOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperation.h"
#import "LCSOperationPrivate.h"

@implementation LCSOperation

-(id)init
{
    self = [super init];
    delegate = nil;
    name = [[NSNull null] retain];
    environmentContext = [[NSNull null] retain];
    parameterContext = [[NSNull null] retain];
    resultContext = [[NSNull null] retain];
    environmentKeyPath = [[NSNull null] retain];
    parameterKeyPath = [[NSNull null] retain];
    resultKeyPath = [[NSNull null] retain];
    return self;
}

-(void)dealloc
{
    [name release];
    [environmentContext release];
    [parameterContext release];
    [resultContext release];
    [environmentKeyPath release];
    [parameterKeyPath release];
    [resultKeyPath release];
    [super dealloc];
}

@synthesize name;
@synthesize delegate;
@synthesize environmentContext;
@synthesize parameterContext;
@synthesize resultContext;
@synthesize environmentKeyPath;
@synthesize parameterKeyPath;
@synthesize resultKeyPath;

-(void)operationStarted
{
    [self delegateSelector:@selector(operationStarted:) withArguments:[NSArray arrayWithObject:self]];
}

-(void)updateProgress:(float)progress
{
    [self delegateSelector:@selector(operation:updateProgress:)
             withArguments:[NSArray arrayWithObjects:self, [NSNumber numberWithFloat:progress], nil]];
}

-(void)operationFinished
{
    [self delegateSelector:@selector(operationFinished:) withArguments:[NSArray arrayWithObject:self]];
}

-(void)handleError:(NSError*)error
{
    [self delegateSelector:@selector(operation:handleError:)
             withArguments:[NSArray arrayWithObjects:self, error, nil]];
}

-(void)handleResult:(id)result
{
    if (resultContext != [NSNull null] && resultKeyPath != [NSNull null]) {
        [resultContext setValue:result forKeyPath:resultKeyPath];
    }

    [self delegateSelector:@selector(operation:handleResult:)
             withArguments:[NSArray arrayWithObjects:self, result, nil]];
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
        NSLog(@"Failed to perform delegate method: %@", [e description]);
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

-(void)prepareMain
{
    /* check for cancelation */
    if ([self isCancelled]) {
        NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                   code:NSUserCancelledError
                                               userInfo:[NSDictionary dictionary]];
        [self handleError:cancelError];
    }

    /* notify delegate that we're preparing for launch now */
    [self operationStarted];

    /* register finished handler */
    [self addObserver:self forKeyPath:@"isFinished" options:0 context:nil];    
}

-(void)cancel
{
    NSError *cancelError = [NSError errorWithDomain:NSCocoaErrorDomain
                                               code:NSUserCancelledError
                                           userInfo:[NSDictionary dictionary]];
    [self handleError:cancelError];
    [super cancel];
}
@end
