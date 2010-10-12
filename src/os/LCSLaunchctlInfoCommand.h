//
//  LCSLaunchctlInfoCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistExternalCommand.h"


@interface LCSLaunchctlInfoCommand : LCSPlistExternalCommand
-(id)initWithLabel:(NSString*)label;
+(LCSLaunchctlInfoCommand*)commandWithLabel:(NSString*)label;
@end
