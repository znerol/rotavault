#import <Foundation/Foundation.h>
#import "LCSRotavaultScheduleInstallCommand.h"
#import "LCSCommandSignalHandler.h"


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* process command line arguments */
    NSUserDefaults *args = [[NSUserDefaults alloc] init];
    [args addSuiteNamed:NSArgumentDomain];

    /* alloc and run operation queue */
    NSString *sourcedev = [args stringForKey:@"sourcedev"];
    NSString *targetdev = [args stringForKey:@"targetdev"];
    NSDate *rundate = [NSDate dateWithTimeIntervalSinceNow:60];

    NSFileManager *fm = [[NSFileManager alloc] init];
    NSError *error;
    NSDictionary *fattrs;

    LCSRotavaultScheduleInstallCommand *cmd = [[LCSRotavaultScheduleInstallCommand alloc]
                                               initWithSourceDevice:sourcedev targetDevice:targetdev runAt:rundate];

    LCSCommandSignalHandler *handler = [[LCSCommandSignalHandler alloc] initWithCommand:cmd];

    error = [cmd execute];

    int status = 0;
    if (error) {
        status = 1;
    }

    [handler release];

    [pool drain];
    return status;
}
