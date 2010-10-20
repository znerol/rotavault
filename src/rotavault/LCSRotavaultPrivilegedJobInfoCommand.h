//
//  LCSRotavaultPrivilegedHelperToolCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExecuteBASCommand.h"


@interface LCSRotavaultPrivilegedJobInfoCommand : LCSExecuteBASCommand
+ (LCSRotavaultPrivilegedJobInfoCommand*)privilegedJobInfoCommandWithLabel:(NSString*)label
                                                             authorization:(AuthorizationRef)auth;
- (id)initPrivilegedJobInfoCommandWithLabel:(NSString*)label authorization:(AuthorizationRef)auth;
@end
