//
//  NSOperationQueue+NonBlockingWaitUntilFinished.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{
    NSPredicate *isFinished = [NSPredicate predicateWithFormat:@"isFinished = NO AND isCancelled = NO"];
    while ([[[self operations] filteredArrayUsingPredicate:isFinished] count] > 0) {
        /* FXME: runloop needs signal */
        [[NSRunLoop currentRunLoop] runMode:runloopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}    
@end
