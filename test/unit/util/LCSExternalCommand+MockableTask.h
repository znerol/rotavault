//
//  LCSExternalCommand+MockableTask.h
//  rotavault
//
//  Created by Lorenz Schori on 15.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


#define LCSTestExternalCommandTaskInitNotification @"LCSTestExternalCommandTaskInitNotification"

@interface LCSExternalCommand (MockableTask)
@property(retain) NSTask* task;
@end
