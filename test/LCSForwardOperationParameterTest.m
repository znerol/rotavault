//
//  LCSForwardOperationParameterTest.m
//  rotavault
//
//  Created by Lorenz Schori on 14.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSForwardOperationParameterTest.h"
#import "LCSForwardOperationParameter.h"
#import <OCMock/OCMock.h>


@implementation LCSForwardOperationParameterTest

-(void)testForwardOperationInputParameter
{
    id mock = [OCMockObject mockForProtocol:@protocol(LCSOperationInputParameter)];
    [[[mock expect] andReturn:@"TEST"] inValue];
    
    LCSForwardOperationInputParameter *infw = [LCSForwardOperationInputParameter parameterWithParameterPointer:&mock];
    GHAssertEqualObjects(infw.inValue, @"TEST", @"Forwarding input parameter must pass the value to its target");
    
    [mock verify];
}

-(void)testForwardOperationOutputParameter
{
    id mock = [OCMockObject mockForProtocol:@protocol(LCSOperationOutputParameter)];
    [[mock expect] setOutValue:@"TEST"];
    
    LCSForwardOperationOutputParameter *outfw = [LCSForwardOperationOutputParameter parameterWithParameterPointer:&mock];
    outfw.outValue = @"TEST";
    
    [mock verify];
}

-(void)testForwardOperationInOutParameter
{
    id mock = [OCMockObject mockForProtocol:@protocol(LCSOperationInOutParameter)];
    [[[mock expect] andReturn:@"TEST INPUT"] inOutValue];
    [[mock expect] setInOutValue:@"TEST OUTPUT"];
    
    LCSForwardOperationInOutParameter *iofw = [LCSForwardOperationInOutParameter parameterWithParameterPointer:&mock];
    GHAssertEqualObjects(iofw.inOutValue, @"TEST INPUT", @"Forwarding input parameter must pass the value to its target");
    iofw.inOutValue = @"TEST OUTPUT";
    
    [mock verify];
}
    
@end
