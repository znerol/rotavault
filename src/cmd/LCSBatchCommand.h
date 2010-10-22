//
//  LCSBatchCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandCollection.h"


@interface LCSBatchCommand : LCSCommand
{
    LCSCommandCollection* activeControllers;
}
@end


@interface LCSBatchCommand (SubclassOverrides)
-(void)invalidate;
-(void)handleError:(NSError*)error;
-(void)commandCollectionFailed:(NSNotification*)ntf;
-(void)commandCollectionCancelled:(NSNotification*)ntf;
-(void)commandCollectionInvalidated:(NSNotification*)ntf;
@end
