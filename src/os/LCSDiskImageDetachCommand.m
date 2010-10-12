//
//  LCSDiskImageDetachCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskImageDetachCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskImageDetachCommand
-(id)initWithDevicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"detach", devicePath, nil]];
    
    return self;
}

+(LCSDiskImageDetachCommand*)commandWithDevicePath:(NSString*)devicePath
{
    return [[[LCSDiskImageDetachCommand alloc] initWithDevicePath:devicePath] autorelease];
}
@end
