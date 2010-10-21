//
//  LCSRotavaultMainWindowController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultMainWindowController.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultScheduleInstallCommand.h"
#import "SampleCommon.h"

@implementation LCSRotavaultMainWindowController
@synthesize job;
- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:
                                [[NSBundle mainBundle] pathForResource:@"StandardPreferences" ofType:@"plist"]]];
    
    AuthorizationItem monitorRights[] = 
    {
        {
            .name = kLCSHelperMonitorRotavaultLaunchdJobRightName,
            .valueLength = 0,
            .value = NULL,
            .flags = 0
        }
    };
    AuthorizationRights rights = {
        .count = 1,
        .items = monitorRights
    };
    
    OSStatus err = AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment,
                                       kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights,
                                       &authorization);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(err == 0);
        
    job = [[LCSRotavaultJob alloc] initWithDataObject:[NSUserDefaults standardUserDefaults]
                                              keyPath:@""
                                        authorization:authorization];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(job);
    
    return self;
}

- (void)dealloc
{
    [job release];
    [super dealloc];
}

#if 0
- (void)handleControllerFailedNotification:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    if (sender.error != nil) {
        /* 
         * presentError runs the current runloop, so we better defer that until after all notification handlers got the
         * chance to act.
         */
        [window performSelector:@selector(presentError:) withObject:sender.error afterDelay:0];
    }
}
#endif

- (void)windowWillClose:(NSNotification*)notification
{
    [job saveToDataObject:[NSUserDefaults standardUserDefaults] keyPath:@""];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] terminate:self];
}
@end
