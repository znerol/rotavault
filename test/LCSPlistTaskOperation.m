//
//  LCSPlistTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperation.h"
#import "LCSInitMacros.h"
#import "LCSTaskOperationError.h"
#import "LCSOperationParameterMarker.h"


@implementation LCSPlistTaskOperation

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    launchPath = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(launchPath);
    
    arguments = [[LCSOperationOptionalInputParameterMarker alloc] initWithDefaultValue:[NSArray array]];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(arguments);
    return self;
}

-(void)dealloc
{
    [launchPath release];
    [arguments release];
    [super dealloc];
}

@synthesize launchPath;
@synthesize arguments;

-(void)taskSetup
{
    [task setLaunchPath:launchPath.inValue];
    [task setArguments:arguments.inValue];
}
@end
