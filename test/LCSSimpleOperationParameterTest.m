//
//  LCSSimpleOperationParameterTest.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSimpleOperationParameterTest.h"


@implementation LCSSimpleOperationParameterTest

-(void)testSimpleOperationInputParameterNoThread
{
    NSMutableString* paramValue = [NSMutableString stringWithString:@"Test"];
    LCSSimpleOperationInputParameter* inparam = [[LCSSimpleOperationInputParameter alloc] initWithValue:paramValue];
    STAssertTrue([inparam.value isEqualToString:@"Test"], @"%@", @"Parameter value must be set correctly");
    [paramValue appendString:@" copy Test"];
    STAssertTrue([inparam.value isEqualToString:@"Test"], @"%@", @"Parameter value must be a copy of original value");
    [inparam release];
}

-(void)testSimpleOperationOutputParameterNoThread
{
    NSString* returnValue = nil;
    LCSSimpleOperationOutputParameter* outparam =
        [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&returnValue];
    STAssertNil(returnValue, @"%@", @"Return value must be nil before assignement");
    outparam.value = @"Test";
    STAssertNotNil(returnValue, @"%@", @"Return value must not be nil after assignement");
    STAssertTrue([returnValue isEqualToString:@"Test"], @"%@", @"Return value must be equal to the test string");
    [outparam release];
}
@end
