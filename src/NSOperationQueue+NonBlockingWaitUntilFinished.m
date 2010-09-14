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
    NSThread *targetThread;
    BOOL done;
    BOOL postedDone;
}
@property(assign,readonly) BOOL done;
@end

@implementation LCSNonBlockingWaitUntilFinishedDummyKVO
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    targetThread = [NSThread currentThread];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetThread);
    return self;
}

-(void)setDone
{
    done = YES;
}

-(void)signalDone
{
    if (postedDone) {
        return;
    }
    [self performSelector:@selector(setDone) onThread:targetThread withObject:nil waitUntilDone:NO];
    postedDone = YES;
}

@synthesize done;

-(void)wakeRunloop
{
    /* do nothing */
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    @synchronized(self) {
        [self performSelector:@selector(wakeRunloop) onThread:targetThread withObject:nil waitUntilDone:NO];
    }
}
@end


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{
    static NSString *filter =
        @"(isExecuting = YES AND isFinished = NO) OR (isExecuting = NO AND isFinished = NO AND isCancelled = NO)";
    NSPredicate *executingOperations = [NSPredicate predicateWithFormat:filter];
        
    /* track changes to our operations array */
    LCSNonBlockingWaitUntilFinishedDummyKVO *dummy = [[LCSNonBlockingWaitUntilFinishedDummyKVO alloc] init];
    
    NSMutableSet *observedOperations = [NSMutableSet set];
  
    while (!dummy.done) {
        NSArray *runningOperations;
        @synchronized(dummy) {
            runningOperations = [self.operations filteredArrayUsingPredicate:executingOperations];
            
            if ([runningOperations count] == 0) {
                [dummy signalDone];
            }
            else {
                /* check for new operations in the queue */
                NSMutableSet *newOperations = [NSMutableSet setWithArray:runningOperations];
                [newOperations minusSet:observedOperations];
                
                /*
                 * Observe relevant attributes of each operation in order to trigger a runloop-exit whenever one of those
                 * change.
                 */
                for (NSOperation *op in newOperations) {
                    [op addObserver:dummy forKeyPath:@"isReady" options:0 context:nil];
                    [op addObserver:dummy forKeyPath:@"isExecuting" options:0 context:nil];
                    [op addObserver:dummy forKeyPath:@"isCancelled" options:0 context:nil];
                    [op addObserver:dummy forKeyPath:@"isFinished" options:0 context:nil];
                }
                
                [observedOperations unionSet:newOperations];
            }
        }
        
        /*
         * Wait until some observation triggers the dummy handler
         */
        [[NSRunLoop currentRunLoop] runMode:runloopMode beforeDate:[NSDate distantFuture]];
    }

    @synchronized(dummy) {
        for (NSOperation *op in observedOperations) {
            [op removeObserver:dummy forKeyPath:@"isReady"];
            [op removeObserver:dummy forKeyPath:@"isExecuting"];            
            [op removeObserver:dummy forKeyPath:@"isCancelled"];
            [op removeObserver:dummy forKeyPath:@"isFinished"];
        }
    }
    
    [dummy release];
}    
@end
