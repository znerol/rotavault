//
//  LCSHdiUtilPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilPlistOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSHdiInfoOperation
-(void)taskSetup
{
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"info", @"-plist", nil]];
    [super taskSetup];
}
@end

@implementation LCSAttachImageOperation

@synthesize path;

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    path = [[LCSOperationRequiredInputParameterMarker alloc] init];

    LCSINIT_RELEASE_AND_RETURN_IF_NIL(path);
    return self;
}

-(void)dealloc
{
    [path release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"attach", path.inValue, @"-plist", @"-nomount", nil]];
    [super taskSetup];
}
@end

@implementation LCSDetachImageOperation

@synthesize path;

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(path);
    return self;
}

-(void)dealloc
{
    [path release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"detach", path.inValue, nil]];
    [super taskSetup];
}
@end
