//
//  LCSSimpleOperationParameter.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSimpleOperationParameter.h"
#import "LCSInitMacros.h"


@implementation LCSSimpleOperationInputParameter
+(LCSSimpleOperationInputParameter*)parameterWithValue:(id)newValue
{
    return [[[LCSSimpleOperationInputParameter alloc] initWithValue:newValue] autorelease];
}

-(id)initWithValue:(id)newValue
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    value = [newValue copy];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(value);
    return self;
}

-(void)dealloc
{
    [value release];
    [super dealloc];
}

-(id)inValue
{
    return value;
}
@end

@implementation LCSSimpleOperationOutputParameter
+(LCSSimpleOperationOutputParameter*)parameterWithReturnValue:(id *)returnPointer
{
    return [[[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:returnPointer] autorelease];
}

-(id)initWithReturnValue:(id *)returnPointer
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    value = returnPointer;
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(value);
    return self;
}

-(id)outValue
{
    NSAssert(0, @"Tried to read a value from an output only parameter");
    return nil; /* suppress complier warning */
}

-(void)setValueOnMainThread:(id)newValue
{
    id tmp = [newValue copy];
    [*value release];
    *value = tmp;
}

-(void)setOutValue:(id)newValue
{
    [self performSelectorOnMainThread:@selector(setValueOnMainThread:) withObject:newValue waitUntilDone:YES];
}
@end
