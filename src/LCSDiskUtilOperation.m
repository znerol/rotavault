//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"


@implementation LCSDiskUtilOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments resultKeyPath:(NSString*)keyPath
{
    NSArray *args = [[NSArray arrayWithObjects:command, @"-plist", nil] arrayByAddingObjectsFromArray:arguments];
    self = [super initWithLaunchPath:@"/usr/sbin/diskutil" arguments:args resultKeyPath:keyPath];
    return self;
}
@end

@implementation LCSListDisksOperation
-(id)init
{
    self = [super initWithCommand:@"list" arguments:nil resultKeyPath:@"AllDisks"];
    return self;
}
@end

@implementation LCSInformationForDiskOperation
-(id)initWithDiskIdentifier:(NSString*)identifier
{
    self = [super initWithCommand:@"info" arguments:[NSArray arrayWithObject:identifier] resultKeyPath:nil];
    return self;
}
@end
