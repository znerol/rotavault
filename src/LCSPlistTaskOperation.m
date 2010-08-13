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

@synthesize result;
@synthesize extractKeyPath;

-(id)init
{
    self = [super init];
    _outputData = [[NSMutableData alloc] init];
    extractKeyPath = [[NSNull null] retain];
    result = [[NSNull null] retain];
    return self;
}

-(void)dealloc
{
    [_outputData release];
    [extractKeyPath release];
    [result release];
    [super dealloc];
}

-(void)updateStandardOutput:(NSData*)data
{
    [_outputData appendData:data];
    [super updateStandardOutput:data];
}

-(void)taskOutputComplete
{
    if ([_outputData length] == 0) {
        return;
    }

    NSString *errorDescription;
    NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:_outputData
                                                            mutabilityOption:0
                                                                      format:nil
                                                            errorDescription:&errorDescription];

    if (plist) {
        if (![extractKeyPath isKindOfClass:[NSNull class]]) {
            plist = [plist valueForKeyPath:extractKeyPath];
        }
        result = [plist retain];
    }
    else {
        NSError *error = [LCSTaskOperationError errorReceivedUnexpectedOutputFromLaunchPath:[task launchPath]
                                                                                    message:errorDescription];
        [self handleError:error];
    }

    [super taskOutputComplete];
}

@end
