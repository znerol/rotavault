//
//  LCSAppleRAIDWaitRebuildCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAppleRAIDMonitorRebuildCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"
#import "LCSAppleRAIDListCommand.h"
#import "NSScanner+AppleRAID.h"


@interface LCSAppleRAIDMonitorRebuildCommand (Internal)
- (void)startCheckraid;
- (void)completeCheckraid:(NSNotification*)ntf;
- (void)invalidateCheckraid:(NSNotification*)ntf;
@end

@implementation LCSAppleRAIDMonitorRebuildCommand
@synthesize controller;
@synthesize updateInterval;

+ (LCSAppleRAIDMonitorRebuildCommand*)commandWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath
{
    return [[[LCSAppleRAIDMonitorRebuildCommand alloc] initWithRaidUUID:raidUUID devicePath:devicePath] autorelease];
}

- (id)initWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    raidsetUUID = [raidUUID copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(raidsetUUID);
    memberDevpath = [devicePath copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(memberDevpath);
    
    updateInterval = 2.0;
    return self;
}

- (void)dealloc
{
    [raidsetUUID release];
    [memberDevpath release];
    [listraidctl release];
    [super dealloc];
}

- (void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    controller.state = LCSCommandStateInvalidated;
}

- (void)startCheckraid
{
    if (listraidctl && listraidctl.state != LCSCommandStateInvalidated) {
        return;
    }
    [listraidctl release];
    
    listraidctl = [[LCSCommandController controllerWithCommand:[LCSAppleRAIDListCommand command]] retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckraid:)
                                                 name:[LCSCommandController notificationNameStateEntered:
                                                       LCSCommandStateInvalidated]
                                               object:listraidctl];
    [listraidctl start];
}

- (void)invalidateCheckraid:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandController notificationNameStateEntered:
                                                          LCSCommandStateInvalidated]
                                                  object:listraidctl];
    
    NSArray *result = listraidctl.result;
    float progress;
    NSString *status = [result extractAppleRAIDMemberStatus:raidsetUUID
                                           memberDeviceNode:memberDevpath
                                                   progress:&progress];
    
    if ([status isEqualToString:@"Rebuilding"]) {
        /* still in the rebuilding progress */
        controller.progress = progress;
        [self performSelector:@selector(startCheckraid) withObject:nil afterDelay:updateInterval];
    }
    else if ([status isEqualToString:@"Online"]) {
        /* we're done! */
        controller.state = LCSCommandStateFinished;
        [self invalidate];
    }
    else {
        /* Unexpected state. Report error */
        controller.state = LCSCommandStateFailed;
        [self invalidate];
    }    
}

- (void)start
{
    controller.state = LCSCommandStateRunning;
    [self startCheckraid];
}
@end
