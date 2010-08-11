//
//  LCSTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSTaskOperation : LCSOperation {
    NSTask  *task;
    NSPipe  *errPipe;
    NSPipe  *outPipe;
    BOOL    errEOF;
    BOOL    outEOF;
}

-(id)initWithLaunchPath:(NSString*)path arguments:(NSArray*)arguments;

-(void)updateStandardOutput:(NSData*)data;
-(void)updateStandardError:(NSData*)data;
-(void)taskTerminatedWithStatus:(int)status;
@end
