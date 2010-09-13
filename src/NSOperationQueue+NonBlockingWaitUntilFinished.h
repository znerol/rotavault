//
//  NSOperationQueue+NonBlockingWaitUntilFinished.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOperationQueue (NonBlockingWaitUntilFinished)
/**
 *
 *  Wait until all operations in the queue have finished ore have been cancelled.
 *  
 *  isReady isExecuting isFinished isCancelled  Action
 *    0         0           0         0         wait
 *    0         0           0         1         don't wait
 *    0         0           1         0         don't wait
 *    0         0           1         1         don't wait
 *    0         1           0         0         wait
 *    0         1           0         1         wait
 *    0         1           1         0         wait (inconsistent)
 *    0         1           1         1         wait (inconsistent)
 *    1         0           0         0         wait
 *    1         0           0         1         don't wait
 *    1         0           1         0         wait (inconsistent)
 *    1         0           1         1         wait (inconsistent)
 *    1         1           0         0         wait (inconsistent)
 *    1         1           0         1         wait (inconsistent)
 *    1         1           1         0         wait (inconsistent)
 *    1         1           1         1         wait (inconsistent)
 */
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode;
@end
