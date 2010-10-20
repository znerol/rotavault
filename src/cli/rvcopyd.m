#include <asl.h>
#import <Foundation/Foundation.h>
#import "LCSCmdlineCommandRunner.h"
#import "LCSRotavaultBlockCopyCommand.h"
#import "LCSRotavaultAppleRAIDCopyCommand.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* process command line arguments */
    NSUserDefaults *args = [[[NSUserDefaults alloc] init] autorelease];
    [args addSuiteNamed:NSArgumentDomain];
    [args registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:NO], @"debug",
                            @"ch.znerol.rvcopyd", @"label",
                            nil]];

    BOOL debug = [args boolForKey:@"debug"];

    /* setup asl */
    asl_add_log_file(NULL, 2);
    
    if (debug == YES) {
        asl_set_filter(NULL, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
    }

    /* FIXME: check / create pid file */
    // NSString *pidfile = [args stringForKey:@"pidfile"];
    
    NSString* method = [args objectForKey:@"method"];
    id <LCSCommand> copyCommand = nil;
    if ([@"asr" isEqualToString:method]) {
        copyCommand = [LCSRotavaultBlockCopyCommand commandWithSourceDevice:[args stringForKey:@"sourcedev"]
                                                             sourceChecksum:[args stringForKey:@"sourcecheck"]
                                                               targetDevice:[args stringForKey:@"targetdev"]
                                                             targetChecksum:[args stringForKey:@"targetcheck"]];
    }
    else if ([@"appleraid" isEqualToString:method]) {
        copyCommand = [LCSRotavaultAppleRAIDCopyCommand commandWithSourceDevice:[args stringForKey:@"sourcedev"]
                                                                 sourceChecksum:[args stringForKey:@"sourcecheck"]
                                                                   targetDevice:[args stringForKey:@"targetdev"]
                                                                 targetChecksum:[args stringForKey:@"targetcheck"]];
    }
    
    int status = 0;
    if (copyCommand) {
        /* alloc and run operation queue */
        LCSCmdlineCommandRunner *runner = [[LCSCmdlineCommandRunner alloc] initWithCommand:copyCommand];
        
        NSError *error = [runner run];
        
        if (error) {
            status = 1;
        }
        
        [runner release];
    }
    else {
        status = 2;
    }
    
    [pool drain];
    return status;
}
