//
//  LCSRotavaultScheduleInstallVerifier.m
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultScheduleInstallVerifier.h"
#import "LCSInitMacros.h"
#import "LCSPredicateVerifier.h"


@implementation LCSRotavaultScheduleInstallVerifier
+ (LCSRotavaultScheduleInstallVerifier*)verifierWithMethod:(NSString*)bcmethod
                                              sourceDevice:(NSString*)sourcedev
                                              targetDevice:(NSString*)targetdev
                                                   runDate:(NSDate*)runDate
                                         systemEnvironment:(NSDictionary*)sysenv
{
    return [[[LCSRotavaultScheduleInstallVerifier alloc] initWithMethod:bcmethod
                                                           sourceDevice:sourcedev
                                                           targetDevice:targetdev
                                                                runDate:runDate
                                                      systemEnvironment:sysenv] autorelease];
}

- (id)initWithMethod:(NSString*)method
        sourceDevice:(NSString*)sourcedev
        targetDevice:(NSString*)targetdev
             runDate:(NSDate*)runDate
   systemEnvironment:(NSDictionary*)sysenv
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    NSMutableArray *newVerifiers = [NSMutableArray array];
    
    NSString *sourceDeviceKeyPath = [NSString stringWithFormat:@"diskinfo.byDeviceIdentifier.%@",
                                     [sourcedev lastPathComponent]];
    NSString *targetDeviceKeyPath = [NSString stringWithFormat:@"diskinfo.byDeviceIdentifier.%@",
                                     [targetdev lastPathComponent]];
    
    LCSPredicateVerifier *v = nil;
    
    /* error if source is null */
    v = [[[LCSPredicateVerifier alloc] init] autorelease];
    v.predicate = [NSPredicate predicateWithFormat:@"%K != nil", sourceDeviceKeyPath];
    v.object = sysenv;
    v.message = NSLocalizedString(@"Unable to retreive information on the source drive. Please check the device path.", @"");
    [newVerifiers addObject:v];
    
    /* error if target is null */
    v = [[[LCSPredicateVerifier alloc] init] autorelease];
    v.predicate = [NSPredicate predicateWithFormat:@"%K != nil", targetDeviceKeyPath];
    v.object = sysenv;
    v.message = NSLocalizedString(@"Unable to retreive information on the target drive. Please check the device path.", @"");
    [newVerifiers addObject:v];
    
    /* error if source device is not a hfs disk */
    if ([@"asr" isEqualToString:method]) {
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"%K == 'Apple_HFS'",
                       [sourceDeviceKeyPath stringByAppendingString:@".Content"]];
        v.object = sysenv;
        v.message = NSLocalizedString(@"Source device is not a HFS Volume.", @"");
        [newVerifiers addObject:v];
    
        /* error if source device is the startup disk (only holds for asr) */
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"%K != %K", @"diskinfo.byMountPoint./", sourceDeviceKeyPath];
        v.object = sysenv;
        v.message = NSLocalizedString(@"Block copy operation from startup disk is not supported", @"");
        [newVerifiers addObject:v];
    }
    
    /* error if source and target are the same */
    v = [[[LCSPredicateVerifier alloc] init] autorelease];
    v.predicate = [NSPredicate predicateWithFormat:@"%K != %K", sourceDeviceKeyPath, targetDeviceKeyPath];
    v.object = sysenv;
    v.message = NSLocalizedString(@"Source and target may not be the same", @"");
    [newVerifiers addObject:v];
    
    /* error if target disk is mounted */
    v = [[[LCSPredicateVerifier alloc] init] autorelease];
    v.predicate = [NSPredicate predicateWithFormat:@"%K == ''",
                   [targetDeviceKeyPath stringByAppendingString:@".MountPoint"]];
    v.object = sysenv;
    v.message = NSLocalizedString(@"Target must not be mounted", @"");
    [newVerifiers addObject:v];
    
    /* error if target device is not big enough to hold contents from source */
    v = [[[LCSPredicateVerifier alloc] init] autorelease];
    v.predicate = [NSPredicate predicateWithFormat:@"%K <= %K",
                   [sourceDeviceKeyPath stringByAppendingString:@".TotalSize"],
                   [targetDeviceKeyPath stringByAppendingString:@".TotalSize"]];
    v.object = sysenv;
    v.message = NSLocalizedString(@"Target is too small to hold all content of source", @"");
    [newVerifiers addObject:v];
    
    if ([@"appleraid" isEqualToString:method]) {
        /* error if source device is not a raid-master (this only holds for appleraid) */
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"%K == %@",
                       [sourceDeviceKeyPath stringByAppendingString:@".RAIDSlice"],
                       [NSNumber numberWithBool:YES]];
        v.object = sysenv;
        v.message = NSLocalizedString(@"Source device is not a raid slice", @"");
        [newVerifiers addObject:v];

        /* error if source device is not a raid-1 (this only holds for appleraid) */
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"%K == 'Mirror'",
                       [sourceDeviceKeyPath stringByAppendingString:@".RAIDSetLevelType"]];
        v.object = sysenv;
        v.message = NSLocalizedString(@"Source device is not raid mirror", @"");
        [newVerifiers addObject:v];
        
        /* error if there is no other member appart from the source device in the raid */
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"%K == 'Online'",
                       [sourceDeviceKeyPath stringByAppendingString:@".RAIDSetStatus"]];
        v.object = sysenv;
        v.message = NSLocalizedString(@"This RAID set is not online", @"");
        [newVerifiers addObject:v];
    
        /* error if raid set is not online */
        v = [[[LCSPredicateVerifier alloc] init] autorelease];
        v.predicate = [NSPredicate predicateWithFormat:@"count(%K) >= 2",
                       [NSString stringWithFormat:@"appleraid.byMemberDeviceIdentifier.%@.RAIDSetMembers",
                        [sourcedev lastPathComponent]]];
        v.object = sysenv;
        v.message = NSLocalizedString(@"This RAID set has not enough devices. You should have at least two devices in a mirror set", @"");
        [newVerifiers addObject:v];
    }
    
    verifiers = [newVerifiers copy];
    
    return self;
}

- (void)performEvaluation
{
    for (LCSVerifier *verifier in verifiers) {
        [verifier evaluate];
    }
    
    NSPredicate *failedPredicate = [NSPredicate predicateWithFormat:@"passed == %@", [NSNumber numberWithBool:NO]];
    NSArray *failedVerifiers = [verifiers filteredArrayUsingPredicate:failedPredicate];
    self.passed = ([failedVerifiers count] == 0);
    
    if (!passed) {
        NSPredicate *evaluatedPredicate = [NSPredicate predicateWithFormat:@"evaluated == %@",
                                           [NSNumber numberWithBool:YES]];
        NSArray *evaluatedFailedVerifiers = [failedVerifiers filteredArrayUsingPredicate:evaluatedPredicate];
        if ([evaluatedFailedVerifiers count] > 0) {
            self.message = [[evaluatedFailedVerifiers objectAtIndex:0] message];
        }
        if (!message) {
            self.message = NSLocalizedString(@"Verification failed because of an unknown condition.", @"");
        }
    }
    self.evaluated = YES;
}

@end
