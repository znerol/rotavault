//
//  LCSRotavaultMainWindowController.h
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSRotavaultActivityController.h"

@interface LCSRotavaultMainWindowController : NSObject {
    IBOutlet NSDatePicker *runDateField;
    IBOutlet NSTextField *sourceDeviceField;
    IBOutlet NSTextField *statusField;
    IBOutlet NSTextField *targetDeviceField;
    IBOutlet LCSRotavaultActivityController *activityController;
}
- (IBAction)createTargetImage:(id)sender;
- (IBAction)scheduleTask:(id)sender;
- (IBAction)selectSourceDevice:(id)sender;
- (IBAction)selectTargetDevice:(id)sender;
- (IBAction)startTask:(id)sender;
- (IBAction)stopTask:(id)sender;
@end
