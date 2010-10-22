//
//  LCSCommandStatePublisher.m
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDistributedCommandStatePublisher.h"
#import "LCSInitMacros.h"


@implementation LCSDistributedCommandStatePublisher
- (id)initWithCommandController:(LCSCommand*)ctl label:(NSString*)sndlabel
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    controller = [ctl retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(controller);
    label = [sndlabel copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    return self;
}

- (void)dealloc
{
    [controller release];
    [label release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != controller) {
        return;
    }
    
    NSDictionary *msg = [NSDictionary dictionaryWithObject:[controller valueForKeyPath:keyPath] forKey:keyPath];
    
    [[NSDistributedNotificationCenter defaultCenter]
     postNotificationName:[LCSCommand notificationNameStateChanged] object:label userInfo:msg
     options:NSNotificationPostToAllSessions];
}

- (void)watch
{
    [controller addObserver:self forKeyPath:@"title" options:0 context:nil];
    [controller addObserver:self forKeyPath:@"state" options:0 context:nil];
    [controller addObserver:self forKeyPath:@"progress" options:0 context:nil];
    [controller addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
    [controller addObserver:self forKeyPath:@"progressAnimate" options:0 context:nil];
    [controller addObserver:self forKeyPath:@"progressIndeterminate" options:0 context:nil];
}

- (void)unwatch
{
    [controller removeObserver:self forKeyPath:@"title"];
    [controller removeObserver:self forKeyPath:@"state"];
    [controller removeObserver:self forKeyPath:@"progress"];
    [controller removeObserver:self forKeyPath:@"progressMessage"];
    [controller removeObserver:self forKeyPath:@"progressAnimate"];
    [controller removeObserver:self forKeyPath:@"progressIndeterminate"];
}
@end
