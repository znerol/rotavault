//
//  LCSGenerateRotavaultCopyLaunchdPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSGenerateRotavaultCopyLaunchdPlistOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"


@implementation LCSGenerateRotavaultCopyLaunchdPlistOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    runAtDate = [[LCSOperationOptionalInputParameterMarker alloc] initWithDefaultValue:nil];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(runAtDate);
    
    sourceInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfo);
    
    targetInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfo);
    
    rvcopydLaunchPath = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(rvcopydLaunchPath);
    
    result = [[LCSOperationOptionalOutputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(result);

    return self;
}

-(void)dealloc
{
    [runAtDate release];
    [sourceInfo release];
    [targetInfo release];
    [result release];
    [super dealloc];
}

@synthesize runAtDate;
@synthesize sourceInfo;
@synthesize targetInfo;
@synthesize rvcopydLaunchPath;
@synthesize result;

-(void)execute
{
    NSString *sourceDevice = [sourceInfo.inValue objectForKey:@"DeviceNode"];
    NSString *sourceUUID = [sourceInfo.inValue objectForKey:@"VolumeUUID"];
    NSString *targetDevice = [targetInfo.inValue objectForKey:@"DeviceNode"];
    NSString *targetSHA1 = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:targetInfo.inValue] stringWithHexBytes];

    // FIXME: handle nil/empty values
    NSArray *args = [NSArray arrayWithObjects:rvcopydLaunchPath.inValue, @"-sourcedev", sourceDevice, @"-targetdev",
                     targetDevice, @"-sourcecheck", [NSString stringWithFormat:@"uuid:%@", sourceUUID], @"-targetcheck", 
                     [NSString stringWithFormat:@"sha1:%@", targetSHA1], nil];

    NSString *runKey;
    id runValue;
    if (runAtDate.inValue) {
        runKey = @"StartCalendarInterval";
        NSDateFormatter *minFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [minFormatter setDateFormat:@"mm"];
        NSDateFormatter *hourFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [hourFormatter setDateFormat:@"HH"];
        NSDateFormatter *dayFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dayFormatter setDateFormat:@"dd"];
        NSDateFormatter *monthFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [monthFormatter setDateFormat:@"MM"];
        NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [numberFormatter setAllowsFloats:NO];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

        runValue = [NSDictionary dictionaryWithObjectsAndKeys:
                    [numberFormatter numberFromString:[minFormatter stringFromDate:runAtDate.inValue]], @"Minute",
                    [numberFormatter numberFromString:[hourFormatter stringFromDate:runAtDate.inValue]], @"Hour",
                    [numberFormatter numberFromString:[dayFormatter stringFromDate:runAtDate.inValue]], @"Day",
                    [numberFormatter numberFromString:[monthFormatter stringFromDate:runAtDate.inValue]], @"Month",
                    nil];
    }
    else {
        runKey = @"RunAtLoad";
        runValue = [NSNumber numberWithBool:YES];
    }

    result.outValue = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"ch.znerol.rvcopyd", @"Label",
                       args, @"ProgramArguments",
                       [NSNumber numberWithBool:YES], @"LaunchOnlyOnce",
                       runValue, runKey,
                       nil];
}
@end
