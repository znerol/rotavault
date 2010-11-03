//
//  LCSRotavaultSystemEnvironment.m
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultSystemEnvironmentObserver.h"
#import "LCSInitMacros.h"
#import "LCSAppleRAIDListCommand.h"
#import "LCSPkgInfoObserver.h"
#import "LCSDiskInfoObserver.h"

extern const double LCSAVGVersionNumberSymbol;


NSString* LCSRotavaultSystemEnvironmentRefreshed = @"LCSRotavaultSystemEnvironmentRefreshed";

@interface LCSRotavaultSystemEnvironmentObserver (Internal)
- (void)updateSystoolsVersionInformation:(NSNotification*)ntf;
- (void)updateDiskInformation:(NSNotification*)ntf;

- (void)checkAppleRAIDInformation;
- (void)invalidateCheckAppleRAIDInformation:(NSNotification*)ntf;
@end


LCSRotavaultSystemEnvironmentObserver *LCSDefaultRotavaultSystemEnvironmentObserver = nil;


@implementation LCSRotavaultSystemEnvironmentObserver
@synthesize registry;

+ (LCSRotavaultSystemEnvironmentObserver*)defaultSystemEnvironmentObserver
{
    if (!LCSDefaultRotavaultSystemEnvironmentObserver) {
        LCSDefaultRotavaultSystemEnvironmentObserver = [[LCSRotavaultSystemEnvironmentObserver alloc] init];
    }
    
    return LCSDefaultRotavaultSystemEnvironmentObserver;
}

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    registry = [[NSMutableDictionary alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(registry);
    
    systoolsInfoObserver = [[LCSPkgInfoObserver alloc] initWithPkgId:@"ch.znerol.rotavault.systools"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(systoolsInfoObserver);
    systoolsInfoObserver.autorefresh = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSystoolsVersionInformation:)
                                                 name:[LCSObserver notificationNameValueFresh]
                                               object:systoolsInfoObserver];
    [systoolsInfoObserver install];
    
    diskInfoObserver = [[LCSDiskInfoObserver alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(diskInfoObserver);
    diskInfoObserver.autorefresh = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDiskInformation:)
                                                 name:[LCSObserver notificationNameValueFresh]
                                               object:diskInfoObserver];
    [diskInfoObserver install];
    
    return self;
}

- (void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [registry release];
    
    [systoolsInfoObserver remove];
    [systoolsInfoObserver release];
    
    [diskInfoObserver remove];
    [diskInfoObserver release];
    
    [appleraidInfoCommand release];
    
    [super dealloc];
}

- (void)completeRefresh
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(completeRefresh) object:nil];
    if (systoolsInfoObserver.state == LCSObserverStateFresh &&
        diskInfoObserver.state == LCSObserverStateFresh && appleraidInfoFresh) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCSRotavaultSystemEnvironmentRefreshed object:self];
    }
}

- (void)refreshInBackgroundAndNotify
{
    /*
     * We currently don't get notified when disk information changes, so we have to load that information on every
     * refresh
     */
    appleraidInfoFresh = NO;

    [systoolsInfoObserver refreshInBackgroundAndNotify];
    [diskInfoObserver refreshInBackgroundAndNotify];
    
    if (!appleraidInfoFresh) {
        [self checkAppleRAIDInformation];
    }
    
    /* Notify immediately if no new information needs to be fetched */
    [self performSelector:@selector(completeRefresh) withObject:nil afterDelay:0];
}

#pragma mark System Tools Subsystem
- (void)updateSystoolsVersionInformation:(NSNotification*)ntf
{
    BOOL installed = (systoolsInfoObserver.value != nil);
    double version = 0.0;
    
    if (installed) {
        version = [[systoolsInfoObserver.value objectForKey:@"pkg-version"] doubleValue];
    }
    
    BOOL upToDate = (version == LCSAVGVersionNumberSymbol);
    
    NSDictionary *systemToolsState = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithDouble:version], @"installedVersion",
                                      [NSNumber numberWithDouble:LCSAVGVersionNumberSymbol], @"requiredVersion",
                                      installed ? kCFBooleanFalse : kCFBooleanTrue, @"installed",
                                      upToDate ? kCFBooleanTrue : kCFBooleanFalse, @"upToDate",
                                      nil];
    [self.registry setObject:systemToolsState forKey:@"systools"];
    [self completeRefresh];
}

#pragma mark Disk Info Subsystem
- (void)updateDiskInformation:(NSNotification*)ntf
{
    [self.registry setObject:diskInfoObserver.value ? diskInfoObserver.value : [NSDictionary dictionary]
                      forKey:@"diskinfo"];
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
