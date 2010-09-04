//
//  LCSOperationQueueOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 04.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationQueueOperationTest.h"
#import "LCSOperationQueueOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"


@interface LCSTestOperation1 : LCSOperation
{
    id <LCSOperationInputParameter> param;
    id <LCSOperationOutputParameter> result;
}
@property(retain) id <LCSOperationInputParameter> param;
@property(retain) id <LCSOperationOutputParameter> result;
@end

@implementation LCSTestOperation1
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    param = [[LCSOperationRequiredInputParameterMarker alloc] init];
    result = [[LCSOperationRequiredOutputParameterMarker alloc] init];
    if (!param || !result) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [param release];
    [result release];
    [super dealloc];
}

@synthesize param;
@synthesize result;

-(void)execute
{
    result.value = param.value;
}
@end

@interface LCSTestQueueOperation1 : LCSOperationQueueOperation
{
    id transit;
    LCSTestOperation1 *op1;
    LCSTestOperation1 *op2;
    id <LCSOperationInputParameter> param;
    id <LCSOperationOutputParameter> result;
}
@property(retain) id <LCSOperationInputParameter> param;
@property(retain) id <LCSOperationOutputParameter> result;
@end

@implementation LCSTestQueueOperation1
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }    
    op1 = [[LCSTestOperation1 alloc] init];
    /* op1.param */
    op1.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"transit"];
    [queue addOperation:op1];
    
    op2 = [[LCSTestOperation1 alloc] init];
    op2.param = [[LCSKeyValueOperationInputParameter alloc] initWithTarget:self keyPath:@"transit"];
    /* op2.result */
    [op2 addDependency:op1];
    [queue addOperation:op2];
    if (!op1 || !op2) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [op1 release];
    [op2 release];
    [super dealloc];
}

-(void)setParam:(id <LCSOperationInputParameter>)inParam
{
    [op1 setParam:inParam];
}

-(id <LCSOperationInputParameter>)param
{
    return [op1 param];
}

-(void)setResult:(id <LCSOperationOutputParameter>)inResult
{
    [op2 setResult:inResult];
}

-(id <LCSOperationOutputParameter>)result
{
    return [op2 result];
}
@end


@implementation LCSOperationQueueOperationTest
-(void)testOperationQueueOperation
{
    id result = nil;

    LCSTestQueueOperation1 *qop = [[LCSTestQueueOperation1 alloc] init];
    qop.delegate = self;
    qop.param = [[[LCSSimpleOperationInputParameter alloc] initWithValue:@"Test"] autorelease];;
    qop.result = [[[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result] autorelease];
    [qop start];
    
    STAssertEqualObjects(@"Test", result, @"Queue operation should copy objects from param to result");
    
    [qop release];
}

-(void)testOperationQueueOperationCancelBeforeStart
{
    id result = nil;
    
    LCSTestQueueOperation1 *qop = [[LCSTestQueueOperation1 alloc] init];
    qop.delegate = self;
    qop.param = [[[LCSSimpleOperationInputParameter alloc] initWithValue:@"Test"] autorelease];;
    qop.result = [[[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result] autorelease];
    [qop cancel];
    [qop start];
    
    STAssertNil(result, @"Nil expected as a result for a run-call to a cancelled queue");
    
    [qop release];
}

@end
