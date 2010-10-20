//
//  LCSRotavaultPrivilegedJobInstallCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExecuteBASCommand.h"


@interface LCSRotavaultPrivilegedJobInstallCommand : LCSExecuteBASCommand
+ (LCSRotavaultPrivilegedJobInstallCommand*)privilegedJobInstallCommandWithLabel:(NSString*)label
                                                                                   method:(NSString*)method
                                                                                  runDate:(NSDate*)runDate
                                                                                   source:(NSString*)source
                                                                                   target:(NSString*)target
                                                                           sourceChecksum:(NSString*)sourceChecksum
                                                                           targetChecksum:(NSString*)targetChecksum
                                                                            authorization:(AuthorizationRef)auth;

- (id)initPrivilegedJobInstallCommandWithLabel:(NSString*)label
                                        method:(NSString*)method
                                       runDate:(NSDate*)runDate
                                        source:(NSString*)source
                                        target:(NSString*)target
                                sourceChecksum:(NSString*)sourceChecksum
                                targetChecksum:(NSString*)targetChecksum
                                 authorization:(AuthorizationRef)auth;
@end
