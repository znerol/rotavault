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
        
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Block copy operation from startup disk is not supported"));
        [self handleError:error];
        return;
    }

    /* error if source and target are the same */
    if ([sinfo isEqual:tinfo]) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Source and target may not be the same"));
        [self handleError:error];
        return;
    }

    /* error if target disk is mounted */
    if (![[tinfo objectForKey:@"MountPoint"] isEqualToString:@""])
    {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Target must not be mounted"));
        [self handleError:error];
        return;
    }

    /* error if target device is not big enough to hold contents from source */
    if ([[sinfo objectForKey:@"TotalSize"] longLongValue] > [[tinfo objectForKey:@"TotalSize"] longLongValue]) {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSParameterError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Target is too small to hold all content of source"));
        [self handleError:error];
        return;
    }
}
@end
