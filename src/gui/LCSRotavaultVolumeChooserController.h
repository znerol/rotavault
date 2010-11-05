//
//  LCSRotavaultVolumeChooserController.h
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSRotavaultVolumeChooserController : NSViewController{
    NSArray *disks;
    NSIndexSet *selectedDisks;
}

@property(retain) NSArray *disks;
@property(copy) NSIndexSet *selectedDisks;
@end
