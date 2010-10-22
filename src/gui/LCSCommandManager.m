//
//  LCSCommandManager.m
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSCommandManager.h"

@interface LCSCommandManager (Private)
-(void)controllerLeftInitState:(NSNotification*)ntf;
-(void)controllerEnteredInvalidatedState:(NSNotification*)ntf;
@end


@implementation LCSCommandManager

-(id)init
{
    self = [super init];
    self.commands = [NSArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerLeftInitState:)
                                                 name:[LCSCommandController notificationNameStateLeft:LCSCommandStateInit]
                                               object:nil];
    return self;
}

-(void)dealloc
{
    [commands release];
    [super dealloc];
}

-(void)controllerLeftInitState:(NSNotification*)ntf
{
    LCSCommandController* controller = [ntf object];
    [self addCommandController:controller];
}

-(void)controllerEnteredInvalidatedState:(NSNotification*)ntf
{
    LCSCommandController* controller = [ntf object];
    [self removeCommandController:controller];
}

-(void)addCommandController:(LCSCommandController*)controller
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerEnteredInvalidatedState:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:controller];
    
    self.commands = [commands arrayByAddingObject:controller];    
}

-(void)removeCommandController:(LCSCommandController*)controller
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:controller];
    
    self.commands = [commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", controller]];
}
@end
