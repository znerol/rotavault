//
//  LCSCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 28.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSCommand : NSObject
{
    NSOperationQueue*   queue;
    NSError*            originalError;
    NSMutableData*      stderrData;
}
@property(readonly) NSOperationQueue* queue;
-(void)cancel;
-(void)operation:(LCSOperation*)operation handleError:(NSError*)error;
-(NSError*)execute;
@end
