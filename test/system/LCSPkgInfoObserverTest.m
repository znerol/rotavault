//
//  LCSPkgInfoObserverTest.m
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSPkgInfoObserver.h"


@interface LCSPkgInfoObserverTest : GHTestCase
@end


@implementation LCSPkgInfoObserverTest
- (void)testWithAppleBaseSystem
{
    LCSPkgInfoObserver *obs = [LCSPkgInfoObserver observerWithPkgId:@"com.apple.pkg.BaseSystem"];
    
    [obs install];
    [obs refreshInBackgroundAndNotify];
    [obs waitUntil:LCSObserverStateFresh];
    [obs remove];
    
    GHAssertTrue([obs.value isKindOfClass:[NSDictionary class]], @"Reported value should be a dictionary");
    GHAssertEqualObjects([obs.value objectForKey:@"pkgid"], @"com.apple.pkg.BaseSystem",
                         @"Pkgid in result must match the observer parameter");
}

- (void)testWithAppleBaseSystemAutorefresh
{
    LCSPkgInfoObserver *obs = [LCSPkgInfoObserver observerWithPkgId:@"com.apple.pkg.BaseSystem"];
    
    obs.autorefresh = YES;
    [obs install];
    [obs waitUntil:LCSObserverStateFresh];
    [obs remove];
    
    GHAssertTrue([obs.value isKindOfClass:[NSDictionary class]], @"Reported value should be a dictionary");
    GHAssertEqualObjects([obs.value objectForKey:@"pkgid"], @"com.apple.pkg.BaseSystem",
                         @"Pkgid in result must match the observer parameter");
}

- (void)testWithNonExistingPackageId
{
    LCSPkgInfoObserver *obs = [LCSPkgInfoObserver observerWithPkgId:
                               @"some.completely.insane.package.id.which.hopefully.nobody.will.ever.use"];
    
    obs.autorefresh = YES;
    [obs install];
    [obs waitUntil:LCSObserverStateFresh];
    [obs remove];
    
    GHAssertNil(obs.value, @"Reported value must be nil");
}
@end
