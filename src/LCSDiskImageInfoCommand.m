//
//  LCSDiskImageInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskImageInfoCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskImageInfoCommand
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"info", @"-plist", nil]];
    
    return self;
}
@end
