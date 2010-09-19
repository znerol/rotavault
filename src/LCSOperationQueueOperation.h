//
//  LCSOperationQueueOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSOperationQueueOperation : LCSOperation {
    NSOperationQueue *queue;
}
@property(readonly) NSOperationQueue *queue;
@end
