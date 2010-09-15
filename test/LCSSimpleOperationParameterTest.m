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
    LCSSimpleOperationInputParameter* inparam = [LCSSimpleOperationInputParameter parameterWithValue:paramValue];
    STAssertEqualObjects(inparam.inValue, @"Test", @"Parameter value must be set correctly");
    [paramValue appendString:@" copy Test"];
    STAssertEqualObjects(inparam.inValue, @"Test", @"Parameter value must be a copy of original value");
}

-(void)testSimpleOperationOutputParameterNoThread
{
    NSString* returnValue = nil;
    LCSSimpleOperationOutputParameter* outparam =
        [LCSSimpleOperationOutputParameter parameterWithReturnValue:&returnValue];
    STAssertNil(returnValue, @"%@", @"Return value must be nil before assignement");
    outparam.outValue = [NSString stringWithString:@"Test"];
    STAssertNotNil(returnValue, @"%@", @"Return value must not be nil after assignement");
    STAssertTrue([returnValue isEqualToString:@"Test"], @"%@", @"Return value must be equal to the test string");
    [returnValue release];
    
    @try {
        id test = outparam.outValue;
        STFail(@"Read attempt from output parameter must throw an exception");
        test = nil;
    }
    @catch (NSException * e) {
        if (![[e name] isEqualToString:NSInternalInconsistencyException]) {
            @throw;
        }        
    }    
}
@end
