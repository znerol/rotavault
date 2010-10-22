//
//  LCSCommandManager.m
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSCommandManager.h"

@interface LCSCommandManager (Private)
-(void)commandLeftInitState:(NSNotification*)ntf;
-(void)commandEnteredInvalidatedState:(NSNotification*)ntf;
@end


@implementation LCSCommandManager
@synthesize commands;

-(id)init
{
    self = [super init];
    self.commands = [NSArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandLeftInitState:)
                                                 name:[LCSCommand notificationNameStateLeft:LCSCommandStateInit]
                                               object:nil];
    return self;
}

-(void)dealloc
{
    [commands release];
    [super dealloc];
}

-(void)commandLeftInitState:(NSNotification*)ntf
{
    LCSCommand* command = [ntf object];
    [self addCommand:command];
}

-(void)commandEnteredInvalidatedState:(NSNotification*)ntf
{
    LCSCommand* command = [ntf object];
    [self removeCommand:command];
}

-(void)addCommand:(LCSCommand*)command
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(commandEnteredInvalidatedState:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:command];
    
    self.commands = [commands arrayByAddingObject:command];    
}

-(void)removeCommand:(LCSCommand*)command
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:command];
    
    self.commands = [commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", command]];
}
@end
