//
//  LCSAppleRAIDWaitRebuildCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAppleRAIDMonitorRebuildCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommand.h"
#import "LCSAppleRAIDListCommand.h"
#import "NSScanner+AppleRAID.h"


@interface LCSAppleRAIDMonitorRebuildCommand (Internal)
- (void)startCheckraid;
- (void)completeCheckraid:(NSNotification*)ntf;
- (void)invalidateCheckraid:(NSNotification*)ntf;
@end

@implementation LCSAppleRAIDMonitorRebuildCommand
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
    self.state = LCSCommandStateInvalidated;
}

- (void)startCheckraid
{
    if (listraidctl) {
        return;
    }
    
    listraidctl = [[LCSAppleRAIDListCommand command] retain];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckraid:)
                                                 name:[LCSCommand notificationNameStateEntered:
                                                       LCSCommandStateInvalidated]
                                               object:listraidctl];
    [listraidctl start];
}

- (void)invalidateCheckraid:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:
                                                          LCSCommandStateInvalidated]
                                                  object:listraidctl];
    
    NSArray *res = listraidctl.result;
    [listraidctl autorelease];
    listraidctl = nil;
    
    float progr;
    NSString *status = [res extractAppleRAIDMemberStatus:raidsetUUID
                                        memberDeviceNode:memberDevpath
                                                progress:&progr];
    
    if ([status isEqualToString:@"Rebuilding"]) {
        /* still in the rebuilding progress */
        self.progress = progr;
        [self performSelector:@selector(startCheckraid) withObject:nil afterDelay:updateInterval];
    }
    else if ([status isEqualToString:@"Online"]) {
        /* we're done! */
        self.state = LCSCommandStateFinished;
        [self invalidate];
    }
    else {
        /* Unexpected state. Report error */
        self.state = LCSCommandStateFailed;
        [self invalidate];
    }    
}

- (void)performStart
{
    self.state = LCSCommandStateRunning;
    [self startCheckraid];
}
@end
