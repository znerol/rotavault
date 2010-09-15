//
//  LCSKeyValueOperationParameterTest.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSKeyValueOperationParameterTest.h"


@implementation LCSKeyValueOperationParameterTest
-(void)testKeyValueOperationInputParameterNoThreads
{
    NSMutableDictionary* paramValues = [NSMutableDictionary dictionaryWithCapacity:2];
    [paramValues setValue:@"one" forKeyPath:@"foo"];
    [paramValues setValue:[NSMutableDictionary dictionary] forKeyPath:@"more"];
    [paramValues setValue:@"two" forKeyPath:@"more.stuff"];

    LCSKeyValueOperationInputParameter *inputParam1 =
        [LCSKeyValueOperationInputParameter parameterWithTarget:paramValues keyPath:@"foo"];
    STAssertTrue([inputParam1.inValue isEqualToString:@"one"], @"%@", @"Value of parameter must be reported correctly");

    LCSKeyValueOperationInputParameter *inputParam2 = 
        [LCSKeyValueOperationInputParameter parameterWithTarget:paramValues keyPath:@"more.stuff"];
    STAssertTrue([inputParam2.inValue isEqualToString:@"two"], @"%@",
                 @"Extraction of parameter value also must work with key paths");

    [paramValues setValue:@"changed" forKeyPath:@"foo"];
    STAssertTrue([inputParam1.inValue isEqualToString:@"changed"], @"%@",
                 @"Parameter must return the actual (changed) value");
}

-(void)testKeyValueOperationOutputParameterNoThreads
{
    NSMutableDictionary* paramValues = [NSMutableDictionary dictionaryWithCapacity:2];
    [paramValues setValue:@"to be overwritten" forKeyPath:@"foo"];
    [paramValues setValue:[NSMutableDictionary dictionary] forKeyPath:@"more"];
    [paramValues setValue:[NSNull null] forKeyPath:@"more.stuff"];

    LCSKeyValueOperationOutputParameter *outParam1 = 
        [LCSKeyValueOperationOutputParameter parameterWithTarget:paramValues keyPath:@"foo"];
    STAssertTrue([[paramValues valueForKey:@"foo"] isEqualToString:@"to be overwritten"], @"%@",
                  @"Output parameter must not be set before property assignement");
    outParam1.outValue = @"new value";
    STAssertTrue([[paramValues valueForKey:@"foo"] isEqualToString:@"new value"], @"%@",
                  @"Output parameter must be set correctly");

    LCSKeyValueOperationOutputParameter *outParam2 = 
        [LCSKeyValueOperationOutputParameter parameterWithTarget:paramValues keyPath:@"more.stuff"];
    STAssertTrue([[paramValues valueForKeyPath:@"more.stuff"] isEqualTo:[NSNull null]], @"%@",
                 @"Output parameter must not be set before property assignement");
    outParam2.outValue = @"changed";
    STAssertTrue([[paramValues valueForKeyPath:@"more.stuff"] isEqualToString:@"changed"], @"%@",
                 @"Output parameter must be set correctly also using a key path");
    
    @try {
        id test = outParam1.outValue;
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
