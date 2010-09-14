//
//  LCSKeyValueOperationParameter.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSKeyValueOperationParameter.h"
#import "LCSInitMacros.h"


@implementation LCSKeyValueOperationParameterBase
-(id)initWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    target = [targetObject retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(target);
    
    keyPath = [targetKeyPath copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(keyPath);
    
    targetThread = [NSThread currentThread];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetThread);
    return self;
}

-(void)dealloc
{
    [target release];
    [keyPath release];
    targetThread = nil;
    [super dealloc];
}

-(id)baseValue
{
    id returnValue;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [target methodSignatureForSelector:@selector(valueForKeyPath:)]];
    [inv setSelector:@selector(valueForKeyPath:)];
    [inv setArgument:&keyPath atIndex:2];
    
    [inv performSelector:@selector(invokeWithTarget:) onThread:targetThread withObject:target waitUntilDone:YES];
    [inv getReturnValue:&returnValue];
    return returnValue;
}

-(void)baseSetValueOnMainThread:(id)newValue
{
    /* we don't have to retain the value here because we expect our target to do this for us */
    [target setValue:newValue forKeyPath:keyPath];
}

-(void)baseSetValue:(id)newValue
{
    [self performSelector:@selector(baseSetValueOnMainThread:) onThread:targetThread withObject:newValue waitUntilDone:YES];
}
@end


@implementation LCSKeyValueOperationInputParameter
+(LCSKeyValueOperationInputParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath
{
    return [[[LCSKeyValueOperationInputParameter alloc] initWithTarget:targetObject keyPath:targetKeyPath] autorelease];
}

-(id)inValue
{
    return [super baseValue];
}
@end

@implementation LCSKeyValueOperationInOutParameter
+(LCSKeyValueOperationInOutParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath
{
    return [[[LCSKeyValueOperationInOutParameter alloc] initWithTarget:targetObject keyPath:targetKeyPath] autorelease];
}

-(id)inOutValue
{
    return [super baseValue];
}

-(void)setInOutValue:(id)newValue
{
    [super baseSetValue:newValue];
}
@end

@implementation LCSKeyValueOperationOutputParameter
+(LCSKeyValueOperationOutputParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString *)targetKeyPath
{
    return [[[LCSKeyValueOperationOutputParameter alloc] initWithTarget:targetObject keyPath:targetKeyPath] autorelease];
}
-(id)outValue
{
    NSAssert(0, @"Tried to read from an output-only parameter");
    return nil; /* suppress complier warning */
}

-(void)setOutValue:(id)newValue
{
    [super baseSetValue:newValue];
}
@end
