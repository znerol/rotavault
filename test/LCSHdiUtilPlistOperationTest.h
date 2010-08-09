//
//  LCSHdiUtilPlistOperationTest.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "LCSTestdir.h"


@interface LCSHdiUtilPlistOperationTest : SenTestCase {
    LCSTestdir *testdir;
    NSString *imgpath;
    NSString *devpath;
    
    NSDictionary    *result;
    NSError         *error;
}

@end
