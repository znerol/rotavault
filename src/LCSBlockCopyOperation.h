//
//  LCSBlockCopyOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSTaskOperation.h"


@interface LCSBlockCopyOperation : LCSTaskOperation {
}

- (LCSBlockCopyOperation*) initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev;

@end
