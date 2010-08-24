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
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:paramValues keyPath:@"foo"];
    STAssertTrue([inputParam1.value isEqualToString:@"one"], @"Value of parameter must be reported correctly");

    LCSKeyValueOperationInputParameter *inputParam2 = 
        [[LCSKeyValueOperationInputParameter alloc] initWithTarget:paramValues keyPath:@"more.stuff"];
    STAssertTrue([inputParam2.value isEqualToString:@"two"],
                 @"Extraction of parameter value also must work with key paths");

    [paramValues setValue:@"changed" forKeyPath:@"foo"];
    STAssertTrue([inputParam1.value isEqualToString:@"changed"], @"Parameter must return the actual (changed) value");
    [inputParam1 release];
    [inputParam2 release];
}

-(void)testKeyValueOperationOutputParameterNoThreads
{
    NSMutableDictionary* paramValues = [NSMutableDictionary dictionaryWithCapacity:2];
    [paramValues setValue:@"to be overwritten" forKeyPath:@"foo"];
    [paramValues setValue:[NSMutableDictionary dictionary] forKeyPath:@"more"];
    [paramValues setValue:[NSNull null] forKeyPath:@"more.stuff"];

    LCSKeyValueOperationOutputParameter *outParam1 = 
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:paramValues keyPath:@"foo"];
    STAssertTrue([[paramValues valueForKey:@"foo"] isEqualToString:@"to be overwritten"],
                  @"Output parameter must not be set before property assignement");
    outParam1.value = @"new value";
    STAssertTrue([[paramValues valueForKey:@"foo"] isEqualToString:@"new value"],
                  @"Output parameter must be set correctly");

    LCSKeyValueOperationOutputParameter *outParam2 = 
        [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:paramValues keyPath:@"more.stuff"];
    STAssertTrue([[paramValues valueForKeyPath:@"more.stuff"] isEqualTo:[NSNull null]],
                 @"Output parameter must not be set before property assignement");
    outParam2.value = @"changed";
    STAssertTrue([[paramValues valueForKeyPath:@"more.stuff"] isEqualToString:@"changed"],
                 @"Output parameter must be set correctly also using a key path");
    [outParam1 release];
    [outParam2 release];
}

@end
