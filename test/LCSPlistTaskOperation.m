//
//  LCSPlistTaskOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperation.h"
#import "LCSTaskOperationError.h"
#import "LCSOperationParameterMarker.h"


@implementation LCSPlistTaskOperation

-(id)init
{
    self = [super init];
    launchPath = [[LCSOperationRequiredInputParameterMarker alloc] init];
    arguments = [[LCSOperationOptionalInputParameterMarker alloc] initWithDefaultValue:[NSArray array]];
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
