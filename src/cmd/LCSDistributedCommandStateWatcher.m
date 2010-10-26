//
//  LCSDistributedCommandStateWatcher.m
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDistributedCommandStateWatcher.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultDistributedStateNotification.h"


@interface LCSDistributedCommandStateWatcher (Internal)
- (void)updateStatus:(NSNotification*)ntf;
- (void)synchronizeStatus:(NSNotification*)ntf;
@end

@implementation LCSDistributedCommandStateWatcher
+ (LCSDistributedCommandStateWatcher*)commandWithLabel:(NSString*)senderLabel
{
    return [[[LCSDistributedCommandStateWatcher alloc] initWithLabel:senderLabel] autorelease];
}

- (id)initWithLabel:(NSString*)senderLabel
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    label = [senderLabel copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(updateStatus:)
                                                            name:LCSDistributedStateNotification
                                                          object:label];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(synchronizeStatus:)
                                                            name:LCSDistributedStateSyncNotification
                                                          object:label];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidate)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:self];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:LCSDistributedStateSyncRequestNotification
                                                                   object:label];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
        [self setValue:[msg valueForKey:keyPath] forKeyPath:keyPath];
    }
}

- (void)synchronizeStatus:(NSNotification*)ntf
{
    NSMutableDictionary *msg = [[ntf userInfo] mutableCopy];
    
    NSArray *states = [msg objectForKey:@"states"];
    for (NSNumber *st in states) {
        self.state = [st intValue];
    }
    [msg removeObjectForKey:@"states"];
    
    for (NSString *keyPath in msg) {
        [self setValue:[msg valueForKey:keyPath] forKeyPath:keyPath];
    }
    
    [msg release];
}

- (void)performStart
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"[LCSCommand start] Don't start a LCSDistributedCommandWatcher."
                                 userInfo:nil];    
}
@end
