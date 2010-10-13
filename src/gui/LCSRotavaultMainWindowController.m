//
//  LCSRotavaultMainWindowController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultMainWindowController.h"
#import "LCSRotavaultScheduleInstallCommand.h"

@implementation LCSRotavaultMainWindowController

- (IBAction)createTargetImage:(id)sender {
    
}

- (IBAction)scheduleTask:(id)sender {
    LCSRotavaultScheduleInstallCommand *cmd = [LCSRotavaultScheduleInstallCommand
                                               commandWithSourceDevice:sourceDeviceField.stringValue
                                               targetDevice:targetDeviceField.stringValue
                                               runDate:runDateField.dateValue];
    cmd.rvcopydLaunchPath = [[NSBundle mainBundle] pathForResource:@"rvcopyd" ofType:nil];
    
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    ctl.title = [NSString localizedStringWithFormat:@"Schedule rotavault job"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleControllerFailedNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [ctl start];
}

- (IBAction)selectSourceDevice:(id)sender {
    
}

- (IBAction)selectTargetDevice:(id)sender {
    
}

- (IBAction)startTask:(id)sender {
    LCSRotavaultScheduleInstallCommand *cmd = [LCSRotavaultScheduleInstallCommand
                                               commandWithSourceDevice:sourceDeviceField.stringValue
                                               targetDevice:targetDeviceField.stringValue
                                               runDate:nil];
    cmd.rvcopydLaunchPath = [[NSBundle mainBundle] pathForResource:@"rvcopyd" ofType:nil];
    
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    ctl.title = [NSString localizedStringWithFormat:@"Run rotavault job"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleControllerFailedNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [ctl start];
}

- (IBAction)stopTask:(id)sender {
    
}

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

- (void)windowWillClose:(NSNotification*)notification
{
    [[NSApplication sharedApplication] terminate:self];
}
@end
