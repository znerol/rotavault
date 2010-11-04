//
//  LCSPredicateVerifier.h
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSVerifier.h"


@interface LCSPredicateVerifier : LCSVerifier {
    NSPredicate*    predicate;
    id              object;
}
@property(retain) NSPredicate*  predicate;
@property(retain) id            object;
@end
