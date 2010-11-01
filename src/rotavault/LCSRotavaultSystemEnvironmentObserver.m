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

NSString* LCSRotavaultSystemEnvironmentRefreshed = @"LCSRotavaultSystemEnvironmentRefreshed";

@interface LCSRotavaultSystemEnvironmentObserver (Internal)
- (void)updateSystoolsVersionInformation;
- (void)checkSystoolsVersionInformation;
- (void)invalidateCheckSystoolsVersionInformation:(NSNotification*)ntf;
@end


@implementation LCSRotavaultSystemEnvironmentObserver
@synthesize registry;

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    registry = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(registry);
    
    return self;
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    
    [registry release];
    [systoolsInfoCommand release];
    [super dealloc];
}

- (void)completeRefresh
{
    if (systoolsInfoFresh) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCSRotavaultSystemEnvironmentRefreshed object:self];
    }
}

- (void)refreshInBackgroundAndNotify
{
    BOOL dirty = NO;
    if (!systoolsInfoFresh) {
        [self checkSystoolsVersionInformation];
        dirty = YES;
    }
    
    if (!dirty) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCSRotavaultSystemEnvironmentRefreshed object:self];
    }
}

- (void)watch
{
    NSParameterAssert(watching == NO);
    
    /* systools installed version */
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(checkSystoolsVersionInformation)
                                                            name:@"PKInstallDaemonDidEndInstallNotification"
                                                          object:nil];
}

- (void)unwatch
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                               name:@"PKInstallDaemonDidEndInstallNotification"
                                                             object:nil];
}

#pragma mark System Tools Subsystem
- (void)updateSystoolsVersionInformation
{
    NSDictionary *systemToolsState = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:systoolsInstalledVersion], @"installedVersion",
                                      [NSNumber numberWithDouble:RotavaultVersionNumber], @"requiredVersion",
                                      systoolsInstalled ? kCFBooleanTrue : kCFBooleanFalse, @"installed",
                                      systoolsInstalledVersion == RotavaultVersionNumber ?
                                                                    kCFBooleanTrue : kCFBooleanFalse, @"upToDate",
                                      nil];
    [self.registry setObject:systemToolsState forKey:@"systools"];
}

- (void)checkSystoolsVersionInformation
{
    if (systoolsInfoCommand != nil) {
        /* don't run more than one command on a single job */
        return;
    }
    
    systoolsInfoFresh = NO;
    systoolsInfoCommand = [LCSPkgInfoCommand commandWithPkgId:@"ch.znerol.rotavault.systools"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckSystoolsVersionInformation:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:systoolsInfoCommand];
    systoolsInfoCommand.title = [NSString localizedStringWithFormat:@"Checking Rotavault System Tools Installation"];
    
    [systoolsInfoCommand retain];
    [systoolsInfoCommand start];
    
    [self updateSystoolsVersionInformation];
}

- (void)invalidateCheckSystoolsVersionInformation:(NSNotification*)ntf
{
    assert(systoolsInfoCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:systoolsInfoCommand];
    
    systoolsInstalled = (systoolsInfoCommand.exitState == LCSCommandStateFinished);
    if (systoolsInstalled) {
        systoolsInstalledVersion = [[systoolsInfoCommand.result objectForKey:@"pkg-version"] doubleValue];
    }
    
    [systoolsInfoCommand autorelease];
    systoolsInfoCommand = nil;
    systoolsInfoFresh = YES;
    
    [self updateSystoolsVersionInformation];
    [self completeRefresh];
}
@end
