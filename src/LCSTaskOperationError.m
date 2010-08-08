//
//  LCSTaskOperationError.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperationError.h"
#import "LCSRotavaultErrorDomain.h"

NSString* LCSExecutableReturnStatus   = @"ch.znerol.rotavault.LCSExecutableReturnStatus";
NSString* LCSExecutableErrorString    = @"ch.znerol.rotavault.LCSExecutableErrorString";

@implementation LCSTaskOperationError
-(id)initWithLaunchPath:(NSString*)path status:(NSInteger)status message:(NSString*)message
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, NSLocalizedFailureReasonErrorKey,
                              [NSString localizedStringWithFormat:@"The unix command %1$@ failed with status code %2$d",
                                                                    path, status], NSLocalizedDescriptionKey,
                              [NSNumber numberWithInt:status], LCSExecutableReturnStatus,
                              path, NSFilePathErrorKey, nil];

    self = [super initWithDomain:LCSRotavaultErrorDomain code:LCSExecutableReturnedNonZeroStatus userInfo:userInfo];
    return self;
}

-(id)initExecutionOfPathFailed:(NSString*)path message:(NSString*)message
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, NSLocalizedFailureReasonErrorKey,
                              [NSString localizedStringWithFormat:@"Failed to launch command %1$@\n%2$@",
                                                                    path, message], NSLocalizedDescriptionKey,
                              path, NSFilePathErrorKey, nil];

    self = [super initWithDomain:LCSRotavaultErrorDomain code:LCSLaunchOfExecutableFailed userInfo:userInfo];
    return self;
}

-(id)initReceivedUnexpectedOutputFromLaunchPath:(NSString*)path message:(NSString*)message
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, NSLocalizedFailureReasonErrorKey,
                              [NSString localizedStringWithFormat:@"Failed to interpret output from %1$@\n%2$@",
                                                                    path, message], NSLocalizedDescriptionKey,
                              path, NSFilePathErrorKey, nil];

    self = [super initWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedOutputReceived userInfo:userInfo];
    return self;
}

+(id)errorWithLaunchPath:(NSString*)path status:(NSInteger)status message:(NSString*)message;
{
    return [[[LCSTaskOperationError alloc] initWithLaunchPath:path status:status message:message] autorelease];
}

+(id)errorExecutionOfPathFailed:(NSString*)path message:(NSString*)message
{
    return [[[LCSTaskOperationError alloc] initExecutionOfPathFailed:path message:message] autorelease];
}

+(id)errorReceivedUnexpectedOutputFromLaunchPath:(NSString*)path message:(NSString*)message
{
    return [[[LCSTaskOperationError alloc] initReceivedUnexpectedOutputFromLaunchPath:path message:message] autorelease];
}
@end