//
//  LCSRotavaultError.m
//  rotavault
//
//  Created by Lorenz Schori on 15.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultError.h"


NSString* LCSRotavaultErrorDomain = @"ch.znerol.rotavault.ErrorDomain";

NSString* LCSSourceFileNameKey = @"ch.znerol.rotavault.LCSSourceFileName";
NSString* LCSSourceFileLineNumberKey = @"ch.znerol.rotavault.LCSSourceFileLineNumber";
NSString* LCSSourceFileFunctionKey = @"ch.znerol.rotavault.LCSSourceFileFunction";
NSString* LCSSourceFileSelectorKey = @"ch.znerol.rotavault.LCSSourceFileSelector";
NSString* LCSSourceFileObjectKey = @"ch.znerol.rotavault.LCSSourceFileObject";

NSString* LCSExecutableLaunchPathKey = @"ch.znerol.rotavault.LCSExecutableLaunchPath";
NSString* LCSExecutableTerminationStatusKey = @"ch.znerol.rotavault.LCSExecutableTerminationStatus";

NSString* LCSErrorLocalizedFailureReasonFromErrno(int errnoValue)
{
    // http://stackoverflow.com/questions/423248/what-size-should-i-allow-for-strerror-r
    char buf[256];
    
    int notok = strerror_r(errnoValue, buf, sizeof(buf));
    if (notok) {
        return nil;
    }
    
    buf[sizeof(buf)-1] = '\0';
    
    return [[[NSString alloc] initWithCString:buf encoding:NSUTF8StringEncoding] autorelease];
}
