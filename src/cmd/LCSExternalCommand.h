//
//  LCSExternalCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandTemp.h"


@interface LCSExternalCommand : NSObject <LCSCommandTemp> {
    LCSCommandController *controller;
    NSTask *task;

}
@property(readonly,retain) NSTask *task;
@end

@interface LCSExternalCommand (SubclassOverrides)
-(void)invalidate;
-(void)handleTaskTermination;
-(void)handleError:(NSError *)error;
@end
