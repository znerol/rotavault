//
//  LCSCommandStatePublisher.m
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDistributedCommandStatePublisher.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultDistributedStateNotification.h"


@interface LCSDistributedCommandStatePublisher (Internal)
- (void)handleSynchronizationRequest:(NSNotification*)ntf;
- (void)sendSynchronization;
@end


@implementation LCSDistributedCommandStatePublisher
- (id)initWithCommand:(LCSCommand*)cmd label:(NSString*)sndlabel
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    command = [cmd retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(command);
    label = [sndlabel copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    states = [[NSMutableArray alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(states);
    
    return self;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    
    [states release];
    [command release];
    [label release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != command) {
        return;
    }
    
    if ([@"state" isEqualToString:keyPath]) {
        [states addObject:[NSNumber numberWithInt:command.state]];
    }
    
    NSDictionary *msg = [NSDictionary dictionaryWithObject:[command valueForKeyPath:keyPath] forKey:keyPath];
    
    [[NSDistributedNotificationCenter defaultCenter]
     postNotificationName:LCSDistributedStateNotification object:label userInfo:msg
     options:NSNotificationPostToAllSessions];
}

- (void)handleSynchronizationRequest:(NSNotification*)ntf
{
    [self sendSynchronization];
}

- (void)sendSynchronization
{
    NSDictionary *msg = [NSDictionary dictionaryWithObjectsAndKeys:
                         command.title ? command.title : @"", @"title",
                         states, @"states",
                         [NSNumber numberWithFloat:command.progress], @"progress",
                         command.progressMessage ? command.progressMessage : @"", @"progressMessage",
                         [NSNumber numberWithBool:command.progressAnimate], @"progressAnimate",
                         [NSNumber numberWithBool:command.progressIndeterminate], @"progressIndeterminate",
                         nil];
    
    [[NSDistributedNotificationCenter defaultCenter]
     postNotificationName:LCSDistributedStateSyncNotification object:label userInfo:msg
     options:NSNotificationPostToAllSessions];    
}

- (void)watch
{
    [command addObserver:self forKeyPath:@"title" options:0 context:nil];
    [command addObserver:self forKeyPath:@"state" options:0 context:nil];
    [command addObserver:self forKeyPath:@"progress" options:0 context:nil];
    [command addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
    [command addObserver:self forKeyPath:@"progressAnimate" options:0 context:nil];
    [command addObserver:self forKeyPath:@"progressIndeterminate" options:0 context:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(handleSynchronizationRequest:)
                                                            name:LCSDistributedStateSyncRequestNotification
                                                          object:label];
    
    [self sendSynchronization];
}

- (void)unwatch
{
    [command removeObserver:self forKeyPath:@"title"];
    [command removeObserver:self forKeyPath:@"state"];
    [command removeObserver:self forKeyPath:@"progress"];
    [command removeObserver:self forKeyPath:@"progressMessage"];
    [command removeObserver:self forKeyPath:@"progressAnimate"];
    [command removeObserver:self forKeyPath:@"progressIndeterminate"];
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}
@end
