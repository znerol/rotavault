//
//  LCSLaunchctlInfoCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSLaunchctlInfoCommand : LCSCommand
{
    NSString *label;
}

-(id)initWithLabel:(NSString*)aLabel;
+(LCSLaunchctlInfoCommand*)commandWithLabel:(NSString*)aLabel;
@end
