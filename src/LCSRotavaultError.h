//
//  LCSRotavaultError.h
//  rotavault
//
//  Created by Lorenz Schori on 15.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* LCSRotavaultErrorDomain;

/* user info dictionary keys */
extern NSString* LCSSourceFileNameKey;
extern NSString* LCSSourceFileLineNumberKey;

/* error codes */
enum {
    LCSExecutableReturnedNonZeroStatus  = 1,
    LCSLaunchOfExecutableFailed         = 2,
    LCSUnexpectedOutputReceived         = 3,
    LCSUnexpectedInputReceived          = 4
};

#define LCSERROR_BEGIN(errdomain, errcode) \
    [NSError errorWithDomain:errdomain code:errcode userInfo: \
        [NSDictionary dictionaryWithObjectsAndKeys: \
            [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding], LCSSourceFileNameKey, \
            [NSNumber numberWithInt:__LINE__], LCSSourceFileLineNumberKey,

#define LCSERROR_ADD_LOCALIZED_DESCRIPTION(fmt...) \
    [NSString localizedStringWithFormat:fmt], NSLocalizedDescriptionKey,

#define LCSERROR_ADD_LOCALIZED_FAILURE_REASON(fmt...) \
    [NSString localizedStringWithFormat:fmt], NSLocalizedFailureReasonErrorKey,

#define LCSERROR_ADD_UNDERLYING_ERROR(underlyingError) \
    underlyingError, NSUnderlyingErrorKey,

#define LCSERROR_END \
    nil]]

