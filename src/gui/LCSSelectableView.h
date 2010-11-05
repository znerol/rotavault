//
//  LCSSelectableView.h
//  rotavault
//
//  Created by Lorenz Schori on 05.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSSelectable.h"


@interface LCSSelectableView : NSView <LCSSelectable> {
    BOOL selected;
}
@end
