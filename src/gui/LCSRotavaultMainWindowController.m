//
//  LCSRotavaultMainWindowController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultMainWindowController.h"
#import "LCSRotavaultScheduleInstallCommand.h"

@implementation LCSRotavaultMainWindowController

- (void)awakeFromNib
{
    commandManager.errorHandler = self;
}

- (IBAction)createTargetImage:(id)sender {
    
}

- (IBAction)scheduleTask:(id)sender {
    LCSRotavaultScheduleInstallCommand *cmd = [LCSRotavaultScheduleInstallCommand
                                               commandWithSourceDevice:sourceDeviceField.stringValue
                                               targetDevice:targetDeviceField.stringValue
                                               runDate:runDateField.dateValue];
    cmd.rvcopydLaunchPath = [[NSBundle mainBundle] pathForResource:@"rvcopyd" ofType:nil];
    
    currentController = [commandManager run:cmd];
    currentController.title = [NSString localizedStringWithFormat:@"Schedule rotavault job"];
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
    
    currentController = [commandManager run:cmd];
    currentController.title = [NSString localizedStringWithFormat:@"Run rotavault job"];
}

- (IBAction)stopTask:(id)sender {
    
}

- (void)handleError:(NSError*)error fromController:(LCSCommandController*)controller
{
    if (controller != currentController) {
        return;
    }
    [window presentError:error];
}

- (void)windowWillClose:(NSNotification*)notification
{
    [[NSApplication sharedApplication] terminate:self];
}
@end
