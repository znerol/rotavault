//
//  LCSAppleRAIDWaitRebuildCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandTemp.h"


@interface LCSAppleRAIDMonitorRebuildCommand : NSObject <LCSCommandTemp> {
    NSString *raidsetUUID;
    NSString *memberDevpath;
    
    LCSCommandController *listraidctl;
    NSTimeInterval updateInterval;
}
+ (LCSAppleRAIDMonitorRebuildCommand*)commandWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
- (id)initWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
@property(assign) NSTimeInterval updateInterval;
@end
