//
//  LCSBatchCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSCommandRunner.h"
#import "LCSCommandControllerCollection.h"


@interface LCSBatchCommand : NSObject <LCSCommand>
{
    LCSCommandController* controller;
    
    LCSCommandControllerCollection* activeControllers;
}
@end


@interface LCSBatchCommand (SubclassOverrides)
-(void)invalidate;
-(void)handleError:(NSError*)error;
-(void)commandCollectionFailed:(NSNotification*)ntf;
-(void)commandCollectionCancelled:(NSNotification*)ntf;
-(void)commandCollectionInvalidated:(NSNotification*)ntf;
@end