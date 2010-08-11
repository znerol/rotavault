//
//  NSOperationQueue+NonBlockingWaitUntilFinished.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSOperationQueue (NonBlockingWaitUntilFinished)
-(void)waitUntilAllOperationsAreFinishedPollingRunLoopInMode:(NSString*)runloopMode;
@end
