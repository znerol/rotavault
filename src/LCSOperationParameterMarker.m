//
//  LCSOperationParameterMarker.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationParameterMarker.h"
#import "LCSInitMacros.h"


@implementation LCSOperationRequiredInputParameterMarker
-(id)inValue
{
    NSAssert(0, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
    return nil; /* suppress compiler warning */
}
@end

@implementation LCSOperationRequiredInOutParameterMarker
-(id)inOutValue
{
    NSAssert(0, [NSString stringWithFormat:@"Attempt to access the value of an unset inout parameter."]);
    return nil; /* suppress compiler warning */
}

-(void)setInOutValue:(id)newValue
{
    NSAssert(0, [NSString stringWithFormat:@"Attempt to access the value of an unset inout parameter."]);
}
@end

@implementation LCSOperationRequiredOutputParameterMarker
-(id)outValue
{
    NSAssert(0, @"Tried to assign a value to an output only parameter");
    return nil; /* suppress compiler warning */
}

-(void)setOutValue:(id)newValue
{
    NSAssert(0, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
}
@end

@implementation LCSOperationOptionalInputParameterMarker
-(id)initWithDefaultValue:(id)defaultValue
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    value = [defaultValue retain];
    /* LCSINIT_RELEASE_AND_RETURN_IF_NIL(value); check for nil parameter omitted on purpose */
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

@implementation LCSOperationOptionalInOutParameterMarker
-(id)initWithDefaultValue:(id)defaultValue
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    value = [defaultValue retain];
    /* LCSINIT_RELEASE_AND_RETURN_IF_NIL(value); check for nil parameter omitted on purpose */
    return self;
}

-(void)dealloc
{
    [value release];
    [super dealloc];
}

-(id)inOutValue
{
    return value;
}

-(void)setInOutValue:(id)newValue
{
    if (value == newValue) {
        return;
    }
    [value release];
    value = [newValue retain];
}
@end

@implementation LCSOperationOptionalOutputParameterMarker
-(id)outValue
{
    NSAssert(0, @"Tried to assign a value to an output only parameter");
    return nil; /* suppress compiler warning */
}

-(void)setOutValue:(id)newValue
{
    /* ignored */
}
@end
