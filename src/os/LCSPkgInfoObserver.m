//
//  LCSPkgInfoObserver.m
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPkgInfoObserver.h"
#import "LCSPkgInfoCommand.h"
#import "LCSInitMacros.h"


@implementation LCSPkgInfoObserver

+ (LCSPkgInfoObserver*)observerWithPkgId:(NSString*)aPkgId
{
    return [[[LCSPkgInfoObserver alloc] initWithPkgId:aPkgId] autorelease];
}

- (id)initWithPkgId:(NSString*)aPkgId
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    pkgid = [aPkgId copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(pkgid);
    
    return self;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [pkgid release];
    [pkgInfoCommand release];
    [super dealloc];
}

- (void)invalidatePkgInfoCommand:(NSNotification*)ntf
{
    NSAssert(pkgInfoCommand == [ntf object], @"Received unexpected notification");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:pkgInfoCommand];
    
    self.value = pkgInfoCommand.exitState == LCSCommandStateFinished ? pkgInfoCommand.result : nil;
    
    [pkgInfoCommand autorelease];
    pkgInfoCommand = nil;
    
    self.state = LCSObserverStateFresh;
}

- (void)expirePkgInfo
{
    self.state = LCSObserverStateStale;
}

- (void)performInstall
{
    /* mark information as stale whenever the mac os x installer completes any package installation */
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(expirePkgInfo)
                                                            name:@"PKInstallDaemonDidEndInstallNotification"
                                                          object:nil];
    
    self.state = LCSObserverStateInstalled;
}

- (void)performRemove
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name:@"PKInstallDaemonDidEndInstallNotification"
                                                             object:nil];
}

- (void)performStartRefresh
{
    if (pkgInfoCommand != nil) {
        return;
    }
    
    self.state = LCSObserverStateRefreshing;
    
    pkgInfoCommand = [LCSPkgInfoCommand commandWithPkgId:pkgid];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidatePkgInfoCommand:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:pkgInfoCommand];
    pkgInfoCommand.title = [NSString localizedStringWithFormat:@"Retreiving information about Package %@", pkgid];
    
    [pkgInfoCommand retain];
    [pkgInfoCommand start];
}
@end
