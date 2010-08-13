//
//  LCSOperationParameterMarker.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSOperationParameterMarker.h"


@implementation LCSOperationRequiredInputParameterMarker
-(id)value
{
    NSAssert(YES, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
    return nil; /* suppress complier warning */
}
@end

@implementation LCSOperationRequiredInOutParameterMarker
-(id)value
{
    NSAssert(YES, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
    return nil; /* suppress complier warning */
}

-(void)setValue:(id)newValue
{
    NSAssert(YES, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
}
@end

@implementation LCSOperationRequiredOutputParameterMarker
-(id)value
{
    NSAssert(YES, @"Tried to assign a value to an output only parameter");
    return nil; /* suppress complier warning */
}

-(void)setValue:(id)newValue
{
    NSAssert(YES, [NSString stringWithFormat:@"Attempt to access the value of an unset input parameter."]);
}
@end

@implementation LCSOperationOptionalInputParameterMarker
@synthesize value;

-(id)initWithDefaultValue:(id)defaultValue
{
    self = [super init];
    value = [defaultValue retain];
    return self;
}

-(void)dealloc
{
    [value release];
    [super dealloc];
}
@end

@implementation LCSOperationOptionalInOutParameterMarker
@synthesize value;

-(id)initWithDefaultValue:(id)defaultValue
{
    self = [super init];
    value = [defaultValue retain];
    return self;
}

-(void)dealloc
{
    [value release];
    [super dealloc];
}
@end

@implementation LCSOperationOptionalOutputParameterMarker
-(id)value
{
    NSAssert(YES, @"Tried to assign a value to an output only parameter");
    return nil; /* suppress complier warning */
}

-(void)setValue:(id)newValue
{
    /* ignored */
}
@end
