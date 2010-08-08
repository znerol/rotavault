//
//  LCSPlistTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperation.h"
#import "LCSTaskOperationError.h"


@implementation LCSPlistTaskOperation

@synthesize result;

-(BOOL)parseOutput:(NSData*)data isAtEnd:(BOOL)atEnd error:(NSError**)outError
{
    BOOL ok = [super parseOutput:data isAtEnd:atEnd error:outError];

    if (!atEnd || !ok) {
        return ok;
    }

    /*
     * if we collected all data and it was successfully aggregated in the parents output property we try to interpret
     * as plist and store it into our result property.
     */
    NSString *errorDescription;
    result = [NSPropertyListSerialization propertyListFromData:[super output]
                                              mutabilityOption:0
                                                        format:nil
                                              errorDescription:&errorDescription];
    if (result) {
        /* success! */
        return YES;
    }

    /*
     * Something went wrong with the interpretation of the result. Let's construct an error object if our caller is
     * interested in it.
     */
    if (outError != nil) {
        *outError = [LCSTaskOperationError errorReceivedUnexpectedOutputFromLaunchPath:[super path]
                                                                               message:errorDescription];
    }
    return NO;
}

-(BOOL)hasProgress
{
    return YES;
}

@end
