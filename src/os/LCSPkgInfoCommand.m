//
//  LCSPkgInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 22.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPkgInfoCommand.h"
#import "LCSInitMacros.h"


@implementation LCSPkgInfoCommand
+ (LCSPkgInfoCommand*)commandWithPkgId:(NSString*)pkgid
{
    return [[[LCSPkgInfoCommand alloc] initWithPkgId:pkgid] autorelease];
}

- (id)initWithPkgId:(NSString*)pkgid
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/pkgutil"];
    [task setArguments:[NSArray arrayWithObjects:@"--pkg-info-plist", pkgid, nil]];
    
    return self;
}
@end
