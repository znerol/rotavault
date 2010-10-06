//
//  LCSCommandManager.h
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandRunner.h"
#import "LCSCommandController.h"


@interface LCSCommandManager : NSObject <LCSCommandRunner> {
    NSArray *commands;
}

-(void)addCommandController:(LCSCommandController*)controller;
-(void)removeCommandController:(LCSCommandController*)controller;
-(void)waitUntilAllCommandsAreDone;

/**
 * List of running LCSCommandController
 */
@property(retain) NSArray *commands;
@end
