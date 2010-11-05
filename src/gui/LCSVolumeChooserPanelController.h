//
//  LCSVolumeChooserPanelController.h
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSRotavaultVolumeChooserController.h"
#import "LCSRotavaultSystemEnvironmentObserver.h"


@interface LCSVolumeChooserPanelController : NSWindowController {
    IBOutlet NSView *chooserView;
    LCSRotavaultVolumeChooserController *volumeChooser;
}
@property(retain) LCSRotavaultVolumeChooserController *volumeChooser;
@end
