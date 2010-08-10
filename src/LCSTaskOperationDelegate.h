//
//  LCSTaskOperationDelegate.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSTaskOperation.h"


@protocol LCSTaskOperationDelegate

-(void)taskOperation:(LCSTaskOperation*)operation updateStandardOutput:(NSData*)stdoutData;
-(void)taskOperation:(LCSTaskOperation*)operation updateStandardError:(NSData*)stderrData;
-(void)taskOperation:(LCSTaskOperation*)operation handleError:(NSError*)error;
-(void)taskOperation:(LCSTaskOperation*)operation handleResult:(id)result;
-(void)taskOperationPreparing:(LCSTaskOperation*)operation;
-(void)taskOperationLaunched:(LCSTaskOperation*)operation;
-(void)taskOperation:(LCSTaskOperation*)operation updateProgress:(NSNumber*)progress;
-(void)taskOperation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status;
-(void)taskOperationFinished:(LCSTaskOperation*)operation;
@end
