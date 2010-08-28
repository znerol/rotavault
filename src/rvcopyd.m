#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSBlockCopyOperation.h"
#import "LCSDiskUtilOperation.h"
#import "LCSVerifyDiskInfoChecksumOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"

@interface LCSRotavaultCopyCommand : LCSCommand
{
    NSMutableDictionary *context;
}
@end

@implementation LCSRotavaultCopyCommand
-(id)initWithSourceDevice:(NSString*)sourceDevice
              sourceCheck:(NSString*)sourceChecksum
             targetDevice:(NSString*)targetDevice
           targetChecksum:(NSString*)targetChecksum
{
    if(!(self = [super init])) {
        return nil;
    }

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

    return self;
}

-(void)dealloc
{
    [context release];
    [super dealloc];
}

-(NSError*)execute
{
    NSError *err = [super execute];

    if(err)
    {
        /* try to mount the source volume */
        NSArray* remountArgs = [NSArray arrayWithObjects:@"mount", [context objectForKey:@"sourceDevice"], nil];
        [[NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:remountArgs] waitUntilExit];
    }

    return err;
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
