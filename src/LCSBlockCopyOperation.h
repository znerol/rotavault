//
//  LCSBlockCopyOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSBlockCopyOperation : NSOperation {
    NSString* source;
    NSString* target;
}

@property(readonly) NSError* error;
@property(readonly) float progress;

- (LCSBlockCopyOperation*) initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev;

@end
