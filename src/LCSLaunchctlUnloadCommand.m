//
//  LCSLaunchctlUnload.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlUnloadCommand.h"
#import "LCSInitMacros.h"


@implementation LCSLaunchctlUnloadCommand
-(id)initWithPath:(NSString*)plistPath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"unload", plistPath, nil]];
    
    return self;
}

+(LCSLaunchctlUnloadCommand*)commandWithPath:(NSString*)plistPath
{
    return [[[LCSLaunchctlUnloadCommand alloc] initWithPath:plistPath] autorelease];
}
@end
