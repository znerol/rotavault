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
    
    BOOL attachImageEnabled;
}
@property(readonly) LCSRotavaultJob *job;
@property(readonly) LCSRotavaultSystemTools *systools;
@property(assign) BOOL attachImageEnabled;
@end
