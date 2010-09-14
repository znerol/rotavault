//
//  LCSForwardOperationParameter.m
//  rotavault
//
//  Created by Lorenz Schori on 14.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSForwardOperationParameter.h"
#import "LCSInitMacros.h"


@implementation LCSForwardOperationInputParameter
+(LCSForwardOperationInputParameter*)parameterWithParameterPointer:(id <LCSOperationInputParameter> *)paramPointer
{
    return [[[LCSForwardOperationInputParameter alloc] initWithInputParameterPointer:paramPointer] autorelease];
}

-(id)initWithInputParameterPointer:(id <LCSOperationInputParameter> *)paramPointer
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    ptr = paramPointer;
    return self;
}

-(id)inValue
{
    return [*ptr inValue];
}
@end



@implementation LCSForwardOperationInOutParameter
+(LCSForwardOperationInOutParameter*)parameterWithParameterPointer:(id <LCSOperationInOutParameter> *)paramPointer
{
    return [[[LCSForwardOperationInOutParameter alloc] initWithInOutParameterPointer:paramPointer] autorelease];
}

-(id)initWithInOutParameterPointer:(id <LCSOperationInOutParameter> *)paramPointer
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    ptr = paramPointer;
    return self;
}

-(id)inOutValue
{
    return [*ptr inOutValue];
}

-(void)setInOutValue:(id)newValue
{
    [*ptr setInOutValue:newValue];
}
@end



@implementation LCSForwardOperationOutputParameter
+(LCSForwardOperationOutputParameter*)parameterWithParameterPointer:(id <LCSOperationOutputParameter> *)paramPointer
{
    return [[[LCSForwardOperationOutputParameter alloc] initWithOutputParameterPointer:paramPointer] autorelease];
}

-(id)initWithOutputParameterPointer:(id <LCSOperationOutputParameter> *)paramPointer
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    ptr = paramPointer;
    return self;
}

-(id)outValue
{
    NSAssert(0, @"Tried to read from an output-only parameter");
    return nil; /* suppress complier warning */
}

-(void)setOutValue:(id)newOutValue
{
    [*ptr setOutValue:newOutValue];
}
@end
