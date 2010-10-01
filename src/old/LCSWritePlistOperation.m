//
//  LCSWritePlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSWritePlistOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultError.h"


@implementation LCSWritePlistOperation
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    plist = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plist);
    
    plistPath = [[LCSOperationRequiredInOutParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(plistPath);
    
    return self;
}

-(void)dealloc
{
    [plist release];
    [plistPath release];
    [super dealloc];
}

@synthesize plist;
@synthesize plistPath;

-(void)execute
{
    NSString *errstring = nil;
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:plist.inValue
                                                              format:NSPropertyListXMLFormat_v1_0
                                                    errorDescription:&errstring];
    if (!data) {
        error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                LCSERROR_LOCALIZED_FAILURE_REASON(errstring));
        [self handleError:error];
        return;
    }

    /* Write the data to a temporary file if the path-parameter is not set */
    NSString* path = plistPath.inOutValue;
    if(!path) {
        static const char template[] = "/tmp/plist.XXXXXXXX";
        char *pathBuffer = malloc(sizeof(template));
        memcpy(pathBuffer, template, sizeof(template));
        pathBuffer[sizeof(template)-1]=0;

        int fd = mkstemp(pathBuffer);
        path = [NSString stringWithCString:pathBuffer encoding:NSASCIIStringEncoding];
        free(pathBuffer);

        NSFileHandle *fh = [[NSFileHandle alloc] initWithFileDescriptor:fd closeOnDealloc:NO];
        @try {
            [fh writeData:data];
            plistPath.inOutValue = path;
        }
        @catch (NSException * e) {
            error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                    LCSERROR_LOCALIZED_FAILURE_REASON([e description]));
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
        BOOL ok = [data writeToFile:plistPath.inOutValue options:NSAtomicWrite error:&error];
        if (!ok) {
            [self handleError:error];
            return;
        }
    }
}
@end
