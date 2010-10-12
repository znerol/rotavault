//
//  LCSDiskInfoCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistExternalCommand.h"


@interface LCSDiskInfoCommand : LCSPlistExternalCommand
+(LCSDiskInfoCommand*)commandWithDevicePath:(NSString*)devicePath;
-(id)initWithDevicePath:(NSString*)devicePath;
@end
