//
//  LCSRotavaultSystemEnvironment.m
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultSystemEnvironmentObserver.h"
#import "LCSInitMacros.h"
#import "LCSPkgInfoCommand.h"

extern const double RotavaultVersionNumber;

@implementation LCSRotavaultSystemEnvironmentObserver
@synthesize registry;

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    registry = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(registry);
    
    return self;
}

-(void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    
    [registry release];
    [pkgInfoCommand release];
    [super dealloc];
}

-(void)updateControls
{
    NSDictionary *systemToolsState = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:installedVersion], @"installedVersion",
                                      [NSNumber numberWithDouble:RotavaultVersionNumber], @"requiredVersion",
                                      installed ? kCFBooleanTrue : kCFBooleanFalse, @"installed",
                                      upToDate ? kCFBooleanTrue : kCFBooleanFalse, @"upToDate",
                                      nil];
    [self.registry setObject:systemToolsState forKey:@"systools"];
}

-(void)checkInstalledVersion
{
    if (pkgInfoCommand != nil) {
        /* don't run more than one command on a single job */
        return;
    }
    
    pkgInfoCommand = [LCSPkgInfoCommand commandWithPkgId:@"ch.znerol.rotavault.systools"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckStatus:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:pkgInfoCommand];
    pkgInfoCommand.title = [NSString localizedStringWithFormat:@"Checking Rotavault System Tools Installation"];
    
    [pkgInfoCommand retain];
    [pkgInfoCommand start];
    [self updateControls];
}

- (void)invalidateCheckStatus:(NSNotification*)ntf
{
    assert(pkgInfoCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:pkgInfoCommand];
    
    installed = (pkgInfoCommand.exitState == LCSCommandStateFinished);
    if (installed) {
        installedVersion = [[pkgInfoCommand.result objectForKey:@"pkg-version"] doubleValue];
    }
    
    [pkgInfoCommand autorelease];
    pkgInfoCommand = nil;
    
    [self updateControls];
}

- (void)setAutocheck:(BOOL)value
{
    if (value == autocheck) {
        return;
    }
    autocheck = value;
    
    if (autocheck == YES) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(checkInstalledVersion)
                                                                name:@"PKInstallDaemonDidEndInstallNotification"
                                                              object:nil];
    }
    else {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                                   name:@"PKInstallDaemonDidEndInstallNotification"
                                                                 object:nil];
    }
}

- (BOOL)autocheck
{
    return autocheck;
}

@end
