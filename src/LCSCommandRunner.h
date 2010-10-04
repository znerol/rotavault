//
//  LCSCommandRunner.h
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LCSCommand;
@class LCSCommandController;


@protocol LCSCommandRunner <NSObject>
-(LCSCommandController*)run:(id <LCSCommand>)command;
@end
