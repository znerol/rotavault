//
//  LCSPlistTaskOutputHandler.m
//  rotavault
//
//  Created by Lorenz Schori on 03.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOutputHandler.h"


@implementation LCSPlistTaskOutputHandler
- (void) accumulateData:(NSNotification*)nfc
{
    [buffer appendData:
        [[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem]];
}

- (NSDictionary*) results
{
    return [NSPropertyListSerialization propertyListFromData:buffer
                                            mutabilityOption:0
                                                      format:nil
                                            errorDescription:nil];
}

- (LCSPlistTaskOutputHandler*) initWithTarget:(NSTask*) targetTask
{
    self = [super init];
    target = targetTask;

    buffer = [[NSMutableData alloc] init];
    pipe = [[NSPipe alloc] init];

    [[NSNotificationCenter defaultCenter]
        addObserver:self selector:@selector(accumulateData:)
        name:NSFileHandleReadCompletionNotification
        object:[pipe fileHandleForReading]];

    [target setStandardOutput:pipe];
    [[pipe fileHandleForReading] readInBackgroundAndNotify];

    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [buffer release];
    [pipe release];
    [super dealloc];
}

+ (NSDictionary*) resultsFromTerminatedTaskWithLaunchPath:(NSString *)path
                                                arguments:(NSArray *)arguments
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    [task setArguments:arguments];

    LCSPlistTaskOutputHandler* handler =
        [[LCSPlistTaskOutputHandler alloc] initWithTarget:task];
    [task launch];
    [task waitUntilExit];

    NSDictionary *results = [handler results];

    [handler release];    
    [task release];

    return results;
}

@end
