//
//  LCSVerifier.m
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVerifier.h"


@implementation LCSVerifier
@synthesize evaluated;
@synthesize passed;
@synthesize title;
@synthesize message;
@synthesize depends;

- (void)dealloc
{
    [title release];
    [message release];
    [depends release];
    [super dealloc];
}

- (void)performEvaluation
{
    self.passed = NO;
    self.evaluated = YES;
}

- (void)evaluate
{
    self.evaluated = NO;
    if ([self valueForKeyPath:@"depends.passed"]) {
        self.passed = NO;
        return;
    }
    
    [self performEvaluation];
}
@end
