//
//  LCSTaskOperationError.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    LCSExecutableReturnedNonZeroStatus  = 1,
    LCSLaunchOfExecutableFailed         = 2,
    LCSUnexpectedOutputReceived         = 3
};

extern NSString* LCSExecutableReturnStatus;
extern NSString* LCSExecutableErrorString;

@interface LCSTaskOperationError : NSError {
    
}

-(id)initWithLaunchPath:(NSString*)path status:(NSInteger)status;
-(id)initExecutionOfPathFailed:(NSString*)path message:(NSString*)message;
-(id)initReceivedUnexpectedOutputFromLaunchPath:(NSString*)path message:(NSString*)message;

+(id)errorWithLaunchPath:(NSString*)path status:(NSInteger)status;
+(id)errorExecutionOfPathFailed:(NSString*)path message:(NSString*)message;
+(id)errorReceivedUnexpectedOutputFromLaunchPath:(NSString*)path message:(NSString*)message;

@end
