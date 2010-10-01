//
//  LCSBlockCopyValidateDiskInfoOperationTest.h
//  rotavault
//
//  Created by Lorenz Schori on 04.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface LCSBlockCopyValidateDiskInfoOperationTest : SenTestCase {
    NSError *error;
    NSDictionary *sourceInfo;
    NSDictionary *targetInfo;
    NSDictionary *smallTargetInfo;
    NSDictionary *bootdiskInfo;
}

@end
