//
//  LCSHdiUtilPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilPlistOperation.h"
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
    self = [super init];
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
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
    [task setArguments:[NSArray arrayWithObjects:@"attach", path.value, @"-plist", @"-nomount", nil]];
    [super taskSetup];
}
@end

@implementation LCSDetachImageOperation

@synthesize path;

-(id)init
{
    self = [super init];
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
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
    [task setArguments:[NSArray arrayWithObjects:@"detach", path.value, nil]];
    [super taskSetup];
}
@end
