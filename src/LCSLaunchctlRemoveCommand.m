//
//  LCSLaunchctlRemoveCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlRemoveCommand.h"
#import "LCSInitMacros.h"


@implementation LCSLaunchctlRemoveCommand
-(id)initWithLabel:(NSString*)label
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"remove", label, nil]];
    
    return self;
}

+(LCSLaunchctlRemoveCommand*)commandWithLabel:(NSString*)label
{
    return [[[LCSLaunchctlRemoveCommand alloc] initWithLabel:label] autorelease];
}
@end
