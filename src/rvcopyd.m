#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSRotavaultCopyCommand.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

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

    int status = 0;
    if (error) {
        status = 1;
    }

    [pool drain];
    return status;
}
