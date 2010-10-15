//
//  LCSAppleRAIDWaitRebuildCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSAppleRAIDMonitorRebuildCommand : NSObject <LCSCommand> {
    NSString *raidsetUUID;
    NSString *memberDevpath;
    
    LCSCommandController *listraidctl;
}
+ (LCSAppleRAIDMonitorRebuildCommand*)commandWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
- (id)initWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
@end
