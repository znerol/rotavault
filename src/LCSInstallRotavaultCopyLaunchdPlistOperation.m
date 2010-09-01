//
//  LCSInstallRotavaultCopyLaunchdPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSInstallRotavaultCopyLaunchdPlistOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultErrorDomain.h"


@implementation LCSInstallRotavaultCopyLaunchdPlistOperation
-(id)init
{
    if(!(self = [super init])) {
        return nil;
    }

    launchdPlist = [[LCSOperationRequiredInOutParameterMarker alloc] init];
    installPath = [[LCSOperationOptionalInputParameterMarker alloc]
                   initWithDefaultValue:@"/Library/LaunchDaemons/ch.znerol.rvcopyd.plist"];
    
    if (!launchdPlist || !installPath) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [launchdPlist release];
    [installPath release];
    [super dealloc];
}

@synthesize launchdPlist;
@synthesize installPath;

-(void)execute
{
    NSString *errstring = nil;
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:launchdPlist.value
                                                              format:NSPropertyListXMLFormat_v1_0
                                                    errorDescription:&errstring];
    if (!data) {
        NSDictionary *errdict = [NSDictionary dictionaryWithObject:errstring forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedOutputReceived userInfo:errdict];
        [self handleError:error];
        return;
    }

    BOOL ok = [data writeToFile:installPath.value options:NSAtomicWrite error:&error];
    if (!ok) {
        [self handleError:error];
        return;
    }
}
@end
