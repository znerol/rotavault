//
//  NSOperationQueue+NonBlockingWaitUntilFinished.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"

@interface LCSNonBlockingWaitUntilFinishedDummyKVO : NSObject
@end

@implementation LCSNonBlockingWaitUntilFinishedDummyKVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    /* noop */
}
@end


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{

    static NSString *filter = @"NOT ("
        @"(isReady = NO AND isExecuting = NO AND (isFinished = YES OR isCancelled = YES)) OR "
        @"(isReady = YES AND isExecuting = NO AND isFinished = NO AND isCancelled = YES))";
    
    
    LCSNonBlockingWaitUntilFinishedDummyKVO *dummy = [[LCSNonBlockingWaitUntilFinishedDummyKVO alloc] init];
    NSPredicate *executingOperations = [NSPredicate predicateWithFormat:filter];
    NSMutableSet *hasObservers = [NSMutableSet set];
    
    while ([[self.operations filteredArrayUsingPredicate:executingOperations] count] > 0) {
        /*
         * Observe relevant attributes of each operation in order to trigger a runloop-exit whenever one of those
         * change.
         */
        
        for (NSOperation *op in self.operations) {
            if ([hasObservers containsObject:op]) {
                [op removeObserver:dummy forKeyPath:@"isReady"];
                [op removeObserver:dummy forKeyPath:@"isExecuting"];            
                [op removeObserver:dummy forKeyPath:@"isCancelled"];
                [op removeObserver:dummy forKeyPath:@"isFinished"];
            }
            [op addObserver:dummy forKeyPath:@"isReady" options:0 context:nil];
            [op addObserver:dummy forKeyPath:@"isExecuting" options:0 context:nil];
            [op addObserver:dummy forKeyPath:@"isCancelled" options:0 context:nil];
            [op addObserver:dummy forKeyPath:@"isFinished" options:0 context:nil];
            [hasObservers addObject:op];
        }
        
        /*
         * Wait until some observation triggers the dummy handler
         */
        [[NSRunLoop currentRunLoop] runMode:runloopMode beforeDate:[NSDate distantFuture]];
    }
    
    /* cleanup */
    for (NSOperation *op in self.operations) {
        if ([hasObservers containsObject:op]) {
            [op removeObserver:dummy forKeyPath:@"isReady"];
            [op removeObserver:dummy forKeyPath:@"isExecuting"];            
            [op removeObserver:dummy forKeyPath:@"isCancelled"];
            [op removeObserver:dummy forKeyPath:@"isFinished"];
        }
        [hasObservers removeObject:op];
    }
    [hasObservers removeAllObjects];
    [dummy release];
}    
@end
