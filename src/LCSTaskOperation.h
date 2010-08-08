//
//  LCSTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSTaskOperationError.h"


@interface LCSTaskOperation : NSOperation {
    NSTask          *task;
    id              delegate;
}

-(id)initWithLaunchPath:(NSString*)path arguments:(NSArray*)arguments;
-(void)setDelegate:(id)newDelegate;

@end
