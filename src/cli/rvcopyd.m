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
    
    NSString* label = [args objectForKey:@"label"];
    
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
        /* run operation */
        NSString* title = [NSString stringWithFormat:@"Rotavault copying from %@ to %@",
                           [args stringForKey:@"sourcedev"], [args stringForKey:@"targetdev"]];
        LCSCmdlineCommandRunner *runner = [[LCSCmdlineCommandRunner alloc] initWithCommand:copyCommand
                                                                                     label:label
                                                                                     title:title];
        
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
