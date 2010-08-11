//
//  LCSTaskOperationDelegate.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@protocol LCSTaskOperationDelegate

-(void)operation:(LCSTaskOperation*)operation updateStandardOutput:(NSData*)stdoutData;
-(void)operation:(LCSTaskOperation*)operation updateStandardError:(NSData*)stderrData;
-(void)operation:(LCSTaskOperation*)operation handleError:(NSError*)error;
-(void)operation:(LCSTaskOperation*)operation handleResult:(id)result;
-(void)operationStarted:(LCSTaskOperation*)operation;
-(void)taskOperationLaunched:(LCSTaskOperation*)operation;
-(void)operation:(LCSTaskOperation*)operation updateProgress:(NSNumber*)progress;
-(void)operation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status;
-(void)operationFinished:(LCSTaskOperation*)operation;
@end
