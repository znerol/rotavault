//
//  NSOperationQueue+NonBlockingWaitUntilFinished.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
/**
 *
 *  Wait for until all operations in the queue have finished ore have been cancelled.
 *  
 *  isReady isExecuting isFinished isCanceled Action
 *    0         0           0         0       wait
 *    0         0           0         1       don't wait
 *    0         0           1         0       don't wait
 *    0         0           1         1       don't wait
 *    0         1           0         0       wait
 *    0         1           0         1       wait
 *    1         0           0         0       wait
 *    1         0           0         1       don't wait
 */
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{
    NSPredicate *executingOperations = [NSPredicate predicateWithFormat:
                                        @"isExecuting = YES OR (isCancelled = NO AND isFinished = NO)"];
    while ([[[self operations] filteredArrayUsingPredicate:executingOperations] count] > 0) {
        /* FXME: runloop needs signal */
        [[NSRunLoop currentRunLoop] runMode:runloopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}    
@end
