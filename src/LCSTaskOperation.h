//
//  LCSTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"
#import "LCSOperationParameter.h"


@interface LCSTaskOperation : LCSOperation {
    NSTask  *task;
    NSPipe  *errPipe;
    NSPipe  *outPipe;
    BOOL    errEOF;
    BOOL    outEOF;
    
    id <LCSOperationInputParameter> launchPath;    /* NSString */
    id <LCSOperationInputParameter> arguments;     /* NSArray of NSString */
}

@property(retain) id <LCSOperationInputParameter> launchPath;
@property(retain) id <LCSOperationInputParameter> arguments;

-(void)updateStandardOutput:(NSData*)data;
-(void)updateStandardError:(NSData*)data;
-(void)taskTerminatedWithStatus:(int)status;

/* private interface. override in subclasses. */
-(void)taskOutputComplete;
-(void)taskBuildArguments;
@end

@protocol LCSTaskOperationDelegate <LCSOperationDelegate>
-(void)taskOperationLaunched:(LCSTaskOperation*)operation;
-(void)operation:(LCSTaskOperation*)operation updateStandardOutput:(NSData*)stdoutData;
-(void)operation:(LCSTaskOperation*)operation updateStandardError:(NSData*)stderrData;
-(void)operation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status;
@end
