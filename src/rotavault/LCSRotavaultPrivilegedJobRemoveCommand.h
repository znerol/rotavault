//
//  LCSRotavaultPrivilegedJobRemoveCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExecuteBASCommand.h"


@interface LCSRotavaultPrivilegedJobRemoveCommand : LCSExecuteBASCommand
+ (LCSRotavaultPrivilegedJobRemoveCommand*)privilegedJobRemoveCommandWithLabel:(NSString*)label
                                                                          authorization:(AuthorizationRef)auth;
- (id)initPrivilegedJobRemoveCommandWithLabel:(NSString*)label authorization:(AuthorizationRef)auth;
@end
