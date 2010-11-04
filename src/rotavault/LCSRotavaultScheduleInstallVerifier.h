//
//  LCSRotavaultScheduleInstallVerifier.h
//  rotavault
//
//  Created by Lorenz Schori on 04.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSVerifier.h"


@interface LCSRotavaultScheduleInstallVerifier : LCSVerifier {
    NSArray *verifiers;
}
+ (LCSRotavaultScheduleInstallVerifier*)verifierWithMethod:(NSString*)bcmethod
                                              sourceDevice:(NSString*)sourcedev
                                              targetDevice:(NSString*)targetdev
                                                   runDate:(NSDate*)runDate
                                         systemEnvironment:(NSDictionary*)sysenv;

- (id)initWithMethod:(NSString*)bcmethod
        sourceDevice:(NSString*)sourcedev
        targetDevice:(NSString*)targetdev
             runDate:(NSDate*)runDate
   systemEnvironment:(NSDictionary*)sysenv;
@end
