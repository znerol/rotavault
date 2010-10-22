//
//  LCSCommandCollection.m
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommandCollection.h"
#import "LCSInitMacros.h"

NSString* LCSCommandCollectionOriginalSenderKey = @"LCSCommandCollectionOriginalSender";

@implementation LCSCommandCollection

@synthesize commands;

+(LCSCommandCollection*)collection
{
    return [[[LCSCommandCollection alloc] init] autorelease];
}

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    commands = [[NSMutableSet alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(commands);
    watchers = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(watchers);
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [commands release];
    [watchers release];
    
    [super dealloc];
}

-(void)handleCommandState:(NSNotification*)ntf
{
    LCSCommand* sender = [ntf object];
    
    NSMutableSet *commandsPerState = [[watchers objectForKey:[NSNumber numberWithInt:sender.state]] retain];
    
    [commandsPerState addObject:sender];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:sender
                                                         forKey:LCSCommandCollectionOriginalSenderKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[LCSCommandCollection notificationNameAnyCommandEnteredState:sender.state]
                                                        object:self
                                                      userInfo:userInfo];
    
    if ([commandsPerState isEqualToSet:commands]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[LCSCommandCollection notificationNameAllCommandsEnteredState:sender.state]
                                                            object:self];
    }
    [commandsPerState release];
}

-(void)addCommand:(LCSCommand*)ctl
{
    [commands addObject:ctl];
    
    for (NSNumber *state in [watchers allKeys]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleCommandState:)
                                                     name:[LCSCommand notificationNameStateEntered:[state intValue]]
                                                   object:ctl];
    }
}

-(void)removeCommand:(LCSCommand*)ctl
{
    [commands removeObject:ctl];
    
    for (NSNumber *state in [watchers allKeys]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[LCSCommand notificationNameStateEntered:[state intValue]]
                                                      object:ctl];
    }
}

-(void)watchState:(LCSCommandState)state
{
    // check if we're already watching this state
    if ([watchers objectForKey:[NSNumber numberWithInt:state]]) {
        return;
    }
    
    [watchers setObject:[NSMutableSet set] forKey:[NSNumber numberWithInt:state]];
    
    for (LCSCommand *ctl in commands) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleCommandState:)
                                                     name:[LCSCommand notificationNameStateEntered:state]
                                                   object:ctl];
    }
}

-(void)unwatchState:(LCSCommandState)state
{
    // check if we know this guy
    if (![watchers objectForKey:[NSNumber numberWithInt:state]]) {
        return;
    }
    
    [watchers removeObjectForKey:[NSNumber numberWithInt:state]];
    
    for (LCSCommand *ctl in commands) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[LCSCommand notificationNameStateEntered:state]
                                                      object:ctl];
    }
}

+(NSString*)notificationNameAnyCommandEnteredState:(LCSCommandState)state
{
    return [NSString stringWithFormat:@"LCSCommandCollectionAnyEnteredState-%d", state];
}

+(NSString*)notificationNameAllCommandsEnteredState:(LCSCommandState)state
{
    return [NSString stringWithFormat:@"LCSCommandCollectionAllEnteredState-%d", state];
}
@end
