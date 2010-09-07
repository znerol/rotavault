//
//  LCSOperationQueueOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 04.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationQueueOperationTest.h"
#import "LCSInitMacros.h"
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
    LCSINIT_SUPER_OR_RETURN_NIL();

    param = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(param);
    
    result = [[LCSOperationRequiredOutputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(result);
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
    result.outValue = param.inValue;
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
    LCSINIT_SUPER_OR_RETURN_NIL();

    op1 = [[LCSTestOperation1 alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(op1);
    /* op1.param intentionally left out */
    op1.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"transit"];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(op1.result);
    [queue addOperation:op1];
    
    op2 = [[LCSTestOperation1 alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(op2);
    op2.param = [LCSKeyValueOperationInputParameter parameterWithTarget:self keyPath:@"transit"];
    /* op2.result intentionally left out */
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(op2.param);    
    [op2 addDependency:op1];
    [queue addOperation:op2];

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
    qop.param = [LCSSimpleOperationInputParameter parameterWithValue:@"Test"];
    qop.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    [qop start];
    
    STAssertEqualObjects(@"Test", result, @"Queue operation should copy objects from param to result");
    
    [result release];
    [qop release];
}

-(void)testOperationQueueOperationCancelBeforeStart
{
    id result = nil;
    
    LCSTestQueueOperation1 *qop = [[LCSTestQueueOperation1 alloc] init];
    qop.delegate = self;
    qop.param = [LCSSimpleOperationInputParameter parameterWithValue:@"Test"];
    qop.result = [LCSSimpleOperationOutputParameter parameterWithReturnValue:&result];
    [qop cancel];
    [qop start];
    
    STAssertNil(result, @"Nil expected as a result for a run-call to a cancelled queue");
    
    [result release];
    [qop release];
}

@end
