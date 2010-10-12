//
//  LCSQuickExternalCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 25.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


@interface LCSQuickExternalCommand : LCSExternalCommand {
    NSData *stdoutData;
    NSPipe *stdoutPipe;
    
    BOOL stdoutCollected;
    BOOL stderrCollected;
    
    NSData *stderrData;
    NSPipe *stderrPipe;
    
    BOOL taskTerminated;
}
@end


@interface LCSQuickExternalCommand (SubclassOverrides)
-(void)stderrDataAvailable:(NSData*)data;
-(void)stdoutDataAvailable:(NSData*)data;
-(void)collectResults;
@end
