//
//  LCSPredicateVerifier.m
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPredicateVerifier.h"


@implementation LCSPredicateVerifier
@synthesize predicate;
@synthesize object;

- (void)performEvaluation
{
    @try {
        self.passed = [predicate evaluateWithObject:object];
    }
    @catch (NSException * e) {
        NSLog(@"Caught exception while evaluating predicate:\n%@", [e description]);
        self.passed = NO;
    }
    self.evaluated = YES;
}
@end
