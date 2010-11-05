//
//  LCSVolumeChooserPanelController.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVolumeChooserPanelController.h"
#import "LCSRotavaultMainWindowController.h"
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

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode != NSRunStoppedResponse || [volumeChooser.selectedDisks count] != 1) {
        return;
    }
    
    LCSRotavaultMainWindowController *ctl = (LCSRotavaultMainWindowController *)contextInfo;
    NSDictionary *choice = [volumeChooser.disks objectAtIndex:[volumeChooser.selectedDisks firstIndex]];
    
    ctl.job.sourceDevice = [choice objectForKey:@"DeviceNode"];
    
    BOOL isRAIDSlice = [[NSNumber numberWithBool:YES] isEqual:[choice objectForKey:@"isRAIDSlice"]];
    ctl.job.blockCopyMethodIndex = isRAIDSlice;
}

- (void)showVolumeChooser:(id)mainWindowController
{
    [NSApp beginSheet:[self window]
       modalForWindow:[mainWindowController window]
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:mainWindowController];
}

- (void)cancel
{
    [NSApp endSheet:[self window] returnCode:NSRunAbortedResponse];
    [self close];
}

- (void)chooseDisk
{
    [NSApp endSheet:[self window]];
    [self close];
}
@end
