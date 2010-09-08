#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSRotavaultCopyOperation.h"
#import "LCSCommandLineOperationRunner.h"
#import "LCSSimpleOperationParameter.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* process command line arguments */
    NSUserDefaults *args = [[[NSUserDefaults alloc] init] autorelease];
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
    LCSRotavaultCopyOperation *op = [[[LCSRotavaultCopyOperation alloc] init] autorelease];
    op.sourceDevice = [[LCSSimpleOperationInputParameter alloc] initWithValue:[args stringForKey:@"sourcedev"]];
    op.targetDevice = [[LCSSimpleOperationInputParameter alloc] initWithValue:[args stringForKey:@"targetdev"]];
    op.sourceChecksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:[args stringForKey:@"sourcecheck"]];
    op.targetChecksum = [[LCSSimpleOperationInputParameter alloc] initWithValue:[args stringForKey:@"targetcheck"]];
    
    NSError *error = [LCSCommandLineOperationRunner runOperation:op];

    int status = 0;
    if (error) {
        status = 1;
    }

    [pool drain];
    return status;
}
