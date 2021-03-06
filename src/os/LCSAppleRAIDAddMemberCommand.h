//
//  LCSRAIDAddMember.h
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


@interface LCSAppleRAIDAddMemberCommand : LCSExternalCommand {
    NSPipe *stdoutPipe;
}
+ (LCSAppleRAIDAddMemberCommand*) commandWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
- (id)initWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath;
@end
