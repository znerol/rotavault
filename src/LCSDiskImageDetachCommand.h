//
//  LCSDiskImageDetachCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


@interface LCSDiskImageDetachCommand : LCSExternalCommand
-(id)initWithDevicePath:(NSString*)devicePath;
+(LCSDiskImageDetachCommand*)commandWithDevicePath:(NSString*)devicePath;
@end
