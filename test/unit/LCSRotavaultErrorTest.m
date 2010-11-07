//
//  LCSRotavaultErrorTest.m
//  rotavault
//
//  Created by Lorenz Schori on 15.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSRotavaultError.h"


@interface LCSRotavaultErrorTest : GHTestCase    
@end

@implementation LCSRotavaultErrorTest
-(void)testMinimalError
{
    NSError *error = LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError);
    
    GHAssertNotNil(error, @"An error object must have been created");
    GHAssertEqualObjects([error domain], NSCocoaErrorDomain, @"The correct error domain must have been set");
    GHAssertEquals([error code], (NSInteger)NSUserCancelledError, @"The correct error code must have been set");
    GHAssertTrue([[error userInfo] isKindOfClass:[NSDictionary class]],
                         @"The error must contain a userInfo dictionary");
    GHAssertEquals([[error userInfo] count], (NSUInteger)3,
                   @"The user info must contain two objects (source file and source line, class and selector");
}

-(void)testComplexError
{
    NSError *underlyingError = LCSERROR_METHOD(NSPOSIXErrorDomain, NSExecutableLoadError);
    NSError *error = LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError,
                                     LCSERROR_LOCALIZED_DESCRIPTION(@"Something happened in executable %@", @"/usr/bin/false"),
                                     LCSERROR_LOCALIZED_FAILURE_REASON(@"The binary returned a non-zero status code"),
                                     LCSERROR_UNDERLYING_ERROR(underlyingError));
    
    GHAssertEquals([[error userInfo] count], (NSUInteger)6,
                   @"The user info must contain two objects (source file/line/class/selector, description, underlying error");
}

- (void)testLocalizedFailureReasonFromErrno
{
    NSString *expect = @"Operation not permitted";
    NSString *actual = LCSErrorLocalizedFailureReasonFromErrno(EPERM);
    GHAssertEqualObjects(expect, actual, @"Unexpected error reason reported");
}
@end
