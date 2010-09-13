//
//  NSOperationQueue+NonBlockingWaitUntilFinished.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"
#import "LCSInitMacros.h"

@interface LCSNonBlockingWaitUntilFinishedDummyKVO : NSObject {
    NSThread *target;
}
@end

@implementation LCSNonBlockingWaitUntilFinishedDummyKVO
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    target = [NSThread currentThread];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(target);
    return self;
}

-(void)wakeRunloop
{
    /* do nothing */
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelector:@selector(wakeRunloop) onThread:target withObject:nil waitUntilDone:YES];
}
@end


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{

    static NSString *filter = @"NOT ("
        @"(isReady = NO AND isExecuting = NO AND (isFinished = YES OR isCancelled = YES)) OR "
        @"(isReady = YES AND isExecuting = NO AND isFinished = NO AND isCancelled = YES))";
    
    LCSNonBlockingWaitUntilFinishedDummyKVO *dummy = [[LCSNonBlockingWaitUntilFinishedDummyKVO alloc] init];
    
    /* FIXME: we definitely have a race condition around here */
    usleep(100000);

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
