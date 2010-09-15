//
//  LCSRotavaultErrorTest.m
//  rotavault
//
//  Created by Lorenz Schori on 15.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultErrorTest.h"
#import "LCSRotavaultError.h"


@implementation LCSRotavaultErrorTest
-(void)testMinimalError
{
    NSError *error = LCSERROR_BEGIN(NSCocoaErrorDomain, NSUserCancelledError) LCSERROR_END;
    
    STAssertNotNil(error, @"An error object must have been created");
    STAssertEqualObjects([error domain], NSCocoaErrorDomain, @"The correct error domain must have been set");
    STAssertEquals([error code], (NSInteger)NSUserCancelledError, @"The correct error code must have been set");
    STAssertTrue([[error userInfo] isKindOfClass:[NSDictionary class]],
                         @"The error must contain a userInfo dictionary");
    STAssertEquals([[error userInfo] count], (NSUInteger)2,
                   @"The user info must contain two objects (source file and source line");
}
-(void)testComplexError
{
    NSError *underlyingError = LCSERROR_BEGIN(NSPOSIXErrorDomain, NSExecutableLoadError) LCSERROR_END;
    NSError *error = LCSERROR_BEGIN(NSCocoaErrorDomain, NSUserCancelledError)
        LCSERROR_ADD_LOCALIZED_DESCRIPTION(@"Something happened in executable %@", @"/usr/bin/false")
        LCSERROR_ADD_LOCALIZED_FAILURE_REASON(@"The binary returned a non-zero status code")
        LCSERROR_ADD_UNDERLYING_ERROR(underlyingError)
    LCSERROR_END;
    
    STAssertEquals([[error userInfo] count], (NSUInteger)5,
                   @"The user info must contain two objects (source file/line, description, underlying error");
}    
@end
