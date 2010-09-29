//
//  LCSLaunchctlLoad.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlLoadCommand.h"
#import "LCSInitMacros.h"


@implementation LCSLaunchctlLoadCommand
-(id)initWithPath:(NSString*)plistPath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"load", plistPath, nil]];
    
    return self;
}

+(LCSLaunchctlLoadCommand*)commandWithPath:(NSString*)plistPath
{
    return [[[LCSLaunchctlLoadCommand alloc] initWithPath:plistPath] autorelease];
}
@end
