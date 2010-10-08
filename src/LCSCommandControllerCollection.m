//
//  LCSCommandControllerCollection.m
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCommandControllerCollection.h"
#import "LCSInitMacros.h"

NSString* LCSCommandControllerCollectionOriginalSenderKey = @"LCSCommandControllerCollectionOriginalSender";

@implementation LCSCommandControllerCollection

@synthesize controllers;

+(LCSCommandControllerCollection*)collection
{
    return [[[LCSCommandControllerCollection alloc] init] autorelease];
}

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    controllers = [[NSMutableSet alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(controllers);
    watchers = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(watchers);
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [controllers dealloc];
    [watchers dealloc];
    
    [super dealloc];
}

-(void)handleControllerState:(NSNotification*)ntf
{
    LCSCommandController* sender = [ntf object];
    
    NSMutableSet *controllersPerState = [watchers objectForKey:[NSNumber numberWithInt:sender.state]];
    
    [controllersPerState addObject:sender];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:sender
                                                         forKey:LCSCommandControllerCollectionOriginalSenderKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:[LCSCommandControllerCollection notificationNameAnyControllerEnteredState:sender.state]
                                                        object:self
                                                      userInfo:userInfo];
    
    if ([controllersPerState isEqualToSet:controllers]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:sender.state]
                                                            object:self];
    }
}

-(void)addController:(LCSCommandController*)ctl
{
    [controllers addObject:ctl];
    
    for (NSNumber *state in [watchers allKeys]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleControllerState:)
                                                     name:[LCSCommandController notificationNameStateEntered:[state intValue]]
                                                   object:ctl];
    }
}

-(void)removeController:(LCSCommandController*)ctl
{
    [controllers removeObject:ctl];
    
    for (NSNumber *state in [watchers allKeys]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[LCSCommandController notificationNameStateEntered:[state intValue]]
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
    
    for (LCSCommandController *ctl in controllers) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleControllerState:)
                                                     name:[LCSCommandController notificationNameStateEntered:state]
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
    
    for (LCSCommandController *ctl in controllers) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:[LCSCommandController notificationNameStateEntered:state]
                                                      object:ctl];
    }
}

+(NSString*)notificationNameAnyControllerEnteredState:(LCSCommandState)state
{
    return [NSString stringWithFormat:@"LCSCommandControllerCollectionAnyEnteredState-%d", state];
}

+(NSString*)notificationNameAllControllersEnteredState:(LCSCommandState)state
{
    return [NSString stringWithFormat:@"LCSCommandControllerCollectionAllEnteredState-%d", state];
}
@end
