//
//  LCSBlockCopyOperationTest.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LCSTestdir.h"


@interface LCSBlockCopyOperationTest : SenTestCase {
    LCSTestdir *testdir;
    float progress;
    NSError *error;
    NSDictionary *result;
}

@end
