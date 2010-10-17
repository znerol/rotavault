//
//  LCSExternalCommand+MockableTask.m
//  rotavault
//
//  Created by Lorenz Schori on 15.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSExternalCommand+MockableTask.h"
#import "LCSInitMacros.h"


@implementation LCSExternalCommand (MockableTask)
-(id)init
{
    /* keep the implementation in sync with the implementation in LCSExternalCommand.m */
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    task = [[NSTask alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(task);
    
    /* 
     * Notify that we've just initialized the task to give the observer an opportunity to replace the task object with
     * a mock object.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:LCSTestExternalCommandTaskInitNotification
                                                        object:self];
    return self;
}

- (void)setTask:(NSTask*)newTask
{
    if (task == newTask) {
        return;
    }
    
    [task release];
    task = [newTask retain];
}

- (NSTask*)task
{
    return task;
}
@end
