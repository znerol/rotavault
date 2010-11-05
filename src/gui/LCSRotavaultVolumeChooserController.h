//
//  LCSRotavaultVolumeChooserController.h
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSRotavaultVolumeChooserController : NSObject {
    IBOutlet NSView *view;

    NSArray *disks;
    NSIndexSet *selectedDisks;
}

@property(retain) NSArray *disks;
@property(copy) NSIndexSet *selectedDisks;
@end
