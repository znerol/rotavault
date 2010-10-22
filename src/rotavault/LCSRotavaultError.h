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
extern NSString* LCSSourceFileFunctionKey;
extern NSString* LCSSourceFileSelectorKey;
extern NSString* LCSSourceFileObjectKey;

/* user info dictionary keys for task operaiton errors */
extern NSString* LCSExecutableLaunchPathKey;
extern NSString* LCSExecutableTerminationStatusKey;

/* error codes */
enum {
    LCSExecutableReturnedNonZeroStatusError,
    LCSLaunchOfExecutableFailedError,
    LCSUnexpectedOutputReceivedError,
    LCSUnexpectedInputReceivedError,
    LCSParameterError,
    LCSPropertyListParseError,
    LCSPropertyListSerializationError,
    LCSSubcommandWasCancelledError
};

#define LCSERROR_FUNCTION(errdomain, errcode, ...) \
    [NSError errorWithDomain:errdomain code:errcode userInfo: \
        [NSDictionary dictionaryWithObjectsAndKeys: \
            [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding], LCSSourceFileNameKey, \
            [NSNumber numberWithInt:__LINE__], LCSSourceFileLineNumberKey, \
            [NSString stringWithCString:__func__], LCSSourceFileFunctionKey, ## __VA_ARGS__, nil]]

#define LCSERROR_METHOD(errdomain, errcode, ...) \
    [NSError errorWithDomain:errdomain code:errcode userInfo: \
        [NSDictionary dictionaryWithObjectsAndKeys: \
            [NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding], LCSSourceFileNameKey, \
            [NSNumber numberWithInt:__LINE__], LCSSourceFileLineNumberKey, \
            NSStringFromSelector(_cmd), LCSSourceFileSelectorKey, \
            [self description], LCSSourceFileObjectKey, ## __VA_ARGS__, nil]]

#define LCSERROR_LOCALIZED_DESCRIPTION(fmt...) \
    [NSString localizedStringWithFormat:fmt], NSLocalizedDescriptionKey

#define LCSERROR_LOCALIZED_FAILURE_REASON(fmt...) \
    [NSString localizedStringWithFormat:fmt], NSLocalizedFailureReasonErrorKey

#define LCSERROR_EXECUTABLE_LAUNCH_PATH(path) \
    path, LCSExecutableLaunchPathKey

#define LCSERROR_EXECUTABLE_TERMINATION_STATUS(status) \
    [NSNumber numberWithInt:status], LCSExecutableTerminationStatusKey

#define LCSERROR_UNDERLYING_ERROR(underlyingError) \
    underlyingError, NSUnderlyingErrorKey

NSString* LCSErrorLocalizedFailureReasonFromErrno(int errnoValue);
