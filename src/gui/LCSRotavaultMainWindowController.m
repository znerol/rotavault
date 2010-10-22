//
//  LCSRotavaultMainWindowController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultMainWindowController.h"
#import "LCSInitMacros.h"
#import "LCSDiskImageAttachCommand.h"
#import "SampleCommon.h"

@implementation LCSRotavaultMainWindowController
@synthesize job;
@synthesize systools;
@synthesize attachImageEnabled;

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:
                                [[NSBundle mainBundle] pathForResource:@"StandardPreferences" ofType:@"plist"]]];
    
    OSStatus err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults,
                                       &authorization);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(err == 0);
        
    job = [[LCSRotavaultJob alloc] initWithDataObject:[NSUserDefaults standardUserDefaults]
                                              keyPath:@""
                                        authorization:authorization];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(job);
    
    [job addObserver:self forKeyPath:@"lastError" options:0 context:nil];
    
    systools = [[LCSRotavaultSystemTools alloc] init];
    [systools checkInstalledVersion];
    systools.autocheck = YES;
    
    self.attachImageEnabled = YES;
    
    return self;
}

- (void)dealloc
{
    [job removeObserver:self forKeyPath:@"lastError"];
    [job release];
    [systools release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (job.lastError != nil) {
        /* 
         * presentError runs the current runloop, so we better defer that until after all notification handlers got the
         * chance to act.
         */
        [window performSelector:@selector(presentError:) withObject:job.lastError afterDelay:0];
    }
}

- (void)installRotavaultSystemTools
{
    NSString *pkgpath = [[NSBundle mainBundle] pathForResource:@"Rotavault System Tools.pkg" ofType:nil];
    assert(pkgpath != nil);
    [[NSWorkspace sharedWorkspace] openFile:pkgpath withApplication:@"Installer.app" andDeactivate:YES];
}

- (void)attachImage
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:NO];
    
    NSInteger resp = [op runModalForTypes:[NSArray arrayWithObjects:@"dmg", @"sparseimage", @"sparsebundle", nil]];
    if (resp != NSOKButton) {
        return;
    }
    
    self.attachImageEnabled = NO;
    
    NSString *imagepath = [[op filenames] objectAtIndex:0];
    
    LCSCommand *cmd = [LCSDiskImageAttachCommand commandWithImagePath:imagepath];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(attachImageInvalidated:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:cmd];
    [cmd start];
}

- (void)attachImageInvalidated:(NSNotification*)ntf
{
    self.attachImageEnabled = YES;
    
    LCSCommand *cmd = [ntf object];
    if (cmd.exitState == LCSCommandStateFailed && cmd.error) {
        [window performSelector:@selector(presentError:) withObject:cmd.error afterDelay:0];
        return;
    }
    
    NSArray *labels = [cmd.result objectForKey:@"system-entities"];
    NSString *deventry = nil;
    for (NSDictionary *label in labels) {
        if (![@"Apple_HFS" isEqualToString:[label objectForKey:@"content-hint"]]) {
            continue;
        }
        
        deventry = [label objectForKey:@"dev-entry"];
    }
    
    if (!deventry) {
        NSRunAlertPanel(@"Image Attach Error", @"Failed to attach the specified image", nil, nil, nil);
        return;
    }
    
    job.targetDevice = deventry;
}

- (void)windowWillClose:(NSNotification*)notification
{
    [job saveToDataObject:[NSUserDefaults standardUserDefaults] keyPath:@""];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] terminate:self];
}
@end
