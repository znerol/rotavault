//
//  LCSSimpleOperationParameter.m
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSSimpleOperationParameter.h"


@implementation LCSSimpleOperationInputParameter
@synthesize value;
-(id)initWithValue:(id)inValue
{
    self = [super init];
    value = [inValue copy];
    return self;
}

-(void)dealloc
{
    [value release];
    [super dealloc];
}
@end

@implementation LCSSimpleOperationOutputParameter
-(id)initWithReturnValue:(id *)outValue
{
    self = [super init];
    value = outValue;
    return self;
}

-(id)value
{
    NSAssert(YES, @"Tried to read a value from an output only parameter");
    return nil; /* suppress complier warning */
}

-(void)setValueOnMainThread:(id)newValue
{
    *value = newValue;
}

-(void)setValue:(id)newValue
{
    [self performSelectorOnMainThread:@selector(setValueOnMainThread:) withObject:newValue waitUntilDone:YES];
}
@end
