//
//  LCSPassphraseReader.h
//  rotavault
//
//  Created by Lorenz Schori on 23.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol LCSPassphraseReader

/**
 * Manipulate the task object by adding/removing command line arguments and/or
 * redirecting input/output streams in order to alter the behaviour of hdiutil
 * in the required way.
 */
- (void) prepareTask:(NSTask*)task;

@end
