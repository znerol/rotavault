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
    NSTask  *task;
    NSPipe  *errPipe;
    NSPipe  *outPipe;
    BOOL    errEOF;
    BOOL    outEOF;
    id      delegate;
}

-(id)initWithLaunchPath:(NSString*)path arguments:(NSArray*)arguments;
-(void)setDelegate:(id)newDelegate;

-(void)updateStandardOutput:(NSData*)data;
-(void)updateStandardError:(NSData*)data;
-(void)handleError:(NSError*)error;
-(void)handleResult:(id)result;
-(void)taskPreparingToLaunch;
-(void)taskLaunched;
-(void)updateProgress:(float)progress;
-(void)taskTerminatedWithStatus:(int)status;
-(void)operationFinished;
@end
