//
//  LCSCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 28.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommand.h"
#import "LCSOperation.h"
#import "LCSTaskOperation.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSTaskOperationError.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"


@implementation LCSCommand
-(id)init
{
    if(!(self = [super init])) {
        return nil;
    }

    originalError = nil;

    /* collected stuff from stderr */
    stderrData = [[NSMutableData alloc] init];

    /* setup operations */
    queue = [[NSOperationQueue alloc] init];
    [queue setSuspended:YES];

    if (stderrData == nil || queue == nil) {
        [self release];
        return nil;
    }

    return self;
}

-(void)dealloc
{
    [queue release];
    [originalError release];
    [stderrData release];
    [super dealloc];
}

@synthesize queue;

-(void)operation:(LCSTaskOperation*)operation updateStandardError:(NSData*)data
{
    [stderrData appendData:data];
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)error
{
    if(!originalError) {
        originalError = [error retain];
    }

    if ([error domain] == NSCocoaErrorDomain && [error code] == NSUserCancelledError) {
        return;
    }

    NSLog(@"ERROR: %@", [error localizedDescription]);
    [queue cancelAllOperations];
}

-(void)operation:(LCSOperation*)operation updateProgress:(NSNumber*)progress
{
}

-(void)operation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status
{
    if([status intValue] == 0) {
        return;
    }
    NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain
                                         code:LCSExecutableReturnedNonZeroStatus
                                     userInfo:[NSDictionary dictionary]];
    /*
     * it is save to call back into the operation because we block the operation thread when calling delegate methods!
     */
    [operation handleError:error];
}

-(void)cancel
{
    [queue cancelAllOperations];
}

-(NSError*)execute
{
    //    [timer setReferenceTime];
    
    [queue setSuspended:NO];
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];
    
        /*
         long double milliseconds = [timer nanosecondsSinceReferenceTime] / 1000000.;
         long double speed = UInt64ToLongDouble(srcsize) / milliseconds;
         
         NSLog(@"Duration of copy & verification of %d bytes took %.2Lf seconds (%.2Lf bytes/sec)",
         srcsize, milliseconds / 1000., speed * 1000.);
         */
    return originalError;
}
@end
