//
//  LCSRotavaultScheduleInstallCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSBatchCommand.h"


@interface LCSRotavaultScheduleInstallCommand : LCSBatchCommand {
    NSString *rvcopydLabel;
    NSString *method;
    NSString *sourceDevice;
    NSString *targetDevice;
    
    LCSCommand *sourceInfoCtl;
    LCSCommand *targetInfoCtl;
    LCSCommand *startupInfoCtl;

    NSString *rvcopydLaunchPath;
    
    NSString *launchdPlistPath;
    NSDictionary *launchdPlist;
    NSDate *runAtDate;
    AuthorizationRef authorization;
}

@property(copy) NSString *rvcopydLaunchPath;

+(LCSRotavaultScheduleInstallCommand*)commandWithLabel:(NSString*)label
                                                method:(NSString*)bcmethod
                                          sourceDevice:(NSString*)sourcedev
                                          targetDevice:(NSString*)targetdev
                                               runDate:(NSDate*)runDate
                                     withAuthorization:(AuthorizationRef)auth;
-(id)initWithLabel:(NSString*)label
            method:(NSString*)bcmethod
      sourceDevice:(NSString*)sourcedev
      targetDevice:(NSString*)targetdev
           runDate:(NSDate*)runDate
 withAuthorization:(AuthorizationRef)auth;
@end
