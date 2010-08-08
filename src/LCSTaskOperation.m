//
//  LCSTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperation.h"


@implementation LCSTaskOperation

@synthesize path;
@synthesize output;
@synthesize error;

-(id)initWithLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments
{
    self = [super init];
    task = [[NSTask alloc] init];
    output = [[NSData alloc] init];
    error = nil;
    path = [launchPath retain];
    [task setLaunchPath:path];
    [task setArguments:arguments];
    return self;
}

-(void)dealloc
{
    if (error) {
        [error release];
    }

    [output release];
    [path release];
    [task release];
    [super dealloc];
}

-(BOOL)hasProgress
{
    return NO;
}

-(float)progress
{
    return -1.0;
}

-(void)terminateWithError:(NSError*)inError
{
    if ([task isRunning]) {
        [task interrupt];
    }
    if (error == nil) {
        error = [inError retain];
    }
}

-(BOOL)cancelIfRequested
{
    if ([self isCancelled]) {
        [self terminateWithError:[NSError errorWithDomain:NSCocoaErrorDomain
                                                     code:NSUserCancelledError
                                                 userInfo:[NSDictionary dictionary]]];
        return YES;
    }
    else {
        return NO;
    }
}

-(void)cancel
{
    [super cancel];
    [self cancelIfRequested];
}

-(BOOL)parseOutput:(NSData*)data isAtEnd:(BOOL)atEnd error:(NSError**)outError
{
    NSMutableData *tmp = [NSMutableData dataWithData:output];
    [output release];
    [tmp appendData:data];
    output = [[NSData alloc] initWithData:tmp];
    return YES;
}

-(void)updateOutput:(NSNotification*)nfc
{
    if ([self cancelIfRequested]) {
        return;
    }

    NSError *parseError;
    BOOL ok = [self parseOutput:[[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem]
                        isAtEnd:NO error:&parseError];
    if (!ok) {
        [self terminateWithError:parseError];
    }
}

-(void)main
{
    /* check for cancelation */
    if ([self cancelIfRequested]) {
        return;
    }

    /* install standard error pipe */
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];

    /* install progress meter */
    NSPipe *outPipe = [NSPipe pipe];
    [task setStandardOutput:outPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOutput:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[outPipe fileHandleForReading]];
    [[outPipe fileHandleForReading] readInBackgroundAndNotify];

    /* 
     * launch the task, process output and wait until its finished or canceled. Because we're inside an NSOperation
     * we *must* catch any exception!
     */
    @try {
        [task launch];
    }
    @catch (NSException *e) {
        NSError* err = [LCSTaskOperationError errorExecutionOfPathFailed:path message:[e reason]];
        [self terminateWithError:err];
        return;
    }

    [task waitUntilExit];

    /* read the remaining data from the output pipe */
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSData* rest=[[outPipe fileHandleForReading] readDataToEndOfFile];

    NSError *parseError = nil;
    BOOL ok = [self parseOutput:rest isAtEnd:YES error:&parseError];
    if (!ok) {
        [self terminateWithError:parseError];
        return;
    }

    /* check if the process was canceled */    
    if ([self cancelIfRequested]) {
        return;
    }
    /* otherwise check the termination status and prepare error message if required */
    else {
        int status = [task terminationStatus];
        if (status != 0) {
            NSString *message = [[NSString alloc] initWithData:[[errPipe fileHandleForReading] availableData]
                                                      encoding:NSUTF8StringEncoding];

            [self terminateWithError:[LCSTaskOperationError errorWithLaunchPath:path status:status message:message]];
        }
    }
}

@end
