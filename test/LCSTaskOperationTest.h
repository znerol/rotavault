//
//  LCSTaskOperationTest.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface LCSTaskOperationTest : SenTestCase {
    BOOL launched;
    id mock;
    NSMutableData *dataout;
    NSMutableData *dataerr;    
}

@end
