//
//  LCSRotavaultMainWindowController.h
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSRotavaultJob.h"
#import "LCSRotavaultSystemTools.h"

@interface LCSRotavaultMainWindowController : NSObject {
    IBOutlet NSWindow *window;
    AuthorizationRef authorization;
}

@property(readonly) LCSRotavaultJob *job;
@property(readonly) LCSRotavaultSystemTools *systools;
@end
