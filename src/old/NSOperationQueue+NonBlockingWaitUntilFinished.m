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
}
@end

@implementation LCSNonBlockingWaitUntilFinishedDummyKVO
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    targetThread = [NSThread currentThread];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetThread);
    return self;
}

-(void)wakeRunloop
{
    /* do nothing */
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self performSelector:@selector(wakeRunloop) onThread:targetThread withObject:nil waitUntilDone:NO];
}
@end


@implementation NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode
{
    /* track changes to our operations array */
    LCSNonBlockingWaitUntilFinishedDummyKVO *dummy = [[LCSNonBlockingWaitUntilFinishedDummyKVO alloc] init];
    [self addObserver:dummy forKeyPath:@"operations" options:0 context:nil];
    
    NSPredicate *runningOperations =
        [NSPredicate predicateWithFormat:@"isExecuting = YES OR isFinished = YES OR isCancelled = NO"];
    
    while ([[self.operations filteredArrayUsingPredicate:runningOperations] count] > 0) {
        /*
         * Wait until some modification of the operations array triggers the dummy handler
         */
        [[NSRunLoop currentRunLoop] runMode:runloopMode beforeDate:[NSDate distantFuture]];
    }
    
    [self removeObserver:dummy forKeyPath:@"operations"];
    [dummy release];
}    
@end
