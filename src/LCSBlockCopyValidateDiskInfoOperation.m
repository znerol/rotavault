//
//  LCSBlockCopyValidateDiskInfoOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyValidateDiskInfoOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultError.h"


@implementation LCSBlockCopyValidateDiskInfoOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    sourceInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourceInfo);

    targetInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetInfo);

    bootdiskInfo = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(bootdiskInfo);
    
    return self;
}

-(void)dealloc
{
    [sourceInfo release];
    [targetInfo release];
    [bootdiskInfo release];
    [super dealloc];
}

@synthesize sourceInfo;
@synthesize targetInfo;
@synthesize bootdiskInfo;

-(void)execute
{
    NSDictionary *sinfo = [[sourceInfo.inValue copy] autorelease];
    NSDictionary *tinfo = [[targetInfo.inValue copy] autorelease];
    NSDictionary *binfo = [[bootdiskInfo.inValue copy] autorelease];

    /* error if source device is the startup disk */
    if ([sinfo isEqual:binfo]) {
        NSDictionary *userInfo = 
        [NSDictionary dictionaryWithObject:@"block copy operation from startup disk is not supported"
                                    forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                         userInfo:userInfo];
        [self handleError:error];
        return;
    }

    /* error if source and target are the same */
    if ([sinfo isEqual:tinfo]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"sourcedev and targetdev may not be the same"
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                         userInfo:userInfo];
        [self handleError:error];
        return;
    }

    /* error if target disk is mounted */
    if (![[tinfo objectForKey:@"MountPoint"] isEqualToString:@""])
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"targetdev must not be mounted"
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                         userInfo:userInfo];
        [self handleError:error];
        return;
    }

    /* error if target device is not big enough to hold contents from source */
    if ([[sinfo objectForKey:@"TotalSize"] longLongValue] > [[tinfo objectForKey:@"TotalSize"] longLongValue]) {
        NSDictionary *userInfo =
            [NSDictionary dictionaryWithObject:@"targetdev is too small to hold all contents of sourcedev"
                                        forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                         userInfo:userInfo];
        [self handleError:error];
        return;
    }
}
@end
