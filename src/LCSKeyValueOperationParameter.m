//
//  LCSKeyValueOperationParameter.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSKeyValueOperationParameter.h"


@implementation LCSKeyValueOperationInputParameter
-(id)initWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath
{
    self = [super init];
    target = [targetObject retain];
    keyPath = [targetKeyPath copy];
    return self;
}

-(void)dealloc
{
    [target release];
    [keyPath release];
    [super dealloc];
}

-(id)value
{
    id returnValue;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [target methodSignatureForSelector:@selector(valueForKeyPath:)]];
    [inv setSelector:@selector(valueForKeyPath:)];
    [inv setArgument:&keyPath atIndex:2];

    [inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:target waitUntilDone:YES];
    [inv getReturnValue:&returnValue];
    return returnValue;
}
@end

@implementation LCSKeyValueOperationInOutParameter
-(id)value
{
    return [super value];
}

-(void)setValueOnMainThread:(id)newValue
{
    /* we don't have to retain the value here because we expect our target to do this for us */
    [target setValue:newValue forKeyPath:keyPath];
}

-(void)setValue:(id)newValue
{
    [self performSelectorOnMainThread:@selector(setValueOnMainThread:) withObject:newValue waitUntilDone:YES];
}
@end

@implementation LCSKeyValueOperationOutputParameter
-(id)value
{
    NSAssert(YES, @"Tried to assign a value to an output only parameter");
    return nil; /* suppress complier warning */
}

-(void)setValue:(id)newValue
{
    [super setValue:newValue];
}
@end
