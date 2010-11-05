//
//  LCSVolumeChooserPanelController.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVolumeChooserPanelController.h"
#import "LCSInitMacros.h"


@implementation LCSVolumeChooserPanelController
@synthesize volumeChooser;

- (id)init
{
    LCSINIT_OR_RETURN_NIL([super initWithWindowNibName:@"VolumeChooserPanel"]);
    
    volumeChooser = [[LCSRotavaultVolumeChooserController alloc] init];
    
    return self;
}

- (void)awakeFromNib
{
    [chooserView setSubviews:[NSArray arrayWithObject:[volumeChooser view]]];
}
@end
