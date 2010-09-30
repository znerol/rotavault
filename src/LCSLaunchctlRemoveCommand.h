//
//  LCSLaunchctlRemoveCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSQuickExternalCommand.h"


@interface LCSLaunchctlRemoveCommand : LCSQuickExternalCommand
-(id)initWithLabel:(NSString*)label;
+(LCSLaunchctlRemoveCommand*)commandWithLabel:(NSString*)label;
@end
