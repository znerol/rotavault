//
//  LCSOperationQueueOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationQueueOperation.h"
#import "LCSInitMacros.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"

@implementation LCSOperationQueueOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    queue = [[NSOperationQueue alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(queue);
    [queue setSuspended:YES];

    return self;
}

@synthesize queue;

-(void)setDelegate:(id)newDelegate
{
    [super setDelegate:newDelegate];
    for (LCSOperation* op in [queue operations]) {
        [op setDelegate:newDelegate];
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
    [super cancel];
    [queue cancelAllOperations];
}

-(void)execute
{
    [queue performSelector:@selector(setSuspended:) withObject:NO afterDelay:0];
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];
}
@end
