//
//  LCSDiskMountCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskMountCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskMountCommand
+(LCSDiskMountCommand*)commandWithDevicePath:(NSString*)devicePath
{
    return [[[LCSDiskMountCommand alloc] initWithDevicePath:devicePath] autorelease];
}

-(id)initWithDevicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"mount", devicePath, nil]];
    
    return self;
}
@end
