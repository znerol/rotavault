//
//  LCSGenerateRotavaultCopyLaunchdPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSGenerateRotavaultCopyLaunchdPlistOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"


@implementation LCSGenerateRotavaultCopyLaunchdPlistOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    runAtDate = [[LCSOperationRequiredInputParameterMarker alloc] init];
    sourceInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    targetInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    result = [[LCSOperationOptionalOutputParameterMarker alloc] init];

    if (!runAtDate || !sourceInfo || !targetInfo || !result) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [runAtDate release];
    [sourceInfo release];
    [targetInfo release];
    [result release];
}

@synthesize runAtDate;
@synthesize sourceInfo;
@synthesize targetInfo;
@synthesize result;

-(void)execute
{
    NSString *sourceDevice = [sourceInfo.value objectForKey:@"DeviceNode"];
    NSString *sourceUUID = [sourceInfo.value objectForKey:@"VolumeUUID"];
    NSString *targetDevice = [targetInfo.value objectForKey:@"DeviceNode"];
    NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetInfo.value] stringWithHexBytes];

    // FIXME: handle nil/empty values
    NSArray *args = [NSArray arrayWithObjects:@"/usr/local/bin/rvcopyd", @"-sourcedev", sourceDevice, @"-targetdev",
                     targetDevice, @"-sourcecheck", [NSString stringWithFormat:@"uuid:%@", sourceUUID], @"-targetcheck", 
                     [NSString stringWithFormat:@"sha1:%@", targetSHA1], nil];

    NSDateFormatter *minFormatter = [[NSDateFormatter alloc] init];
    [minFormatter setDateFormat:@"mm"];
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    [hourFormatter setDateFormat:@"HH"];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd"];
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setAllowsFloats:NO];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSDictionary *date = [NSDictionary dictionaryWithObjectsAndKeys:
                          [numberFormatter numberFromString:[minFormatter stringFromDate:runAtDate.value]], @"Minute",
                          [numberFormatter numberFromString:[hourFormatter stringFromDate:runAtDate.value]], @"Hour",
                          [numberFormatter numberFromString:[dayFormatter stringFromDate:runAtDate.value]], @"Day",
                          [numberFormatter numberFromString:[monthFormatter stringFromDate:runAtDate.value]], @"Month",
                          nil];

    result.value = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"ch.znerol.rvcopyd", @"Label",
                    args, @"ProgramArguments",
                    [NSNumber numberWithBool:TRUE], @"LaunchOnlyOnce",
                    date, @"StartCalendarInterval",
                    nil];
}
@end
