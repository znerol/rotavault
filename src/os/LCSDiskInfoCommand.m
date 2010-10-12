//
//  LCSDiskInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskInfoCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskInfoCommand
+(LCSDiskInfoCommand*)commandWithDevicePath:(NSString*)devicePath
{
    return [[[LCSDiskInfoCommand alloc] initWithDevicePath:devicePath] autorelease];
}

-(id)initWithDevicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"info", @"-plist", [[devicePath copy] autorelease], nil]];
    
    return self;
}
@end
