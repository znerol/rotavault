//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSListDisksOperation
-(void)taskSetup
{
    self.extractKeyPath = [LCSSimpleOperationInputParameter parameterWithValue:@"AllDisks"];
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"list", @"-plist", nil]];
    [super taskSetup];
}
@end

@implementation LCSInformationForDiskOperation
@synthesize device;
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    device = [[LCSOperationRequiredInputParameterMarker alloc] init];

    LCSINIT_RELEASE_AND_RETURN_IF_NIL(device);
    return self;
}

-(void)dealloc
{
    [device release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"info", @"-plist", device.inValue, nil]];
    [super taskSetup];
}
@end

@implementation LCSMountOperation
@synthesize device;
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    device = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(device);
    return self;
}

-(void)dealloc
{
    [device release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"mount",  device.inValue, nil]];
    [super taskSetup];
}
@end

@implementation LCSUnmountOperation
@synthesize device;
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    device = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(device);
    return self;
}

-(void)dealloc
{
    [device release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"unmount",  device.inValue, nil]];
    [super taskSetup];
}
@end
