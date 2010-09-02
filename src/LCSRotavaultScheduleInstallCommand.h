//
//  LCSRotavaultScheduleInstallCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSLaunchctlOperation.h"


@interface LCSRotavaultScheduleInstallCommand : LCSCommand {
    NSDictionary    *sourceInfo;
    NSDictionary    *targetInfo;
    NSDictionary    *launchdPlist;
    NSString        *plistPath;
    LCSLaunchctlRemoveOperation *launchctlRemoveOperation;
}
-(id)initWithSourceDevice:(NSString*)sourceDevice targetDevice:(NSString*)targetDevice runAt:(NSDate*)targetDate;
@end
