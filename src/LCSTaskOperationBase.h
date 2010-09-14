//
//  LCSTaskOperationBaseBase.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSTaskOperationBase : LCSOperation {
    NSTask  *task;
    NSPipe  *errPipe;
    NSPipe  *outPipe;
    BOOL    errEOF;
    BOOL    outEOF;
    NSThread *operationThread;
}

-(void)updateStandardOutput:(NSData*)data;
-(void)updateStandardError:(NSData*)data;
-(void)taskTerminatedWithStatus:(int)status;

/* private interface. override in subclasses. */
-(void)taskOutputComplete;
-(void)taskSetup;
@end

@protocol LCSTaskOperationDelegate <LCSOperationDelegate>
-(void)taskOperationLaunched:(LCSTaskOperationBase*)operation;
-(void)operation:(LCSTaskOperationBase*)operation updateStandardOutput:(NSData*)stdoutData;
-(void)operation:(LCSTaskOperationBase*)operation updateStandardError:(NSData*)stderrData;
-(void)operation:(LCSTaskOperationBase*)operation terminatedWithStatus:(NSNumber*)status;
@end
