//
//  LCSSelectableView.m
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSelectableView.h"


@implementation LCSSelectableView
- (void)setSelected:(BOOL)flag
{
    [self setNeedsDisplay:YES];
    selected = flag;
}

- (BOOL)selected
{
    return selected;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (selected) {
        [[NSColor selectedTextBackgroundColor] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}
@end
