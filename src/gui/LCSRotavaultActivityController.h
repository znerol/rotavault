//
//  LCSRotavaultActivityController.h
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSOperation.h"

@interface LCSRotavaultActivityController : NSObject {
    IBOutlet NSTableView *activityTable;
    NSOperationQueue    *_queue;
}
- (IBAction)togglePanelVisibility:(id)sender;

-(void)runOperation:(LCSOperation*)operation;
@end
