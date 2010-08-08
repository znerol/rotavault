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

-(void)taskOperation:(LCSTaskOperation*)operation
        updateOutput:(NSData*)stdoutData
             isAtEnd:(NSNumber*)atEnd;

-(void)taskOperation:(LCSTaskOperation*)operation
         updateError:(NSData*)stderrData
             isAtEnd:(NSNumber*)atEnd;

-(void)taskOperation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status;

-(void)taskOperation:(LCSTaskOperation*)operation handleError:(NSError*)error;

-(void)taskOperation:(LCSTaskOperation*)operation updateStatusMessage:(NSString*)statusMessage;
-(void)taskOperation:(LCSTaskOperation*)operation updateProgress:(NSNumber*)newProgress;


@end
