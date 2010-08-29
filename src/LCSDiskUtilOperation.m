//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSListDisksOperation
-(void)taskSetup
{
    self.extractKeyPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"AllDisks"];
    self.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:
                      [NSArray arrayWithObjects:@"list", @"-plist", nil]];
    self.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/sbin/diskutil"];
    [super taskSetup];
}
@end

@implementation LCSInformationForDiskOperation
@synthesize device;
-(id)init
{
    self = [super init];
    device = [[LCSOperationRequiredInputParameterMarker alloc] init];
    return self;
}

-(void)dealloc
{
    [(id)device release];
    [super dealloc];
}

-(void)taskSetup
{
    self.arguments = [[LCSSimpleOperationInputParameter alloc] initWithValue:
                      [NSArray arrayWithObjects:@"info", @"-plist", device.value, nil]];
    self.launchPath = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/usr/sbin/diskutil"];
    [super taskSetup];
}
@end

@implementation LCSMountOperation
@synthesize device;
-(id)init
{
    self = [super init];
    device = [[LCSOperationRequiredInputParameterMarker alloc] init];
    return self;
}

-(void)dealloc
{
    [(id)device release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    [task setArguments:[NSArray arrayWithObjects:@"mount",  device.value, nil]];
    [super taskSetup];
}
@end
