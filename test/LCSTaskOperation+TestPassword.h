//
//  LCSHdiUtilWithProgressOperation+TestPassword.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSTaskOperation (TestPassword)
- (void)injectTestPassword:(NSString*)password;
@end
