#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSBlockCopyOperation.h"
#import "LCSDiskUtilOperation.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSTaskOperationError.h"
#import "LCSSignalHandler.h"
//#import "LCSNanosecondTimer.h"
#import "LCSVerifyDiskInfoChecksumOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"

@interface LCSRotavaultCopyCommand : NSObject
{
    NSOperationQueue* queue;
    NSError* originalError;
//    LCSNanosecondTimer *timer;
    NSMutableDictionary *context;
}
@end

@implementation LCSRotavaultCopyCommand
-(id)initWithSourceDevice:(NSString*)sourceDevice
              sourceCheck:(NSString*)sourceChecksum
             targetDevice:(NSString*)targetDevice
           targetChecksum:(NSString*)targetChecksum
{
    self = [super init];
    originalError = nil;

    /* setup operations */
    queue = [[NSOperationQueue alloc] init];
    [queue setSuspended:YES];

    context = [[NSMutableDictionary alloc] init];
    [context setValue:[NSNull null] forKey:@"sourceInfo"];
//    [context setValue:[NSNull null] forKey:@"sourceSize"];
    [context setValue:[NSNull null] forKey:@"targetInfo"];

    LCSInformationForDiskOperation *sourceInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    sourceInfoOperation.delegate = self;
    sourceInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    sourceInfoOperation.result =
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:context keyPath:@"sourceInfo"];
    [queue addOperation:sourceInfoOperation];

    LCSVerifyDiskInfoChecksumOperation *verifySourceInfoOperation =
        [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifySourceInfoOperation.delegate = self;
    verifySourceInfoOperation.diskinfo =
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:context keyPath:@"sourceInfo"];
    verifySourceInfoOperation.checksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceChecksum];
    [verifySourceInfoOperation addDependency:sourceInfoOperation];
    [queue addOperation:verifySourceInfoOperation];

    LCSInformationForDiskOperation *targetInfoOperation = [[[LCSInformationForDiskOperation alloc] init] autorelease];
    targetInfoOperation.delegate = self;
    targetInfoOperation.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    targetInfoOperation.result =
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:context keyPath:@"targetInfo"];
    [queue addOperation:targetInfoOperation];

    LCSVerifyDiskInfoChecksumOperation *verifyTargetInfoOperation =
        [[[LCSVerifyDiskInfoChecksumOperation alloc] init] autorelease];
    verifySourceInfoOperation.delegate = self;
    verifySourceInfoOperation.diskinfo =
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:context keyPath:@"targetInfo"];
    verifySourceInfoOperation.checksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetChecksum];
    [verifyTargetInfoOperation addDependency:targetInfoOperation];
    [queue addOperation:verifyTargetInfoOperation];

    LCSBlockCopyOperation *blockCopyOperation = [[[LCSBlockCopyOperation alloc] init] autorelease];
    blockCopyOperation.delegate = self;
    blockCopyOperation.source = [[LCSSimpleOperationInputParameter alloc] initWithValue:sourceDevice];
    blockCopyOperation.target = [[LCSSimpleOperationInputParameter alloc] initWithValue:targetDevice];
    [blockCopyOperation addDependency:verifySourceInfoOperation];
    [blockCopyOperation addDependency:verifyTargetInfoOperation];
    [queue addOperation:blockCopyOperation];

//    timer = [[LCSNanosecondTimer alloc] init];

    /* setup signal handler and signal pipe */
    LCSSignalHandler *sh = [LCSSignalHandler defaultSignalHandler];
    [sh setDelegate:self];
    [sh addSignal:SIGHUP];
    [sh addSignal:SIGINT];
    [sh addSignal:SIGPIPE];
    [sh addSignal:SIGALRM];
    [sh addSignal:SIGTERM];

    return self;
}

-(void)dealloc
{
    [queue release];
    
    if(originalError) {
        [originalError release];
    }
    [super dealloc];
}


-(void)operation:(LCSTaskOperation*)operation updateStandardError:(NSData*)data
{
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

-(void)handleSignal:(NSNumber*)signal
{
    [queue cancelAllOperations];
}

-(NSError*)execute
{
//    [timer setReferenceTime];

    [queue setSuspended:NO];
    [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];

    if(originalError)
    {
        /* try to mount the source volume */
        NSArray* remountArgs = [NSArray arrayWithObjects:@"mount", [context objectForKey:@"sourceDevice"], nil];
        [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:remountArgs] waitUntilExit];
        return originalError;
    }
    else {
        /*
        long double milliseconds = [timer nanosecondsSinceReferenceTime] / 1000000.;
        long double speed = UInt64ToLongDouble(srcsize) / milliseconds;

        NSLog(@"Duration of copy & verification of %d bytes took %.2Lf seconds (%.2Lf bytes/sec)",
              srcsize, milliseconds / 1000., speed * 1000.);
         */
        return nil;
    }
}
@end

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int status = 0;

    /* process command line arguments */
    NSUserDefaults *args = [[NSUserDefaults alloc] init];
    [args addSuiteNamed:NSArgumentDomain];

    BOOL debug = [args boolForKey:@"debug"];

    /* setup asl */
    aslmsg tmpl = asl_new(ASL_TYPE_MSG);
    asl_set(tmpl, ASL_KEY_FACILITY, "ch.znerol.rotavault.copy");
    asl_add_log_file(NULL, 2);

    if (debug == YES) {
        asl_set_filter(NULL, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    }

    /* FIXME: check / create pid file */
    // NSString *pidfile = [args stringForKey:@"pidfile"];
    
    /* alloc and run operation queue */
    NSString *sourcedev = [args stringForKey:@"sourcedev"];
    NSString *sourcecheck = [args stringForKey:@"sourcecheck"];
    NSString *targetdev = [args stringForKey:@"targetdev"];
    NSString *targetcheck = [args stringForKey:@"targetcheck"];

    LCSRotavaultCopyCommand *cmd = [[LCSRotavaultCopyCommand alloc] initWithSourceDevice:sourcedev
                                                                             sourceCheck:sourcecheck
                                                                            targetDevice:targetdev
                                                                          targetChecksum:targetcheck];

    NSError *error = [cmd execute];

    if (error) {
        status = 1;
    }

    [pool drain];
    return status;
}
