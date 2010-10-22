//
//  LCSDistributedCommandStateWatcher.m
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDistributedCommandStateWatcher.h"
#import "LCSInitMacros.h"


@implementation LCSDistributedCommandStateWatcher
@synthesize controller;

+ (LCSDistributedCommandStateWatcher*)commandWithLabel:(NSString*)senderLabel
{
    return [[[LCSDistributedCommandStateWatcher alloc] initWithLabel:senderLabel] autorelease];
}

- (id)initWithLabel:(NSString*)senderLabel
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    label = [senderLabel copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    return self;
}

- (void)dealloc
{
    [label release];
    [super dealloc];
}

- (void)invalidate
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateStatus:(NSNotification*)ntf
{
    if (![label isEqualTo:[ntf object]]) {
        return;
    }
    
    NSDictionary *msg = [ntf userInfo];
    for (NSString *keyPath in msg) {
        [controller setValue:[msg valueForKey:keyPath] forKeyPath:keyPath];
    }
}

- (void)start
{
    if (![controller tryStart]) {
        return;
    }
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(updateStatus:)
                                                            name:[LCSCommandController notificationNameStateChanged]
                                                          object:label];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidate)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:controller];
}
@end
