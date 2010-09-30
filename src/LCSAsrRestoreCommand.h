//
//  LCSAsrRestoreCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


@interface LCSAsrRestoreCommand : LCSExternalCommand {
    NSString *sourcedev;
    NSString *targetdev;
    
    NSPipe *stdoutPipe;
}
-(id)initWithSource:(NSString*)sourceDevice target:(NSString*)targetDevice;
+(LCSAsrRestoreCommand*)commandWithSource:(NSString*)sourceDevice target:(NSString*)targetDevice;

@end
