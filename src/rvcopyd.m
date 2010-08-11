#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSBlockCopyOperation.h"
#import "LCSDiskUtilOperation.h"
#import "NSOperationQueue+NonBlockingWaitUntilFinished.h"
#import "LCSTaskOperationDelegate.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSTaskOperationError.h"
#import "LCSSignalHandler.h"

@interface LCSRotavaultCopyCommand : NSObject
{
    NSString* source;
    NSString* target;
    NSString* srccksum;
    NSString* tgtcksum;
    LCSInformationForDiskOperation *sourceInfoOperation;
    LCSInformationForDiskOperation *targetInfoOperation;
    LCSBlockCopyOperation *blockCopyOperation;
    NSOperationQueue* queue;
    NSError* originalError;
}
@end

@implementation LCSRotavaultCopyCommand
-(id)initWithSourceDevice:(NSString*)sourceDevice
              sourceCheck:(NSString*)sourceChecksum
             targetDevice:(NSString*)targetDevice
           targetChecksum:(NSString*)targetChecksum
{
    self = [super init];

    source = [sourceDevice retain];
    target = [targetDevice retain];
    srccksum = [sourceChecksum retain];
    tgtcksum = [targetChecksum retain];

    originalError = nil;

    sourceInfoOperation = [[LCSInformationForDiskOperation alloc] initWithDiskIdentifier:source];
    [sourceInfoOperation setDelegate:self];
    targetInfoOperation = [[LCSInformationForDiskOperation alloc] initWithDiskIdentifier:target];
    [targetInfoOperation setDelegate:self];    
    blockCopyOperation = [[LCSBlockCopyOperation alloc] initWithSourceDevice:source targetDevice:target];    
    [blockCopyOperation setDelegate:self];

    queue = [[NSOperationQueue alloc] init];

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
    [source release];
    [target release];
    [srccksum release];
    [tgtcksum release];
    [sourceInfoOperation release];
    [targetInfoOperation release];
    [blockCopyOperation release];
    [queue release];
    
    if(originalError) {
        [originalError release];
    }
    [super dealloc];
}

-(void)taskOperation:(LCSTaskOperation*)operation updateStandardError:(NSData*)data
{
    // [[stderrData objectForKey:operation] appendData:data];
}

-(void)taskOperation:(LCSTaskOperation*)operation handleError:(NSError*)error
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

-(void)taskOperation:(LCSTaskOperation*)operation handleResult:(id)result
{
    if(operation == sourceInfoOperation) {
    }
    else if(operation == targetInfoOperation) {
    }
    else {
        // FIXME: unexpected result
    }
}

-(void)taskOperation:(LCSTaskOperation*)operation updateProgress:(NSNumber*)progress
{
    if(operation == blockCopyOperation) {
        
    }
    else {
        // FIXME: unexpected
    }
}

-(void)taskOperation:(LCSTaskOperation*)operation terminatedWithStatus:(NSNumber*)status
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

-(void)taskOperationFinished:(LCSTaskOperation*)operation
{
    /* 
     * FIXME: we need to respond to this selector, otherwise the runloop will not return after the last operation
     * terminated.
     */
}

-(void)handleSignal:(NSNumber*)signal
{
    [queue cancelAllOperations];
}

-(NSError*)execute
{
    /* This is not a loop! */
    do {
        [queue addOperation:sourceInfoOperation];
        [queue addOperation:targetInfoOperation];

        /* from NSOperationQueue+NonBlockingWaitUntilFinished.h */
        [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];

        if(originalError) break;

        [queue addOperation:blockCopyOperation];
        [queue waitUntilAllOperationsAreFinishedPollingRunLoopInMode:NSDefaultRunLoopMode];

        if(originalError) break;
        
        return nil;
    }
    while(0);

    /* try to mount the source volume */
    NSArray* remountArgs = [NSArray arrayWithObjects:@"mount", source, nil];
    [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:remountArgs] waitUntilExit];
    return originalError;
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
