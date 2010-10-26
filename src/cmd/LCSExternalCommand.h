//
//  LCSExternalCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSExternalCommand : LCSCommand {
    NSTask *task;
@private
    BOOL    taskTerminated;
}
@property(readonly,retain) NSTask *task;
@end

@interface LCSExternalCommand (SublcassInterface)
-(void)handleError:(NSError *)error;
-(void)completeIfDone;
@end

@interface LCSExternalCommand (SubclassOverrides)
-(void)invalidate;
-(void)handleTaskStarted;
-(BOOL)done;
-(void)collectResults;
@end
