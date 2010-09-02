//
//  LCSWritePlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSWritePlistOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultErrorDomain.h"


@implementation LCSWritePlistOperation
-(id)init
{
    if(!(self = [super init])) {
        return nil;
    }

    launchdPlist = [[LCSOperationRequiredInputParameterMarker alloc] init];
    plistPath = [[LCSOperationRequiredInOutParameterMarker alloc] init];
    
    if (!launchdPlist || !plistPath) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [launchdPlist release];
    [plistPath release];
    [super dealloc];
}

@synthesize launchdPlist;
@synthesize plistPath;

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

    /* Write the data to a temporary file if the path-parameter is not set */
    NSString* path = plistPath.value;
    if(!path) {
        int fd;
        char template[] = "/tmp/plist.XXXXXXXX";

        fd = mkstemp(template);
        path = [NSString stringWithCString:template];

        NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:NO];
        @try {
            [fh writeData:data];
            plistPath.value = path;
        }
        @catch (NSException * e) {
            NSDictionary *errdict = [NSDictionary dictionaryWithObject:[e description]
                                                                forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedOutputReceived userInfo:errdict];
            [self handleError:error];
            return;
        }
        @finally {
            [fh closeFile];
            [fh release];
        }
    }
    /* otherwise just dump the plist to the specified path */
    else {
        BOOL ok = [data writeToFile:plistPath.value options:NSAtomicWrite error:&error];
        if (!ok) {
            [self handleError:error];
            return;
        }
    }
}
@end
