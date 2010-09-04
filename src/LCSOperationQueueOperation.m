//
//  LCSOperationQueueOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationQueueOperation.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"


@implementation LCSOperationQueueOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }

    queue = [[NSOperationQueue alloc] init];
    [queue setSuspended:YES];
    
    if (!queue) {
        [self release];
        return nil;
    }
    return self;
}

-(void)setDelegate:(id)newDelegate
{
    delegate = newDelegate;
    for (LCSOperation* op in [queue operations]) {
        op.delegate = newDelegate;
    }
}

-(void)dealloc
{
    [queue release];
    [super dealloc];
}

-(void)cancel
{
    [queue setSuspended:YES];
    [queue cancelAllOperations];
    [super cancel];
}

-(void)execute
{
    [queue setSuspended:NO];
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];
}
@end
