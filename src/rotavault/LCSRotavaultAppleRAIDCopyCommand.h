//
//  LCSRotavaultAppleRAIDCopyCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSBatchCommand.h"


@interface LCSRotavaultAppleRAIDCopyCommand : LCSBatchCommand
{
    NSString* sourceDevice;
    NSString* sourceChecksum;
    NSString* targetDevice;
    NSString* targetChecksum;
    
    NSString* raidUUID;
    
    LCSCommandController *sourceInfoCtl;
    LCSCommandController *targetInfoCtl;    
}

+(LCSRotavaultAppleRAIDCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                             sourceChecksum:(NSString*)sourcecheck
                                               targetDevice:(NSString*)targetdev
                                             targetChecksum:(NSString*)targetcheck;

-(id)initWithSourceDevice:(NSString*)sourcedev
           sourceChecksum:(NSString*)sourcecheck
             targetDevice:(NSString*)targetdev
           targetChecksum:(NSString*)targetcheck;
@end
