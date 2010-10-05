//
//  LCSCommandManager.m
//  task-test-2
//
//  Created by Lorenz Schori on 24.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSCommandManager.h"
#import "LCSCommand.h"


@implementation LCSCommandManager
@synthesize commands;
@synthesize errorHandler;

-(id)init
{
    self = [super init];
    self.commands = [NSArray array];
    return self;
}

-(void)dealloc
{
    [commands release];
    [super dealloc];
}

-(void)controllerEnteredInvalidatedState:(LCSCommandController*)controller
{
//    [self performSelector:@selector(removeCommandController:) withObject:controller afterDelay:0];
    if (errorHandler && controller.exitState == LCSCommandStateFailed && controller.error != nil) {
        [errorHandler handleError:controller.error fromController:controller];
    }
    
    [self removeCommandController:controller];
}

-(void)addCommandController:(LCSCommandController*)controller
{
    if ([controller.command respondsToSelector:@selector(setRunner:)]) {
        controller.command.runner = self;
    }
    
    [controller addObserver:self
                   selector:@selector(controllerEnteredInvalidatedState:)
                   forState:LCSCommandStateInvalidated];
    self.commands = [commands arrayByAddingObject:controller];    
}

-(void)removeCommandController:(LCSCommandController*)controller
{
    [controller removeObserver:self forState:LCSCommandStateInvalidated];
    self.commands = [commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", controller]];
}

-(LCSCommandController*)run:(id <LCSCommand>)command
{
    LCSCommandController* controller = [LCSCommandController controllerWithCommand:command];
    [self addCommandController:controller];
    
    [controller performSelector:@selector(start) withObject:nil afterDelay:0];
    return controller;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"commands"] && object == self && [commands count] == 0) {
        CFRunLoopStop([[NSRunLoop currentRunLoop] getCFRunLoop]);
    }
}

-(void)waitUntilAllCommandsAreDone
{
    [self addObserver:self forKeyPath:@"commands" options:0 context:nil];
    while([commands count] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    [self removeObserver:self forKeyPath:@"commands"];
}
@end
