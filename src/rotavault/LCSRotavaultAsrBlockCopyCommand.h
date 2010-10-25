//
//  LCSRotavaultAsrBlockCopyCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSBatchCommand.h"


@interface LCSRotavaultAsrBlockCopyCommand : LCSBatchCommand
{
    NSString* sourceDevice;
    NSString* sourceChecksum;
    NSString* targetDevice;
    NSString* targetChecksum;
    
    BOOL needsSourceRemount;
    
    LCSCommand *sourceInfoCtl;
    LCSCommand *targetInfoCtl;
}

+(LCSRotavaultAsrBlockCopyCommand*)commandWithSourceDevice:(NSString*)sourcedev
                                         sourceChecksum:(NSString*)sourcecheck
                                           targetDevice:(NSString*)targetdev
                                         targetChecksum:(NSString*)targetcheck;

-(id)initWithSourceDevice:(NSString*)sourcedev
           sourceChecksum:(NSString*)sourcecheck
             targetDevice:(NSString*)targetdev
           targetChecksum:(NSString*)targetcheck;
@end
