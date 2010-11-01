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
#import "LCSAllDiskInfoCommand.h"
#import "LCSAppleRAIDListCommand.h"

extern const double RotavaultVersionNumber;

NSString* LCSRotavaultSystemEnvironmentRefreshed = @"LCSRotavaultSystemEnvironmentRefreshed";

@interface LCSRotavaultSystemEnvironmentObserver (Internal)
- (void)updateSystoolsVersionInformation;
- (void)checkSystoolsVersionInformation;
- (void)invalidateCheckSystoolsVersionInformation:(NSNotification*)ntf;

- (void)checkDiskInformation;
- (void)invalidateCheckDiskInformation:(NSNotification*)ntf;

- (void)checkAppleRAIDInformation;
- (void)invalidateCheckAppleRAIDInformation:(NSNotification*)ntf;
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
    [diskInfoCommand release];
    [appleraidInfoCommand release];
    
    [super dealloc];
}

- (void)completeRefresh
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(completeRefresh) object:nil];
    if (systoolsInfoFresh && diskInfoFresh && appleraidInfoFresh) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCSRotavaultSystemEnvironmentRefreshed object:self];
    }
}

- (void)refreshInBackgroundAndNotify
{
    /*
     * We currently don't get notified when disk information changes, so we have to load that information on every
     * refresh
     */
    diskInfoFresh = NO;
    appleraidInfoFresh = NO;
    
    if (!systoolsInfoFresh) {
        [self checkSystoolsVersionInformation];
    }
    
    if (!diskInfoFresh) {
        [self checkDiskInformation];
    }
    
    if (!appleraidInfoFresh) {
        [self checkAppleRAIDInformation];
    }
    
    /* Notify immediately if no new information needs to be fetched */
    [self performSelector:@selector(completeRefresh) withObject:nil afterDelay:0];
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

#pragma mark Disk Info Subsystem
- (void)checkDiskInformation
{
    if (diskInfoCommand != nil) {
        return;
    }
    
    diskInfoFresh = NO;
    diskInfoCommand = [LCSAllDiskInfoCommand command];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckDiskInformation:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:diskInfoCommand];
    diskInfoCommand.title = [NSString localizedStringWithFormat:@"Getting information on attached disks and mounted volumes"];
    
    [diskInfoCommand retain];
    [diskInfoCommand start];
}

- (void)invalidateCheckDiskInformation:(NSNotification*)ntf
{
    assert(diskInfoCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:diskInfoCommand];
    
    [self.registry setObject:diskInfoCommand.result ? diskInfoCommand.result : [NSArray array] forKey:@"diskinfo"];
    [diskInfoCommand autorelease];
    diskInfoCommand = nil;
    diskInfoFresh = YES;
    
    [self completeRefresh];
}

#pragma mark AppleRAID Subsystem
- (void)checkAppleRAIDInformation
{
    if (appleraidInfoCommand != nil) {
        return;
    }
    
    appleraidInfoFresh = NO;
    appleraidInfoCommand = [LCSAppleRAIDListCommand command];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckAppleRAIDInformation:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:appleraidInfoCommand];
    appleraidInfoCommand.title = [NSString localizedStringWithFormat:@"Getting information on AppleRAID devices"];
    
    [appleraidInfoCommand retain];
    [appleraidInfoCommand start];
}

- (void)invalidateCheckAppleRAIDInformation:(NSNotification*)ntf
{
    assert(appleraidInfoCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:appleraidInfoCommand];
    
    [self.registry setObject:appleraidInfoCommand.result ? appleraidInfoCommand.result : [NSArray array] forKey:@"appleraid"];
    [appleraidInfoCommand autorelease];
    appleraidInfoCommand = nil;
    appleraidInfoFresh = YES;
    
    [self completeRefresh];
}
@end
