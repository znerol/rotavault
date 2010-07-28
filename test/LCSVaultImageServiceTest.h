//
//  LCSVaultImageServiceTest.h
//  rotavault
//
//  Created by Lorenz Schori on 22.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface LCSVaultImageServiceTest : SenTestCase {
    NSString        *tempdirPath;
}

/**
 * Callback helper for LCSTestStatusReporter
 */
- (void)failWithStatus:(int)status message:(NSString*)message;
@end
