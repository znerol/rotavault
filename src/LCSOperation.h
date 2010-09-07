//
//  LCSOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationError.h"
#import "LCSOperationParameter.h"

typedef enum {
    LCSParameterIn      = 1,
    LCSParameterOut     = 2
} LCSParameterDirection;

@interface LCSOperation : NSOperation {
    id              delegate;
}

@property(assign) id delegate;

-(void)handleError:(NSError*)error;
@end

/* private methods overridden by subclasses */
@interface LCSOperation (SubclassOverride)
-(void)execute;
@end

/* Private methods used by subclasses */
@interface LCSOperation (SubclassUse)
-(void)delegateSelector:(SEL)selector withArguments:(NSArray*)arguments;
-(void)updateProgress:(float)progress;
@end

/* methods optionally implemented by the delegate */
@protocol LCSOperationDelegate
-(void)operation:(LCSOperation*)operation handleError:(NSError*)error;
-(void)operation:(LCSOperation*)operation updateProgress:(NSNumber*)progress;
@end
