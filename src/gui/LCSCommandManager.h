//
//  LCSCommandManager.h
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSCommandManager : NSObject {
    NSArray *commands;
}

-(void)addCommandController:(LCSCommand*)controller;
-(void)removeCommandController:(LCSCommand*)controller;

/**
 * List of running LCSCommandController
 */
@property(retain) NSArray *commands;
@end
