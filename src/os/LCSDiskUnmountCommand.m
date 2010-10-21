//
//  LCSDiskUnmountCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 21.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUnmountCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskUnmountCommand
+(LCSDiskUnmountCommand*)commandWithDevicePath:(NSString*)devicePath
{
    return [[[LCSDiskUnmountCommand alloc] initWithDevicePath:devicePath] autorelease];
}

-(id)initWithDevicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"unmount", devicePath, nil]];
    
    return self;
}
@end
