//
//  LCSPlistTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperation.h"
#import "LCSTaskOperationError.h"


@implementation LCSPlistTaskOperation

-(id)initWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments extractKeyPath:(NSString*)keyPath
{
    self = [super initWithLaunchPath:path arguments:arguments];
    _outputData = [[NSMutableData alloc] init];
    extractKeyPath = [keyPath retain];
    return self;
}

-(id)initWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments
{
    return [self initWithLaunchPath:path arguments:arguments extractKeyPath:nil];
}

-(void)dealloc
{
    [_outputData release];
    [extractKeyPath release];
    _outputData = nil;
    [super dealloc];
}

-(void)updateStandardOutput:(NSData*)data
{
    [_outputData appendData:data];
    [super updateStandardOutput:data];
}

-(void)operationFinished
{
    if ([_outputData length] == 0) {
        return;
    }

    NSString *errorDescription;
    NSDictionary* result = [NSPropertyListSerialization propertyListFromData:_outputData
                                                            mutabilityOption:0
                                                                      format:nil
                                                            errorDescription:&errorDescription];

    if (result) {
        if (extractKeyPath) {
            result = [result valueForKeyPath:extractKeyPath];
        }
        [self handleResult:result];
    }
    else {
        NSError *error = [LCSTaskOperationError errorReceivedUnexpectedOutputFromLaunchPath:[task launchPath]
                                                                                    message:errorDescription];
        [self handleError:error];
    }

    [super operationFinished];
}

@end
