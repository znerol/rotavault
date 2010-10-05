//
//  LCSRotavaultScheduleInstallCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSCommandController.h"


@interface LCSRotavaultScheduleInstallCommand : NSObject <LCSCommand> {
    LCSCommandController *controller;
    id <LCSCommandRunner> runner;
    
    NSString *sourceDevice;
    NSString *targetDevice;
    NSMutableArray *activeControllers;
    
    NSDictionary *startupDiskInformation;
    NSDictionary *sourceDiskInformation;
    NSDictionary *targetDiskInformation;
    
    NSString *rvcopydLaunchPath;
    
    NSDictionary *launchctlInfo;
    NSString *launchdPlistPath;
    NSDictionary *launchdPlist;
    NSDate *runAtDate;
}

@property(retain) NSString *rvcopydLaunchPath;

+(LCSRotavaultScheduleInstallCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                                 targetDevice:(NSString*)targetdev
                                                      runDate:(NSDate*)runDate;
-(id)initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev runDate:(NSDate*)runDate;
@end
