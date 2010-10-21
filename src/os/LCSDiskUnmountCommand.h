//
//  LCSDiskUnmountCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 21.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSQuickExternalCommand.h"


@interface LCSDiskUnmountCommand : LCSQuickExternalCommand
+(LCSDiskUnmountCommand*)commandWithDevicePath:(NSString*)devicePath;
-(id)initWithDevicePath:(NSString*)devicePath;
@end
