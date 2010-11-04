//
//  LCSRotavaultSystemEnvironment.m
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultSystemEnvironmentObserver.h"
#import "LCSInitMacros.h"
#import "LCSPkgInfoObserver.h"
#import "LCSDiskInfoObserver.h"
#import "LCSAppleRAIDObserver.h"

extern const double LCSAVGVersionNumberSymbol;


NSString* LCSRotavaultSystemEnvironmentRefreshed = @"LCSRotavaultSystemEnvironmentRefreshed";

@interface LCSRotavaultSystemEnvironmentObserver (Internal)
- (void)updateSystoolsVersionInformation:(NSNotification*)ntf;
- (void)updateDiskInformation:(NSNotification*)ntf;
- (void)updateAppleraidInformation:(NSNotification*)ntf;
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

    appleraidObserver = [[LCSAppleRAIDObserver alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(appleraidObserver);
    appleraidObserver.autorefresh = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAppleraidInformation:)
                                                 name:[LCSObserver notificationNameValueFresh]
                                               object:appleraidObserver];
    [appleraidObserver install];    
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
    
    [appleraidObserver remove];
    [appleraidObserver release];
    
    [super dealloc];
}

- (void)completeRefresh
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(completeRefresh) object:nil];
    if (systoolsInfoObserver.state == LCSObserverStateFresh &&
        diskInfoObserver.state == LCSObserverStateFresh && 
        appleraidObserver.state == LCSObserverStateFresh) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LCSRotavaultSystemEnvironmentRefreshed object:self];
    }
}

- (void)refreshInBackgroundAndNotify
{
    [systoolsInfoObserver refreshInBackgroundAndNotify];
    [diskInfoObserver refreshInBackgroundAndNotify];
    [appleraidObserver refreshInBackgroundAndNotify];
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
- (void)updateAppleraidInformation:(NSNotification*)ntf
{
    [self.registry setObject:appleraidObserver.value ? [[appleraidObserver.value objectForKey:@"byRAIDSetUUID"] allObjects] : [NSArray array]
                      forKey:@"appleraid"];
    [self completeRefresh];
}
@end
