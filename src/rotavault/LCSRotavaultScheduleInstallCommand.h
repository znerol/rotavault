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
    NSString *sourceDevice;
    NSString *targetDevice;

    LCSCommandController *launchdInfoCtl;
    LCSCommandController *sourceInfoCtl;
    LCSCommandController *targetInfoCtl;
    LCSCommandController *startupInfoCtl;

    NSString *rvcopydLaunchPath;
    NSString *rvcopydLabel;
    
    NSString *launchdPlistPath;
    NSDictionary *launchdPlist;
    NSDate *runAtDate;
}

@property(copy) NSString *rvcopydLaunchPath;
@property(copy) NSString *rvcopydLabel;

+(LCSRotavaultScheduleInstallCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                                 targetDevice:(NSString*)targetdev
                                                      runDate:(NSDate*)runDate;
-(id)initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev runDate:(NSDate*)runDate;
@end
