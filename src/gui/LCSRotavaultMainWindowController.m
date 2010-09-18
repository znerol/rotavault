//
//  LCSRotavaultMainWindowController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultMainWindowController.h"
#import "LCSRotavaultScheduleInstallOperation.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSSimpleOperationParameter.h"

@implementation LCSRotavaultMainWindowController
- (IBAction)createTargetImage:(id)sender {
    
}

- (IBAction)scheduleTask:(id)sender {
    LCSRotavaultScheduleInstallOperation *op = [[LCSRotavaultScheduleInstallOperation alloc] init];
    op.sourceDevice = [LCSKeyValueOperationInputParameter parameterWithTarget:sourceDeviceField keyPath:@"stringValue"];
    op.targetDevice = [LCSKeyValueOperationInputParameter parameterWithTarget:targetDeviceField keyPath:@"stringValue"];
    op.runAtDate = [LCSKeyValueOperationInputParameter parameterWithTarget:runDateField keyPath:@"dateValue"];
    
    NSString* rvcopydPath = [[NSBundle mainBundle] pathForResource:@"rvcopyd" ofType:nil];
    op.rvcopydLaunchPath = [LCSSimpleOperationInputParameter parameterWithValue:rvcopydPath];
    
    [activityController runOperation:op];    
    [op release];
}

- (IBAction)selectSourceDevice:(id)sender {
    
}

- (IBAction)selectTargetDevice:(id)sender {
    
}

- (IBAction)startTask:(id)sender {
    LCSRotavaultScheduleInstallOperation *op = [[LCSRotavaultScheduleInstallOperation alloc] init];
    op.sourceDevice = [LCSKeyValueOperationInputParameter parameterWithTarget:sourceDeviceField keyPath:@"stringValue"];
    op.targetDevice = [LCSKeyValueOperationInputParameter parameterWithTarget:targetDeviceField keyPath:@"stringValue"];
    op.runAtDate = [LCSSimpleOperationInputParameter parameterWithValue:nil];
    
    NSString* rvcopydPath = [[NSBundle mainBundle] pathForResource:@"rvcopyd" ofType:nil];
    op.rvcopydLaunchPath = [LCSSimpleOperationInputParameter parameterWithValue:rvcopydPath];
    
    [activityController runOperation:op];    
    [op release];
}

- (IBAction)stopTask:(id)sender {
    
}

- (void)windowWillClose:(NSNotification*)notification
{
    [[NSApplication sharedApplication] terminate:self];
}
@end
