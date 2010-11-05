//
//  LCSRotavaultMainWindowController.h
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSRotavaultJob.h"
#import "LCSRotavaultSystemEnvironmentObserver.h"
#import "LCSDiskArbitration.h"
#import "LCSCommandManager.h"
#import "LCSVolumeChooserPanelController.h"

@interface LCSRotavaultMainWindowController : NSObject {
    IBOutlet NSWindow *window;
    AuthorizationRef authorization;
    
    LCSRotavaultJob *job;
    LCSRotavaultSystemEnvironmentObserver *env;
    LCSDiskArbitration *da;
    
    NSWindowController *commandManagerWindow;
    BOOL attachImageEnabled;
    
    LCSVolumeChooserPanelController *volumeChooserPanel;
}
@property(readonly) LCSRotavaultJob *job;
@property(readonly) LCSRotavaultSystemEnvironmentObserver *env;
@property(assign) BOOL attachImageEnabled;
@property(readonly) NSWindow *window;
@end
