//
//  LCSDiskMountCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSQuickExternalCommand.h"


@interface LCSDiskMountCommand : LCSQuickExternalCommand
+(LCSDiskMountCommand*)commandWithDevicePath:(NSString*)devicePath;
-(id)initWithDevicePath:(NSString*)devicePath;
@end
