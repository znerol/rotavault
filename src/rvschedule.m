#import <Foundation/Foundation.h>
#import "LCSRotavaultScheduleInstallOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSCommandLineOperationRunner.h"


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* process command line arguments */
    NSUserDefaults *args = [[NSUserDefaults alloc] init];
    [args addSuiteNamed:NSArgumentDomain];

    /* alloc and run operation queue */
    NSString *sourcedev = [args stringForKey:@"sourcedev"];
    NSString *targetdev = [args stringForKey:@"targetdev"];
    NSDate *rundate = [NSDate dateWithTimeIntervalSinceNow:60];

    NSError *error;

    LCSRotavaultScheduleInstallOperation *op = [[LCSRotavaultScheduleInstallOperation alloc] init];
    op.runAtDate = [LCSSimpleOperationInputParameter parameterWithValue:rundate];
    op.sourceDevice = [LCSSimpleOperationInputParameter parameterWithValue:sourcedev];
    op.targetDevice = [LCSSimpleOperationInputParameter parameterWithValue:targetdev];

    error = [LCSCommandLineOperationRunner runOperation:op];

    int status = 0;
    if (error) {
        status = 1;
    }

    [op release];
    [pool drain];
    return status;
}
