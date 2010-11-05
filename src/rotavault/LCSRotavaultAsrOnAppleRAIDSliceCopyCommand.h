//
//  LCSRotavaultAsrOnAppleRAIDSliceCopyCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 25.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSBatchCommand.h"


@interface LCSRotavaultAsrOnAppleRAIDSliceCopyCommand : LCSBatchCommand
{
    NSString* sourceDevice;
    NSString* sourceChecksum;
    NSString* targetDevice;
    NSString* targetChecksum;
    
    NSString* raidUUID;
    
    BOOL addSourceBackToRaid;
    BOOL noMonitorRebuild;
    
    LCSCommand *sourceInfoCtl;
    LCSCommand *targetInfoCtl;    
    LCSCommand *raidInfoCtl;
}

+(LCSRotavaultAsrOnAppleRAIDSliceCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                                       sourceChecksum:(NSString*)sourcecheck
                                                         targetDevice:(NSString*)targetdev
                                                       targetChecksum:(NSString*)targetcheck;

-(id)initWithSourceDevice:(NSString*)sourcedev
           sourceChecksum:(NSString*)sourcecheck
             targetDevice:(NSString*)targetdev
           targetChecksum:(NSString*)targetcheck;
@end
