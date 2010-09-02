//
//  LCSCommandLineOperationRunner.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommandLineOperationRunner.h"


@implementation LCSCommandLineOperationRunner

-(id)initWithOperation:(LCSOperation *)operation
{
    if (!(self = [super init])) {
        return nil;
    }

    _firstError = nil;
    _operation = [operation retain];
    _operation.delegate = self;

    if (!_operation) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [_firstError release];
    [_operation release];
    [super dealloc];
}

-(void)operation:(LCSOperation*)op handleError:(NSError*)error
{
    if (error != _firstError) {
        [_firstError release];
        _firstError = [error retain];
    }

    if (op != _operation) {
        [_operation cancel];
    }

    if ([error domain] == NSCocoaErrorDomain && [error code] == NSUserCancelledError) {
        return;
    }

    NSLog(@"ERROR: %@", [error localizedDescription]);
    [op cancel];
}

-(void)operation:(LCSOperation*)op updateProgress:(NSNumber*)progress
{
    NSLog(@"PROGR: %.2f", [progress floatValue]);
}

-(NSError*)run
{
    [_operation start];
    return _firstError;
}

+(NSError*)runOperation:(LCSOperation*)operation
{
    LCSCommandLineOperationRunner *runner =
        [[[LCSCommandLineOperationRunner alloc] initWithOperation:operation] autorelease];
    return [runner run];
}
@end
